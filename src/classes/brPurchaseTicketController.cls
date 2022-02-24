/**
 * Created by mitfity on 17.07.2019.
 */

public without sharing class brPurchaseTicketController {


    @AuraEnabled
    public static Boolean registerForCoupledEvent(String eventId){
        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        BR_Event__c childEvt = [SELECT Id, Parent_Event__c FROM BR_Event__c WHERE Id=: eventId];
        List<BR_Participation__c> participations = [SELECT Id, User__c, Contact__c, Pre_Post_Doc__c,
                                                    GDPR_Certification__c, Fon_Sales_Order__c, AC_User_Segment__c,
                                                    Allergies__c, Food_Preferences__c, Vegetarian__c
                                                    FROM BR_Participation__c
                                                    WHERE Contact__c =: contactId
                                                    AND BR_Event__c=:childEvt.Parent_Event__c
                                                    AND Participate__c = 'yes'];
        if(!participations.isEmpty()){
            BR_Participation__c childParticipation = new BR_Participation__c();
            childParticipation.BR_Event__c = eventId;
            childParticipation.User__c = participations[0].User__c;
            childParticipation.Contact__c = participations[0].Contact__c;
            childParticipation.Pre_Post_Doc__c = participations[0].Pre_Post_Doc__c;
            childParticipation.GDPR_Certification__c = participations[0].GDPR_Certification__c;
            childParticipation.Participate__c = 'Yes';
            childParticipation.AC_User_Segment__c = participations[0].AC_User_Segment__c;
            childParticipation.Allergies__c = participations[0].Allergies__c;
            childParticipation.Food_Preferences__c = participations[0].Food_Preferences__c;
            childParticipation.Vegetarian__c = participations[0].Vegetarian__c;
            childParticipation.Registration_Date__c = Date.today();
            try{
                insert childParticipation;
            } catch(Exception e){
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Coupled Event Registration');
            }
        } else {
            return false;
        }

        return true;
    }

    @AuraEnabled
    public static Boolean sendRefundRequest(String eventId) {
        Boolean isSuccess = false;
        BR_Event__c evt = [SELECT Id, Name FROM BR_Event__c WHERE Id = :eventId];
        Contact con = ECRMUtils.getCurrentLoginContact();
        BR_Participation__c participant = [SELECT Id FROM BR_Participation__c WHERE BR_Event__c=:evt.Id AND Contact__c=:con.Id];
        participant.Refund_Requested__c = true;
        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, Type__c, Label FROM ServiceNow_Incident_Type__mdt WHERE DeveloperName = 'Refund_Request'];
        if (incidentTypes.size() == 1) {
            AACR_Error_Log__c log = ErrorHelper.buildErrorLog(con, incidentTypes[0].Id, incidentTypes[0].Label, evt.Name + ' Refund Request');
            String servUrl = Url.getSalesforceBaseUrl().toExternalForm();
            log.URL__c = servUrl + '/LiveEventsList?ac__id=' + eventId;
            try {
                insert log;
                sendRefundEmail(log.Id, evt.Name);
                update participant;
                isSuccess = true;
            } catch (Exception e) {
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Refund Request');
            }
        }

        return isSuccess;
    }

    private static Boolean sendRefundEmail(Id logId, String eventName) {
        OrgWideEmailAddress owa = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Meetings & Exhibits'];
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body, Subject FROM EmailTemplate WHERE Name = 'ServiceNow_Request_HTML'];
        AACR_Error_Log__c log = [SELECT Issue_Description__c, URL__c, CreatedDate, Contact_Name__c, Contact_Email__c, Contact_Phone__c, Contact_Method__c, Contact__c, Contact__r.Name, Contact__r.AACR_ID__c, Contact__r.Member_Type__c, Affiliation__c, Incident_Type__c, Incident_Id__c, Name FROM AACR_Error_Log__c WHERE Id = :logId];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!dateTime}', log.CreatedDate.format())
                .replace('{!userName}', log.Contact_Name__c != null ? log.Contact_Name__c : '')
                .replace('{!email}', log.Contact_Email__c != null ? log.Contact_Email__c : '')
                .replace('{!phone}', log.Contact_Phone__c != null ? log.Contact_Phone__c : '')
                .replace('{!contactMethod}', log.Contact_Method__c != null ? log.Contact_Method__c : '')
                .replace('{!aacrID}', log.Contact__c != null ? log.Contact__r.AACR_ID__c : '')
                .replace('{!memberType}', log.Contact__r.Member_Type__c != null ? log.Contact__r.Member_Type__c : '')
                .replace('{!account}', log.Affiliation__c != null ? log.Affiliation__c : '')
                .replace('{!url}', log.URL__c != null ? log.URL__c : '')
                .replace('{!incidentType}', log.Incident_Type__c != null ? log.Incident_Type__c : '')
                .replace('{!description}', log.Issue_Description__c != null ? log.Issue_Description__c : '')
                .replace('{!logName}', log.Name != null ? log.Name : '');

        email.setPlainTextBody(plainBody);
        email.setToAddresses(new List<String>{
                owa.Address
        });
        email.setTemplateId(emailTemplate.Id);
        email.setSubject(eventName + ' Refund Request');
        email.setSaveAsActivity(false);

        emails.add(email);

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (EmailException ex) {
                System.debug('error sending email: ' + ex.getMessage());
            }
        }

        return null;
    }

//    @AuraEnabled
//    public static Boolean checkForTicketTypes(Id eventId) {
//        System.debug('cehckForTicketTypes: ' + eventId);
//
//
//
//        return brEventParticipationManager.checkForTicketTypes(eventId);
//    }

    @AuraEnabled
    public static BR_Participation__c checkForTicket(Id eventId) {
        System.debug('cehckForTicketTypes: ' + eventId);

        if(brEventParticipationManager.checkForTicketTypes(eventId)){
            String contactId = ECRMUtils.getCurrentLoginUserContactId();
            List<BR_Participation__c> participations = [SELECT Id, Participate__c, Refund_Requested__c FROM BR_Participation__c WHERE BR_Event__c=:eventId AND Contact__c=:contactId];
            if(!participations.isEmpty()){
                return participations[0];
            }
        }


        return null;
    }

    @AuraEnabled
    public static String completePurchase(Id eventId){
        String contactId = ECRMUtils.getCurrentLoginUserContactId();
        List<BR_Participation__c> ticketsAwaitingPayment = [SELECT Id, Participate__c, Refund_Requested__c,
                                                            Fon_Sales_Order__c
                                                            FROM BR_Participation__c
                                                            WHERE BR_Event__c=:eventId AND Contact__c=:contactId
                                                            AND Participate__c = 'Awaiting Payment'];
        if(!ticketsAwaitingPayment.isEmpty()){
            return '/AACRPayment?id=m0U02000000GmuE&salesOrder=' + ticketsAwaitingPayment[0].Fon_Sales_Order__c;
        }

        return null;
    }

    /**
     * Generates purchase ticket user for specified event.
     *
     * @param eventId
     *
     * @return
     */
    @AuraEnabled
    public static String getTicketPurchaseUrl(Id eventId) {
//        brSecurity.performAccessCheck('read', BR_Event__c.SObjectType);
        String ticketPurchaseUrl;


        Savepoint savePoint = Database.setSavepoint();

        BrEvents_Settings__c joinProcessId = BrEvents_Settings__c.getValues('Join Process Id');
        BrEvents_Settings__c virtualJoinProcessId = BrEvents_Settings__c.getValues('Virtual Join Process Id');

        if (joinProcessId == null) {
            new AACRCustomException(eventId, 'Purchase process was not specified', 'brPurchaseTicketController.getTicketPurchaseUrl', 'Ticket Purchase');
            throw new brEventsException('Purchase process was not specified.');
        }


        List<Join_Process__mdt> jps = [SELECT Id FROM Join_Process__mdt WHERE Is_Event__c = true];
        Set<String> jpIds = new Set<String>();
        for (Join_Process__mdt jp : jps) {
            jpIds.add(jp.Id);
        }
        List<contact_last_accessed_step__c> lastSteps = [SELECT Step_Order__c FROM contact_last_accessed_step__c WHERE Contact__c = :ECRMUtils.getCurrentLoginUserContactId() AND JoinId__c IN:jpIds];
        for(contact_last_accessed_step__c step : lastSteps){
            step.Step_Order__c = 1;
        }
        update lastSteps;

        BR_Event__c evt = [SELECT Pre_verify_myAACR_Info__c, Registration_Form__c, Custom_Registration_URL__c, Event_Stage__c FROM BR_Event__c WHERE Id = :eventId];
        STring processId;
        if (evt.Event_Stage__c != 'In Person') {
            processId = virtualJoinProcessId.Value__c;
        } else {
            processId = joinProcessId.Value__c;
        }
        System.debug('event: ' + evt);

        try {
            String userType = UserInfo.getUserType();
            System.debug('User Type: ' + userType);
            if (userType != 'Guest') {

                if (evt.Registration_Form__c != 'Custom') {

                    Map<String, AC_Event_User_Segment__c> priceMap = brEventParticipationManager.getTicketPrice(eventId, UserInfo.getUserId());
                    System.debug('priceMap: ' + priceMap);
                    DOuble ticketPrice = 0.0;
                    AC_Event_User_Segment__c uSegment = null;
                    for (String key : priceMap.keySet()) {
                        if (priceMap.get(key).Early_Bird_Price__c != null && Datetime.now() < priceMap.get(key).Early_Bird_Price_Deadline__c) {
                            ticketPrice = priceMap.get(key).Early_Bird_Price__c;
                        }
                        else if(priceMap.get(key).On_Demand_Price__c!=null && Datetime.now() >= priceMap.get(key).On_Demand_Start_Date__c) {
                            System.debug('on demand: ' + priceMap.get(key).On_Demand_Price__c);
                            ticketPrice = priceMap.get(key).On_Demand_Price__c;
                        }
                        else {
                            ticketPrice = priceMap.get(key).Price__c;
                        }

                        uSegment = priceMap.get(key);
                    }


                    List<BR_Participation__c> participationResult = [
                            SELECT Fon_Sales_Order__c, Fon_Sales_Order__r.OrderApi__Status__c, Fon_Sales_Order__r.OrderApi__Posting_Status__c
                            FROM BR_Participation__c
                            WHERE User__c = :UserInfo.getUserId()
                            AND BR_Event__c = :eventId
                            LIMIT 1
                    ];
                    BR_Participation__c participation;
                    Id salesOrderId;

                    if (!participationResult.isEmpty()) {
                        participation = participationResult.get(0);
                    } else {
                        String contactId = ECRMUtils.getCurrentLoginUserContactId();
                        participation = new BR_Participation__c();
                        participation.BR_Event__c = eventId;
                        participation.Contact__c = contactId;
                        participation.User__c = UserInfo.getUserId();
                        participation.GDPR_Certification__c = GDPRCertificationController.getGDPRDefault(contactId);
                    }

                    OrderApi__Sales_Order__c oldSalesOrder = participation.Fon_Sales_Order__r;

                    if (oldSalesOrder != null) {
                        if (oldSalesOrder.OrderApi__Status__c == 'Closed' && oldSalesOrder.OrderApi__Posting_Status__c=='Posted') {
                            new AACRCustomException(eventId, 'Ticket has already been purchased', 'brPurchaseTicketController.getTicketPurchaseUrl', 'Ticket Purchase');
                            throw new brEventsException('You already bought a ticket.');
                        }

                        oldSalesOrder.OrderApi__Status__c = 'Cancelled';
                        update oldSalesOrder;
                    }

                    OrderApi__Sales_Order__c salesOrder = brEventParticipationManager.generateFonSalesOrderForTicket(uSegment, eventId);

                    if (salesOrder == null || salesOrder.Id == null) {
                        new AACRCustomException(eventId, 'Failed to create sales order', 'brPurchaseTicketController.getTicketPurchaseUrl', 'Ticket Purchase');
                        throw new brEventsException('Failed to create sales order for your purchase.');
                    }

                    participation.Fon_Sales_Order__c = salesOrder.Id;
                    upsert participation;
                    salesOrderId = salesOrder.Id;

                    if(evt.Custom_Registration_URL__c!=null){
                        ticketPurchaseUrl = evt.Custom_Registration_URL__c + '&salesOrder=' + salesOrderId;
                    } else {

                        Id networkId = Network.getNetworkId();

                        if (networkId == null) {
                            ticketPurchaseUrl = Url.getSalesforceBaseUrl().toExternalForm();
                        } else {
                            ConnectApi.Community currentCommunity = ConnectApi.Communities.getCommunity(networkId);

                            ticketPurchaseUrl = currentCommunity.siteUrl;
                        }

                        ticketPurchaseUrl += '/apex/JP_Container?id=' + processId + '&salesOrder=' + salesOrderId + '&eventId=' + eventId;
                    }
                } else {
                    System.debug('Registration form is custom');
                    if(evt.Pre_verify_myAACR_Info__c){
//                        String joinId = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'myAACR_Verify_Info' ].Id;
                        ticketPurchaseUrl = '/myAACRVerifyInfo?eventId=' + evt.Id;
                    } else {
                        String contactId = ECRMUtils.getCurrentLoginUserContactId();
                        ticketPurchaseUrl = evt.Custom_Registration_URL__c;
                        if(ticketPurchaseUrl.contains('?')){
                            ticketPurchaseUrl += '&contactid=' + contactId;
                        } else {
                            ticketPurchaseUrl += '?contactid=' + contactId;
                        }
                    }
                }
            } else {//guest user
                System.debug('user is a guest');
                Id networkId = Network.getNetworkId();

                if (networkId == null) {
                    ticketPurchaseUrl = Url.getSalesforceBaseUrl().toExternalForm();
                } else {
                    ConnectApi.Community currentCommunity = ConnectApi.Communities.getCommunity(networkId);
                    ticketPurchaseUrl = currentCommunity.siteUrl;
                }

                if (evt.Registration_Form__c != 'Custom') {
                    ticketPurchaseUrl += '/VirtualEventLogin?id=' + eventId ;
                    if(evt.Pre_verify_myAACR_Info__c){
                        ticketPurchaseUrl += '&startURL=/myAACRVerifyInfo?eventId=' + eventId;
                    } else {
                        ticketPurchaseUrl += '&startURL=/JP_Container?id=' + processId + '%26eventId=' + eventId;
                    }
                } else {
                    System.debug('Registration form is custom');
                    ticketPurchaseUrl += '/VirtualEventLogin?id=' + eventId;
                }
            }
            System.debug('ticketPurchaseURL: ' + ticketPurchaseUrl);
            return ticketPurchaseUrl;

        } catch (Exception e) {
            Database.rollback(savePoint);
            System.debug('msg: ' + e.getMessage());
            System.debug('stackTrace: ' + e.getStackTraceString());
            throw new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Ticket Purchase');
        }


    }

    /**
     * Retrieves event preferences form fields.
     *
     * @param salesOrderId
     *
     * @return
     */
//    @AuraEnabled
//    public static List<brIFieldWrap> getEventPreferencesFormFields(Id salesOrderId) {
//        brSecurity.performAccessCheck('read', BR_Event__c.SObjectType);
//
//        List<brIFieldWrap> formFields;
//
//        try {
//            Id eventId = brEventParticipationManager.getEventId(salesOrderId);
//            formFields = brEventParticipationManager.getEventPreferencesFormFields(eventId);
//        } catch (Exception e) {
//            throw new AuraHandledException(e.getMessage());
//        }
//
//        return formFields;
//    }

    @AuraEnabled
    public static FormFieldData getEventPreferencesFormFields(Id eventId, Id salesOrderId) {
        brSecurity.performAccessCheck('read', BR_Event__c.SObjectType);

        FormFieldData ffd = new FormFieldData();


        List<OrderApi__Sales_Order_Line__c> lines = [SELECT OrderApi__Item__r.AC_Event__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];
        eventId = lines[0].OrderApi__Item__r.AC_Event__c;


        System.debug('salesOrderId: ' + salesOrderId);
        System.debug('eventId: ' + eventId);

        Id contactId = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId].OrderApi__Contact__c;
        Id userId = [SELECT Id FROM User WHERE ContactId = :contactId].Id;

        List<brIFieldWrap> formFields;

        ffd.userId = userId;
        ffd.contactId = contactId;
        ffd.eventId = eventId;

        List<BR_Participation__c> participationResult = [SELECT Id FROM BR_Participation__c WHERE BR_Event__c = :eventId AND User__c = :userId];
        System.debug('participations: ' + participationResult);
        if (!participationResult.isEmpty()) {
            ffd.participationId = participationResult[0].Id;
        } else {
            ffd.participationId = null;
        }

        try {
//            Id eventId = brEventParticipationManager.getEventId(salesOrderId);
            formFields = brEventParticipationManager.getEventPreferencesFormFields(eventId, userId);
            System.debug('formFields size: ' + formFields.size());
            if (!formFields.isEmpty()) {
                ffd.fields = formFields;

            } else {
                ffd.fields = null;
            }

        } catch (Exception e) {
            System.debug('msg: ' + e.getMessage());
            System.debug('stackTrace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return ffd;
    }

    public class FormFieldData {
        @AuraEnabled public String userId;
        @AuraEnabled public String contactId;
        @AuraEnabled public String participationId;
        @AuraEnabled public String eventId;
        @AuraEnabled public List<brIFieldWrap> fields;
    }

    /**
     * Saves event preferences for current user.
     *
     * @param salesOrderId
     * @param preferencesJson
     */
//    @AuraEnabled
//    public static void saveEventPreferences(Id salesOrderId, String preferencesJson) {
//        brSecurity.performAccessCheck('read', BR_Event__c.SObjectType);
//
//        List<OrderApi__Sales_Order_Line__c> lines = [SELECT OrderApi__Item__r.AC_Event__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId];
//         Id eventId = lines[0].OrderApi__Item__r.AC_Event__c;
//
//        System.debug('salesOrderId: ' + salesOrderId);
//        System.debug('eventId: ' + eventId);
//
//        Id contactId = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId].OrderApi__Contact__c;
//        Id userId = [SELECT Id FROM User WHERE ContactId=: contactId].Id;
//
//        try {
////            Id eventId = brEventParticipationManager.getEventId(salesOrderId);
//            brEventParticipationManager.saveEventPreferences(eventId,userId,salesOrderId,preferencesJson);
//        } catch (Exception e) {
//            throw new AuraHandledException(e.getMessage());
//        }
//    }
}
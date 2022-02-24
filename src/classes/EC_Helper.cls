/**
 * Created by afaf.awad on 2/23/2021.
 */

public without sharing class EC_Helper {

    //public static BR_Event__c globalEvent = BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name = 'AACR Annual Meeting 2021'];
//    public static BR_Event__c globalEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Tumor Heterogeneity: From Single Cells to Clinical Impact'];

    public static EC_Event__c globalEvent = EC_Event__c.getOrgDefaults();


    public static EC_Exhibitor_Setting__c getECSettingFromContact(String contactId){
        return [SELECT Id, Exhibitor_Email__c, Verified_Email__c, Company__c FROM EC_Exhibitor_Setting__c
                WHERE Company__c IN (SELECT AccountId FROM Contact WHERE Id =: contactId) LIMIT 1];

    }

    public static EC_Order__c getOrderRecord(String orderId){
        return [
                SELECT Id,Countries__c, Attendee_Type__c, Institution_Type__c, Degrees__c, Organ_Sites__c, Research_Area_of_Expertise__c,
                        Order_Name__c, Order_Date__c, Name, Amount_Targeted__c, (SELECT Id FROM Exhibitor_Emails__r)
                FROM EC_Order__c
                WHERE Id = :orderId
        ];

    }

    public static List<EC_Order__c> getAllOrdersForAccount(){
        Contact contact = ECRMUtils.getCurrentLoginContact();

        return [
                SELECT Id, Name, Order_Date__c, Order_Name__c, Requested_By__r.FirstName, Requested_By__r.LastName,
                        Status__c
                FROM EC_Order__c
                WHERE Company__c = :contact.AccountId
                ORDER BY Name DESC
        ];
    }

    public static EC_Email__c getEmailRecordFromOrder(String orderId) {
        return [
                SELECT Id, Subject__c, Template_Body__c, Send_Test_To__c, Template_Name__c, Exhibitor_Setting__r.Reply_To__c, Call_to_Action__c, Action_Link__c,
                        Exhibitor_Setting__r.Verified_Email__c, Exhibitor_Setting__r.Verified_Domain__c, Exhibitor_Setting__r.Signature_1__c, Exhibitor_Setting__r.Signature_2__c,
                        Exhibitor_Setting__r.Signature_3__c, Exhibitor_Setting__r.Signature_4__c, Exhibitor_Setting__r.Signature_5__c,
                        Exhibitor_Setting__r.Signature_6__c, Exhibitor_Setting__r.Logo_Image_Id__c, Comments__c, EC_Order__r.Requested_By__r.Email,
                        EC_Order__r.Requested_By__r.FirstName,  EC_Order__r.Requested_By__r.LastName, EC_Order__c, EC_Order__r.Name, EC_Order__r.Order_Name__c,
                        EC_Order__r.Status__c
                FROM EC_Email__c
                WHERE EC_Order__c = :orderId
        ];
    }

    public static EC_Email__c getEmailRecord(String emailId){
        return [SELECT Id, Subject__c, Template_Body__c, Send_Test_To__c, Template_Name__c, Exhibitor_Setting__r.Reply_To__c, Call_to_Action__c, Action_Link__c,
                Exhibitor_Setting__r.Verified_Email__c, Exhibitor_Setting__r.Signature_1__c, Exhibitor_Setting__r.Signature_2__c,
                Exhibitor_Setting__r.Signature_3__c, Exhibitor_Setting__r.Signature_4__c, Exhibitor_Setting__r.Signature_5__c,
                Exhibitor_Setting__r.Signature_6__c, Exhibitor_Setting__r.Logo_Image_Id__c, Exhibitor_Setting__r.Sender_Name__c
                , Exhibitor_Setting__r.Company__r.Name, EC_Order__c
        FROM EC_Email__c WHERE Id=: emailId];

    }

    public static EC_Exhibitor_Setting__c getExhibitorSetting(String accountId){
        try {
            return [SELECT Id, Verified_Domain__c FROM EC_Exhibitor_Setting__c WHERE Company__c = :accountId];
        }catch(Exception e){
            return null;
        }
    }

    public static String getPreviousStep(String stepId, String joinProcess) {
        List<Process_Steps__mdt> currentStep = [
                SELECT Id, Step_Order__c, Step_Title__c, Description__c,
                        Join_Step__r.Component_Name__c, Join_Step__r.MasterLabel, Process__r.Is_Renewal__c, Process__c
                FROM Process_Steps__mdt
                WHERE Id = :stepId
                LIMIT 1
        ];

        Integer previousStep = currentStep[0].Step_Order__c.intValue() - 1;

        List<Process_Steps__mdt> newStep = [
                SELECT Id, Step_Order__c, Step_Title__c, Description__c, Join_Step__r.Component_Name__c,
                        Join_Step__r.MasterLabel, Process__r.Is_Renewal__c, Process__c
                FROM Process_Steps__mdt
                WHERE Step_Order__c = :previousStep and Process__r.DeveloperName = :joinProcess
                LIMIT 1
        ];

        return newStep[0].Id ;
    }


    @AuraEnabled
    public static Integer getTargetCount(String orderId) {

        EC_Order__c order = [SELECT Id, Status__c, Amount_Targeted__c FROM EC_Order__c WHERE Id=: orderId];

        if(order.Status__c != 'Complete') {
            List<BR_Participation__c> parts = queryTargetAudience(orderId, globalEvent.Event_Id__c);

            EC_Order__c updateOrder = new EC_Order__c(Id = orderId, Amount_Targeted__c = parts.size());

            System.debug('target count == ' + parts.size());

            update updateOrder;
            return parts.size();
        }else{
            return order.Amount_Targeted__c.intValue();
        }
    }


    public static List<BR_Participation__c> queryTargetAudience(String orderId, String eventId){

        EC_Order__c order = getOrderRecord(orderId);
        List<String> countryList = order.Countries__c != null ? order.Countries__c.split(';'): new List<String>();
        List<String> attendeeList = order.Attendee_Type__c != null ? order.Attendee_Type__c.split(';'): new List<String>();
        List<String> degreeList = order.Degrees__c != null ? order.Degrees__c.split(';'): new List<String>();
        List<String> institutionList = order.Institution_Type__c != null ? order.Institution_Type__c.split(';') : new List<String>();
        List<String> organList = order.Organ_Sites__c != null ? order.Organ_Sites__c.split(';') : new List<String>();
        List<String> researchList = order.Research_Area_of_Expertise__c != null ? order.Research_Area_of_Expertise__c.split(';')  : new List<String>();

        System.debug('coutnryList: ' + countryList);
        System.debug('attendeeList: ' + attendeeList);
        System.debug('degreeList: ' + degreeList);
        System.debug('institutionList: ' + institutionList);
        System.debug('organList: ' + organList);
        System.debug('researchList: ' + researchList);
        System.debug('eventId == ' + eventId);

        String querystring = 'SELECT Contact__r.Email, Contact__r.FirstName, Contact__r.LastName FROM BR_Participation__c WHERE BR_Event__c =: eventId AND Participate__c = \'Yes\' AND GDPR_Certification__c = TRUE AND Contact__c IN (SELECT Id FROM Contact WHERE';
        //NEED TO ADD END PARANTHESIS FOR SUBQUERY OF CONTACTS
        if(countryList.size()>0 && countryList.size() < 3) {
            if(countryList.size()==1 && countryList.contains('International')){
                querystring += ' MailingCountry NOT IN (\'Canada\', \'United States\') ';
            }else if(countryList.contains('Canada') && countryList.contains('International')){
                querystring += ' MailingCountry NOT IN (\'United States\') ';
            }else if(countryList.contains('United States') && countryList.contains('International')) {
                querystring += ' MailingCountry NOT IN (\'Canada\') ';
            }else {
                querystring += ' MailingCountry IN: countryList';
            }
            if(degreeList.size() > 0 || institutionList.size() > 0 || organList.size() > 0 || researchList.size() > 0 || attendeeList.size() > 0) {
                querystring += ' AND ';
            }
        }

        if ( attendeeList.size() > 0 ) {
            List<String> recordTypes = new List<String>();
            If ( attendeeList.contains('Non-Members') ) {
                recordTypes.add('Nonmember');
                recordTypes.add('Prior Member');
            }
            If ( attendeeList.contains('Members') ) {
                recordTypes.add('Member');
            }
            System.debug('record Types:: ' + recordTypes);

            querystring += ' RecordType.Name IN: recordTypes';
            if(degreeList.size() > 0 || institutionList.size() > 0 || organList.size() > 0 || researchList.size() > 0) {
                querystring += ' AND (';
            }
        }else if(degreeList.size() > 0 || institutionList.size() > 0 || organList.size() > 0 || researchList.size() > 0){
            querystring += '(';
        }

        if ( degreeList.size() > 0 ) {
            String degreeString='';

            for(String d : degreeList){
                degreeString += '\'' + d + '\',';
            }

            degreeString = degreeString.removeEnd(',');

            querystring += 'Degrees_Held__c INCLUDES (' + degreeString + ')';
        }

        if(institutionList.size()>0) {
            if(degreeList.size() > 0 ){
                querystring += ' OR ';
            }
            querystring += 'Account.Institution_Type__c IN: institutionList';
        }

        if(organList.size()>0) {
            if(degreeList.size() >0 || institutionList.size() >0){
                querystring += ' OR ';
            }
            //Turn List to String for multipicklist field to use with INCLUDES
//            String organString = String.join(organList, ',');

            String organString='';

            for(String o : organList){
                organString += '\'' + o + '\',';
            }

            organString = organString.removeEnd(',');
            System.debug('organString: ' + organString);

            querystring += 'Organ_Sites__c INCLUDES (' + organString + ')';
        }

        if(researchList.size()>0) {
            if(degreeList.size() >0 || institutionList.size() >0 || organList.size() >0){
                querystring += ' OR ';
            }
            querystring += 'Primary_Research_Area_of_Expertise__c IN: researchList';
        }

        if(degreeList.size() > 0 || institutionList.size() > 0 || organList.size() > 0 || researchList.size() > 0) {
            querystring += ')';
        }

        querystring += ')';

        If(querystring.containsIgnoreCase('(SELECT Id FROM Contact WHERE)')){
            querystring= querystring.remove('AND Contact__c IN (SELECT Id FROM Contact WHERE)');
            System.debug('removing chars');
        }

        System.debug('queryString: ' + queryString);

        return Database.query(querystring);
    }

    public static EC_Order__c createNewOrder(){
        EC_Order__c order = new EC_Order__c();
        Contact contact = ECRMUtils.getCurrentLoginContact();
        order.Requested_By__c = contact.Id;
        order.Status__c='Incomplete';
        order.Order_Date__c = Date.today();
        order.Company__c = contact.AccountId;
        order.Exhibitor_Setting__c = getECSettingFromContact(contact.Id).Id;

        return order;
    }

    @AuraEnabled
    public static Boolean approveBudget(String orderId){

        Time_Slot__c timeSlot = [SELECT Id, Status__c FROM Time_Slot__c WHERE EC_Order__c =: orderId];

        timeSlot.Status__c = 'Scheduled';
        EC_Order__c order = new EC_Order__c(Id = orderId, Status__c = 'Approved');

        try {
            update timeSlot;
            update order;
            return true;
        }catch (Exception e){
            System.debug('Could not update statuses :: ' + e.getMessage());
            return false;
        }

    }

    @AuraEnabled
    public static String buildEmailTemplate(String emailId) {

        System.debug('eventId = ' + globalEvent.Event_Id__c);
        try {
            EC_Email__c email = getEmailRecord(emailId);
            System.debug('email == ' + email);
            String templateBody = email.Template_Body__c;

            Network network = [SELECT Id FROM Network WHERE Name ='AACR Community' ];
            String siteURL = Test.isRunningTest() ? 'https://uat-aacr.cs195.force.com' : ConnectApi.Communities.getCommunity(network.Id).siteURL;

            String url = siteURL + '/EC_OptOutEmails?c__eventId=' + globalEvent.Event_Id__c;
            String footer = '</br> <div style="text-align: center;" width="100%"> <p style="font-size: .7rem">You received this e-mail because you agreed to receive exhibitor communications as part of your AACR meeting registration. If you no longer wish to receive these exhibitor communications, <a href="' + url + '">click here</a> to unsubscribe.</p> </div> </body>';

            System.debug('baseURL = ' + url);


            If(templateBody.contains('</body>')) {
                return templateBody.replace('</body>', footer);
            }

            return templateBody + footer;
        } catch (Exception e) {
            System.debug('Could not create email template: ' + e.getMessage());
            return null;
        }


    }



    public static void sendOverBudgetEmail(Time_Slot__c timeSlot, Decimal total, Integer totalCount){

        try {
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Exhibitor_Email_Over_Budget'];

            String body = emailTemplate.HtmlValue;
            String name = timeSlot.EC_Order__r.Requested_By__r.FirstName + ' ' + timeSlot.EC_Order__r.Requested_By__r.LastName;
            Datetime startDateTime = Datetime.newInstance(Date.today(), timeSlot.Start_Time__c);

            body = emailTemplate.HtmlValue.replace('{!Name}', name )
                    .replace('{!maxbudget}', '$' + String.valueOf(timeSlot.EC_Email__r.Exhibitor_Setting__r.Max_Budget__c))
                    .replace('{!total}', '$' + String.valueOf(total))
                    .replace('{!StartTime}', startDateTime.format('h:mm a'))
                    .replace('{!orderId}', timeSlot.EC_Order__c)
                    .replace('{!EC_Order__c.Order_Name__c}', timeSlot.EC_Order__r.Order_Name__c)
                    .replace('{!EC_Order__c.Name}', timeSlot.EC_Order__r.Name)
                    .replace('{!EC_Order__c.Id}', timeSlot.EC_Order__c)
                    .replace('{!EC_Order__c.Status}', timeSlot.EC_Order__r.Status__c);

            System.debug('returning email template body: ' + body);
            //Send email
            Map<String,String> emailMap = new Map<String, String>();
            emailMap.put(timeSlot.EC_Order__r.Requested_By__r.Email, name);

                callSendGridAPI(emailMap, 'Your Order is over budget', 'marketing@aacr.org', 'AACR', 'marketing@aacr.org', body);

            //update status
            EC_Order__c order = new EC_Order__c(Id = timeSlot.EC_Order__c, Status__c='Over Budget', Amount_Targeted__c = totalCount);
            timeSlot.Status__c = 'Over Budget';
            update order;
            update timeSlot;

        } catch (Exception e) {
            System.debug('Could not send Over Budget email: ' + e.getMessage());
        }

    }

    public static void sendCancelEmail(Time_Slot__c timeSlot){

//        List<BR_Participation__c> parts = EC_Helper.queryTargetAudience(timeSlot.EC_Order__c, timeSlot.EC_Schedule__r.Event__c);
//        OrderApi__Item__c ecItem = [Select Id, Name, OrderApi__Price__c from OrderApi__Item__c WHERE Name = 'Exhibitor Request'];

        try {
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Exhibitor_Email_Cancelled'];

            String body = emailTemplate.HtmlValue;
            String name = timeSlot.EC_Order__r.Requested_By__r.FirstName + ' ' + timeSlot.EC_Order__r.Requested_By__r.LastName;
            Datetime startDateTime = Datetime.newInstance(Date.today(), timeSlot.Start_Time__c);

            body = emailTemplate.HtmlValue.replace('{!Name}', name )
                    .replace('{!orderId}', timeSlot.EC_Order__c)
                    .replace('{!StartTime}', startDateTime.format('h:mm a'))
                    .replace('{!EC_Order__c.Order_Name__c}', timeSlot.EC_Order__r.Order_Name__c)
                    .replace('{!EC_Order__c.Name}', timeSlot.EC_Order__r.Name)
                    .replace('{!EC_Order__c.Id}', timeSlot.EC_Order__c)
                    .replace('{!EC_Order__c.Status}', timeSlot.EC_Order__r.Status__c);

            System.debug('returning email template body: ' + body);
            //Send email
            Map<String,String> emailMap = new Map<String, String>();
            emailMap.put(timeSlot.EC_Order__r.Requested_By__r.Email, name);

                callSendGridAPI(emailMap, 'Your Order is over budget and cancelled', 'marketing@aacr.org', 'AACR', 'marketing@aacr.org', body);
            //update status
            EC_Order__c order = new EC_Order__c(Id = timeSlot.EC_Order__c, Status__c='Cancelled');
            timeSlot.Status__c = 'Cancelled';
            update order;
            update timeSlot;

        } catch (Exception e) {
            System.debug('Could not send Cancelled EC email: ' + e.getMessage());
        }

    }

    @Future(Callout=true)
    public static void callSendGridAPI(Map<String, String> emailMap, String subject, String fromEmail, String fromWho, String replyTo, String emailContent){
        PlatformEmailService.callSendGridAPI(emailMap, subject, fromEmail, fromWho, replyTo , emailContent);
    }

}
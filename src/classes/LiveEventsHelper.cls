/**
 * Created by lauren.lezberg on 4/15/2020.
 */

public without sharing class LiveEventsHelper {

    public static Map<String, String> getEventImageMap(Set<Id> items_ids){
//        System.debug('getEventImageMap: '  + items_ids);
//        Map<String, String> imgMap = new Map<String, String>();
//        if(items_ids.size() == 0 || !BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', null))
//            return imgMap;
//
//        List<ContentDocumentLink> chatterFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
//        FROM ContentDocumentLink WHERE LinkedEntityId IN :items_ids];
//
//        System.debug('chatterFiles: '  + chatterFiles);
//
//        if(!chatterFiles.isEmpty()) {
//            Map<Id, Id> contentDocumentEntityMap = new Map<Id, Id>();
//            Set<Id> versionIds = new Set<Id>();
//
//            for (ContentDocumentLink file : chatterFiles) {
//                if (!contentDocumentEntityMap.containsKey(file.ContentDocumentId)) {
//                    versionIds.add(file.ContentDocument.LatestPublishedVersionId);
//                    contentDocumentEntityMap.put(file.ContentDocumentId, file.LinkedEntityId);
//                }
//            }
//            System.debug('versionsIds: '  + versionIds);
//            System.debug('contentDocumentEntityMap: '  + contentDocumentEntityMap);
//
//            List<ContentDistribution> distributions = [Select Id, ContentDocumentId, ContentDownloadUrl, ContentVersion.Title from ContentDistribution WHERE ContentVersionId IN:versionIds];
//            System.debug('distributions: '  + distributions);
//            for (ContentDistribution d : distributions) {
//                imgMap.put(contentDocumentEntityMap.get(d.ContentDocumentId), d.ContentDownloadUrl);
//            }
//            System.debug('imgMap: '  + imgMap);
//        }
//
//        return imgMap;
        System.debug('getEventImageMap: '  + items_ids);
        Map<String, String> imgMap = new Map<String, String>();
        if(items_ids.size() == 0 || !BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', null))
            return imgMap;

        List<ContentDocumentLink> chatterFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId IN :items_ids];

        System.debug('chatterFiles: '  + chatterFiles);

        if(!chatterFiles.isEmpty()) {
            Map<Id, Id> contentDocumentEntityMap = new Map<Id, Id>();
            Set<Id> versionIds = new Set<Id>();

            for (ContentDocumentLink file : chatterFiles) {
                if (!contentDocumentEntityMap.containsKey(file.ContentDocumentId)) {
                    versionIds.add(file.ContentDocument.LatestPublishedVersionId);
                    contentDocumentEntityMap.put(file.ContentDocument.LatestPublishedVersionId, file.LinkedEntityId);
                }
            }
            System.debug('versionsIds: '  + versionIds);
            System.debug('contentDocumentEntityMap: '  + contentDocumentEntityMap);

            List<ContentDistribution> distributions = [Select Id, ContentDocumentId, ContentDownloadUrl, ContentVersionId, ContentVersion.Title, RelatedRecordId from ContentDistribution WHERE ContentVersionId IN:versionIds];
            System.debug('distributions: '  + distributions);
            for (ContentDistribution d : distributions) {
                imgMap.put(contentDocumentEntityMap.get(d.ContentVersionId), d.ContentDownloadUrl);
            }
            System.debug('imgMap: '  + imgMap);
        }

        return imgMap;
    }


    public static void sendRegistrationConfirmationEmail(List<BR_Participation__c> participations, List<String> ccs){

        //SAVED FOR SPONSOR Display_on_Confirmation_Email__c AND Show_Confirmation_Email_Logos__c
        participations = [SELECT BR_Event__r.Venue__c, BR_Event__c, Contact__c, Contact__r.Name, Contact__r.Salutation, BR_Event__r.Portal_Event_Link__c,
                            BR_Event__r.Name, BR_Event__r.Hide_Date_Time__c, BR_Event__r.Start_Date__c, BR_Event__r.End_Date__c, BR_Event__r.Main_Image_Filename__c,
                            BR_Event__r.Registration_Confirmation_Message__c, BR_Event__r.Virtual_Venue__r.Virtual_Instructions__c,
                            BR_Event__r.Venue__r.Name, BR_Event__r.Display_on_Confirmation_Email__c, BR_Event__r.Show_Confirmation_Email_Logos__c
                            FROM BR_Participation__c WHERE Id IN: participations];

//        participations = [SELECT BR_Event__r.Venue__c, BR_Event__c, Contact__c, Contact__r.Name, Contact__r.Salutation, BR_Event__r.Portal_Event_Link__c,
//                            BR_Event__r.Name, BR_Event__r.Hide_Date_Time__c, BR_Event__r.Start_Date__c, BR_Event__r.End_Date__c, BR_Event__r.Main_Image_Filename__c,
//                            BR_Event__r.Registration_Confirmation_Message__c, BR_Event__r.Virtual_Venue__r.Virtual_Instructions__c,
//                            BR_Event__r.Venue__r.Name
//                            FROM BR_Participation__c WHERE Id IN: participations];

        Set<Id> eventIds = new Set<Id>();
        for(BR_Participation__c p : participations){
            eventIds.add(p.BR_Event__c);
        }


        Map<String, String> imgMap = getEventImageMap(eventIds);
        System.debug('imgMap: ' + imgMap);

        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();

        EmailTemplate et = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name='Live Registration Confirmation'];

        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');


        for(BR_Participation__c participation : participations) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(participation.Contact__c);
            message.setWhatId(participation.BR_Event__c);
            message.setOrgWideEmailAddressId(orgWideEmailId);
            message.setCcAddresses(ccs);
            message.setSubject('Thank you for registering for ' + participation.BR_Event__r.Name);
            message.setTreatTargetObjectAsRecipient(true);

            String vlocation = '<a href="https://' + participation.BR_Event__r.Portal_Event_Link__c + '">MyAACR</a>';

            String body;
            System.debug('participation event: ' + participation.BR_Event__c);
//            if(participation.BR_Event__r.Venue__c==null){ //virtual template
                body = et.HtmlValue.replace('{!Contact.Name}', participation.Contact__c!=null?participation.Contact__r.Name:'')
                        .replace('{!imgLocation}', imgMap.get(participation.BR_Event__c)!=null?imgMap.get(participation.BR_Event__c):'')
                        .replace('{!BR_Event__c.Name}', participation.BR_Event__r.Name)
                        .replace('{!BR_Event__c.Id}', participation.BR_Event__c)
                        .replace('{!eventDates}', participation.BR_Event__r.Hide_Date_Time__c?'':'Dates: ' + participation.BR_Event__r.Start_Date__c.formatLong() + ' - ' +  participation.BR_Event__r.End_Date__c.formatLong() + ' (ET)')
//                        .replace('{!BR_Event__c.Start_Date__c}', participation.BR_Event__r.Start_Date__c.formatLong())
//                        .replace('{!BR_Event__c.End_Date__c}', participation.BR_Event__r.End_Date__c.formatLong())
//                        .replace('{!BR_Event__c.Hide_Date_Time__c}', participation.BR_Event__r.Hide_Date_Time__c?'true':'false')
                        .replace('{!BR_Event__c.Venue__c}', participation.BR_Event__r.Venue__c==null? vlocation:participation.BR_Event__r.Venue__r.Name)
                        .replace('{!BR_Event__c.Registration_Confirmation_Message__c}', participation.BR_Event__r.Registration_Confirmation_Message__c)
                        .replace('{!Virtual_Venue_Instructions}', participation.BR_Event__r.Venue__c==null ? Label.Virtual_Venue_Instructions : '')
//                        .replace('{!Sponsors}', EventSponsorshipController.buildLogosInEmail(participation.BR_Event__c));
                        .replace('{!Sponsors}', EventSponsorshipController.buildLogosInEmail(participation.BR_Event__c, participation.BR_Event__r.Display_on_Confirmation_Email__c, participation.BR_Event__r.Show_Confirmation_Email_Logos__c)); // SAVE FOR NEW SPONSOR BUTTONS

                message.setHtmlBody(body);
                message.setTemplateId(et.Id);
            messages.add(message);
        }

        if (!messages.isEmpty()) {
            try {
                Messaging.sendEmail(messages);
            } catch (EmailException ex) {
                new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Event Registration');
            }
        }
    }

    public static Boolean cancelEvent(Id eventId){
        BR_Event__c evt = [SELECT Id, Cancelled__c, RecordTypeId FROM BR_Event__c WHERE Id=: eventId];
        evt.Cancelled__c = true;
//        evt.Draft__c = true;
        evt.RecordTypeId = Schema.SObjectType.BR_Event__c.getRecordTypeInfosByName().get('Cancelled').getRecordTypeId();

        try{
            Database.update(evt);

            notifyFinanceOfCancellation(eventId);

            return true;
        } catch(Exception e){
            System.debug('Could not cancel event: ' + e.getMessage());

            throw new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Event Cancel');
        }
    }


    private static void notifyFinanceOfCancellation(Id eventId){
        BR_Event__c evt = [SELECT Id, Name FROM BR_Event__c WHERE Id=:eventId];
        List<BR_Participation__c> cancelledParticipations = [SELECT Id, Contact__r.Name, Fon_Sales_Order__r.Name, Fon_Sales_Order__c FROM BR_Participation__c WHERE BR_Event__c=:eventId AND BR_Event__r.Cancelled__c=true AND Participate__c = 'Yes'];
        Set<Id> SOIds = new Set<Id>();
        for(BR_Participation__c par : cancelledParticipations){
            SOIds.add(par.Fon_Sales_Order__c);
        }

        List<OrderApi__Receipt_Line__c> receiptLines = [SELECT Name, OrderApi__Receipt__r.Name, OrderApi__Receipt__r.OrderApi__Contact__r.Account_Name__c, OrderApi__Item__r.Name, OrderApi__Receipt__r.OrderApi__Total__c, OrderApi__GL_Account__r.Name, OrderApi__Receipt__r.OrderApi__Posted_Date__c, OrderApi__Receipt__r.OrderApi__Contact__r.Name, OrderApi__Receipt__r.OrderApi__Contact__c, OrderApi__Receipt__r.OrderApi__Contact__r.AACR_ID__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Item__r.AC_Event__c =:eventId AND OrderApi__Receipt__r.OrderApi__Total__c!=0.0];

        string header = 'Receipt Number, Receipt Line Number, Account Name, Item, Total, GL Account, Posted Date, Contact, SF ContactId, AACR ID \n';
        string finalstr = header ;
        for(OrderApi__Receipt_Line__c line : receiptLines)
        {

            string recordString = line.OrderApi__Receipt__r.Name+','+line.OrderApi__Receipt__r.Name+','+line.OrderApi__Receipt__r.OrderApi__Contact__r.Account_Name__c+','+ line.OrderApi__Item__r.Name+','+line.OrderApi__Receipt__r.OrderApi__Total__c+','+line.OrderApi__GL_Account__r.Name+','+ Date.valueOf(line.OrderApi__Receipt__r.OrderApi__Posted_Date__c)+','+line.OrderApi__Receipt__r.OrderApi__Contact__r.Name +','+line.OrderApi__Receipt__r.OrderApi__Contact__c+','+ line.OrderApi__Receipt__r.OrderApi__Contact__r.AACR_ID__c+'\n';

            finalstr = finalstr +recordString;

        }

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = evt.Name.remove(' ') + 'RefundCandidates.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = evt.Name.remove(' ') + 'RefundCandidates'; // Display name of the files
        conVer.VersionData =  Blob.valueOf(finalstr); // converting your binary string to Blog
        insert conVer;
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = eventId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'I';
        insert conDocLink;



        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= evt.Name.remove(' ') + 'RefundCandidates.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);


        EmailTemplate et = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name='Event Cancellation'];

        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {Label.Finance_Notification_Email};
        String subject ='Event Cancellation - ' + evt.Name;
        email.setTemplateId(et.Id);


        String body = et.HtmlValue;
        body = et.HtmlValue.replace('{!eventName}', evt.Name);
        email.setHtmlBody(body);

        body = et.Body.replace('{!eventName}', evt.Name);
        email.setPlainTextBody(body);

        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        try {
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    email
            });
        } catch(Exception e){
            new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Event Cancellation Notification');
        }
    }


    public static Boolean deleteEvent(Id eventId){

        try{
            Database.delete(eventId);

            return false;
        }catch(Exception e){
            System.debug('Could not delete event: ' + e.getMessage());

            throw new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Event Delete');
        }
    }


    public static Boolean deleteEventUserSegments(Id eventId){
        List<AC_Event_User_Segment__c> eventSegments = [SELECT Id FROM AC_Event_User_Segment__c WHERE AC_Event__c=:eventId];

        if(!eventSegments.isEmpty()) {

            try {
                Database.delete(eventSegments);

                return false;
            } catch (Exception e) {
                System.debug('Could not delete event user segments: ' + e.getMessage());
                throw new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'UserSegment Delete');

            }
        }

        return false;

    }

    public static Boolean deleteEventTicket(Id eventId){
        List<OrderApi__Item__c> ticketItems = [SELECT Id FROM OrderApi__Item__c WHERE AC_Event__c=:eventId];
        try{
            delete ticketItems;
            return false;
        }catch(Exception e){
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Ticket Delete');
            return true;
        }

    }

    public static Boolean deleteEventSchedule(Id eventId){
        Map<Id, AACR_Session__c> sessionMap = new Map<Id, AACR_Session__c>([SELECT Id FROM AACR_Session__c WHERE Event__c =: eventId]);

//        if(!sessionMap.isEmpty()) {

            List<Id> sessionIds = new List<Id>();
            sessionIds.addAll(sessionMap.keySet());

            List<Session_Speaker__c> speakers = [SELECT Id FROM Session_Speaker__c WHERE Event__c = :eventId OR Session__c IN:sessionIds];



            try {
                if(!speakers.isEmpty()) {
                    Database.delete(speakers);
                }


                if(!sessionIds.isEmpty()) {
                    Database.delete(sessionIds);
                }

                return false;
            } catch (Exception e) {
                System.debug('Could not delete event schedule: ' + e.getMessage());
                throw new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Event Schedule');

            }


//        }


//        return false;
    }

}
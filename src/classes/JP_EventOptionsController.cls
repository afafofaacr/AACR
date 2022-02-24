/**
 * Created by lauren.lezberg on 11/12/2019.
 */

public with sharing class JP_EventOptionsController {


    @AuraEnabled
    public static Boolean validateZoomData(String eventId, String userId, String venueId){
        Boolean isValid = true;
        BR_Event__c evt = [SELECT Start_Date__c FROM BR_Event__c WHERE Id=:eventId];

        List<Virtual_Event_Details__c> veds = [SELECT Id FROM Virtual_Event_Details__c
                                                WHERE Zoom_User_Id__c=:userId AND Event__r.Virtual_Venue__c=:venueId
                                                AND Event__r.Start_Date__c=: evt.Start_Date__c];
        if(!veds.isEmpty()){
            isValid = false;
        }

        return isValid;
    }

    /**
     * @purpose Retrieve specific event image file ids
     *
     * @param eventId
     *
     * @return List of file ids
     */
    @AuraEnabled
    public static List<String> getEventImages(String eventId){
        System.debug('--getting event images for eventId: ' + eventId);
        List<String> imgs = new List<String>(2);
        if(String.isBlank(eventId)){
            new AACRCustomException('Null event Id','JP_EventOptionsController.getEventImages()', 'Event Builder');
            return imgs;
        }
        List<BR_Event__c> events = [SELECT Main_Image_Filename__c,List_Image_Filename__c FROM BR_Event__c WHERE Id=: eventId ];
        List<ContentDocumentLink> docs = [SELECT ContentDocument.Title, ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =: eventId];
        for(ContentDocumentLink dl : docs){
            if(dl.ContentDocument.Title == events[0].Main_Image_Filename__c){
                imgs[0] = dl.ContentDocumentId;
            }
            if(dl.ContentDocument.Title == events[0].List_Image_Filename__c){
                imgs[1] = dl.ContentDocumentId;
            }
        }
        System.debug('--fileIds: ' + imgs);
        return imgs;

    }

    @AuraEnabled
    public static List<String> getFieldsInFieldset(String fieldsetName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Contact');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        system.debug('fieldSetMemberList ====>' + fieldSetMemberList);

        List<String> fields = new List<String>();
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            fields.add(fieldSetMemberObj.getLabel());
        }

        return fields;
    }

    /**
     * @purpose Set main/list image to public visibility so that portal users can see the image in the events list and detail
     *
     * @param fileId
     */
    @AuraEnabled
    public static void setImageToPublic(String fileId, String eventId, String type){
        System.debug('setImageToPublic...');

        BR_Event__c evt = [SELECT List_Image_Filename__c FROM BR_Event__c WHERE Id=: eventId];
        System.debug('evt: ' + evt);

        if(fileId!=null) {
            List<ContentDocumentLink> cdls = [SELECT Visibility, Id, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId = :fileId];
            for (ContentDocumentLink link : cdls) {
                link.Visibility = 'AllUsers';
            }

            ContentVersion cv = [select id, ContentDocumentId, Title from contentversion where contentdocumentid = :fileId];

            ContentDistribution cd = new ContentDistribution();
            cd.Name = cdls[0].ContentDocument.Title;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;


            try {
                update cdls;
                insert cd;

                if(type == 'list') {
                    cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE Id = :cd.Id];

                    List<OrderApi__Item__c> tickets = [SELECT Id,OrderApi__Image_Path__c FROM OrderApi__Item__c WHERE AC_Event__c = :eventId];
                    if (!tickets.isEmpty()) {
                        if (tickets[0].OrderApi__Image_Path__c != cd.ContentDownloadUrl) {
                            tickets[0].OrderApi__Image_Path__c = cd.ContentDownloadUrl;
                            update tickets[0];
                        }
                    }

                }

            } catch (Exception e) {
                new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'Event Builder');
            }
        } else {
            new AACRCustomException('Null file Id','JP_EventOptionsController.setImagesToPublic()', 'Event Builder');
        }
    }



    /**
     * @purpose Save event
     *
     * @param event
     */
    @AuraEnabled
    public static void saveEvent(BR_Event__c event){
        System.debug('--saving event: ' + event);
        if(null == event.BR_Events_Zone__c){
            System.debug('---setting default zone');
            List<BR_Events_Zone__c> zones = [SELECT Id FROM BR_Events_Zone__c WHERE Is_Default__c = true];
            event.BR_Events_Zone__c = zones[0].Id;
        }
        try {
            update event;
        } catch (DmlException e) {
            System.debug('Could not update event: ' + e.getMessage());
            new AACRCustomException(event.Id,e.getMessage(), e.getStackTraceString(), 'Event Builder');
        }

    }


    /**
     * @purpose Set event image names on event object based on uploaded files
     *
     * @param eventId
     * @param fileName
     * @param type
     */
    @AuraEnabled
    public static void setEventImage(String eventId, String fileName, String type ){
        System.debug('setting ' + type + ' image file to ' + fileName + ' for eventId: ' + eventId);
        if(String.isBlank(eventId)){
            new AACRCustomException('Null event Id','JP_EventOptionsController.setEventImage()', 'Event Builder');
            return;
        }
        List<BR_Event__c> events = [SELECT Main_Image_Filename__c,List_Image_Filename__c FROM BR_Event__c WHERE Id=: eventId ];
        if(type == 'main'){
            events[0].Main_Image_Filename__c = fileName;
        } else {
            events[0].List_Image_Filename__c = fileName;
        }
        try{
            update events[0];
        } catch(DmlException e ){
            System.debug('Could not set event images: ' + e.getMessage());
            new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Event Builder');
        }
    }
}
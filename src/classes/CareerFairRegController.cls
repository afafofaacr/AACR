/**
 * Created by lauren.lezberg on 2/12/2021.
 */

public without sharing class CareerFairRegController {
    public String imgURL {get;set;}

    public CareerFairRegController(){
        imgURL = '/resource/BrEvents/images/main-banner.jpg';
        String eventId = APexPages.currentPage().getParameters().get('eventId');
        BR_Event__c evt = [SELECT Main_Image_Filename__c FROM BR_Event__c WHERE Id=:eventId];
        Set<Id> items_ids = new Set<Id>();
        items_ids.add(eventId);
        Map<Id, Map<String, String>> itemsAttachments = BrEventsHelper.getAttachmentsForItems(items_ids);
        System.debug('itemsAttachments: ' + itemsAttachments);
        if(itemsAttachments.keySet().size()>0) {
            for (Id item_id : itemsAttachments.keySet()) {
                Map<String, String> itemAttachments = itemsAttachments.get(item_id);
                for (String att : itemAttachments.keySet()) {
                    if (evt.Main_Image_Filename__c == att) {
                        System.debug('itemAttachments: ' + itemAttachments);
                        imgURL = itemAttachments.get(evt.Main_Image_Filename__c);
                    }
                }
            }
        }

    }

    @AuraEnabled
    public static void processTicket(String salesOrderId){
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Posting_Status__c, OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id=:salesOrderId];
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        update so;
    }

    @AuraEnabled
    public static CareerFairRegInfo createCFSalesOrder(String eventId){
        String contactId = ECRMUtils.getCurrentLoginUserContactId();

        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c WHERE Participate__c = 'Yes' AND Contact__c=:contactId AND BR_Event__c=:eventId];

        if(participations.isEmpty()) {
            OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId);
            insert so;

            addCareerFairTicket(contactId, so.Id, eventId);

            List<ContentDocumentLink> cdl = [SELECT Id, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId=: contactId AND ContentDocumentId IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title LIKE 'Resume%') ORDER BY SystemModstamp DESC];
            String fileId = null;
            if(!cdl.isEmpty()){
                fileId = cdl[0].ContentDocument.LatestPublishedVersionId;
            }

            return new CareerFairRegInfo(contactId, false, fileId, so.Id);
        }


        return new CareerFairRegInfo(contactId, true, null, null);
    }


    @AuraEnabled
    public static CareerFairRegInfo getCFRegInfo(String careerFairEventId, String salesOrderId){
        String contactId = ECRMUtils.getCurrentLoginUserContactId();
        //check if career fair sales order line exists
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:salesOrderId AND OrderApi__Item__r.AC_Event__c=:careerFairEventId];
        System.debug('lines: ' + lines);
        System.debug('isEmpty: ' + lines.isEmpty());

        List<ContentDocumentLink> cdl = [SELECT Id, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId=: contactId AND ContentDocumentId IN (SELECT ContentDocumentId FROM ContentVersion WHERE Title LIKE 'Resume%') ORDER BY SystemModstamp DESC];
        String fileId = null;
        if(!cdl.isEmpty()){
            fileId = cdl[0].ContentDocument.LatestPublishedVersionId;
        }

        return new CareerFairRegInfo(contactId, lines.size()>0, fileId, salesOrderId);

    }

    public without sharing class CareerFairRegInfo{
        @AuraEnabled
        public String fileId;

        @AuraEnabled
        public String contactId;

        @AuraEnabled
        public Boolean registered;

        @AuraEnabled
        public String salesOrderId;

        public CareerFairRegInfo(String contactId, Boolean registered, String fileId, String salesOrderId){
            this.contactId = contactId;
            this.registered = registered;
            this.fileId = fileId;
            this.salesOrderId = salesOrderId;
        }
    }

    @AuraEnabled
    public static void addCareerFairTicket(String contactId, String salesOrderId, String careerFairEventId){
        OrderApi__Item__c careerFairTicket = [SELECT id FROM OrderApi__Item__c WHERE AC_Event__c=:careerFairEventId];

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:salesOrderId AND OrderApi__Item__r.AC_Event__c=:careerFairEventId];

        //add career fair to sales order
        if(lines.isEmpty()) {
            insert new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrderId, OrderApi__Item__c = careerFairTicket.Id);
        }

        //create/update incomplete participant record for career fair
        BR_Participation__c participation;
        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c WHERE Contact__c=:contactId AND BR_Event__c=:careerFairEventId];
        if(!participations.isEmpty()){
            participation = participations[0];

        } else {
            participation =  new BR_Participation__c();
            participation.User__c=UserInfo.getUserId();
            participation.Contact__c=contactId;
            participation.BR_Event__c=careerFairEventId;
        }
        participation.Fon_Sales_Order__c=salesOrderId;

        //create public link for resume file
        List<ContentDocumentLink> contactFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId =: contactId ANd ContentDocument.Title LIKE '%Resume%' ORDER BY SystemModstamp DESC];
        System.debug('contactFiles: ' + contactFiles);

        if(!contactFiles.isEmpty()) {
            List<ContentDistribution> distributions = [Select Id, DistributionPublicUrl from ContentDistribution WHERE ContentVersionId = :contactFiles[0].ContentDocument.LatestPublishedVersionId];

            if (distributions.isEmpty()) {

                ContentDistribution cd = new ContentDistribution();
                cd.Name = contactFiles[0].ContentDocument.Title;
                cd.ContentVersionId = contactFiles[0].ContentDocument.LatestPublishedVersionId;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesLinkLatestVersion = true;
                cd.PreferencesNotifyOnVisit = false;
                cd.PreferencesPasswordRequired = false;
                cd.PreferencesAllowOriginalDownload = true;

                insert cd;
            }

        }


        try{
            upsert participation;


        }catch(Exception e){
            System.debug('ERROR: ' + e.getMessage());
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Add Career Fair Ticket');
        }
    }

    @AuraEnabled
    public static void removeCareerFairTicket(String salesOrderId, String careerFairEventId){
        //remove career fair to sales order
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:salesOrderId AND OrderApi__Item__r.AC_Event__c=:careerFairEventId];
        if(!lines.isEmpty()){
            delete lines;
        }
    }

}
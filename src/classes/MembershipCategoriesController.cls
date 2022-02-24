/**
 * Created by lauren.lezberg on 12/5/2018.
 */
 
public without sharing class MembershipCategoriesController {

    /**
     * @purpose Retrieves all membership items
     *
     * @return List of items
     */
    @AuraEnabled
    public static List<OrderApi__Item__c> getMembershipItems(Boolean isTransfer){
        System.debug('getMembershipItems with isTransfer: ' + isTransfer);
        List<OrderApi__Item__c> items = new List<OrderApi__Item__c>();
        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Individual Memberships');
        //get all membership items
        List<OrderApi__Item__c> membershipItems = JP_Helper.getPortalItemsByClass(itemClassNames);
        System.debug('membershipItems: ' + membershipItems);

        Set<String> availableItems = new Set<String>();
        if(isTransfer){
            String contactId = ECRMUtils.getCurrentLoginUserContactId();
            List<OrderApi__Subscription__c> subs = RenewalUtils.getIndividualMembershipSubscription(contactId);
            if(subs.size()>0){
                String currentMembershipType = subs[0].OrderApi__Item__r.Name;
                List<Transfer_Setting__mdt> tSettings = [SELECT Id, Transfer_Options__c FROM Transfer_Setting__mdt WHERE MasterLabel=:currentMembershipType];
                if(tSettings.size()==1){
                    availableItems.addAll(tSettings[0].Transfer_Options__c.split(','));
                    System.debug('availableItems: ' + availableItems);
                    for (OrderApi__Item__c item : membershipItems) {
                        System.debug('item: ' + item.Name);
                        if (availableItems.contains(item.Name)) {
                            items.add(item);
                        }
                    }

                }
            }
        } else {

            for (OrderApi__Item__c item : membershipItems) {
                if (item.Show_In_Portal__c) {
                    items.add(item);
                }
            }
        }
        SYstem.debug('items: ' + items);
        return items;
    }

    /**
     * @purpose Starts process of member application by setting application status, creating SO, creating new contact last accessed step record and retrieving join process Id to redirect
     *
     * @param itemId
     *
     * @return redirect url string with join process id and new sales order id
     */
    @AuraEnabled
    public static String startNewMemberApplication(String itemId){

        Contact currentContact = ECRMUtils.getCurrentLoginContact();

        //get membership item
        OrderApi__Item__c membership = [SELECT Id, Name, OrderApi__Business_Group__c,OrderApi__Item_Class__c, OrderApi__Price__c FROM OrderApi__Item__c WHERE Id=: itemId LIMIT 1];
        //start a
        String salesOrderId = ECRMUtils.startMembershipApplication(itemId);

        // get join process
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%' + membership.Name + '%' AND Is_Renewal__c = false AND Campaign_Code__c = null];
        Decimal lastStepOrder = JP_Helper.getLastAccessedStepOrder(jp.Id);
        if(lastStepOrder!=null) {
            if (lastStepOrder != 0) {
                contact_last_accessed_step__c las = [SELECT Id FROM contact_last_accessed_step__c WHERE JoinId__c = :jp.Id AND Contact__c=: currentContact.Id];
                delete las;
            }
        }

        String redirectURL = '/apex/JP_Container?id=' + jp.Id + '&salesOrder=' + salesOrderId;

        return redirectURL;
    }

    /**
     * @purpose Starts process of member application by setting application status, creating SO, creating new contact last accessed step record and retrieving join process Id to redirect
     *
     * @param itemId
     *
     * @return redirect url string with join process id and new sales order id
     */
    @AuraEnabled
    public static String startTransferApplication(String itemId){

        Contact currentContact = ECRMUtils.getCurrentLoginContact();

        String salesOrderId;
        //start application
        if(currentContact.RecordType.Name == 'Member') {
            salesOrderId = ECRMUtils.startTransferApplication(itemId);
        } else {
            salesOrderId = ECRMUtils.startReinstateTransferApplication(itemId);
        }

        // get join process
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Transfer_General'];
        Decimal lastStepOrder = JP_Helper.getLastAccessedStepOrder(jp.Id);
        if(lastStepOrder!=null) {
            if (lastStepOrder != 0) {
                contact_last_accessed_step__c las = [SELECT Id FROM contact_last_accessed_step__c WHERE JoinId__c = :jp.Id AND Contact__c=: currentContact.Id];
                delete las;
            }
        }

        String redirectURL = '/apex/JP_Container?id=' + jp.Id + '&salesOrder=' + salesOrderId + '&isInvoice=true';

        return redirectURL;
    }


}
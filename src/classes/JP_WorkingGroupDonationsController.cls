/**
 * Created by lauren.lezberg on 8/23/2019.
 */

public with sharing class JP_WorkingGroupDonationsController {

    /**
     * @purpose Updates last accessed step and retrieves all working group donation items that should be available to user based on working group selections. If any working groups are deselected but a
     * donation was present in the sales order, the donation will be deleted as well.
     *
     * @param salesOrderId
     * @param stepId
     *
     * @return List of working group donation items
     */
    @AuraEnabled
    public static List<WorkingGroupDonationItem> getWorkingGroupDonationItems(String salesOrderId, String stepId){
        if(stepId!=null) {
            JP_Helper.upsertLastAccessedStep(stepId);
        }
        List<WorkingGroupDonationItem> wgItems = new List<WorkingGroupDonationItem>();

        //get all active working groups
        List<OrderApi__Item__c> workingGroups = [SELECT Id, Name FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='Working Groups' AND OrderApi__Is_Active__c = true];

        //find all sales order lines with working groups
        List<OrderApi__Sales_Order_Line__c> wgLines = [SELECT OrderApi__Item__c, OrderApi__Item__r.Portal_Label__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND OrderApi__Item_Class__r.Name = 'Working Groups'];

        //Get all working group ids
        Set<String> wgItemIds = new Set<String>();
        for(OrderApi__Sales_Order_Line__c line: wgLines){
            wgItemIds.add(line.OrderApi__Item__c);
        }

        //determine whether donation should be inserted or removed based on working group selection
        Set<String> wgDonationsToRemove = new Set<String>();
        Set<String> wgNames = new Set<String>();
        for(OrderApi__Item__c wg : workingGroups){
            if(wgItemIds.contains(wg.Id)){
                wgNames.add(wg.Name + ' Donations');
            } else {
                wgDonationsToRemove.add(wg.Name + ' Donations');
            }
        }

        List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();
        Set<String> selectedDonations = new Set<String>();

        //get all lines with donation items
        wgLines = [SELECT OrderApi__Item__c, OrderApi__Item__r.Portal_Label__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND (OrderApi__Item_Class__r.Name IN: wgDonationsToRemove OR OrderApi__Item_Class__r.Name IN: wgNames)];

        //collect all sales order lines to delete and set of selected ids
        for(OrderApi__Sales_Order_Line__c line : wgLines){
            if(wgDonationsToRemove.contains(line.OrderApi__Item_Class__r.Name)){
                linesToDelete.add(line);
            } else {
                selectedDonations.add(line.OrderApi__Item__c);
            }
        }

        //get all donation classes where working group is selected
        List<OrderApi__Item_Class__c> donationClasses = [SELECT Id, Name FROM OrderApi__Item_Class__c WHERE Name IN: wgNames];
        Set<String> classIds = new Set<String>();
        Map<String, String> donationMap = new Map<String, String>();
        for(OrderApi__Item_Class__c iClass : donationClasses){
            classIds.add(iClass.Id);
            donationMap.put(iClass.Id, iClass.Name);
        }

        //get all donation items from selections
        List<OrderApi__Item__c> donationItems = [SELECT Id, OrderApi__Price__c, OrderApi__Item_Class__c, OrderApi__Item_Class__r.OrderApi__Description__c FROM OrderApi__Item__c WHERE OrderApi__Is_Active__c = true AND OrderApi__Item_Class__c IN: classIds ORDER BY OrderApi__Item_Class__c, OrderApi__Price__c];


        //create list of working group items for each working group selection based on selections
        for(String classId : classIds){
            WorkingGroupDonationItem wgItem = new WorkingGroupDonationItem();
            List<OrderApi__Item__c> items = new List<OrderApi__Item__c>();
            for(OrderApi__Item__c dItem : donationItems){
                if(dItem.OrderApi__Item_Class__c == classId){
                    wgItem.description = dItem.OrderApi__Item_Class__r.OrderApi__Description__c;
                    if(selectedDonations.contains(dItem.Id)){
                        wgItem.selectedId = dItem.Id;

                    }
                    items.add(dItem);
                }
            }
            wgItem.workingGroupName = donationMap.get(classId).remove(' Donations');
            wgItem.donationItems = items;
            wgItems.add(wgItem);
        }

        try{
            delete linesToDelete;
        }catch(Exception e){
            System.debug('Could not remove old donation items.' + e.getMessage());
        }
        return wgItems;

    }

    /**
     * @purpose Save all working group donation selections and delete all working group donations that were present before but not in the current selections
     *
     * @param salesOrderId
     * @param selectedDonations
     *
     * @return Success or Failure
     */
    @AuraEnabled
    public static Boolean saveWorkingGroupDonations(String salesOrderId, List<String> selectedDonations){
        //find all selected working group donations
        List<OrderApi__Sales_Order_Line__c> wgLines = [SELECT OrderApi__Item__r.Portal_Label__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND OrderApi__Item_Class__r.Name = 'Working Groups'];

        Set<String> wgNames = new Set<String>();
        for(OrderApi__Sales_Order_Line__c line: wgLines){
            wgNames.add(line.OrderApi__Item__r.Portal_Label__c + ' Donations');
        }

        Set<Id> donationSet = new Set<Id>();
        for(String s : selectedDonations){
            donationSet.add((Id)s);
        }

        List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();
        //get all wg donation lines that match working groups
        wgLines = [SELECT OrderApi__Item__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND OrderApi__Item_Class__r.Name IN: wgNames];
        for(OrderApi__Sales_Order_Line__c wgLine : wgLines){
            if(!donationSet.contains(wgLine.OrderApi__Item__c)){
               linesToDelete.add(wgLine);
            } else {
                donationSet.remove(wgLine.OrderApi__Item__c);
            }
        }

        //create sales order lines for each selection
        JP_Helper.JPError itemsAdded = JP_Helper.addItemsToSalesOrder(donationSet, (Id)salesOrderId);

        if(itemsAdded.isSuccess) {
            try {
                delete linesToDelete;
                return true;
            } catch (Exception e) {
                System.debug('Could not save working group donations.');
                return false;
            }
        } else {
            System.debug('Could not add items to sales order.');
            return false;
        }


    }



    public class WorkingGroupDonationItem{
        @AuraEnabled
        public String selectedId;

        @AuraEnabled
        public String workingGroupName;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public List<OrderApi__Item__c> donationItems;


        public WorkingGroupDonationItem(){}

    }


}
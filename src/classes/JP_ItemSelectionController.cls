/**
 * Created by lauren.lezberg on 1/24/2019.
 */

public with sharing class JP_ItemSelectionController {
 
    /** 
    *
    * @purpose Save working group selections by inserting new sales order lines for each selected item
    * @param salesOrderId
    * @param selectedItems
    * @param stepId
    *
    * @return JP_Helper.JP_Error wrapper object
    */
    @AuraEnabled
    public static JP_Helper.JPError saveWorkingGroupSelections(Id salesOrderId, List<Id> selectedItems, Id stepId){
        System.debug('saveWorkingGroupSelections was just called with salesOrderId: ' + salesOrderId + ' and selectedItems: ' + selectedItems);
        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Working Groups');
        return JP_Helper.saveItemSelections(itemClassNames, salesOrderId, selectedItems);
    }

    /**
      *
      * @purpose Save journal selections by inserting new sales order lines for each selected item
      * @param salesOrderId
      * @param selectedItems
      * @param stepId
      *
      * @return JP_Helper.JP_Error wrapper object
      */
    @AuraEnabled
    public static JP_Helper.JPError saveJournalSelections(Id salesOrderId, List<Id> selectedItems, Id stepId){
        System.debug('saveJournalSelections was just called with salesOrderId: ' + salesOrderId + ' and selectedItems: ' + selectedItems);
        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Complimentary Journals');
        itemClassNames.add('Journal Subscriptions');
        itemClassNames.add('ZDecline of the Journals');
        itemClassNames.add('Open Access Journals');
        return JP_Helper.saveItemSelections(itemClassNames, salesOrderId, selectedItems);
    }

    /**
     *
     * @purpose Save optional item selections by inserting new sales order lines for each selected item
     * @param salesOrderId
     * @param selectedItems
     * @param stepId
     *
     * @return JP_Helper.JP_Error wrapper object
     */
    @AuraEnabled
    public static JP_Helper.JPError saveOptionalItemSelections(Id salesOrderId, List<Id> selectedItems, Id stepId){
        System.debug('saveOptionalItemSelections was just called with salesOrderId: ' + salesOrderId + ' and selectedItems: ' + selectedItems);
        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Merchandise');
        return JP_Helper.saveItemSelections(itemClassNames, salesOrderId, selectedItems);
    }


    /**
  *
  * @purpose Get all relevant optional item data for current user
  * @param salesOrderId
  *
  * @return
  */
    @AuraEnabled
    public static List<AddOnItem> getOptionalItemData(Id salesOrderId, Id stepId){
        JP_Helper.upsertLastAccessedStep(stepId);
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        Set<String> selectedIds = new Set<String>();
        List<OrderApi__Sales_Order_Line__c> lines = [ SELECT Id, OrderApi__Item__c
        FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Sales_Order__c = :salesOrderId
        AND OrderApi__Item_Class__r.Name = 'Merchandise'];
        if(lines.size()>0){
            for(OrderApi__Sales_Order_Line__c line : lines ) {
                selectedIds.add(line.OrderApi__Item__c);
            }
        }
        List<AddOnItem> optionalItems = new List<AddOnItem>();

        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Merchandise');
        List<OrderApi__Item__c> merchandise = JP_Helper.getPortalItemsByClass(itemClassNames);

        for(OrderApi__Item__c item : merchandise){
            if(selectedIds.contains(item.Id) || item.OrderApi__Price__c == 0.0) {
                optionalItems.add(new AddOnItem(item.Name + ' - $' + String.valueOf(item.OrderApi__Price__c), item.Id, true, item.OrderApi__Image_Path__c, item.OrderApi__Description__c));
            } else {
                optionalItems.add(new AddOnItem(item.Name + ' - $' + String.valueOf(item.OrderApi__Price__c), item.Id, false, item.OrderApi__Image_Path__c, item.OrderApi__Description__c));
            }
        }
        return optionalItems;
    }

    /**
   *
   * @purpose Updates last accessed step and retrieves all relevant working group data for current user
   * @param salesOrderId
   *
   * @return
   */
    @AuraEnabled
    public static List<AddOnItem> getWorkingGroupData(Id salesOrderId, Id stepId){
        System.debug('getWorkingGroupData being called');

        if(stepId!=null) {
            JP_Helper.upsertLastAccessedStep(stepId);
        }
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        Set<String> selectedIds = new Set<String>();
        Id membershipItemId;
        Id itemClassId;

        List<OrderApi__Sales_Order_Line__c> lines = [ SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name
                                                        FROM OrderApi__Sales_Order_Line__c
                                                        WHERE OrderApi__Sales_Order__c = :salesOrderId
                                                        AND (OrderApi__Item_Class__r.Name = 'Working Groups' OR OrderApi__Item_Class__r.Name='Individual Memberships')];
        if(lines.size()>0){
            for(OrderApi__Sales_Order_Line__c line : lines ) {
                if(line.OrderApi__Item_Class__r.Name == 'Working Groups'){
                    selectedIds.add(line.OrderApi__Item__c);
                } else {
                    membershipItemId = line.OrderApi__Item__c;
                    itemClassId = line.OrderApi__Item_Class__c;
                }

            }
        }
        List<AddOnItem> groupItems = new List<AddOnItem>();

        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Working Groups');
        List<OrderApi__Item__c> workingGroups = JP_Helper.getPortalItemsByClass(itemClassNames);

        for(OrderApi__Item__c item : workingGroups){
            if(selectedIds.contains(item.Id) || (currentContact.Gender__c == 'Female' && item.Name == 'Women in Cancer Research (WICR)') ) {
                groupItems.add(new AddOnItem(item.Name, item.Id, true, item.OrderApi__Image_Path__c, item.OrderApi__Description__c));
            } else {
                groupItems.add(new AddOnItem(item.Name, item.Id, false, item.OrderApi__Image_Path__c, item.OrderApi__Description__c));
            }
        }

        return groupItems;

    }


    @AuraEnabled
    public static List<JournalItemData> getJournals(Id salesOrderId){
        System.debug('getting journals with salesOrderId: ' + salesOrderId);
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        Set<Id> selectedItems = new Set<Id>();
        Id membershipItemId;
        Id itemClassId;
        Id subPlanId;

        if(salesOrderId!=null){
            //get all sales order lines with journals and add ids to set
            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__c, OrderApi__Item_Class__r.Name, OrderApi__Item__r.Name, OrderApi__Subscription_Plan__c
            FROM OrderApi__Sales_Order_Line__c
            WHERE OrderApi__Sales_Order__c=: salesOrderId AND (OrderApi__Item_Class__r.Name = 'Journal Subscriptions' OR OrderApi__Item_Class__r.Name='Individual Memberships')];
            if(lines.size()>0){
                for(OrderApi__Sales_Order_Line__c line: lines){
                    if(line.OrderApi__Item_Class__r.Name == 'Journal Subscriptions'){
                        selectedItems.add(line.OrderApi__Item__c);
                    } else {
                        membershipItemId = line.OrderApi__Item__c;
                        itemClassId = line.OrderApi__Item_Class__c;
                        subPlanId = line.OrderApi__Subscription_Plan__c;
                    }
                }
            }
        }

        Set<String> itemClassNames = new Set<String>();
        itemClassNames.add('Journal Subscriptions');
        itemClassNames.add('Open Access Journals');
        //get all journal items
        List<OrderApi__Item__c> availableJournals = JP_Helper.getPortalItemsByClass(itemClassNames);

        //get map of each journal and corrected price for individual user
        Map<Id, Decimal> fullPriceMap = JP_Helper.getItemPriceMap(availableJournals, currentContact, membershipItemId, itemClassId, subPlanId, salesOrderId);
        if(fullPriceMap!=null) {
            List<OrderApi__Item__c> jItems = new List<OrderApi__Item__c>();
            Map<Id, Decimal> itemPriceMap = new Map<Id, Decimal>();
            List<JournalItemData> itemData = new List<JournalItemData>();
            Integer counter = 0;
            String currentJName;
            Id selectedId = null;

            //iterate through journals and create journalItemData wrapper list
            for (OrderApi__Item__c j : availableJournals) {

                if(currentJName == null || currentJName!= j.name.remove('- Online').remove('- Print')){

                    if (counter != 0) {
                        itemData.add(new JournalItemData(jItems, selectedId, itemPriceMap));
                    }
                    currentJName = j.name.remove('- Online').remove('- Print');
                    selectedId = null;
                    jItems = new List<OrderApi__Item__c>();
                    itemPriceMap = new Map<Id, Decimal>();
                    jItems.add(j);
                    itemPriceMap.put(j.Id, fullPriceMap.get(j.Id));

                } else {
                    jItems.add(j);
                    itemPriceMap.put(j.Id, fullPriceMap.get(j.Id));
                    //add last journal
                    if(counter == availableJournals.size()-1){
                        itemData.add(new JournalItemData(jItems, selectedId, itemPriceMap));
                    }
                }

                if (selectedItems.contains(j.Id)) {
                    selectedId = j.Id;
                }
                counter++;
            }
            return itemData;
        }
        return null;
    }

    /**
    *
    * @purpose Get all relevant journal data for current user
    * @param salesOrderId
    *
    * @return journalData wrapper object
    */
    @AuraEnabled
    public static JournalData getJournalData(Id salesOrderId, Id stepId){
        System.debug('Getting JournalData with sales order: ' + salesOrderId);

        JP_Helper.upsertLastAccessedStep(stepId);
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        Set<Id> selectedItems = new Set<Id>();
        Boolean isActiveMembership = false;
        Id membershipItemId;
        Id itemClassId;

        if(salesOrderId!=null){
            //get all sales order lines with journals and add ids to set
            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__c, OrderApi__Item_Class__r.Name, OrderApi__Item__r.Name
                                                            FROM OrderApi__Sales_Order_Line__c
                                                            WHERE OrderApi__Sales_Order__c=: salesOrderId AND (OrderApi__Item_Class__r.Name = 'Journal Subscriptions' OR OrderApi__Item_Class__r.Name='Individual Memberships')];
            if(lines.size()>0){
                for(OrderApi__Sales_Order_Line__c line: lines){
                    if(line.OrderApi__Item_Class__r.Name == 'Journal Subscriptions'){
                        selectedItems.add(line.OrderApi__Item__c);
                    } else {
                        membershipItemId = line.OrderApi__Item__c;
                        itemClassId = line.OrderApi__Item_Class__c;
                        if(line.OrderApi__Item__r.Name == 'Active Membership'){
                            isActiveMembership = true;
                        }
                    }

                }
            }
        }
//        Boolean hasJournalAddress = false;
//        if(currentContact.Journal_Street__c!=null && currentContact.Journal_City__c!=null && currentContact.Journal_Country__c!=null){
//            hasJournalAddress = true;
//        }
        return new JournalData(null, currentContact.Id, isActiveMembership);
    }

    /**
     *
     * @purpose Get all relevant comp journals and selected comp journal
     * @param salesOrderId
     *
     * @return CompJournalData wrapper class object
     */
    @AuraEnabled
    public static CompJournalData getCompJournalOptions(Id salesOrderId){
        List<OrderApi__Item__c> OnlineOnlyJournals  = new List<OrderApi__Item__c>();
        List<OrderApi__Item__c> PrintJournals  = new List<OrderApi__Item__c>();
        String declineId;

        if(salesOrderId!=null)  {
            for(OrderApi__Item__c comp : [SELECT Id, Name, OrderApi__Price__c, Fon_Association_Journal_Type__c, OrderApi__Item_Class__r.Name,
                    Hide_In_Join__c, Default_Selected_In_Join__c, Portal_Label__c
            FROM OrderApi__Item__c
            WHERE ((OrderApi__Item_Class__r.Name = 'Complimentary Journals' AND Name LIKE 'COMP-%') OR OrderApi__Item_Class__r.Name ='ZDecline of the Journals') AND
            OrderApi__Is_Active__c = true
            Order by Name]){
                if(comp.Portal_Label__c.contains('Online')){
                    OnlineOnlyJournals.add(comp);
                } else if (comp.Portal_Label__c.contains('Print')){
                    PrintJournals.add(comp);
                } else if(comp.Portal_Label__c == 'Declined Free Journal'){
                    declineId = comp.Id;
                }
            }
            List<OrderApi__Sales_Order_Line__c> compLines = [SELECT Id, OrderApi__Item__c FROM OrderApi__Sales_Order_Line__c WHERE (OrderApi__Item_Class__r.Name='Complimentary Journals' OR OrderApi__Item_Class__r.Name ='ZDecline of the Journals') AND OrderApi__Sales_Order__c =: salesOrderId];
            if(compLines.size()>0){
                return new CompJournalData(OnlineOnlyJournals, PrintJournals, compLines[0].OrderApi__Item__c, declineId);
            } else {
                return new CompJournalData(OnlineOnlyJournals, PrintJournals, null, declineId);
            }
        }
        return null;
    }


    /**
   * JournalItemData wrapper class to store individual journal information used in JP_JournalItem.cmp (Aura Bundle)
   */
    public class JournalItemData{
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String imgURL;

        @AuraEnabled
        public String locationURL;

        @AuraEnabled
        public List<OrderApi__Item__c> items;

        @AuraEnabled
        public Map<Id, Decimal> itemPriceMap;

        @AuraEnabled
        public Id selectedItem;

        @AuraEnabled
        public String itemDescription;

        @AuraEnabled
        public String itemClass;


        public JournalItemData(List<OrderApi__Item__c> items, Id selectedItem, Map<Id, Decimal> priceMap){
            if(selectedItem!=null){
                this.selectedItem = selectedItem;
            } else {
                if(items.size() == 1){
                    this.selectedItem = items[0].Id;
                } else {
                    this.selectedItem = null;
                }
            }
            this.name = items[0].Portal_Label__c.replace('- Online', '');
            this.imgURL = items[0].OrderApi__Image_Path__c;
            this.itemClass = items[0].OrderApi__Item_Class__r.Name;
            this.itemPriceMap = priceMap;
            this.items = items;
            this.itemDescription = items[0].OrderApi__Description__c;
            this.locationURL = items[0].Journal_Location_URL__c;
        }
    }

    /**
     * JournalData wrapper class to retrieve current users journal selections and available journals
     */
    public class JournalData {
        @AuraEnabled
        public List<JournalItemData> journals;

        @AuraEnabled
        public Id contactId;

        @AuraEnabled
        public Boolean isActiveMembership;


        public JournalData(List<JournalItemData> itemData, Id conId, Boolean active) {
            this.journals = itemData;
            this.contactId = conId;
            this.isActiveMembership = active;
        }

    }

    /**
     * CompJournalData wrapper class to retrieve current users comp journal selection and available comp journals
     */
    public class CompJournalData {

        @AuraEnabled
        public List<OrderApi__Item__c> journalsPrint;

        @AuraEnabled
        public List<OrderApi__Item__c> journalsOnline;

        @AuraEnabled
        public String selectedJournal;

        @AuraEnabled
        public String declineJournal;

        public CompJournalData(List<OrderApi__Item__c> onlineOnly, List<OrderApi__Item__c> print, String selected, String decline){
            this.journalsPrint = print;
            this.journalsOnline = onlineOnly;
            this.selectedJournal = selected;
            this.declineJournal = decline;
        }
    }

    /**
     * WorkingGroupItem wrapper class to retrieve current users working group selections and available working groups
     */
    public class AddOnItem{
        @AuraEnabled
        public String itemLabel;

        @AuraEnabled
        public String itemId;

        @AuraEnabled
        public Boolean isSelected;

        @AuraEnabled
        public String itemDescription;

        @AuraEnabled
        public String imgURL;

        public AddOnItem(String name, String id, Boolean isSelected, String imgURL, String itemDescription){
            this.itemLabel = name;
            this.itemId = id;
            this.isSelected = isSelected;
            this.imgURL = imgURL;
            this.itemDescription = itemDescription;
        }

    }

}
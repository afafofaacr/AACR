/**
 * Created by lauren.lezberg on 10/7/2019.
 */

public with sharing class ItemQuickAddController {

    /**
     * @purpose Retrieves records based on search keyword from specific object type
     *
     * @param searchKeyWord
     * @param ObjectName
     *
     * @return List of records matching the search keyword
     */
    @AuraEnabled
    public static List <OrderApi__Item__c> fetchItems(String searchKeyWord, String filterString) {
        String searchKey = '%' + searchKeyWord + '%';
        Date today = Date.today();

        List < OrderApi__Item__c> returnList = new List < OrderApi__Item__c > ();

        String sQuery =  'SELECT id, Name, OrderApi__Price__c, OrderApi__Item_Class__r.EventApi__Event__r.ROEApi__Active_Ticket_Type_Count__c, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__r.EventApi__Event__r.EventApi__Start_Date__c, OrderApi__Item_Class__r.OrderApi__Is_Event__c, OrderApi__Item_Class__r.EventApi__Event__r.EventApi__Display_Name__c from OrderApi__Item__c WHERE Name LIKE: searchKey';
        if(filterString !=null){
            //' AND (OrderApi__Item_Class__r.OrderApi__Is_Event__c = false OR OrderApi__Item_Class__r.EventApi__Event__r.EventApi__End_Date__c >= :today)'
            sQuery += ' AND ' + filterString;
        }
        sQuery += ' ORDER BY createdDate DESC limit 5';

        System.debug('squery: ' + sQuery);
        List <OrderApi__Item__c> lstOfRecords = Database.query(sQuery);

        for (OrderApi__Item__c obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

}
/**
 * Created by lauren.lezberg on 2/26/2021.
 */

public with sharing class ExhibitorBoothSelectionController {


    @AuraEnabled
    public static List<OrderApi__Item__c> getBoothItems(){
        return [SELECT Id, OrderApi__Price__c, Portal_Label__c FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='AACR Booth Items'];
    }

}
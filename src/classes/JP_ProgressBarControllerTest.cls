/**
 * Created by lauren.lezberg on 2/4/2019.
 */
@isTest  
private with sharing class JP_ProgressBarControllerTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;
        OrderApi__Item__c item2 = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item2;
        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine;

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE '%Active Membership%' AND Is_Renewal__c = false];

        PageReference pageRef = new PageReference('/apex/JP_Container?id=' + jp.Id);
        Test.setCurrentPage(pageRef);
    }

    @isTest
    public static void testGetProgressBarData(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: testContact.Id];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE '%Active Membership%' AND Is_Renewal__c = false];
        Integer processStepsCount = [SELECT COUNT() FROM Process_Steps__mdt WHERE Process__c=: jp.Id];

        JP_ProgressBarController.ProgressBarData pbData = JP_ProgressBarController.getProgressBarData(jp.Id, so.Id);

        System.assertNotEquals(pbData, null);
        System.assertEquals(processStepsCount, pbData.steps.size());
        System.assertEquals(pbData.isRenewal, false);
        System.assertEquals(pbData.membershipType, 'Active Membership');
    }

    @isTest
    public static void test_getCancelURL(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: testContact.Id];
        Join_Process__mdt jp = [SELECT Id, Cancel_URL__c FROM Join_Process__mdt WHERE Item__c LIKE '%Active Membership%' AND Is_Renewal__c = false];
        List<Process_Steps__mdt> processSteps = [SELECT Id FROM Process_Steps__mdt WHERE Process__c=: jp.Id];

        Test.startTest();
        String cancelURL = JP_ProgressBarController.getCancelURL(processSteps[0].Id);
        System.assertNotEquals(null, cancelURL);
        System.assertEquals(jp.Cancel_URL__c, cancelURL);

        Test.stopTest();


    }

}
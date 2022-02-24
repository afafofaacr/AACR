/**
 * Created by lauren.lezberg on 6/14/2019.
 */
@isTest
private with sharing class JP_RequiredDocumentationControllerTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContact(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item;

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine1;

    }

    @isTest
    public static void testGetRequiredDocuments(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId=: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: testContact.Id];
        OrderApi__Item__c item = [SELECT Id, Name FROM OrderApi__Item__c WHERE Name='Associate Membership'];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: testContact.Id];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE:'%' + item.Name + '%' AND Is_Renewal__c = false AND Campaign_Code__c != null LIMIT 1 ];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName= 'Required_Documentation'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c();
        las.JoinId__c = jp.Id;
        las.Step_Order__c = 4;
        las.Contact__c = testContact.Id;
        insert las;

        System.runAs(u) {
            Test.startTest();
            JP_RequiredDocumentationController.RequiredDocumentation reqDocumentation = JP_RequiredDocumentationController.getRequiredDocuments(so.Id, step.id);

            System.assertNotEquals(null, reqDocumentation);
            Test.stopTest();
        }

    }
}
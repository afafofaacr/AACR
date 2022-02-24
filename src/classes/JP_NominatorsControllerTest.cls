/**
 * Created by lauren.lezberg on 3/14/2019.
 */
@isTest
private with sharing class JP_NominatorsControllerTest {
    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        //adding membership item
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

        //create sales order and sales order lines
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine1;
    }

    @isTest static void test_getNominationsData(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Journal_Selections'];
        System.runAs(u){
            JP_NominatorsController.NominationsData nomData = JP_NominatorsController.getNominationData(so.Id, step.Id);
            System.assertNotEquals(null, nomData);
        }
    }

    @isTest static void test_verifyNominator(){
        Contact con = [SELECT Id, Email FROM Contact LIMIT 1];

        Test.startTest();
        JP_NominatorsController.NominatorInfo nomInfo = JP_NominatorsController.verifyNominator(con.Id, con.Email, null);
        Test.stopTest();

        System.assertNotEquals(null, nomInfo);
    }

    @isTest static void test_StudentNominator(){
        JP_NominatorsController.StudentNominator studentNom = new JP_NominatorsController.StudentNominator('Test Nom', 'Test Title', 'Test Type');
    }

    @isTest static void test_saveNominationData(){
        Contact con = [SELECT Id,AccountId, Email, RecordTypeId FROM Contact LIMIT 1];
        Contact nominator1 = new Contact(LastName = 'Nominator1 ',
        AccountId =con.AccountId,
        RecordTypeId = con.recordTypeId,
        Email = 'testContact1@yopmail.com',
        Membership_Status__c = 'Current',
        Member_Type__c = 'Active Member',
        Application_Status__c = 'Accepted',
        Phone ='9878986789',
        Fax = 'fax',
        Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31));
        insert nominator1;
        JP_NominatorsController.NominatorInfo nom1 = new JP_NominatorsController.NominatorInfo(nominator1.Id, null, nominator1.Email, nominator1.LastName, true);
        Contact nominator2 = new Contact(LastName = 'Nominator2',
                AccountId =con.AccountId,
                RecordTypeId = con.recordTypeId,
                Email = 'testContact2@yopmail.com',
                Membership_Status__c = 'Current',
                Member_Type__c = 'Active Member',
                Application_Status__c = 'Accepted',
                Phone ='9878986789',
                Fax = 'fax',
                Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31));
        insert nominator2;
        JP_NominatorsController.NominatorInfo nom2 = new JP_NominatorsController.NominatorInfo(nominator2.Id, null, nominator2.Email, nominator2.LastName, true);
        List<Object> nominators = new List<Object>();
        nominators.add(nom1);
        nominators.add(nom2);

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id, Step_Order__c FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Nominators'];

        Test.startTest();
        JP_NominatorsController.saveNominationData(con.Id, nominators, step.Id);
        Test.stopTest();

    }

    @isTest
    public static void testBuildNominatorQuery(){
        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        Test.startTest();
        String queryString = JP_NominatorsController.buildNominatorQuery(testContact.Id, null, 'test@yopmail.com');
        Test.stopTest();

        System.assertNotEquals(queryString, null);
    }

}
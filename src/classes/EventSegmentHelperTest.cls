/**
 * Created by afaf.awad on 9/21/2021.
 */
@IsTest
public with sharing class EventSegmentHelperTest {

    @testSetup
    public static void setup() {

        Account a = TestDataFactory.buildAccount('Test Account');
        insert a;

        Contact con = TestDataFactory.buildContactMemberCurrent(a.Id);
        con.Advocate__c = false;
        con.Pre_Post_Doc__c = false;
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }

    @isTest
    public static void test_checkAccess(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        Test.startTest();

        Boolean access = EventSegmentHelper.checkAccess(con.Id);
        System.assertEquals(true, access);


        System.runAs(u){
            access = EventSegmentHelper.checkAccess(con.Id);
            System.assertEquals(false, access);
        }

        Test.stopTest();

    }

    @IsTest
    public static void test_getSegmentInfo(){
        Contact contact = [Select Id, AccountId from Contact LIMIT 1];

        Contact con = EventSegmentHelper.getSegmentInfo(contact.Id);
        System.assertEquals(contact.AccountId,con.AccountId);

    }


    @IsTest
    public static void test_saveSegmentOverride(){
        Contact contact = [Select Id, AccountId from Contact LIMIT 1];

        EventSegmentHelper.saveSegmentOverride(contact.Id, 'Test Class Reason', 'Low Income', 'Other', 'Int type reason',contact.AccountId);

        Contact con = [SELECT Id, Event_Segment__c, Income_Level__c, Account.Institution_Type__c, Account.Institution_Type_Override__c, Manual_Segment_Override__c FROM Contact WHERE Id =: contact.Id];
        System.assertEquals(true, con.Event_Segment__c.contains('LWI'));
        System.assertEquals('Low Income', con.Income_Level__c);
        System.assertEquals('Other', con.Account.Institution_Type__c);
        System.assertEquals(true,con.Manual_Segment_Override__c);
        System.assertEquals(true,con.Account.Institution_Type_Override__c);


    }


    @IsTest
    public static void test_buildSegmentCode_IntType() {
        Contact con = [Select Id, RecordType.Name, AccountId, Account.Institution_Type__c, Member_Type__c, Income_Level__c, Advocate__c, Pre_Post_Doc__c
                        from Contact LIMIT 1];
        Map <Id,Account> accMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, NPO__c FROM Account WHERE Id =: con.AccountId]);
        String segment = EventSegmentHelper.buildSegmentCode(con, accMap);
        System.debug('event segement false npo = ' + segment);
        accMap.get(con.AccountId).NPO__c = true;
        EventSegmentHelper.buildSegmentCode(con, accMap);
        System.debug('event segement true npo = ' + segment);



//        List<String> instTypes = new List<String>{  'Academia',
//                'Association/Professional Org',
//                'Cancer Center (NCI-designated)',
//                'Government',
//                'Hospital/Medical Center',
//                'Industry/Private Sector',
//                'Press',
//                'Vendor',
//                'Other', '' };
//        for(String i : instTypes) {
//            Contact con = [Select Id, RecordType.Name, AccountId, Account.Institution_Type__c, Member_Type__c, Income_Level__c, Advocate__c, Pre_Post_Doc__c from Contact LIMIT 1];
//            acc.Institution_Type__c = i;
//            update acc;
//            Map <Id,Account> accMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, NPO__c FROM Account WHERE Id =: con.AccountId]);
//            EventSegmentHelper.buildSegmentCode(con, accMap);
//        }


    }

    @IsTest
    public static void test_buildSegmentCode_MemType() {
        Contact con = [Select Id, RecordType.Name, RecordTypeId, AccountId, Account.Institution_Type__c, Member_Type__c, Income_Level__c, Advocate__c, Pre_Post_Doc__c from Contact LIMIT 1];
        Map <Id,Account> accMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, NPO__c FROM Account WHERE Id =: con.AccountId]);
        List<String> memTypes = new List<String>{ 'Active Member',
                'Associate Member',
                'Affiliate Member',
                'Emeritus Member',
                'Student Member',
                'Nonmember'};
        for(String i : memTypes) {
            con.Member_Type__c = i;
            update con;
            EventSegmentHelper.buildSegmentCode(con, accMap);
        }

        con.RecordTypeId = TestDataFactory.getContactRecordTypeId('Nonmember');
        update con;
        EventSegmentHelper.buildSegmentCode(con,accMap);

        con.Advocate__c = true;
        update con;
        EventSegmentHelper.buildSegmentCode(con, accMap);

        con.Advocate__c = false;
        con.Pre_Post_Doc__c = true;
        update con;
        EventSegmentHelper.buildSegmentCode(con,accMap);



    }

    @IsTest
    public static void test_buildSegmentCode_IncomeLevel() {
        Contact con = [Select Id, RecordType.Name, AccountId, Account.Institution_Type__c, Member_Type__c, Income_Level__c, Advocate__c, Pre_Post_Doc__c from Contact LIMIT 1];
        Map <Id,Account> accMap = new Map<Id, Account>([SELECT Id, Institution_Type__c, NPO__c FROM Account WHERE Id =: con.AccountId]);
        List<String> incomes = new List<String>{
                'High Income',
                'Upper Middle Income',
                'Lower Middle Income',
                'Low Income', ''
        };
        for (String i : incomes) {
            con.Income_Level__c = i;
            update con;
            EventSegmentHelper.buildSegmentCode(con, accMap);
        }
    }

}
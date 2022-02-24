/**
 * Created by afaf.awad on 12/14/2020.
 */
@IsTest
public with sharing class BatchUpdateMembershipHelperTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i<100; i++){
            Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
            con.Member_Type__c = 'Associate Member';
            contacts.add(con);
        }
        insert contacts;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
        insert membership;

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
        insert renewalProcess;

        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>();

        for(Contact contact : contacts){
            OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(contact.Id, subPlan.Id, membership.Id, membershipClass.Id);
            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(system.today().year(), 1, 1);
            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year(), 12, 31);
            sub.OrderApi__Is_Active__c = true;
            sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year(), 12, 31);
            subscriptions.add(sub);
        }

        insert  subscriptions;

    }

    @IsTest
    static void test_ValidateData(){
        List<Contact> contacts = [Select Id, AACR_ID__c, Email FROM Contact];

        String contentCSV = '';
        for(Contact con : contacts){
            contentCSV += con.Id + ',' + con.AACR_ID__c + '\n';
        }
        String withAACRIdContent = 'ContactId, AACRID\n' + contentCSV;

        String noAACRIdContent = 'ContactId, AACRID\n';
        noAACRIdContent += contacts[0].Id + ', \n';
        noAACRIdContent += contacts[1].Id + ',' + contacts[1].AACR_ID__c + '\n';

        List<String> fields = new List<String>{'ContactId','AACRID'};


        Test.startTest();
        Boolean noAACRID = BatchUpdateMembershipHelper.validateData(noAACRIdContent, fields, 'AACRID');
        Boolean withAACRID = BatchUpdateMembershipHelper.validateData(withAACRIdContent, fields, 'AACRID');
        Test.stopTest();
        System.assertEquals(false, noAACRID);
        System.assertEquals(true, withAACRID);

    }

    @IsTest
    static void test_processData_isRenew(){

        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];

        String fileData = 'Email,AACRID' + '\n'
                + contacts[0].Email + ',' + contacts[0].AACR_ID__c + '\n'
                + contacts[1].Email + ',' + contacts[1].AACR_ID__c + '\n'
                + contacts[2].Email + ',' + contacts[2].AACR_ID__c;

        System.debug('fileData = ' + fileData);

        List<String> fields = new List<String>{'Email','AACRID'};

        Test.startTest();
        System.debug('FileData: ' + fileData);
        BatchUpdateMembershipHelper.processData(fileData, fields, 'AACRID',true);
        Test.stopTest();

    }

    @IsTest
    static void test_processData_isPriorMem(){

        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];

        String fileData = 'Email,AACRID' + '\n'
                + contacts[0].Email + ',' + contacts[0].AACR_ID__c + '\n'
                + contacts[1].Email + ',' + contacts[1].AACR_ID__c + '\n'
                + contacts[2].Email + ',' + contacts[2].AACR_ID__c;

        System.debug('fileData = ' + fileData);

        List<String> fields = new List<String>{'Email','AACRID'};

        Test.startTest();
        BatchUpdateMembershipHelper.processData(fileData, fields, 'AACRID',false);
        Test.stopTest();

    }

    @IsTest
    static void test_sendErrorsSubs(){
        List<OrderApi__Subscription__c> subs = [SELECT Id, OrderApi__Contact__r.FirstName, OrderApi__Contact__r.LastName
                                                , OrderApi__Contact__r.AACR_ID__c, OrderApi__Current_Term_End_Date__c
                                                FROM OrderApi__Subscription__c];

        System.debug('Subs = ' + subs.size());

        Test.startTest();
        BatchUpdateMembershipHelper.sendRecordErrors_Subscriptions(subs, subs.size(), '7070200000BHFrm');
        Test.stopTest();

    }

    @IsTest
    static void test_sendErrorsContacts(){
        List<Contact> contacts = [SELECT Id, FirstName, LastName ,AACR_ID__c, Paid_thru_date__c, Membership_Status__c FROM Contact];

        Test.startTest();
        BatchUpdateMembershipHelper.sendRecordErrors_Contacts(contacts, contacts.size(), '7070200000BHFrm');
        Test.stopTest();

    }



}
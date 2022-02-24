/**
 * Created by lauren.lezberg on 6/14/2019.
 */
@isTest
private with sharing class MemberProfileControllerTest { 

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;
        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;
        OrderApi__Item__c journalItem1 = TestDataFactory.buildItem(journalClass.Id, 'BTest Journal 1');
        insert journalItem1;
        OrderApi__Item_Class__c workingGroupClass = TestDataFactory.buildItemClass('Working Groups');
        insert workingGroupClass;
        OrderApi__Item__c workingGroupItem1 = TestDataFactory.buildItem(workingGroupClass.Id, 'CTest Working Group 1');
        insert workingGroupItem1;

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
        insert renewalProcess;

        DW_Manage_Dues_Item__c DWduesItem = new DW_Manage_Dues_Item__c(Delinquent_Years__c=2, Membership_Item_Name__c='2YR Dues', Name='2YR Dues');
        insert DWduesItem;


    }


    @IsTest
    public static void test_getInvoiceURL(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: testContact.Id];
        List<OrderApi__Item_Class__c> itemClasses = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Individual Memberships' OR Name='Journal Subscriptions' OR Name='Working Groups' ORDER BY Name];
        List<OrderApi__Item__c> items = [SELECT Id, Name FROM OrderApi__Item__c WHERE OrderApi__Item_Class__c IN: itemClasses ORDER BY Name];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        so.Is_Transfer__c = true;
        insert so;
        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, items[0].Id, itemClasses[0].Id);
        insert sol;


        System.runAs(u) {
            Test.startTest();

            String url = MemberProfileController.getInvoicePaymentURL(testContact.Id);
            System.assertNotEquals(null, url);

            Test.stopTest();
        }
    }


    @isTest
    public static void testGetSubscriptions(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: testContact.Id];
        List<OrderApi__Item_Class__c> itemClasses = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Individual Memberships' OR Name='Journal Subscriptions' OR Name='Working Groups' ORDER BY Name];
        List<OrderApi__Item__c> items = [SELECT Id, Name FROM OrderApi__Item__c WHERE OrderApi__Item_Class__c IN: itemClasses ORDER BY Name];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, items[0].Id, itemClasses[0].Id);
        insert sol;


        System.runAs(u) {
            Test.startTest();

            MemberProfileController.MembershipData subscriptionData = MemberProfileController.getMembershipData();
            System.assertNotEquals(null, subscriptionData);

            OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
            OrderApi__Subscription__c memSub = TestDataFactory.buildSubscription(testContact.Id, subPlan.Id, items[0].Id, itemClasses[0].Id);
            insert memSub;
            OrderApi__Subscription__c journalSub = TestDataFactory.buildSubscription(testContact.Id, subPlan.Id, items[1].Id, itemClasses[1].Id);
            insert journalSub;
            OrderApi__Subscription__c wgSub = TestDataFactory.buildSubscription(testContact.Id, subPlan.Id, items[2].Id, itemClasses[2].Id);
            insert wgSub;

            subscriptionData = MemberProfileController.getMembershipData();
            System.assertNotEquals(null, subscriptionData);

            Test.stopTest();


        }

    }

    @isTest
    public static void testCancelApplication(){

        Account acc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: testContact.Id];
        List<OrderApi__Item_Class__c> itemClasses = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Individual Memberships' OR Name='Journal Subscriptions' OR Name='Working Groups' ORDER BY Name];
        List<OrderApi__Item__c> items = [SELECT Id, Name FROM OrderApi__Item__c WHERE OrderApi__Item_Class__c IN: itemClasses ORDER BY Name];

        System.runAs(u) {
            //create sales order and sales order lines
            OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
            insert so;
            OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, items[0].Id, itemClasses[0].Id);
            insert soLine1;
            OrderApi__Sales_Order_Line__c soLine2 = TestDataFactory.buildSOLine(so.Id, items[1].Id, itemClasses[1].Id);
            insert soLine2;
            OrderApi__Sales_Order_Line__c soLine3  = TestDataFactory.buildSOLine(so.Id, items[2].Id, itemClasses[2].Id);
            insert soLine3;

            Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE:'%' + items[0].Name + '%' AND Is_Renewal__c = false LIMIT 1 ];
            contact_last_accessed_step__c las = new contact_last_accessed_step__c();
            las.JoinId__c = jp.Id;
            las.Step_Order__c = 5;
            las.Contact__c = testContact.Id;
            insert las;
            Test.startTest();

            String returnURL = MemberProfileController.cancelApplication();
            System.assertEquals('/apex/MembershipCategories', returnURL);

            Test.stopTest();
        }

    }

    @IsTest
    public static void test_checkPermissions(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: testContact.Id];

        System.runAs(u) {
            MemberProfileController mpc = new MemberProfileController();
            System.assertEquals(false, mpc.ecAccess);
        }

        Community_Permission__c cp = new Community_Permission__c(Contact__c = testContact.Id);
        insert cp;

        System.runAs(u) {
            MemberProfileController mpc = new MemberProfileController();
            System.assertEquals(true, mpc.ecAccess);
        }


    }
}
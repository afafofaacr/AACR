/**
 * Created by lauren.lezberg on 2/4/2019.
 */
@isTest 
private with sharing class JP_ProductFlowControllerTest {

    @testSetup
    public static void setup(){
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Special Items');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Emeritus Voluntary Assessment');
        insert item;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        OrderApi__Subscription_Plan__c subPlan2YR = TestDataFactory.buildsubPlan();
        subPlan2YR.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2YR.Show_In_Portal__c = false;
        insert subPlan2YR;


    }

    @isTest
    public static void testGetProductDataCampaign(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item;



        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Associate Membership%' AND Is_Renewal__c = false AND Campaign_Code__c!=null];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Membership_Dues'];

        System.runAs(u) {
            JP_ProductFlowController.MembershipData data = JP_ProductFlowController.getProductData(null, step.Id);
            System.assertEquals(1, data.lines.size());
        }
    }

    @IsTest
    public static void test_getMembershipDataRenewalsON(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item;
        OrderApi__Item_Class__c item2Class = TestDataFactory.buildItemClass('Journals');
        insert item2Class;
        OrderApi__Item__c item2 = TestDataFactory.buildItem(itemClass.Id, 'Blood Cancer Discovery - Online');
        insert item2;
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;

        Renewal_Settings__c renSet = new Renewal_Settings__c(Term_Year__c=Date.today().year() + 1, Is_Active__c = true);
        insert renSet;

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Associate Membership%' AND Is_Renewal__c = false AND Campaign_Code__c=null];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Membership_Dues'];

        System.runAs(u) {
            JP_ProductFlowController.MembershipData data = JP_ProductFlowController.getMembershipData(so.Id, step.Id, item.Id);
            System.assertEquals(1, data.lines.size());
        }

    }

    @IsTest
    public static void test_getMembershipDataRenewalsOff(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item;
        OrderApi__Item_Class__c item2Class = TestDataFactory.buildItemClass('Journals');
        insert item2Class;
        OrderApi__Item__c item2 = TestDataFactory.buildItem(itemClass.Id, 'Blood Cancer Discovery - Online');
        insert item2;
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Associate Membership%' AND Is_Renewal__c = false AND Campaign_Code__c=null];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Membership_Dues'];

        System.runAs(u) {
            JP_ProductFlowController.MembershipData data = JP_ProductFlowController.getMembershipData(so.Id, step.Id, item.Id);
            System.assertEquals(1, data.lines.size());
        }

    }

    @isTest
    public static void testGetProductDataCampaign2(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        insert SO;
        
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item;


        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Associate Membership%' AND Is_Renewal__c = false AND Campaign_Code__c!=null];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Membership_Dues'];

        System.runAs(u) {
            JP_ProductFlowController.MembershipData data = JP_ProductFlowController.getProductData(null, step.Id);
            System.assertEquals(1, data.lines.size());
        }
    }

    @isTest
    public static void testGetProductDataRenew(){
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
        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine;

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Journal_Selections'];

        System.runAs(u) {
            //try with sales order present
            JP_ProductFlowController.MembershipData data = JP_ProductFlowController.getProductData(so.Id, step.Id);
            System.assertEquals(1, data.lines.size());

            //without sales order present
            data = JP_ProductFlowController.getProductData(null, step.Id);
            System.assertEquals(1, data.lines.size());
        }
    }


    @isTest
    private static void testAddNextTerm(){
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
        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        subPlan.OrderApi__Advanced_Calendar_Days__c = 365;
        insert subPlan;


        OrderApi__Item_Subscription_Plan__c isp2 = TestDataFactory.buildItemSubPlan(item.Id, subPlan.Id);
        insert isp2;

        Test.startTest();
        JP_ProductFlowController.MembershipData data = JP_ProductFlowController.addNextMembershipTerm(so.Id, String.valueOf(System.now().year()), 2);


        Test.stopTest();

        OrderApi__Sales_Order_Line__c sol = [SELECT Id, OrderApi__Subscription_Plan__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: so.Id];
        System.assertEquals(subPlan.Id, sol.OrderApi__Subscription_Plan__c);
    }

    @isTest
    private static void testSaveEmeritusDues(){
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
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Emeritus Membership');
        insert item;
        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        Test.startTest();

        JP_ProductFlowController.saveEmeritusDues(true, so.Id);

        Test.stopTest();

        Integer linesCount = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c where OrderApi__Sales_Order__c=: so.Id];
        System.assertEquals(2, linesCount);
    }

}
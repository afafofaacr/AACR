@isTest
public class Test_FonTransactionService {

    @testSetup
    public static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        System.assert(acc != null, 'account should not be null');

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.MailingCountryCode = 'US';
        con.Income_Level__c = 'High Income';
        insert con;
        System.assert(con != null, 'contact should not be null');

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
        System.assert(u != null, 'user should not be null');

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;
        System.assert(membershipClass != null, 'membershipClass should not be null');

        OrderApi__Item__c membershipItem = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        membershipItem.OrderApi__Price__c = 315.00;
        membershipItem.Is_Active_Membership_Type__c = true;
        insert membershipItem;
        System.assert(membershipItem != null, 'membershipItem should not be null');

        OrderApi__Item_Class__c compClass = TestDataFactory.buildItemClass('Complimentary Journals');
        insert compClass;
        System.assert(compClass != null, 'compClass should not be null');

        OrderApi__Item__c compItem = TestDataFactory.buildItem(compClass.Id, 'COMP-O-Cancer Discovery Journal');
        compItem.Is_Complimentary__c = true;
        compItem.OrderApi__Price__c = 0.0;
        insert compItem;
        System.assert(compItem != null, 'compItem should not be null');

        OrderApi__Price_Rule__c pr = TestDataFactory.buildPriceRule('2 years', membershipItem.Id, membershipClass.Id);
        insert pr;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert SO;
        System.assert(SO != null, 'sales Order should not be null');

        OrderApi__Sales_Order_Line__c membershipLine = TestDataFactory.buildSOLine(SO.Id, membershipItem.Id, membershipClass.Id);
        insert membershipLine;
        System.assert(membershipLine != null, 'membershipLine should not be null');

        OrderApi__Sales_Order_Line__c compLine = TestDataFactory.buildSOLine(SO.Id, compItem.Id, compClass.Id);
        insert compLine;
        System.assert(compLine != null, 'compLine should not be null');
    }


    static testMethod void testSplitrevenue() {

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c = :con.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId = :con.Id];

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(OrderApi__Sales_Order__c=SO.Id, OrderApi__Contact__c=con.Id);
        insert rec;

        System.runAs(u) {
            Test.startTest();
            SO.OrderApi__Is_Closed__c = true;
            SO.OrderApi__Is_Posted__c = true;
            update SO;
            system.debug('===!!!!' + SO);

            List<OrderApi__Receipt_Line__c> linesToAdd = new List<OrderApi__Receipt_Line__c>();

            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:SO.Id];
            for(OrderApi__Sales_Order_Line__c line: lines){
                OrderApi__Receipt_Line__c rLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=rec.Id, OrderApi__Item__c=line.OrderApi__Item__c);
                linesToAdd.add(rLine);
            }

            insert linesToAdd;


            OrderApi__Transaction__c trans = new OrderApi__Transaction__c(OrderApi__Receipt_Type__c = 'Payment', OrderApi__Contact__c = con.Id, OrderApi__Sales_Order__c = SO.Id, OrderApi__Receipt__c=rec.Id);
            insert trans;

            update trans;

            Test.stoptest();

            list<OrderApi__Transaction_Line__c> Trec = [select id,Plan__c,OrderApi__Credit__c,OrderApi__Debit__c,OrderApi__Item__c, OrderApi__Item__r.Is_Complimentary__c,OrderApi__Item__r.name from OrderApi__Transaction_Line__c where OrderApi__Credit__c = 140.00 OR OrderApi__Credit__c = 175.00];
            //system.debug('======tlline='+Trec);
            system.assert(Trec.size() == 2, 'transaction lines actual: ' + Trec.size());
        }
    }

    static testMethod void testSplitrevenue2YR() {

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c = :con.Id LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId = :con.Id];

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;

        OrderApi__Price_Rule__c pr = [SELECT Id FROM OrderApi__Price_Rule__c WHERE Name='2 years'];
        pr.OrderApi__Required_Subscription_Plans__c = subPlan2.Id;
        update pr;

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(OrderApi__Sales_Order__c=SO.Id, OrderApi__Contact__c=con.Id);
        insert rec;


        System.runAs(u) {
            Test.startTest();

            SO.Is2YR__c = true;
            SO.OrderApi__Is_Closed__c = true;
            SO.OrderApi__Is_Posted__c = true;
            update SO;
            system.debug('===!!!!' + SO);

            List<OrderApi__Receipt_Line__c> linesToAdd = new List<OrderApi__Receipt_Line__c>();

            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:SO.Id];
            for(OrderApi__Sales_Order_Line__c line: lines){
                OrderApi__Receipt_Line__c rLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=rec.Id, OrderApi__Item__c=line.OrderApi__Item__c);
                if(line.OrderApi__Item_Class__r.Name=='Individual Memberships') {
                    if (SO.Is2YR__c) {
                        rLine.OrderApi__Price_Rule__c = pr.Id;
                    }
                }
                linesToAdd.add(rLine);
            }

            insert linesToAdd;

            OrderApi__Transaction__c trans = new OrderApi__Transaction__c(OrderApi__Receipt_Type__c = 'Payment', OrderApi__Contact__c = con.Id, OrderApi__Sales_Order__c = SO.Id, OrderApi__Receipt__c=rec.Id);
            insert trans;

            update trans;


            Test.stoptest();

            list<OrderApi__Transaction_Line__c> Trec = [select id,Plan__c,OrderApi__Credit__c,OrderApi__Debit__c,OrderApi__Item__c, OrderApi__Item__r.Is_Complimentary__c,OrderApi__Item__r.name from OrderApi__Transaction_Line__c where OrderApi__Credit__c = 140.00 OR OrderApi__Credit__c = 175.00];
            system.debug('======tlline='+Trec);
            system.assert(Trec.size() == 4, 'transaction lines actual: ' + Trec.size());
        }
    }


    @IsTest
    public static void test_1YRSuspended(){
        //1YR suspended, renewals on, current year == term year

        Renewal_Settings__c renewalSettings = new Renewal_Settings__c();
        renewalSettings.Is_Active__c = true;
        renewalSettings.Term_Year__c = System.now().year();
        insert renewalSettings;

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Item_Class__c duesClass = TestDataFactory.buildItemClass('Prior Year Dues');
        insert duesClass;

        OrderApi__Item__c duesItem = TestDataFactory.buildItem(duesClass.Id, '1-YR Dues');
        duesItem.OrderApi__Price__c = 315.00;
        insert duesItem;

        OrderApi__Item__c membershipItem = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];

        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true];

        OrderApi__Subscription__c membershipSub = new OrderApi__Subscription__c(
                OrderApi__Contact__c = con.Id,
                OrderApi__Item__c = membershipItem.Id,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Is_Cancelled__c = false,
                OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-1, System.now().month(), SYstem.now().day()),
                OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-1, 12, 31),
                OrderApi__Paid_Through_Date__c = Date.newInstance(System.now().year()-1, 12, 31)
        );
        insert membershipSub;

        OrderApi__Subscription_Line__c subLine = new OrderApi__Subscription_Line__c(
                OrderApi__Subscription__c = membershipSub.Id,
                OrderApi__Item__c = membershipItem.Id
        );
        insert subLine;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c = Date.newInstance(System.now().year()-1, System.now().month(), SYstem.now().day()),
                OrderApi__Term_End_Date__c = Date.newInstance(System.now().year()-1, 12, 31),
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Subscription__c = membershipSub.Id
        );
        insert term;


        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=con.Id);
        insert SO;

        OrderApi__Sales_Order_Line__c membershipLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c=SO.Id,
                OrderApi__Item__c = membershipItem.Id,
                OrderApi__Item_Class__c = membershipItem.OrderApi__Item_Class__c,
                OrderApi__Subscription__c = membershipSub.Id,
                OrderApi__Is_Renewal__c = true,
                OrderApi__Subscription_Plan__c = subPlan.Id
        );
        insert membershipLine;

        OrderApi__Sales_Order_Line__c duesLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c=SO.Id,
                OrderApi__Item__c = duesItem.Id,
                OrderApi__Item_Class__c = duesClass.Id
        );
        insert duesLine;

        Test.startTest();

        SO.OrderApi__Is_Closed__c = true;
        SO.OrderApi__Is_Posted__c = true;
        update SO;

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(OrderApi__Sales_Order__c=SO.Id, OrderApi__Contact__c=con.Id);
        insert rec;

        OrderApi__Transaction__c trans = new OrderApi__Transaction__c(OrderApi__Receipt_Type__c = 'Payment', OrderApi__Contact__c = con.Id, OrderApi__Sales_Order__c = SO.Id, OrderApi__Receipt__c=rec.Id);
        insert trans;

        List<OrderApi__Receipt_Line__c> linesToAdd = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Transaction_Line__c> transLinesToAdd = new List<OrderApi__Transaction_Line__c>();

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item_Class__c, OrderApi__Subscription__c, OrderApi__Item__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:SO.Id];
        for(OrderApi__Sales_Order_Line__c line: lines){
            OrderApi__Receipt_Line__c rLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=rec.Id, OrderApi__Item__c=line.OrderApi__Item__c, OrderApi__Item_Class__c = line.OrderApi__Item_Class__c);
            linesToAdd.add(rLine);
            OrderApi__Transaction_Line__c tLine = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c=trans.Id, OrderApi__Subscription__c=line.OrderApi__Subscription__c, OrderApi__Item__c=line.OrderApi__Item__c, OrderApi__Item_Class__c=line.OrderApi__Item_Class__c, OrderApi__Receipt_Line__c=rLine.Id, OrderApi__Receipt__c=rec.Id);
            transLinesToAdd.add(tLine);
        }

        insert linesToAdd;
        insert transLinesToAdd;

        update trans;

        Test.stopTest();

        trans = [SELECT Id FROM OrderApi__Transaction__c WHERE OrderApi__Sales_Order__c=: SO.Id];
        System.assertNotEquals(null, trans);

    }

    @IsTest
    public static void test_2YRSuspended(){
        //2YR suspended, renewals on, current year!=term year

        Renewal_Settings__c renewalSettings = new Renewal_Settings__c();
        renewalSettings.Is_Active__c = true;
        renewalSettings.Term_Year__c = System.now().year()+1;
        insert renewalSettings;

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Item_Class__c duesClass = TestDataFactory.buildItemClass('Prior Year Dues');
        insert duesClass;

        OrderApi__Item__c duesItem = TestDataFactory.buildItem(duesClass.Id, '1-YR Dues');
        duesItem.OrderApi__Price__c = 315.00;
        insert duesItem;

        OrderApi__Item__c membershipItem = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];

        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true];
        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;

        OrderApi__Subscription__c membershipSub = new OrderApi__Subscription__c(
                OrderApi__Contact__c = con.Id,
                OrderApi__Item__c = membershipItem.Id,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Is_Cancelled__c = false,
                OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-2, System.now().month(), SYstem.now().day()),
                OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-2, 12, 31),
                OrderApi__Paid_Through_Date__c = Date.newInstance(System.now().year()-2, 12, 31)
        );
        insert membershipSub;

        OrderApi__Subscription_Line__c subLine = new OrderApi__Subscription_Line__c(
                OrderApi__Subscription__c = membershipSub.Id,
                OrderApi__Item__c = membershipItem.Id
        );
        insert subLine;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c(
                OrderApi__Term_Start_Date__c = Date.newInstance(System.now().year()-2, System.now().month(), SYstem.now().day()),
                OrderApi__Term_End_Date__c = Date.newInstance(System.now().year()-2, 12, 31),
                OrderApi__Subscription_Plan__c = subPlan.Id,
                OrderApi__Subscription__c = membershipSub.Id
        );
        insert term;


        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=con.Id);
        insert SO;

        OrderApi__Sales_Order_Line__c membershipLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c=SO.Id,
                OrderApi__Item__c = membershipItem.Id,
                OrderApi__Item_Class__c = membershipItem.OrderApi__Item_Class__c,
                OrderApi__Subscription__c = membershipSub.Id,
                OrderApi__Is_Renewal__c = true,
                OrderApi__Subscription_Plan__c = subPlan2.Id
        );
        insert membershipLine;

        OrderApi__Sales_Order_Line__c duesLine = new OrderApi__Sales_Order_Line__c(
                OrderApi__Sales_Order__c=SO.Id,
                OrderApi__Item__c = duesItem.Id,
                OrderApi__Item_Class__c = duesClass.Id
        );
        insert duesLine;

        Test.startTest();

        SO.Is2YR__c = true;
        SO.OrderApi__Is_Closed__c = true;
        SO.OrderApi__Is_Posted__c = true;
        update SO;

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(OrderApi__Sales_Order__c=SO.Id, OrderApi__Contact__c=con.Id);
        insert rec;

        OrderApi__Transaction__c trans = new OrderApi__Transaction__c(OrderApi__Receipt_Type__c = 'Payment', OrderApi__Contact__c = con.Id, OrderApi__Sales_Order__c = SO.Id, OrderApi__Receipt__c=rec.Id);
        insert trans;

        List<OrderApi__Receipt_Line__c> linesToAdd = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Transaction_Line__c> transLinesToAdd = new List<OrderApi__Transaction_Line__c>();

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Total__c, OrderApi__Item_Class__c, OrderApi__Subscription__c, OrderApi__Item__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:SO.Id];
        for(OrderApi__Sales_Order_Line__c line: lines){
            OrderApi__Receipt_Line__c rLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=rec.Id, OrderApi__Item__c=line.OrderApi__Item__c, OrderApi__Item_Class__c = line.OrderApi__Item_Class__c);
            linesToAdd.add(rLine);
            OrderApi__Transaction_Line__c tLine = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c=trans.Id, OrderApi__Credit__c=line.OrderApi__Total__c, OrderApi__Subscription__c=line.OrderApi__Subscription__c, OrderApi__Item__c=line.OrderApi__Item__c, OrderApi__Item_Class__c=line.OrderApi__Item_Class__c, OrderApi__Receipt_Line__c=rLine.Id, OrderApi__Receipt__c=rec.Id);
            transLinesToAdd.add(tLine);
            if(line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && SO.Is2YR__c){
                transLinesToAdd.add(Fon_TransactionService.createFutureTransactionLine(tLine, trans.Id));
            }
        }

        insert linesToAdd;
        insert transLinesToAdd;

        update trans;

        Test.stopTest();

        trans = [SELECT Id FROM OrderApi__Transaction__c WHERE OrderApi__Sales_Order__c=: SO.Id];
        System.assertNotEquals(null, trans);


    }

}
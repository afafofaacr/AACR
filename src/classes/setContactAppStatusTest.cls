@IsTest
public class setContactAppStatusTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;
        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert sol;

        Contact member = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert member;
        OrderApi__Sales_Order__c so2 = TestDataFactory.buildOpenSalesOrder(acc.Id, member.Id);
        insert so2;
        OrderApi__Sales_Order_Line__c sol2 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert sol2;

        //Appeal codes for Opportunity
        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        OrderApi__Source_Code__c sc = TestDataFactory.buildSourceCode('WAIVE');
        insert sc;

        Offer__c o = new Offer__c(
                SourceCode__c = sc.Id,
                Prefix__c = 'BOGO'
        );
        insert o;

        OfferVersion__c ov = new OfferVersion__c(
                StartDate__c = Date.today(),
                EndDate__c = Date.today().addDays(7),
                Offer__c = o.Id,
                Name = 'OfferVersionName',
                Publish__c = true,
                Override__c = false,
                SOQLQuery__c = 'SELECT Id, ContactId FROM User WHERE IsActive=true AND ContactId!=null'
        );
        insert ov;

        OfferMembership__c om = new OfferMembership__c(
                Contact__c = con.Id,
                Offer__c = o.Id,
                Name = 'OfferMembersipName',
                OfferVersion__c = ov.Id,
                Used__c = false
        );
        insert om;
    }

    @IsTest
    public static void test_useOffer(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        OrderApi__Source_Code__c sc = [SELECT id FROM OrderApi__Source_Code__c LIMIT 1];
        OfferMembership__c om = [SELECT Id FROM OfferMembership__c WHERE Contact__c=:con.Id];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];
        so.OrderApi__Source_Code__c = sc.Id;
        so.Offer_Membership__c = om.Id;
        update so;

        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Contact__c = con.Id;
        receipt.OrderApi__Sales_Order__c = so.Id;
        test.startTest();
        insert receipt;

        receipt.OrderApi__Is_Posted__c = true;
        update receipt;
        test.stopTest();

        om = [SELECT Id, Used__c FROM OfferMembership__c WHERE Contact__c=:con.Id];
        System.assertEquals(true, om.Used__c);

    }

    @IsTest static void testAppStatus(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.Name='Nonmember' LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Contact__c = con.Id;
        receipt.OrderApi__Sales_Order__c = so.Id;
        test.startTest();
        insert receipt;
        test.stopTest();

        con = [SELECT Application_Status__c FROM Contact WHERE Id=: con.Id];
        System.assertEquals('Pending Approval', con.Application_Status__c);

    }

    @IsTest static void testAppStatusTransfer(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.Name='Member' LIMIT 1];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];
        so.OrderApi__Description__c = 'Transfer Application';
        update so;
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Contact__c = con.Id;
        receipt.OrderApi__Sales_Order__c = so.Id;
        test.startTest();
        insert receipt;
        test.stopTest();

        con = [SELECT Application_Status__c FROM Contact WHERE Id=: con.Id];
        System.assertEquals(null, con.Application_Status__c);

    }
}
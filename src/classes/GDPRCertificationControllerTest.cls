/**
 * Created by lauren.lezberg on 1/14/2021.
 */

@IsTest
private class GDPRCertificationControllerTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic'
        );
        insert testEvent;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        itemClass.OrderApi__Is_Subscription__c = false;
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        item.OrderApi__Is_Subscription__c= false;
        item.AC_Event__c = testEvent.Id;
        insert item;

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert sol;

        insert new BR_Participation__c(Contact__c=con.Id, BR_Event__c=testEvent.Id, User__c=u.Id, Participate__c='Incomplete', Fon_Sales_Order__c=so.Id);

    }

    @IsTest
    static void test_getGDPRInfo() {
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__r.Account.Name='Test Account'];


        Test.startTest();

        String pId = GDPRCertificationController.getGDPRInfo(so.Id);
        System.assertNotEquals(null, pId);

        Test.stopTest();
    }

    @IsTest
    public static void test_getDefault(){
        Contact con = [SELECT Id fROM Contact WHERE Account.Name='Test Account'];
        con.MailingState = 'California';
        con.MailingCountryCode = 'US';
        con.Preferred_Address__c = 'Business';

        update con;

        Test.startTest();

        Boolean gdprDefault = GDPRCertificationController.getGDPRDefault(con.Id);
        System.assertEquals(false, gdprDefault);

        con.OtherState = 'Texas';
        con.OtherCountryCode = 'US';
        con.Preferred_Address__c = 'Home';

        update con;

        gdprDefault = GDPRCertificationController.getGDPRDefault(con.Id);
        System.assertEquals(true, gdprDefault);

        Test.stopTest();
    }
}
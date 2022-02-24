/**
 * Created by mitfity on 20.08.2019.
 */

@IsTest
private class brSalesOrderTriggerTest {

    @IsTest
    static void testParticipationDependency() {
        Test.startTest();

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
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert testEvent;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        OrderApi__Sales_Order__c order = new OrderApi__Sales_Order__c();
        order.OrderApi__Contact__c = con.Id;
        order.OrderApi__Status__c = 'Open';
        insert order;

        BR_Participation__c participation = new BR_Participation__c();
        participation.Fon_Sales_Order__c = order.Id;
        participation.BR_Event__c = testEvent.Id;
        participation.User__c = u.Id;
        participation.Contact__c = con.Id;
        insert participation;

        order.OrderApi__Status__c = 'Closed';
        order.OrderApi__Posting_Status__c = 'Posted';
        update order;

        participation = [SELECT Participate__c FROM BR_Participation__c];

        System.assertEquals('Yes', participation.Participate__c);

        Test.stopTest();
    }
}
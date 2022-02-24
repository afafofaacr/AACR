/**
 * Created by lauren.lezberg on 7/22/2021.
 */

@IsTest
private class AdvocateAppConfirmationControllerTest {

    @TestSetup
    public static void setup(){

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
        SYstem.assertEquals(orgWideEmailId, owas[0].Id);


        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c testEvent = LiveTestDataFactory.buildEvent('Test Event', true, false);
        testEvent.Start_Date__c = Datetime.newInstance(System.now().year(), System.now().month() +1, 12, 24, 0, 0);
        testEvent.End_Date__c = Datetime.newInstance(System.now().year(), System.now().month() +1, 13, 12, 0, 0);
        insert testEvent;

        BR_Participation__c ticket = new BR_Participation__c(Contact__c=con.Id, BR_Event__c=testEvent.Id, Participate__c='Incomplete');
        insert ticket;

    }

    @IsTest
    static void test_getEventInfo() {
        User u = [SELECT Id FROM User WHERE Contact.Account.Name='Test Account'];
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        System.runAs(u){
            Test.startTest();

            AdvocateAppConfirmationController.EventInfo eInfo = AdvocateAppConfirmationController.getEventInfo(evt.Id);

            Test.stopTest();
        }
    }
}
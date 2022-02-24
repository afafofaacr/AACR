/**
 * Created by lauren.lezberg on 9/25/2020.
 */

@IsTest
private class ResendConfirmationEmailControllerTest {

    @TestSetup
    public static void setup(){
        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert evt;

        BR_Participation__c participation = new BR_Participation__c();
        participation.User__c = u.Id;
        participation.Contact__c = con.Id;
        participation.BR_Event__c = evt.Id;
        participation.Participate__c = 'Yes';
        insert participation;

    }

    @IsTest
    static void test_resendEmail() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        BR_Participation__c participant = [SELECT Id FROM BR_Participation__c WHERE Contact__c=:con.Id];

        Test.startTest();

        ResendConfirmationEmailController.resendEmail(participant.Id, '[]');

        Test.stopTest();
    }
}
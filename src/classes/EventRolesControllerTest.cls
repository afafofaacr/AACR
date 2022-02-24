/**
 * Created by lauren.lezberg on 6/23/2020.
 */
@isTest
private with sharing class EventRolesControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, true);
        insert evt;

        Meeting_Role__c role = new Meeting_Role__c(AC_Event__c=evt.Id,User__c=u.Id, Role__c='Meetings Manager' );
        insert role;

    }

    @isTest
    public static void test_getRoles(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();

        List<Meeting_Role__c> roles = EventRolesController.getRoles(evt.Id);
        System.assertEquals(1, roles.size());

        Boolean resp = EventRolesController.deleteRole(roles[0].Id);
        System.assertEquals(true, resp);

        resp = EventRolesController.deleteRole(roles[0].Id);
        System.assertEquals(false, resp);


        Test.stopTest();
    }


}
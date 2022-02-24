/**
 * Created by lauren.lezberg on 2/20/2020.
 */
@isTest
private with sharing class EventNew_OverrideControllerTest {

    @isTest
    public static void test_GetJoinId(){
        Id jpId = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Event_Create'].Id;

        Test.startTest();
        Id eventNewJPId = EventNew_OverrideController.getEventBuilderJoinId();
        Test.stopTest();

        System.assertEquals(jpId, eventNewJPId);
    }
}
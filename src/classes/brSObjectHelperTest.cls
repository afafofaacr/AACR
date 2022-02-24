/**
 * Created by mitfity on 23.07.2019.
 */

@IsTest
private class brSObjectHelperTest {

    @TestSetup
    static void setup() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();
        PermissionSet adminPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Live_Events_Admin'];

        Integer assignmentCount = [
                SELECT COUNT()
                FROM PermissionSetAssignment
                WHERE AssigneeId = :currentUserId AND PermissionSetId = :adminPermissionSet.Id
        ];

        if (assignmentCount == 0) {
            insert new PermissionSetAssignment(AssigneeId = currentUserId, PermissionSetId = adminPermissionSet.Id);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetFieldSetOptions() {
        Test.startTest();

        List<Map<String, String>> fieldSetOptions = brSObjectHelper.getFieldSetOptions(BR_Participation__c.SObjectType);

        System.assertNotEquals(null, fieldSetOptions);

        Test.stopTest();
    }
}
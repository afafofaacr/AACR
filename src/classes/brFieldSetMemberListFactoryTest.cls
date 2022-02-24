/**
 * Created by mitfity on 22.07.2019.
 */

@IsTest
private class brFieldSetMemberListFactoryTest {

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
    static void testMock2() {
        Test.startTest();

        Boolean exceptionThrown = false;

        try {
            brFieldSetMemberListFactory.setMock(new List<SObjectField> { BR_Participation__c.Name });
            Schema.FieldSet fs1 = Schema.SObjectType.BR_Participation__c.fieldSets.getMap().get('Dietary_Preferences');
            brFieldSetMemberListFactory.construct(fs1, 'update');
        } catch (Exception e) {
            exceptionThrown = true;
        } finally {
            System.assertEquals(false, exceptionThrown);
        }

        Test.stopTest();
    }

    @IsTest
    static void testMock() {
        Test.startTest();

        Boolean exceptionThrown = false;

        try {
            brFieldSetMemberListFactory.setMock(new List<SObjectField> { BR_Participation__c.Name });
            brFieldSetMemberListFactory.construct(null);
        } catch (Exception e) {
            exceptionThrown = true;
        } finally {
            System.assertEquals(false, exceptionThrown);
        }

        Test.stopTest();
    }
}
/**
 * Created by mitfity on 18.07.2019.
 */

@IsTest
private class brSecurityTest {

    @TestSetup
    static void setup() {
        Test.startTest();

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

//        Id currentUserId = UserInfo.getUserId();
//        PermissionSet adminPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Live_Events'];
//
//        Integer assignmentCount = [
//                SELECT COUNT()
//                FROM PermissionSetAssignment
//                WHERE AssigneeId = :currentUserId AND PermissionSetId = :adminPermissionSet.Id
//        ];
//
//        if (assignmentCount == 0) {
//            insert new PermissionSetAssignment(AssigneeId = currentUserId, PermissionSetId = adminPermissionSet.Id);
//        }

        Test.stopTest();
    }

    @IsTest
    static void testPerformAccessCheck() {
        User u = [SELECT Id FROM User WHERE Email = 'testusr100@testorg.com'];
        System.runAs(u) {
            Test.startTest();
            brSecurity.performAccessCheck('write', BR_Event__c.getSObjectType(),
                    new List<SObjectField>{
                            BR_Event__c.Name, BR_Event__c.Description__c
                    }
            );

            Boolean noAccessHandled = false;
            try {
                brSecurity.performAccessCheck('write', BR_Event__c.getSObjectType(),
                        new List<SObjectField>{
                                BR_Event__c.CreatedDate
                        }
                );
            } catch (AuraHandledException e) {
                noAccessHandled = true;
            } finally {
                System.assertEquals(true, noAccessHandled, 'Access was not checked correctly.');
            }

            brSecurity.performAccessCheck('delete', BR_Event__c.getSObjectType(), null);

            brSecurity.performAccessCheck('read', BR_Event__c.getSObjectType(),
                    new List<SObjectField>{
                            BR_Event__c.Name
                    }
            );

            brSecurity.performAccessCheck('edit', BR_Event__c.getSObjectType(),
                    new List<SObjectField>{
                            BR_Event__c.Name
                    }
            );

            brSecurity.performAccessCheck('edit', BR_Event__c.getSObjectType());

            Test.stopTest();
        }
    }

    @IsTest
    static void testGetAccessibleFields() {
        Test.startTest();

        Map<String, Schema.SObjectField> fieldMap = AC_User_Segment__c.SObjectType.getDescribe().fields.getMap();

        fieldMap = brSecurity.getAccessibleFields(fieldMap);
        System.assertNotEquals(null, fieldMap);

        fieldMap = brSecurity.getAccessibleFields(fieldMap, 'any');
        System.assertNotEquals(null, fieldMap);

        fieldMap = brSecurity.getAccessibleFields(fieldMap, 'create');
        System.assertNotEquals(null, fieldMap);

        fieldMap = brSecurity.getAccessibleFields(fieldMap, 'update');
        System.assertNotEquals(null, fieldMap);

        fieldMap = brSecurity.getAccessibleFields(fieldMap, 'read');
        System.assertNotEquals(null, fieldMap);

        Test.stopTest();
    }
}
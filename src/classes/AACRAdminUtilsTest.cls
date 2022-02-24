/**
 * Created by lauren.lezberg on 12/11/2019.
 */
@isTest
private with sharing class AACRAdminUtilsTest {

    @testSetup
    public static void setup(){
        Renewal_Settings__c renSettings = new Renewal_Settings__c();
        renSettings.Name = 'Test Renewal Setting';
        renSettings.Is_Active__c = true;
        renSettings.Term_Year__c = System.now().year();
        insert renSettings;


        DW_Manage_Dues_Item__c duesItem = new DW_Manage_Dues_Item__c();
        duesItem.Name='Test Dues Item';
        duesItem.Delinquent_Years__c = 1;
        duesItem.Membership_Item_Name__c='1YR Dues';
        insert duesItem;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u = TestDataFactory.buildTestUser(p.Id, 'admin', 'user');
        insert u;


    }


    @isTest
    public static void test_getIncidentTypes(){
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        Integer incidentCount = [SELECT COUNT() FROM ServiceNow_Incident_Type__mdt];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'ServiceNow_Incident_Types'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Test.startTest();

        System.runAs(u) {

            List<ServiceNow_Incident_Type__mdt> types = AACRAdminUtils.getIncidentTypes();

            System.assertNotEquals(null, types);
            System.assertEquals(incidentCount , types.size());

        }

        Test.stopTest();
    }

    @isTest
    public static void test_getSiteConfigs(){
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];


        List<Maintenance_Mode_Config__mdt> mConfigs = [SELECT DeveloperName, Id FROM Maintenance_Mode_Config__mdt];

        if(!mConfigs.isEmpty()) {
            PermissionSet ps = new PermissionSet();
            ps.Name = 'Test';
            ps.Label = 'Test';
            insert ps;

            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = :mConfigs[0].DeveloperName][0].Id;
            insert sea;

            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }

        Test.startTest();

        System.runAs(u) {

            List<Maintenance_Mode_Config__mdt> configs = AACRAdminUtils.getSiteConfigs();

            System.assertNotEquals(null, configs);
            mConfigs = [SELECT DeveloperName, Id FROM Maintenance_Mode_Config__mdt];
            System.assertEquals(mConfigs.size(), 2);

        }

        Test.stopTest();

    }

    @isTest
    public static void test_getDirectoryCriteria() {
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Directory_Settings'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Integer dcCount = [SELECT COUNT() FROM Directory_Criteria__mdt];

        Test.startTest();

        System.runAs(u) {
            List<Directory_Criteria__mdt> dc = AACRAdminUtils.getDirectoryCriteria();
            System.assertNotEquals(null, dc);
            System.assertEquals(dcCount, dc.size());
        }

        Test.stopTest();
    }

    @isTest
    public static void test_getDirectoryLaunchData() {
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Directory_Settings'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Integer dldCount = [SELECT COUNT() FROM Directory_Launch_Data__mdt];

        Test.startTest();

        System.runAs(u) {
            List<Directory_Launch_Data__mdt> dld = AACRAdminUtils.getDirectoryLaunchData();
            System.assertNotEquals(null, dld);
            System.assertEquals(dldCount, dld.size());
        }

        Test.stopTest();
    }

    @isTest
    public static void test_getRenewalSettings() {
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Renewal_Settings'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Test.startTest();

        System.runAs(u) {

            Renewal_Settings__c renewalSettings = AACRAdminUtils.getRenewalSettings();

            System.assertNotEquals(null, renewalSettings);


        }

        Test.stopTest();
    }

//    @isTest
//    public static void test_getDuesItems() {
//        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];
//
//        PermissionSet ps = new PermissionSet();
//        ps.Name = 'Test';
//        ps.Label = 'Test';
//        insert ps;
//
//        SetupEntityAccess sea = new SetupEntityAccess();
//        sea.ParentId = ps.Id;
//        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Renewal_Settings'][0].Id;
//        insert sea;
//
//        PermissionSetAssignment psa = new PermissionSetAssignment();
//        psa.AssigneeId = u.Id;
//        psa.PermissionSetId = ps.Id;
//        insert psa;
//
//        Test.startTest();
//
//        System.runAs(u) {
//
//            List<DW_Manage_Dues_Item__c> duesItems = AACRAdminUtils.getDuesItems();
//
//            System.assertNotEquals(null, duesItems);
//            System.assertEquals(1, duesItems.size());
//
//        }
//
//        Test.stopTest();
//    }


}
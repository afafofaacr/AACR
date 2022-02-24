/**
 * Created by lauren.lezberg on 12/11/2019.
 */
@isTest
private with sharing class AACRAdminControllerTest {

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
    public static void test_getIncidentTypesWithAccess(){

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

            List<ServiceNow_Incident_Type__mdt> types = AACRAdminController.getIncidentTypes();

            System.assertNotEquals(null, types);
            System.assertEquals(incidentCount , types.size());


            ServiceNow_Incident_Type__mdt t = types[0];
            t.Is_Active__c = false;
            AACRAdminController.updateIncidentType(t);

        }

        Test.stopTest();


    }

    @isTest
    public static void test_getIncidentTypesWithoutAccess(){

        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        Test.startTest();

        System.runAs(u) {

            List<ServiceNow_Incident_Type__mdt> types = AACRAdminController.getIncidentTypes();

            System.assertNotEquals(null, types);
            System.assertEquals(16, types.size());

        }

        Test.stopTest();


    }

    @isTest
    public static void test_getSiteConfigsWithAccess(){

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


            List<Maintenance_Mode_Config__mdt> configs = AACRAdminController.getSiteConfigs();


            System.assertNotEquals(null, configs);

            mConfigs = [SELECT DeveloperName, Id FROM Maintenance_Mode_Config__mdt];
            System.assertEquals(mConfigs.size(), 2);

            Maintenance_Mode_Config__mdt mmc = configs[0];
            mmc.Is_Active__c = true;
            AACRAdminController.saveSiteConfigs(mmc);

        }

        Test.stopTest();
    }

    @isTest
    public static void test_getSiteConfigsWithoutAccess(){

        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];


        Test.startTest();

        System.runAs(u) {
            List<Maintenance_Mode_Config__mdt> configs = AACRAdminController.getSiteConfigs();
            System.assertNotEquals(null, configs);
            System.assertEquals(2, configs.size());
        }

        Test.stopTest();

    }

    @isTest
    public static void test_getDirectorySettingsDataWithAccess(){
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

        Integer launchDataCount = [SELECT COUNT() FROM Directory_Launch_Data__mdt];

        Test.startTest();

        System.runAs(u) {

            AACRAdminController.DirectorySettingsData dsd = AACRAdminController.getDirectorySettingsData();

            System.assertNotEquals(null, dsd);
            System.assertNotEquals(null, dsd.directoryCriteria);
            System.assertEquals(launchDataCount, dsd.launchData.size());


            Directory_Launch_Data__mdt dld = dsd.launchData[0];
            dld.Message__c = 'TEST MESSAGE';
            AACRAdminController.saveDirectoryLaunchData(dld);

            Directory_Criteria__mdt dc = dsd.directoryCriteria;
            dc.Is_Active__c = true;
            AACRAdminController.saveDirectoryCriteria(dc);


        }

        Test.stopTest();


    }

    @isTest
    public static void test_getDirectorySettingsDataWithoutAccess(){
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        Test.startTest();

        System.runAs(u) {

            AACRAdminController.DirectorySettingsData dsd = AACRAdminController.getDirectorySettingsData();

            System.assertNotEquals(null, dsd);
            System.assertNotEquals(null, dsd.directoryCriteria);
            System.assertEquals(2, dsd.launchData.size());

        }

        Test.stopTest();
    }

    @isTest
    public static void test_getRenewalDataWithAccess(){

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

            AACRAdminController.RenewalData rd = AACRAdminController.getRenewalData();
            System.assertNotEquals(null, rd);
//            System.assertEquals(1, rd.duesItems.size());
            System.assertNotEquals(null, rd.renewalSettings);


            Renewal_Settings__c rs = rd.renewalSettings;
            rs.Term_Year__c = System.now().year() - 1;
            AACRAdminController.saveRenewalSettings(rs);

//            DW_Manage_Dues_Item__c di = rd.duesItems[0];
//            di.Membership_Item_Name__c = 'TEST ITEM';
//            AACRAdminController.saveDuesItem(di);

            rd = AACRAdminController.getRenewalData();
            System.assertNotEquals(null, rd);
//            System.assertEquals('TEST ITEM', rd.duesItems[0].Membership_Item_Name__c);
            System.assertEquals(System.now().year() - 1, rd.renewalSettings.Term_Year__c);
        }

        Test.stopTest();


    }

    @isTest
    public static void test_getRenewalDataWithoutAccess(){
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        Test.startTest();

        System.runAs(u) {

            AACRAdminController.RenewalData rd = AACRAdminController.getRenewalData();
            System.assertNotEquals(null, rd);
//            System.assertEquals(0, rd.duesItems.size());
//            System.assertEquals(null, rd.renewalSettings);

        }

        Test.stopTest();
    }


}
/**
 * Created by lauren.lezberg on 9/6/2019.
 */

public without sharing class AACRAdminUtils {
//
//    public class CommunityLicenseSettings{
//        @AuraEnabled
//        public Community_License_Settings__c lSetting;
//
//        @AuraEnabled
//        public Integer licenseCount;
//
//        public CommunityLicenseSettings(){
//            this.lSetting = getCommunityLicenseWarningSettings();
//            this.licenseCount = getCommunityLicenseCount();
//        }
//    }
//
//    public static Community_License_Settings__c getCommunityLicenseWarningSettings(){
//        Community_License_Settings__c settings;
//        if(FeatureManagement.checkPermission('Community_Licenses')){
//            settings = [SELECT Email__c, Warning_Limit__c FROM Community_License_Settings__c];
//        }
//
//        return settings;
//    }
//
//    public static Integer getCommunityLicenseCount(){
//        Integer toReturn;
//        List<AggregateResult> groupedResults = [select COUNT(Id) from user WHERE profile.UserLicense.name='Customer Community Login' AND IsActive = true group by profile.UserLicense.name];
//        for(AggregateResult ar : groupedResults){
//            toReturn = (Integer)ar.get('expr0');
//        }
//        System.debug('toReturn: ' + toReturn);
//        return toReturn;
//    }
//
//    public static void saveCommunityLicenseSettings(Community_License_Settings__c setting){
//        update setting;
//    }

    public static List<ServiceNow_Incident_Type__mdt> getIncidentTypes(){
        List<ServiceNow_Incident_Type__mdt> incidentTypes = new List<ServiceNow_Incident_Type__mdt>();
        if(FeatureManagement.checkPermission('ServiceNow_Incident_Types')){
            incidentTypes = [SELECT Id, Is_Active__c,Email_Recipient__c, Type__c, Label, DeveloperName, MasterLabel FROM ServiceNow_Incident_Type__mdt ORDER BY Is_Active__c DESC];
        }
        return incidentTypes;
    }

    public static List<Maintenance_Mode_Config__mdt> getSiteConfigs(){
        List<Maintenance_Mode_Config__mdt> maintenanceModeConfigs = [SELECT Id, Is_Active__c, Maintenance_Message__c,Page_API_Name__c, Label, DeveloperName, MasterLabel FROM Maintenance_Mode_Config__mdt ORDER BY Is_Active__c DESC];
        List<Maintenance_Mode_Config__mdt> accessibleConfigs = new List<Maintenance_Mode_Config__mdt>();
        for(Maintenance_Mode_Config__mdt config : maintenanceModeConfigs){
            if(FeatureManagement.checkPermission(config.DeveloperName)){
                accessibleConfigs.add(config);
            }
        }
        return accessibleConfigs;
    }

    public static List<Directory_Criteria__mdt> getDirectoryCriteria(){
        List<Directory_Criteria__mdt> directoryCriteria = new List<Directory_Criteria__mdt>();
        if(FeatureManagement.checkPermission('Directory_Settings')) {
            directoryCriteria = [SELECT Id, Is_Active__c, Show_Filters__c, Query__c, Query_String__c, DeveloperName, MasterLabel FROM Directory_Criteria__mdt ORDER BY Is_Active__c DESC];
        }
        return directoryCriteria;
    }

    public static List<Directory_Launch_Data__mdt> getDirectoryLaunchData(){
        List<Directory_Launch_Data__mdt> launchData = new List<Directory_Launch_Data__mdt>();
        if(FeatureManagement.checkPermission('Directory_Settings')) {
            launchData = [SELECT Id, Message__c, Record_Type__c, URL__c, DeveloperName, MasterLabel FROM Directory_Launch_Data__mdt];
        }
        return launchData;
    }

    public static Renewal_Settings__c getRenewalSettings(){
        Renewal_Settings__c settings;
        if(FeatureManagement.checkPermission('Renewal_Settings')){
            settings = [SELECT Id, Term_Year__c, Is_Active__c FROM Renewal_Settings__c];
        }
        return settings;
    }

    public static Member_Count__c getMemberCount(){
        if(FeatureManagement.checkPermission('Member_Count')){
            Member_Count__c mc = [SELECT Id, Count__c FROM Member_Count__c];
            return mc;
        }
        return null;
    }


    public static void saveMemberCount(Member_Count__c mc){
        update mc;
    }

//    public static List<DW_Manage_Dues_Item__c> getDuesItems(){
//        List<DW_Manage_Dues_Item__c> duesItems = new List<DW_Manage_Dues_Item__c>();
//        if(FeatureManagement.checkPermission('Renewal_Settings')){
//            duesItems = [SELECT Id, Membership_Item_Name__c, Delinquent_Years__c, Name FROM DW_Manage_Dues_Item__c];
//        }
//        return duesItems;
//    }

    public static void saveRenewalSettings(Renewal_Settings__c record){
        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
        renewalProcess.Is_Active__c = record.Is_Active__c;
        renewalProcess.Term_Year__c = record.Term_Year__c;
        update renewalProcess;
    }


    public static List<AC_User_Segment__c> getActiveUserSegments(){
        List<AC_User_Segment__c> segments = new List<AC_User_Segment__c>();
        segments = [SELECT Id, Name, Query__c FROM AC_User_Segment__c WHERE Active__c = true AND Available__c = true];
        return segments;
    }
    


    public static void updateIncidentType(ServiceNow_Incident_Type__mdt record){

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'ServiceNow_Incident_Type__mdt.' + record.DeveloperName;
        customMetadata.label = record.MasterLabel;

        Metadata.CustomMetadataValue iType = new Metadata.CustomMetadataValue();
        iType.field = 'Type__c';
        iType.value = record.Type__c;
        customMetadata.values.add(iType);

        Metadata.CustomMetadataValue isActive = new Metadata.CustomMetadataValue();
        isActive.field = 'Is_Active__c';
        isActive.value = record.Is_Active__c;
        customMetadata.values.add(isActive);

        Metadata.CustomMetadataValue emailRecipient = new Metadata.CustomMetadataValue();
        emailRecipient.field = 'Email_Recipient__c';
        emailRecipient.value = record.Email_Recipient__c;
        customMetadata.values.add(emailRecipient);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        MetadataCallback callback = new MetadataCallback();

        Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        System.debug('jobId: ' + jobId);

    }

    public static void createSegmentFields(List<UserSegmentHelper.FieldValuePair> fvps, String objectName){
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

        for(UserSegmentHelper.FieldValuePair fvp : fvps) {
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'User_Segment_Fields__mdt.' + fvp.fieldName.substringBefore('__c');
            customMetadata.label = fvp.fieldLabel;

            Metadata.CustomMetadataValue apiName = new Metadata.CustomMetadataValue();
            apiName.field = 'API_Name__c';
            apiName.value = fvp.fieldName;
            customMetadata.values.add(apiName);

            Metadata.CustomMetadataValue objName = new Metadata.CustomMetadataValue();
            objName.field = 'Object_Type__c';
            objName.value = objectName;
            customMetadata.values.add(objName);


            mdContainer.addMetadata(customMetadata);
        }

        MetadataCallback callback = new MetadataCallback();

        Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);

    }


    public static void saveDirectoryCriteria(Directory_Criteria__mdt record){

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'Directory_Criteria__mdt.' + record.DeveloperName;
        customMetadata.label = record.MasterLabel;

        Metadata.CustomMetadataValue showFilters = new Metadata.CustomMetadataValue();
        showFilters.field = 'Show_Filters__c';
        showFilters.value = record.Show_Filters__c;
        customMetadata.values.add(showFilters);

        Metadata.CustomMetadataValue isActive = new Metadata.CustomMetadataValue();
        isActive.field = 'Is_Active__c';
        isActive.value = record.Is_Active__c;
        customMetadata.values.add(isActive);

        Metadata.CustomMetadataValue query = new Metadata.CustomMetadataValue();
        query.field = 'Query__c';
        query.value = record.Query__c;
        customMetadata.values.add(query);

        Metadata.CustomMetadataValue queryString = new Metadata.CustomMetadataValue();
        queryString.field = 'Query_String__c';
        queryString.value = record.Query_String__c;
        customMetadata.values.add(queryString);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        MetadataCallback callback = new MetadataCallback();

        Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        System.debug('jobId: ' + jobId);

    }

    public static void saveDirectoryLaunchData(Directory_Launch_Data__mdt record){

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'Directory_Launch_Data__mdt.' + record.DeveloperName;
        customMetadata.label = record.MasterLabel;

        Metadata.CustomMetadataValue rType = new Metadata.CustomMetadataValue();
        rType.field = 'Record_Type__c';
        rType.value = record.Record_Type__c;
        customMetadata.values.add(rType);

        Metadata.CustomMetadataValue message = new Metadata.CustomMetadataValue();
        message.field = 'Message__c';
        message.value = record.Message__c;
        customMetadata.values.add(message);

        Metadata.CustomMetadataValue url = new Metadata.CustomMetadataValue();
        url.field = 'URL__c';
        url.value = record.URL__c;
        customMetadata.values.add(url);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        MetadataCallback callback = new MetadataCallback();

        Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        System.debug('jobId: ' + jobId);

    }


    public static void saveMaintenanceModeConfig(Maintenance_Mode_Config__mdt record){

        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'Maintenance_Mode_Config__mdt.' + record.DeveloperName;
        customMetadata.label = record.MasterLabel;

        Metadata.CustomMetadataValue isActive = new Metadata.CustomMetadataValue();
        isActive.field = 'Is_Active__c';
        isActive.value = record.Is_Active__c;
        customMetadata.values.add(isActive);

        Metadata.CustomMetadataValue message = new Metadata.CustomMetadataValue();
        message.field = 'Maintenance_Message__c';
        message.value = record.Maintenance_Message__c;
        customMetadata.values.add(message);

        Metadata.CustomMetadataValue pageName = new Metadata.CustomMetadataValue();
        pageName.field = 'Page_API_Name__c';
        pageName.value = record.Page_API_Name__c;
        customMetadata.values.add(pageName);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);

        MetadataCallback callback = new MetadataCallback();

        Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
        System.debug('jobId: ' + jobId);

    }



}
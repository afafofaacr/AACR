/**
 * Created by lauren.lezberg on 9/6/2019.
 */

public with sharing class AACRAdminController {


    //SERVICE NOW
    @AuraEnabled
    public static List<ServiceNow_Incident_Type__mdt> getIncidentTypes(){
        return AACRAdminUtils.getIncidentTypes();
    }

    @AuraEnabled
    public static void updateIncidentType(ServiceNow_Incident_Type__mdt record){
        AACRAdminUtils.updateIncidentType(record);
    }

    //GENERAL
    @AuraEnabled
    public static List<Maintenance_Mode_Config__mdt> getSiteConfigs(){
        return AACRAdminUtils.getSiteConfigs();
    }

    @AuraEnabled
    public static void saveSiteConfigs(Maintenance_Mode_Config__mdt record){
        AACRAdminUtils.saveMaintenanceModeConfig(record);
    }

    @AuraEnabled
    public static Member_Count__c getMemberCount(){
        return AACRAdminUtils.getMemberCount();
    }

    @AuraEnabled
    public static void saveMemberCount(Member_Count__c mc){
        AACRAdminUtils.saveMemberCount(mc);
    }

//    @AuraEnabled
//    public static AACRAdminUtils.CommunityLicenseSettings getCommunityLicenseSettings(){
//        return new AACRAdminUtils.CommunityLicenseSettings();
//    }
//
//    @AuraEnabled
//    public static void saveCommunityLicenseSettings(Community_License_Settings__c setting){
//        AACRAdminUtils.saveCommunityLicenseSettings(setting);
//    }

    //DIRECTORY
    @AuraEnabled
    public static DirectorySettingsData getDirectorySettingsData(){
        return new DirectorySettingsData();
    }

    @AuraEnabled
    public static void saveDirectoryCriteria(Directory_Criteria__mdt record){
        AACRAdminUtils.saveDirectoryCriteria(record);
    }

    @AuraEnabled
    public static void saveDirectoryLaunchData(Directory_Launch_Data__mdt record){
        AACRAdminUtils.saveDirectoryLaunchData(record);
    }

    public class DirectorySettingsData{
        @AuraEnabled
        public Directory_Criteria__mdt directoryCriteria;

        @AuraEnabled
        public List<Directory_Launch_Data__mdt> launchData;

        public DirectorySettingsData(){
            List<Directory_Criteria__mdt> dCriteria = AACRAdminUtils.getDirectoryCriteria();
            if(!dCriteria.isEmpty()) {
                this.directoryCriteria = dCriteria[0];
            } else {
                this.directoryCriteria = null;
            }
            this.launchData  = AACRAdminUtils.getDirectoryLaunchData();

        }
    }


    //RENEWALS
    @AuraEnabled
    public static RenewalData getRenewalData(){
        return new RenewalData();
    }

    @AuraEnabled
    public static void saveRenewalSettings(Renewal_Settings__c record){
        update record;
    }

//    @AuraEnabled
//    public static void saveDuesItem(DW_Manage_Dues_Item__c record){
//        update record;
//    }


    public class RenewalData{
//        @AuraEnabled
//        public List<DW_Manage_Dues_Item__c> duesItems;

        @AuraEnabled
        public Renewal_Settings__c renewalSettings;

        public RenewalData(){
            renewalSettings = AACRAdminUtils.getRenewalSettings();
//            duesItems = AACRAdminUtils.getDuesItems();

        }
    }
}
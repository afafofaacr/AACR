public with sharing class BrEventsWrapper {
    @AuraEnabled
    public BR_Event__c item;

    @AuraEnabled
    public String listImageURL;

    @AuraEnabled
    public String itemDates;

    @AuraEnabled
    public Integer attendeesCount;

    @AuraEnabled
    public String userImageUrl;

    @AuraEnabled
    public Boolean exhibitOpen;
}
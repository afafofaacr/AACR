public with sharing class BrEventsItemWrapper {
    @AuraEnabled
    public BR_Event__c item;

    @AuraEnabled
    public Venue__c venue;

    @AuraEnabled
    public String itemDate;

    @AuraEnabled
    public Boolean userIsParticipating = false;

    @AuraEnabled
    public Boolean refundRequested = false;

    @AuraEnabled
    public Boolean isZeroDollars = false;

    @AuraEnabled
    public Boolean exhibitOpen = false;
}
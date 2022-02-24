/**
 * Created by afaf.awad on 6/14/2021.
 */

public with sharing class ExportHelper_Opportunity {

    public static final List<String> opportunityHeaders = new List<String>{'Id',
                                                                            'Opportunity_Name',
                                                                            'Account_Id',
                                                                            'Account_Name',
                                                                            'Primary_Contact',
                                                                            'Amount',
                                                                            'Expected_Amount',
                                                                            'Requested_Amount',
                                                                            'Record_Type',
                                                                            'Type',
                                                                            'Pledge_Type',
                                                                            'Stage',
                                                                            'Ask_Date',
                                                                            'Close_Date',
                                                                            'Acknowledgment_Date',
                                                                            'Acknowledgment_Status',
                                                                            'Donation_Is_Recurring',
                                                                            'Donation_Recurring_Cancel_Date',
                                                                            'Donor_ContactId',
                                                                            'DonorDrive_ID',
                                                                            'Level',
                                                                            'Appeal_Code',
                                                                            'Distribution_Code',
                                                                            'Lead_Source',
                                                                            'InKind_Type',
                                                                            'Matching_Gift',
                                                                            'Matching_Gift_Account',
                                                                            'Matching_Gift_Employer',
                                                                            'Matching_Gift_Status',
                                                                            'Tribute_Type',
                                                                            'Probability'};

    public static OpportunityExport queryOpportunities(String dimTagId){
        
        List<Opportunity> Opportunities = [SELECT Account.Id, Account.Name, Account.ddrive__DonorDrive_ID__c, c4g_Appeal_Code__r.Name, GL_Account__r.Distribution_Code__c,
                GL_Account__r.Name, npsp__Primary_Contact__r.Name, RecordType.Name, Id, Amount, CloseDate, Description, LeadSource, Name, Probability,
                StageName, Type, c4g_Expected_Amount__c, c4g_Pledge_Type__c, ddrive__Donation_Is_Recurring__c, ddrive__Donation_Recurring_Cancel_Date__c,
                ddrive__Donor__c, ddrive__Level__c, npsp__Acknowledgment_Date__c, npsp__Acknowledgment_Status__c, npsp__Ask_Date__c, npsp__In_Kind_Type__c,
                npsp__Matching_Gift_Account__r.Name, npsp__Matching_Gift_Employer__c, npsp__Matching_Gift_Status__c, npsp__Matching_Gift__r.Name, npsp__Primary_Contact__c,
                npsp__Requested_Amount__c, npsp__Tribute_Type__c, ddrive__DonorDrive_ID__c
                FROM Opportunity WHERE Id IN (SELECT Object_Lookup__c
                                                FROM Opportunity_Dimension_Tag__c
                                                WHERE Dim_Tag_Id__c =: dimTagId)];

        System.debug('Opportunities == ' + Opportunities);

        List<OpportunityList> oppList = new List<OpportunityList>();
        for(Opportunity opp : Opportunities){
        OpportunityList ol = new OpportunityList();
            ol.Id = opp.Id;
            ol.Opportunity_Name = opp.Name;
            ol.Account_Id = opp.Account.Id;
            ol.Account_Name = opp.Account.Name;
            ol.Primary_Contact = opp.npsp__Primary_Contact__r.Name;
            ol.Amount = opp.Amount;
            ol.Expected_Amount = opp.c4g_Expected_Amount__c ;
            ol.Requested_Amount = opp.npsp__Requested_Amount__c;
            ol.Record_Type = opp.RecordType.Name;
            ol.Type = opp.Type;
            ol.Pledge_Type = opp.c4g_Pledge_Type__c;
            ol.Stage = opp.StageName;
            ol.Ask_Date = opp.npsp__Ask_Date__c;
            ol.Close_Date = opp.CloseDate;
            ol.Acknowledgment_Date = opp.npsp__Acknowledgment_Date__c;
            ol.Acknowledgment_Status = opp.npsp__Acknowledgment_Status__c;
            ol.Donation_Is_Recurring = opp.ddrive__Donation_Is_Recurring__c;
            ol.Donation_Recurring_Cancel_Date = opp.ddrive__Donation_Recurring_Cancel_Date__c == null ? null : Date.newInstance(opp.ddrive__Donation_Recurring_Cancel_Date__c.year(),opp.ddrive__Donation_Recurring_Cancel_Date__c.month(),opp.ddrive__Donation_Recurring_Cancel_Date__c.day());
            ol.Donor_ContactId = opp.ddrive__Donor__c;
            ol.DonorDrive_ID = opp.ddrive__DonorDrive_ID__c;
            ol.Level = opp.ddrive__Level__c;
            ol.Appeal_Code = opp.c4g_Appeal_Code__r.Name;
            ol.Distribution_Code = opp.GL_Account__r.Name;
            ol.Lead_Source = opp.LeadSource;
            ol.InKind_Type = opp.npsp__In_Kind_Type__c;
            ol.Matching_Gift = opp.npsp__Matching_Gift__r.Name;
            ol.Matching_Gift_Account = opp.npsp__Matching_Gift_Account__r.Name;
            ol.Matching_Gift_Employer = opp.npsp__Matching_Gift_Employer__c;
            ol.Matching_Gift_Status = opp.npsp__Matching_Gift_Status__c;
            ol.Tribute_Type = opp.npsp__Tribute_Type__c;
            ol.Probability = opp.Probability;

            oppList.add(ol);
        }

        System.debug('oppList == ' + oppList);
        return new OpportunityExport(oppList);
    }

    public class OpportunityExport{
        @AuraEnabled
        public List<Object> Opportunities;
        @AuraEnabled
        public List<String> headers;

        public OpportunityExport(List<OpportunityList> OpportunityLists){
            this.Opportunities = OpportunityLists;
            this.headers  = opportunityHeaders;
        }

    }

    public class OpportunityList{
        @AuraEnabled public String Id;
        @AuraEnabled public String Opportunity_Name;
        @AuraEnabled public String Account_Id;
        @AuraEnabled public String Account_Name;
        @AuraEnabled public String Primary_Contact;
        @AuraEnabled public Double Amount;
        @AuraEnabled public Double Expected_Amount;
        @AuraEnabled public Double Requested_Amount;
        @AuraEnabled public String Record_Type;
        @AuraEnabled public String Type;
        @AuraEnabled public String Pledge_Type;
        @AuraEnabled public String Stage;
        @AuraEnabled public Date Ask_Date;
        @AuraEnabled public Date Close_Date;
        @AuraEnabled public Date Acknowledgment_Date;
        @AuraEnabled public String Acknowledgment_Status;
        @AuraEnabled public Boolean Donation_Is_Recurring;
        @AuraEnabled public Date Donation_Recurring_Cancel_Date;
        @AuraEnabled public String Donor_ContactId;
        @AuraEnabled public String DonorDrive_ID;
        @AuraEnabled public String Level;
        @AuraEnabled public String Appeal_Code;
        @AuraEnabled public String Distribution_Code;
        @AuraEnabled public String Lead_Source;
        @AuraEnabled public String InKind_Type;
        @AuraEnabled public String Matching_Gift;
        @AuraEnabled public String Matching_Gift_Account;
        @AuraEnabled public String Matching_Gift_Employer;
        @AuraEnabled public String Matching_Gift_Status;
        @AuraEnabled public String Tribute_Type;
        @AuraEnabled public Double Probability;
    }

}
/**
 * Created by afaf.awad on 6/14/2021.
 */

public with sharing class ExportHelper_Account {

    public static final List<String> accountHeaders = new List<String>{'Id',
                                                                'Account_Name',
                                                                'Primary_Contact',
                                                                'Record_Type',
                                                                'Date_Entered',
                                                                'Industry',
                                                                'Institution_Type',
                                                                'Minority_Serving_Institution',
                                                                'MSI_type',
                                                                'Do_Not_Solicit',
                                                                'Employees',
                                                                'Annual_Revenue',
                                                                'Actively_Prospecting_Corporate_Gift',
                                                                'Funding_Cycle',
                                                                'Gifts_Received',
                                                                'Last_Gift_Amount',
                                                                'Last_Gift_Date',
                                                                'Total_Gifts',
                                                                'SIC_Code',
                                                                'SIC_Description'};


    
    public static AccountExport queryAccounts(String dimTagId){
        List<Account> accounts = [SELECT RecordType.Name, Id, AnnualRevenue, DonorApi__Do_Not_Solicit__c, DonorApi__Funding_Cycle__c, DonorApi__Gifts_Received__c,
                DonorApi__Last_Gift_Amount__c, DonorApi__Last_Gift_Date__c, Industry, Institution_Type__c, MSI_type__c, Minority_Institution__c, Name,
                NumberOfEmployees, OrderApi__Primary_Contact__c, Sic, SicDesc, cfg_Actively_Prospecting_Corporate_Gift__c, ddrive__Date_Entered__c,
                npo02__TotalOppAmount__c FROM Account WHERE Id IN (SELECT Object_Lookup__c
                                                                    FROM Account_Dimension_Tag__c
                                                                    WHERE Dim_Tag_Id__c =: dimTagId)];

        System.debug('accounts == ' + accounts);

        List<AccountList> accList = new List<AccountList>();
        for(Account acc : accounts){
            AccountList al = new AccountList();
            al.Id = acc.Id;
            al.Primary_Contact = acc.OrderApi__Primary_Contact__c;
            al.Record_Type = acc.RecordType.Name;
            al.Date_Entered = acc.ddrive__Date_Entered__c == null ? null : date.newinstance(acc.ddrive__Date_Entered__c.year(), acc.ddrive__Date_Entered__c.month(), acc.ddrive__Date_Entered__c.day());
            al.Industry = acc.Industry;
            al.Institution_Type = acc.Institution_Type__c;
            al.Minority_Serving_Institution = acc.Minority_Institution__c;
            al.MSI_type = acc.MSI_type__c;
            al.Do_Not_Solicit = acc.DonorApi__Do_Not_Solicit__c;
            al.Employees = acc.NumberOfEmployees;
            al.Annual_Revenue = acc.AnnualRevenue;
            al.Actively_Prospecting_Corporate_Gift = acc.cfg_Actively_Prospecting_Corporate_Gift__c;
            al.Funding_Cycle = acc.DonorApi__Funding_Cycle__c;
            al.Gifts_Received = acc.DonorApi__Gifts_Received__c;
            al.Last_Gift_Amount = acc.DonorApi__Last_Gift_Amount__c;
            al.Last_Gift_Date = acc.DonorApi__Last_Gift_Date__c;
            al.Total_Gifts = acc.npo02__TotalOppAmount__c;
            al.SIC_Code = acc.Sic;
            al.Account_Name = acc.Name;
            al.SIC_Description = acc.SicDesc;

            accList.add(al);
        }

        System.debug('accList == ' + accList);
        return new AccountExport(accList);
    }

    public class AccountExport{
        @AuraEnabled
        public List<Object> Accounts;
        @AuraEnabled
        public List<String> headers;

        public AccountExport(List<AccountList> accountLists){
            this.Accounts = accountLists;
            this.headers  = accountHeaders;
        }

    }

    public class AccountList{
        @AuraEnabled public String Id;
        @AuraEnabled public String Account_Name;
        @AuraEnabled public String Primary_Contact;
        @AuraEnabled public String Record_Type;
        @AuraEnabled public Date Date_Entered;
        @AuraEnabled public String Industry;
        @AuraEnabled public String Institution_Type;
        @AuraEnabled public Boolean Minority_Serving_Institution;
        @AuraEnabled public String MSI_type;
        @AuraEnabled public Boolean Do_Not_Solicit;
        @AuraEnabled public Integer Employees;
        @AuraEnabled public Double Annual_Revenue;
        @AuraEnabled public String Actively_Prospecting_Corporate_Gift;
        @AuraEnabled public String Funding_Cycle;
        @AuraEnabled public Double Gifts_Received;
        @AuraEnabled public Double Last_Gift_Amount;
        @AuraEnabled public Date Last_Gift_Date;
        @AuraEnabled public Double Total_Gifts;
        @AuraEnabled public String SIC_Code;
        @AuraEnabled public String SIC_Description;
    }

}
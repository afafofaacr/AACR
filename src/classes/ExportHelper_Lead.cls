/**
 * Created by afaf.awad on 9/9/2021.
 */

public with sharing class ExportHelper_Lead {

    public static final List<String> leadHeaders = new List<String>{'LeadId',
            'First_Name',
            'Last_Name',
            'Email',
            'Converted',
            'Lead_Source',
            'Full_Name',
            'Phone',
            'Status',
            'Title',
            'Company',
            'Converted_Account_ID',
            'Converted_Contact_ID',
            'Converted_Date',
            'Converted_Opportunity_ID',
            'Created_By_ID',
            'Created_Date'
    };



    public static LeadExport queryLeads(String dimTagId){
        List<Lead> leads = [SELECT Company, ConvertedAccountId, ConvertedContactId, ConvertedDate, ConvertedOpportunityId,
                CreatedById, CreatedDate, Email, FirstName, LastName, Id, IsConverted, LeadSource, Name, Phone, Status, Title
        FROM Lead WHERE Id IN (SELECT Object_Lookup__c
                                                    FROM Lead_Dimension_Tag__c
                                                    WHERE Dim_Tag_Id__c =: dimTagId)];

        System.debug('leads == ' + leads);

        List<LeadList> leadList = new List<LeadList>();
        for(Lead l : leads){
            LeadList ll = new LeadList();
            ll.LeadId = l.Id;
            ll.First_Name = l.FirstName;
            ll.Last_Name = l.LastName;
            ll.Email = l.Email;
            ll.Converted = l.IsConverted;
            ll.Lead_Source = l.LeadSource;
            ll.Full_Name = l.Name;
            ll.Phone = l.Phone;
            ll.Status = l.Status;
            ll.Title = l.Title;
            ll.Company = l.Company;
            ll.Converted_Account_ID = l.ConvertedAccountId;
            ll.Converted_Contact_ID = l.ConvertedContactId;
            ll.Converted_Opportunity_ID = l.ConvertedOpportunityId;
            ll.Converted_Date = l.ConvertedDate;
            ll.Created_By_ID = l.CreatedById;
            ll.Created_Date = Date.newInstance(l.CreatedDate.year(), l.CreatedDate.month(), l.CreatedDate.day());
            leadList.add(ll);
        }

        System.debug('leadList == ' + leadList);
        return new LeadExport(leadList);
    }

    public class LeadExport{
        @AuraEnabled
        public List<Object> Leads;
        @AuraEnabled
        public List<String> headers;

        public LeadExport(List<LeadList> leadLists){
            this.Leads = leadLists;
            this.headers  = leadHeaders;
        }

    }

    public class LeadList{
        @AuraEnabled public String LeadId;
        @AuraEnabled public String First_Name;
        @AuraEnabled public String Last_Name;
        @AuraEnabled public String Email;
        @AuraEnabled public Boolean Converted;
        @AuraEnabled public String Lead_Source;
        @AuraEnabled public String Full_Name;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Status;
        @AuraEnabled public String Title;
        @AuraEnabled public String Company;
        @AuraEnabled public String Converted_Account_ID;
        @AuraEnabled public String Converted_Contact_ID;
        @AuraEnabled public Date Converted_Date;
        @AuraEnabled public String Converted_Opportunity_ID;
        @AuraEnabled public String Created_By_ID;
        @AuraEnabled public Date Created_Date;
    }

}
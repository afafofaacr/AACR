/**
 * Created by afaf.awad on 6/15/2021.
 */

public with sharing class ExportHelper_Contact {

    public static final List<String> marketContactHeaders = new List<String>{
            'Id',
            'AACR_ID',
            'FirstName',
            'LastName',
            'Email'
    };


    public static final List<String> fullContactHeaders = new List<String>{ 'Id',
                                                                        'AACR_ID',
                                                                        'Salutation',
                                                                        'FirstName',
                                                                        'LastName',
                                                                        'AccountId',
                                                                        'Account_Name',
                                                                        'RecordType',
                                                                        'Title',
                                                                        'Email',
                                                                        'Do_Not_Email',
                                                                        'IsEmailBounced',
                                                                        'Race',
                                                                        'Gender',
                                                                        'Birthdate',
                                                                        'CreatedDate',
                                                                        'MailingStreet',
                                                                        'MailingCity',
                                                                        'MailingState',
                                                                        'MailingStateCode',
                                                                        'MailingPostalCode',
                                                                        'MailingCountry',
                                                                        'Bad_Mailing_Address',
                                                                        'Do_Not_Mail',
                                                                        'Member_Type',
                                                                        'Membership_Status',
                                                                        'Initial_Join_Date',
                                                                        'Paid_thru_date',
                                                                        'Primary_Research_Area_of_Expertise',
                                                                        'Major_Focus',
                                                                        'Specific_Research_Areas',
                                                                        'Organ_Sites',
                                                                        'Additional_Research_Areas',
                                                                        'World_Bank_Income_Level',
                                                                        'Foundation_Do_Not_Solicit',
                                                                        'Advocate',
                                                                        'Annual_Meeting',
                                                                        'Awards_Grants',
                                                                        'Cancer_Today_Magazine',
                                                                        'Conferences_Workshops',
                                                                        'AACR_Announcements',
                                                                        'AACR_Foundation',
                                                                        'Chemistry_in_Cancer_Research',
                                                                        'Stand_Up_2_Cancer',
                                                                        'Cancer_Immunology_Group',
                                                                        'Survivor_Advocacy',
                                                                        'Minorities_in_Cancer_Research',
                                                                        'Molecular_Epidemiology',
                                                                        'Tumor_Microenvironment',
                                                                        'Women_in_Cancer_Research',
                                                                        'SITA_Award',
                                                                        'WG_CIMM',
                                                                        'WG_CICR',
                                                                        'WG_MEG',
                                                                        'WG_MICR',
                                                                        'WG_PCWG',
                                                                        'WG_RSM',
                                                                        'WG_TME',
                                                                        'WG_WICR'
    };


    public static WorkingGroups getWorkingGroups(List<Id> contactIds){
        List<String> workingGroupTypes = new List<String>{'Cancer Immunology (CIMM)',
                'Chemistry in Cancer Research (CICR)',
                'Molecular Epidemiology (MEG)',
                'MICR - Minorities in Cancer Research',
                'Pediatric Cancer (PCWG)',
                'Radiation Science and Medicine (RSM)',
                'Tumor Microenvironment (TME)',
                'Scholar In Training Award',
                'WICR - Women in Cancer Research'};
        List<OrderApi__Badge__c> badges = [SELECT Id, OrderApi__Badge_Type__r.Name, OrderApi__Contact__c FROM OrderApi__Badge__c
                                            WHERE OrderApi__Is_Active__c = TRUE
                                            AND OrderApi__Contact__c IN: contactIds
                                            AND OrderApi__Badge_Type__r.Name IN:workingGroupTypes ];

        WorkingGroups workingGroups = new WorkingGroups();
        workingGroups.cimm = buildWGLists(badges, 'Cancer Immunology (CIMM)');
        workingGroups.cicr = buildWGLists(badges, 'Chemistry in Cancer Research (CICR)');
        workingGroups.meg = buildWGLists(badges, 'Molecular Epidemiology (MEG)');
        workingGroups.micr = buildWGLists(badges, 'MICR - Minorities in Cancer Research');
        workingGroups.pcwg = buildWGLists(badges, 'Pediatric Cancer (PCWG)');
        workingGroups.rsm = buildWGLists(badges, 'Radiation Science and Medicine (RSM)');
        workingGroups.tme = buildWGLists(badges, 'Tumor Microenvironment (TME)');
        workingGroups.sita = buildWGLists(badges, 'Scholar In Training Award');
        workingGroups.wicr = buildWGLists(badges, 'WICR - Women in Cancer Research');

        return WorkingGroups;

    }

    public static List<String> buildWGLists(List<OrderApi__Badge__c> badges, String badgeType){
        List<String> wgList = new List<String>();
        for(OrderApi__Badge__c b : badges){
            if(b.OrderApi__Badge_Type__r.Name == badgeType){
                wgList.add(b.OrderApi__Contact__c);
            }
        }
        return wgList;
    }

    public static ContactExport queryContacts_full(String dimTagId){

        List<Contact> Contacts = [SELECT Account.Id, Account.Name, RecordType.Name, Id, AACR_Announcements__c, AACR_Foundation__c, AACR_ID__c, Additional_Research_Areas__c,
                Advocate__c, Annual_Meeting__c, Awards_Grants__c, Bad_Mailing_Address__c, Bad_Other_Address__c, Birthdate, Cancer_Immunology_Group__c,
                Cancer_Today_Magazine__c, Chemistry_in_Cancer_Research__c, Conferences_Workshops__c, CreatedDate, Do_Not_Email__c, Do_Not_Mail__c, Email, FirstName,
                Foundation_Do_Not_Solicit__c, Gender__c, Initial_Join_Date__c, IsEmailBounced, LastName, MailingCity, MailingCountry, MailingPostalCode, MailingState,
                MailingStateCode, MailingStreet, Major_Focus__c, Member_Type__c, Membership_Status__c, Minorities_in_Cancer_Research__c, Molecular_Epidemiology__c,
                Name, Organ_Sites__c, OtherCity, OtherCountry, OtherPostalCode, OtherState, OtherStateCode, OtherStreet, Paid_thru_date__c,
                Primary_Research_Area_of_Expertise__c, Salutation, Specific_Research_Areas__c, Stand_Up_2_Cancer__c, Survivor_Advocacy__c,
                Title, Tumor_Microenvironment__c, Women_in_Cancer_Research__c, Race__c, Income_Level__c, IsDeleted
        FROM Contact WHERE Id IN (SELECT Object_Lookup__c
        FROM Contact_Dimension_Tag__c
        WHERE Dim_Tag_Id__c =: dimTagId)];

        List<Id> conIds = new List<Id>();
        for(Contact con: Contacts){
            conIds.add(con.Id);
        }

        WorkingGroups workingGroups = getWorkingGroups(conIds);

//        System.debug('Contacts == ' + Contacts);

        List<ContactList> conList = new List<ContactList>();
        for(Contact con : Contacts){
            ContactList cl = new ContactList();
            cl.AACR_Announcements = con.AACR_Announcements__c ;
            cl.AACR_Foundation =  con.AACR_Foundation__c;
            cl.AACR_ID = con.AACR_ID__c ;
            cl.AccountId = con.Account.Id ;
            cl.Account_Name = con.Account.Name ;
            cl.Additional_Research_Areas = con.Additional_Research_Areas__c ;
            cl.Advocate = con.Advocate__c ;
            cl.Annual_Meeting = con.Annual_Meeting__c ;
            cl.Awards_Grants = con.Awards_Grants__c ;
            cl.Birthdate = con.Birthdate ;
            cl.Cancer_Immunology_Group = con.Cancer_Immunology_Group__c ;
            cl.Cancer_Today_Magazine =  con.Cancer_Today_Magazine__c;
            cl.Chemistry_in_Cancer_Research = con.Chemistry_in_Cancer_Research__c ;
            cl.Conferences_Workshops = con.Conferences_Workshops__c ;
            cl.Do_Not_Email = con.Do_Not_Email__c ;
            cl.Do_Not_Mail = con.Do_Not_Mail__c ;
            cl.Email = con.Email ;
            cl.FirstName = con.FirstName ;
            cl.Foundation_Do_Not_Solicit = con.Foundation_Do_Not_Solicit__c ;
            cl.Gender = con.Gender__c ;
            cl.Race =  con.Race__c;
            cl.Id =  con.Id;
            cl.Initial_Join_Date = con.Initial_Join_Date__c ;
            cl.IsEmailBounced = con.IsEmailBounced ;
            cl.LastName =  con.LastName;
            cl.Bad_Mailing_Address = con.Bad_Mailing_Address__c ;
            cl.MailingStreet =  con.MailingStreet;
            cl.MailingCity = con.MailingCity ;
            cl.MailingState = con.MailingState ;
            cl.MailingStateCode = con.MailingStateCode ;
            cl.MailingPostalCode = con.MailingPostalCode ;
            cl.MailingCountry = con.MailingCountry ;
            cl.Major_Focus =  con.Major_Focus__c;
            cl.Membership_Status = con.Membership_Status__c ;
            cl.Member_Type = con.Member_Type__c ;
            cl.Minorities_in_Cancer_Research = con.Minorities_in_Cancer_Research__c  ;
            cl.CreatedDate = date.newInstance( con.CreatedDate.year(), con.CreatedDate.month(), con.CreatedDate.day()) ;
            cl.Molecular_Epidemiology = con.Molecular_Epidemiology__c ;
            cl.Name = con.Name ;
            cl.Organ_Sites = con.Organ_Sites__c ;
            cl.Paid_thru_date = con.Paid_thru_date__c ;
            cl.Primary_Research_Area_of_Expertise =  con.Primary_Research_Area_of_Expertise__c;
            cl.Salutation = con.Salutation ;
            cl.Specific_Research_Areas =  con.Specific_Research_Areas__c;
            cl.Stand_Up_2_Cancer = con.Stand_Up_2_Cancer__c ;
            cl.Survivor_Advocacy = con.Survivor_Advocacy__c ;
            cl.Title = con.Title ;
            cl.Tumor_Microenvironment = con.Tumor_Microenvironment__c ;
            cl.Women_in_Cancer_Research = con.Women_in_Cancer_Research__c ;
            cl.RecordType = con.RecordType.Name ;
            cl.World_Bank_Income_Level = con.Income_Level__c ;
            cl.SITA_Award = workingGroups.sita.contains(con.Id) ? true: false ;
            cl.WG_CIMM = workingGroups.cimm.contains(con.Id) ? true: false ;
            cl.WG_CICR = workingGroups.cicr.contains(con.Id) ? true: false ;
            cl.WG_MEG = workingGroups.meg.contains(con.Id) ? true: false ;
            cl.WG_MICR = workingGroups.micr.contains(con.Id) ? true: false ;
            cl.WG_PCWG = workingGroups.pcwg.contains(con.Id) ? true: false ;
            cl.WG_RSM = workingGroups.rsm.contains(con.Id) ? true: false ;
            cl.WG_TME = workingGroups.tme.contains(con.Id) ? true: false ;
            cl.WG_WICR = workingGroups.wicr.contains(con.Id) ? true: false ;

            conList.add(cl);
        }

        System.debug('conList == ' + conList);
        return new ContactExport(conList, 'full');
    }

    public static ContactExport queryContacts_market(String dimTagId){

        List<Contact> Contacts = [SELECT Id, AACR_ID__c, Email, FirstName,LastName
                                    FROM Contact
                                    WHERE Id IN (SELECT Object_Lookup__c
                                                    FROM Contact_Dimension_Tag__c
                                                    WHERE Dim_Tag_Id__c =: dimTagId)];

        System.debug('Contacts == ' + Contacts);

        List<ContactList> conList = new List<ContactList>();
        for(Contact con : Contacts){
            ContactList cl = new ContactList();
            cl.AACR_ID = con.AACR_ID__c ;
            cl.Email = con.Email ;
            cl.FirstName = con.FirstName ;
            cl.LastName =  con.LastName;
            cl.Id =  con.Id;
            conList.add(cl);
        }

        System.debug('conList == ' + conList);
        return new ContactExport(conList, 'market');
    }

    public class WorkingGroups{
        public List<String> cimm;
        public List<String> cicr;
        public List<String> meg;
        public List<String> micr;
        public List<String> pcwg;
        public List<String> rsm;
        public List<String> tme;
        public List<String> wicr;
        public List<String> sita;

    }

    public class ContactExport{
        @AuraEnabled
        public List<Object> Contacts;
        @AuraEnabled
        public List<String> headers;

        public ContactExport(List<ContactList> ContactLists, String exportType){
            this.Contacts = ContactLists;
            this.headers  = exportType == 'full' ? fullContactHeaders : marketContactHeaders ;
        }

    }

    public class ContactList{
        @AuraEnabled public String AACR_Announcements;
        @AuraEnabled public String AACR_Foundation;
        @AuraEnabled public String AACR_ID;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String Account_Name;
        @AuraEnabled public String Additional_Research_Areas;
        @AuraEnabled public Boolean Advocate;
        @AuraEnabled public String Annual_Meeting;
        @AuraEnabled public String Awards_Grants;
        @AuraEnabled public Date Birthdate;
        @AuraEnabled public String Cancer_Immunology_Group;
        @AuraEnabled public String Cancer_Today_Magazine;
        @AuraEnabled public String Chemistry_in_Cancer_Research;
        @AuraEnabled public String Conferences_Workshops;
        @AuraEnabled public Boolean Do_Not_Email;
        @AuraEnabled public Boolean Do_Not_Mail;
        @AuraEnabled public String Email;
        @AuraEnabled public String FirstName;
        @AuraEnabled public Boolean Foundation_Do_Not_Solicit;
        @AuraEnabled public String Gender;
        @AuraEnabled public String Race;
        @AuraEnabled public String Id;
        @AuraEnabled public Date Initial_Join_Date;
        @AuraEnabled public Boolean IsEmailBounced;
        @AuraEnabled public String LastName;
        @AuraEnabled public Boolean Bad_Mailing_Address;
        @AuraEnabled public String MailingStreet;
        @AuraEnabled public String MailingCity;
        @AuraEnabled public String MailingState;
        @AuraEnabled public String MailingStateCode;
        @AuraEnabled public String MailingPostalCode;
        @AuraEnabled public String MailingCountry;
        @AuraEnabled public String Major_Focus;
        @AuraEnabled public String Membership_Status;
        @AuraEnabled public String Member_Type;
        @AuraEnabled public String Minorities_in_Cancer_Research;
        @AuraEnabled public Date CreatedDate;
        @AuraEnabled public String Molecular_Epidemiology;
        @AuraEnabled public String Name;
        @AuraEnabled public String Organ_Sites;
        @AuraEnabled public Date Paid_thru_date;
        @AuraEnabled public String Primary_Research_Area_of_Expertise;
        @AuraEnabled public String Salutation;
        @AuraEnabled public String Specific_Research_Areas;
        @AuraEnabled public String Stand_Up_2_Cancer;
        @AuraEnabled public String Survivor_Advocacy;
        @AuraEnabled public String Title;
        @AuraEnabled public String Tumor_Microenvironment;
        @AuraEnabled public String Women_in_Cancer_Research;
        @AuraEnabled public String RecordType;
        @AuraEnabled public String World_Bank_Income_Level;
        @AuraEnabled public Boolean SITA_Award;
        @AuraEnabled public Boolean WG_CIMM;
        @AuraEnabled public Boolean WG_CICR;
        @AuraEnabled public Boolean WG_MEG;
        @AuraEnabled public Boolean WG_MICR;
        @AuraEnabled public Boolean WG_PCWG;
        @AuraEnabled public Boolean WG_RSM;
        @AuraEnabled public Boolean WG_TME;
        @AuraEnabled public Boolean WG_WICR;

    }


}
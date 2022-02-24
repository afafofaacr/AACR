/**
 * Created by afaf.awad on 9/7/2021.
 */
@RestResource(urlMapping='/Con_CSI/*')

global with sharing class CSI_Reg_Api {
    @Httpget
    global static CSIObject fetchContact() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String keyId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String contactId;

        System.debug('keyId = ' + keyId.substring(0, 3));

        If (keyId.substring(0, 3) == '005') {
            contactId = [SELECT ContactId FROM User WHERE Id = :keyId].ContactId;
        } else if (keyId.contains('@')) {
            contactId = [SELECT ContactId FROM User WHERE Email = :keyId].ContactId;
        } else {
            contactId = keyId;
        }

        CSIObject result = new CSIObject();

        try {
            Contact con = [
                    SELECT Id,
                            Salutation,
                            FirstName,
                            MiddleName,
                            LastName,
                            Suffix_Text__c,
                            Name,
                            Title,
                            Account.Name,
                            MailingStreet,
                            MailingCity,
                            MailingState,
                            MailingPostalCode,
                            MailingCountry,
                            Email,
                            OrderApi__Preferred_Phone__c,
                            Race__c,
                            Gender__c,
                            Birthdate,
                            Highest_Degree__c,
                            Primary_Research_Area_of_Expertise__c,
                            Additional_Research_Areas__c,
                            Major_Focus__c,
                            AACR_ID__c,
                            Organ_Sites__c,
                            Member_Type__c,
                            RecordType.Name,
                            Account.Institution_Type__c,
                            Advocate__c,
                            Pre_Post_Doc__c,
                            Income_Level__c,
                            Event_Segment__c,
                            Department,
                            Current_Education_Status__c

                    FROM Contact
                    WHERE AACR_ID__c = :contactId OR Id = :contactId
            ];

            List<Degree_Translation__mdt> degreeTranslations = [SELECT Id, Label, CSI_Degree__c FROM Degree_Translation__mdt];

            Map<String,String> degreeMap = new Map<String,String>();
            for(Degree_Translation__mdt dt : degreeTranslations){
                degreeMap.put(dt.Label,dt.CSI_Degree__c);
            }

            result.Name = con.Name;
            result.ContactId = con.Id;
            result.Salutation = con.Salutation;
            result.First_Name = con.FirstName;
            result.Middle_Name = con.MiddleName;
            result.Last_Name = con.LastName;
            result.Suffix = con.Suffix_Text__c;
            result.Title = con.Title;
            result.Account_Name = (con.Account.Name.contains('Household') || con.Account.Name.contains('(Individual)')) ? null : con.Account.Name;
            result.Address = con.MailingStreet;
            result.City = con.MailingCity;
            result.State = con.MailingState;
            result.Zip = con.MailingPostalCode;
            result.Country = con.MailingCountry;
            result.Email = con.Email;
            result.Phone = con.OrderApi__Preferred_Phone__c;
            result.Race = con.Race__c;
            result.Gender = con.Gender__c;
            result.Birthdate = con.Birthdate;
            result.Primary_Research_Area_of_Expertise = con.Primary_Research_Area_of_Expertise__c + ';'+ con.Additional_Research_Areas__c;
            result.Major_Focus = con.Major_Focus__c;
            result.AACR_ID = con.AACR_ID__c;
            result.Organ_Sites = con.Organ_Sites__c;
            result.Segment = con.Event_Segment__c.replace('-', '_');
            result.Dues_Alert = con.RecordType.Name=='Prior Member'?true:false;
            result.Highest_Degree = degreeMap.get(con.Highest_Degree__c);
            result.Institution_Type = con.Account.Institution_Type__c;
            result.Department = con.Department;
            result.Current_Education_Status = con.Current_Education_Status__c == 'N/A' ? null : con.Current_Education_Status__c;

        } catch (DmlException e) {
            System.debug('Id ' + contactId + ' returned no result');
        }

        return result;
    }

    global class CSIObject {

        public String Name;
        public String ContactId;
        public String Salutation;
        public String First_Name;
        public String Middle_Name;
        public String Last_Name;
        public String Suffix;
        public String Title;
        public String Account_Name;
        public String Address;
        public String City;
        public String State;
        public String Zip;
        public String Country;
        public String Email;
        public String Phone;
        public String Race;
        public String Gender;
        public Date Birthdate;
        public String Primary_Research_Area_of_Expertise;
        public String Major_Focus;
        public String AACR_ID;
        public String Organ_Sites;
        public String Segment;
        public Boolean Dues_Alert;
        public String Highest_Degree;
        public String Institution_Type;
        public String Department;
        public String Current_Education_Status;

    }

}
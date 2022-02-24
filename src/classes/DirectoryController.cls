/**
 * Created by lauren.lezberg on 5/20/2019.
 */

public with sharing class DirectoryController {

    public Boolean suspended {get;set;}
    public Boolean lapsed {get;set;}
    public Boolean error{get;set;}
    public Boolean nonMember {get;set;}
    public Boolean member{get;set;}
    public Boolean showDirectory {get;set;}

    public Boolean priorMember {get;set;}


    public void checkDirectoryAccess(){
        System.debug('checking directory access');
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        System.debug('currentContact: ' + currentContact);
        priorMember = false;
        nonMember = false;
        showDirectory = false;
        member = false;

        if(currentContact.RecordType.Name == 'Prior Member'){
            if(currentContact.Membership_Status__c == '1-YR Suspended' || currentContact.Membership_Status__c == '2-YR Suspended' || currentContact.Membership_Status__c=='Suspended'){
                suspended = true;
            } else {
                lapsed = true;
            }
            priorMember = true;
        } else if(currentContact.RecordType.Name == 'Nonmember'){
            nonMember = true;
        }  else {
            error = true;
        }
        //Id currentContactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        OrderApi__Badge__c directoryBadge = BadgeUtils.getDirectoryBadge(currentContact.Id);
        if(directoryBadge!=null){
            System.debug('directory badge found: ' + directoryBadge);
            if(directoryBadge.OrderApi__Is_Active__c){
                showDirectory = true;
            }
        }
    }

    @AuraEnabled
    public static DirectoryLaunchData getDirectoryLaunchData(){
        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        DirectoryLaunchData dld = new DirectoryLaunchData();

        String recordType = currentContact.RecordType.Name;

        if(recordType == 'Member'){
            dld.showLaunchButton = true;
        } else {
            dld.showLaunchButton = false;
        }

        List<Directory_Launch_Data__mdt> data = [SELECT Id, URL__c, Message__c FROM Directory_Launch_Data__mdt WHERE Record_Type__c =: recordType LIMIT 1];
        if(data.size()==1){
            dld.description = data[0].Message__c;
            if(data[0].URL__c!=null) {
                dld.url = data[0].URL__c;
            } else {
                dld.url = null;
            }
        }

//        dld.description = Directory_Launch_Data__c.getInstance().Description__c;
//        dld.url = Directory_Launch_Data__c.getInstance().Directory_URL__c;
        return dld;
    }


    @AuraEnabled
    public static DirectoryFilters getFilterCriteria() {
        DirectoryFilters filters = new DirectoryFilters();
        filters.states = ECRMUtils.getStatePicklistValues();
        //TODO: Get city options
//        filters.cities = ECRMUtils.getStatePicklistValues();
        filters.countries = ECRMUtils.getCountryPicklistValues();
        filters.primaryFocus = ECRMUtils.getPicklistValues('Contact', 'Primary_Research_Area_of_Expertise__c');

        return filters;
    }

    @AuraEnabled
    public static Boolean sendEmailToMember(String emailAddr, String subject, String body) {
        EmailTemplate et = [Select Id, HtmlValue, Body, Subject from EmailTemplate where Name = 'AACR_Dir_EmailMe'];
        System.debug('sending email to member: ' + subject + ' and body: ' + body);

        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        if (contactId != null) {
            List<String> to = new List<String>();
            to.add(emailAddr);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // add to html body template
            String htmlBody = et.HtmlValue;
            htmlBody = htmlBody.replace('{{message_body}}', '<br/>' + body);


            String plainBody = et.Body;
            plainBody = plainBody.replace('{{message_body}}', '<br/>' +  body);

            String concatSubject = et.Subject;
            concatSubject += ' - ' + subject;

            mail.setHtmlBody(htmlBody);
            mail.setPlainTextBody(plainBody);
            mail.setTemplateId(et.Id);
            mail.setToAddresses(to);
            mail.setTargetObjectId(contactId);
            mail.setSaveAsActivity(false);
//            mail.setHtmlBody(body);
            mail.setSubject(concatSubject);
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
                return true;

            } catch (Exception e) {
                System.debug('Exception occurred sending email: ' + e.getMessage());
                return false;
            }
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static String getContactWorkingGroups(Id contactId){
        String toReturn = '';
        List<OrderApi__Subscription__c> wgs = [SELECT OrderApi__Item__r.Name FROM OrderApi__Subscription__c WHERE OrderApi__Item_Class__r.Name = 'Working Groups' AND OrderApi__Is_Active__c = true AND OrderApi__Contact__c=: contactId ORDER BY OrderApi__Paid_Through_Date__c];
        if(wgs.size()>0){
            for(OrderApi__Subscription__c wg : wgs){
                toReturn += wg.OrderApi__Item__r.Name + ';';
            }
        }
        return toReturn;
    }

    @AuraEnabled
    public static DirectoryPagerWrapper fetchContacts(Decimal pageNumber, Integer recordsToDisplay, List<String> focusFilters, List<String> countryFilters, List<String> stateFilters, String nameFilter, String accountFilter, String orderBy, String order) {
        Integer pageSize = recordsToDisplay;
        Integer offset = ((Integer) pageNumber - 1) * pageSize;

        // create a instance of wrapper class.
        DirectoryPagerWrapper obj = new DirectoryPagerWrapper();
        // set the pageSize,Page(Number), total records and accounts List(using OFFSET)
        obj.pageSize = pageSize;


        Directory_Criteria__mdt dirCriteria = [SELECT Query__c, Query_String__c, Show_Filters__c FROM Directory_Criteria__mdt WHERE Is_Active__c = true];
        String countQueryString = 'SELECT COUNT() FROM Contact WHERE ' + dirCriteria.Query__c;
        String queryString = 'SELECT Id, Specific_Research_Areas__c, Additional_Research_Areas__c, Account.Institution_Type__c, Working_Groups__c, Name, Omit_Household_Label__c, MailingCity, MailingState, MailingCountry, Primary_Research_Area_of_Expertise__c, Major_Focus__c, Organ_Sites__c,OrderApi__Preferred_Email__c, Email FROM Contact WHERE ' + dirCriteria.Query__c;

        if (!focusFilters.isEmpty() ) {
            if(focusFilters.size()>1){
                queryString += ' AND (Primary_Research_Area_of_Expertise__c = \'' + focusFilters[0] + '\'';
                countQueryString += ' AND (Primary_Research_Area_of_Expertise__c = \'' + focusFilters[0] + '\'';

                for(Integer i=1; i<focusFilters.size();i++){
                    queryString += ' OR Primary_Research_Area_of_Expertise__c = \'' + focusFilters[i] + '\'';
                    countQueryString += ' OR Primary_Research_Area_of_Expertise__c = \'' + focusFilters[i] + '\'';

                    if(i==focusFilters.size()-1){
                        queryString += ')';
                        countQueryString += ')';
                    }

                }
            } else {
                queryString += ' AND Primary_Research_Area_of_Expertise__c = \'' + focusFilters[0] + '\'';
                countQueryString += ' AND Primary_Research_Area_of_Expertise__c = \'' + focusFilters[0] + '\'';
            }

        }

        if (!countryFilters.isEmpty()) {
            if(countryFilters.size()>1){
                queryString += ' AND (MailingCountry = \'' + countryFilters[0] + '\'';
                countQueryString += ' AND (MailingCountry = \'' + countryFilters[0] + '\'';

                for(Integer i=1; i<countryFilters.size();i++){
                    queryString += ' OR MailingCountry = \'' + countryFilters[i] + '\'';
                    countQueryString += ' OR MailingCountry = \'' + countryFilters[i] + '\'';

                    if(i==countryFilters.size()-1){
                        queryString += ')';
                        countQueryString += ')';
                    }

                }
            } else {
                queryString += ' AND MailingCountry = \'' + countryFilters[0] + '\'';
                countQueryString += ' AND MailingCountry = \'' + countryFilters[0] + '\'';
            }
        }

        if (!stateFilters.isEmpty()) {
            if(stateFilters.size()>1){
                queryString += ' AND (MailingState = \'' + stateFilters[0] + '\'';
                countQueryString += ' AND (MailingState = \'' + stateFilters[0] + '\'';

                for(Integer i=1; i<stateFilters.size();i++){
                    queryString += ' OR MailingState = \'' + stateFilters[i] + '\'';
                    countQueryString += ' OR MailingState = \'' + stateFilters[i] + '\'';

                    if(i==stateFilters.size()-1){
                        queryString += ')';
                        countQueryString += ')';
                    }
                }
            } else {
                queryString += ' AND MailingState = \'' + stateFilters[0] + '\'';
                countQueryString += ' AND MailingState = \'' + stateFilters[0] + '\'';
            }
        }

        if (nameFilter != null) {
            queryString += ' AND Name LIKE \'%' + nameFilter + '%\'';
            countQueryString += ' AND Name LIKE \'%' + nameFilter + '%\'';
        }

        if (accountFilter != null) {
            queryString += ' AND AccountId = \'' + accountFilter + '\'';
            countQueryString += ' AND AccountId = \'' + accountFilter + '\'';
        }

        if (orderBy != null) {
            queryString += ' ORDER BY ' + orderBy;
        } else {
            queryString += ' ORDER BY Name';
        }

        if (order != null) {
            queryString += ' ' + order;
        } else {
            queryString += ' ASC';
        }
        queryString += ' NULLS LAST';

        queryString += ' LIMIT ' + recordsToDisplay + ' OFFSET ' + offset;
        System.debug('queryString: ' + queryString);

        obj.contacts = Database.query(queryString);
        obj.total = Database.countQuery(countQueryString);
        obj.showFilters = dirCriteria.Show_Filters__c;
        obj.page = obj.total!=0?(Integer) pageNumber : 0;

        return obj;
    }

    public class DirectoryFilters {
        @AuraEnabled public Map<string, string> countries { get; set; }
        @AuraEnabled public Map<string, string> states { get; set; }
        @AuraEnabled public Map<string, string> cities { get; set; }
        @AuraEnabled public List<String> primaryFocus { get; set; }
    }


    public class DirectoryPagerWrapper {
        @AuraEnabled public Integer pageSize { get; set; }

        @AuraEnabled public Integer page { get; set; }

        @AuraEnabled
        public Integer total { get; set; }

        @AuraEnabled
        public List<Contact> contacts { get; set; }

        @AuraEnabled
        public Boolean showFilters {get;set;}
    }

    public class DirectoryLaunchData {
        @AuraEnabled
        public String description;

        @AuraEnabled
        public String url;

        @AuraEnabled
        public Boolean showLaunchButton;

    }

}
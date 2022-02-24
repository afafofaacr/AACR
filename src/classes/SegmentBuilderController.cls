/**
 * Created by lauren.lezberg on 4/7/2020.
 */

public with sharing class SegmentBuilderController {

    /**
     * @purpose create user segment query from contact and account fields
     * @param conJSON
     * @param accJSON
     *
     * @return User segment query string
     */
    @AuraEnabled
    public static String getQueryString(String conJSON, String accJSON){
        return UserSegmentHelper.buildSegmentQueryString(conJSON, accJSON);
    }

    /**
     * @purpose Retrieve first 200 records as 'preview' in user segment
     * @param conJSON
     * @param accJSON
     *
     * @return First 200 contacts in preview
     */
    @AuraEnabled
    public static List<Contact> getQueryResults(String conJSON, String accJSON){
        System.debug('getQueryResults...');
        System.debug('conJSON: ' + conJSON + ' and accJSON: ' + accJSON);
        String queryString = UserSegmentHelper.buildSegmentQueryString(conJSON, accJSON);
        queryString += ' LIMIT 200';
        List<User> users = Database.query(queryString);
        Set<Id> userIds = new Set<Id>();
        for(User u : users){
            userIds.add(u.Id);
        }

        List<Contact> contacts = [SELECT Name, AACR_ID__c, Member_Type__c, RT_ByName__c, Income_Level__c FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id IN: userIds)];

        return contacts;
    }


}
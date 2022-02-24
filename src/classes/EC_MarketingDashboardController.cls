/**
 * Created by afaf.awad on 3/1/2021.
 */

public without sharing class EC_MarketingDashboardController {


    @AuraEnabled
    public static List<Integer> getAvailableYears(){
        List<Integer> years = new List<Integer>();
        list<Schema.AggregateResult> results = [SELECT COUNT(Id), Calendar_Year(Delivery_Date__c) sendYear
        FROM Time_Slot__c
        WHERE Blocked__c = false
        GROUP BY Calendar_Year(Delivery_Date__c)
        ORDER BY Calendar_Year(Delivery_Date__c) ASC];
        if(!results.isEmpty()) {
            for (AggregateResult r : results) {
                years.add((Integer) r.get('sendYear'));
            }
        } else {
            years.add(System.now().year());
        }

        return years;
    }


    /**
     * @purpose Retrieve all published and non-cancelled events for a specified month
     *
     * @param month
     *
     * @return
     */
    @AuraEnabled
    public static List<Time_Slot__c> getEventsPerMonth(String month, Integer year) {
        Date monthStart = Date.newInstance(year, Integer.valueOf(month), 1);
        Date nextMonthStart = Date.newInstance(year, Integer.valueOf(month) + 1, 1);
        List<Time_Slot__c> timeSlots = [SELECT Id, Start_Time__c, End_Time__c, Delivery_Date__c, EC_Order__c, EC_Order__r.Name,
                                                EC_Order__r.Company__r.Name, EC_Order__r.Company__c,
                                                Status__c, EC_Order__r.Amount_Targeted__c
                                        FROM Time_Slot__c WHERE  Delivery_Date__c >= :monthStart
                                                            AND Delivery_Date__c < :nextMonthStart
                                                            AND Blocked__c = false
                                        ORDER BY Delivery_Date__c, Start_Time__c ASC];

        return timeSlots;
    }


}
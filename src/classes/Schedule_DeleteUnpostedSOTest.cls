/**
 * Created by lauren.lezberg on 11/29/2018.
 */
@isTest
public with sharing class Schedule_DeleteUnpostedSOTest {

    @isTest static void testSchedule_DeleteUnpostedSOCancelled(){

        Schedule_DeleteUnpostedSO controller =  new Schedule_DeleteUnpostedSO();


        TestDataFactory dataFactory = new TestDataFactory();
        List<OrderApi__Sales_Order__c> lstSO = dataFactory.createCancelledUnpostedSalesOrders(100);

        //set half creation dates to 90 days ago
        for(OrderApi__Sales_Order__c s: lstSO){
            Test.setCreatedDate(s.Id, Date.today().addDays(-91));
        }

        Test.startTest();
        String chron = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('Test Schedule_DeleteUnpostedSO', chron , controller );

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        controller.execute(null);

        System.assertEquals(chron, ct.CronExpression);

        Test.stopTest();

    }

}
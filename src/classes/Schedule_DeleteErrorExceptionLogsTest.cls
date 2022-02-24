/**
 * Created by lauren.lezberg on 7/1/2020.
 */
@isTest
private with sharing class Schedule_DeleteErrorExceptionLogsTest {

    @isTest
    public static void test_scheduleDeleteLogs(){
        String chron = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('Test Schedule_DeleteErrorExceptionLogs', chron , new Schedule_DeleteErrorExceptionLogs() );

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(chron, ct.CronExpression);
    }

}
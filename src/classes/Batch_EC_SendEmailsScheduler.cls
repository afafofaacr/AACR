/**
 * Created by afaf.awad on 3/4/2021.
 */

global class Batch_EC_SendEmailsScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {

        Time timeNow = Time.newInstance(System.now().hour(),0,0,0);
        Time time2hr = Time.newInstance(System.now().hour() + 2,0,0,0);
        Date todayDate = Date.today();

        if(Test.isRunningTest()) {
        timeNow = Time.newInstance(06,0,0,0);
        time2hr = Time.newInstance(08,0,0,0);
        }


        System.debug('timeNow == ' + timeNow);
        System.debug('time2hr == ' + time2hr);
        System.debug('todaydate == ' + todayDate);

        List<Time_Slot__c> timeSlots = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                                            EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                                            Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                                            EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Name, EC_Order__r.Order_Name__c
                                FROM Time_Slot__c
                                WHERE Delivery_Date__c = :todayDate
                                AND (Start_Time__c = :timeNow OR Start_Time__c = :time2hr)
                                AND Blocked__c = false
                                AND Status__c IN ('Scheduled', 'Over Budget')];

        System.debug('TimeSlots == ' + timeSlots);
        If(!timeSlots.isEmpty()) {
            for(Time_Slot__c ts : timeSlots) {
                If ( ts.Start_Time__c == timeNow ) {
                    If(ts.Status__c == 'Over Budget'){
                       EC_Helper.sendCancelEmail(ts);
                    }else if(String.isBlank(ts.EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c)){
                        System.debug('error applying offer.');
                        new AACRCustomException(ts.EC_Order__c, 'Verified Domain is Blank. Cannot send exhibitor emails.', 'Batch_EC_SendEmailsScheduler.execute()', 'Exhibitor Connect');
                    }else{
                        batchSendEmails(ts);
                    }
                }
                If(ts.Start_Time__c == time2hr){
                    checkBudget(ts);
                }
            }
        }

    }

    public static void batchSendEmails(Time_Slot__c ts){
        List<BR_Participation__c> parts = EC_Helper.queryTargetAudience(ts.EC_Order__c, ts.EC_Schedule__r.Event__c);

        System.debug('audienceSize == ' + parts[0].Id);
        if ( !parts.isEmpty() ) {
            List<Id> partIds = new List<Id>();
            for (BR_Participation__c p : parts) {
                partIds.add(p.Id);
            }

            Database.executeBatch(new Batch_EC_SendEmails(partIds, EC_Helper.getEmailRecord(ts.EC_Email__c), EC_Helper.buildEmailTemplate(ts.EC_Email__c), ts));
        }
    }


    public static void checkBudget(Time_Slot__c ts) {
        System.debug('checking budget....');

        Decimal maxBudget = ts.EC_Email__r.Exhibitor_Setting__r.Max_Budget__c;

        if ( maxBudget > 0 ) {
            List<BR_Participation__c> parts = EC_Helper.queryTargetAudience(ts.EC_Order__c, ts.EC_Schedule__r.Event__c);
            OrderApi__Item__c ecItem = [Select Id, Name, OrderApi__Price__c from OrderApi__Item__c WHERE Name = 'Exhibitor Request'];

            System.debug('audienceSize == ' + parts.size());
            if(ecItem.OrderApi__Price__c * parts.size() > maxBudget) {
                System.debug('Sending Email...');
                EC_Helper.sendOverBudgetEmail(ts, ecItem.OrderApi__Price__c * parts.size(), parts.size());

            }
        }
    }
}
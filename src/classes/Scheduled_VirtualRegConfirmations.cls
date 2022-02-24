/**
 * Created by lauren.lezberg on 5/21/2020.
 */

global class Scheduled_VirtualRegConfirmations implements Schedulable{

    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    global void execute(SchedulableContext sc){


        List<Virtual_Meeting_Links__mdt> vmls = new List<Virtual_Meeting_Links__mdt>();
        if(!Test.isRunningTest()) {
            vmls = [SELECT Event_Id__c, Email_Template_Id__c FROM Virtual_Meeting_Links__mdt WHERE Registration_Open__c = true AND DeveloperName = 'Virtual_AM_2'];
        } else {
            vmls = virtualMeetings;
        }

        if(!vmls.isEmpty()) {

            if(vmls[0].Email_Template_Id__c!=null) {
                EmailTemplate et = [SELECT Id, Description FROM EmailTemplate WHERE Id = :vmls[0].Email_Template_Id__c];

                //execute batch job
                database.executeBatch(new Batch_SendRegConfirmationEmails(vmls[0].Event_Id__c, 'Mass Email: ' + et.Description, et.Id));
            } else {
                System.debug('email template is null');
            }

        }

    }

}
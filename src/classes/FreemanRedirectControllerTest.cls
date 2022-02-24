/**
 * Created by lauren.lezberg on 4/25/2020.
 */
@isTest
public with sharing class FreemanRedirectControllerTest {

    @isTest(seeAllData=true)
    public static void test_getFreemanURL(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Title = 'Senior Scientist';
        con.Salutation = 'Mr';
        insert con;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '08:00 AM';
        testEvt.EventApi__End_Time__c = '08:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;




        User u = TestDataFactory.buildUser(con.Id);

        String freemanEventId = 'FREEMAN123456';
        Pagereference currentPage = Page.FreemanRedirect;
        Test.setCurrentPage(currentPage);
        currentPage.getParameters().put('id', freemanEventId);

        FreemanRedirectController.RedirectInfo ri = FreemanRedirectController.getFreemanURL(freemanEventId);

        System.runAs(u) {
            Test.startTest();

            //failure
            Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
            vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.DeveloperName = 'Virtual_Test_Event';
            vml.Event_Id__c = testEvt.Id;
            vml.View_Link__c = 'https://www.google.com';
            vml.Event_IsActive__c = false;
            vml.Computer_Check_Link__c = 'https://www.salesforce.com';
            vml.Check_IsActive__c = true;
            vml.Registration_Open__c = true;
            vml.Freeman_Event_Id__c = freemanEventId;
            vml.Exhibit_Open__c = false;

            FreemanRedirectController.virtualMeetings.add(vml);


            ri = FreemanRedirectController.getFreemanURL(freemanEventId);

            EventApi__Attendee__c att = new EventApi__Attendee__c();
            att.EventApi__Contact__c = con.Id;
            att.EventApi__Event__c = testEvt.Id;
            insert att;


            ri = FreemanRedirectController.getFreemanURL(freemanEventId);

            vml.Exhibit_Open__c = true;


            ri = FreemanRedirectController.getFreemanURL(freemanEventId);

            Test.stopTest();
        }
    }

}
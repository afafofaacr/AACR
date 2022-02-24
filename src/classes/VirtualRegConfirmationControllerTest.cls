/**
 * Created by lauren.lezberg on 5/22/2020.
 */
@isTest
private with sharing class VirtualRegConfirmationControllerTest {

    @testsetup
    public static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Calendar_Invite_Msg__c = 'TEST';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Date_Time__c = System.now();
        testEvt.EventApi__End_Date_Time__c = SYstem.now().addDays(2);
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;
    }


    @isTest
    public static void test_constructor(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name ='Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Pagereference currentPage = Page.VirtualRegisterConfirmation;
        Test.setCurrentPage(currentPage);


        System.runAs(u) {
            Test.startTest();
            currentPage.getParameters().put('id', evt.Id);

            Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
            vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.DeveloperName = 'Virtual_Test_Event';
            vml.Event_Id__c = evt.Id;
            vml.View_Link__c = 'https://www.google.com';
            vml.Event_IsActive__c = true;
            vml.Computer_Check_Link__c = 'https://www.salesforce.com';
            vml.Check_IsActive__c = true;
            vml.Confirmation_Text__c = 'CONFIRM';
            vml.Exhibit_Open__c = false;
            vml.Registration_Open__c = true;

            VirtualRegisterConfirmationController.virtualMeetings.add(vml);

            VirtualRegisterConfirmationController ctrl = new VirtualRegisterConfirmationController();

            PageReference pageRef = ctrl.checkIsActive();

            System.assertEquals(null, PageRef);

            vml.Exhibit_Open__c = true;

            pageRef = ctrl.checkIsActive();

            System.assertNotEquals(null, PageRef);

            Test.stopTest();
        }
    }
}
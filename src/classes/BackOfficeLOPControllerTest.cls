/**
 * Created by afaf.awad on 10/15/2020.
 */

@IsTest
private class BackOfficeLOPControllerTest {

    @testSetup
    public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Zono';
        insert con;

//      ***LIVE EVENT OBJECTS***
        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;

        BR_Participation__c part = new BR_Participation__c(BR_Event__c = event.Id,Contact__c = con.Id);
        insert part;

        BR_Participation__c partNull = new BR_Participation__c(BR_Event__c = event.Id);
        insert partNull;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);
        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

//        ***FONTEVA EVENT OBJECTS***

        EventApi__Event__c fonEvent = TestDataFactory.buildEvent();
        insert fonEvent;

        EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Contact__c=con.Id, EventApi__Event__c=fonEvent.Id);
        insert att;

    }

    @IsTest
    static void test_getLOP() {
        String participant = [SELECT Id FROM BR_Participation__c LIMIT 1].Id;
        Test.startTest();
        Boolean disabled = BackOfficeLOPController.getLOP(participant);

        BR_Event__c event = [SELECT End_Date__c FROM BR_Event__c LIMIT 1];
        event.Start_Date__c = System.now() -2;
        event.End_Date__c = System.now()-1;
        update event;

        Boolean enable = BackOfficeLOPController.getLOP(participant);
        Test.stopTest();
        System.assertEquals(true,enable);
        System.assertEquals(false,disabled);


    }

    @IsTest
    static void test_getDomain(){
        Test.startTest();
        String domain = BackOfficeLOPController.getDomain();
        Test.stopTest();
        System.assertEquals('Test domain', domain);
    }


    @IsTest
    static void test_sendPDF() {
        List<BR_Participation__c> participant = [SELECT Id, Contact__c FROM BR_Participation__c];

        String body = 'Testing Email Messaging with merge fields : {!BR_Event__c} and {!First_Name}';

//        EmailTemplate e = new EmailTemplate (developerName = 'Test_Email'
//                                            , FolderId = userInfo.getUserId()
//                                            , TemplateType= 'Text'
//                                            , Name = 'Letter of Participation'
//                                            , HtmlValue = body);
//
//        insert e;

        Test.startTest();
        BackOfficeLOPController.EmailResults withContact;

        for(BR_Participation__c p : participant) {
            if(p.Contact__c != null) {
               withContact = BackOfficeLOPController.sendPDF(p.Id);
            }else {
                BackOfficeLOPController.sendPDF(p.Id);
            }
        }
        System.assertEquals('Letter emailed!',withContact.message);
        Test.stopTest();
    }


    @IsTest
    static void test_sendPDF_Fon() {
        List<EventApi__Attendee__c> att = [SELECT Id, EventApi__Contact__c FROM EventApi__Attendee__c];

        String body = 'Testing Email Messaging with merge fields : {!BR_Event__c} and {!First_Name}';

        Test.startTest();
        BackOfficeLOPController.EmailResults results;

        for(EventApi__Attendee__c a : att) {
                results = BackOfficeLOPController.sendPDF_Fon(a.Id);
        }
        System.assertEquals('Letter emailed!',results.message);
        Test.stopTest();
    }
}
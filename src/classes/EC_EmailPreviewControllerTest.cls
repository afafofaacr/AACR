/**
 * Created by afaf.awad on 3/24/2021.
 */
@IsTest
public with sharing class EC_EmailPreviewControllerTest {

    @TestSetup public static void setup(){
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        EC_Exhibitor_Setting__c ecSetting = ExhibitorTestDataFactory.buildExhibitorSetting(account.Id);
        insert ecSetting;

        EC_Order__c order = ExhibitorTestDataFactory.buildECOrder(ecSetting.Id, contact);
        insert order;

        EC_Email__c email = ExhibitorTestDataFactory.buildECEmail(ecSetting.Id, order.Id);
        insert email;

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Default', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Exhibitor Test Event', false, false, zone.Id);
        insert event;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);
    }

    @IsTest
    public static void test_getEmailPreview(){

            String body = EC_EmailPreviewController.getEmailPreview([SELECT Id FROM EC_Email__c LIMIT 1].Id);
        System.debug('body == ' + body);
            System.assertEquals(body.contains('Lorem ipsum dolor'), true);

    }

}
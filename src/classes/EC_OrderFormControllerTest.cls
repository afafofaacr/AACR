/**
 * Created by afaf.awad on 3/24/2021.
 */
@IsTest
public with sharing class EC_OrderFormControllerTest {

    @TestSetup public static void setup() {
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

        EC_Schedule__c schedule = ExhibitorTestDataFactory.buildECSchedule(event.Id);
        insert schedule;

        Time_Slot__c timeSlot = ExhibitorTestDataFactory.buildTimeSlot(order.Id, email.Id, schedule.Id);
        insert timeSlot;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);


    }

    @IsTest
    public static void test_getOrderInfo() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        EC_Email__c email = [SELECT Id, EC_Order__c, Exhibitor_Setting__c FROM EC_Email__c];

        List<Process_Steps__mdt> pSteps = [SELECT Id, Step_Order__c, Process__c FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'New_Exhibitor_Order' AND Join_Step__r.DeveloperName = 'EC_Order_Form'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Contact__c = con.Id, JoinId__c = pSteps[0].Process__c, Step_Order__c = pSteps[0].Step_Order__c - 1);
        insert las;

        System.runAs(user) {
            EC_OrderFormController.OrderInfo orderInfo = EC_OrderFormController.getOrderInfo(email.EC_Order__c, pSteps[0].Id);
            System.assertEquals(OrderInfo.order.Id, email.EC_Order__c);
            System.assertEquals(OrderInfo.countries.size(), 3);

        }
    }

    @IsTest
    public static void test_saveOrder() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        EC_Order__c order = [SELECT Id FROM EC_Order__c LIMIT 1];

        List<EC_OrderFormController.columnObject> countries = EC_OrderFormController.getColumnObject('Countries__c');
        List<EC_OrderFormController.columnObject> attendeeTypes = EC_OrderFormController.getColumnObject('Attendee_Type__c');
        List<EC_OrderFormController.columnObject> institutionTypes = EC_OrderFormController.getColumnObject('Institution_Type__c');
        List<EC_OrderFormController.columnObject> degrees = EC_OrderFormController.getColumnObject('Degrees__c');
        List<EC_OrderFormController.columnObject> organs = EC_OrderFormController.getColumnObject('Organ_Sites__c');
        List<EC_OrderFormController.columnObject> researchAreas = EC_OrderFormController.getColumnObject('Research_Area_of_Expertise__c');

        System.runAs(user) {
           EC_OrderFormController.saveOrder(order.Id, 'Test Order', JSON.serialize(countries), JSON.serialize(attendeeTypes)
                                                            ,JSON.serialize(degrees) , JSON.serialize(institutionTypes), JSON.serialize(organs), JSON.serialize(researchAreas));

        }

        EC_Order__c newOrder = [SELECT Id, Countries__c, Attendee_Type__c, Institution_Type__c, Degrees__c, Organ_Sites__c, Research_Area_of_Expertise__c FROM EC_Order__c];

        System.assertEquals(ColumnObjectToList(countries), newOrder.Countries__c);
        System.assertEquals(ColumnObjectToList(attendeeTypes), newOrder.Attendee_Type__c);
        System.assertEquals(ColumnObjectToList(degrees), newOrder.Degrees__c);

    }

    private static String ColumnObjectToList(List<EC_OrderFormController.columnObject> cObject){
        List<String> objectList = new List<String>();
        for(EC_OrderFormController.columnObject o : cObject){
            objectList.add(o.option);
        }
        return JSON.serialize(objectList).remove('"').remove('[').remove(']').replace(',',';');
    }

}
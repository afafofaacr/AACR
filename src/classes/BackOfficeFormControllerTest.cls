/**
 * Created by afaf.awad on 12/18/2019.
 */

@IsTest
private class BackOfficeFormControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('TEST Account');
        insert acc;

        Contact con = TestDataFactory.buildContactMemberPrior(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c event = TestDataFactory.buildEvent();
        insert event;

        PagesApi__Form__c form = TestDataFactory.buildForm();
        insert form;

        PagesApi__Field_Group__c fieldGroup = TestDataFactory.buildFieldGroup(form);
        insert fieldGroup;

        PagesApi__Field__c field = TestDataFactory.buildField(form, fieldGroup, 'text');
        insert field;

        EventApi__Ticket_Type__c ticketType = TestDataFactory.buildTicketType(event);
        ticketType.EventApi__Form__c = form.Id;
        insert ticketType;

        OrderApi__Item_Class__c ticketItemClass = TestDataFactory.buildItemClass('Test Tickets');
        insert ticketItemClass;

        OrderApi__Item__c ticketItem = TestDataFactory.buildItem(ticketItemClass.Id, 'Test Ticket');
        ticketItem.EventApi__Ticket_Type__c = ticketType.Id;
        insert ticketItem;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id );
        insert SO;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(SO.Id, ticketItem.Id, ticketItemClass.Id);
        insert sol;

        ContentVersion cv = TestDataFactory.buildFile('Test file');
        insert cv;

    }


    @isTest
    public static void test_getTicketTypeForm(){

        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;
        OrderApi__Sales_Order_Line__c sol = [SELECT Id, OrderApi__Item__r.EventApi__Ticket_Type__c FROM OrderApi__Sales_Order_Line__c
                                            WHERE OrderApi__Sales_Order__c =: salesOrderId LIMIT 1];

        EventApi__Ticket_Type__c tt = [
                SELECT Id, Name, EventApi__Item__c,EventApi__Is_Active__c, EventApi__Is_Published__c, EventApi__Form__c
                FROM EventApi__Ticket_Type__c
                WHERE Id = : sol.OrderApi__Item__r.EventApi__Ticket_Type__c];

        System.debug('tt = ' + tt);

        List<PagesApi__Field__c> fields =[SELECT Id, Name, PagesApi__Order__c, PagesApi__Type__c, PagesApi__Options__c, PagesApi__Is_Required__c,
                PagesApi__Help_Text__c, PagesApi__Field_Group__r.PagesApi__Instructions__c, PagesApi__Field_Group__r.Name,
                PagesApi__Field_Group__r.PagesApi__Order__c, PagesApi__Field_Group__c, PagesApi__Form__r.Name, PagesApi__Form__c
        FROM PagesApi__Field__c
        WHERE PagesApi__Form__c = :tt.EventApi__Form__c];

        System.debug('Fields = ' + fields);

        Test.startTest();
        BackOfficeFormController.BackOfficeFormData BOFData = BackOfficeFormController.getBackOfficeFormData(salesOrderId);
        System.debug('BOFData = ' + BOFData);
        Test.stopTest();

        System.assertNotEquals(null, BOFData);

    }

    @isTest
    public static void test_getFieldResponses() {

        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c = :con.Id].Id;

        Test.startTest();
        List<PagesApi__Field_Response__c> fieldResponses = BackOfficeFormController.getFieldResponses(salesOrderId);
        Test.stopTest();

        System.assertEquals(0, fieldResponses.size());
    }

    @isTest
    public static void test_createFieldResponses(){

        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;
        BackOfficeFormController.BackOfficeFormData BOFData = BackOfficeFormController.getBackOfficeFormData(salesOrderId);
        PagesApi__Field__c field = [SELECT Id, PagesApi__Field_Group__c FROM PagesApi__Field__c WHERE PagesApi__Form__c =: BOFData.form.Id];
        PagesApi__Field_Group__c fieldGroup= [SELECT Id FROM PagesApi__Field_Group__c WHERE PagesApi__Form__c =: BOFData.form.Id];
        String fieldResponse = '[{"fieldObj":"' + field.Id + '","response":"yes","formId":"' + BOFData.form.Id + '","fieldResponseId":""}]';

        Test.startTest();
        BackOfficeFormController.createFieldResponses(fieldResponse, BOFData.formResponse.Id);
        String fieldResponseId = [SELECT Id from PagesApi__Field_Response__c WHERE PagesApi__Field__c =: field.Id LIMIT 1].Id;
        String fieldResponse2 = '[{"fieldObj":"' + field.Id + '","response":"No","formId":"' + BOFData.form.Id + '","fieldResponseId":"'+ fieldResponseId + '"}]';
        BackOfficeFormController.createFieldResponses(fieldResponse2, BOFData.formResponse.Id);
        PagesApi__Field__c field2 = TestDataFactory.buildField(BOFData.form, fieldGroup, 'text');
        insert field2;
//        String fieldResponseId2 = [SELECT Id from PagesApi__Field_Response__c WHERE PagesApi__Field__c =: field2.Id LIMIT 1].Id;
        String fieldResponse3 = '[{"fieldObj":"' + field2.Id + '","response":"Maybe","formId":"' + BOFData.form.Id + '","fieldResponseId":""}]';
        BackOfficeFormController.createFieldResponses(fieldResponse3, BOFData.formResponse.Id);
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Id from PagesApi__Field_Response__c where OrderApi__Form_Response__c =: BOFData.formResponse.Id]);


    }

    @isTest
    public static void test_getAndRemoveFile(){

        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        ContentVersion documentId = [SELECT Id, Title, ContentDocumentId FROM ContentVersion LIMIT 1];

        System.debug('documentId = ' + documentId);

        Test.startTest();
        ContentVersion cv = BackOfficeFormController.getAttachments(documentId.ContentDocumentId);
        BackOfficeFormController.removeFile('Test File', con.id);
        Test.stopTest();

    }

}
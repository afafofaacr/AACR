/**
 * Created by afaf.awad on 11/26/2019.
 */

public with sharing class BackOfficeFormController {

    /**
     * @purpose: Getting Form data for Back office Ticketing
     *
     * @param salesOrderId
     *
     * @return: contactId, form, fieldGroups, fields, formResponse
     */
    @AuraEnabled
    public static BackOfficeFormData getBackOfficeFormData(Id salesOrderId) {
        List<OrderApi__Sales_Order_Line__c> soLines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        String contactId = soLines[0].OrderApi__Sales_Order__r.OrderApi__Contact__c;
        System.debug('Contact Id = ' + contactId);

        try{
            EventApi__Ticket_Type__c tt = [
                    SELECT Id, Name, EventApi__Item__c,EventApi__Is_Active__c, EventApi__Is_Published__c, EventApi__Form__c
                    FROM EventApi__Ticket_Type__c
                    WHERE Id = :soLines[0].OrderApi__Item__r.EventApi__Ticket_Type__c
            ];

            System.debug('TicketType Object: ' + tt);

            List<PagesApi__Field__c> fields = getFormFields(tt.EventApi__Form__c);

            System.debug('Fields returned : ' + fields);

            PagesApi__Form__c form = new PagesApi__Form__c(Id = fields[0].PagesApi__Form__c,
                                                            Name = fields[0].PagesApi__Form__r.Name);

            Set<PagesApi__Field_Group__c> fieldGroupsSet = new Set<PagesApi__Field_Group__c>();
            List<PagesApi__Field_Group__c> fieldGroupsLst = new List<PagesApi__Field_Group__c>();

            for(PagesApi__Field__c field : fields){
                PagesApi__Field_Group__c fieldGroup = new PagesApi__Field_Group__c();
                fieldGroup.Id =field.PagesApi__Field_Group__c;
                fieldGroup.Name = field.PagesApi__Field_Group__r.Name;
                fieldGroup.PagesApi__Instructions__c = field.PagesApi__Field_Group__r.PagesApi__Instructions__c;
                fieldGroup.PagesApi__Order__c = field.PagesApi__Field_Group__r.PagesApi__Order__c;
                fieldGroupsLst.add(fieldGroup);
            }
            System.debug('fieldGroupsLst = ' + fieldGroupsLst);

            List<PagesApi__Field_Group__c> fieldGroups = new List<PagesApi__Field_Group__c>();
            fieldGroupsSet.addAll(fieldGroupsLst);
            fieldGroups.addAll(fieldGroupsSet);

            System.debug('fieldGroupsSet = ' + fieldGroupsSet);
            System.debug('fieldGroups = ' + fieldGroups);

            PagesApi__Form_Response__c formResponse = createFormResponse(form.Id, salesOrderId, contactId);
//            PagesApi__Form__c form = [SELECT Id, Name FROM PagesApi__Form__c WHERE Id = :tt.EventApi__Form__c];

            return new BackOfficeFormData(contactId, form, fieldGroups, fields, formResponse);

        }catch(Exception ex){
            return null;
        }
    }

    @AuraEnabled
    public static List<PagesApi__Field_Response__c> getFieldResponses(String salesOrderId){

        List<PagesApi__Field_Response__c> fieldResponses = [SELECT Id, Name, PagesApi__Response__c, PagesApi__Form_Response__r.PagesApi__Contact__c,
                                                            PagesApi__Field__c,PagesApi__Field__r.PagesApi__Type__c, PagesApi__Field__r.PagesApi__Help_Text__c, PagesApi__Field__r.Name,
                                                            PagesApi__Field__r.PagesApi__Field_Group__c,PagesApi__Form_Response__c, PagesApi__Field__r.PagesApi__Form__c,
                                                            PagesApi__Field__r.PagesApi__Order__c, PagesApi__Field__r.PagesApi__Is_Required__c
                                                        FROM PagesApi__Field_Response__c
                                                        WHERE PagesApi__Form_Response__r.OrderApi__Sales_Order__c = :salesOrderId
                                                        ORDER BY PagesApi__Field_Group__r.PagesApi__Order__c, PagesApi__Field__r.PagesApi__Order__c];

        System.debug('FieldResponses : ' + fieldResponses);
        return fieldResponses;
    }


    @AuraEnabled
    public static List<PagesApi__Field__c> getFormFields(String formId) {

        return [SELECT Id, Name, PagesApi__Order__c, PagesApi__Type__c, PagesApi__Options__c, PagesApi__Is_Required__c,
                PagesApi__Help_Text__c, PagesApi__Field_Group__r.PagesApi__Instructions__c, PagesApi__Field_Group__r.Name,
                PagesApi__Field_Group__r.PagesApi__Order__c, PagesApi__Field_Group__c, PagesApi__Form__r.Name, PagesApi__Form__c
                FROM PagesApi__Field__c
                WHERE PagesApi__Form__c = :formId];

    }

    @AuraEnabled
    public static PagesApi__Form_Response__c createFormResponse(String formId, String salesOrderId, String contactId){

        PagesApi__Form_Response__c formResponse = new PagesApi__Form_Response__c();

        try {
            formResponse = [SELECT Id FROM PagesApi__Form_Response__c WHERE OrderApi__Sales_Order__c = :salesOrderId];

        }catch(Exception e){
            //Create form Response
            formResponse.PagesApi__Form__c = formId;
            formResponse.PagesApi__Contact__c = contactId;
            formResponse.PagesApi__Entity__c = 'Contact';
            formResponse.PagesApi__Date__c = Date.today();
            formResponse.OrderApi__Sales_Order__c = salesOrderId;

            insert formResponse;
        }

        System.debug(formResponse);
        return formResponse;

    }

    public class JSON2Apex {
        public String fieldObj;
        public String response;
        public String formId;
        public String fieldResponseId;
    }

    /**
     * @Purpose: Creating or Updating Field Responses. It will check if the related Field to the Field Response exists for the choosen form response
     *          If it does not exist, it will create a new Field Response record.
     * @param fieldResponses
     * @param formResponseId
     */
    @AuraEnabled
    public static void createFieldResponses(String fieldResponses, String formResponseId){

        String jsonString = fieldResponses;
        List<JSON2Apex> obj = (List<JSON2Apex>) JSON.deserialize(jsonString, List<JSON2Apex>.class);

        System.debug('fieldObj = ' + obj[0].fieldObj + '::::response = ' + obj[0].response + ':::: formId = ' + obj[0].formId + ':::: fieldResponseId = ' + obj[0].fieldResponseId);

        String fieldId =  obj[0].fieldObj;
        String fieldResponseId = obj[0].fieldResponseId;
        String response = obj[0].response;

        List<PagesApi__Field_Response__c> fieldResponsesList = [Select Id, PagesApi__Field__c from PagesApi__Field_Response__c where PagesApi__Form_Response__c =: formResponseId];
        List<String> fieldIds = new List<String>();


        List<PagesApi__Field_Response__c> updateFieldResponses = new List<PagesApi__Field_Response__c>();
        List<PagesApi__Field_Response__c> createFieldResponses = new List<PagesApi__Field_Response__c>();

            if(!fieldResponsesList.isEmpty()) {
                for(PagesApi__Field_Response__c fr : fieldResponsesList ){
                    fieldIds.add(fr.PagesApi__Field__c);
                }
                    if ( fieldIds.contains(fieldId)) {
                        PagesApi__Field_Response__c updateFieldResponse = new PagesApi__Field_Response__c();

                        updateFieldResponse.PagesApi__Response__c = response;
                        updateFieldResponse.Id = fieldResponseId;
                        updateFieldResponses.add(updateFieldResponse);
                    } else {
                        PagesApi__Field_Response__c createFieldResponse = new PagesApi__Field_Response__c();

                        createFieldResponse.PagesApi__Field__c = fieldId;
                        createFieldResponse.PagesApi__Response__c = response;
                        createFieldResponse.PagesApi__Form_Response__c = formResponseId;
                        createFieldResponse.OrderApi__Form__c = obj[0].formId;

                        createFieldResponses.add(createFieldResponse);
                    }
            } else {
                PagesApi__Field_Response__c createFieldResponse = new PagesApi__Field_Response__c();

                createFieldResponse.PagesApi__Field__c = fieldId;
                createFieldResponse.PagesApi__Response__c = response;
                createFieldResponse.PagesApi__Form_Response__c = formResponseId;
                createFieldResponse.OrderApi__Form__c = obj[0].formId;

                createFieldResponses.add(createFieldResponse);
            }
        System.debug('updateFieldResponses = ' + updateFieldResponses);
        System.debug('createFieldResponses = ' + createFieldResponses);

        if(!updateFieldResponses.isEmpty()){
            update updateFieldResponses;
        }
        if(!createFieldResponses.isEmpty()){
        insert createFieldResponses;
        }

    }

    @AuraEnabled
    public static Boolean removeFile(String fileName, String recordId){
        Boolean result = JP_FileUploadController.removeFile(fileName, recordId);

        return result;
    }

    @AuraEnabled
    public static ContentVersion getAttachments(String documentId){
        ContentVersion cvs = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =: documentId ORDER BY CreatedDate DESC LIMIT 1];

        return cvs;
    }

    //Consolidation of Back Office Form Data
    public class BackOfficeFormData{
        @AuraEnabled
        public PagesApi__Form__c form;

        @AuraEnabled
        public List<PagesApi__Field_Group__c> fieldGroups;

        @AuraEnabled
        public String contactId;

        @AuraEnabled
        public List<PagesApi__Field__c> fields;

        @AuraEnabled
        public PagesApi__Form_Response__c formResponse;

        public BackOfficeFormData(String contactId, PagesApi__Form__c form, List<PagesApi__Field_Group__c> fieldGroups, List<PagesApi__Field__c> fields, PagesApi__Form_Response__c formResponse ){
            this.form = form;
            this.contactId = contactId;
            this.fieldGroups = fieldGroups;
            this.fields = fields;
            this.formResponse = formResponse;
        }
    }


}
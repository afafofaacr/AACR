/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class DimensionTagBulkImportControllerTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i <5; i++) {
            Contact con = TestDataFactory.buildContact(acc.Id);
            con.LastName = con.LastName+i;
            con.Email = 'testemail' + i + '@yopmail.com';
            contacts.add(con);
        }
        insert contacts;

        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        OrderApi__GL_Account__c glAccount = TestDataFactory.buildGLAccount();
        glAccount.Distribution_Code__c = true;
        insert glAccount;

        Opportunity opp = TestDataFactory.buildOpportunity(acc.Id, contacts[0].Id, appealCode.Id, glAccount.Id);
        insert opp;

    }

    @IsTest
    public static void test_validateData(){
        List<Contact> contacts = [Select Id, AACR_ID__c FROM Contact];

        String sampleFile = 'Id, AACRID';
        for(Contact contact: contacts) {
            sampleFile += '\n' + contact.Id + ',' + contact.AACR_ID__c ;
        }

        List<String> fields = new List<String>();
        fields.add('Id');
        fields.add('AACRID');

        DimensionTagBulkImportController.fileData fileData = DimensionTagBulkImportController.validateData(sampleFile, fields,'Id');
        System.assertEquals(true, fileData.validated);

        sampleFile += '\n  , 123456';
        DimensionTagBulkImportController.fileData fileDataBlank = DimensionTagBulkImportController.validateData(sampleFile, fields,'Id');
        System.assertEquals(false, fileDataBlank.validated);

        sampleFile += '\n NOT AN ID , 123456';
        DimensionTagBulkImportController.fileData fileDataFalseId = DimensionTagBulkImportController.validateData(sampleFile, fields,'Id');
        System.assertEquals(false, fileDataFalseId.validated);

    }

    @IsTest
    public static void test_createTagRecords(){

        Dimension_Tags__mdt dimTag = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact];

        List<String> idString = new List<String>();
        for(Contact con: contacts){
            idString.add(con.Id);
        }

        DimensionTagBulkImportController.TagImportResults results = DimensionTagBulkImportController.createTagRecords(JSON.serialize(idString), dimTag.Id);
        System.assertEquals(5, results.importResults.size());
    }


//    @IsTest
//    public static void test_createTagRecords_Error(){
//
//        Dimension_Tags__mdt dimTag = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
//        List<Appeal_Code__c> appealCodes = [SELECT Id FROM Appeal_Code__c];
//
//        List<String> idString = new List<String>();
//        for(Appeal_Code__c ac: appealCodes){
//            idString.add(ac.Id);
//        }
//
//        DimensionTagBulkImportController.TagImportResults results = DimensionTagBulkImportController.createTagRecords(JSON.serialize(idString), dimTag.Id);
//        System.assertEquals(false, results.success);
//    }
}
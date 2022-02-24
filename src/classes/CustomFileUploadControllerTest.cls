/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class CustomFileUploadControllerTest {
 
    @isTest static void test_uploadAndRemoveFile(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        Test.startTest();
        Id fileId = CustomFileUploadController.saveChunk(con.Id, 'Test File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'JoinProcess');
        System.assertNotEquals(null, fileId);

        Id newFileId = CustomFileUploadController.saveChunk(con.Id, null, EncodingUtil.base64Encode(Blob.valueOf('Testing 456..')), null, fileId, 'JoinProcess');
        System.assertNotEquals(null, newFileId);

        CustomFileUploadController.removeFile('Test File', con.id);

        Test.stopTest();


    }
}
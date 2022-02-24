/**
 * Created by lauren.lezberg on 3/14/2019.
 */
@isTest
private with sharing class JP_FileUploadControllerTest {

    @isTest static void test_uploadAndRemoveFile(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact con = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert con;
        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        Test.startTest();
        ContentVersion file = JP_FileUploadController.saveChunk(con.Id, 'Test File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), '', 'JoinProcess', null);
//        JP_FileUploadController.uploadFile('TestFile', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', con.Id);
        System.assertNotEquals(null, file.Id);

        ContentVersion newFile = JP_FileUploadController.saveChunk(con.Id, null, EncodingUtil.base64Encode(Blob.valueOf('Testing 456..')), file.Id, 'JoinProcess', file.ContentDocumentId);
        System.assertNotEquals(null, newFile);

        JP_FileUploadController.removeFile(file.Id);

        Test.stopTest();


    }

}
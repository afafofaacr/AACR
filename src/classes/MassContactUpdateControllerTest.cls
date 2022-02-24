/**
 * Created by afaf.awad on 11/12/2021.
 */
@IsTest
public with sharing class MassContactUpdateControllerTest {

    @TestSetup
    public static void setup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<100 ; i++) {
            Contact con = TestDataFactory.buildContact(acc.Id);
            con.FirstName = 'Zono';
            con.LastName = 'TestAddress' + i;
            con.Email = 'testcontact'+i+'@aacrtest.org';
            contacts.add(con);
        }
        insert contacts;


    }

    @IsTest
    public static void test_executeMassContactUpdate(){
        String Id = MassContactUpdateController.executeMassContactUpdate();

        AsyncApexJob job = MassContactUpdateController.getBatchJobStatus(Id);

        System.assertEquals(job != null, true);
    }

    @IsTest
    public static void test_emailBatchResults(){
        List<Contact> contacts = [SELECT Id FROM Contact];
        Map<String,String> errorMap = new Map<String,String>();
        for(Contact con : contacts){
            errorMap.put(con.Id, 'Test Error');
        }

        MassContactUpdateController.emailBatchResults(errorMap,100);
    }
}
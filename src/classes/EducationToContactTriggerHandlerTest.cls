/**
 * Created by lauren.lezberg on 4/23/2021.
 */

@IsTest
private class EducationToContactTriggerHandlerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
    }


    @IsTest
    static void testBehavior() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();

        Education__c edu = new Education__c(
                Education_Related_to_Contact__c=con.Id,
                Date_of_Expected_Graduation__c=Date.newInstance(System.now().year() + 3, 4, 20),
                Degree_Completion_Year__c = String.valueOf(System.now().year()+3)
        );

        insert edu;

        con = [SELECT Expected_Completion_Date__c FROM Contact WHERE Id=:con.Id];
        SYstem.assertEquals(con.Expected_Completion_Date__c, edu.Date_of_Expected_Graduation__c);

        edu.Date_of_Expected_Graduation__c = Date.newInstance(System.now().year() + 5, 5, 7);
        update edu;


        Test.stopTest();

    }
}
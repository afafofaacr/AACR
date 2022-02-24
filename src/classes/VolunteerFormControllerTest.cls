/**
 * Created by afaf.awad on 9/18/2020.
 */

@IsTest
private class VolunteerFormControllerTest {

    @IsTest static void testDefaultData(){
        Test.startTest();
        VolunteerFormController.getDefaultData('Advocate');
        Test.stopTest();
    }

    @IsTest static void testGetStakeholderOptions(){
        Test.startTest();
        VolunteerFormController.getStakeholderOptions();
        Test.stopTest();
    }

    @IsTest static void testForceSiteDomain(){
        Test.startTest();
        VolunteerFormController.getForceSiteDomain();
        Test.stopTest();
    }

    @IsTest static void testGetSiteKey(){
        Test.startTest();
        VolunteerFormController.getSiteKey();
        Test.stopTest();
    }

    @IsTest
    static void testSaveVolunteer() {

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.Email='testvolunteer@yopmail.com';
        con.Phone= '1234567890';
//        con.Volunteer_For__c = 'Anything';

        String conString = JSON.serialize(con);

        Test.startTest();
        //Trigger an error
        VolunteerFormController.saveVolunteer(conString);

        //Fix error and fire again
        con.LastName = 'Volunteer';
        String conString2 = JSON.serialize(con);
        VolunteerFormController.saveVolunteer(conString2);
        Test.stopTest();

        List<Contact> contact = [SELECT Id FROM Contact];
        System.assertEquals(1, contact.size());
    }

}
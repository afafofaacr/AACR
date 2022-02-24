/**
 * Created by afaf.awad on 11/17/2020.
 */

@IsTest(SeeAllData=true)
private class WorldBankIntegrationTest {

    
    @IsTest
    public static void testWorldBankApi() {

        Test.startTest();
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'OK',
                createJSONResponseBody(),
                null);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Id JobId = WorldBankIntegration.findNewIncomeLevels();
        AsyncApexJob BatchJobInfo = WorldBankIntegration.getWB_BatchJobStatus(JobId);

        Test.stopTest();
        System.assertEquals(JobId, BatchJobInfo.Id);


    }

    @IsTest public static void test_Schedule(){

        String CRON_EXP = '0 0 0 15 3 ? 2025';

        Test.startTest();

        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'OK',
                createJSONResponseBody(),
                null);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        String schedJobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_UpdateContactWorldBankScheduler());
        Test.stopTest();


    }

    @IsTest public static void test_triggerContactUpdate(){

        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Test.startTest();
        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Zono';
        con.LastName = 'WorldBank';
        con.MailingCountryCode = 'AF';
        insert con;

        Contact conPost = [SELECT Id, Income_Level__c FROM Contact WHERE Id =: con.Id];
        System.assertEquals('Low Income', conPost.Income_Level__c);

        Test.stopTest();


    }

    private static String createJSONResponseBody(){
        return '[\n' +
                '    {\n' +
                '        "page": 1,\n' +
                '        "pages": 1,\n' +
                '        "per_page": "500",\n' +
                '        "total": 459\n' +
                '    },\n' +
                '    [\n' +
                '        {\n' +
                '            "id": "AFG",\n' +
                '            "iso2Code": "AF",\n' +
                '            "name": "Afghanistan",\n' +
                '            "region": {\n' +
                '                "id": "SAS",\n' +
                '                "iso2code": "8S",\n' +
                '                "value": "South Asia"\n' +
                '            },\n' +
                '            "adminregion": {\n' +
                '                "id": "SAS",\n' +
                '                "iso2code": "8S",\n' +
                '                "value": "South Asia"\n' +
                '            },\n' +
                '            "incomeLevel": {\n' +
                '                "id": "LIC",\n' +
                '                "iso2code": "XM",\n' +
                '                "value": "Low income"\n' +
                '            },\n' +
                '            "lendingType": {\n' +
                '                "id": "IDX",\n' +
                '                "iso2code": "XI",\n' +
                '                "value": "IDA"\n' +
                '            },\n' +
                '            "capitalCity": "Kabul",\n' +
                '            "longitude": "69.1761",\n' +
                '            "latitude": "34.5228"\n' +
                '        }\n' +
                ']\n' +
                ']';
    }
}
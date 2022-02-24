/**
 * Created by lauren.lezberg on 3/15/2021.
 */

@IsTest
private class CallableTestTest {

    @TestSetup
    public static void setup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
    }


    @IsTest
    static void testSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Callable extension = (Callable) Type.forName('CallableTest').newInstance();
        String att = String.valueOf(extension.call('sendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>'12345', 'flag'=>false}));

        System.assertNotEquals(null, att);
    }

    @IsTest
    static void testGoToVenue() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Callable extension = (Callable) Type.forName('CallableTest').newInstance();
        String url = String.valueOf(extension.call('goToVenue', new Map<String, Object>{'contactId'=>con.Id, 'SFEventId'=>'1234'}));

        System.assertNotEquals(null, url);
    }

    @IsTest
    static void testUpdateAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Callable extension = (Callable) Type.forName('CallableTest').newInstance();
        extension.call('updateAttendee', new Map<String, Object>{'contactId'=>con.Id, 'SFEventId'=>'1234'});

    }
}
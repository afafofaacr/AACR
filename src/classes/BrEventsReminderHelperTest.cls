@IsTest
private class BrEventsReminderHelperTest {
    @isTest
    public static void testGetDiffMinutesBetweenTimezones() {
        Test.startTest();

        Integer diffMinutes = BrEventsReminderHelper.getDiffMinutesBetweenTimezones('(GMT+01:00) British Summer Time', 'Europe/Minsk');

        Test.stopTest();

        System.assertEquals(-120, diffMinutes, 'wrong minutes');
    }
}
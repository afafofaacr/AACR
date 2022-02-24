public with sharing class BrEventsReminderHelper {
    public static Integer getDiffMinutesBetweenTimezones(String eventTimezone, String userTimezoneSidKey) {
        String eventTimezoneGmt = eventTimezone.substringAfter('(GMT').substringBefore(')');
        String operation = eventTimezoneGmt.substring(0, 1);

        Integer lastIndex = eventTimezoneGmt.length();
        String eventTime = eventTimezoneGmt.substring(1, lastIndex);
        String firstChar = eventTime.substring(0, 1);
        String secondChar = eventTime.substring(1, 2);
        String preLastChar = eventTime.substring(lastIndex-3, lastIndex-2);
        String lastChar = eventTime.substring(lastIndex-2, lastIndex-1);

        Integer hours = Integer.valueOf(firstChar) * 10 + Integer.valueOf(secondChar);
        Integer eventTimezoneOffsetMinutes = hours * 60 + Integer.valueOf(preLastChar) * 10 + Integer.valueOf(lastChar);

        if (operation == '-') {
            eventTimezoneOffsetMinutes *= -1;
        }

        Timezone currentTimezone = Timezone.getTimeZone(userTimezoneSidKey);
        Integer userTimezoneOffsetMinutes = currentTimezone.getOffset(DateTime.now())/1000/60;

        System.debug(eventTimezoneOffsetMinutes - userTimezoneOffsetMinutes);

        return (eventTimezoneOffsetMinutes - userTimezoneOffsetMinutes);
    }
}
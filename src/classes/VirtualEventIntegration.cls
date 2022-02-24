/**
 * Created by lauren.lezberg on 6/23/2020.
 */

public interface VirtualEventIntegration {

    String sendAttendee(String contactId, String externalEventId, Boolean flag);
    void asyncSendAttendee(String contactId, String externalEventId, Boolean flag);
    void deleteAttendee(String fuzionAttendeeId, String fuzionEventId);
    void updateAttendee(String participantId);
    String goToVenue(String contactId, String SFEventId);
}
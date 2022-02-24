/**
 * Created by afaf.awad on 3/15/2021.
 */

public with sharing class SendGrid2Apex {

    public class Messages {
        public String from_email;
        public String msg_id;
        public String subject;
        public String to_email;
        public String status;
        public Integer opens_count;
        public Integer clicks_count;
        public String last_event_time;
    }

    public List<Messages> messages;


    public static SendGrid2Apex parse(String json) {
        try {
            return (SendGrid2Apex) System.JSON.deserialize(json, SendGrid2Apex.class);
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }

}
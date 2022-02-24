/**
 * Created by afaf.awad on 5/10/2021.
 */

public with sharing class SendGridActivityController {

    @Future(Callout=true)
    public static void downloadEmailActivity(Date deliveryDate, Time startTime, String subject, Id orderId){
        Send_Grid__c sendGrid = Send_Grid__c.getOrgDefaults();

        String startString = Datetime.newInstance(deliveryDate,startTime).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String endString = Datetime.newInstance(System.today().year(), System.today().month(), System.today().day() ,0,0,0).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        System.debug('Start dateTime == ' + startString);
        System.debug('End dateTime == ' + endString);

        String url = sendGrid.url__c + '/messages?query=subject%3D%22'+ subject.replace(' ','%20')
                + '%22AND%20last_event_time%20BETWEEN%20TIMESTAMP%20%22'+EncodingUtil.urlEncode(String.valueOf(startString),'UTF-8')
                + '%22%20AND%20TIMESTAMP%20%22' + EncodingUtil.urlEncode(String.valueOf(endString),'UTF-8') + '%22&limit=100000';

        System.debug('url == ' + url);


        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('authorization', 'Bearer ' + sendGrid.API_key__c);

            Http http = new Http();
            req.setTimeout(20000);
            HttpResponse res = http.send(req);
            System.debug(res.getBody());
            System.debug('statusCode == ' + res.getStatusCode());
            SendGrid2Apex sendGrid_Obj = SendGrid2Apex.parse(res.getBody());

            System.debug('sendGrid_Obj == ' + sendGrid_Obj);
            if ( res.getStatusCode() == 200 ) {
                List<Email_Activity__c> emailActivities = new List<Email_Activity__c>();
                for (SendGrid2Apex.Messages mes : sendGrid_Obj.messages) {
                    Email_Activity__c ea = new Email_Activity__c(Subject__c = mes.subject
                            , Delivery_Time__c = Datetime.valueOf(mes.last_event_time.replace('T', ' '))
                            , From_Email__c = mes.from_email
                            , To_Email__c = mes.to_email
                            , EC_Order__c = orderId);

                    emailActivities.add(ea);
                }
                insert emailActivities;
            } else {
                System.debug('Error: ' + res.getBody());
                System.debug('ErrorCode: ' + res.getStatusCode());
            }
        }catch(Exception ex){

        }

    }

}
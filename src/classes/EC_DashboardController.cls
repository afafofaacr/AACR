/**
 * Created by afaf.awad on 2/8/2021.
 */

public without sharing class EC_DashboardController {

    @AuraEnabled
    public static DashboardInfo getDashboardInfo(){

        EC_Exhibitor_Setting__c exSetting = EC_Helper.getExhibitorSetting(ECRMUtils.getCurrentLoginContact().AccountId);
        List<Time_Slot__c> timeSlots;
        List<EC_Order__c> orders = EC_Helper.getAllOrdersForAccount();
        If(!orders.isEmpty()){
            List<Id> orderIds = new List<Id>();
            for (EC_Order__c o : orders) {
                orderIds.add(o.Id);
            }

            System.debug('orderIds == ' + orderIds);

            timeSlots = [SELECT Id, Start_Time__c, End_Time__c, Delivery_Date__c, EC_Order__c,
                            EC_Order__r.Name, EC_Order__r.Amount_Targeted__c, Status__c, EC_Email__r.Subject__c
                    FROM Time_Slot__c
                    WHERE EC_Order__c IN:orderIds
                    ORDER BY Name DESC
            ];

            System.debug('TimeSlots = ' + timeSlots);
        }

        System.debug('DashboardInfo == ' + new DashboardInfo(orders, timeSlots, exSetting));

            return new DashboardInfo(orders, timeSlots, exSetting);
    }

    /**
     * @purpose Get exhibitor order "join process" id
     *
     * @return Id of process
     */
    @AuraEnabled
    public static String getExhibitorOrderProcessId(){

        String conId = ECRMUtils.getCurrentLoginUserContactId();
        EC_Order__c order = EC_Helper.createNewOrder();
        insert order;
        // get join process
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='New_Exhibitor_Order'];

        Decimal lastStepOrder = JP_Helper.getLastAccessedStepOrder(jp.Id);
        if(lastStepOrder!=null) {
            if (lastStepOrder != 0) {
                contact_last_accessed_step__c las = [SELECT Id FROM contact_last_accessed_step__c WHERE JoinId__c = :jp.Id AND Contact__c=: conId];
                delete las;
            }
        }
        String redirectURL = '/apex/JP_Container?id=' + jp.Id + '&c__orderId=' + order.Id;

        return redirectURL;
    }

    @AuraEnabled
    public static String getExhbitorSettingURL(){

        String accountId = ECRMUtils.getCurrentLoginContact().AccountId;

        String redirectURL;
        EC_Exhibitor_Setting__c exSetting = EC_Helper.getExhibitorSetting(accountId);

        if(exSetting != null) {
            redirectURL = '/apex/EC_AccountInformation?exId=' + exSetting.Id;
        }else{
            EC_Exhibitor_Setting__c newSetting = new EC_Exhibitor_Setting__c(Company__c = accountId);
            insert newSetting;
            redirectURL = '/apex/EC_AccountInformation?exId=' + newSetting.Id;
        }
        return redirectURL;
    }

    @AuraEnabled
    public static String getIncompleteOrder(String orderId){

        EC_Order__c order = EC_Helper.getOrderRecord(orderId);
        // get join process
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='New_Exhibitor_Order'];

        String redirectURL = '/apex/JP_Container?id=' + jp.Id + '&c__orderId=' + order.Id;

        return redirectURL;
    }

    @AuraEnabled
    public static List<EC_Order__c> deleteRecord(String orderId){

        List<Time_Slot__c> timeSlots = new List<Time_Slot__c>();
        List<EC_Email__c> emails = new List<EC_Email__c>();

        EC_Order__c orders = [SELECT Id, (SELECT Id FROM Time_Slots__r), (SELECT Id FROM Exhibitor_Emails__r) FROM EC_Order__c WHERE Id =: orderId];

        if(orders.Time_Slots__r.size() > 0){
            for(Time_Slot__c ts: orders.Time_Slots__r) {
                timeSlots.add(new Time_Slot__c(Id = ts.Id));
            }
        }
        if(orders.Exhibitor_Emails__r.size() > 0){
            for(EC_Email__c e: orders.Exhibitor_Emails__r) {
                emails.add(new EC_Email__c(Id = e.Id));
            }
        }

        EC_Order__c order = new EC_Order__c(Id = orderId);

        if(!timeSlots.isEmpty()){
            delete timeSlots;
        }
        if(!emails.isEmpty()){
            delete emails;
        }
        delete order;

        return EC_Helper.getAllOrdersForAccount();

    }

//    @AuraEnabled
//    public static List<EmailActivity> getEmailActivityList(String jsonString){
//        List<String> orderIds = (List<String>) JSON.deserialize(jsonString, List<String>.class);
//
//        System.debug(orderIds);
//
//        List<Time_Slot__c> timeSlots = [SELECT Id, Start_Time__c, End_Time__c, Delivery_Date__c, EC_Order__c,
//                                        EC_Order__r.Name, EC_Order__r.Amount_Targeted__c, Status__c, EC_Email__r.Subject__c
//                                        FROM Time_Slot__c
//                                        WHERE EC_Order__c IN:orderIds
//                                        ORDER BY Name DESC
//        ];
//
//        List<EmailActivity> emailActivities = new List<EmailActivity>();
//
//        for(Time_Slot__c ts: timeSlots){
//            if(ts.Status__c == 'Sent') {
//                emailActivities.add(getEmailActivity(ts));
//            }
//        }
//
//        return emailActivities;
//    }


//    @AuraEnabled
//    public static EmailActivity getEmailActivity(Time_Slot__c timeSlot){
//        Send_Grid__c sendGrid = Send_Grid__c.getOrgDefaults();
//        Integer totalClicks = 0;
//        Integer openClicks = 0;
//
//        String startDateTime = Datetime.newInstance(timeSlot.Delivery_Date__c,timeSlot.Start_Time__c).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
//        String endDateTime = Datetime.newInstance(timeSlot.Delivery_Date__c, timeSlot.End_Time__c).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
//
//        System.debug('Start dateTime == ' + startDateTime);
//        System.debug('End dateTime == ' + endDateTime);
//
//        String url = sendGrid.url__c + '/messages?query=subject%3D%22'+timeSlot.EC_Email__r.Subject__c.replace(' ','%20')
//                + '%22AND%20last_event_time%20BETWEEN%20TIMESTAMP%20%22'+EncodingUtil.urlEncode(String.valueOf(startDateTime),'UTF-8')
//                + '%22%20AND%20TIMESTAMP%20%22' + EncodingUtil.urlEncode(String.valueOf(endDateTime),'UTF-8') + '%22&limit=100000';
//
//        System.debug('url == ' + url);
//
//        HttpRequest req = new HttpRequest();
//        req.setMethod('GET');
//        req.setEndpoint(url);
//        req.setHeader('Content-Type','application/json');
//        req.setHeader('authorization','Bearer ' + sendGrid.API_key__c);
//        //req.setBody(jsonGenerator(emailMap,subject,fromWho,replyTo,emailContent));
//
//        if (Test.isRunningTest()) {
//            totalClicks = 1;
//            openClicks = 1;
//        } else {
//            Http http = new Http();
//            req.setTimeout(20000);
//            HttpResponse res = http.send(req);
//            System.debug(res.getBody());
//
//            SendGrid2Apex sendGrid_Obj = SendGrid2Apex.parse(res.getBody());
//
//            if ( res.getStatusCode() == 200 ) {
//                for (SendGrid2Apex.Messages mes : sendGrid_Obj.messages) {
////            System.debug('messages = ' + mes.clicks_count);
//                    totalClicks = totalClicks + mes.clicks_count;
//                    openClicks = openClicks + mes.opens_count;
//                }
//            } else {
//                System.debug('Error: ' + res.getBody());
//            }
//        }
//
//        return new EmailActivity(timeSlot.EC_Order__r.Name, totalClicks, openClicks);
//
//    }


//    public class EmailActivity{
//        @AuraEnabled
//        public String orderNum;
//        @AuraEnabled
//        public Integer clicks;
//        @AuraEnabled
//        public Integer opens;
//
//        public EmailActivity(String orderNumber, Integer totalClicks, Integer totalOpens){
//            this.orderNum = orderNumber;
//            this.clicks = totalClicks;
//            this.opens = totalOpens;
//
//        }
//    }


    public class DashboardInfo{
        @AuraEnabled
        public List<EC_Order__c> orders;
        @AuraEnabled
        public List<Time_Slot__c> timeSlots;
        @AuraEnabled
        public EC_Exhibitor_Setting__c exSetting;
//        @AuraEnabled
//        public List<EmailActivity> emailAct;

        public DashboardInfo(List<EC_Order__c> exOrders, List<Time_Slot__c> schedules, EC_Exhibitor_Setting__c exhibitorSetting){
            this.orders = exOrders;
            this.timeSlots = schedules;
            this.exSetting = exhibitorSetting;
//            this.emailAct = emailActivities;
        }
    }


}
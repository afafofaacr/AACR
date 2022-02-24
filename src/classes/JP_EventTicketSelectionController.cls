/**
 * Created by lauren.lezberg on 3/17/2020.
 */

public without sharing class JP_EventTicketSelectionController {


    @AuraEnabled
    public static String getEventId(String salesOrderId){

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT OrderApi__Item__r.AC_Event__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId];

        if(!lines.isEmpty()) {
            return lines[0].OrderApi__Item__r.AC_Event__c;
        }

        return null;
    }

    @AuraEnabled
    public static EventTickets getUserTicketPrice(String eventId, String salesOrderId){
        if(String.isBlank(salesOrderId)){
            new AACRCustomException('Empty sales order Id', 'JP_EventTicketSelectionController.getUserTicketPrice', 'Back Office Ticketing');
            return null;
        }

        if(String.isBlank(eventId)){
            new AACRCustomException('Null event Id','JP_EventTicketSelectionController.getUserTicketPrice()', 'Back Office Ticketing');
            return null;
        }

        Boolean hasTicket, ticketHasPrice = false;
        OrderApi__Sales_Order__c so = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=:salesOrderId];
        List<BR_Participation__c> tickets = [SELECT Id, Fon_Sales_Order__r.OrderApi__Total__c FROM BR_Participation__c WHERE Contact__c=:so.OrderApi__Contact__c AND BR_Event__c=:eventId AND Participate__c = 'Yes'];
        if(!tickets.isEmpty()){
            hasTicket = true;
            if(tickets[0].Fon_Sales_Order__r.OrderApi__Total__c>0.0){
                ticketHasPrice = true;
            }
        }

        BR_Event__c evt = [SELECT Id, Limit_of_attendees__c, (SELECT Id FROM BR_Participations__r WHERE Participate__c='Yes') FROM BR_Event__c WHERE Id=: eventId];
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId];
        Map<String, Decimal> tPrice = new Map<String, Decimal>();
        if(lines.isEmpty()) {
            Id contactId = [SELECT Id, OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId].OrderApi__Contact__c;
            List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId];
            if (!users.isEmpty() || users != null) {
                Map<String, AC_Event_User_Segment__c> priceMap = brEventParticipationManager.getTicketPrice(eventId, users[0].Id);
                System.debug('priceMap: ' + priceMap);
                for(String key : priceMap.keySet()){
                    if(priceMap.get(key).Early_Bird_Price__c!=null && Datetime.now() < priceMap.get(key).Early_Bird_Price_Deadline__c) {
                        System.debug('early bird: ');
                        tPrice.put('Early Bird - ' + priceMap.get(key).AC_User_Segment__r.Name, priceMap.get(key).Early_Bird_Price__c);
                    }
                    else if(priceMap.get(key).On_Demand_Price__c!=null && Datetime.now() >= priceMap.get(key).On_Demand_Start_Date__c) {
                        System.debug('on demand: ' + priceMap.get(key).On_Demand_Price__c);
                        tPrice.put('On Demand - ' + priceMap.get(key).AC_User_Segment__r.Name, priceMap.get(key).On_Demand_Price__c);
                    }
                    else{
//                    if(priceMap.get(key).Early_Bird_Price__c==null && priceMap.get(key).On_Demand_Price__c==null) {
                        tPrice.put(priceMap.get(key).AC_User_Segment__r.Name, priceMap.get(key).Price__c);
                    }


                }


            }
        } else {
            Map<String,Decimal> priceMap = getUserSegments(eventId);
            for(String key : priceMap.keySet()){
                if(priceMap.get(key) == lines[0].OrderApi__Sale_Price__c){
                    tPrice.put(key, priceMap.get(key));
                }
            }

            if(tPrice.isEmpty()){
                tPrice.put('COMP', 0.0);
            }
        }

        System.debug('ticketPRice: ' + tPrice);
        Boolean soldOut = evt.Limit_of_attendees__c <= evt.BR_Participations__r.size() && evt.Limit_of_attendees__c!=0;
        System.debug('soldOut: ' + soldOut);

        return new EventTickets(tPrice, soldOut, hasTicket, ticketHasPrice);
    }

    @AuraEnabled
    public static Map<String,Decimal> getUserSegments(String eventId){
        if(String.isBlank(eventId)){
            new AACRCustomException('Null event Id','JP_EventTicketSelectionController.getUserSegments()', 'Back Office Ticketing');
            return null;
        }

        List<AC_Event_User_Segment__c> segments = [SELECT Id, On_Demand_Price__c, On_Demand_Start_Date__c, AC_User_Segment__r.Name, Price__c, Early_Bird_Price__c, Early_Bird_Price_Deadline__c FROM AC_Event_User_Segment__c WHERE AC_Event__c=: eventId];

        Map<String, Decimal> priceMap = new Map<String, Decimal>();
        Date today = System.today();

        for(AC_Event_User_Segment__c segment : segments){
            if(segment.Early_Bird_Price__c!=null){
//                if(segment.Early_Bird_Price_Deadline__c >= Datetime.now()){
                    priceMap.put('Early Bird - ' + segment.AC_User_Segment__r.Name, segment.Early_Bird_Price__c);
//                } else {
//                    priceMap.put(segment.AC_User_Segment__r.Name, segment.Price__c);
//                }
            }
            if(segment.On_Demand_Price__c!=null){
                System.debug('add on demand segment...');
                if(segment.On_Demand_Start_Date__c <= Datetime.now()){
                    priceMap.put('On Demand - ' + segment.AC_User_Segment__r.Name, segment.On_Demand_Price__c);
                } else {
                    priceMap.put(segment.AC_User_Segment__r.Name, segment.Price__c);
                }
            }
            priceMap.put(segment.AC_User_Segment__r.Name, segment.Price__c);
        }
        return priceMap;
    }

    @AuraEnabled
    public static Boolean addTicketToSalesOrder(String salesOrderId, String eventId, Decimal price, String ticketType){

        List<OrderApi__Item__c> ticketItems = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='Live Event Tickets' AND AC_Event__c=: eventId];
        if(ticketItems.isEmpty()){
            new AACRCustomException(eventId, 'Could not find ticket item for event.','JP_EventTicketSelectionController.addTicketToSalesOrder()', 'Back Office Ticketing');
            return false;
        }

        if(ticketType.contains('Early Bird')){
            ticketType = ticketType.replace('Early Bird - ', '');
        }

        List<AC_Event_User_Segment__c> uSegment = [SELECT Id, AC_User_Segment__c FROM AC_Event_User_Segment__c WHERE AC_User_Segment__r.Name =: ticketType AND (Price__c=:price OR Early_Bird_Price__c=:price)];


        List<OrderApi__Sales_Order_Line__c> lines = [SELECT OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId];
        OrderApi__Sales_Order_Line__c sol;
        if(lines.isEmpty()){
            sol = new OrderApi__Sales_Order_Line__c();
            sol.OrderApi__Item__c = ticketItems[0].Id;
            sol.OrderApi__Price_Override__c = true;
            sol.OrderApi__Sale_Price__c = price;
            sol.OrderApi__Sales_Order__c = salesOrderId;
            sol.AC_User_Segment__c = uSegment[0].AC_User_Segment__c;
        } else {
            sol = lines[0];
            sol.OrderApi__Sale_Price__c = price;
            sol.AC_User_Segment__c = uSegment[0].AC_User_Segment__c;
        }

        try{
            upsert sol;

            return true;
        } catch(Exception e){
            System.debug('Could not insert sales order line: ' + e.getMessage());
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Back Office Ticketing');
            return false;
        }

    }

    public class EventTickets{
        @AuraEnabled
        public Map<String, Decimal> priceMap;

        @AuraEnabled
        public Boolean soldOut;

        @AuraEnabled
        public Boolean dupeAlert;

        @AuraEnabled
        public Boolean refundAlert;

        public EventTickets(Map<String, Decimal> pMap, Boolean soldOut, Boolean hasTicket, Boolean ticketHasPrice){
            this.priceMap = pMap;
            this.soldOut = soldOut;
            this.dupeAlert = hasTicket;
            this.refundAlert = ticketHasPrice;
        }
    }


}
/**
 * Created by lauren.lezberg on 11/7/2019.
 */

public with sharing class JP_EventInfoController {



    @AuraEnabled
    public static void createTicketItem(String eventId){
        System.debug('createTicketItem with event: ' + eventId);
        if(eventId!=null) {
            BR_Event__c evt = [SELECT Name, Ticket_Label__c, Income_Account__c, Adjustment_Account__c, A_R_Account__c, Refund_Credit_Account__c FROM BR_Event__c WHERE id = :eventId];
            List<OrderApi__Item_Class__c> iClasses = [SELECT id FROM OrderApi__Item_Class__c WHERE Name = 'Live Event Tickets'];
            if (!iClasses.isEmpty() && iClasses != null) {
                //check if item already exists
                List<OrderApi__Item__c> tickets = [SELECT Id, OrderApi__Income_Account__c, OrderApi__Adjustment_Account__c, OrderApi__Refund_Account__c, OrderApi__AR_Account__c FROM OrderApi__Item__c WHERE AC_Event__c = :eventId];
                if (tickets.isEmpty()) {
                    OrderApi__Item__c eventTicketItem = new OrderApi__Item__c();
                    eventTicketItem.AC_Event__c = eventId;
                    eventTicketItem.Name = evt.Ticket_Label__c + ' Ticket';
                    eventTicketItem.Portal_Label__c = evt.Name + ' Ticket';
                    eventTicketItem.OrderApi__Is_Active__c = true;
                    eventTicketItem.OrderApi__Is_Event__c = true;
                    eventTicketItem.OrderApi__Item_Class__c = iClasses[0].id;
                    eventTicketItem.OrderApi__Income_Account__c = evt.Income_Account__c;
                    eventTicketItem.OrderApi__Adjustment_Account__c = evt.Adjustment_Account__c;
                    eventTicketItem.OrderApi__AR_Account__c = evt.A_R_Account__c;
                    eventTicketItem.OrderApi__Refund_Account__c = evt.Refund_Credit_Account__c;
                    eventTicketItem.OrderApi__Image_Path__c = null;

                    try {
                        insert eventTicketItem;
                    } catch (Exception e) {
                        new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Event Builder');
                    }

                } else {
                    tickets[0].OrderApi__Income_Account__c = evt.Income_Account__c;
                    tickets[0].OrderApi__Adjustment_Account__c = evt.Adjustment_Account__c;
                    tickets[0].OrderApi__AR_Account__c = evt.A_R_Account__c;
                    tickets[0].OrderApi__Refund_Account__c = evt.Refund_Credit_Account__c;

                    try {
                        update tickets[0];
                    } catch (Exception e) {
                        new AACRCustomException(eventId,e.getMessage(), e.getStackTraceString(), 'Event Builder');
                    }
                }
            } else {
                new AACRCustomException('Could not find item class Live Event Tickets.' , 'JP_EventInfoController.createTicketItem()', 'Event Builder');
            }
        } else {
            new AACRCustomException('Null event Id','JP_EventInfoController.createTicketItem()', 'Event Builder');
        }

    }

    /**
     * @purpose Get default zone
     *
     * @return zone id
     */
    @AuraEnabled
    public static String getZone(){
        List<BR_Events_Zone__c> zones = [SELECT Id FROM BR_Events_Zone__c WHERE Is_Default__c = true LIMIT 1];
//        System.debug('---zones: ' + zones);
        if(!zones.isEmpty()){
            return zones[0].Id;
        } else {
            new AACRCustomException('Could not find default zone.', 'JP_EventInfoController.getZone()', 'Event Builder');
        }

        return null;

    }


    /**
     * @purpose Get venue info based on venue id
     *
     * @param venueId
     *
     * @return Venue__c object
     */
    @AuraEnabled
    public static Venue__c getVenue(String venueId){
        List<Venue__c> venues = [SELECT Street_1__c, Street_2__c, Street_3__c, City__c, State__c, Country__c, Zip__c FROM Venue__c WHERE Id=: venueId];
//        System.debug('---venues: ' + venues);
        if(venues.isEmpty()){
            return null;
        }
        return venues[0];
    }


}
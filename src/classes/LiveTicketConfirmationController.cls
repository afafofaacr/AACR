/**
 * Created by lauren.lezberg on 10/5/2020.
 */

public without sharing class LiveTicketConfirmationController {
    public BR_Event__c evt { get; set; }
    public String receiptId { get; set; }
    public String location {get;set;}
    public String StartDate {get;set;}
    public String EndDate {get;set;}

    public LiveTicketConfirmationController() {
        String salesOrderId = ApexPages.currentPage().getParameters().get('salesOrder');
        receiptId = ApexPages.currentPage().getParameters().get('receipt');
        if(receiptId==null){
            List<OrderApi__Receipt__c> recs = [SELECT Id FROM OrderApi__Receipt__c WHERE OrderApi__Sales_Order__c=:salesOrderId];
            receiptId = recs[0].Id;
        }
        List<OrderApi__Sales_Order_Line__c> ticketLines = [SELECT Id, OrderApi__Item__r.AC_Event__c, OrderApi__Item__r.AC_Event__r.Parent_Event__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item_Class__r.Name = 'Live Event Tickets'];

        if (ticketLines.size() == 1) {
            evt = [SELECT Name, Id, Virtual_Venue__c, Portal_Event_Link__c, Display_on_Confirmation_Page__c , Show_Confirmation_Page_Logos__c, View_Confirmation_Page_Horizontally__c,
                            Ticket_Purchase_Confirmation_Message__c, Main_Image_Filename__c, Start_Date__c, End_Date__c, Description__c, Venue__c,
                            Venue__r.Name, Draft_Program__c
                    FROM BR_Event__c
                    WHERE Parent_Event__c=null
                    AND Id = :ticketLines[0].OrderApi__Item__r.AC_Event__c];
            //Create short datetime format in guest timezone for AddToCalendar cmp
            StartDate = evt.Start_Date__c.format();
            EndDate  = evt.End_Date__c.format();



//            TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
//            Integer offsetSeconds = targetTimezone.getOffset(evt.Start_Date__c) / 1000;
//            Datetime targetDatetime = evt.Start_Date__c.addSeconds(offsetSeconds);
//            evt.Start_Date__c = targetDatetime;
//
//            offsetSeconds = targetTimezone.getOffset(evt.End_Date__c) / 1000;
//            targetDatetime = evt.End_Date__c.addSeconds(offsetSeconds);
//            evt.End_Date__c = targetDatetime;

            if(evt.Virtual_Venue__c == null){
                location = evt.Venue__r.Name;
            }else{
                location = 'https://' + evt.Portal_Event_Link__c;
            }
        } else {
            OrderApi__Sales_Order_Line__c ticketLine;
            for(OrderApi__Sales_Order_Line__c line : ticketLines){
                if(line.OrderApi__Item__r.AC_Event__r.Parent_Event__c == null){
                    ticketLine = line;
                }
            }
            evt = [SELECT Name, Id, Virtual_Venue__c, Portal_Event_Link__c, Display_on_Confirmation_Page__c , Show_Confirmation_Page_Logos__c, View_Confirmation_Page_Horizontally__c,Ticket_Purchase_Confirmation_Message__c, Main_Image_Filename__c, Start_Date__c, End_Date__c, Description__c, Venue__c, Venue__r.Name, Draft_Program__c FROM BR_Event__c WHERE Parent_Event__c=null AND Id = :ticketLine.OrderApi__Item__r.AC_Event__c];
            StartDate = evt.Start_Date__c.format();
            EndDate  = evt.End_Date__c.format();
            if(evt.Virtual_Venue__c == null){
                location = evt.Venue__r.Name;
            }else{
                location = 'https://' + evt.Portal_Event_Link__c;
            }
        }
    }

    public PageReference checkExhibitStatus(){
        String salesOrderId = ApexPages.currentPage().getParameters().get('salesOrder');
        List<OrderApi__Sales_Order_Line__c> ticketLines = [SELECT Id, OrderApi__Sales_Order__r.OrderApi__Contact__c, OrderApi__Item__r.AC_Event__c, OrderApi__Item__r.AC_Event__r.Parent_Event__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item_Class__r.Name = 'Live Event Tickets'];
        OrderApi__Sales_Order_Line__c ticketLine;
        for(OrderApi__Sales_Order_Line__c line : ticketLines){
            if(line.OrderApi__Item__r.AC_Event__r.Parent_Event__c == null){
                ticketLine = line;
            }
        }
        evt = [SELECT Name, Id, Display_on_Confirmation_Page__c, Show_Confirmation_Page_Logos__c, View_Confirmation_Page_Horizontally__c, Virtual_Venue__c, Virtual_Venue__r.Name, Virtual_Venue__r.Integration_Controller__c, Portal_Event_Link__c, Ticket_Purchase_Confirmation_Message__c, Main_Image_Filename__c, Start_Date__c, End_Date__c, Description__c, Venue__c, Venue__r.Name, Draft_Program__c FROM BR_Event__c WHERE Parent_Event__c=null AND Id = :ticketLines[0].OrderApi__Item__r.AC_Event__c];
        if(evt.Virtual_Venue__c!=null) { //if virtual event

            List<Virtual_Event_Details__c> veds = [SELECT Exhibit_Open__c
                                            FROM Virtual_Event_Details__c
                                            WHERE Event__c = :ticketLines[0].OrderApi__Item__r.AC_Event__c];
            if(veds.size()==1){
                if(veds[0].Exhibit_Open__c){//if exhibit open, send user to event
                    Callable extension = (Callable) Type.forName(evt.Virtual_Venue__r.Integration_Controller__c).newInstance();
                    String evtURL = (String) extension.call('goToVenue', new Map<String, Object>{
                            'contactId' => (String) ticketLine.OrderApi__Sales_Order__r.OrderApi__Contact__c, 'SFEventId' => evt.Id
                    });
                    System.debug('evtURL: ' + evtURL);
                    if(evt.Virtual_Venue__r.Name == 'Freeman'){
                        return new PageReference('/FreemanRedirect?venueURL=' + evtURL);
                    } else {
                        return new PageReference(evtURL);
                    }
                }
            }

        }

        return null;
    }

}
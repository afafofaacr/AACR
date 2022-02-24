/**
 * Created by mitfity on 20.08.2019.
 */

public with sharing class brSalesOrderTriggerHandler {

    public brSalesOrderTriggerHandler() {
        if (!Trigger.isExecuting) {
            throw new brEventsException('This code must run in trigger context only');
        }
    }

    public void approveBoughtTickets(List<OrderApi__Sales_Order__c> orders, Map<Id, OrderApi__Sales_Order__c> oldMap) {
        System.debug('approveBOughtTickets...');
        List<OrderApi__Sales_Order__c> closedOrders = new List<OrderApi__Sales_Order__c>();
        Set<Id> closedOrderIds = new Set<Id>();



        for (OrderApi__Sales_Order__c order : orders) {
            OrderApi__Sales_Order__c oldOrder = oldMap.get(order.Id);

            if (oldOrder.OrderApi__Posting_Status__c!='Posted' && order.OrderApi__Status__c == 'Closed' && order.OrderApi__Posting_Status__c == 'Posted') {
                closedOrders.add(order);
                closedOrderIds.add(order.Id);
            }
        }

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__r.AC_Event__c, AC_User_Segment__c, OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c IN: closedOrderIds];
        Map<Id, Id> lineSegmentMap = new Map<Id,Id>();
        for(OrderApi__Sales_Order_Line__c line : lines){
            lineSegmentMap.put(line.OrderApi__Sales_Order__c, line.AC_User_Segment__c);
        }

        List<BR_Participation__c> participations = [
                SELECT Participate__c, Fon_Sales_Order__c, BR_Event__c, AC_User_Segment__c
                FROM BR_Participation__c
                WHERE Fon_Sales_Order__c IN :closedOrderIds
        ];

        if(!participations.isEmpty()) {
            Map<Id, BR_Participation__c> salesOrderIdToParticipation = new Map<Id, BR_Participation__c>();
            List<BR_Participation__c> participationsToUpdate = new List<BR_Participation__c>();


            for (BR_Participation__c participation : participations) {
//                salesOrderIdToParticipation.put(participation.Fon_Sales_Order__c, participation);
                if (participation.Participate__c != 'Yes') {
                    participation.Participate__c = 'Yes';
                    if(participation.AC_User_Segment__c == null) {
                        participation.AC_User_Segment__c = lineSegmentMap.get(participation.Fon_Sales_Order__c);
                    }
                } else {
                    participation.AC_User_Segment__c = lineSegmentMap.get(participation.Fon_Sales_Order__c);
                }
                participationsToUpdate.add(participation);
            }


//            for (OrderApi__Sales_Order__c order : closedOrders) {
//                BR_Participation__c participation = salesOrderIdToParticipation.get(order.Id);
//
//                if (participation.Participate__c != 'Yes') {
//                    participation.Participate__c = 'Yes';
//                    participation.AC_User_Segment__c = lineSegmentMap.get(order.Id);
//                } else {
//                    participation.AC_User_Segment__c = lineSegmentMap.get(order.Id);
//                }
//                participationsToUpdate.add(participation);
//            }

            update participationsToUpdate;
        }
    }

    /**
     * Approves bought tickets for closed sales orders.
     *
     * @param orders
     * @param oldMap
     */
//    public void approveBoughtTickets(List<AACR_Sales_Order__c> orders, Map<Id, AACR_Sales_Order__c> oldMap) {
//        List<AACR_Sales_Order__c> closedOrders = new List<AACR_Sales_Order__c>();
//        Set<Id> closedOrderIds = new Set<Id>();
//
//        for (AACR_Sales_Order__c order : orders) {
//            AACR_Sales_Order__c oldOrder = oldMap.get(order.Id);
//
//            if (oldOrder.Status__c == 'Open' && order.Status__c == 'Closed') {
//                closedOrders.add(order);
//                closedOrderIds.add(order.Id);
//            }
//        }
//
//        List<BR_Participation__c> participations = [
//                SELECT Participate__c, AACR_Sales_Order__c
//                FROM BR_Participation__c
//                WHERE AACR_Sales_Order__c IN :closedOrderIds
//        ];
//        Map<Id, BR_Participation__c> salesOrderIdToParticipation = new Map<Id, BR_Participation__c>();
//
//
//        for (BR_Participation__c participation : participations) {
//            salesOrderIdToParticipation.put(participation.AACR_Sales_Order__c, participation);
//        }
//
//
//        List<BR_Participation__c> participationsToUpdate = new List<BR_Participation__c>();
//        for (AACR_Sales_Order__c order : closedOrders) {
//            BR_Participation__c participation = salesOrderIdToParticipation.get(order.Id);
//
//            if (participation.Participate__c != 'Yes') {
//                participation.Participate__c = 'Yes';
//                participationsToUpdate.add(participation);
//            }
//        }
//
//        update participationsToUpdate;
//    }
}
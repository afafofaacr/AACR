/**
 * Created by lauren.lezberg on 3/18/2020.
 */
({
    doInit : function(cmp, event, helper){

        var salesOrderId = helper.getSalesOrderId(cmp);
        cmp.set("v.salesOrderId", salesOrderId);

        if(salesOrderId!=null) {
            var action = cmp.get("c.getEventId");
            action.setParams({
                "salesOrderId": salesOrderId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    // console.log('data: ' + data);
                    if(data!=null) {
                        cmp.set("v.eventId", data);
                        cmp.find("eventLookup").refreshLookup();
                    }
                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout: doInit');
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("doInit - Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("doInit - Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    // compTicket : function(cmp, event, helper){
    //     cmp.set("v.ticketPrice", 0);
    //     cmp.set("v.ticketType", 'COMP');
    // },


    getTicketPrice : function(cmp, event, helper){
        var salesOrderId = helper.getSalesOrderId(cmp);

        var action = cmp.get("c.getUserTicketPrice");
        action.setParams({
            "eventId": cmp.get("v.eventId"),
            "salesOrderId": salesOrderId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));

                if(data!=null) {
                    var conts = data.priceMap;
                    for (var key in conts) {
                        cmp.set("v.ticketType", key);
                        cmp.set("v.ticketPrice", conts[key]);
                    }

                    cmp.set("v.soldOut", data.soldOut);
                    cmp.set("v.dupeAlert", data.dupeAlert);
                    cmp.set("v.refundAlert", data.refundAlert);
                }

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: getTicketPrice');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("getTicketPrice - Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("getTicketPrice - Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    selectTicketType : function(cmp,event, helper){
        var selectedItem = event.getSource().get("v.value");

        var segments = cmp.get("v.eventSegments");
        segments.forEach(function(segment){
           if(selectedItem == segment.key){
               cmp.set("v.ticketPrice", segment.value);
               cmp.set("v.ticketType", segment.key);
           }
        });

        cmp.set("v.eventSegments", []);

    },

    getPriceMap : function(cmp, event, helper){
        var action = cmp.get("c.getUserSegments");
        action.setParams({
            "eventId": cmp.get("v.eventId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var custs = [];
                var conts = response.getReturnValue();

                    for (var key in conts) {
                        custs.push({value: conts[key], key: key});
                    }

                if(custs.length>0) { 
                    cmp.set("v.eventSegments", custs);
                } else {
                    helper.showToast(cmp, event, 'error', 'There are no other available prices for this event.');
                }

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete Callout - getPriceMap");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("getPriceMap - Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("getPriceMap - Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.eventSegments", []);
    },

    onStepChange : function(cmp,event,helper){
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if(!cmp.get("v.processing")) {
            cmp.set("v.processing", true);
            var action = cmp.get("c.addTicketToSalesOrder");
            action.setParams({
                "salesOrderId": helper.getSalesOrderId(cmp),
                "eventId": cmp.get("v.eventId"),
                "price": cmp.get("v.ticketPrice"),
                "ticketType": cmp.get("v.ticketType")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    // console.log('data: ' + JSON.stringify(data));
                    if (data) {
                        // helper.addEventIdToURL(cmp, cmp.get("v.eventId"));

                        var navEvt = $A.get("e.c:JP_NavigateEvt");
                        navEvt.setParams({"stepId": stepId});
                        navEvt.setParams({"cmpName": cmpName});
                        navEvt.fire();
                    } else {
                        var navEvt = $A.get("e.c:JP_NavigateEvt");
                        navEvt.setParams({"stepId": stepId});
                        navEvt.setParams({"cmpName": null});
                        navEvt.fire();
                    }

                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete Callout - onStepChange");
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("onStepChange - Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("onStepChange - Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }

    }



})
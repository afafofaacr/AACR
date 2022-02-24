/**
 * Created by lauren.lezberg on 10/9/2019.
 */
({
    initialize : function(cmp, event){
        console.log('initializing BackOfficeCheckout...');
        cmp.set("v.isModify", this.getIsModify(cmp));

        var action = cmp.get("c.getCartItems");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cartData = response.getReturnValue();
                cmp.set("v.salesOrder", cartData.SO);
                var context = this;
                window.addEventListener("message", $A.getCallback(function(event) {
                    if (event.origin !== cartData.vfHostName) {
                        // Not the expected origin: Reject the message!
                        return;
                    } else {
                        // expected origin : cancel order
                        context.cancelOrder(cmp);
                    }
                }), false);

                //get checkout data
                var data = cartData.items;

                var membershipItem;
                var cartItems = [];
                var taxTotal = 0.0;
                var subTotal = 0.0;


                if(cartData.items.length>0) {
                    var fullTotal = data[0].OrderApi__Sales_Order__r.OrderApi__Total__c;

                    //separate cart items from tax items and add up tax total;
                    data.forEach(function (record) {
                        if (record.OrderApi__Item_Class__r.Name == 'Individual Memberships') {
                            membershipItem = record;
                            subTotal += record.OrderApi__Sale_Price__c;
                        } else {
                            if (record.OrderApi__Item_Class__r.Name == 'Tax Class') {
                                taxTotal += record.OrderApi__Sale_Price__c;
                            } else {
                                subTotal += record.OrderApi__Sale_Price__c;
                                if (record.OrderApi__Item_Class__r.Name != 'ZDecline of the Journals' && record.OrderApi__Item_Class__r.Name != 'Tax Class') {
                                    cartItems.push(record);
                                }
                            }
                        }
                    });

                    //move membership to front of line
                    if (membershipItem != null) {
                        cartItems.unshift(membershipItem);
                    }


                    //Check for $0 payment to show payment form or process order button
                    if (fullTotal > 0) {
                        cmp.set("v.showPayment", true);
                    } else {
                        cmp.set("v.showPayment", false);
                    }
                    //add discount code if already present in sales order
                    if (data[0].OrderApi__Sales_Order__r.OrderApi__Source_Code__c != null) {
                        cmp.set("v.discountCode", data[0].OrderApi__Sales_Order__r.OrderApi__Source_Code__r.Name);
                        cmp.set("v.discountApplied", true);
                    }
                }

                //set checkout attributes
                cmp.set("v.cartItems", cartItems);
                cmp.set("v.taxTotal", taxTotal);
                cmp.set("v.subTotal", subTotal);
                cmp.set("v.fullTotal", fullTotal);
                cmp.set("v.processing", false);

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve cart item data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve cart item data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve cart item data: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Cancels sales order by deleting it and redirecting user to join process cancel url or navigating back in window history if none exists
     * @param cmp
     * @param event
     * @param helper
     */
    cancelOrder : function(cmp){
        console.log('Canceling order...');
        var action = cmp.get("c.deleteSalesOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cancelURL = response.getReturnValue();
                if(cancelURL!=null){
                    window.location.href = cancelURL;
                } else {
                    window.history.back();
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not cancel order: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not cancel order - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not cancel order: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    getIsModify : function(cmp){
        //get sales order id from URL
        var name ='c__isModify';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            if(results[1] == 'true'){
                return true;
            } else {
                return false;
            }
        }

        return false;


    },


    getSalesOrderId : function(cmp){
        //get sales order id from URL
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId;
        if(results==null){
            name ='c__salesOrder';
            name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            name = name.toLowerCase();
            regexS = "[\\?&]"+name+"=([^&#]*)";
            regex = new RegExp( regexS, "i" );
            results = regex.exec( url );
            SOId=results[1];
        } else {
            SOId=results[1];
        }

        return SOId;
    },

    getJoinId : function(cmp){
        //get join id from URL
        var name ='id';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId;
        if(results==null){
            name ='c__id';
            name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            name = name.toLowerCase();
            regexS = "[\\?&]"+name+"=([^&#]*)";
            regex = new RegExp( regexS, "i" );
            results = regex.exec( url );
            SOId=results[1];
        } else {
            SOId=results[1];
        }

        return SOId;
    },
})
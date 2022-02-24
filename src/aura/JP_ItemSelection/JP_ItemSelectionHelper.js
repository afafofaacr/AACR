/**
 * Created by lauren.lezberg on 1/8/2019.
 */
({
    initialize : function(cmp, event, stepId){
        console.log('JP_ItemSelection initialize...');

        var soId = this.getSalesOrderId(cmp);
        // var action = cmp.get("c.getProductData");
        var action = cmp.get("c.getMembershipData");
        action.setParams({
            "SOId" : soId,
            "stepId": cmp.get("v.stepId"),
            "itemId" : this.getItemId(cmp)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var membershipData = response.getReturnValue();
                var data = membershipData.lines;
                var total = 0.0;
                cmp.set("v.lines", data);
                cmp.set("v.isLoading", false);
                var isEmeritus = false;
                var hasEmeritusDues = false;

                var nextYearAdded = false;
                var thisYearOnly = false;
                var nextYearOnly = false;

                data.forEach(function (line) {
                    if(line.OrderApi__Item__r.Name=='Emeritus Membership'){
                        isEmeritus = true;
                        membershipData.canPurchaseNextYear = false;
                    }
                    if (line.OrderApi__Item__r.Name=='Emeritus Voluntary Assessment'){
                        hasEmeritusDues = true;
                    }
                    total += line.OrderApi__Sale_Price__c;

                    if(membershipData.canPurchaseNextYear) {
                            if (line.OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c == 365) {
                                nextYearAdded = true;
                            } else {
                                var myDateArray = line.OrderApi__Activation_Date__c.split("-");
                                var theDate = new Date(myDateArray[0], myDateArray[1] - 1, myDateArray[2]);
                                if (theDate.getFullYear() == cmp.get("v.currentYear")) {
                                    thisYearOnly = true;
                                } else {
                                    nextYearOnly = true;
                                }
                            }

                    }
                });
                cmp.set("v.total", total);
                cmp.set("v.bothYears", nextYearAdded);
                cmp.set("v.thisYearOnly", thisYearOnly);
                cmp.set("v.nextYearOnly", nextYearOnly);

                var priceMap = membershipData.priceMap;
                if(priceMap!=null) {
                    cmp.set("v.singlePrice", priceMap[1]);
                    cmp.set("v.doublePrice", priceMap[2]);
                }

                cmp.set("v.isEmeritus", isEmeritus);
                cmp.set("v.hasVoluntaryDues", hasEmeritusDues);
                cmp.set("v.voluntaryAssessment", membershipData.voluntaryAssessment);
                cmp.set("v.renewalsOpen", membershipData.canPurchaseNextYear);
                cmp.set("v.voluntaryAssessment", membershipData.voluntaryAssessment);

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },

    saveSalesOrder : function(cmp, nextStepId, nextCmpName){
        console.log('JP_ItemSelection saveSalesOrder...');

        var soId = this.getSalesOrderId(cmp);
        // var action = cmp.get("c.getProductData");
        var action = cmp.get("c.saveEmeritusDues");
        action.setParams({
            "hasEmeritusDues": cmp.get("v.hasVoluntaryDues"),
            "salesOrderId" : soId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId" : nextStepId});
                navEvt.setParams({"cmpName" : nextCmpName});
                navEvt.fire();

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Retrieves salesOrder id parameter from URL
     * @param cmp
     * @returns {string}
     */
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
        if(results!=null){
            SOId = results[1];
        }

        return SOId;
    },

    /**
     * @purpose Retrieves offerCode parameter from URL
     * @param cmp
     * @returns {string}
     */
    getOffer : function(cmp){
        //get sales order id from URL
        var name ='c__OfferCode';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId;
        if(results!=null){
            SOId = results[1];
        }

        return SOId;
    },

    /**
     * @purpose Retrieves salesOrder id parameter from URL
     * @param cmp
     * @returns {string}
     */
    getItemId : function(cmp){
        //get sales order id from URL
        var name ='item';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId;
        if(results!=null){
            SOId = results[1];
        }

        return SOId;
    },

    /**
     * @purpose Retrieves isRenew parameter from URL
     * @param cmp
     * @returns {string}
     */
    getIsRenew : function(cmp){
        //get is renew flag from URL
        var name ='isRenew';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var isRenew;
        if(results!=null){
            isRenew = results[1];
        }

        return isRenew;
    },



})
/**
 * Created by lauren.lezberg on 8/23/2019.
 */
({
    /**
     * @purpose Retrieve sales order parameter from page URL
     * @param cmp
     * @returns {*}
     */
    getSalesOrderId : function(cmp){ 
        var name ='c__salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },


    /**
     * @purpose Retrieve isRenew parameter from page URL
     * @param cmp
     * @returns {*}
     */
    getIsRenew : function(cmp){
        var name ='c__isRenew';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            if(results[1]=='true'){
                return true;
            } else {
                return false;
            }
        }
        return null;
    },

    getTermOpts : function(cmp){
        var membershipItemId = '';

        var lines = cmp.get("v.salesOrderLines");
        lines.forEach(function(line){
            if(line.OrderApi__Item_Class__r.Name=='Individual Memberships'){
                membershipItemId = line.OrderApi__Item__c;
            }
        });

        if(membershipItemId!='') {

            var action = cmp.get("c.getTermOptions");
            action.setParams({
                "membershipItemId": membershipItemId,
                "salesOrderId": this.getSalesOrderId(cmp),
                "isRenew": cmp.get("v.isRenewal")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();

                    var managedMembership = false;
                    var subPlanId;
                    lines.forEach(function (line) {
                        //set subPlanId for memberships except honorary and lifetime
                        if (line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && !line.OrderApi__Item__r.Name.includes('Emeritus') && !line.OrderApi__Item__r.Name.includes('Honorary')) {

                            cmp.set("v.subPlanId", line.OrderApi__Subscription_Plan__c);
                            if (line.OrderApi__Item__r.Managed__c) {
                                managedMembership = true;
                            }
                        }
                    });

                    if (managedMembership) {
                        var termOptions = [];
                        var selectedTerm = null;
                        data.forEach(function (term) {
                            cmp.get("v.salesOrderLines").forEach(function (line) {
                                if (line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && !line.OrderApi__Item__r.Name.includes('Emeritus') && !line.OrderApi__Item__r.Name.includes('Honorary')) {
                                    if (line.OrderApi__Subscription_Plan__c == term.subPlanId && term.termYear.includes(new Date(line.OrderApi__Activation_Date__c).getUTCFullYear())) {
                                        selectedTerm = term.termYear;
                                    }
                                }
                            });
                            var option = {};
                            option.label = term.termYear;
                            option.value = term.termYear;
                            option.id = term.subPlanId;
                            termOptions.push(option);
                        });
                        if (selectedTerm != null) {
                            cmp.set("v.termValue", selectedTerm);
                        }

                        cmp.set("v.termOptions", termOptions);
                    } else {
                        cmp.set("v.termValue", data[0].termYear);
                    }
                    cmp.set("v.isLoading", false);
                } else if (state === "INCOMPLETE") {
                    console.log('Could not retrieve data: Incomplete Callout');
                    cmp.set("v.processing", false);
                    cmp.set("v.isLoading", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Could not retrieve data - Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Could not retrieve data: Unknown error");
                    }
                    cmp.set("v.processing", false);
                    cmp.set("v.isLoading", false);
                }

            });
            $A.enqueueAction(action);
        }
    }
})
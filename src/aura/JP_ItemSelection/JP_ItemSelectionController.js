/**
 * Created by lauren.lezberg on 1/8/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('JP_ItemSelection init...');

        var name ='id';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var stepId=results[1];

        var date = new Date();
        cmp.set("v.currentYear", date.getFullYear());
        cmp.set("v.nextYear", date.getFullYear() + 1);

        var isRenew = helper.getIsRenew(cmp);
        if(isRenew!=null){
            var trueVal = 'true';
            if(isRenew == trueVal.ignoreCase){
                cmp.set("v.isRenew", true);
            } else {
                cmp.set("v.isRenew", false);
            }
        } else {
            cmp.set("v.isRenew",false);
        }

        helper.initialize(cmp, event, stepId);

    },

    removeVoluntaryDues : function(cmp, event){
        console.log('JP_ItemSelection removeVoluntaryDues...');

        cmp.set("v.hasVoluntaryDues", false);
    },

    addVoluntaryDues : function(cmp, event){
        console.log('JP_ItemSelection addVoluntaryDues...');

        cmp.set("v.hasVoluntaryDues", true);
    },


    /**
     * @purpose Finds subscription plan information from selection and calls apex method to change subscription plan for all sales order lines in the sales order
     * @param cmp
     * @param event
     * @param helper
     */
    changeTerm : function(cmp, event, helper){
        console.log('JP_ItemSelection changeTerm...');

        if(helper.getOffer(cmp)!=null){
            cmp.set("v.msg", 'Changing your selections may affect the applied offer.');
        } else {
            cmp.set("v.msg", null);
        }

        var selectedTerm = event.getSource().get("v.value");

        $A.util.removeClass(cmp.find("thisYear"), 'selected');
        $A.util.removeClass(cmp.find("nextYear"), 'selected');
        $A.util.removeClass(cmp.find("bothYears"), 'selected');

        cmp.set("v.changingTerm", true);
        var activationYear = cmp.get("v.currentYear");
        var yearsOfMembership = 1;
        if(selectedTerm == 'thisYear'){
            cmp.set("v.thisYearOnly", true);
            cmp.set("v.nextYearOnly", false);
            cmp.set("v.bothYears", false);
        } else if(selectedTerm == 'nextYear'){
            cmp.set("v.thisYearOnly", false);
            cmp.set("v.nextYearOnly", true);
            cmp.set("v.bothYears", false);
            activationYear = cmp.get("v.nextYear");
        } else {
            cmp.set("v.thisYearOnly", false);
            cmp.set("v.nextYearOnly",false );
            cmp.set("v.bothYears", true);
            yearsOfMembership = 2;
        }

        var action = cmp.get("c.addNextMembershipTerm");
        action.setParams({
            "SOId" : helper.getSalesOrderId(cmp),
            "activationYear" : activationYear,
            "subYears" : yearsOfMembership
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var membershipData = response.getReturnValue();
                var data = membershipData.lines;
                var total = 0.0;
                cmp.set("v.lines", data);

                var nextYearAdded = false;
                var thisYearOnly = false;
                var nextYearOnly = false;
                data.forEach(function (line) {
                    total += line.OrderApi__Sale_Price__c;
                    if(cmp.get("v.renewalsOpen")) {
                        if (line.OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c == 365) {
                            nextYearAdded = true;
                        } else {
                            var myDateArray = line.OrderApi__Activation_Date__c.split("-");
                            var theDate = new Date(myDateArray[0],myDateArray[1]-1,myDateArray[2]);
                            if(theDate.getFullYear() == cmp.get("v.currentYear")){
                                thisYearOnly = true;
                            } else {
                                nextYearOnly = true;
                            }
                        }
                    }
                });
                cmp.set("v.total", total);

                // cmp.set("v.bothYears", nextYearAdded);
                // cmp.set("v.thisYearOnly", thisYearOnly);
                // cmp.set("v.nextYearOnly", nextYearOnly);

                // cmp.set("v.renewalsOpen", membershipData.canPurchaseNextYear);
                cmp.set("v.changingTerm", false);
                $A.util.addClass(cmp.find(selectedTerm), 'selected');
                console.log('done changing term...');
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
     * @purpose Handles Join Process stepchange event and fires navigate event to move forward or backward in process 
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave : function(cmp, event, helper){
        console.log('JP_ItemSelection handleSave...');

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");
        cmp.set("v.isLoading", true);

        if(cmp.get("v.isEmeritus")){
            helper.saveSalesOrder(cmp, stepId, cmpName);
        } else {
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId" : stepId});
            navEvt.setParams({"cmpName" : cmpName});
            navEvt.fire();
        }
    }


})
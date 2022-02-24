/**
 * Created by lauren.lezberg on 3/7/2019.
 */
({

    handleNavigate : function(cmp, event, helper){
        console.log('JP_Container handleNavigate...');

        var currentStepId = cmp.get("v.currentStepId");

        //Get data from event
        var stepId = event.getParam("stepId");
        // console.log('Event: stepId ' + stepId);
        var componentName = event.getParam("cmpName");
        // console.log('Event: componentName: ' + componentName);

        // Dynamically create component for specified stepId
        if(componentName!=null && (cmp.get("v.isInitialStep") || currentStepId!=stepId)) {
            if(cmp.get("v.isInitialStep")){
                cmp.set("v.isInitialStep", false);
            }

            cmp.set("v.stepCmp", []);

            $A.createComponent(
                "c:" + componentName,
                {
                    "stepId": stepId,
                    "aura:id": 'stepCmp'
                },
                function (stepCmp, status, errorMessage) {
                    //Add the new button to the body array
                    if (status === "SUCCESS") {
                        var cmpInput = cmp.get("v.stepCmp");
                        cmpInput.push(stepCmp);
                        cmp.set("v.stepCmp", cmpInput);
                    } else if (status === "INCOMPLETE") {
                        console.log("Could not create component: No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("Could not create component: Error - " + errorMessage);
                    }
                });
            cmp.set("v.currentStepId", stepId);
        } else {
            cmp.set("v.currentStepId", stepId);
        }
    },

    closeOfferModal : function(cmp, event, helper){

        $A.util.removeClass(cmp.find('toastMsg'), 'slds-show');
        $A.util.addClass(cmp.find('toastMsg'), 'slds-hide');
    },

    closeErrorModal : function(cmp, event, helper){
        console.log('JP_Container closeErrorModal...');

        $A.util.removeClass(cmp.find('errorToastMsg'), 'slds-show');
        $A.util.addClass(cmp.find('errorToastMsg'), 'slds-hide');
    },

    handleCodeSuccess : function(cmp, event, helper){
        console.log('handleCodeSuccess Aura');

            var result = {};
            result.sourceCodeId = event.getParam("sourceCodeId");
            result.validationResult = event.getParam("result");
            result.offerMembershipId = event.getParam("membershipId");
            result.usedMode = event.getParam("usedMode");

            console.log("result: " + JSON.stringify(result));



        if(result.validationResult==true) {

        var salesOrderId = helper.getSalesOrderId(cmp);

            var action = cmp.get("c.applyOffer");
            action.setParams({
                "sourceCodeId": result.sourceCodeId,
                "salesOrderId": salesOrderId,
                "offerMembershipId" : result.offerMembershipId,
                "usedMode" : result.usedMode,
                "joinId" : helper.getJoinId(cmp)
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    console.log('data: ' + JSON.stringify(data));

                    result.applied = true;
                    cmp.set("v.vResult", result);

                    $A.util.removeClass(cmp.find('toastMsg'), 'slds-hide');
                    $A.util.addClass(cmp.find('toastMsg'), 'slds-show');

                    if(salesOrderId==null && data.salesOrderId!=null){
                        var key = 'salesOrder';
                        var value = data.salesOrderId;
                        var kvp = document.location.search.substr(1).split('&');
                        // console.log('kvp: ', kvp);
                        var i = kvp.length;
                        var x;
                        while (i--) {
                            x = kvp[i].split('=');

                            if (x[0] == key) {
                                x[1] = value;
                                kvp[i] = x.join('=');
                                break;
                            }
                        }

                        if (i < 0) {
                            kvp[kvp.length] = [key, value].join('=');
                        }

                        window.history.pushState({urlPath:'JP_Container?' + kvp.join('&')}, document.title,'JP_Container?'+kvp.join('&'));
                        if(data.refresh) {
                            window.location.reload();
                        }
                    }


                } else if (state === "INCOMPLETE") {
                    // do something
                    console.log('incomplete...');
                    result.applied = false;
                    cmp.set("v.vResult", result);
                } else if (state === "ERROR") {
                    console.log('error...');
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    result.applied = false;
                    cmp.set("v.vResult", result);
                }
            });
            $A.enqueueAction(action);
        } else {
            result.applied = false;
            cmp.set("v.vResult", result);
        }


    },

    handleCodeError : function(cmp, event, helper){
        console.log('handleCodeError Aura');
        var result = {};
        result.sourceCodeId = event.getParam("sourceCodeId");
        result.validationResult = event.getParam("result");
        result.offerMembershipId = event.getParam("membershipId");
        result.usedMode = event.getParam("usedMode");
        result.applied = false;
        result.errorMsg = event.getParam("errorMsg");

        console.log("result: " + JSON.stringify(result));

        cmp.set("v.vResult", result);

        var salesOrderId = helper.getSalesOrderId(cmp);
        console.log('salesOrder: ' + salesOrderId);
        if(salesOrderId==null){
            var action = cmp.get("c.startOrder");
            action.setParams({
                "joinId" : helper.getJoinId(cmp)
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    // console.log('data: ' + JSON.stringify(data));

                    if(salesOrderId==null && data.salesOrderId!=null){
                        var key = 'salesOrder';
                        var value = data.salesOrderId;
                        var kvp = document.location.search.substr(1).split('&');
                        // console.log('kvp: ', kvp);
                        var i = kvp.length;
                        var x;
                        while (i--) {
                            x = kvp[i].split('=');

                            if (x[0] == key) {
                                x[1] = value;
                                kvp[i] = x.join('=');
                                break;
                            }
                        }

                        if (i < 0) {
                            kvp[kvp.length] = [key, value].join('=');
                        }

                        window.history.pushState({urlPath:'JP_Container?' + kvp.join('&')}, document.title,'JP_Container?'+kvp.join('&'));
                        if(data.refresh) {
                            window.location.reload();
                        }
                    } else {
                        $A.util.removeClass(cmp.find('errorToastMsg'), 'slds-hide');
                        $A.util.addClass(cmp.find('errorToastMsg'), 'slds-show');

                        cmp.set("v.errorMsg", result.errorMsg);
                    }


                } else if (state === "INCOMPLETE") {
                    // do something
                    console.log('incomplete...');
                } else if (state === "ERROR") {
                    console.log('error...');
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
        } else {
            $A.util.removeClass(cmp.find('errorToastMsg'), 'slds-hide');
            $A.util.addClass(cmp.find('errorToastMsg'), 'slds-show');

            cmp.set("v.errorMsg", result.errorMsg);
        }
    }
})
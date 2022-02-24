/**
 * Created by lauren.lezberg on 4/1/2021.
 */

({
    doInit : function(cmp, event, helper){
        console.log('ModifyAACRGroups init...');
        var salesOrderId = helper.getSalesOrderId(cmp);
        if(salesOrderId!=null){
            cmp.set("v.salesOrderId", salesOrderId);
        } else {
            var action = cmp.get("c.buildAACRGroupsSO");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var SOID = response.getReturnValue();
                    var key = 'salesOrder';
                    var value = SOID;

                    var kvp = document.location.search.substr(1).split('&');

                    // console.log('kvp: ', kvp);
                    var i = kvp.length;
                    var x;
                    while (i--) {
                        kvp[i] = kvp[i].replace('%3D', '=');
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

                    window.history.pushState({urlPath: 'ModifyAACRGroups?' + kvp.join('')}, document.title, 'ModifyAACRGroups?' + kvp.join(''));

                    cmp.set("v.salesOrderId", SOID);

                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout');
                } else if (state === "ERROR") {
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
        }
    },

    handleSave : function(cmp, event, helper){
        console.log('ModifyAACRGroups handleSave...');

        var navEvt = $A.get("e.c:JP_StepChangeEvt");
        navEvt.setParams({"stepId" : null});
        navEvt.setParams({"cmpName" : 'JP_WorkingGroupSelection'});
        navEvt.fire();
    },

    handleNavigate : function(cmp, event, helper){
        console.log('ModifyAACRGroups handleNavigate...');

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if(cmpName!=null){
            helper.closeOrder(cmp);
        }
    },

    handleCancel : function(cmp, event, helper){
        console.log('ModifyAACRGroups handleCancel...');

        helper.cancelOrder(cmp);
    }
});
/**
 * Created by lauren.lezberg on 11/17/2020.
 */

({

    doInit: function (cmp, event, helper) {
        var cardInfo = {};
        cardInfo.name = '';
        cardInfo.num = '';
        cardInfo.cvc = '';
        cardInfo.exp_month = '';
        cardInfo.exp_year = '';
        cardInfo.address_line1 = '';
        cardInfo.address_line2 = '';
        cardInfo.address_city = '';
        cardInfo.address_state = '';
        cardInfo.address_country = '';
        cardInfo.address_zip = '';
        cmp.set("v.cardInfo", cardInfo);
    },


    payNow: function (cmp, event, helper) {
        var cardInfo = cmp.get('v.cardInfo');
        console.log('cardInfo: ' + JSON.stringify(cardInfo));

        var action = cmp.get("c.getCardToken");
        action.setParams({
            "cardJSON": JSON.stringify(cardInfo),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));

                if (data.success) {
                    helper.processSOPayment(cmp, data.token);
                } else {
                    cmp.set("v.errorMsg", data.errorMsg);
                    cmp.set("v.success", false);

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
    },

    //TODO: add address functionality
});
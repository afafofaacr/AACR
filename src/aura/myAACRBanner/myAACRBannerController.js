/**
 * Created by lauren.lezberg on 9/22/2020.
 */

({
    doInit: function (cmp, event, helper) {
        var action = cmp.get("c.getBannerInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('images: ', data);
                cmp.set("v.cImages", data.images);
                cmp.set("v.selectedPanel", data.images[0].Id);
                cmp.set("v.intervalSeconds", data.intervalSeconds);

                helper.incrementPanel(cmp);
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
    },

    changePanel: function (cmp, event, helper) {
        console.log('changePanel...');
        clearInterval(cmp.get("v.timer"));
        cmp.set("v.timer", null);

        var target = event.srcElement.id;
        // console.log('target: ' + target);

        cmp.set("v.selectedPanel", target);

        setTimeout(function () {
            helper.incrementPanel(cmp);
        }, cmp.get("v.intervalSeconds") * 1000);
    },


    setDescriptions: function (cmp, event, helper) {
        var images = cmp.get("v.cImages");
        images.forEach(function (img) {
            // console.log('img: ' + JSON.stringify(img));
            // console.log("decoded text: " + helper.htmlDecode(img.Image_Text__c));
            cmp.find(img.Id).set("v.description", helper.htmlDecode(img.Image_Text__c));
        });
    }
});
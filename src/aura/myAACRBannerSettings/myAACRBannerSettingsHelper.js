/**
 * Created by lauren.lezberg on 9/22/2020.
 */

({
    getBannerImages : function(cmp, event){
        var action = cmp.get("c.getImages");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data.segments));
                var options = [];
                data.segments.forEach(function(seg){
                    options.push({label:seg.Name, value:seg.Id});
                });
                cmp.set("v.availableSegments", options);

                cmp.set("v.imgs", data.images);
                cmp.set("v.intervalSeconds", data.interval);

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

    deactivateAll : function(cmp, event){
        var action = cmp.get("c.deactivateBanner");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                // var data = response.getReturnValue();
                // cmp.set("v.imgs", data);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "The job has been submitted successfully."
                });
                toastEvent.fire();

                // setTimeout(function(){
                //     this.getBannerImages(cmp, event);
                // },10000);
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

    updateImage : function(cmp, img){
        var action = cmp.get("c.updateBannerImage");
        action.setParams({
            "img" : img
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success");
                // var data = response.getReturnValue();
                // cmp.set("v.imgs", data);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "The job has been submitted successfully."
                });
                toastEvent.fire();


                // setTimeout(function(){
                //     this.getBannerImages(cmp, event);
                // },10000);
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
    }
});
/**
 * Created by lauren.lezberg on 2/18/2020.
 */
({

    goToSpeakerInviteWizard : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.getSpeakerInviteJPId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var jpId = response.getReturnValue();
                console.log('jpId: ' + jpId);

                var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__BAMContainer',
                    },
                    state: {
                        "c__id": jpId,
                        "c__eventId" : cmp.get("v.recordId")
                    }
                };

                cmp.set("v.processing", false);
                // cmp.set("v.pageReference", pageReference);
                var navService = cmp.find("navService");
                navService.navigate(pageReference);

            } else if (state === "INCOMPLETE") {
                // do something
                cmp.set("v.processing", false);

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
                cmp.set("v.processing", false);
            }
        });
        $A.enqueueAction(action);
    },


    doInit : function(cmp, event, helper){
        console.log('doINit');
        cmp.set("v.processing", false);
        // var action = cmp.get("c.getSpeakerInviteJPId");
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     if (state === "SUCCESS") {
        //         var jpId = response.getReturnValue();
        //
        //         var pageReference = {
        //             type: 'standard__component',
        //             attributes: {
        //                 componentName: 'c__BAMContainer',
        //             },
        //             state: {
        //                 "c__id": jpId,
        //                 "c__eventId" : cmp.get("v.recordId")
        //             }
        //         };
        //         cmp.set("v.pageReference", pageReference);
        //
        //
        //     } else if (state === "INCOMPLETE") {
        //         // do something
        //
        //     } else if (state === "ERROR") {
        //         var errors = response.getError();
        //         if (errors) {
        //             if (errors[0] && errors[0].message) {
        //                 console.log("Error message: " +
        //                     errors[0].message);
        //             }
        //         } else {
        //             console.log("Unknown error");
        //         }
        //     }
        // });
        // $A.enqueueAction(action);

    },

    reInit : function(cmp, event, helper){
        console.log('reInit');

        // var navService = cmp.find("navService");
        // navService.navigate(cmp.get("v.pageReference"));
    }
})
/**
 * Created by lauren.lezberg on 7/25/2019.
 */
({

    doInit : function(cmp, event){
        console.log('DirectoryLaunch init...');

        var action = cmp.get("c.getDirectoryLaunchData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.directoryURL", data.url);
                cmp.set("v.showLaunchButton", data.showLaunchButton);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve directory launch data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve directory launch data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve directory launch data: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    openDirectory : function(cmp, event){
        console.log('DirectoryLaunch openDirectory...');

        window.open(cmp.get("v.directoryURL"),'_blank');
    }
})
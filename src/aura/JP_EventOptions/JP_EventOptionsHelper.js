/**
 * Created by lauren.lezberg on 11/12/2019.
 */
({
    getEventId : function(cmp, event){
        var name ='c__event';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1];
        }

        return null;
    },

    showToast : function(component, event, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },

    setFileAccessSettings: function(cmp,event, fileId, type){
        var action = cmp.get("c.setImageToPublic");
        action.setParams({
            "fileId": fileId,
            "eventId" : this.getEventId(cmp, event),
            "type" : type
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('file set to public..');
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: setImageToPublic');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})
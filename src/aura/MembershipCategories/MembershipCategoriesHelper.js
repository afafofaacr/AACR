/**
 * Created by lauren.lezberg on 2/12/2019.
 */
({
    getIsTransfer : function(){
        var name ='isTransfer';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            var isTransfer = results[1];
            if(isTransfer == 'true'){
                return true;
            }

        }
        return false;
    },


    newMemberApplication : function(cmp, itemId){
        console.log('MembershipCategories newMemberApplication...');

        var action = cmp.get("c.startNewMemberApplication");
        action.setParams({
            "itemId" : itemId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var redirectURL = response.getReturnValue();
                window.location.href = redirectURL;
            }
            else if (state === "INCOMPLETE") {
                // do something
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

    newTransferApplication : function(cmp, itemId){
        console.log('MembershipCategories newTransferApplication...');

        var action = cmp.get("c.startTransferApplication");
        action.setParams({
            "itemId" : itemId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var redirectURL = response.getReturnValue();
                window.location.href = redirectURL;
            }
            else if (state === "INCOMPLETE") {
                // do something
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
})
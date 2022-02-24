/**
 * Created by lauren.lezberg on 2/17/2020.
 */
({

    getEventId : function(cmp){
        var name ='c__eventId';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            return results[1];
        }

        return false;
    },

    updateEmailTemplate : function(cmp, eventId, stepId, cmpName){

        var sig1 = cmp.find("sig1").get("v.value");
        if(sig1!=''){
            var sig1Title = cmp.find("sig1Title");
            // console.log('sig1Title: ' + sig1Title);
            if(sig1Title.get("v.value")!=''){
                sig1 += '<br/>' + sig1Title.get("v.value");
            }
        }
        // console.log('sig1: ' + sig1);
        var sig2 = cmp.find("sig2").get("v.value");
        if(sig2!=''){
            var sig2Title = cmp.find("sig2Title");
            // console.log('sig2Title: ' + sig2Title);
            if(sig2Title.get("v.value")!=''){
                sig2 += '<br/>' + sig2Title.get("v.value");
            }
        }
        // console.log('sig2: ' + sig2);
        var sig3 = cmp.find("sig3").get("v.value");
        if(sig3!=''){
            var sig3Title = cmp.find("sig3Title");
            // console.log('sig3Title: ' + sig3Title.get("v.value"));
            if(sig3Title.get("v.value")!=''){
                sig3 += '<br/>' + sig3Title.get("v.value");
            }
        }
        // console.log('sig3: ' + sig3);
        var sig4 = cmp.find("sig4").get("v.value");
        if(sig4!=''){
            var sig4Title = cmp.find("sig4Title");
            // console.log('sig4Title: ' + sig4Title.get("v.value"));
            if(sig4Title.get("v.value")!=''){
                sig4 += '<br/>' + sig4Title.get("v.value");
            }
        }
        // console.log('sig4: ' + sig4);
        var sig5 = cmp.find("sig5").get("v.value");
        if(sig5!=''){
            var sig5Title = cmp.find("sig5Title");
            // console.log('sig5Title: ' + sig5Title.get("v.value"));
            if(sig5Title.get("v.value")!=''){
                sig5 += '<br/>' + sig5Title.get("v.value");
            }
        }
        // console.log('sig5: ' + sig5);
        var sig6= cmp.find("sig6").get("v.value");
        if(sig6!=''){
            var sig6Title = cmp.find("sig6Title");
            // console.log('sig6Title: ' + sig6Title.get("v.value"));
            if(sig6Title.get("v.value")!=''){
                sig6 += '<br/>' + sig6Title.get("v.value");
            }
        }
        // console.log('sig6: ' + sig6);


        var action = cmp.get("c.updateEventAndPreview");
        action.setParams({
            "eventId": eventId,
            "message" : cmp.find("inviteMessage").get("v.value"),
            "sig1" : sig1,
            "sig2" : sig2,
            "sig3" : sig3,
            "sig4" : sig4,
            "sig5" : sig5,
            "sig6" : sig6
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + data);
                
                if(data) {
                    if (stepId != null && cmpName != null) {
                        var navEvt = $A.get("e.c:JP_NavigateEvt");
                        navEvt.setParams({"stepId": stepId});
                        navEvt.setParams({"cmpName": cmpName});
                        navEvt.fire();
                    } else {
                        cmp.find("emailPreview").refreshPreview();
                    }
                }else {
                        console.log("Could not update preview.");
                }
            } else if (state === "INCOMPLETE") {
                // do something
                return false;
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
                return false;
            }
        });
        $A.enqueueAction(action);
    }
})
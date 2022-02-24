/**
 * Created by afaf.awad on 3/25/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit...');

        let eventId;
        let name ='c__eventId';
        let url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        let regexS = "[\\?&]"+name+"=([^&#]*)";
        let regex = new RegExp( regexS, "i" );
        let results = regex.exec( url );
        if(results!=null){
            eventId = results[1];
        }

        cmp.set('v.eventId', eventId);
    },

    optOutEmails: function(cmp,event,helper){
        cmp.set('v.showError', '');
        let action = cmp.get("c.optOutOfEmails");
        action.setParams({
            "eventId" : cmp.get('v.eventId'),
            "emailString" : cmp.find('emailInput').get('v.value')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let results = response.getReturnValue();
                console.log(results);
                if (results) {
                    console.log('success!');
                    cmp.set('v.isOptOut', true);
                }else if (results === null){
                    cmp.set('v.showError', 'This email is not in our records.');
                }else{
                    cmp.set('v.showError', 'Something went wrong opting out with this email.');
                }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
                cmp.set('v.showError', 'Something went wrong. Please try again later.');
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        cmp.set('v.showError', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});
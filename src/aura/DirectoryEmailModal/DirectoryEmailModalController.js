/**
 * Created by lauren.lezberg on 5/22/2019.
 */
({
    closeModal : function(cmp, event, helper){
        cmp.set("v.isOpen", false);
        cmp.set("v.hasError", false);
        cmp.set("v.emailBody", null);
        cmp.set("v.subject", null);
        cmp.set("v.emailAddr", null);
    },

    sendEmail : function(cmp, event, helper){
        var emailAddr = cmp.get("v.emailAddr");
        var subject = cmp.get("v.subject");
        var body = cmp.get("v.emailBody");

        if(emailAddr!=null && subject!=null && body!=null) {
            console.log("email: ", emailAddr);
            var action = cmp.get("c.sendEmailToMember");
            // set the parameters to method
            action.setParams({
                "emailAddr": emailAddr,
                "subject": subject,
                "body": body
            });
            // set a call back
            action.setCallback(this, function (a) {
                // store the response return value (wrapper class insatance)
                var result = a.getReturnValue();
                console.log('result ---->' + JSON.stringify(result));
                if (result == false) {
                    cmp.set("v.hasError", true);
                } else {
                    cmp.set("v.isOpen", false);
                    cmp.set("v.emailAddr", null);
                    cmp.set("v.emailBody", null);
                    cmp.set("v.subject", null);
                }
            });
            // enqueue the action
            $A.enqueueAction(action);
        } else {
            cmp.set("v.hasError", true);
        }
    }
})
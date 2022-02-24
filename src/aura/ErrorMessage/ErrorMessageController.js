/**
 * Created by lauren.lezberg on 2/11/2020.
 */
({

    setErrorMessage : function(cmp,event, helper){
        var msg = event.getParam("errorMsg");
        cmp.set("v.errorMsg", msg);
    }
})
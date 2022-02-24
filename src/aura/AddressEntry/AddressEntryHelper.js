/**
 * Created by lauren.lezberg on 3/29/2019.
 */
({

    /**
     * @purpose Gets new state list based on selected country
     * @param cmp
     * @param countryVal
     */
    getNewStatesList : function(cmp, countryVal){
        var action = cmp.get("c.getStates");
        action.setParams({
            "countryVal" : countryVal,
            "mailingCountryCode" : cmp.get("v.parent").get('v.mailingAddress.countryCode'),
            "otherCountryCode" : cmp.get("v.parent").get('v.otherAddress.countryCode')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('states: ', data);
                var custs = [];
                for(var key in data){
                    custs.push({label:data[key], value:key});
                }
                cmp.set("v.displayStateList", custs);
                if(custs.length == 0){
                    cmp.set("v.address.stateCode", null);
                }
                var parent = cmp.get("v.parent");
                if(parent!=null) {
                    parent.updateContact();
                }
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
    
})
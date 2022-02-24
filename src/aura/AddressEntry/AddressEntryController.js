/**
 * Created by lauren.lezberg on 2/26/2019.
 */
({

    doInit : function(cmp, event, helper){
        // console.log(JSON.stringify(cmp.get("v.countryList")));
        cmp.set("v.displayStateList", cmp.get("v.statesList"));
    },

    /**
     * @purpose Sets state list with the states that should be displayed
     * @param cmp
     * @param event
     * @param helper
     */
    setStatesList : function(cmp, event, helper){
        console.log('getStateList...');
        cmp.set("v.displayStateList", cmp.get("v.statesList"));
    },

    /**
     * @purpose Responds when country picklist is modified and calls helper method to retrieve new state list
     * @param cmp
     * @param event
     * @param helper
     */
    onCountryChange : function (cmp, event, helper) {
        console.log('onCountryChange...');
        var changeValue = event.getSource().get("v.value");
        console.log('country changeValue: ', changeValue);
        if(changeValue == null || changeValue == '') {
            $A.util.removeClass(cmp.find("state"), "slds-has-error");
            $A.util.addClass(cmp.find("state"), "hide-error-message");
        }
        cmp.set("v.mailingCountry", changeValue);
        helper.getNewStatesList(cmp, changeValue);
    },


})
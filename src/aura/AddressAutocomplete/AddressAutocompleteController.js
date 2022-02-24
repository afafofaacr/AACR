/**
 * Created by lauren.lezberg on 9/8/2020.
 */

({
    /**
     * @purpose Closes results dropdown onblur
     * @param cmp
     * @param event
     * @param helper
     */
    onblur: function (cmp, event, helper) {
        cmp.set("v.listOfSearchRecords", null);
        var forclose = cmp.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },


    /**
     * Retrieves initial address load if a placeId is supplied
     * @param cmp
     * @param event
     * @param helper
     */
    handleAddressLoad : function(cmp, event, helper){
        // console.log('handleAddressLoad...' + cmp.get("v.placeId"));

        var forclose = cmp.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = cmp.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = cmp.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

        helper.getPlaceAddress(cmp, event, cmp.get("v.placeId"));
    },

    /**
     * @purpose Shows results dropdown onfocus
     * @param cmp
     * @param event
     * @param helper
     */
    onfocus : function(cmp,event,helper){
        $A.util.addClass(cmp.find("mySpinner"), "slds-show");
        var forOpen = cmp.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC
        var getInputkeyWord = '';

        helper.searchHelper(cmp, event, getInputkeyWord);
    },

    /**
     * @purpose Function to find address as text is typed out by user
     * @param cmp
     * @param event
     * @param helper
     */
    keyPressController : function(cmp, event, helper) {
        // get the search Input keyword
        var getInputkeyWord = cmp.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and call the helper
        // else close the lookup result List part.
        if( getInputkeyWord.length > 0 ){
            var forOpen = cmp.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(cmp,event,getInputkeyWord);
        }
        else{
            cmp.set("v.listOfSearchRecords", null );
            var forclose = cmp.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    /**
     * @purpose function to clear the record selection
     * @param cmp
     * @param event
     * @param helper
     */
    clear :function(cmp,event,helper){
        var pillTarget = cmp.find("lookup-pill");
        var lookUpTarget = cmp.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        cmp.set("v.SearchKeyWord",null);
        cmp.set("v.listOfSearchRecords", null );
        cmp.set("v.selection", {} );
        cmp.set("v.selectedId", null);
        cmp.set("v.address", {});
    },

    /**
     * @purpose This function is called when the end User Selects any record from the result list.
     * @param component
     * @param event
     * @param helper
     */
    handleComponentEvent : function(component, event, helper) {
        // get the selected record from the COMPONENT event
        var selectedRecord = event.getParam("recordByEvent");
        component.set("v.selection", selectedRecord);
        component.set("v.selectedId", selectedRecord.place_id);

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

        helper.getPlaceAddress(component, event, selectedRecord.place_id);

    },
});
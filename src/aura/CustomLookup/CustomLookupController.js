/**
 * Created by lauren.lezberg on 3/21/2019.
 */
({

    doInit : function(component, event, helper){
        console.log('CustomLookup init...');

        helper.initialize(component, event);

    },

    /**
     * @purpose Shows results dropdown onfocus
     * @param component
     * @param event
     * @param helper
     */
    onfocus : function(component,event,helper){
        console.log('CustomLookup onfocus...');

        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC
        var getInputkeyWord = '';
        if(!component.get("v.showNewRecordModal")) {
            helper.searchHelper(component, event, getInputkeyWord);
        }
    },

    /**
     * @purpose Closes results dropdown onblur
     * @param component
     * @param event
     * @param helper
     */
    onblur : function(component,event,helper){
        console.log('CustomLookup onblur...');

        if(!component.get("v.showNewRecordModal")) {
            component.set("v.listOfSearchRecords", null);
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    
    keyPressController : function(component, event, helper) {
        console.log('CustomLookup keyPressController...');

        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and call the helper
        // else close the lookup result List part.
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction
    clear :function(component,event,heplper){
        console.log('CustomLookup clear...');

        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selection", {} );
        component.set("v.selectedId", null);
    },

    /**
     * @purpose This function is called when the a user selects any record from the result list.
     * @param component
     * @param event
     * @param helper
     */
    handleComponentEvent : function(component, event, helper) {
        console.log('CustomLookup handleComponentEvent...');

        // get the selected Account record from the COMPONENT event
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var selectedRecord = {"Id":selectedAccountGetFromEvent.Id, "Name":selectedAccountGetFromEvent.Name };
        component.set("v.selection", selectedRecord);
        component.set("v.selectedId", selectedAccountGetFromEvent.Id);

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

    },

    closeNewRecordModal : function(component, event, helper){
        console.log('CustomLookup closeNewRecordModal...');

        component.set("v.showNewRecordModal", false);
        component.set("v.listOfSearchRecords", null);
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },

    showNewRecordModal : function(component, event, helper){
        console.log('CustomLookup showNewRecordModal...');

        component.set("v.showNewRecordModal", true);
    },

    enterPressed : function(cmp, event, helper){
        console.log('CustomLookup enterPressed...');

        if(event.keyCode == 13){
            helper.createRecord(cmp, event);
        }
    },


    handleSaveRecord : function(cmp, event, helper){
        console.log('CustomLookup handleSaveRecord...');

        helper.createRecord(cmp, event);
    }

})
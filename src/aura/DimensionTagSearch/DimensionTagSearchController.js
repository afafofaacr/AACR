/**
 * Created by afaf.awad on 5/27/2021.
 */

({
    doInit : function(cmp, event, helper){
        cmp.set('v.IconName', 'standard:' + cmp.get('v.sobjecttype').toLowerCase())
        console.log('sobjectType = ' + cmp.get('v.sobjecttype'));
    },

    /**
     * @purpose Shows results dropdown onfocus
     * @param component
     * @param event
     * @param helper
     */
    onfocus : function(component,event,helper){
        // $A.util.addClass(component.find("mySpinner"), "slds-show");
        // let forOpen = component.find("searchRes");
        // $A.util.addClass(forOpen, 'slds-is-open');
        // $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC
        let getInputkeyWord = '';
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
        console.log('onblur...');
        if(!component.get("v.showNewRecordModal")) {
            component.set('v.newTag', false);
            component.set("v.listOfSearchRecords", null);
            let listBox = component.find("resultsBox");
            $A.util.removeClass(listBox, 'slds-box_border');
        }
    },

    keyPressController : function(component, event, helper) {
        let getInputkeyWord = component.get("v.SearchKeyWord");
        if( getInputkeyWord.length > 0 ){
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
        }
    },

    
    // This function call when the end User Select any record from the result list.
    handleComponentEvent : function(component, event, helper) {
        let selectedRecordFromEvent = event.getParam("recordByEvent");
        let selectedRecord = {"Id":selectedRecordFromEvent.Id, "Name":selectedRecordFromEvent.Name, "DeveloperName": selectedRecordFromEvent.DeveloperName };
        console.log('selection == ' + JSON.stringify(selectedRecord));
        helper.createRecord(component, selectedRecord);
    },

    closeNewRecordModal : function(component, event, helper){
        component.set("v.showNewRecordModal", false);
        component.set("v.listOfSearchRecords", null);
        let forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },

    openModal : function(cmp, event, helper){
        cmp.find('DimTagModal').set("v.isOpen", true);
    },

    enterPressed : function(cmp, event, helper){
        if(event.keyCode == 13){
            helper.createRecord(cmp, event);
        }
    },

    handleSaveRecord : function(cmp, event, helper){
        // helper.createRecord(cmp, event);
    }

});
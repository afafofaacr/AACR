/**
 * Created by lauren.lezberg on 3/21/2019.
 */
({
    /**
     * @purpose Initialize component data
     * @param component
     * @param event
     */
    initialize : function(component, event ){
        console.log('CustomLookup initialize...');

        var selected = component.get("v.selectedId");
        var action = component.get("c.getInitialValue");
        // set param to method
        action.setParams({
            'ObjectName' : component.get("v.objectAPIName"),
            'recordId': selected!=null&&selected!=undefined?selected:null
        });
        // set a callBack
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if(storeResponse!=null){
                    component.set("v.selection", storeResponse);
                    var pillTarget = component.find("lookup-pill");
                    var lookUpTarget = component.find("lookupField");

                    $A.util.addClass(pillTarget, 'slds-show');
                    $A.util.removeClass(pillTarget, 'slds-hide');

                    $A.util.addClass(lookUpTarget, 'slds-hide');
                    $A.util.removeClass(lookUpTarget, 'slds-show');

                } else {
                    component.set("v.selection", {});
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    },


    /**
     * @purpose Call controller to get results based off search keyword
     * @param component
     * @param event
     * @param getInputkeyWord
     */
    searchHelper : function(component,event,getInputkeyWord) {
        console.log('CustomLookup searchHelper...');

        // call the apex class method
        var action = component.get("c.fetchLookUpValues");
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'filterString' : component.get("v.filterString")!=null?component.get("v.filterString"):null
        });
        // set a callBack
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'Cannot find ' + component.get("v.objectAPIName") + '...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);

    },

    /**
     * @purpose calls apex method to create a new record of the specified object type with a specified name. Component is re-initialized after record is added.
     * @param component
     * @param event
     */
    createRecord : function(component, event){
        console.log('CustomLookup createRecord...');

        var action = component.get("c.createNewRecord");
        action.setParams({
            'objectApiName' : component.get("v.objectAPIName"),
            'recordName' : component.find("newAccountName").get("v.value"),
            'recordTypeName' : component.get("v.recordTypeName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse!=null) {
                    component.set("v.selectedId", storeResponse);
                    component.set("v.showNewRecordModal", false);
                    this.initialize(component, event);
                } else {
                    component.set("v.Message", 'Could not create account. ');
                }
            } else {
                console.log('error');
            }

        });
        $A.enqueueAction(action);
    }
})
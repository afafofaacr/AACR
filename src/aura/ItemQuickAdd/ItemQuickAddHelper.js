/**
 * Created by lauren.lezberg on 10/7/2019.
 */
({
    /**
     * Call apex method to search records based on search keyword
     * @param component
     * @param event
     * @param getInputkeyWord
     */
    searchHelper : function(component,event,getInputkeyWord) {
        console.log('ItemQuickAdd searchHelper...');

        // call the apex class method
        var action = component.get("c.fetchItems");
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
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

})
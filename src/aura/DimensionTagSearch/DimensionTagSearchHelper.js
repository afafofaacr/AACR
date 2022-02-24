/**
 * Created by afaf.awad on 5/27/2021.
 */

({
    /**
     * @purpose Call controller to get results based off search keyword
     * @param component
     * @param event
     * @param getInputkeyWord
     */
    searchHelper : function(component,event,getInputkeyWord) {
        console.log("searchHelper..." + component.get("v.sobjecttype"));
        // call the apex class method
        let action = component.get("c.searchTags");
        // set param to method
        action.setParams({
            'searchString': getInputkeyWord,
            'objectName' : component.get("v.sobjecttype"),
            'recordId' : component.get('v.recordId')
        });
        // set a callBack
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let storeResponse = response.getReturnValue();
                console.log('storeResponse:: ' + JSON.stringify(storeResponse));

                //Rename Label to Name to reuse CustomLookupResult cmp
                storeResponse.forEach((tag) => {
                    tag.Name = tag.Label;
                });

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set('v.newTag', true);
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                    let listBox = component.find("resultsBox");
                    $A.util.addClass(listBox, 'slds-box_border');
                component.set("v.listOfSearchRecords", storeResponse);

            } else if (state === "INCOMPLETE") {
            console.log('Incomplete Callout: - searchHelper: ');
        } else if (state === "ERROR") {
            let errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message - searchHelper: " +
                        errors[0].message);
                }
            } else {
                console.log("Unknown error: searchHelper");
            }
        }
    });
        $A.enqueueAction(action);

    },

    /**
     * @purpose calls apex method to create a new record of the specified object type with a specified name. Component is re-initialized after record is added.
     * @param component
     * @param event
     */
    createRecord : function(component, record){
        console.log('recrodid = ' + component.get('v.recordId'));
        let action = component.get("c.createTagRecord");
        action.setParams({
            'dimTagId' : record.Id ,
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let storeResponse = response.getReturnValue();
                if(storeResponse!=null) {
                    let cmpEvent = component.getEvent('callDimTagEvent');
                    cmpEvent.setParams({
                        'action' : 'refresh'
                    })
                    cmpEvent.fire();
                    component.set("v.listOfSearchRecords", null);
                    let listBox = component.find("resultsBox");
                    $A.util.removeClass(listBox, 'slds-box_border');
                } else {
                    component.set("v.Message", 'Could not create tag record. ');
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - createRecord: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - createRecord: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: createRecord");
                }
            }
        });
        $A.enqueueAction(action);
    }
});
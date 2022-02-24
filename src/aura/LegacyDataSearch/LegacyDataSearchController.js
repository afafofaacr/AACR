/**
 * Created by afaf.awad on 6/13/2019.
 */
({
    doInit: function (cmp, event, helper) {

        let searchResults = cmp.get("v.searchResults");
        console.log('searchResults.length = ' + searchResults.length);

        if(searchResults.length != 0){
            cmp.set("v.showTable", true);}

        let action = cmp.get("c.getActivityTypes");
        let options = [];
        console.log('calling doInit');
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === 'SUCCESS') {
                let result = a.getReturnValue() ;
                result.forEach(function(element){
                    options.push({value:element.Label, label:element.Label});
                });
                cmp.set('v.activityTypes', helper.sortArray(options));
            }
        });
                $A.enqueueAction(action);

    },

    activityFilterChange: function (component, event, helper) {
        let filterOptions = component.get("v.activityTypes");
        let activity = event.getSource().get("v.value");
        filterOptions.forEach(function (option, idx) {
            if (option.label == activity) {
                filterOptions.splice(idx, 1);
            }
        });

        component.set("v.activityTypes", helper.sortArray(filterOptions));
        let filters = component.get("v.activityFilters");
        filters.push(activity);
        component.set("v.activityFilters", filters);
        component.find('activityTypes').set("v.value",null);
    },

    removeActivityFilter: function (component, event, helper) {
        let filterOptions = component.get("v.activityTypes");
        let filterToPush = event.getSource().get("v.label");
        let filters = component.get("v.activityFilters");
        filters.forEach(function (pill, idx) {
            if (filterToPush == pill) {
                filters.splice(idx, 1);
                filterOptions.push({label: filterToPush, value: filterToPush});
            }
        });
        component.set("v.activityFilters", filters);
        component.set("v.activityTypes", helper.sortArray(filterOptions));
    },

    enterPressed: function (component, event, helper) {
        if (event.keyCode == 13) {
            $A.enqueueAction(component.get('c.handleSearch'));
        }
    },

    handleSearch: function (cmp,event, helper) {

        console.log("Activity Types= " + JSON.stringify(cmp.get("v.activityFilters")));

        //validate date range
        let dateToField = cmp.find('dateToField');
        let dateTo = dateToField.get('v.value');
        let dateFrom = cmp.get("v.dateFrom");

        if (dateFrom && dateTo && (dateFrom > dateTo)){
            dateToField.setCustomValidity("This date cannot be smaller than your From date.");
        } else {
            dateToField.setCustomValidity("");
            cmp.set('v.processing', true);
            let action = cmp.get("c.getLegacyData");
            action.setParams({
                "activityTypes": JSON.stringify(cmp.get("v.activityFilters")),
                "searchText": cmp.get('v.searchText'),
                "dateFrom": cmp.get('v.dateFrom'),
                "dateTo": cmp.get('v.dateTo'),
                "recordId": cmp.get('v.recordId'),
                "imisID": cmp.get('v.imisID'),
            });

            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === 'SUCCESS') {
                    let records = response.getReturnValue();
                    console.log("searchResults returned from DataSearch cmp=" + JSON.stringify(records));
                    cmp.set("v.searchResults", JSON.parse(records.resultListString));
                    cmp.set("v.recordCount", records.recordCount);
                    cmp.set("v.showTable", true);
                    cmp.set("v.processing", false);

                } else if (state === "INCOMPLETE") {
                    console.log('state =' + state);
                    cmp.set("v.processing", false);
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    console.log("Error message: " + errors[0].message);
                    cmp.set("v.processing", false);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            cmp.set("v.processing", false);
                        }
                    } else {
                        console.log("Unknown error");
                        cmp.set("v.processing", false);
                    }
                }
            });

            $A.enqueueAction(action);
        }
        dateToField.reportValidity();

    }
})
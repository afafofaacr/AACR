/**
 * Created by lauren.lezberg on 5/21/2019.
 */
({
    getContacts: function(component, page) {
        // console.log('getting contacts...');

        if(component.get("v.Contacts").length==0){
            component.set("v.isLoading", true);
        }

        var recordsToDisplay = component.get("v.recordsToDisplay");
        if(page==null){
            page= component.get("v.page") || 1;
        }
        var action = component.get("c.fetchContacts");
        action.setParams({
            "pageNumber": page,
            "recordsToDisplay": recordsToDisplay,
            "focusFilters" : component.get("v.focusFilters"),
            "countryFilters" : component.get("v.countryFilters"),
            "stateFilters" : component.get("v.stateFilters"),
            "nameFilter" : component.get("v.nameFilter"),
            "accountFilter" : component.get("v.accountFilter"),
            "orderBy" : component.get("v.orderBy"),
            "order" : component.get("v.order")
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            // console.log('result--> ', result);
            // console.log("contacts", component.get("v.showFilters"));
            component.set("v.showFilters", result.showFilters);
            component.set("v.Contacts", result.contacts);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordsToDisplay));
            component.set("v.isLoading", false);
            this.getFilters(component);
        });
        $A.enqueueAction(action);
    },
    

    getFilters : function(component){
        console.log('getFilters...');
        var action = component.get("c.getFilterCriteria");
        // set a call back
        action.setCallback(this, function(a) {
            // store the response return value (wrapper class instance)
            var result = a.getReturnValue();

            var primaryFocusOptions = [];
            result.primaryFocus.forEach(function(focus){
                var focusOption = {};
                focusOption.label = focus;
                focusOption.value = focus;
                primaryFocusOptions.push(focusOption);
            });
            // console.log("focusOptions: ", primaryFocusOptions);
            component.set("v.primaryFocusOptions", primaryFocusOptions);

            var countryKeys = [];
            var countryOptions = result.countries;
            for (var singlekey in countryOptions) {
                //console.log('singleKey: ', countryOptions[singlekey]);
                var countries = {};
                countries.label = countryOptions[singlekey];
                countries.value = countryOptions[singlekey];
                countryKeys.push(countries);
            }
            component.set("v.countryOptions", countryKeys);

            var stateKeys = [];
            var stateOptions = result.states;
            for (var singlekey in stateOptions) {
                var states = {};
                states.label = stateOptions[singlekey];
                states.value = stateOptions[singlekey];
                stateKeys.push(states);
            }
            component.set("v.stateOptions", stateKeys);

        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    sortArray : function(array){

        array.sort(function(a, b) {
            a.label !== b.label ? a.label < b.label ? -1 : 1 : 0;
        });

        return array;
    }
})
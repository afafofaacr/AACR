/**
 * Created by lauren.lezberg on 5/21/2019.
 */
({
    doInit: function(component, event, helper) {
        helper.getContacts(component, null);

    },


    navigate: function(component, event, helper) {
        // this function call on click on the previous page button
        var page = component.get("v.page") || 1;
        // get the previous button label
        var direction = event.getSource().get("v.label");
        // set the current page,(using ternary operator.)
        page = direction === "Previous" ? (page - 1) : (page + 1);
        // call the helper function
        helper.getContacts(component, page);

    },

    openDetails : function(cmp, event, helper){
        var contactId = event.getSource().get("v.value");
        var contacts = cmp.get("v.Contacts");
        contacts.forEach(function(con){
            if(contactId == con.Id){
                cmp.find("detailModal").set("v.Contact", con);
            }
        });

        cmp.find("detailModal").set("v.isOpen", true);
    },

    // onSelectChange: function(component, event, helper) {
    //     var page = 1
    //     var recordsToDisplay = component.find("recordSize").get("v.value");
    //     helper.getContacts(component, page);
    // },

    emailMember : function(component, event, helper){
        var emailAddr = event.getSource().get("v.value");
        component.set("v.emailModalOpen", true);
        component.find("emailModal").set("v.emailAddr", emailAddr);
    },

    showFilterPanel : function(component, event, helper){
        console.log('showFilterPanel: ', component.get("v.showFilters"));
        if(component.get("v.showFilters")){
            component.set("v.showFilters", false);
        } else {
            component.set("v.showFilters", true);
            helper.getFilters(component);
        }
    },

    primaryFocusChange : function(component, event, helper){
        var filterOptions = component.get("v.primaryFocusOptions");
        var primaryFocus = event.getSource().get("v.value");
        filterOptions.forEach(function(option, idx){
            if(option.label == primaryFocus){
                filterOptions.splice(idx, 1);
            }
        });
        component.set("v.primaryFocusOptions", filterOptions);
        var filters = component.get("v.focusFilters");
        filters.push(primaryFocus);
        component.set("v.focusFilters", filters);
        component.find('focusFilters').set("v.value", null);
        helper.getContacts(component, 1);
    },

    removeFocusFilter : function(component, event, helper){
        var filterOptions = component.get("v.primaryFocusOptions");
        var filter = event.getSource().get("v.label");
        var filters = component.get("v.focusFilters");
        filters.forEach(function(focus, idx){
            if(filter == focus){
                filters.splice(idx,1);
                filterOptions.push({label:filter, value:filter});
            }
        });
        component.set("v.focusFilters", filters);
        component.set("v.primaryFocusOptions", helper.sortArray(filterOptions));

        helper.getContacts(component, 1);
    },

    countryChange : function(component, event, helper){
        var filterOptions = component.get("v.countryOptions");
        var country = event.getSource().get("v.value");
        filterOptions.forEach(function(option, idx){
            if(option.label == country){
                filterOptions.splice(idx, 1);
            }
        });
        component.set("v.countryOptions", filterOptions);
        var filters = component.get("v.countryFilters");
        filters.push(country);
        component.set("v.countryFilters", filters);
        component.find('countryFilters').set("v.value", null);
        helper.getContacts(component, 1);
    },

    removeCountryFilter : function(component, event, helper){
        var filterOptions = component.get("v.countryOptions");
        var filter = event.getSource().get("v.label");
        var filters = component.get("v.countryFilters");
        filters.forEach(function(country, idx){
            if(filter == country){
                filters.splice(idx,1);
                filterOptions.push({label:filter, value:filter});
            }
        });
        component.set("v.countryFilters", filters);
        component.set("v.countryOptions", helper.sortArray(filterOptions));
        helper.getContacts(component, 1);
    },

    stateChange : function(component, event, helper){
        var filterOptions = component.get("v.stateOptions");
        var state = event.getSource().get("v.value");
        filterOptions.forEach(function(option, idx){
            if(option.label == state){
                filterOptions.splice(idx, 1);
            }
        });
        component.set("v.stateOptions", filterOptions);
        var filters = component.get("v.stateFilters");
        filters.push(state);
        component.set("v.stateFilters", filters);
        component.find('stateFilters').set("v.value", null);
        helper.getContacts(component, 1);
    },

    removeStateFilter : function(component, event, helper){
        var filterOptions = component.get("v.stateOptions");
        var filter = event.getSource().get("v.label");
        var filters = component.get("v.stateFilters");
        filters.forEach(function(state, idx){
            if(filter == state){
                filters.splice(idx,1);
                filterOptions.push({label:filter, value:filter});
            }
        });
        component.set("v.stateFilters", filters);
        component.set("v.stateOptions", helper.sortArray(filterOptions));
        helper.getContacts(component, 1);
    },

    accountFilterChange : function(cmp, event, helper){
        helper.getContacts(cmp, null);
    },

    clearAllFilters : function(component, event, helper){
        var filters = component.get("v.stateFilters");
        var stateOptions = component.get("v.stateOptions");
        filters.forEach(function(state){
            stateOptions.push({label:state, value:state});
        });
        component.set("v.stateOptions", helper.sortArray(stateOptions));
        component.set("v.stateFilters", []);

        filters = component.get("v.countryFilters");
        var countryOptions = component.get("v.countryOptions");
        filters.forEach(function(country){
            countryOptions.push({label:country, value:country});
        });
        component.set("v.countryOptions", helper.sortArray(countryOptions));
        component.set("v.countryFilters", []);

        filters = component.get("v.focusFilters");
        var focusOptions = component.get("v.primaryFocusOptions");
        filters.forEach(function(focus){
            focusOptions.push({label:focus, value:focus});
        });
        component.set("v.primaryFocusOptions", helper.sortArray(focusOptions));
        component.set("v.focusFilters", []);

        component.set("v.accountFilter", null);
        component.find("accountFilters").clearAccount();

        helper.getContacts(component, null);
    },

    sortMembers : function(component, event, helper){
        var newSortBy = event.currentTarget.getAttribute('id');
        var oldSortBy = component.get("v.orderBy");


        if(newSortBy==oldSortBy){
            var order = component.get("v.order");
            if(order == 'ASC'){
                component.set("v.order", 'DESC');
            } else {
                component.set("v.order", 'ASC');
            }
        } else {
            component.set("v.orderBy", newSortBy );
            component.set("v.order", 'ASC');
        }
        helper.getContacts(component, null);
    },

    searchForMember : function(component, event, helper){
        helper.getContacts(component, 1);

    },

    enterPressed : function(component, event, helper){
        if(event.keyCode == 13){
            helper.getContacts(component, null);
        }
    },

    clearSearch : function(component, event, helper){
        component.set("v.nameFilter", '');
        helper.getContacts(component, null);
    },

})
/**
 * Created by lauren.lezberg on 1/16/2019.
 */
({
    doInit: function (cmp, event, helper) {
        var action = cmp.get("c.getCompJournalOptions");
        action.setParams({
            "salesOrderId": helper.getSalesOrderId(cmp)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                if (cmp.get("v.selectedComp") == undefined) {
                    cmp.set("v.selectedComp", data.selectedJournal);
                }
                cmp.set("v.declineId", data.declineJournal);

                var items = [];
                var online = false;
                if (data.selectedJournal == data.declineJournal) {
                    cmp.set("v.value", 'Decline');
                    cmp.set("v.selectedCompName", 'Declined Free Journal');
                }

                //create combobox list for online comps
                data.journalsOnline.forEach(function (option) {
                    if (data.selectedJournal == undefined || option.Id == data.selectedJournal) {
                        cmp.set("v.value", 'Online Only');
                        online = true;
                    }
                    var item = {
                        "label": option.Portal_Label__c,
                        "value": option.Id,
                    };
                    items.push(item);
                });
                cmp.set("v.onlineComps", items);

                //if selected comp is online only
                if (online) {
                    cmp.set("v.availableComps", items);
                }

                //create combobox list for print comps
                items = [];
                data.journalsPrint.forEach(function (option) {
                    if (option.Id == data.selectedJournal) {
                        cmp.set("v.value", 'Print & Online');
                    }
                    var item = {
                        "label": option.Portal_Label__c,
                        "value": option.Id,
                    };
                    items.push(item);
                });
                cmp.set("v.printComps", items);
                //if selected comp is not online only
                if (!online) {
                    cmp.set("v.availableComps", items);
                }
                var availableComps = cmp.get("v.availableComps");
                availableComps.forEach(function (comp) {
                    if (comp.value == data.selectedJournal) {
                        // console.log('found selection...', comp.label);
                        cmp.set("v.selectedCompName", comp.label);
                    }
                });


            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Handles selection of COMP journal from dropdown
     * @param cmp
     * @param event
     */
    handleCompChange: function (cmp, event) {
        var selectedOptionValue = event.getParam("value");
        var availableComps = cmp.get("v.availableComps");
        if (availableComps.length > 0) {
            if (selectedOptionValue != null && selectedOptionValue != cmp.get("v.declineId")) {
                availableComps.forEach(function (comp) {
                    if (comp.value == selectedOptionValue) {
                        cmp.set("v.selectedCompName", comp.label);
                    }
                });
            } else {
                cmp.set("v.selectedCompName", null);
            }
        }
    },

    /**
     * Handles toggle of button group for online/print/decline. If decline is selected, the decline journal id is added as the selection
     * @param cmp
     * @param event
     * @param helper
     */
    onToggle: function (cmp, event, helper) {
        var online = cmp.get("v.onlineComps");
        var print = cmp.get("v.printComps");

        var selectedValue = cmp.get("v.selectedComp");
        var changeValue = event.getParam("value");

        if (changeValue == 'Online Only') {
            if (selectedValue == cmp.get("v.declineId")) {
                cmp.set("v.selectedComp", null);
            }
            if (selectedValue != null) {
                print.forEach(function (journal) {
                    if (journal.value == selectedValue) {
                        helper.getMatchingOnlineJournal(cmp, online, journal.label);
                    }
                });
            }
            cmp.set("v.availableComps", online);
        } else if (changeValue == 'Print & Online') {
            if (selectedValue == cmp.get("v.declineId")) {
                cmp.set("v.selectedComp", null);
            }
            if (selectedValue != null) {
                online.forEach(function (journal) {
                    if (journal.value == selectedValue) {
                        helper.getMatchingPrintJournal(cmp, print, journal.label);
                    }
                });
            }
            cmp.set("v.availableComps", print);
        } else if (changeValue == 'Decline') {
            cmp.set("v.selectedComp", cmp.get("v.declineId"));

        }

    },


})
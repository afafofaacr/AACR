/**
 * Created by lauren.lezberg on 1/18/2019.
 */
({
    /**
     * Calls apex method to retrieve journal data and any pre-existing selections from the sales order
     * @param cmp
     * @param event
     */
    getJournalData: function (cmp, event) {
        console.log('JP_JournalSelections getJournalData...');

        var stepId = cmp.get("v.stepId");
        var action = cmp.get("c.getJournalData");
        action.setParams({
            "salesOrderId": this.getSalesOrderId(cmp),
            "stepId": stepId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.contactId", data.contactId);
                cmp.set("v.isActiveMember", data.isActiveMembership);
                if (cmp.get("v.selectedCOMP") != null || !data.isActiveMembership) {
                    this.getBuyUpJournals(cmp, event);
                } else {
                    cmp.set("v.isLoading", false);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve journal data: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve journal data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve journal data: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Removes selected comp journal from list of buyups so user cannot purchase the same journal as a COMP and a buy up
     * @param cmp
     * @param selectedComp
     * @param journals
     */
    hideCompJournalFromBuyup: function (cmp, selectedComp, journals) {
        console.log('JP_JournalSelections hideCompJournalFromBuyup...');

        journals.forEach(function (journal) {
            if (selectedComp != null && selectedComp == journal.name + '- Online' || selectedComp == journal.name + '- Print') {
                journal.hidden = true;
                journal.selectedItem = null;
            } else {
                journal.hidden = false;
            }
        });

        cmp.set("v.journals", journals);
    },

    /**
     * @purpose Calls apex method to retrieve all buyup journals available for purchase. If a comp journal is selected, it will be hidden from the list of journals.
     * @param cmp
     * @param event
     */
    getBuyUpJournals: function (cmp, event) {
        console.log('JP_JournalSelections getBuyUpJournals...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getJournals");
        action.setParams({
            "salesOrderId": this.getSalesOrderId(cmp)
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('journals: ' + JSON.stringify(data));
                var selectedComp = cmp.get("v.compName");
                this.hideCompJournalFromBuyup(cmp, selectedComp, data);
            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve journal data: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve journal data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve journal data: Unknown error");
                }
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },


    /**
     * @purpose Calls apex method to save all selected journal items as sales order lines for the given sales order. Upon completion, the navigate event is fired in order to move forward
     * or backward in the particular join process
     * @param cmp
     * @param event
     * @param selected
     * @param stepId
     * @param cmpName
     */
    saveSelections: function (cmp, event, selected, stepId, cmpName) {
        console.log('JP_JournalSelections saveSelections...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.saveJournalSelections");
        action.setParams({
            "salesOrderId": this.getSalesOrderId(cmp),
            "selectedItems": selected,
            "stepId": cmp.get("v.stepId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.isSuccess) {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": stepId});
                    navEvt.setParams({"cmpName": cmpName});
                    navEvt.fire();

                } else {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": cmp.get("v.stepId")});
                    navEvt.setParams({"cmpName": null});
                    navEvt.fire();
                    alert('Could not save data: ' + data.message);
                }

            } else if (state === "INCOMPLETE") {
                cmp.set("v.isLoading", false);
                console.log('Incomplete Callout');
            } else if (state === "ERROR") {
                cmp.set("v.isLoading", false);
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
     * @purpose Validates that a comp journal has been selected and is not null
     * @param cmp
     * @returns {*}
     */
    validateComp: function (cmp) {
        console.log('JP_JournalSelections validateComp...');

        var comp = cmp.get("v.selectedCOMP");
        if (comp == null && comp == undefined) {
            cmp.set("v.isLoading", false);
            var compJournal = cmp.find("comps").find("complimentaryJournalsOnline");
            $A.util.addClass(compJournal, 'slds-has-error');
            return false;
        }

        return this.validateJournalAddress(cmp);

    },

    /**
     * @purpose Validates that a journal address has been chosen. If the primary address has been chosen, it is copied into the journal address field.
     * @returns {*}
     */
    validateJournalAddress: function (cmp) {
        console.log('JP_JournalSelections validateJournalAddress...');

        console.log('journalAddress: ' + cmp.find('journalAddress').get('v.jAddress').Id);
        if(cmp.find('journalAddress').get('v.jAddress').Id==null || cmp.find('journalAddress').get('v.jAddress').Id==undefined) {
            cmp.find("journalAddress").set("v.recordError", 'You must select a shipping option.');
            return false;
        }

        return true;
    },

    /**
     * @purpose Retrieve salesOrder id parameter from URL
     * @returns {*}
     */
    getSalesOrderId: function (cmp) {
        var name = 'salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS, "i");
        var results = regex.exec(url);

        var SOId = results[1];
        return SOId;
    },

    /**
     * @purpose Retrieve step id parameter from URL
     * @returns {*}
     */
    getStepId: function () {
        var name = 'id';
        var url = location.href;
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS, "i");
        var results = regex.exec(url);

        if (results != null) {
            var stepId = results[1];
            return stepId;
        }
        return null;
    }

})
/**
 * Created by lauren.lezberg on 1/17/2019.
 */
({
    doInit: function (cmp, event, helper) {
        console.log('JP_JournalSelections init...');

        cmp.set("v.isLoading", true);
        helper.getJournalData(cmp, event);
    },

    /**
     * @purpose Handles COMP selection change or initialization
     * @param cmp
     * @param event
     * @param helper
     */
    compSelectChange: function (cmp, event, helper) {
        console.log('JP_JournalSelections compSelectChange...');
        var journals = cmp.get("v.journals");
        var selectedComp = cmp.get("v.compName");

        if (journals.length > 0) {
            helper.hideCompJournalFromBuyup(cmp, selectedComp, journals);
        } else {
            helper.getBuyUpJournals(cmp, event);
        }
    },

    /**
     * @purpose Handles Join Process step change event. Validates and consolidates all selections. If all selections are validated, saveSelection method is called and user moves forward or backward in process,
     * If selections are not validated, a null navigate event is fired and user will not move forward or backward.
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave: function (cmp, event, helper) {
        console.log('JP_JournalSelections handleSave...');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if (!cmp.get("v.isLoading")) {
            cmp.set("v.isLoading", true);

            var selected = [];

            if (cmp.get("v.isActiveMember")) {
                if (helper.validateComp(cmp)) {
                    cmp.set("v.isSaving", true);
                    var selections = cmp.find("journalItem");
                    selections.forEach(function (journal) {
                        if (journal.get("v.selected")) {
                            selected.push(journal.get("v.selectedItem"));
                        }
                    });
                    selected.push(cmp.get("v.selectedCOMP"));
                    helper.saveSelections(cmp, event, selected, stepId, cmpName);
                } else {
                    helper.getBuyUpJournals(cmp, event);
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": cmp.get("v.stepId")});
                    navEvt.setParams({"cmpName": null});
                    navEvt.fire();
                }
            } else {
                if (helper.validateJournalAddress(cmp)) {
                    cmp.set("v.isSaving", true);
                    var selections = cmp.find("journalItem");
                    selections.forEach(function (journal) {
                        if (journal.get("v.selected")) {
                            selected.push(journal.get("v.selectedItem"));
                        }
                    });
                    helper.saveSelections(cmp, event, selected, stepId, cmpName);
                } else {
                helper.getBuyUpJournals(cmp, event);
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": cmp.get("v.stepId")});
                navEvt.setParams({"cmpName": null});
                navEvt.fire();
            }

            }
        } else {
            helper.getBuyUpJournals(cmp, event);
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }

    },

})
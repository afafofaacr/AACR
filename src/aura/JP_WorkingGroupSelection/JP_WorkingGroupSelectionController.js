/**
 * Created by lauren.lezberg on 1/23/2019.
 */
({
    doInit: function (cmp, event, helper){
        console.log('JP_WorkingGroupSelection init...');
        helper.initialize(cmp, event);
    },

    /**
     * @purpose Handles join process StepChange event and calls saveSelections method to save all working group selections
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave :  function(cmp, event, helper){
        console.log('JP_WorkingGroupSelection handleSave...');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if(!cmp.get("v.isLoading")) {
            cmp.set("v.isLoading", true);
            var selected = [];
            var selections = cmp.find("workingGroupItem");
            selections.forEach(function (group) {
                if (group.get("v.isSelected")) {
                    selected.push(group.get("v.itemId"));
                }
            });
            cmp.set("v.selectedGroups", selected);
            helper.saveSelections(cmp, event, selected, stepId, cmpName);
        } else {
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }
    },
    
})
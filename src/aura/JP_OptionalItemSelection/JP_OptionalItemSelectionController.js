/**
 * Created by lauren.lezberg on 1/24/2019.
 */
({
    doInit: function (cmp, event, helper){
        helper.initialize(cmp, event);
    },

    handleSave : function(cmp, event, helper){
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var selected = [];
        var selections = cmp.find("optionalItem");
        selections.forEach(function(group){
            if(group.get("v.isSelected")){
                selected.push(group.get("v.itemId"));
            }
        });
        helper.saveSelections(cmp, event, selected, stepId, cmpName);
    },

    goNext : function(cmp, event, helper){
        var selected = [];
        var selections = cmp.find("optionalItem");
        selections.forEach(function(group){
            if(group.get("v.isSelected")){
                selected.push(group.get("v.itemId"));
            }
        });
        helper.saveSelections(cmp, event, selected);
    },

    goPrevious : function(cmp, event, helper){
        window.location.href = cmp.get("v.previousStepURL");
    },

    cancelJoin : function(cmp, event, helper){
        window.location.href = cmp.get("v.cancelURL");
    },
})
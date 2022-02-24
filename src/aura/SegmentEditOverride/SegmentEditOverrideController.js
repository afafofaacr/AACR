/**
 * Created by lauren.lezberg on 4/20/2020.
 */
({

    closeModal : function(cmp, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:SegmentManager",
        });
        evt.fire();
    }
})
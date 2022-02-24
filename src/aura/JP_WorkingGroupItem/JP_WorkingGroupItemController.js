/**
 * Created by lauren.lezberg on 1/23/2019.
 */
({

    addToList : function(cmp, event, helper){
        console.log('JP_WorkingGroupItem addToList...');

        if(cmp.get("v.isSelected")) {
            cmp.set("v.isSelected", false);
        } else {
            cmp.set("v.isSelected", true);
        }
    }
})
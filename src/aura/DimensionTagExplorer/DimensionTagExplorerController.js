/**
 * Created by afaf.awad on 6/4/2021.
 */

({
    updateFilter : function(cmp,event,helper){
        let objFilters = cmp.get('v.objectFilters');
        let target = event.getSource().get('v.name');
        let button = cmp.find(target);
        if(button.get('v.variant') == 'neutral') {
            button.set('v.variant', 'brand');
            objFilters.push(button.get('v.label'));
        }else{
            button.set('v.variant', 'neutral');
            objFilters = objFilters.filter(e => e !== button.get('v.label'));
        }
        console.log(objFilters);
        cmp.set('v.objectFilters', objFilters);
    },

    openNewTagModal : function(cmp, event, helper){
        cmp.find('DimTagModal').set("v.isOpen", true);
    },

    // keyPressController : function(cmp, event, helper) {
    //     let getInputkeyWord = cmp.get("v.searchString");
    //     if( getInputkeyWord.length > 0 ){
    //         helper.searchHelper(cmp,event,getInputkeyWord);
    //     }
    // },
});
/**
 * Created by lauren.lezberg on 1/6/2021.
 */

({

    handleRemove : function(cmp, event,helper){
        var option = event.getSource().get("v.name");
        console.log('remove element: ' + option);
        var selected = cmp.get("v.selected");
        selected.forEach(function(opt, idx){
            if(opt == option){
                selected.splice(idx, 1);
            }
        });

        var available = cmp.get("v.available");
        available.push(option);
        available.sort((a, b) => {
            if (a < b)
                return -1;
            if (a> b)
                return 1;
            return 0;
        });
        cmp.set("v.available", available);

        cmp.set("v.selected", selected);

        $A.util.addClass(cmp.find('avail'), 'slds-hide');
    },

    handleAdd : function(cmp, event , helper){
        console.log('handleAdd..');
        var option = event.target.id;
        var available = cmp.get("v.available");
        available.forEach(function(opt, idx){
            if(opt == option){
                available.splice(idx, 1);
            }
        });

        var selected = cmp.get("v.selected");
        selected.push(option);
        cmp.set("v.selected", selected);

        cmp.set("v.available", available);

        $A.util.addClass(cmp.find('avail'), 'slds-hide');
    },


    openOptions: function(cmp, event, helper){
        console.log('openOptions');
        $A.util.removeClass(cmp.find('avail'), 'slds-hide');
    },

    closeOptions: function(cmp, event, helper){
        console.log('closeOptions');
        $A.util.addClass(cmp.find('avail'), 'slds-hide');
    }
});
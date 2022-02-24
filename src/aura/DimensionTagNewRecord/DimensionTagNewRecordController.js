/**
 * Created by afaf.awad on 6/7/2021.
 */

({
    onSuccess : function (cmp,event,helper){
        cmp.find('objectLookup').set('v.value', null);
        let cmpEvent = cmp.getEvent('callDimTagEvent');
        cmpEvent.setParams({
            'action' : 'refresh'
        })
        cmpEvent.fire();

    },

    cancel : function(cmp,event,helper){
        let cmpEvent = cmp.getEvent('callDimTagEvent');
        cmpEvent.setParams({
            'action' : 'destroy'
        })
        cmpEvent.fire();
    }
});
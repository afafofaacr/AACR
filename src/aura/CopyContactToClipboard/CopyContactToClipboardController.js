(
    {
    doInit : function(component, event, helper) {
        },

    copyContact : function(component, event, helper){

        component.set('v.copying',true);
        var action = component.get("c.getContactData");
        action.setParams({
            contactId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var conData = response.getReturnValue();
                component.set("v.CopiedContactData",conData);

                component.find('holdtext').getElement().value= conData;
                var holdtxt = component.find('holdtext').getElement();
                console.log('holdtxt = ' + JSON.stringify(holdtxt));
                holdtxt.select();
                document.queryCommandSupported('copy');
                document.execCommand('copy');

                component.set('v.copying',false);
            }
        });
        $A.enqueueAction(action);
     }

})
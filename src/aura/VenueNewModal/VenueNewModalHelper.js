/**
 * Created by lauren.lezberg on 3/12/2020.
 */
({
    refresh : function(component, event, helper) {
        var action = component.get('c.myController');
        action.setCallback(component,
            function(response) {
                var state = response.getState();
                if (state === 'SUCCESS'){
                    $A.get('e.force:refreshView').fire();
                } else {
                    console.log('Callout Error - refresh');
                }
            }
        );
        $A.enqueueAction(action);
    }
})
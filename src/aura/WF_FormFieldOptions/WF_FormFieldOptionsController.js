/**
 * Created by afaf.awad on 10/6/2021.
 */

({

    startDrag : function(cmp, event) {
        let target = event.target.id;

        console.log('target id == ' + event.target.id);
        let appEvent = $A.get("e.c:WF_AppEvent");
        appEvent.setParams({
            "fieldName" : event.dataTransfer.setData('Text', target),
            "fieldCategory" : event.target.title
        });
        appEvent.fire();
    }
});
/**
 * Created by lauren.lezberg on 11/12/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('eventId:' ,  helper.getEventId(cmp, event));
        var eventId = helper.getEventId(cmp, event);
        if(eventId!=null) {
            cmp.find("editForm").set("v.recordId", eventId);
        }
    },
})
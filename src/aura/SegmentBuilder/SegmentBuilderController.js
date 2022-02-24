/**
 * Created by lauren.lezberg on 4/7/2020.
 */
({
    doInit : function(cmp,event, helper){
        var recordId = cmp.get("v.recordId");
        console.log("recordId: " + recordId);
        if(recordId!=undefined){
            cmp.find("recordForm").set("v.recordId", recordId);
        }
    },


    runPreviewQuery : function(cmp, event, helper){
        cmp.set("v.loadingPreview", true);
        cmp.set("v.previewOpen", true);
        var queryString = cmp.find('queryString').get("v.value");

        helper.getPreviewResults(cmp);


    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.previewResults", null);
        cmp.set("v.previewOpen", false);
    },


    getFieldValuePairs: function(cmp, event, helper){

        // var queryString = cmp.find('queryString').get("v.value");
        //
        // if(queryString!=null && queryString!=undefined) {
        //     cmp.find("recordForm").submit();
        //     helper.buildQueryString(cmp, event);
        // } else {
            helper.buildQueryString(cmp, event);
        // }
    },

    handleSuccess : function(cmp, event, helper){
        var payload = event.getParams();
        console.log(JSON.stringify(payload));
        // window.location.href = '/' + payload.id;

        cmp.find('conFields').refresh();
        cmp.find('accFields').refresh();

        helper.resetForm(cmp, event);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":'success',
            "title": "Success!",
            "message": "Segment saved successfully."
        });
        toastEvent.fire();

        setTimeout(function() {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:SegmentManager",

            });
            evt.fire();
        }, 2000);
    }



})
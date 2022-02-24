/**
 * Created by lauren.lezberg on 4/16/2020.
 */
({
    buildQueryString : function(cmp, event){
        var conFields = cmp.find('conFields').get("v.selectedList");
        var accFields = cmp.find('accFields').get("v.selectedList");

        var action = cmp.get("c.getQueryString");
        action.setParams({
            "conJSON": JSON.stringify(conFields),
            "accJSON": JSON.stringify(accFields)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + data);
                cmp.find('queryString').set("v.value", data);

                cmp.find("recordForm").submit();
            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get query string - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get query string: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },



    resetForm: function(cmp, event) {
        console.log('resetForm...');
        cmp.set("v.recordId", null);
        console.log('fields: ' + cmp.find('field'));
        cmp.find('field').forEach(function(f) {
            f.set("v.value", null);
        });
        cmp.find('queryString').set("v.value", null);
    },

    getPreviewResults: function(cmp){
        var conFields = cmp.find('conFields').get("v.selectedList");
        var accFields = cmp.find('accFields').get("v.selectedList");

        var action = cmp.get("c.getQueryResults");
        action.setParams({
            "conJSON": JSON.stringify(conFields),
            "accJSON": JSON.stringify(accFields)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));

                if(data.length!=0) {
                    cmp.set('v.columns', [
                        {label: 'Name', fieldName: 'Name', type: 'text'},
                        {label: 'AACR ID', fieldName: 'AACR_ID__c', type: 'text'},
                        {label: 'Member Type', fieldName: 'Member_Type__c', type: 'text'},
                        {label: 'Record Type', fieldName: 'RT_ByName__c', type: 'text'},
                        {label: 'Income Level', fieldName: 'Income_Level__c', type: 'text'}
                    ]);
                    cmp.set("v.previewResults", data);

                }
                cmp.set("v.loadingPreview", false);
                // cmp.set("v.columns", data);
                // cmp.set("v.previewResults", [{
                //     Member_Type__c: 'Active Member',
                //     Membership_Status__c: 'Current'
                // },
                //     {
                //         Member_Type__c: 'Active Member',
                //         Membership_Status__c: 'Current'
                //     }])

            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get query string - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get query string: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})
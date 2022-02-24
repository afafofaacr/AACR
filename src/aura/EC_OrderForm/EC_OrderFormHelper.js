/**
 * Created by afaf.awad on 2/8/2021.
 */

({
    getOrderId : function(cmp){
        var name ='c__orderId';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },

    getSelectedRows : function(cmp,table){
        var list=[];
        var rows = cmp.find(table).getSelectedRows();
        for (var i = 0; i < rows.length; i++){
            list.push(rows[i].option);
        }
        return list;
    },

    saveRecord: function(cmp){
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = cmp.get("c.saveOrder");
                action.setParams({
                    orderId: cmp.get('v.orderId'),
                    orderName: cmp.find('orderName').get('v.value'),
                    countryJson: JSON.stringify(cmp.find('countryTable').getSelectedRows()),
                    attendeeJson: JSON.stringify(cmp.find('attendeeTable').getSelectedRows()),
                    degreeJson: JSON.stringify(cmp.find('degreeTable').getSelectedRows()),
                    institutionJson: JSON.stringify(cmp.find('institutionTable').getSelectedRows()),
                    organJson: JSON.stringify(cmp.find('organTable').getSelectedRows()),
                    researchJson: JSON.stringify(cmp.find('researchTable').getSelectedRows()),
                });
                action.setCallback(this, result => {
                    switch (result.getState()) {
                        case "SUCCESS":
                            resolve(result.getReturnValue());
                            break;
                        case "INCOMPLETE": console.log('INCOMPLETE.');
                        case "ERROR": reject(result.getError());
                    }
                });
                $A.enqueueAction(action);
            })
        );
    },

    validate : function(cmp) {
        console.log('validating email info...');
        let isValid = true;

        let validateField = auraId => {
            var field = cmp.find(auraId);
            var fieldVal = field.get("v.value");
            if (!fieldVal) {
                $A.util.addClass(field, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(field, 'slds-has-error');
            }
            return isValid;
        }

        isValid = validateField('orderName');
        console.log('isvalid = ' +  isValid);
        return isValid;
    },


    handleSuccess: function (cmp, event, helper) {
        // console.log('handleSuccess...');
        cmp.set("v.isLoading", true);

        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();


    },

    handleError: function (cmp, event, helper) {
        cmp.set("v.isLoading", false);
        var errors = event.getParams();
        console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.nextStepId");
        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },
});
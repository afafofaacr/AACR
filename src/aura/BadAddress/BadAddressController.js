/**
 * Created by afaf.awad on 10/27/2020.
 */

({
    handleContactChange : function(cmp, event, helper){

        if(cmp.get('v.contactId') == null){
            $A.get('e.force:refreshView').fire();
            // cmp.set('v.knownAddress', null);
            // cmp.set('v.contact', null);
        }else {
            console.log('Getting contact...');
            var value = event.getParam("value");
            cmp.set("v.contactId", value);

            var action = cmp.get("c.getContactInfo");
            action.setParams({
                'contactId': value
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse) {
                        console.log('Contact::: ' + JSON.stringify(storeResponse.reasonList));

                        //RTS Picklist
                        var reasons = storeResponse.reasonList;
                        var custs = [];
                        for(var key in reasons){
                            custs.push({label:reasons[key], value:key});
                        }

                        let ka = storeResponse.knownAddresses;
                        if(ka.length !== 0) {
                            console.log('returned response == ' + JSON.stringify(ka));
                            ka.forEach(function (row) {
                                row.isBadAddress = false;
                                row.rtsReason = '';
                                row.rtsReasonOther = '';
                            });
                        }

                        cmp.set("v.reasonList", custs);
                        cmp.set('v.contact', storeResponse.contact);
                        cmp.set('v.knownAddress', ka);
                        cmp.set('v.error', storeResponse.duplicate);
                        cmp.set('v.errorMessage', 'This contact has a duplicate. No edits can be saved until the duplicates are resolved.');
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    handleSubmit : function(cmp,event,helper){
        cmp.set('v.error', false);

        if(helper.validation(cmp)) {
            cmp.set('v.processing', true);
            console.log('creating contact object');

            var conId = cmp.get('v.contactId');
            var audit = [];
            let kaIds =[];
            var record = {};
            let addresses = cmp.get('v.knownAddress');

            addresses.forEach(function(row){
                if(row.isBadAddress){
                    record.Contact__c = conId;
                    record.Bad_Address__c = row.isBadAddress;
                    record.Return_Sender_Reason__c = row.rtsReason;
                    record.Other_Reason__c = row.rtsReasonOther;
                    record.Address_Type__c = row.Type__c;
                    record.Known_Address__c = row.Id;
                    audit.push(JSON.stringify(record));
                    kaIds.push(row.Id);
                }
            });
            console.log('audit = ' + audit);
            console.log('kaIds = ' + kaIds);
            helper.saveRecords(cmp, audit, kaIds);
        }
    },
});
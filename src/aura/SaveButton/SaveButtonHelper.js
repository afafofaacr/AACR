/**
 * Created by afaf.awad on 1/29/2020.
 */
({
    // getList : function(cmp, event, options){
    //     var items = [];
    //     options.forEach(function(option){
    //         var item = {
    //             "label": option,
    //             "value": option,
    //         };
    //         items.push(item);
    //     });
    //     return items;
    // },
    //
    // createMultiPickListEntry : function(list) {
    //     var response = '';
    //     list.forEach(function (val) {
    //         response += val + ';'
    //     })
    //     console.log(response);
    //     return response;
    // },
    //
    // validateData : function(cmp, event){
    //     console.log('validating data');
    //     var isValid = true;
    //     var contact = cmp.get("v.contactRecord");
    //     // var majorFocus = cmp.get("v.majorFocusValues");
    //
    //     if(contact.Major_Focus__c == null){
    //         console.log("majorFocusValues= " + majorFocus);
    //         var majorFocus= cmp.find("majorFocus");
    //         majorFocus.showHelpMessageIfInvalid();
    //         isValid =  false;
    //     }
    //
    //     if(contact.Primary_Research_Area_of_Expertise__c == 'Other (please specify) | other' && contact.Other_Research_Areas__c == null){
    //         var otherResearch = cmp.find("otherResearch");
    //         otherResearch.showHelpMessageIfInvalid();
    //         isValid = false;
    //     }
    //     if(isValid){
    //         this.updateData(cmp);
    //     }
    //
    //     return isValid;
    // },
    //
    //
    // updateData :function(cmp){
    //     console.log('updating contact');
    //     var contact = cmp.get("v.contactRecord");
    //     if(cmp.get("v.organSiteValues").length>0) {
    //         contact.Organ_Sites__c = this.createMultiPickListEntry(cmp.get("v.organSiteValues"));
    //     }
    //     if(cmp.get("v.specificResearchValues").length>0) {
    //         contact.Specific_Research_Areas__c = this.createMultiPickListEntry(cmp.get("v.specificResearchValues"));
    //     }
    //     if(cmp.get("v.addResearchValues").length>0) {
    //         contact.Additional_Research_Areas__c = this.createMultiPickListEntry(cmp.get("v.addResearchValues"));
    //     }
    //     cmp.set("v.contactRecord", contact);
    // },
    //
    // saveData : function(cmp, stepId) {
    //     console.log('saving contact');
    //     var action = cmp.get("c.updateContactRecord");
    //     action.setParams({
    //         "con" : cmp.get("v.contactRecord")
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var data = response.getReturnValue();
    //         }
    //         else if (state === "INCOMPLETE") {
    //             console.log('Incomplete Callout');
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " +
    //                         errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    //
    // getStepId : function(){
    //     var name ='id';
    //     var url = location.href;
    //     name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    //     name = name.toLowerCase();
    //     var regexS = "[\\?&]"+name+"=([^&#]*)";
    //     var regex = new RegExp( regexS, "i" );
    //     var results = regex.exec( url );
    //
    //     if(results!=null){
    //         var stepId=results[1];
    //         console.log(stepId);
    //         return stepId;
    //     }
    //     return null;
    // }
})
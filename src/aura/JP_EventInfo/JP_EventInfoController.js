/**
 * Created by lauren.lezberg on 11/6/2019.
 */
({

    doInit : function(cmp, event, helper){
        var eventId = helper.getEventId(cmp, event);
        cmp.set("v.eventId", eventId);

        if(eventId!=null) {
            cmp.find("editForm").set("v.recordId", eventId);
        }

        helper.getDefaultZone(cmp, event);
        cmp.set("v.processing", false);
        cmp.set("v.modalOpen", false);
    },

    handleStageChange : function(cmp, event, helper){
        var value = event.getParam("value");
        if(value=='Virtual'){
            //hide physical venue
            $A.util.addClass(cmp.find("pVenue"), 'slds-hide');
            $A.util.addClass(cmp.find("map"), 'slds-hide');
            $A.util.removeClass(cmp.find("vVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("hideDate"), 'slds-hide');
            cmp.set("v.pVenueId", null);
            cmp.find('pVenue').clearAccount();

        } else if(value == 'In Person') {
            //hide virtual venue
            $A.util.addClass(cmp.find("vVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("pVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("map"), 'slds-hide');
            $A.util.addClass(cmp.find("hideDate"), 'slds-hide');
            cmp.find('hideDate').set("v.value",false);
            cmp.set("v.vVenueId", null);
            cmp.find('vVenue').clearAccount();
        } else if(value=='Hybrid') {
            $A.util.removeClass(cmp.find("pVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("map"), 'slds-hide');
            $A.util.removeClass(cmp.find("vVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("hideDate"), 'slds-hide');
        }
    },

    handleCategoryChange : function(cmp, event, helper){
        var value = event.getParam("value");
        if(value=='Joint'){
            //show joint provider institution
            $A.util.removeClass(cmp.find("jpInstitution"), 'slds-hide');

        } else {
            //hide joint provider institution
            $A.util.addClass(cmp.find("jpInstitution"), 'slds-hide');
        }
    },

    handleTicketLabelChange : function(cmp, event, helper){
        console.log('handleTicketLabelChange...');
        if(cmp.find("tLabel").get("v.value")==null || cmp.find("tLabel").get("v.value")==undefined || cmp.find("tLabel").get("v.value")==''){
            if(cmp.find("evtName").get("v.value").length<73) {
                cmp.find('tLabel').set("v.value", cmp.find("evtName").get("v.value"));
                cmp.find('tLabel2').set("v.value", cmp.find("evtName").get("v.value"));
            }
        }
    },

    populateTLabel : function(cmp, event, helper){
        console.log('populateTLabel...');
        cmp.find('tLabel2').set("v.value", cmp.find("tLabel").get("v.value"));
    },

    handleVenueChange : function(cmp, event, helper){

        var value = event.getParam("value");
        cmp.set("v.pVenueId", value);

        cmp.find('pVenue').refreshLookup();

        if(value!=null) {
            helper.getVenueAddress(cmp, value);
        }
    },


    openModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", true);
    },


    handleLoad : function(cmp, event, helper){

        var stage = cmp.find('stage').get("v.value");
        var vVenueId = cmp.find("virtualVenue").get("v.value");
        // console.log('vVenueId: ', vVenueId);


        if(vVenueId!=null){
            cmp.set("v.vVenueId", vVenueId);
            cmp.find("vVenue").refreshLookup();


        }

        var venueId = cmp.find("venue").get("v.value");

        if(venueId!=null) {
            cmp.set("v.pVenueId", venueId);
            cmp.find("pVenue").refreshLookup();

            helper.getVenueAddress(cmp, venueId);
        }

        if(stage == 'Virtual'){
            $A.util.addClass(cmp.find("pVenue"), 'slds-hide');
            $A.util.addClass(cmp.find("map"), 'slds-hide');
            $A.util.removeClass(cmp.find("vVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("hideDate"), 'slds-hide');
        } else if(stage=='In Person'){
            $A.util.addClass(cmp.find("vVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("pVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("map"), 'slds-hide');
            $A.util.addClass(cmp.find("hideDate"), 'slds-hide');
        } else {
            $A.util.removeClass(cmp.find("vVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("hideDate"), 'slds-hide');
            $A.util.removeClass(cmp.find("pVenue"), 'slds-hide');
            $A.util.removeClass(cmp.find("map"), 'slds-hide');
        }

        if(cmp.find('category').get("v.value")=='Joint'){
            //show joint provider institution
            $A.util.removeClass(cmp.find("jpInstitution"), 'slds-hide');
        }

        //Set up Letter of Participation Formats

        var lopField = cmp.find("lopField").get("v.value");
        // console.log('lopFIeld: ' + cmp.find("lopField").get("v.value"));
        var formatString = '<span style=\'font-family: verdana; font-size: 16px;\'>' + (lopField == null? '': lopField)  + '</span>';
        cmp.find('lopInput').set("v.value", formatString);

        var loiField = cmp.find("loiField").get("v.value");
        console.log('loiField: ' + cmp.find("loiField").get("v.value"));
        var formatStringLOI = '<span style=\'font-family: verdana; font-size: 16px;\'>' + (loiField == null? '': loiField)  + '</span>';
        cmp.find('loiInput').set("v.value", formatStringLOI);


        // console.log('parentEvt: ' + cmp.find('parentEvt').get("v.value"));
        cmp.find('evtLookup').set("v.selectedId", cmp.find('parentEvt').get("v.value"));
        cmp.find('evtLookup').refreshLookup();

    },

    handleError: function(cmp, event, helper) {

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": cmp.get("v.stepId")});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

    handleSuccess: function(cmp, event, helper) { 
        var params = event.getParams();
        // console.log('recordId: ' + params.response.id);

        if(params.response.id!=undefined || params.response.id != null) {

            cmp.set('v.disabled', true);
            cmp.set('v.recordId', params.response.id);

            var action = cmp.get("c.createTicketItem");
            action.setParams({
                "eventId" : params.response.id
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //if there is no event id present in the URL, update url param with new eventId
                    helper.addEventIdToURL(cmp, params.response.id);

                    console.log('time to redirect...');

                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": cmp.get("v.nextStepId")});
                    navEvt.setParams({"cmpName": cmp.get("v.nextCmpName")});
                    navEvt.fire();

                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete callout - handleSuccess");
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);


        } else {
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }

    },

    onStepChange:function(cmp, event, helper){
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);


        // console.log("stage: " + cmp.find('stage').get("v.value"));


        if(helper.validateInput(cmp)){

            cmp.find("venue").set("v.value", cmp.get("v.pVenueId"));

            cmp.find("virtualVenue").set("v.value", cmp.get("v.vVenueId"));

            helper.handleLetterFormats(cmp);

            cmp.find('parentEvt').set("v.value",cmp.find('evtLookup').get("v.selectedId"));

            cmp.find('editForm').submit();
        }
        else {
            helper.showToast(cmp, event, 'error', 'Please fill out all required fields.');
        }

    },
})
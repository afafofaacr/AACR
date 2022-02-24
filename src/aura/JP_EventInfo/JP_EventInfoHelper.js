/**
 * Created by lauren.lezberg on 11/11/2019.
 */
({
    validateInput: function(cmp){
        var isValid = true;
        if(cmp.find("stage").get("v.value")==null || cmp.find("stage").get("v.value")==''){
            isValid = false;
            $A.util.addClass(cmp.find('stage'), "slds-has-error");
        } else {
            $A.util.removeClass(cmp.find('stage'), "slds-has-error");

        }

        if(cmp.get("v.eventId")==null) {
            if (cmp.find("tLabel").get("v.value") == null || cmp.find("tLabel").get("v.value") == '') {
                isValid = false;
                $A.util.addClass(cmp.find('tLabel'), "slds-has-error");
            } else {
                $A.util.removeClass(cmp.find('tLabel'), "slds-has-error");

            }
        }




        return isValid;

    },


    getEventId : function(cmp, event){
        var name ='c__event';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1];
        }

        return null;
    },
    
    showToast : function(component, event, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },

    getVenueAddress : function(cmp, venueId){
        console.log('getVenue with venueId: ' + venueId);
        var action = cmp.get("c.getVenue");
        action.setParams({
            "venueId": venueId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));

                if(data!=null) {
                    var streetVal = data.Street_1__c;
                    if (data.Street_2__c != null) {
                        streetVal += ', ' + data.Street_2__c;
                    }
                    if (data.Street_3__c != null) {
                        streetVal += ', ' + data.Street_3__c;
                    }

                    cmp.set('v.mapMarkers', [
                        {
                            location: {
                                Street: streetVal,
                                City: data.City__c != null ? data.City__c : '',
                                PostalCode: data.Zip__c != null ? data.Zip__c : '',
                                State: data.State__c != null ? data.State__c : '',
                                Country: data.Country__c != null ? data.Country__c : ''
                            },
                        }
                    ]);

                } else {
                    cmp.set('v.mapMarkers', []);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete callout: getVenue')
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
    },

    getDefaultZone : function(cmp, event){
        var action = cmp.get("c.getZone");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.zoneId", response.getReturnValue());

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getDefaultZone");
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
    },


    addEventIdToURL : function(cmp, eventId){
        var key = 'c__event';
        var value = eventId;
        var kvp = document.location.search.substr(1).split('&');
        // console.log('kvp: ', kvp);
        var i = kvp.length;
        var x;
        while (i--) {
            x = kvp[i].split('=');

            if (x[0] == key) {
                x[1] = value;
                kvp[i] = x.join('=');
                break;
            }
        }

        if (i < 0) {
            kvp[kvp.length] = [key, value].join('=');
        }

        // console.log('kvp: ' + kvp.join('&'));

        window.history.pushState({urlPath: 'c__BAMContainer?' + kvp.join('&')}, document.title, 'c__BAMContainer?' + kvp.join('&'));
    },

    handleLetterFormats : function (cmp){

        if(cmp.find("lopInput").get("v.value") != cmp.find("lopField").get("v.value")){
            if(cmp.find("lopInput").get("v.value")) {

                // var appliedFormats = {
                //     font: 'verdana',
                //     size: 16
                // };
                // var editor = cmp.find("lopInput");
                // editor.setFormat(appliedFormats);
                console.log('LOPInput: ' + cmp.find("lopInput").get("v.value"));
            }

                cmp.find('lopField').set("v.value", '<p>' + cmp.find("lopInput").get("v.value") + '</p>');
        }

        if(cmp.find("loiInput").get("v.value") != cmp.find("loiField").get("v.value")){
            cmp.find('loiField').set("v.value", '<p>' + cmp.find("loiInput").get("v.value") + '</p>');
        }

    }
})
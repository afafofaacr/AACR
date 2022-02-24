({
    getItem: function (cmp, callback) {
        // console.log('getItem: ' + cmp.get("v.id"));
        var action = cmp.get('c.getEvent'),
            spinner = cmp.find('spinner'),
            communityPrefix = '';

        if(typeof $A.get("$SfdcSite") !== 'undefined'){
            communityPrefix = $A.get("$SfdcSite").pathPrefix;
        }

        $A.util.removeClass(spinner, "slds-hide");

        action.setParams({
            recordId: cmp.get('v.id')
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();
                // console.log('getItem resval: ' + JSON.stringify(resVal));

            if (state === 'SUCCESS') {
                cmp.set('v.item', resVal);

                //set map marker
                if(resVal.venue!=null) {
                    var streetVal = resVal.venue.Street_1__c;
                    if (resVal.venue.Street_2__c != null) {
                        streetVal += ', ' + resVal.venue.Street_2__c;
                    }
                    if (resVal.venue.Street_3__c != null) {
                        streetVal += ', ' + resVal.venue.Street_3__c;
                    }
                    cmp.set('v.mapMarkers', [
                        {
                            location: {
                                Street: streetVal,
                                City: resVal.venue.City__c != null ? resVal.venue.City__c : '',
                                PostalCode: resVal.venue.Zip__c != null ? resVal.venue.Zip__c : '',
                                State: resVal.venue.State__c != null ? resVal.venue.State__c : '',
                                Country: resVal.venue.Country__c != null ? resVal.venue.Country__c : ''
                            },
                        }
                    ]);
                }

                if (resVal.item.hasOwnProperty('BR_Participations__r')) {
                    var rsvpStatus = resVal.item.BR_Participations__r[0].Participate__c,
                        goingBtnYesItem = cmp.find('goingBtnYesItem'),
                        goingBtnNoItem = cmp.find('goingBtnNoItem'),
                        goingBtn2YesItem = cmp.find('goingBtn2YesItem'),
                        goingBtn2NoItem = cmp.find('goingBtn2NoItem');

                    if (rsvpStatus === 'Yes') {
                        cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_going"));
                        $A.util.addClass(goingBtnYesItem, 'slds-is-selected');
                        $A.util.addClass(goingBtn2YesItem, 'slds-is-selected');
                    } else if (rsvpStatus === 'No') {
                        cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_not_going"));
                        $A.util.addClass(goingBtnNoItem, 'slds-is-selected');
                        $A.util.addClass(goingBtn2NoItem, 'slds-is-selected');
                    } else {
                        cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_are_u_going"));
                    }
                } else {
                    cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_are_u_going"));
                }

                var mainImageFilename = resVal.item.Main_Image_Filename__c;

                if(mainImageFilename && mainImageFilename.length > 0){
                    if (mainImageFilename.startsWith('http://') || mainImageFilename.startsWith('https://')) {
                        cmp.set('v.itemMainImage', mainImageFilename);
                    } else {
                        this.getItemMainImage(cmp, mainImageFilename, communityPrefix);
                    }
                } else{
                    cmp.set('v.itemMainImage', communityPrefix + '/resource/BrEvents/images/main-banner.jpg');
                }

                cmp.set('v.hideAttendees', resVal.item.Hide_attendees__c);
                cmp.set('v.attendeesLimit', resVal.item.Limit_of_attendees__c);
                cmp.set('v.listImageFilename', resVal.item.List_Image_Filename__c);

                if (typeof callback === 'function') {
                    callback();
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            $A.util.addClass(spinner, "slds-hide");
        });

        $A.enqueueAction(action);
    },

    attendVirtualMeeting : function(cmp, eventId){
        // console.log('attending virtual meeting...');
        var action = cmp.get('c.goToVirtualMeeting');

        action.setParams({
            "eventId" : eventId
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === 'SUCCESS') {
                var resVal = response.getReturnValue();
                if(resVal!=null){
                    window.open(resVal, '_blank');
                }
            }  else if (state === "INCOMPLETE") {
                console.log('Could not attend virtual meeting: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not attend virtual meeting - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not attend virtual meeting: Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    getItemParticipations: function (cmp, callback) {
        var action = cmp.get('c.getParticipations');

        action.setParams({
            recordId: cmp.get('v.id')
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();


            if (state === 'SUCCESS') {
                cmp.set('v.itemParticipations', resVal);

                if (typeof callback === 'function') {
                    callback();
                }
            }
        });

        $A.enqueueAction(action);
    },

    getItemMainImage: function(cmp, mainImageFilename, communityPrefix){
        var action = cmp.get('c.getEventMainImage');

        action.setParams({
            recordId: cmp.get('v.id'),
            mainImageName: mainImageFilename
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {

                if(resVal !== null){
                    cmp.set('v.itemMainImage', communityPrefix + resVal);
                } else {
                    cmp.set('v.itemMainImage', communityPrefix + '/resource/BrEvents/images/main-banner.jpg');
                }
            }
        });

        $A.enqueueAction(action);
    },

    getAttendeesCount: function(cmp, callback){
        var action = cmp.get('c.getAttendeesCount');

        action.setParams({
            recordId: cmp.get('v.id')
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();


            if (state === 'SUCCESS') {
                cmp.set('v.attendeesCount', resVal);

                if (typeof callback === 'function') {
                    callback();
                }
            }
        });

        $A.enqueueAction(action);
    },

    rsvpItem: function(cmp, rsvpType, callback) {

        var action = cmp.get('c.rsvpEvent');

        action.setParams({
            recordId: cmp.get('v.id'),
            rsvpType: rsvpType,
            attendeesLimit: cmp.get('v.attendeesLimit')
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();


            if (state === 'SUCCESS') {
                if (typeof callback === 'function') {
                    callback(resVal);
                }
            }
        });

        $A.enqueueAction(action);
    },

    toggleGoingDropdown: function (cmp) {
        var goingBtn = cmp.find('dropdown-wrapper-going'),
            goingBtn2 = cmp.find('dropdown-wrapper-going2');
        $A.util.toggleClass(goingBtn, 'slds-is-open');
        $A.util.toggleClass(goingBtn2, 'slds-is-open');
    }
})
/**
 * Created by afaf.awad on 2/19/2021.
 */

({
    getOrderId: function (cmp) {
        var name = 'c__orderId';
        var url = location.href;
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS, "i");
        var results = regex.exec(url);
        if (results != null) {
            var SOId = results[1];
            return SOId;
        }
        return null;
    },

    getAvailableTimes : function (cmp){
        console.log('scheduleId = ' + cmp.get("v.scheduleId"));
        console.log('selectedDate = ' + cmp.get('v.selectedDate'));

        var action = cmp.get("c.getTimeSlots");
        action.setParams({
            "scheduleId": cmp.get("v.scheduleId"),
            "selectedDate": cmp.get('v.selectedDate')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data != '[]') {
                    // console.log('data: ' + JSON.stringify(data));
                    this.divideTimeSlots(cmp, data);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Error: Incomplete callout.");
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

    divideTimeSlots: function (cmp, timeSlots) {
        var date = new Date(cmp.get('v.selectedDate'));
        // var schedule = cmp.get('v.schedule');
        var ap = ['AM', 'PM']; // AM-PM

        console.log('date picked = ' + JSON.stringify(date));

        // START TIMES
        var startTimes = []; // time array
        var tt = 0; // start time
        //loop to increment the time and push results in array
        for (var i = 0; tt < 24 * 60; i++) {
            var hh = Math.floor(tt / 60); // getting hours of day in 0-24 format
            var mm = (tt % 60); // getting minutes of the hour in 0-55 format
            startTimes[i] = ("0" + (hh % 12)).slice(-2) + ':' + ("0" + mm).slice(-2) + ap[Math.floor(hh / 12)]; // pushing data in array in [00:00 - 12:00 AM/PM format]
            tt = tt + 60; //60 minutes
        }

        // END TIMES
        var endTimes = []; // time array
        tt = 60; // start time
        //loop to increment the time and push results in array
        for (var i = 0; tt < 24 * 60; i++) {
            var hh = Math.floor(tt / 60); // getting hours of day in 0-24 format
            var mm = (tt % 60); // getting minutes of the hour in 0-55 format
            endTimes[i] = ("0" + (hh % 12)).slice(-2) + ':' + ("0" + mm).slice(-2) + ap[Math.floor(hh / 12)]; // pushing data in array in [00:00 - 12:00 AM/PM format]
            tt = tt + 60; //60 minutes
        }
        endTimes[23] = '12:00AM'; //Add midnight to endTimes array.

        //BUILD TIME RANGES
        var timesList = [];

        for (var i = 0; i < startTimes.length; i++) {
            timesList[i] = startTimes[i].replace('00:00', '12:00') + ' - ' + endTimes[i].replace('00:00', '12:00');
        }

        // console.log('Time Ranges == ' + JSON.stringify(timesList));
        // console.log('TimeSlots == ' + JSON.stringify(timeSlots));
        var finalTimeSlots = [];
        var takenTimes = [];
        var blockedTimes = [];
        var help = this; //giving "this" and alis; doesn't work inside a forEach loop.

        if (JSON.stringify(timeSlots != '[]')) {
            timeSlots.forEach(function (time) {
                var formatTime = help.convertMiliseconds(cmp,time.Start_Time__c).replace('00:00', '12:00') + ' - ' + help.convertMiliseconds(cmp,time.End_Time__c).replace('00:00', '12:00');
                // console.log('formatted Time to compare == ' + formatTime);
                // console.log('is time blocked == ' + time.Blocked__c);
                if (time.Blocked__c) {
                    blockedTimes.push(formatTime);
                } else {
                    takenTimes.push(formatTime);
                }
            });

            // console.log('BlockedTimes == ' + JSON.stringify(blockedTimes));

            timesList.forEach(function (range) {
                if (takenTimes.includes(range)) {
                    finalTimeSlots.push({timeRange: range, marked: 'taken'});
                } else if (blockedTimes.includes(range)) {
                    finalTimeSlots.push({timeRange: range, marked: 'blocked'});
                } else {
                    finalTimeSlots.push({timeRange: range, marked: 'free'});
                }
            });
        }else{
            console.log('timeSlots isEmpty...');
            timesList.forEach(function (range) {
                    finalTimeSlots.push({timeRange: range, marked: 'free'});
            });
        }
        // console.log('FinalTimeRanges: ' + JSON.stringify(finalTimeSlots));

        cmp.set('v.timeSlots', finalTimeSlots);

    },

    //CONVERT RETURN START/END TIMES TO PROPER STRINGS
    convertMiliseconds: function (cmp, miliseconds) {
        var days, hours, minutes, seconds, total_hours, total_minutes, total_seconds;

        total_seconds = parseInt(Math.floor(miliseconds / 1000));
        total_minutes = parseInt(Math.floor(total_seconds / 60));
        total_hours = parseInt(Math.floor(total_minutes / 60));
        // days = parseInt(Math.floor(total_hours / 24));
        // seconds = parseInt(total_seconds % 60);
        minutes = parseInt(total_minutes % 60);
        hours = parseInt(total_hours % 24);

        minutes = minutes < 10 ? '0' + minutes : minutes;
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours > 12 ? hours - 12 : hours;
        hours = hours < 10 ? '0' + hours : hours;

        return hours + ':' + minutes + ampm;
    },

    getTimeInt: function (cmp, timeString, format) {
        //split time selected for start and end times

        if (format == 'hour') {
            if (timeString.includes('PM')) {
                // console.log('startHour: ' +  Number(startTimeString.substring(0,2)));
                var hour = Number(timeString.substring(0, 2));
                if (hour < 12) {
                    hour = hour + 12;
                }
                return hour;
            }else{
                return Number(timeString.substring(0, 2));
            }
        } else {
            return Number(timeString.substring(4, 5));
        }

        // console.log('24-hour: ' + hour);
        // //Getting today's date to make a date object, in order to use the getTime() function to turn time string to miliseconds.
        // var today = new Date();
        // var dateTime = new Date(today.getFullYear(),today.getMonth(),today.getDay(),hour,minute)
        //
        // console.log('time data type == ' + dateTime.getTime());
        //
        // return dateTime.getTime();

    },

    handleSuccess: function (cmp, event, helper) {
        console.log('handleSuccess...');
        cmp.set("v.isLoading", true);

        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");
        console.log('cmpName = ' + cmpName);
        console.log('stepId = ' + stepId);

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();

    },

    handleError: function (cmp, event, helper) {
        console.log("handle error...");
        cmp.set("v.isLoading", false);

        console.log(event);
        var errors = event.getParams();
        console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.nextStepId");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

});
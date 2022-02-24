/**
 * Created by afaf.awad on 2/22/2021.
 */

({
    retrieveItems: function (cmp, callback) {
        var action = cmp.get('c.getEventsForMonth'),
            year =  cmp.get('v.year'),
            month = cmp.get('v.month'),
            zoneId = cmp.get('v.zoneId'),
            event = cmp.get('v.eventId')
            self = this;

        if(typeof year === 'undefined' || typeof month === 'undefined'){
            var currentDate = new Date();
            year = currentDate.getFullYear();
            month = currentDate.getMonth() + 1;
        }

        if(typeof zoneId === 'undefined' || !zoneId) {
            zoneId = '';
        }

        cmp.set('v.calendarItems', []);
        this.renderGrid(cmp);

        action.setParams({
            zoneId: zoneId,
            year:   year,
            month:  month + 1,
            eventId : event
        });

        action.setCallback(this, function(response){
            var today = new Date().toISOString().slice(0, 10);
            var tomorrow =  new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            tomorrow = tomorrow.toISOString().slice(0, 10);
            console.log('tomorrow == ' + tomorrow);

            var state = response.getState(),
                resVal = response.getReturnValue();
            // console.log('calItems == ' + JSON.stringify(resVal));

            if (state === 'SUCCESS') {
                var calItems = [];
                var calDates = [];

                resVal.forEach(function(row){
                    const date1 = new Date(row.Start_Date__c);
                    const date2 = new Date(row.End_Date__c);
                    const diffTime = Math.abs(date2 - date1) + 86400000;
                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                    // console.log(diffDays + " days");
                    // console.log(diffTime + " Time");


                    for(var i=0; i < diffDays; i++){
                    var dbDate = new Date(new Date(row.Start_Date__c).getTime() + (new Date().getTimezoneOffset() * 60 * 1000));
                    var currMonth = dbDate.getMonth()+1;
                    var currDay = dbDate.getDate()+i;
                    var currDateString = dbDate.getFullYear() + '-' + (currMonth>9 ? '' : '0') + currMonth + '-' + (currDay>9 ? '' : '0') + currDay;

                        if (new Date().getTime() < new Date(row.Start_Date__c).getTime()) {
                            // console.log('currDateString == ' + currDateString);
                            if (currDateString != today && currDateString != tomorrow) {
                                calItems.push({date: currDateString, attending: false, scheduleId: row.Id});
                            }
                        }



                    // console.log('resVal[i]: ' + JSON.stringify(resVal[i]));
                    // if(!this.inArray(calDates, currDateString)){
                    //
                    //     if(resVal[0].hasOwnProperty('BR_Participations__r')){
                    //         calItems.push({date: currDateString, attending: true});
                    //     } else{
                    //         calItems.push({date: currDateString, attending: false});
                    //     }
                    //     calDates.push(currDateString);
                    // } else if(resVal[0].hasOwnProperty('BR_Participations__r')){
                    //     for(var k=0; k < calItems.length; k++){
                    //         if(calItems[k].date === currDateString){
                    //             calItems[k].attending = true;
                    //         } else{
                    //             //do nothing
                    //         }
                    //     }
                    // } else{
                    //     //do nothing
                    // }
                }
                });
                // console.log('calendar Items : ' + JSON.stringify(calItems));
                cmp.set('v.calendarItems', calItems);
                self.renderGrid(cmp);

                if (typeof callback === 'function') {
                    callback();
                }
            }
        });
        $A.enqueueAction(action);
    },

    changeYear: function (component, newYear, date) {

        var currentMonth = component.get("v.month");
        var currentYear = component.get("v.year");

        if (!currentYear) {
            currentYear = this.date.current.year();
        }

        var currentDate = new Date(currentYear, currentMonth, date);
        var targetDate = new Date(newYear, currentDate.getMonth(), 1);

        var daysInMonth = this.numDays(currentMonth, currentYear);

        if (daysInMonth < date) { // The target month doesn't have the current date. Just set it to the last date.
            this.setDateValues(component, targetDate, daysInMonth, true);
        } else{
            this.setDateValues(component, targetDate, date, true);
        }

        this.retrieveItems(component);
    },

    changeMonth: function (component, monthChange) {

        var currentYear = component.get("v.year");
        var currentMonth = component.get("v.month");
        var currentDay = component.get("v.date");
        var targetMonth;
        var currentDate = new Date(currentYear, currentMonth, currentDay);
        var targetYear = currentDate.getFullYear();
        var todayYear = new Date().getFullYear();

        if(monthChange === 'next'){
            if(currentMonth === 11){
                targetMonth = 0;
                targetYear = targetYear + 1;
                component.find('yearSelect').set('v.value', targetYear.toString());
            } else{
                targetMonth = currentDate.getMonth() + 1;
            }
        } else{
            //do nothing
        }

        if(monthChange === 'prev'){
            if(currentMonth === 0){

                targetYear = targetYear - 1;

                if(todayYear > targetYear){
                    return;
                }

                targetMonth = 11;

                component.find('yearSelect').set('v.value', targetYear.toString());
            } else{
                targetMonth = currentDate.getMonth() - 1;
            }
        } else{
            //do nothing
        }


        var targetDate = new Date(targetYear, targetMonth, 1);
        var daysInMonth = this.numDays(currentMonth, currentYear);

        if (daysInMonth < currentDay) { // The target month doesn't have the current date. Just set it to the last date.
            this.setDateValues(component, targetDate, daysInMonth, true);
        } else{
            this.setDateValues(component, targetDate, currentDay, true);
        }

        this.retrieveItems(component);
    },


    goToToday: function (component) {
        var currentYear = this.date.current.year();
        var currentMonth = this.date.current.month.integer();
        var currentDay = this.date.current.day();
        var prevMonth = component.get('v.month');

        component.find("yearSelect").set("v.value", currentYear);

        var month = component.get("v.month") + 1;
        var formattedMonth = month < 10 ? '0' + month: month;

        var day = component.get("v.date");
        var formattedDay = day < 10 ? '0' + day: day;

        var targetDate = new Date(currentYear, currentMonth, currentDay);
        this.setDateValues(component, targetDate, currentDay);
        component.set("v.selectedDate", component.get("v.year") + "-" + formattedMonth + "-" + formattedDay);

        var calItems = component.get('v.calendarItems');
        var selectedcalItem = calItems.find(el => el.date == component.get('v.selectedDate'))
            console.log('selectedCalItem == ' + JSON.stringify(selectedcalItem));

        if(selectedcalItem) {
            var dateChangeEvent = $A.get("e.c:EC_DateChange");
            dateChangeEvent.setParams({
                date: component.get("v.selectedDate"),
                scheduleId : selectedcalItem.scheduleId
            });
            dateChangeEvent.fire();

            this.retrieveItems(component);
        }


    },

    dateCompare: function (date1, date2) {
        if (date1.getFullYear() !== date2.getFullYear()) {
            return date1.getFullYear() - date2.getFullYear();
        } else  if (date1.getMonth() !== date2.getMonth()) {
            return date1.getMonth() - date2.getMonth();
        } else {
            return date1.getDate() - date2.getDate();
        }
    },

    /**
     * Java style date comparisons. Compares by day, month, and year only.
     */
    dateEquals: function (date1, date2) {
        return date1 && date2 && this.dateCompare(date1, date2) === 0;
    },

    checkParticipation: function (dateString, calendarItems) {

        for(var i=0; i < calendarItems.length; i+=1){
            if(calendarItems[i].date === dateString){
                if(calendarItems[i].attending){
                    return 'attend';
                } else{
                    return 'notattend';
                }
            } else{
                //do nothing
            }
        }
        return false;
    },

    /**
     * Find the cell component for a specific date in a month.
     * @date - Date object
     */
    findDateComponent: function (component, date) {
        var firstDate = new Date(date.getTime());
        firstDate.setDate(1);
        var initialPos = firstDate.getDay();
        var pos = initialPos + date.getDate() - 1;

        return component.find(pos);
    },

    /**
     * generates the days for the current selected month.
     */
    generateMonth: function (component) {
        var month = component.get("v.month");
        var year = component.get("v.year");
        var today = new Date();
        var d = new Date();
        d.setDate(1);
        d.setFullYear(year);
        d.setMonth(month);
        // java days are indexed from 1-7, javascript 0-6
        // The startPoint will indicate the first date displayed at the top-left
        // corner of the calendar. Negative dates in JS will subtract days from
        // the 1st of the given month
        var firstDayOfWeek = $A.get("$Locale.firstDayOfWeek") - 1; // In Java, week day is 1 - 7
        var startDay = d.getDay();
        var firstFocusableDate;

        var calendarItems = component.get('v.calendarItems');

        while (startDay !== firstDayOfWeek) {
            d.setDate(d.getDate() - 1);
            startDay = d.getDay();
        }

        for (var i = 0; i < 41; i+=1) {
            var cellCmp = component.find(i);
            if (cellCmp) {
                var tdClass = '';
                var currMonth = d.getMonth()+1;
                var currDay = d.getDate();
                var dateString = d.getFullYear() + '-' + (currMonth>9 ? '' : '0') + currMonth + '-' + (currDay>9 ? '' : '0') + currDay;


                if (d.getMonth() === month - 1 || d.getFullYear() === year - 1) {
                    cellCmp.set("v.ariaDisabled", "true");
                    tdClass = 'slds-disabled-text';
                } else if (d.getMonth() === month + 1 || d.getFullYear() === year + 1) {
                    cellCmp.set("v.ariaDisabled", "true");
                    tdClass = 'slds-disabled-text';
                }

                if (d.getMonth() === month && d.getDate() === 1) {
                    firstFocusableDate = cellCmp;
                }

                if (this.dateEquals(d, today)) {
                    tdClass += ' slds-is-today';
                }

                if(calendarItems.length > 0){
                    var participation = this.checkParticipation(dateString, calendarItems);

                    if (participation) {
                        if(participation === 'attend'){
                            cellCmp.set("v.ariaSelected", "true");
                            tdClass += ' slds-is-selected attended';
                        } else if(participation === 'notattend'){
                            tdClass += ' slds-is-selected hasEvent';
                        } else{
                            //do nothing
                        }
                    }
                }

                cellCmp.set("v.tabIndex", -1);
                cellCmp.set("v.label", d.getDate());
                cellCmp.set("v.tdClass", tdClass);

                var dateStr = d.getFullYear() + "-" +
                    ('0' + (d.getMonth() + 1)).slice(-2) + "-" +
                    ('0' + d.getDate()).slice(-2);
                cellCmp.set("v.value", dateStr);

            }
            d.setDate(d.getDate() + 1);
        }
        if (firstFocusableDate) {
            firstFocusableDate.set("v.tabIndex", 0);
        }
        component.set("v._setFocus", true);
    },

    getEventTarget: function (e) {
        return (window.event) ? e.srcElement : e.target;
    },

    goToFirstOfMonth: function (component) {
        var date = new Date(component.get("v.year"), component.get("v.month"), 1);
        var targetId = date.getDay();
        var targetCellCmp = component.find(targetId);
        targetCellCmp.getElement().focus();
        component.set("v.date", 1);
    },

    goToLastOfMonth: function (component) {
        var date = new Date(component.get("v.year"), component.get("v.month") + 1, 0);
        var targetCellCmp = this.findDateComponent(component, date);
        if (targetCellCmp) {
            targetCellCmp.getElement().focus();
            component.set("v.date", targetCellCmp.get("v.label"));
        }
    },


    renderGrid: function (component) {
        this.generateMonth(component);
    },

    selectDate: function (component, event) {
        var source = event.getSource();
        console.log("source: " + source);

        var firstDate = new Date(component.get("v.year"), component.get("v.month"), 1);
        var firstDateId = parseInt(firstDate.getDay(), 10);

        // need to account for start of week differences when comparing indices
        var firstDayOfWeek = $A.get("$Locale.firstDayOfWeek") - 1; // The week days in Java is 1 - 7
        var offset = 0;
        if (firstDayOfWeek !== 0) {
            if (firstDateId >= firstDayOfWeek) {
                offset -= firstDayOfWeek;
            } else {
                offset += (7 - firstDayOfWeek);
            }
        }

        firstDateId += offset;
        var lastDate = new Date(component.get("v.year"), component.get("v.month") + 1, 0);
        var lastDateCellCmp = this.findDateComponent(component, lastDate);
        var lastDateId = parseInt(lastDateCellCmp.getLocalId(), 10);
        lastDateId += offset;

        var currentId = parseInt(source.getLocalId(), 10);
        var currentDate = source.get("v.label");
        var targetDate;
        if (currentId < firstDateId) { // previous month
            targetDate = new Date(component.get("v.year"), component.get("v.month") - 1, currentDate);
            this.setDateValues(component, targetDate, targetDate.getDate());

        } else if (currentId > lastDateId) { // next month
            targetDate = new Date(component.get("v.year"), component.get("v.month") + 1, currentDate);
            this.setDateValues(component, targetDate, targetDate.getDate());

        } else {
            component.set("v.date", currentDate);
        }

        var month = component.get("v.month") + 1;
        var formattedMonth = month < 10 ? '0' + month: month;

        var day = component.get("v.date");
        var formattedDay = day < 10 ? '0' + day: day;

        component.set("v.selectedDate", component.get("v.year") + "-" + formattedMonth + "-" + formattedDay);
        component.set("v.value", component.get("v.year") + "-" + (component.get("v.month") + 1) + "-" + component.get("v.date"));

        console.log('SelectedDate = ' + component.get('v.selectedDate') );
        var calItems = component.get('v.calendarItems');
        var selectedcalItem = calItems.find(el => el.date == component.get('v.selectedDate'))
        console.log('selectedCalItem == ' + JSON.stringify(selectedcalItem));

        var dateChangeEvent = $A.get("e.c:EC_DateChange");
        dateChangeEvent.setParams({
            date: component.get("v.selectedDate"),
            scheduleId : selectedcalItem.scheduleId
        });
        dateChangeEvent.fire();
    },

    setFocus: function (component) {
        var date = component.get("v.date");
        if (!date) {
            date = 1;
        }
        var year = component.get("v.year");
        var month = component.get("v.month");
        var cellCmp = this.findDateComponent(component, new Date(year, month, date));
        if (cellCmp) {
            cellCmp.getElement().focus();
        }
    },

    updateNameOfWeekDays: function (component) {
        var firstDayOfWeek = $A.get("$Locale.firstDayOfWeek") - 1; // The week days in Java is 1 - 7
        var namesOfWeekDays = $A.get("$Locale.nameOfWeekdays");
        var days = [];
        if (this.isNumber(firstDayOfWeek) && Array.isArray(namesOfWeekDays)) {
            for (var i = firstDayOfWeek; i < namesOfWeekDays.length; i+=1) {
                days.push(namesOfWeekDays[i]);
            }
            for (var j = 0; j < firstDayOfWeek; j+=1) {
                days.push(namesOfWeekDays[j]);
            }
            component.set("v._namesOfWeekdays", days);
        } else {
            component.set("v._namesOfWeekdays", namesOfWeekDays);
        }
    },

    isNumber: function (obj) {
        return !isNaN(parseFloat(obj));
    },

    numDays: function (currentMonth, currentYear) {
        // checks to see if february is a leap year otherwise return the respective # of days
        return currentMonth === 1 && (((currentYear % 4 === 0) && (currentYear % 100 !== 0)) || (currentYear % 400 === 0)) ? 29 : this.l10n.daysInMonth[currentMonth];

    },

    setDateValues: function (component, fullDate, dateNum, clearSelectedDate) {

        component.set("v.year", fullDate.getFullYear());
        component.set("v.month", fullDate.getMonth());
        component.set("v.monthName", this.getMonthLabel(fullDate.getMonth()));
        component.set("v.date", dateNum);

        if(typeof clearSelectedDate !== 'undefined' && clearSelectedDate){
            component.set("v.selectedDate", null);
        } else {
            component.set("v.selectedDate", fullDate);
        }
    },

    generateYearOptions: function (component, fullDate) {

        var years = [];
        var year = fullDate.getFullYear();

        for (var i = year; i < year + 10; i+=1) {
            years.push({"class": "optionClass", label: i, value: i});
        }
        years[0].selected = true;
        component.find("yearSelect").set("v.options", years);
    },


    getMonthLabel: function(month, isShort){
        var monthString = '';
        if(typeof isShort !== 'undefined' && isShort){
            switch (month) {
                case 0:  monthString = $A.get("$Label.c.lbl_month_short_jan"); break;
                case 1:  monthString = $A.get("$Label.c.lbl_month_short_feb"); break;
                case 2:  monthString = $A.get("$Label.c.lbl_month_short_mar"); break;
                case 3:  monthString = $A.get("$Label.c.lbl_month_short_apr"); break;
                case 4:  monthString = $A.get("$Label.c.lbl_month_short_may"); break;
                case 5:  monthString = $A.get("$Label.c.lbl_month_short_jun"); break;
                case 6:  monthString = $A.get("$Label.c.lbl_month_short_jul"); break;
                case 7:  monthString = $A.get("$Label.c.lbl_month_short_aug"); break;
                case 8:  monthString = $A.get("$Label.c.lbl_month_short_sep"); break;
                case 9:  monthString = $A.get("$Label.c.lbl_month_short_oct"); break;
                case 10: monthString = $A.get("$Label.c.lbl_month_short_nov"); break;
                case 11: monthString = $A.get("$Label.c.lbl_month_short_dec"); break;
                default: monthString = "Invalid month"; break;
            }
        }else{
            switch (month) {
                case 0:  monthString = $A.get("$Label.c.lbl_month_jan"); break;
                case 1:  monthString = $A.get("$Label.c.lbl_month_feb"); break;
                case 2:  monthString = $A.get("$Label.c.lbl_month_mar"); break;
                case 3:  monthString = $A.get("$Label.c.lbl_month_apr"); break;
                case 4:  monthString = $A.get("$Label.c.lbl_month_may"); break;
                case 5:  monthString = $A.get("$Label.c.lbl_month_jun"); break;
                case 6:  monthString = $A.get("$Label.c.lbl_month_jul"); break;
                case 7:  monthString = $A.get("$Label.c.lbl_month_aug"); break;
                case 8:  monthString = $A.get("$Label.c.lbl_month_sep"); break;
                case 9:  monthString = $A.get("$Label.c.lbl_month_oct"); break;
                case 10: monthString = $A.get("$Label.c.lbl_month_nov"); break;
                case 11: monthString = $A.get("$Label.c.lbl_month_dec"); break;
                default: monthString = "Invalid month"; break;
            }
        }
        return monthString;
    },
    getWeekDayLabel: function(weekday, isShort){
        var weekdayString = '';

        if(typeof isShort !== 'undefined' && isShort){
            switch (weekday) {
                case 0:  weekdayString = $A.get("$Label.c.lbl_weekday_short_sun"); break;
                case 1:  weekdayString = $A.get("$Label.c.lbl_weekday_short_mon"); break;
                case 2:  weekdayString = $A.get("$Label.c.lbl_weekday_short_tue"); break;
                case 3:  weekdayString = $A.get("$Label.c.lbl_weekday_short_wed"); break;
                case 4:  weekdayString = $A.get("$Label.c.lbl_weekday_short_thu"); break;
                case 5:  weekdayString = $A.get("$Label.c.lbl_weekday_short_fri"); break;
                case 6:  weekdayString = $A.get("$Label.c.lbl_weekday_short_sat"); break;

                default: weekdayString = "Invalid weekday";
                    break;
            }
        }else{
            switch (weekday) {
                case 0:  weekdayString = $A.get("$Label.c.lbl_weekday_sun"); break;
                case 1:  weekdayString = $A.get("$Label.c.lbl_weekday_mon"); break;
                case 2:  weekdayString = $A.get("$Label.c.lbl_weekday_tue"); break;
                case 3:  weekdayString = $A.get("$Label.c.lbl_weekday_wed"); break;
                case 4:  weekdayString = $A.get("$Label.c.lbl_weekday_thu"); break;
                case 5:  weekdayString = $A.get("$Label.c.lbl_weekday_fri"); break;
                case 6:  weekdayString = $A.get("$Label.c.lbl_weekday_sat"); break;

                default: weekdayString = "Invalid month";
                    break;
            }
        }
        return weekdayString;
    },


    l10n: {
        //deprecated should call getWeekDayLabel instead
        weekdays: {
            shorthand: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            longhand: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        },
        //deprecated should call getMonthLabel instead
        months: {
            shorthand: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            longhand: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
        },
        daysInMonth: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
        firstDayOfWeek: 0
    },


    date: {
        current: {
            year: function () {
                return new Date().getFullYear();
            },
            month: {
                integer: function () {
                    return new Date().getMonth();
                }
            },
            day: function () {
                return new Date().getDate();
            }
        }
    },

    inArray: function(arr, val) {
        return arr.some(function(arrVal) {
            return val === arrVal;
        });
    }
});
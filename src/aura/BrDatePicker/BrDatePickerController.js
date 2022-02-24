({
    doInit: function (component, event, helper) {

        for (var i = 0; i < 41; i+=1) {
            var cellCmp = component.find(i);
            if (cellCmp) {
                cellCmp.addEventHandler("BrDateCellClick", component.getReference("c.handleClick"));
            }
        }

        var currentDate = new Date();
        helper.setDateValues(component, currentDate, currentDate.getDate(), true);

        // Set the first day of week
        helper.updateNameOfWeekDays(component);
        helper.generateYearOptions(component, currentDate);

        var setFocus = component.get("v.setFocus");
        if (!setFocus) {
            component.set("v._setFocus", false);
        }

        helper.retrieveItems(component);
    },

    retrieveItems: function(cmp, event, helper) {
        helper.retrieveItems(cmp);
    },

    renderGrid: function (component, event, helper) {
        helper.renderGrid(component);
    },

    handleYearChange: function (component, event, helper) {

        var newYear = component.find("yearSelect").get("v.value");
        var date = component.get("v.date");

        helper.changeYear(component, newYear, date);
    },

    handleClick: function (component, event, helper) {
        console.log('handleClick...');
        var elClass = event.getParam('class');

        console.log('elClass: ' + elClass);
        if(elClass.indexOf('slds-is-selected') !== -1){
            helper.selectDate(component, event);
        }
    },

    goToToday: function (component, event, helper) {
        event.stopPropagation();
        helper.goToToday(component, event);
        return false;
    },

    goToPreviousMonth: function (component, event, helper) {
        event.stopPropagation();
        helper.changeMonth(component, 'prev');

        return false;
    },

    goToNextMonth: function (component, event, helper) {
        event.stopPropagation();
        helper.changeMonth(component, 'next');

        return false;
    },

    onReset: function (cmp) {
        var dateChangeEvent = $A.get("e.c:BrDateChange");
        dateChangeEvent.setParams({
            date: null
        });
        dateChangeEvent.fire();
    }

});
/**
 * Created by lauren.lezberg on 1/8/2021.
 */

({

    doInit : function(cmp, event, helper){
        console.log("doInit");
        console.log('date: ' + cmp.get("v.dateInput"));
        if(cmp.get("v.dateInput")!=null) {
            var dateParts = cmp.get("v.dateInput").split('-');
            console.log('dateParts: ' + dateParts[0]);
            // var date = new Date(dateParts[0], dateParts[1], dateParts[2]);
            // console.log('js date: ' + date);
            // console.log('formatted date ' + $A.localizationService.formatDate(date, "yyyy MM dd"));
            // console.log('month: ' + date.getUTCMonth());
            cmp.find('mon').set("v.value", dateParts[1]);
            // console.log('year: ' + date.getFullYear());
            cmp.find('year').set("v.value", dateParts[0]);
            // console.log('day: ' + date.getDate());
            cmp.find('day').set("v.value", dateParts[2]);
        }

    },


    handleDateChange : function(cmp, event, helper){
        console.log('handleDateChange');
        console.log("date: " + cmp.get("v.dateInput"));
        var dateParts = cmp.get("v.dateInput").split('-');
        var date = new Date(dateParts[0], dateParts[1], dateParts[2]);
        console.log('js date: ' + date);
        if(isNaN(date.getTime())){
            console.log("date is not valid.");
        }
    }
});
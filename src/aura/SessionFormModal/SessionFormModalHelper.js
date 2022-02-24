/**
 * Created by lauren.lezberg on 1/24/2020.
 */
({
    showToast : function(component, event, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },

    getTimezoneOffset : function(tz, hereDate) {
    hereDate = new Date(hereDate || Date.now());
    hereDate.setMilliseconds(0); // for nice rounding

    const
        hereOffsetHrs = hereDate.getTimezoneOffset() / 60 * -1,
        thereLocaleStr = hereDate.toLocaleString('en-US', {timeZone: tz}),
        thereDate = new Date(thereLocaleStr),
        diffHrs = (thereDate.getTime() - hereDate.getTime()) / 1000 / 60 / 60,
        thereOffsetHrs = hereOffsetHrs + diffHrs;

    // console.log(tz, thereDate, 'UTC'+(thereOffsetHrs < 0 ? '' : '+')+thereOffsetHrs);
    return thereOffsetHrs;
    }
})
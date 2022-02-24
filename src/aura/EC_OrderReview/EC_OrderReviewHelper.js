/**
 * Created by afaf.awad on 2/24/2021.
 */

({
    getOrderId : function(cmp){
        var name ='c__orderId';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },

    getStatus : function(cmp){
        var name ='c__status';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var status=results[1];
            return status;
        }
        return null;
    },


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
        // hours = hours < 10 ? '0' + hours : hours;

        return hours + ':' + minutes + ampm;
    },

});
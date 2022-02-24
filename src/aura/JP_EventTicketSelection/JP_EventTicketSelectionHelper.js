/**
 * Created by lauren.lezberg on 3/18/2020.
 */
({

    getSalesOrderId : function(cmp){
        var name ='c__salesOrder';
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

    getEventId : function(cmp){
        var name ='c__event';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var evId=results[1];
            return evId;
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

        console.log('kvp: ' + kvp.join('&'));

        window.location.href = 'c__BAMContainer?' + kvp.join('&');

    }
})
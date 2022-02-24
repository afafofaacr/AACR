/**
 * Created by lauren.lezberg on 4/25/2020.
 */
({
    getEventId : function(cmp, event){
        var name ='id';
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

    getRetURL : function(cmp, event){
        var name ='venueURL';
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
    }
})
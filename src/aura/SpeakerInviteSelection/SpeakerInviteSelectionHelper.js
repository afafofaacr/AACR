/**
 * Created by lauren.lezberg on 2/17/2020.
 */
({
    getEventId : function(cmp){
        var name ='c__eventId';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            return results[1];
        }

        return false;
    },
})
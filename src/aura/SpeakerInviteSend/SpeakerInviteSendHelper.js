/**
 * Created by lauren.lezberg on 3/3/2020.
 */
({
    getEventId : function(){
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
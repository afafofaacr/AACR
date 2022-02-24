/**
 * Created by lauren.lezberg on 2/16/2021.
 */

({
    getEventId : function(cmp){
        var name ='eventId';
        var url = location.href;
        if(url.indexOf('%26')!=-1) {
            url = url.replace('%26', '&');
        }
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
});
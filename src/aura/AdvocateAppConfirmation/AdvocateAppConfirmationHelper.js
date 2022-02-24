/**
 * Created by lauren.lezberg on 7/14/2021.
 */

({
    getEventId : function(cmp){
        var name ='eventId';
        var url = location.href;
        if(url.indexOf('%26')!=-1) {
            url = url.replace('%26', '&');
        }
        if(url.indexOf('%3D')!=-1){
            url = url.replace('%3D', '=');
        }
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1].replace('%26', '&').replace('%3D', '=');
        }

        return null;
    }
});
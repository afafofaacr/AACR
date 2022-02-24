/**
 * Created by lauren.lezberg on 11/12/2019.
 */
({
    getEventId : function(cmp, event){
        var name ='c__event';
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
})
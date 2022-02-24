/**
 * Created by lauren.lezberg on 8/8/2019.
 */
({
    /**
     * @purpose Retrieve join process id parameter from page URL
     * @param cmp
     * @returns {*}
     */
    getJoinId : function(cmp){ 
        var name ='c__id';
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
})
/**
 * Created by lauren.lezberg on 3/8/2019.
 */
({
    /**
     * @purpose Retrieves salesOrder Id parameter from URL
     * @param cmp
     * @returns {*}
     */
    getSalesOrderId : function(cmp){
        var name ='salesOrder';
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

    /**
     * @purpose Retrieve join process Id parameter from URL
     * @param cmp
     * @returns {string}
     */
    getJoinId : function(cmp){
        var name ='id';
        var url = location.href;
        if(url.indexOf('%26')!=-1) {
            // url = url.replaceAll(/%26/g, '&');
            url = url.replace('%26', '&');
        }
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results==null){
            name ='c__id';
            name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            name = name.toLowerCase();
            regexS = "[\\?&]"+name+"=([^&#]*)";
            regex = new RegExp( regexS, "i" );
            results = regex.exec( url );
        }
        return results[1];
    },

   
})
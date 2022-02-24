/**
 * Created by lauren.lezberg on 11/15/2019.
 */
({
    /**
     * @purpose Retrieve sales order parameter from page URL
     * @param cmp
     * @returns {*}
     */
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


    /**
     * @purpose Retrieve isRenew parameter from page URL
     * @param cmp
     * @returns {*}
     */
    getIsRenew : function(cmp){
        var name ='c__isRenew';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            if(results[1]=='true'){
                return true;
            } else {
                return false;
            }
        }
        return null;
    }
})
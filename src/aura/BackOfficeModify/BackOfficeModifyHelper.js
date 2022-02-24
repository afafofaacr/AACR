/**
 * Created by lauren.lezberg on 2/3/2020.
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

    
})
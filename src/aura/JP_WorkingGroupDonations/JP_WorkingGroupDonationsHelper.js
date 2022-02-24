/**
 * Created by lauren.lezberg on 8/27/2019.
 */
({
    /**
     * @purpose Retrieve sales order id parameter from URL
     * @param cmp
     * @returns {string}
     */
    getSalesOrderId : function(cmp){ 
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId=results[1];
        return SOId;
    },

})
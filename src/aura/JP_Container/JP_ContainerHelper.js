/**
 * Created by lauren.lezberg on 11/19/2020.
 */

({
    getSalesOrderId : function(cmp){
        //get sales order id from URL
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId = null;
        if(results==null){
            name ='c__salesOrder';
            name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            name = name.toLowerCase();
            regexS = "[\\?&]"+name+"=([^&#]*)";
            regex = new RegExp( regexS, "i" );
            results = regex.exec( url );
            if(results!=null) {
                SOId = results[1];
            }
        } else {
            SOId=results[1];
        }

        return SOId;
    },

    getJoinId : function(cmp){
        //get join id from URL
        var name ='id';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var jId = null;
        if(results==null){
            name ='c__id';
            name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            name = name.toLowerCase();
            regexS = "[\\?&]"+name+"=([^&#]*)";
            regex = new RegExp( regexS, "i" );
            results = regex.exec( url );
            if(results!=null) {
                jId = results[1];
            }
        } else {
            jId=results[1];
        }

        return jId;
    },
});
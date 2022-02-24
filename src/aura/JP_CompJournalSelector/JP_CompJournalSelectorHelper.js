/**
 * Created by lauren.lezberg on 1/22/2019.
 */
({
    /**
     * Retrieve sales order id parameter from URL
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
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },

    /**
     * Finds matching print journal from online journal selected
     * @param cmp
     * @param prints
     * @param onlineName
     */
    getMatchingPrintJournal : function(cmp, prints, onlineName){
        prints.forEach(function(print){
           if(print.label.replace('- Print', '') == onlineName.replace('- Online', '')){
               cmp.set("v.selectedComp", print.value);
           }
        });
    },

    /**
     * Finds matching online journal from print journal selected
     * @param cmp
     * @param online
     * @param printName
     */
    getMatchingOnlineJournal : function(cmp, online, printName){
        online.forEach(function(journal){
            if(journal.label.replace('- Online', '') == printName.replace('- Print', '')){
                cmp.set("v.selectedComp", journal.value);
            }
        });
    }

})
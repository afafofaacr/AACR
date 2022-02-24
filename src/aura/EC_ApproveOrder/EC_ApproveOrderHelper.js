/**
 * Created by afaf.awad on 3/2/2021.
 */

({
    getOrderId : function(cmp){
        var name ='c__orderId';
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

    goBackToOrder : function (cmp){
        var navLink = cmp.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'EC_Order__c',
                recordId: cmp.get('v.orderId')
            },
        };
        navLink.navigate(pageRef, true);

    }
});
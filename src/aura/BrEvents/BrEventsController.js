({
    doInit: function(cmp, event, helper){
        console.log('doInit..');
        helper.retrieveUserInfo(cmp);
        helper.init(cmp);

    },

    changeLocation : function (cmp, event, helper) {
        helper.init(cmp);
    },

    handleErrorEvent: function(cmp, event) {
        var message = event.getParam('message'),
            removeMsg = function() {
                if (cmp.isValid()) {
                    cmp.set('v.systemMessage', {type: '', body: ''});
                }
            };

        cmp.set('v.systemMessage', {type: 'error', body: message});

        setTimeout($A.getCallback(removeMsg), 5000);
    },

    handleOpenItem: function(cmp, event){
        console.log("handleOpenItem..." + event.getParam('itemId')); 
        cmp.set('v.itemId', event.getParam('itemId'));
        cmp.set('v.view', 'item');
    }
})
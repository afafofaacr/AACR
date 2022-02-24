({
    init: function(cmp){
        console.log("init...");

        var urlVars,
            environmentType = cmp.get('v.environmentType');

        console.log("environmentType: " + environmentType);

        if(environmentType === 'Community'){
            urlVars = this.parseQueryVars();
            // console.log("urlVars: " + JSON.stringify(urlVars));

            if (urlVars.ac__id) {
                cmp.set('v.itemId', urlVars.ac__id);
                cmp.set('v.view', 'item');
            } else {
                if (urlVars.ac__date != null) {
                    cmp.set('v.dateFilter', urlVars.ac__date);
                    history.pushState({}, document.title, location.pathname);
                }

                cmp.set('v.view', 'list');
            }
        } else {
            cmp.set('v.isCommunity', false);
            cmp.set('v.view', 'list');
        }
    },


    retrieveUserInfo: function(cmp) {
        console.log("retrieveUserINfo...");

        var action = cmp.get('c.getUserInfo');
        console.log('action: ' + action);
        action.setCallback(this, function(response) {
            console.log('action after set callback');
            var state = response.getState();
            console.log("state: " + state);
            if (state === "SUCCESS") {
                var  resVal = response.getReturnValue();
                console.log('resVal: ' + JSON.stringify(resVal));
                cmp.set('v.userInfo', resVal);

                if (resVal.Type == 'Guest') {
                    cmp.set('v.isGuest', true);
                }
                cmp.set("v.isLoaded", true);
            } else if (state === "INCOMPLETE") {
                console.log('Could not get user info: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get user info - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get user info: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    parseQueryVars: function() {
        let params = {};

        window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
            return params[key] = value;
        });

        return params;
    }
})
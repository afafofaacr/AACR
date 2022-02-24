/**
 * Created by mitfity on 02.09.2019.
 */

({
    retrieveUserInfo: function(cmp) {
        var action = cmp.get('c.getUserInfo');

        action.setCallback(this, function(response) {
            var state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {
                cmp.set('v.userInfo', resVal);
            }
        });

        $A.enqueueAction(action);
    }
});
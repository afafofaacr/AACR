/**
 * Created by lovandos on 2019-03-27.
 */
({
    doInit: function (component, event, helper) {
        helper.retrievePicklistOptions(component, component.get('v.picklistField'));
    }
})
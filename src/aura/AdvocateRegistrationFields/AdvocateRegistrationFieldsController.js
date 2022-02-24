/**
 * Created by lauren.lezberg on 1/13/2021.
 */

({
    handleLoad : function(cmp, event, helper){
        if(cmp.find('pStakeholder').get("v.value")=='Other'){
            $A.util.removeClass(cmp.find('primaryOther'), 'slds-hide');
            cmp.find('primaryOther').set("v.required", true);
        }

        if(cmp.find('sStakeholder').get("v.value")== 'Other'){
            $A.util.removeClass(cmp.find('secondaryOther'), 'slds-hide');
            cmp.find('secondaryOther').set("v.required", true);
        }
    },

    validateForm : function(cmp, event, helper){
        var isValid = true;
        if(cmp.find('pStakeholder').get("v.value")=='Other'){
            if(cmp.find('primaryOther').get("v.value")==null || cmp.find('primaryOther').get("v.value")==undefined || cmp.find('primaryOther').get("v.value")==''){
                isValid = false;
                $A.util.addClass(cmp.find('primaryOther'), 'slds-has-error');
            }
        } else {
            $A.util.removeClass(cmp.find('primaryOther'), 'slds-has-error');
        }
        if(cmp.find('sStakeholder').get("v.value")=='Other'){
            if(cmp.find('secondaryOther').get("v.value")==null || cmp.find('secondaryOther').get("v.value")==undefined || cmp.find('secondaryOther').get("v.value")==''){
                isValid = false;
                $A.util.addClass(cmp.find('secondaryOther'), 'slds-has-error');
            }
        }else {
            $A.util.removeClass(cmp.find('secondaryOther'), 'slds-has-error');
        }

        cmp.set("v.isValid", isValid);

        return isValid;
    },

    handleError : function(cmp, event, helper){
        console.log('handle advocatefields error');
        cmp.set("v.isValid", false);
    },

    handleSuccess : function(cmp, event, helper){
        console.log('handle advocatefields success');
        cmp.set("v.isValid", true);
    },

    handlePrimaryOtherChange : function(cmp, event, helper){
        $A.util.removeClass(cmp.find('primaryOther'), 'slds-has-error');
    },

    handleSecondaryOtherChange : function(cmp, event, helper){
        $A.util.removeClass(cmp.find('secondaryOther'), 'slds-has-error');
    },

    handlePrimaryChange : function(cmp, event, helper){
        var pStakeholder = event.getSource().get("v.value");
        if(pStakeholder == 'Other'){
            $A.util.removeClass(cmp.find('primaryOther'), 'slds-hide');
            cmp.find('primaryOther').set("v.required", true);
        } else {
            $A.util.addClass(cmp.find('primaryOther'), 'slds-hide');
            cmp.find('primaryOther').set("v.required", false);
            cmp.find('primaryOther').set("v.value", null);
        }
    },

    handleSecondaryChange : function(cmp, event, helper){
        var sStakeholder = event.getSource().get("v.value");
        if(sStakeholder == 'Other'){
            $A.util.removeClass(cmp.find('secondaryOther'), 'slds-hide');
            cmp.find('secondaryOther').set("v.required", true);
        } else {
            $A.util.addClass(cmp.find('secondaryOther'), 'slds-hide');
            cmp.find('secondaryOther').set("v.required", true);
            cmp.find('secondaryOther').set("v.value", null);
        }
    }
});
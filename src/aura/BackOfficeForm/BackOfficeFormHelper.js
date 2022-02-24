/**
 * Created by afaf.awad on 12/2/2019.
 */

({
    /**
     * @purpose Retrieve sales order parameter from page URL
     * @param cmp
     * @returns {string of salesorderId or null}
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

    /**
     * @purpose Get any existing field responses for this sales order.
     *          If any exist, it will be passed to the FormGroup and FormFields cmps in order to prepopulate the form with previous responses.
     * @param cmp
     * @param soID
     */
    getFieldResponses : function(cmp, soID){

        window.setTimeout(
            $A.getCallback(function (){
                let action = cmp.get("c.getFieldResponses");
                action.setParams({
                    "salesOrderId" : soID
                });
                action.setCallback(this, function (response){
                    let state = response.getState();
                    let fieldResponses = response.getReturnValue();
                    if (state === "SUCCESS"){
                        console.log('state=' + state);
                        if (fieldResponses) {
                            console.log('Field Responses Returned: ' + JSON.stringify(fieldResponses));
                            cmp.set("v.fieldResponses", fieldResponses)
                        }
                        else{
                            cmp.set("v.fieldResponses", "");
                        }
                    }else{
                        let error = response.getError();
                        console.log("error from getFieldResponses helper: " + error.message);
                    }
                });
                $A.enqueueAction(action);
            }), 3000);

    },


});
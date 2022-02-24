/**
 * Created by lauren.lezberg on 9/8/2020.
 */

({
    /**
     * @purpose Call controller to get results based off search keyword
     * @param cmp
     * @param event
     * @param getInputkeyWord
     */
    searchHelper: function (cmp, event, getInputkeyWord) {
        var action = cmp.get("c.getAddressAutoComplete");
        action.setParams({
            'input': getInputkeyWord
        });
        action.setCallback(this, function (response) {
            $A.util.removeClass(cmp.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = JSON.parse(response.getReturnValue());
                cmp.set("v.listOfSearchRecords", resp.predictions);
            } else if (state == "INCOMPLETE") {
                console.log('Incomplete callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get address autocomplete - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get address autocomplete: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);

    },

    getPlaceAddress: function (cmp, event, placeId) {
        var action = cmp.get("c.getPlaceDetails");
        action.setParams({
            'placeId': placeId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var placeDetails = JSON.parse(response.getReturnValue());
                console.log('placeDetails: ' + JSON.stringify(placeDetails));

                var address = {};
                for (var i = 0; i < placeDetails.result.address_components.length; i++) {

                    if (placeDetails.result.address_components[i].types[0] == "street_number") {
                        address.street1 = placeDetails.result.address_components[i].long_name;
                    }

                    if (placeDetails.result.address_components[i].types[0] == "route") {
                        if(address.street1==null){
                            address.street1 = placeDetails.result.address_components[i].long_name;
                        } else {
                                address.street1 += ' ' + placeDetails.result.address_components[i].long_name;
                        }
                    }

                    if (placeDetails.result.address_components[i].types[0] == "locality") {
                        address.city = placeDetails.result.address_components[i].long_name;
                    }

                    if(address.city==null) {
                        if (placeDetails.result.address_components[i].types[0] == "sublocality_level_1") {
                            address.city = placeDetails.result.address_components[i].long_name;
                        }
                    }

                    if(address.city==null){
                        if (placeDetails.result.address_components[i].types[0] == "postal_town") {
                            address.city = placeDetails.result.address_components[i].long_name;
                        }
                    }

                    if (placeDetails.result.address_components[i].types[0] == "administrative_area_level_1") {
                        address.state = placeDetails.result.address_components[i].long_name;
                    }
                    if (placeDetails.result.address_components[i].types[0] == "country") {
                        address.country = placeDetails.result.address_components[i].long_name;
                    }
                    if (placeDetails.result.address_components[i].types[0] == "postal_code") {
                        address.zip = placeDetails.result.address_components[i].long_name;
                    }
                }
                console.log('address: ' + JSON.stringify(address));
                cmp.set("v.address", address);
                if (cmp.get("v.selection").description == null) {
                    var selection = {};
                    selection.description = placeDetails.result.formatted_address;
                    cmp.set("v.selection", selection);
                }
            }

        });
        $A.enqueueAction(action);
    }

});
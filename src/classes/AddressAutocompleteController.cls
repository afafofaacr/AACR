/**
 * Created by lauren.lezberg on 9/8/2020.
 */

public with sharing class AddressAutocompleteController {

    /**
     * @purpose Retrieve google maps API key from custom setting
     * @return Google API Key
     */
    private static string getGoogleMapsAPIKey(){
        Google_Session__c gSession = Google_Session__c.getOrgDefaults();
        string strKey = gSession.API_Key__c;
        return strKey;
    }


    /**
     * @purpose Find place based on address string
     * @param input : address string
     *
     * @return Google API Response string
     */
    @AuraEnabled
    public static string findPlace(String input) {
        String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?'
                + 'input=' + EncodingUtil.urlEncode(input, 'UTF-8')
                + '&inputtype=textquery'
                + '&key=' + getGoogleMapsAPIKey();
        String response = getHttp(url);
        system.debug('Response place****'+response);
        return response;
    }



    /**
    * @purpose : Retrieve place details based of place ID
    * @param placeId : unique place id
    * @return : Google API Response string
    **/
    @AuraEnabled
    public static string getPlaceDetails(String placeId) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?'
                + 'placeid=' + EncodingUtil.urlEncode(placeId, 'UTF-8')
                + '&key=' + getGoogleMapsAPIKey();
        String response = getHttp(url);
        system.debug('Response places****'+response);
        return response;
    }


    /**
     * @purpose Retrieves list of places based on address search string
     * @param input : address search string
     *
     * @return Google API response string
     */
    @AuraEnabled
    public static string getAddressAutoComplete(String input) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
                + EncodingUtil.urlEncode(input, 'UTF-8')
                + '&key=' + getGoogleMapsAPIKey();
        return getHttp(url);
    }

    /**
     * @purpose Make Google API callout
     * @param strURL : endpoint
     *
     * @return Google API Response String
     */
    public static string getHttp(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        return responseBody;
    }
}
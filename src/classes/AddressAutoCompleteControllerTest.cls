/**
 * Created by lauren.lezberg on 9/18/2020.
 */

@IsTest
private class AddressAutoCompleteControllerTest {


    @IsTest
    static void testCallouts() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String resp = AddressAutocompleteController.getAddressAutoComplete('615 Ches');
        System.assertNotEquals(null, resp);

        resp = AddressAutocompleteController.getPlaceDetails('1234567890');
        System.assertNotEquals(null, resp);

        resp = AddressAutocompleteController.findPlace('615 Chestnut St, Philadelphia, PA, United States, 19106');
        System.assertNotEquals(null, resp);

        Test.stopTest();
    }


    public class MockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"placeId":"123456"}');
                res.setStatusCode(200);
                return res;
        }
    }
}
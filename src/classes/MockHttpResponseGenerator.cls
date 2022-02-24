/**
 * Created by afaf.awad on 11/10/2020.
 */

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public MockHttpResponseGenerator(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new AACRCustomException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }

//    global HTTPResponse respond(HTTPRequest req) {
//        // Optionally, only send a mock response for a specific endpoint
//        // and method.
//        System.assertEquals('https://api.sendgrid.com/v3/mail/send', req.getEndpoint());
//        System.assertEquals('POST', req.getMethod());
//
//
//        // Create a fake response
//        HttpResponse res = new HttpResponse();
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody('{"example":"test"}');
//        res.setStatusCode(200);
//        return res;
//
//    }

}
@isTest
private class HVAvailabilityServiceTest {

    // Generic mock that returns a configurable status code and body
    private class StaticResourceMock implements HttpCalloutMock {
        Integer statusCode;
        String body;

        StaticResourceMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }

    // Mock that throws to force the catch block in checkAvailability
    private class ThrowingMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Simulated callout failure');
        }
    }

    private static RestRequest buildRequest(String areaCode) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/HVAvailabilityService/';
        req.httpMethod = 'GET';
        if (areaCode != null) {
            req.params.put('areaCode', areaCode);
        }
        RestContext.request = req;
        RestContext.response = new RestResponse();
        return req;
    }

    @isTest
    static void testAvailableItemReturned() {
        buildRequest('90210');

        String body = '{'
            + '"Items":[{'
                + '"ItemId":123,'
                + '"ItemName":"Home Warranty",'
                + '"ItemDescription":"Standard coverage",'
                + '"ItemType":"HV",'
                + '"Quantity":5,'
                + '"Cost":19.99,'
                + '"radius":25'
            + '}]'
            + '}';

        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, body));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testZeroQuantityItem() {
        buildRequest('90210');

        String body = '{'
            + '"Items":[{'
                + '"ItemId":456,'
                + '"ItemName":"Home Warranty",'
                + '"ItemDescription":"Standard coverage",'
                + '"ItemType":"HV",'
                + '"Quantity":0,'
                + '"Cost":19.99,'
                + '"radius":25'
            + '}]'
            + '}';

        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, body));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testNoItemsReturned() {
        buildRequest('00000');

        String body = '{"Items":[]}';

        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, body));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testNullItemsList() {
        buildRequest('00000');

        String body = '{}';

        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, body));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testNonSuccessHttpStatus() {
        buildRequest('90210');

        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(500, '{"error":"Internal Server Error"}'));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testCalloutExceptionIsCaught() {
        buildRequest('90210');

        Test.setMock(HttpCalloutMock.class, new ThrowingMock());

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testMalformedJsonIsCaught() {
        buildRequest('90210');

        // Not valid JSON for BackendResponse -> JSON.deserialize should throw
        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, 'not-json'));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }

    @isTest
    static void testMissingAreaCodeParam() {
        // No areaCode provided at all
        buildRequest(null);

        String body = '{"Items":[]}';
        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, body));

        Test.startTest();
        HVAvailabilityService.AvailabilityResponseWrapper response = HVAvailabilityService.checkAvailability();
        Test.stopTest();
    }
}
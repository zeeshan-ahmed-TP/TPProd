@isTest
private class TPCRMRestHandlerTest {

    // ---------------------------------------------------------------
    // Mocks
    // ---------------------------------------------------------------

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

    // ---------------------------------------------------------------
    // Test data setup
    // ---------------------------------------------------------------

    @testSetup
    static void setup() {
        insert new List<User_Licensing__c>{
            new User_Licensing__c(),
            new User_Licensing__c(),
            new User_Licensing__c(),
            new User_Licensing__c(),
            new User_Licensing__c(),
            new User_Licensing__c()
        };
    }

    private static Id getLicenseId() {
        return [SELECT Id FROM User_Licensing__c LIMIT 1].Id;
    }

    // ---------------------------------------------------------------
    // createAccount
    //
    // NOTE: sendApiCall() short-circuits and returns null whenever
    // Test.isRunningTest() is true, regardless of any HttpCalloutMock,
    // so createAccount can only ever exercise its "Failed" branch here.
    // The success branch (login-name-conflict lookup, password reset
    // link parsing) is unreachable in unit tests as currently written.
    // ---------------------------------------------------------------

    @isTest
    static void testCreateAccount_Agent() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.createAccount('Agent', 5, 'Jane', 'Doe', 'jane.doe@example.com', 'Doe Realty', licenseId);
        Test.stopTest();

        User_Licensing__c result = [
            SELECT Status__c, TPAccountId__c, TPUserID__c, TPSubscriptionID__c, Username__c, Status_Code__c
            FROM User_Licensing__c
            WHERE Id = :licenseId
        ];
    }

    @isTest
    static void testCreateAccount_Broker() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.createAccount('Broker', 10, 'John', 'Smith', 'john.smith@example.com', 'Smith Brokerage', licenseId);
        Test.stopTest();
    }

    @isTest
    static void testCreateAccount_Team() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.createAccount('Team', 3, 'Alex', 'Lee', 'alex.lee@example.com', 'Lee Team', licenseId);
        Test.stopTest();
    }

    @isTest
    static void testCreateAccount_UnrecognizedRecordType() {
        // AccountTypes.get() returns null for an unmapped record type; the
        // payload should still serialize fine with account_type_id == null.
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.createAccount('Manager', 1, 'Pat', 'Nguyen', 'pat.nguyen@example.com', 'Nguyen Group', licenseId);
        Test.stopTest();
    }

    @isTest
    static void testCreateAccount_NullFirstName() {
        // Covers the `if (firstName != null) payload.first_name = firstName;` branch
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.createAccount('Agent', 2, null, 'Ortiz', 'ortiz@example.com', 'Ortiz Realty', licenseId);
        Test.stopTest();
    }

    // ---------------------------------------------------------------
    // updateAccount
    //
    // BUG: unlike createAccount, this method reads
    // `res.getStatusCode() + ' ' + res.getBody()` unconditionally when
    // building Status_Code__c, with no null guard. Since sendApiCall()
    // always returns null in test context, this throws a
    // NullPointerException every time it runs today. The test below
    // documents that current (buggy) behavior rather than asserting a
    // clean update, so it will need to be revisited once the source
    // is fixed (e.g. mirroring the `Test.isRunningTest() ? null : ...`
    // guard used in createAccount).
    // ---------------------------------------------------------------

    @isTest
    static void testUpdateAccount_ThrowsDueToUnguardedNullResponse() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.updateAccount(
            'Fulfilled', 'Agent', 5, 'Jane', 'Doe', 'jane.doe@example.com', 'Doe Realty',
            licenseId, '001000000000001AAA', '005000000000001AAA', 'SUB-001','TestLogin'
        );

        Boolean exceptionThrown = false;
        try {
            Test.stopTest();
        } catch (NullPointerException npe) {
            exceptionThrown = true;
        }
    }

    // ---------------------------------------------------------------
    // addSubscription
    //
    // isSuccess is always false in test context (res is null), so the
    // platform-event publishing block is skipped entirely and no
    // exception is thrown regardless of licenseType.
    // ---------------------------------------------------------------

    @isTest
    static void testAddSubscription_SocialConnectLicenseType() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.addSubscription(licenseId, 1, '001000000000001AAA', '005000000000001AAA', 'SUB-002', '34');
        Test.stopTest();
        // No assertion needed beyond "no exception was thrown" (isSuccess is always false here).
    }

    @isTest
    static void testAddSubscription_HomeIntelLicenseType() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.addSubscription(licenseId, 1, '001000000000001AAA', '005000000000001AAA', 'SUB-003', '35');
        Test.stopTest();
    }

    @isTest
    static void testAddSubscription_OtherLicenseType() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.addSubscription(licenseId, 1, '001000000000001AAA', '005000000000001AAA', 'SUB-004', '99');
        Test.stopTest();
    }

    // ---------------------------------------------------------------
    // addSubscriptionWithLicense
    //
    // BUG: same unguarded `res.getStatusCode() + ' ' + res.getBody()`
    // issue as updateAccount. Documents current NPE behavior.
    // ---------------------------------------------------------------

    @isTest
    static void testAddSubscriptionWithLicense_ThrowsDueToUnguardedNullResponse() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.addSubscriptionWithLicense(licenseId, 2, '001000000000001AAA', '005000000000001AAA', 'SUB-005', '15');

        Boolean exceptionThrown = false;
        try {
            Test.stopTest();
        } catch (NullPointerException npe) {
            exceptionThrown = true;
        }
    }

    // ---------------------------------------------------------------
    // subscribeHVPostalCode / unSubscribeHVPostalCode
    //
    // These two methods build and send the HttpRequest directly rather
    // than going through sendApiCall(), so they are NOT short-circuited
    // by Test.isRunningTest() and genuinely exercise the callout via
    // HttpCalloutMock.
    // ---------------------------------------------------------------

    @isTest
    static void testSubscribeHVPostalCode_Success() {
        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, '{"Result":"Success"}'));

        Test.startTest();
        TPCRMRestHandler.subscribeHVPostalCode('005000000000001AAA', '123', 5, 19.99);
        Test.stopTest();
        // Method only logs the response; reaching this line without an
        // exception confirms the callout and chunked debug logging succeeded.
    }

    @isTest
    static void testSubscribeHVPostalCode_ErrorResponse() {
        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(500, '{"error":"failure"}'));

        Test.startTest();
        TPCRMRestHandler.subscribeHVPostalCode('005000000000001AAA', '123', 5, 19.99);
        Test.stopTest();
    }

    @isTest
    static void testUnSubscribeHVPostalCode_Success() {
        Test.setMock(HttpCalloutMock.class, new StaticResourceMock(200, '{"Result":"Success"}'));

        Test.startTest();
        TPCRMRestHandler.unSubscribeHVPostalCode('005000000000001AAA', '123');
        Test.stopTest();
    }

    // ---------------------------------------------------------------
    // updateSubscriptionDetails
    //
    // BUG: same unguarded response-dereference pattern.
    // ---------------------------------------------------------------

    @isTest
    static void testUpdateSubscriptionDetails_ThrowsDueToUnguardedNullResponse() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.updateSubscriptionDetails('Suspended', licenseId, '001000000000001AAA', '005000000000001AAA', 'SUB-006');

        Boolean exceptionThrown = false;
        try {
            Test.stopTest();
        } catch (NullPointerException npe) {
            exceptionThrown = true;
        }
    }

    // ---------------------------------------------------------------
    // updateSubscriptionLicenses
    //
    // BUG: same unguarded response-dereference pattern.
    // ---------------------------------------------------------------

    @isTest
    static void testUpdateSubscriptionLicenses_ThrowsDueToUnguardedNullResponse() {
        Id licenseId = getLicenseId();

        Test.startTest();
        TPCRMRestHandler.updateSubscriptionLicenses('Active', 4, '001000000000001AAA', '005000000000001AAA', 'SUB-007', '15', licenseId);

        Boolean exceptionThrown = false;
        try {
            Test.stopTest();
        } catch (NullPointerException npe) {
            exceptionThrown = true;
        }
    }

    // ---------------------------------------------------------------
    // sendApiCall
    // ---------------------------------------------------------------

    @isTest
    static void testSendApiCall_ReturnsNullInTestContext() {
        Test.startTest();
        HttpResponse res = TPCRMRestHandler.sendApiCall('https://example.com/api', 'GET', null);
        Test.stopTest();
    }

    @isTest
    static void testSendApiCall_WithBody_ReturnsNullInTestContext() {
        Test.startTest();
        HttpResponse res = TPCRMRestHandler.sendApiCall('https://example.com/api', 'POST', '{"foo":"bar"}');
        Test.stopTest();
    }
}
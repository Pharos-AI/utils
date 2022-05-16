@IsTest
private class LogTest {

    private static void assertCreatedLog(Log.Category logCategory) {
        List<pharos__Log__c> logs = [SELECT Id, pharos__Category__c, pharos__Hash__c FROM pharos__Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals(logCategory.name(), logs.get(0).pharos__Category__c);
        System.assertNotEquals(null, logs.get(0).pharos__Hash__c);
    }

    private static void assertCreatedIntegrationLog() {
        List<pharos__Log__c> logs = [SELECT Id, pharos__Category__c, pharos__Hash__c FROM pharos__Log__c];
        System.assertNotEquals(1, logs.size());
        System.assertEquals(Log.Category.Integration.name(), logs.get(0).pharos__Category__c);
        System.assertEquals(Log.Category.Integration.name(), logs.get(1).pharos__Category__c);
        System.assertNotEquals(null, logs.get(0).pharos__Hash__c);
        System.assertNotEquals(null, logs.get(1).pharos__Hash__c);
    }

    private static void assertBefore() {
        Integer countBefore = [SELECT COUNT() FROM pharos__Log__c];
        System.assertEquals(0, countBefore);
    }

    @TestSetup
    private static void testSetup() {
        pharos.Test_Logger.initSettings();
    }

    @IsTest
    private static void test_sync_event() {
        assertBefore();

        Test.startTest();
        Log.instance.event(Log.Type.Backend, Log.Area.Community, 'some event', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Event);
    }

    @IsTest
    private static void test_async_event() {
        assertBefore();

        Test.startTest();
        Log.instance.eventAsync(Log.Type.Backend, Log.Area.Community, 'some event', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Event);
    }

    @IsTest
    private static void test_sync_debug() {
        assertBefore();

        Test.startTest();
        Log.instance.debug(Log.Type.Backend, Log.Area.Community, 'some debug', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Debug);
    }

    @IsTest
    private static void test_async_debug() {
        assertBefore();

        Test.startTest();
        Log.instance.debugAsync(Log.Type.Backend, Log.Area.Community, 'some debug', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Debug);
    }

    @IsTest
    private static void test_sync_warning() {
        assertBefore();

        Test.startTest();
        Log.instance.warning(Log.Type.Backend, Log.Area.Community, 'some warning', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Warning);
    }

    @IsTest
    private static void test_async_warning() {
        assertBefore();

        Test.startTest();
        Log.instance.warningAsync(Log.Type.Backend, Log.Area.Community, 'some warning', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Warning);
    }

    @IsTest
    private static void test_sync_error() {
        assertBefore();

        Test.startTest();
        Log.instance.error(Log.Type.Backend, Log.Area.Community, 'some error', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Error);
    }

    @IsTest
    private static void test_async_error() {
        assertBefore();

        Test.startTest();
        Log.instance.errorAsync(Log.Type.Backend, Log.Area.Community, 'some error', 'error details');
        Test.stopTest();

        assertCreatedLog(Log.Category.Error);
    }

    @IsTest
    private static void test_sync_error_from_exception() {
        assertBefore();

        Test.startTest();
        try {
            Integer i = 2/0;
        }
        catch(Exception e) {
            Log.instance.error(Log.Area.Community, e);
        }
        Test.stopTest();

        assertCreatedLog(Log.Category.Error);
    }

    @IsTest
    private static void test_async_error_from_exception() {
        assertBefore();

        Test.startTest();
        try {
            Integer i = 2/0;
        }
        catch(Exception e) {
            Log.instance.errorAsync(Log.Area.Community, e);
        }
        Test.stopTest();

        assertCreatedLog(Log.Category.Error);
    }

    @IsTest
    private static void test_sync_integration_from_exception() {
        test_integration_from_exception(false);
    }

    @IsTest
    private static void test_async_integration_from_exception() {
        test_integration_from_exception(true);
    }

    private static void test_integration_from_exception(Boolean isAsync) {
        assertBefore();

        Test.startTest();
        HttpCalloutMock multiCalloutMock = new MultiRequestMock(createEndpoint2TestResp());
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        testHttpRequest(isAsync);
        Contact contact = new Contact();
        contact.LastName = 'Test';
        insert contact;
        testHttpRequest(isAsync);
        Test.stopTest();

        assertCreatedIntegrationLog();
    }

    public static final String TEST_ENDPOINT = 'https://test.endpoint';

    public static Map<String, HttpCalloutMock> createEndpoint2TestResp() {
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put(TEST_ENDPOINT, new SingleRequestMock(
                403,
                'Forbidden',
                'Bad_OAuth_Token'
        ));
        endpoint2TestResp.put(TEST_ENDPOINT, new SingleRequestMock(
                200,
                'OK',
                'Done'
        ));
        return endpoint2TestResp;
    }

    public static void testHttpRequest(Boolean isAsync) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TEST_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{}');
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res;
        try {
            res = h.send(req);
            if (res.getStatusCode() != 200 || res.getStatusCode() != 201) {
                if (isAsync) {
                    Log.instance.integrationErrorAsync(Log.Type.Backend, Log.Area.Community, 'test integration', 'test error details', req, res);
                } else {
                    Log.instance.integrationError(Log.Type.Backend, Log.Area.Community, 'test integration', 'test error details', req, res);
                }
            }
        } catch (Exception e) {
            if (isAsync) {
                Log.instance.integrationErrorAsync(Log.Area.Community, e, req, res);
            } else {
                Log.instance.integrationError(Log.Area.Community, e, req, res);
            }
        }
    }

    public class MultiRequestMock implements HttpCalloutMock {

        Map<String, HttpCalloutMock> requests;

        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpCalloutMock mock = requests.get(req.getEndpoint());
            if (mock != null) {
                return mock.respond(req);
            }
            else {
                throw new MultiRequestMockException('HTTP callout not supported for test methods');
            }
        }

        public void addRequestMock(String url, HttpCalloutMock mock) {
            requests.put(url, mock);
        }
    }

    public class MultiRequestMockException extends Exception {}

    public class SingleRequestMock implements HttpCalloutMock {

        protected Integer code;
        protected String status;
        protected String body;
        protected String reqBody;

        public SingleRequestMock(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody(this.body);
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            this.reqBody = req.getBody();
            return res;
        }

        public String getBodyRequest() {
            return this.reqBody;
        }
    }

}
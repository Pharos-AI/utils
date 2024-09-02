/**
    @description helper class for the Triton Logger project
 */
public with sharing class TritonHelper {

    /**
    * Creates a key for log level based on:
    * @param category -- log category field
    * @param tye -- log type field
    * @param area -- log functional area field
    * @return -- a string with values in the following format: Category:{0};Type:{1};Area:{2}
    */
    public static String buildLogLevelKey(String category, String type, String area) {
        return String.format('Category:{0};Type:{1};Area:{2}', new String[]{category, type, area});
    }

    /**
    * Compares 2 log levels.
    * @param value -- this is the value compared against
    * @param toCompare -- comparison performed against this value
    * @return -- if value is higher than toCompare returns false, otherwise true
    */
    public static Boolean compareLevel(TritonTypes.Level value, TritonTypes.Level toCompare) {
        return value.ordinal() >= toCompare.ordinal();
    }

    /**
     * Generates a UUID.
     * Used to create a transaction Id
     */
    public static String generateUUID4() {
        String h = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        return 
            h.substring(0,8) +
            '-' +
            h.substring(8,12) +
            '-' +
            h.substring(12,16) +
            '-' +
            h.substring(16,20) +
            '-' +
            h.substring(20);
    }

    /**
    * Json serialization for http request and response objects.
    * Used by integration logs.
    */
    public static String toJson(RestRequest request, RestResponse response) {
        return JSON.serialize(new TritonHelper.IntegrationWrapper(
            new pharos.HttpRequestWrapper(request).formatRequest(),
            new pharos.HttpResponseWrapper(response).formatResponse()
        ));
    }

    public static String toJson(HttpRequest request, HttpResponse response) {
        return JSON.serialize(new TritonHelper.IntegrationWrapper(
            new pharos.HttpRequestWrapper(request).formatRequest(),
            new pharos.HttpResponseWrapper(response).formatResponse()
        ));
    }

    /**
    * Wrapper class for integration logs
    * Used to create the Json structure that combines http objects
    */
    public class IntegrationWrapper {
        public Map<String, Object> request;
        public Map<String, Object> response;
        public IntegrationWrapper(Map<String, Object> request, Map<String, Object> response) {
            this.request = request;
            this.response = response;
        }
    }
}

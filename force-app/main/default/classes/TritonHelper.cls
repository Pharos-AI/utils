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
    public static Boolean compareLevel(Level value, Level toCompare) {
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
    * Checks if a log should be persisted based on the current log level
    * @param log -- Pharos log record to be saved
    * @return -- true if current log's level is below the level set in the settings, false otherwise
    */
    public static Boolean isLogAllowedForLogLevel(pharos__Log__c log) {
        if (String.isBlank(log.Log_Level__c) || LOG_LEVELS.isEmpty()) return true;

        //a set of possible mapping permutations
        //these will be checked in the same order as this list
        String[] permutations = new String[] {
                buildLogLevelKey(log.pharos__Category__c, log.pharos__Type__c, log.pharos__Area__c),
                buildLogLevelKey(log.pharos__Category__c, log.pharos__Type__c, null),
                buildLogLevelKey(log.pharos__Category__c, null, log.pharos__Area__c),
                buildLogLevelKey(null, log.pharos__Type__c, log.pharos__Area__c),
                buildLogLevelKey(null, null, log.pharos__Area__c),
                buildLogLevelKey(null, log.pharos__Type__c, null),
                buildLogLevelKey(log.pharos__Category__c, null, null),
                buildLogLevelKey(null, null, null)
        };

        Level currentLevel = Level.valueOf(log.Log_Level__c);
        for (String key : permutations) {
            if (LOG_LEVELS.containsKey(key)) {
                if (compareLevel(LOG_LEVELS.get(key), currentLevel)) return true;
            }
        }

        return false;
    }

    /**
    * Json serialization for http request and response objects.
    * Used by integration logs.
    */
    public static String toJson(RestRequest request, RestResponse response) {
        return JSON.serialize(new TritonLog.IntegrationWrapper(
            new pharos.HttpRequestWrapper(request).formatRequest(),
            new pharos.HttpResponseWrapper(response).formatResponse()
        ));
    }

    public static String toJson(HttpRequest request, HttpResponse response) {
        return JSON.serialize(new TritonLog.IntegrationWrapper(
            new pharos.HttpRequestWrapper(request).formatRequest(),
            new pharos.HttpResponseWrapper(response).formatResponse()
        ));
    }
}

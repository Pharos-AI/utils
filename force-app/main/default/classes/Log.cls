        public without sharing class Log {
            /**
             * -----------------------------
             * HELPER METHODS AND CONSTANTS
             * -----------------------------
             */

            /**
             * Generates a UUID.
             * Used to create a transaction Id
             */
            public static String generateUUID4() {
                Blob b = Crypto.generateAesKey(128);
                String h = EncodingUtil.convertToHex(b);
                String guid = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);
                return guid;
            }


            //singleton instance
            private final pharos.Logger logger;
            public static Log instance {
                get {
                    if (instance == null) {
                        instance = new Log(pharos.Logger.getInstance());
                    }
                    return instance;
                }
                private set;
            }

            private Log(pharos.Logger logger) {
                this.logger = logger;
            }

            /**
            * Helper map for storing current log levels
            */
            @TestVisible
            private static Map<String, Level> LOG_LEVELS {
                get {
                    if (LOG_LEVELS == null) {
                        LOG_LEVELS = new Map<String, Level>();
                        for(Log_Level__mdt ll : LOG_LEVELS_MDT) {
                            LOG_LEVELS.put(
                                    buildLogLevelKey(ll.Category__c, ll.Type__c, ll.Area__c),
                                    Level.valueOf(ll.Level__c));
                        }
                    }
                    return LOG_LEVELS;
                }
                set;
            }

            @TestVisible
            private static Log_Level__mdt[] LOG_LEVELS_MDT = Log_Level__mdt.getAll().values();

            /**
            * Adds a log to the buffer.
            * Performs a check on current log level prior
            * @param log -- Pharos log record
            */
            public void add(pharos__Log__c log) {
                if (isLogAllowedForLogLevel(log)) {
                    this.logger.add(log);
                }
            }

            /**
            * Checks if a log should be persisted based on the current log level
            * @param log -- Pharos log record to be saved
            * @return -- true if current log's level is below the level set in the settings, false otherwise
            */
            public static Boolean isLogAllowedForLogLevel(pharos__Log__c log) {
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

                if (String.isBlank(log.Log_Level__c) || LOG_LEVELS.isEmpty()) return true;

                Level currentLevel = Level.valueOf(log.Log_Level__c);
                for (String key : permutations) {
                    if (LOG_LEVELS.containsKey(key)) {
                        if (compareLevel(LOG_LEVELS.get(key), currentLevel)) return true;
                    }
                }

                return false;
            }

            /**
            * Creates a key for log level based on:
            * @param category -- log category field
            * @param tye -- log type field
            * @param area -- log functional area field
            * @return -- a string with values in the following format: Category:{0};Type:{1};Area:{2}
            */
            private static String buildLogLevelKey(String category, String type, String area) {
                return String.format('Category:{0};Type:{1};Area:{2}', new String[]{category, type, area});
            }

            /**
            * Compares 2 log levels.
            * @param value -- this is the value compared against
            * @param toCompare -- comparison performed against this value
            * @return -- if value is higher than toCompare returns false, otherwise true
            */
            private static Boolean compareLevel(Level value, Level toCompare) {
                return value.ordinal() >= toCompare.ordinal();
            }

            /**
            * Persist Log records immediately.
            * Use this method to persist logs to the database right away.
            */
            public void flush() {
                this.logger.flush();
            }

            /**
            * Shorthand method for creating a new builder
            */
            public static pharos.LogBuilder makeBuilder() {
                return pharos.LogBuilder.getInstance();
            }

            /**
            * Json serialization for http request and response objects.
            * Used by integration logs.
            */
            public static String toJson(RestRequest request, RestResponse response) {
                return JSON.serialize(new IntegrationWrapper(
                        new pharos.HttpRequestWrapper(request).formatRequest(),
                        new pharos.HttpResponseWrapper(response).formatResponse()
                ));
            }

            public static String toJson(HttpRequest request, HttpResponse response) {
                return JSON.serialize(new IntegrationWrapper(
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

            /**
            * Stack trace offset.
            * In case no stack is provided, it will be obtained automatically for error and debug logs.
            * Use the offset to remove unwanted lines from top of the stack trace
            * such as util method invocations.
            */
            private Integer stackOffset = 0;
            private void incStackOffset() {
                stackOffset++;
            }
            private void resetStackOffset() {
                stackOffset = 0;
            }

            //new line separator for formatting
            private static final String SPACE_SEP = '\n\n';

            private static final String USER_ID = 'pharos__User_Id__c';
            private static final String APEX_NAME = 'pharos__Apex_Name__c';
            private static final String RELATED_ID = 'pharos__Related_Id__c';
            private static final String INTERVIEW_GUID = 'pharos__Interview_GUID_External__c';
            private static final String STACKTRACE_PARSE_RESULT = 'pharos__Stacktrace_Parse_Result__c';
            private static final String CREATED_TIMESTAMP = 'pharos__Created_Timestamp__c';
            private static final String DURATION = 'pharos__Duration__c';
            private static final String LOG_LEVEL = 'Log_Level__c';
            private static final String CPU_TIME = 'CPU_Time__c';
            private static final String HEAP_SIZE = 'Heap_Size__c';
            private static final String SOQL_QUERIES = 'SOQL_Queries__c';


            /**
             * A wrapper class for passing log data from flow
             */
            public class FlowLog {
                @InvocableVariable(Required=true Label='Category')
                public String category;
                @InvocableVariable(Required=true Label='Type')
                public String type;
                @InvocableVariable(Required=true Label='Area')
                public String area;
                @InvocableVariable(Required=true Label='Summary')
                public String summary;
                @InvocableVariable(Required=true Label='Details')
                public String details;
                @InvocableVariable(Required=true Label='Interview GUID')
                public String interviewGUID;
                @InvocableVariable(Required=false Label='Additional Fields')
                public String additionalFields;
            }

            /**
             * A wrapper class for passing log data from LWC
             */
            public class ComponentLog {
                @AuraEnabled
                public String category { get; set; }
                @AuraEnabled
                public String type { get; set; }
                @AuraEnabled
                public String area { get; set; }
                @AuraEnabled
                public String summary { get; set; }
                @AuraEnabled
                public String details { get; set; }
                @AuraEnabled
                public Decimal totalTime { get; set; }
                @AuraEnabled
                public String userId { get; set; }
                @AuraEnabled
                public String recordId { get; set; }
                @AuraEnabled
                public String objectApiName { get; set; }
                @AuraEnabled
                public String stack { get; set; }
                @AuraEnabled
                public Error error { get; set; }
                @AuraEnabled
                public Component component { get; set; }
                @AuraEnabled
                public String transactionId { get; set; }
                @AuraEnabled
                public Decimal createdTimestamp { get; set; }
                @AuraEnabled
                public String level { get; set; }
                @AuraEnabled
                public Decimal duration { get; set; }
            }

            /**
             * A wrapper class for passing error log data from LWC
             */
            public class Error {
                @AuraEnabled
                public String message { get; set; }
                @AuraEnabled
                public String stack { get; set; }
                @AuraEnabled
                public String type { get; set; }
            }

            /**
             * A wrapper class for passing component info data from LWC
             */
            public class Component {
                @AuraEnabled
                public String category { get; set; }
                @AuraEnabled
                public String name { get; set; }
                @AuraEnabled
                public String function { get; set; }
                @AuraEnabled
                public String action { get; set; }
            }

            /**
             * Builder class for constructing Pharos post processing settings
             */
            public class PostProcessingControlsBuilder {

                private final Map<String, Boolean> controls;

                private final String STACK_TRACE_KEY = 'stackTrace';
                private final String USER_INFO_KEY = 'userInfo';
                private final String OBJECT_INFO_KEY = 'objectInfo';
                private final String RELATED_OBJECTS_KEY = 'relatedObjects';
                private final String DEPLOY_RESULT_KEY = 'deployResult';
                private final String AUDIT_TRAIL_KEY = 'auditTrail';
                private final String PENDING_JOBS_KEY = 'pendingJobs';
                private final String TOTAL_ACTIVE_SESSION_KEY = 'totalActiveSession';
                private final String INSTALLED_PACKAGES_KEY = 'installedPackages';

                private PostProcessingControlsBuilder() {
                    controls = new Map<String, Boolean>{
                            STACK_TRACE_KEY => false,
                            USER_INFO_KEY => false,
                            OBJECT_INFO_KEY => false,
                            RELATED_OBJECTS_KEY => false,
                            DEPLOY_RESULT_KEY => false,
                            AUDIT_TRAIL_KEY => false,
                            PENDING_JOBS_KEY => false,
                            TOTAL_ACTIVE_SESSION_KEY => false,
                            INSTALLED_PACKAGES_KEY => false
                    };
                }

                /**
                 * Sets all flags to the value provided
                 */
                public PostProcessingControlsBuilder setAll(Boolean value) {
                    for (String key : controls.keySet()) {
                        controls.put(key, value);
                    }
                    return this;
                }

                /**
                 * Controls whether stack trace is enhanced by Pharos
                 * Only applicable to Apex and Integration logs
                 */
                public PostProcessingControlsBuilder stackTrace(Boolean value) {
                    controls.put(STACK_TRACE_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches User name
                 */
                public PostProcessingControlsBuilder userInfo(Boolean value) {
                    controls.put(USER_INFO_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches User name
                 */
                public PostProcessingControlsBuilder objectInfo(Boolean value) {
                    controls.put(OBJECT_INFO_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches related objects names
                 */
                public PostProcessingControlsBuilder relatedObjects(Boolean value) {
                    controls.put(RELATED_OBJECTS_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches recent deployments
                 */
                public PostProcessingControlsBuilder deployResult(Boolean value) {
                    controls.put(DEPLOY_RESULT_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches recent audit trail
                 */
                public PostProcessingControlsBuilder auditTrail(Boolean value) {
                    controls.put(AUDIT_TRAIL_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches jobs currently in the flox queue
                 */
                public PostProcessingControlsBuilder pendingJobs(Boolean value) {
                    controls.put(PENDING_JOBS_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches the number of currently logged in users
                 */
                public PostProcessingControlsBuilder totalActiveSession(Boolean value) {
                    controls.put(TOTAL_ACTIVE_SESSION_KEY, value);
                    return this;
                }

                /**
                 * Controls whether Pharos fetches the number of currently installed packages
                 */
                public PostProcessingControlsBuilder installedPackages(Boolean value) {
                    controls.put(INSTALLED_PACKAGES_KEY, value);
                    return this;
                }

                /**
                 * Returns a Json version of the settings
                 */
                public String build() {
                    return JSON.serialize(controls);
                }

            }



            /**
            * Log Levels.
            * Values listed from the least verbose to the most verbose
            */
            public enum Level {
                ERROR,
                WARNING,
                INFO,
                DEBUG,
                FINE,
                FINER,
                FINEST
            }

            /**
            * Log classification.
            * Use these enums to provide values for Category, Type and Functional Area fields on the log record.
            * These fields are useful for analytics and should be populated on all records.
            * Feel free to modify these or add new values as you see fit. It is best to stick to the
            * general spirit of the definition.
            */

            /**
            * Category.
            * Provides general classification. Defaults are Error, Warning, Event, Debug.
            * This value will be written to the Category field.
            * These values should reflect what kind of log entry they represent at a high level.
            */
            public enum Category {
                Apex,
                Flow,
                Warning,
                Event,
                Debug,
                Integration
            }

            /**
            * Type.
            * Provides a more specific classification. This value will be written to the Type field.
            * Defaults are Backend and Frontend.
            * This value represents a more specific technical classification.
            * When an Exception is provided, the methods below will use the Exception type.
            */
            public enum Type {
                Backend,
                Frontend,
                LongRunningRequest,
                ConcurrentRequestsLimit,
                AccountTrigger
            }

            /**
            * Area.
            * Represents the functional area. This value will be written to the Functional Area field.
            * These values should represent the functional area from a business perspective.
            * E.g. DealRegistration, PartnerCommunity, CustomPipelineUI.
            */
            public enum Area {
                OpportunityManagement,
                LeadConversion,
                Community,
                RestAPI,
                Accounts
            }

            /**
             * Autogenrated Transaction UUID
             * This value can be passed around to trace a complex process spanning multiple Salesforce transactions
             * Can be used between LWC/Apex/Flow transitions when complex tracing is required.
             */
            public String TRANSACTION_ID {
                get {
                    if (TRANSACTION_ID == null) {
                        TRANSACTION_ID = generateUUID4();
                    }
                    return TRANSACTION_ID;
                }
                private set;
            }

            /**
             * Start new transaction
             * This method will obtain a new autogenrated transaction id or use the current one
             */
            public String startTransaction() {
                return TRANSACTION_ID;
            }

            /**
             * Resumes a transaction
             * Assumes an existing transaction id
             * Use this method to tie together different Salesforce transactions.
             */
            public void resumeTransaction(String transactionId) {
                TRANSACTION_ID = transactionId;
            }

            /**
             * Stops a transaction
             * Resets the current transaction Id
             * Use this method to marking tracking logs with the current transaction Id
             */
            public void stopTransaction() {
                TRANSACTION_ID = null;
            }

            /**
            * ---------------------------
            * Log methods.
            * ---------------------------
            *
            * There are 2 types of log methods per each category: buffered and immediate
            * Buffered methods will add to the log collection without flush()'ing
            * Immediate methods will add to the log collection and call flush()
            *
            */

            /**
            * Add Log with Error Category.
            * This method will automatically get the stacktrace and save it on the log record.
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            */
            public void addError(Type type, Area area, String summary, String details) {
                add(
                        makeBuilder()
                                .category(Category.Apex.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                                .transactionId(TRANSACTION_ID)
                                .createIssue()
                                .attribute(LOG_LEVEL, Level.ERROR.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void error(Type type, Area area, String summary, String details) {
                incStackOffset();
                addError(type, area, summary, details);
                flush();
            }


            /**
            * Add Log with Error Category.
            * This method will automatically get the stacktrace from Exception.
            * Type will be obtained from Exception. If blank, a default Backend Type will be saved
            * Summary is the Exception message.
            * Details will be a combination of Exception String and stacktrace
            * @param area -- log record Functional Area (see Area enum)
            * @param e -- instance of an Exception
            */
            public void addError(Area area, Exception e) {
                add(
                        makeBuilder()
                                .category(Category.Apex.name())
                                //use exception type, Backend if blank
                                .type(String.isBlank(e.getTypeName()) ? Type.Backend.name() : e.getTypeName())
                                .area(area.name())
                                .summary(e.getMessage())
                                .stackTrace(e.getStackTraceString())
                                .details(String.valueOf(e) + SPACE_SEP + e.getStackTraceString())
                                .transactionId(TRANSACTION_ID)
                                .createIssue()
                                .attribute(LOG_LEVEL, Level.ERROR.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void error(Area area, Exception e) {
                incStackOffset();
                addError(area, e);
                flush();
                resetStackOffset();
            }


            /**
            * Add Log with Warning Category.
            * This method will not save a stacktrace.
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            */
            public void addWarning(Type type, Area area, String summary, String details) {
                add(
                        makeBuilder()
                                .category(Category.Warning.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .postProcessing(
                                        new PostProcessingControlsBuilder()
                                                .stackTrace(true)
                                                .userInfo(true)
                                                .objectInfo(true)
                                                .build())
                                .transactionId(TRANSACTION_ID)
                                .attribute(LOG_LEVEL, Level.WARNING.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void warning(Type type, Area area, String summary, String details) {
                incStackOffset();
                addWarning(type, area, summary, details);
                flush();
                resetStackOffset();
            }


            /**
            * Add Log with Debug Category.
            * This method will automatically get the stacktrace.
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            */
            public void addDebug(Type type, Area area, String summary, String details) {
                add(
                        makeBuilder()
                                .category(Category.Debug.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .postProcessing(
                                        new PostProcessingControlsBuilder()
                                                .stackTrace(true)
                                                .userInfo(true)
                                                .objectInfo(true)
                                                .build())
                                .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                                .transactionId(TRANSACTION_ID)
                                .attribute(LOG_LEVEL, Level.DEBUG.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void debug(Type type, Area area, String summary, String details) {
                incStackOffset();
                addDebug(type, area, summary, details);
                flush();
                resetStackOffset();
            }

            /**
            * Add Log with Debug Category.
            * This method will automatically get the stacktrace.
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            */
            public void addDebug(Type type, Area area, String summary, String details, Decimal duration) {
                add(
                        makeBuilder()
                                .category(Category.Debug.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .postProcessing(
                                        new PostProcessingControlsBuilder()
                                                .stackTrace(true)
                                                .userInfo(true)
                                                .objectInfo(true)
                                                .build())
                                .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                                .transactionId(TRANSACTION_ID)
                                .attribute(LOG_LEVEL, Level.DEBUG.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .attribute(Log.DURATION, duration)
                                .build());
            }

            /**
            * Immediate
            */
            public void debug(Type type, Area area, String summary, String details, Decimal duration) {
                incStackOffset();
                addDebug(type, area, summary, details, duration);
                flush();
                resetStackOffset();
            }

            /**
            * Add Log with Event Category.
            * Default INFO log level
            * @param level -- log level (see Level enum)
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            */
            public void addEvent(Level level, Type type, Area area, String summary, String details) {
                add(
                        makeBuilder()
                                .category(Category.Event.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .postProcessing(
                                        new PostProcessingControlsBuilder()
                                                .stackTrace(true)
                                                .userInfo(true)
                                                .objectInfo(true)
                                                .build())
                                .transactionId(TRANSACTION_ID)
                                .attribute(LOG_LEVEL, level.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }
            /**
            * Immediate
            */
            public void event(Level level, Type type, Area area, String summary, String details) {
                incStackOffset();
                addEvent(level, type, area, summary, details);
                flush();
                resetStackOffset();
            }


            /**
            * Add Log with Event Category.
            * Default INFO log level
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            */
            public void addEvent(Type type, Area area, String summary, String details) {
                incStackOffset();
                addEvent(Level.INFO, type, area, summary, details);
                resetStackOffset();
            }

            /**
            * Immediate
            */
            public void event(Type type, Area area, String summary, String details) {
                incStackOffset();
                event(Level.INFO, type, area, summary, details);
                resetStackOffset();
            }


            /**
            * Add Log with Integration Category.
            * This method will automatically get the stacktrace from Exception.
            * @param area -- log record Functional Area (see Area enum)
            * @param e -- instance of an Exception
            * @param request -- HttpRequest of the issue. Saves to log record Details field
            * @param response -- HttpResponse of the issue. Saves to log record Details field
            */
            public void addIntegrationError(Area area, Exception e, HttpRequest request, HttpResponse response) {
                add(
                        makeBuilder()
                                .category(Category.Integration.name())
                                //Use Backend as default type
                                .type(String.isBlank(e.getTypeName()) ? Type.Backend.name() : e.getTypeName())
                                .area(area.name())
                                .summary(e.getMessage())
                                .details(String.valueOf(e) + SPACE_SEP + e.getStackTraceString())
                                .stackTrace(e.getStackTraceString())
                                .createIssue()
                                //Set the system field with a json serialized request/response value
                                .attribute(STACKTRACE_PARSE_RESULT, toJson(request, response))
                                .attribute(LOG_LEVEL, Level.ERROR.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void integrationError(Area area, Exception e, HttpRequest request, HttpResponse response) {
                incStackOffset();
                addIntegrationError(area, e, request, response);
                flush();
                resetStackOffset();
            }


            /**
            * Add Log with Integration Category.
            * This method will automatically get the stacktrace from Exception.
            * @param area -- log record Functional Area (see Area enum)
            * @param e -- instance of an Exception
            * @param request -- RestRequest of the issue. Saves to log record Details field
            * @param response -- RestResponse of the issue. Saves to log record Details field
            */
            public void addIntegrationError(Area area, Exception e, RestRequest request, RestResponse response) {
                add(
                        makeBuilder()
                                .category(Category.Integration.name())
                                .type(String.isBlank(e.getTypeName()) ? Type.Backend.name() : e.getTypeName())
                                .area(area.name())
                                .summary(e.getMessage())
                                .details(String.valueOf(e) + SPACE_SEP + e.getStackTraceString())
                                .stackTrace(e.getStackTraceString())
                                .createIssue()
                                .attribute(STACKTRACE_PARSE_RESULT, toJson(request, response))
                                .attribute(LOG_LEVEL, Level.ERROR.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void integrationError(Area area, Exception e, RestRequest request, RestResponse response) {
                incStackOffset();
                addIntegrationError(area, e, request, response);
                flush();
                resetStackOffset();
            }


            /**
            * Add Log with Integration Category.
            * This method will automatically get the stacktrace.
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            * @param request -- HttpRequest of the issue. Saves to log record Details field
            * @param response -- HttpResponse of the issue. Saves to log record Details field
            */
            public void addIntegrationError(Type type, Area area, String summary, String details, HttpRequest request, HttpResponse response) {
                incStackOffset();
                add(
                        makeBuilder()
                                .category(Category.Integration.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                                .createIssue()
                                .attribute(STACKTRACE_PARSE_RESULT, toJson(request,response))
                                .attribute(LOG_LEVEL, Level.ERROR.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
                resetStackOffset();
            }

            /**
            * Immediate
            */
            public void integrationError(Type type, Area area, String summary, String details, HttpRequest request, HttpResponse response) {
                incStackOffset();
                addIntegrationError(type, area, summary, details, request, response);
                flush();
            }


            /**
            * Add Log with Integration Category.
            * This method will automatically get the stacktrace.
            * @param type -- log record Type (see Type enum)
            * @param area -- log record Functional Area (see Area enum)
            * @param summary -- summary of the issue. Saves to log record Summary field
            * @param details -- details of the issue. Saves to log record Details field
            * @param request -- RestRequest of the issue. Saves to log record Details field
            * @param response -- RestResponse of the issue. Saves to log record Details field
            */
            public void addIntegrationError(Type type, Area area, String summary, String details, RestRequest request, RestResponse response) {
                add(
                        makeBuilder()
                                .category(Category.Integration.name())
                                .type(type.name())
                                .area(area.name())
                                .summary(summary)
                                .details(details)
                                .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                                .createIssue()
                                .attribute(STACKTRACE_PARSE_RESULT, toJson(request, response))
                                .attribute(LOG_LEVEL, Level.ERROR.name())
                                .attribute(CPU_TIME, System.Limits.getCpuTime())
                                .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                .build());
            }

            /**
            * Immediate
            */
            public void integrationError(Type type, Area area, String summary, String details, RestRequest request, RestResponse response) {
                incStackOffset();
                addIntegrationError(type, area, summary, details, request, response);
                flush();
            }

            /**
            * ---------------------------
            * Flow/LWC log methods
            * ---------------------------
            */

            /**
            * Create component logs from LWC
            * Use this method to persist logs generated from LWC components
            * @param componentLogs -- a collection of ComponentLog objects
            */
            @AuraEnabled
            public static void saveComponentLogs(List<ComponentLog> componentLogs) {
                for (ComponentLog componentLog : componentLogs) {
                    instance.add(
                            makeBuilder()
                                    //category will be fetched from the componentLog
                                    .category(String.isNotBlank(componentLog.category) ? componentLog.category : componentLog.component.category)
                                    //type will be fetched from the componentLog directly, of from the error. If neither are set, Frontend will be used
                                    .type(String.isNotBlank(componentLog.type) ? componentLog.type :
                                            componentLog.error != null ? componentLog.error.type : Type.Frontend.name())
                                    //area will be fetched from the componentLog directly if set. Otherwise component name will be used
                                    .area(String.isNotBlank(componentLog.area) ? componentLog.area : componentLog.component.name)
                                    //summary will be fetched from the componentLog directly if set. Otherwise, error message will be used if provided.
                                    .summary(String.isNotBlank(componentLog.summary) ? componentLog.summary :
                                            componentLog.error != null ? componentLog.error.message : null)
                                    .stackTrace(componentLog.stack)
                                    .details(componentLog.details)
                                    //transaction id will be used from the componentLog, or a new transaction id will be generated
                                    .transactionId(String.isNotBlank(componentLog.transactionId) ? componentLog.transactionId : instance.TRANSACTION_ID)
                                    .attribute(USER_ID, componentLog.userId)
                                    //apex name will be set to component.function or component.action
                                    .attribute(APEX_NAME, componentLog.component.name + '.' +
                                            (String.isNotBlank(componentLog.component.function) ? componentLog.component.function : componentLog.component.action))
                                    .attribute(RELATED_ID, componentLog.recordId)
                                    //created timestamp will be either set from the componentLog if provided, otherwise current timestamp will be used
                                    .attribute(CREATED_TIMESTAMP, componentLog.createdTimestamp != null ? Double.valueOf(componentLog.createdTimestamp) : Double.valueOf(System.now().getTime()))
                                    //log level will be taken from the componentLog if provided, otherwise INFO will be used
                                    .attribute(LOG_LEVEL, String.isNotBlank(componentLog.level) ? componentLog.level : Level.INFO.name())
                                    .attribute(CPU_TIME, System.Limits.getCpuTime())
                                    .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                                    .attribute(SOQL_QUERIES, System.Limits.getQueries())
                                    .attribute(DURATION, componentLog.duration)
                                    .build());
                }
                instance.flush();
            }

            /**
             * @description
             * Invocable method, that can be called via flow.
             * Defaults to INFO log level
             * @param flowLogs The list of FlowLog instances to save
             */
            @InvocableMethod(Category='Logging' Label='Add Log' Description='Creates a log for a flow or process builder')
            public static void flow(List<FlowLog> flowLogs) {
                for (FlowLog flowLog : flowLogs) {
                    Pharos.LogBuilder builder = makeBuilder();
                    builder
                            .category(Category.Flow.name())
                            .type(flowLog.type)
                            .area(flowLog.area)
                            .summary(flowLog.summary)
                            .details(flowLog.details)
                            .transactionId(Log.instance.TRANSACTION_ID)
                            .attribute(INTERVIEW_GUID, flowLog.interviewGUID)
                            .attribute(LOG_LEVEL, Level.INFO.name())
                            .attribute(CPU_TIME, System.Limits.getCpuTime())
                            .attribute(HEAP_SIZE, System.Limits.getHeapSize())
                            .attribute(SOQL_QUERIES, System.Limits.getQueries());

                    if (String.isNotBlank(flowLog.additionalFields)) {
                        try {
                            Map<String, Object> mapAdditionalFields = (Map<String, Object>)JSON.deserializeUntyped(flowLog.additionalFields);
                            for (String field : mapAdditionalFields.keySet()) {
                                builder.attribute(field, mapAdditionalFields.get(field));
                            }
                        } catch (Exception e) {
                            builder.details(flowLog.details + '\nAdditional Information (failed to parse json input to invokable):' + '\n' + flowLog.additionalFields);
                        }
                    }
                    instance.add(builder.build());
                }
                instance.flush();
            }


        }
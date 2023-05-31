public without sharing class Log {

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
        Error,
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
        Frontend
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
        Community
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

    /**
    * Buffered Log methods.
    * Use these methods to save Log records in bulk.
    * This is the preferred way of saving logs as it reduces the number of DML operations.
    * Generally, you want to capture all errors during execution and persist them at the
    * very end a routine's execution. Be sure to wrap your code with try/catch blocks.
    * Another good practice is to log from the 'finally' clause in your try/catches to ensure
    * that logs are saved no matter what happens within your code routine.
    * NOTE that you MUST call any of the flush methods below to actually save the data.
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
        incStackOffset();
        this.logger.add(
                newBuilder()
                        .category(Category.Error.name())
                        .type(type.name())
                        .area(area.name())
                        .summary(summary)
                        .details(details)
                        .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                        .postProcessing(new PostProcessingControlsBuilder().setAll(true).build())
			.transactionId(TRANSACTION_ID)
                        .build());
        resetStackOffset();
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
        this.logger.add(
                newBuilder()
                        .category(Category.Error.name())
                        //use exception type, Backend if blank
                        .type(String.isBlank(e.getTypeName()) ? Type.Backend.name() : e.getTypeName())
                        .area(area.name())
                        .summary(e.getMessage())
                        .stackTrace(e.getStackTraceString())
                        .details(String.valueOf(e) + SPACE_SEP + e.getStackTraceString())
                        .postProcessing(new PostProcessingControlsBuilder().setAll(true).build())
			.transactionId(TRANSACTION_ID)
                        .build());
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
        this.logger.add(
                newBuilder()
                        .category(Category.Warning.name())
                        .type(type.name())
                        .area(area.name())
                        .summary(summary)
                        .details(details)
                        .postProcessing(new PostProcessingControlsBuilder().userInfo(true).objectInfo(true).build())
			.transactionId(TRANSACTION_ID)
                        .build());
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
        incStackOffset();
        this.logger.add(
                newBuilder()
                        .category(Category.Debug.name())
                        .type(type.name())
                        .area(area.name())
                        .summary(summary)
                        .details(details)
                        .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                        .postProcessing(new PostProcessingControlsBuilder().userInfo(true).objectInfo(true).build())
                        .transactionId(TRANSACTION_ID)
                        .build());
        resetStackOffset();
    }

    /**
    * Add Log with Event Category.
    * This method will not save a stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void addEvent(Type type, Area area, String summary, String details) {
        this.logger.add(
                newBuilder()
                        .category(Category.Event.name())
                        .type(type.name())
                        .area(area.name())
                        .summary(summary)
                        .details(details)
                        .postProcessing(new PostProcessingControlsBuilder().userInfo(true).objectInfo(true).build())
			.transactionId(TRANSACTION_ID)
                        .build());
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
        this.logger.add(
                newBuilder()
                        .category(Category.Integration.name())
                        .type(String.isBlank(e.getTypeName()) ? Type.Backend.name() : e.getTypeName())
                        .area(area.name())
                        .summary(e.getMessage())
                        .details(String.valueOf(e) + SPACE_SEP + e.getStackTraceString())
                        .stackTrace(e.getStackTraceString())
                        .attribute('pharos__Stacktrace_Parse_Result__c', JSON.serialize(new IntegrationWrapper(
                        new pharos.HttpRequestWrapper(request).formatRequest(),
                        new pharos.HttpResponseWrapper(response).formatResponse()
                )))
                        .build());
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
        this.logger.add(
                newBuilder()
                        .category(Category.Integration.name())
                        .type(String.isBlank(e.getTypeName()) ? Type.Backend.name() : e.getTypeName())
                        .area(area.name())
                        .summary(e.getMessage())
                        .details(String.valueOf(e) + SPACE_SEP + e.getStackTraceString())
                        .stackTrace(e.getStackTraceString())
                        .attribute('pharos__Stacktrace_Parse_Result__c', JSON.serialize(new IntegrationWrapper(
                                new pharos.HttpRequestWrapper(request).formatRequest(),
                                new pharos.HttpResponseWrapper(response).formatResponse()
                        )))
                        .build());
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
        this.logger.add(
                newBuilder()
                        .category(Category.Integration.name())
                        .type(type.name())
                        .area(area.name())
                        .summary(summary)
                        .details(details)
                        .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                        .attribute('pharos__Stacktrace_Parse_Result__c', JSON.serialize(new IntegrationWrapper(
                        new pharos.HttpRequestWrapper(request).formatRequest(),
                        new pharos.HttpResponseWrapper(response).formatResponse()
                )))
                        .build());
        resetStackOffset();
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
        incStackOffset();
        this.logger.add(
                newBuilder()
                        .category(Category.Integration.name())
                        .type(type.name())
                        .area(area.name())
                        .summary(summary)
                        .details(details)
                        .stackTrace(this.logger.getCurrentStackTrace(stackOffset))
                        .attribute('pharos__Stacktrace_Parse_Result__c', JSON.serialize(new IntegrationWrapper(
                                new pharos.HttpRequestWrapper(request).formatRequest(),
                                new pharos.HttpResponseWrapper(response).formatResponse()
                        )))
                        .build());
        resetStackOffset();
    }

    /**
    * Immediate Single Log methods.
    * Use these methods to save a single Log record right away without any buffering.
    * These methods can be used when there is a single Log record to be saved.
    * Generally, it is best to buffer logs and save them at the end of execution.
    * However, there are rare cases when a log record should be immediately persisted
    * such as when code execution could fail after the log statement.
    * NOTE that you do NOT need to call any of flush methods afterwards.
    */


    /**
    * Save Log with Error Category.
    * This method will automatically get the stacktrace and save it on the log record.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void error(Type type, Area area, String summary, String details) {
        incStackOffset();
        addError(type, area, summary, details);
        flush();
    }

    /**
    * Save Log with Error Category.
    * This method will automatically get the stacktrace from Exception.
    * Type will be obtained from Exception. If blank, a default Backend Type will be saved
    * Summary is the Exception message.
    * Details will be a combination of Exception String and stacktrace
    * @param area -- log record Functional Area (see Area enum)
    * @param e -- instance of an Exception
    */
    public void error(Area area, Exception e) {
        addError(area, e);
        flush();
    }

    /**
    * Save Log with Warning Category.
    * This method will not save a stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void warning(Type type, Area area, String summary, String details) {
        addWarning(type, area, summary, details);
        flush();
    }

    /**
    * Save Log with Debug Category.
    * This method will automatically get the stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void debug(Type type, Area area, String summary, String details) {
        incStackOffset();
        addDebug(type, area, summary, details);
        flush();
    }

    /**
    * Save Log with Event Category.
    * This method will not save a stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void event(Type type, Area area, String summary, String details) {
        addEvent(type, area, summary, details);
        flush();
    }

    /**
    * Save Log with Integration Category.
    * This method will automatically get the stacktrace from Exception.
    * @param area -- log record Functional Area (see Area enum)
    * @param e -- instance of an Exception
    * @param request -- HttpRequest of the issue. Saves to log record Details field
    * @param response -- HttpResponse of the issue. Saves to log record Details field
    */
    public void integrationError(Area area, Exception e, HttpRequest request, HttpResponse response) {
        addIntegrationError(area, e, request, response);
        flush();
    }

    /**
    * Save Log with Integration Category.
    * This method will automatically get the stacktrace from Exception.
    * @param area -- log record Functional Area (see Area enum)
    * @param e -- instance of an Exception
    * @param request -- RestRequest of the issue. Saves to log record Details field
    * @param response -- RestResponse of the issue. Saves to log record Details field
    */
    public void integrationError(Area area, Exception e, RestRequest request, RestResponse response) {
        addIntegrationError(area, e, request, response);
        flush();
    }

    /**
    * Save Log with Integration Category.
    * This method will automatically get the stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    * @param request -- HttpRequest of the issue. Saves to log record Details field
    * @param response -- HttpResponse of the issue. Saves to log record Details field
    */
    public void integrationError(Type type, Area area, String summary, String details, HttpRequest request, HttpResponse response) {
        incStackOffset();
        addIntegrationError(type, area, summary, details, request, response);
        flush();
    }

    /**
    * Save Log with Integration Category.
    * This method will automatically get the stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    * @param request -- RestRequest of the issue. Saves to log record Details field
    * @param response -- RestResponse of the issue. Saves to log record Details field
    */
    public void integrationError(Type type, Area area, String summary, String details, RestRequest request, RestResponse response) {
        incStackOffset();
        addIntegrationError(type, area, summary, details, request, response);
        flush();
    }

    /**
    * Asynchronous Single Log methods.
    * Use these methods to save a single Log record asynchronously without any buffering.
    * These methods can be used when there is a single Log record to be saved and either no DML can or should be
    * performed afterwards. A typical example would be logging right before a callout.
    * NOTE that you do NOT need to call any of flush methods afterwards.
    */

    /**
    * Save Log with Error Category in a Queueable.
    * This method will automatically get the stacktrace and save it on the log record.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void errorAsync(Type type, Area area, String summary, String details) {
        incStackOffset();
        addError(type, area, summary, details);
        flushAsync();
    }

    /**
    * Save Log with Error Category in a Queueable.
    * This method will automatically get the stacktrace from Exception.
    * Type will be obtained from Exception. If blank, a default Backend Type will be saved
    * Summary is the Exception message.
    * Details will be a combination of Exception String and stacktrace
    * @param area -- log record Functional Area (see Area enum)
    * @param e -- instance of an Exception
    */
    public void errorAsync(Area area, Exception e) {
        addError(area, e);
        flushAsync();
    }

    /**
    * Save Log with Warning Category in a Queueable.
    * This method will not save a stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void warningAsync(Type type, Area area, String summary, String details) {
        addWarning(type, area, summary, details);
        flushAsync();
    }

    /**
    * Save Log with Debug Category in a Queueable.
    * This method will automatically get the stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void debugAsync(Type type, Area area, String summary, String details) {
        incStackOffset();
        addDebug(type, area, summary, details);
        flushAsync();
    }

    /**
    * Save Log with Event Category in a Queueable.
    * This method will not save a stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    */
    public void eventAsync(Type type, Area area, String summary, String details) {
        addEvent(type, area, summary, details);
        flushAsync();
    }

    /**
    * Save Log with Integration Category in a Queueable.
    * This method will automatically get the stacktrace from Exception.
    * @param area -- log record Functional Area (see Area enum)
    * @param e -- instance of an Exception
    * @param request -- HttpRequest of the issue. Saves to log record Details field
    * @param response -- HttpResponse of the issue. Saves to log record Details field
    */
    public void integrationErrorAsync(Area area, Exception e, HttpRequest request, HttpResponse response) {
        addIntegrationError(area, e, request, response);
        flushAsync();
    }

    /**
    * Save Log with Integration Category in a Queueable.
    * This method will automatically get the stacktrace from Exception.
    * @param area -- log record Functional Area (see Area enum)
    * @param e -- instance of an Exception
    * @param request -- RestRequest of the issue. Saves to log record Details field
    * @param response -- RestResponse of the issue. Saves to log record Details field
    */
    public void integrationErrorAsync(Area area, Exception e, RestRequest request, RestResponse response) {
        addIntegrationError(area, e, request, response);
        flushAsync();
    }

    /**
    * Save Log with Integration Category in a Queueable.
    * This method will automatically get the stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    * @param request -- HttpRequest of the issue. Saves to log record Details field
    * @param response -- HttpResponse of the issue. Saves to log record Details field
    */
    public void integrationErrorAsync(Type type, Area area, String summary, String details, HttpRequest request, HttpResponse response) {
        incStackOffset();
        addIntegrationError(type, area, summary, details, request, response);
        flushAsync();
    }

    /**
    * Save Log with Integration Category in a Queueable.
    * This method will automatically get the stacktrace.
    * @param type -- log record Type (see Type enum)
    * @param area -- log record Functional Area (see Area enum)
    * @param summary -- summary of the issue. Saves to log record Summary field
    * @param details -- details of the issue. Saves to log record Details field
    * @param request -- RestRequest of the issue. Saves to log record Details field
    * @param response -- RestResponse of the issue. Saves to log record Details field
    */
    public void integrationErrorAsync(Type type, Area area, String summary, String details, RestRequest request, RestResponse response) {
        incStackOffset();
        addIntegrationError(type, area, summary, details, request, response);
        flushAsync();
    }

    /**
    * Buffer Operations.
    * Use these methods to persist logs to the database.
    * Pharos uses Platform Events so regardless of failures after the log statement,
    * all logs are guaranteed to be persisted. There are also no possibilities for
    * 'mixed dml' operations so you can perform dml on any object prior to logging.
    */

    /**
    * Persist Log records immediately.
    * Use this method to persist logs to the database right away.
    */
    public void flush() {
        this.logger.flush();
    }

    /**
    * Persist Log records in a Queueable.
    * Use this method to persist logs to the database asynchronously.
    * Can be used when immediate execution is not a concern or when no DML is possible or desired
    * after the flush.
    */
    public void flushAsync() {
        this.logger.flushAsync();
    }

    // LogBuilder
    public static pharos.LogBuilder newBuilder() {
        return pharos.LogBuilder.getInstance();
    }

    @AuraEnabled
    public static void saveComponentLogs(List<ComponentLog> componentLogs) {
        pharos.Logger logger = pharos.Logger.getInstance();
        for (ComponentLog componentLog : componentLogs) {
            logger.add(
                    newBuilder()
                            .category(String.isNotBlank(componentLog.category) ? componentLog.category : componentLog.component.category)
                            .type(String.isNotBlank(componentLog.type) ? componentLog.type : componentLog.error != null ? componentLog.error.type : Type.Frontend.name())
                            .area(String.isNotBlank(componentLog.area) ? componentLog.area : componentLog.component.name)
                            .summary(String.isNotBlank(componentLog.summary) ? componentLog.summary : componentLog.error != null ? componentLog.error.message : null)
                            .stackTrace(componentLog.stack)
                            .details(String.isNotBlank(componentLog.details) ? componentLog.details : componentLog.stack)
		    	    .transactionId(Log.instance.TRANSACTION_ID)
                            .attribute(pharos__Log__c.pharos__Apex_Name__c.getDescribe().getName(), componentLog.component.name + '.' + componentLog.component.function)
                            .attribute(pharos__Log__c.pharos__Related_Id__c.getDescribe().getName(), componentLog.recordId)
                            .attribute(pharos__Log__c.pharos__Related_Object_Type__c.getDescribe().getName(),
                                    Schema.getGlobalDescribe().get(componentLog.objectApiName) != null
                                            ? Schema.getGlobalDescribe().get(componentLog.objectApiName).getDescribe().label
                                            : componentLog.objectApiName)
                            .build());
        }
        logger.flush();
    }

    /**
     * @description Invocable method, that can be called via flow.
     * @param flowLogs The list of FlowLog instances to save
     */
    @InvocableMethod(Category='Logging' Label='Add Log' Description='Creates a log for a flow or process builder')
    public static void flow(List<FlowLog> flowLogs) {
        pharos.Logger logger = pharos.Logger.getInstance();
        for (FlowLog flowLog : flowLogs) {
            pharos.LogBuilder logBuilder = newBuilder()
                    .category(flowLog.category)
                    .type(flowLog.type)
                    .area(flowLog.area)
                    .summary(flowLog.summary)
                    .details(flowLog.details);
                    .transactionId(Log.instance.TRANSACTION_ID)
		    .attribute(pharos__Log__c.pharos__Interview_GUID__c.getDescribe().getName(), flowLog.interviewGUID);
            if (String.isNotBlank(flowLog.additionalFields)) {
                try {
                    Map<String, Object> mapAdditionalFields = (Map<String, Object>)JSON.deserializeUntyped(flowLog.additionalFields);
                    for (String field : mapAdditionalFields.keySet()) {
                        logBuilder.attribute(field, mapAdditionalFields.get(field));
                    }
                } catch (Exception e) {
                    logBuilder.details(flowLog.details + '\nAdditional Information (failed to parse json input to invokable):' + '\n' + flowLog.additionalFields);
                }
            }
            logger.add(logBuilder.build());
        }
        logger.flush();
    }
    
    public String TRANSACTION_ID {
        get {
	        if (TRANSACTION_ID == null) {
		        TRANSACTION_ID = generateUUID4();
	        }
	        return TRANSACTION_ID;
        }
        private set;
    }
	
    public String startTransaction() {
	return TRANSACTION_ID;
    }

    public void resumeTransaction(String transactionId) {
	TRANSACTION_ID = transactionId;
    }

    public void stopTransaction() {
	TRANSACTION_ID = null;
    }

    public static String generateUUID4() {
	Blob b = Crypto.generateAesKey(128);
	String h = EncodingUtil.convertToHex(b);
	String guid = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);
	return guid;
    }

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
        public String recordId { get; set; }
        @AuraEnabled
        public String objectApiName { get; set; }
        @AuraEnabled
        public String stack { get; set; }
        @AuraEnabled
        public Error error { get; set; }
        @AuraEnabled
        public Component component { get; set; }
    }

    public class Error {
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String stack { get; set; }
        @AuraEnabled
        public String type { get; set; }
    }

    public class Component {
        @AuraEnabled
        public String category { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String function { get; set; }
    }

    //new line separator for formatting
    private static final String SPACE_SEP = '\n\n';

    public class IntegrationWrapper {
        public Map<String, Object> request;
        public Map<String, Object> response;
        public IntegrationWrapper(Map<String, Object> request, Map<String, Object> response) {
            this.request = request;
            this.response = response;
        }
    }
    
    public class PostProcessingControlsBuilder {

	private final Map<String, Boolean> controls;

	private final String STACK_TRACE_KEY = 'stackTrace';
	private final String USER_INFO_KEY = 'userInfo';
	private final String OBJECT_INFO_KEY = 'objectInfo';
	private final String RELATED_OBJECT_TYPE_KEY = 'relatedObjectType';
	private final String RELATED_OBJECTS_KEY = 'relatedObjects';
	private final String FLOW_VERSION_ID_KEY = 'flowVersionId';
	private final String DEPLOY_RESULT_KEY = 'deployResult';
	private final String AUDIT_TRAIL_KEY = 'auditTrail';
	private final String PENDING_JOBS_KEY = 'pendingJobs';
	private final String TOTAL_PENDING_JOBS_KEY = 'totalPendingJobs';
	private final String TOTAL_ACTIVE_SESSION_KEY = 'totalActiveSession';
	private final String INSTALLED_PACKAGES_KEY = 'installedPackages';

	private PostProcessingControlsBuilder() {
		controls = new Map<String, Boolean>{
				STACK_TRACE_KEY => false,
				USER_INFO_KEY => false,
				OBJECT_INFO_KEY => false,
				RELATED_OBJECT_TYPE_KEY => false,
				RELATED_OBJECTS_KEY => false,
				FLOW_VERSION_ID_KEY => false,
				DEPLOY_RESULT_KEY => false,
				AUDIT_TRAIL_KEY => false,
				PENDING_JOBS_KEY => false,
				TOTAL_PENDING_JOBS_KEY => false,
				TOTAL_ACTIVE_SESSION_KEY => false,
				INSTALLED_PACKAGES_KEY => false
		};
	}
	public PostProcessingControlsBuilder setAll(Boolean value) {
		for (String key : controls.keySet()) {
			controls.put(key, value);
		}
		return this;
	}
	public PostProcessingControlsBuilder stackTrace(Boolean value) {
		controls.put(STACK_TRACE_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder userInfo(Boolean value) {
		controls.put(USER_INFO_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder objectInfo(Boolean value) {
		controls.put(OBJECT_INFO_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder relatedObjectType(Boolean value) {
		controls.put(RELATED_OBJECT_TYPE_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder relatedObjects(Boolean value) {
		controls.put(RELATED_OBJECTS_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder flowVersionId(Boolean value) {
		controls.put(FLOW_VERSION_ID_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder deployResult(Boolean value) {
		controls.put(DEPLOY_RESULT_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder auditTrail(Boolean value) {
		controls.put(AUDIT_TRAIL_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder pendingJobs(Boolean value) {
		controls.put(PENDING_JOBS_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder totalPendingJobs(Boolean value) {
		controls.put(TOTAL_PENDING_JOBS_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder totalActiveSession(Boolean value) {
		controls.put(TOTAL_ACTIVE_SESSION_KEY, value);
		return this;
	}
	public PostProcessingControlsBuilder installedPackages(Boolean value) {
		controls.put(INSTALLED_PACKAGES_KEY, value);
		return this;
	}

	public String build() {
		return JSON.serialize(controls);
	}
    }

}

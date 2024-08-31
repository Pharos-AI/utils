/**
    @description Triton log for Flows
 */
public with sharing class TritonFlowLog {

    /**
     * @description
     * Invocable method, that can be called via flow.
     * Defaults to INFO log level
     * @param flowLogs The list of FlowLog instances to save
     */
    @InvocableMethod(Category='TritonLogging' Label='Add Log' Description='Creates a log for a flow or process builder')
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
}

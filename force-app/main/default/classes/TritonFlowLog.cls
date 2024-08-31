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
            Pharos.LogBuilder builder = TritonLog.makeBuilder();
            builder
                    .category(TritonType.Category.Flow.name())
                    .type(flowLog.type)
                    .area(flowLog.area)
                    .summary(flowLog.summary)
                    .details(flowLog.details)
                    .transactionId(TritonLog.instance.TRANSACTION_ID)
                    .attribute(TritonLog.INTERVIEW_GUID, flowLog.interviewGUID)
                    .attribute(TritonLog.LOG_LEVEL, TritonType.Level.INFO.name())
                    .attribute(TritonLog.CPU_TIME, System.Limits.getCpuTime())
                    .attribute(TritonLog.HEAP_SIZE, System.Limits.getHeapSize())
                    .attribute(TritonLog.SOQL_QUERIES, System.Limits.getQueries());

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
            TritonLog.instance.add(builder.build());
        }
        TritonLog.instance.flush();
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

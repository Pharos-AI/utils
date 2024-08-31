/**
    @description Triton class is the builder class. Named "Triton" for less verbosity when using.
    E.g. Triton.instance vs TritonBuilder.instace
 */
public with sharing class Triton {
    
    /**
     * Builder class for constructing Pharos post processing settings
     */
    public class PostProcessingControlsBuilder {

        private final Map<String, Boolean> controls;

        private final String AUDIT_TRAIL_KEY = 'auditTrail';
        private final String DEPLOY_RESULT_KEY = 'deployResult';
        private final String INSTALLED_PACKAGES_KEY = 'installedPackages';
        private final String OBJECT_INFO_KEY = 'objectInfo';
        private final String PENDING_JOBS_KEY = 'pendingJobs';
        private final String RELATED_OBJECTS_KEY = 'relatedObjects';
        private final String STACK_TRACE_KEY = 'stackTrace';
        private final String TOTAL_ACTIVE_SESSION_KEY = 'totalActiveSession';
        private final String USER_INFO_KEY = 'userInfo';
        

        private PostProcessingControlsBuilder() {
            controls = new Map<String, Boolean>{
                    AUDIT_TRAIL_KEY => false,
                    DEPLOY_RESULT_KEY => false,
                    INSTALLED_PACKAGES_KEY => false
                    OBJECT_INFO_KEY => false,
                    PENDING_JOBS_KEY => false,
                    RELATED_OBJECTS_KEY => false,
                    STACK_TRACE_KEY => false,
                    TOTAL_ACTIVE_SESSION_KEY => false,
                    USER_INFO_KEY => false,
            };
        }

        /**
         * Controls whether Pharos fetches recent audit trail
         */
        public PostProcessingControlsBuilder auditTrail(Boolean value) {
            controls.put(AUDIT_TRAIL_KEY, value);
            return this;
        }

        /**
         * Returns a Json version of the settings
         */
        public String build() {
            return JSON.serialize(controls);
        }

        /**
         * Controls whether Pharos fetches recent deployments
         */
        public PostProcessingControlsBuilder deployResult(Boolean value) {
            controls.put(DEPLOY_RESULT_KEY, value);
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
         * Controls whether Pharos fetches User name
         */
        public PostProcessingControlsBuilder objectInfo(Boolean value) {
            controls.put(OBJECT_INFO_KEY, value);
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
         * Controls whether Pharos fetches related objects names
         */
        public PostProcessingControlsBuilder relatedObjects(Boolean value) {
            controls.put(RELATED_OBJECTS_KEY, value);
            return this;
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
         * Controls whether Pharos fetches the number of currently logged in users
         */
        public PostProcessingControlsBuilder totalActiveSession(Boolean value) {
            controls.put(TOTAL_ACTIVE_SESSION_KEY, value);
            return this;
        }
    }
}

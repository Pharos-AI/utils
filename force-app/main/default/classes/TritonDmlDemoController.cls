/**
    @description LWC Apex Api Class for use to demo Triton
 */
public with sharing class TritonDmlDemoController {

    public class TritonDmlDemoControllerException extends Exception {}
    
    @AuraEnabled
    public static String triggerDmlException() {
        throw new TritonDmlDemoControllerException('Error Msg');
    }
}

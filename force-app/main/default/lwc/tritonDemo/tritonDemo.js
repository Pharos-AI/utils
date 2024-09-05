import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import triggerDmlException from '@salesforce/apex/TritonDmlDemoController.triggerDmlException';
import { AREA, TYPE } from 'c/triton';
import Triton from 'c/triton';

export default class TritonDemo extends LightningElement {

    someText;
    
    async connectedCallback() {

        this.someText = 'Hello World!';
        // This demo will fire everytime this component renders on the page
        // meaning every time you load this LWC you will get a log record
        try {
            const returnMsg = await triggerDmlException();
        } catch(e) {
            
            const tritonLogger = new Triton();
            tritonLogger.error(
                TYPE.FRONTEND,
                AREA.ACCOUNTS,
                e.body.message,
                e.body.stackTrace,
                '',
                'c.tritonDemo',
                '',
                Date.now()
            );

            this.dispatchEvent(new ShowToastEvent({
                message: e.body.message,
                title: 'Test error',
                variant: {label: 'error', value: 'error' }
            }));
        }
    }
}
    
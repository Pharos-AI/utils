import {LightningElement, api} from 'lwc';
import {newLogBuilder} from 'c/logBuilder';
import saveComponentLogs from '@salesforce/apex/Log.saveComponentLogs';

export default class Logger extends LightningElement {

    logs = [];

    /**
     * Add Log with LWC / Aura Category.
     * This method will automatically get the stacktrace from Exception.
     * Type will be obtained from Exception. If blank, a default Frontend Type will be saved
     * Summary is the Exception message.
     * Details will be a combination of Exception String and stacktrace
     */
    @api
    addException(error) {
        return this._newLogBuilder().setError(error);
    }

    /**
     * Add Log with LWC / Aura Category.
     */
    @api
    addError() {
        return this._newLogBuilder();
    }

    /**
     * Add Log with Warning Category.
     */
    @api
    addWarning() {
        return this._newLogBuilder().setCategory(CATEGORY.WARNING);
    }

    /**
     * Add Log with Debug Category.
     */
    @api
    addDebug() {
        return this._newLogBuilder().setCategory(CATEGORY.DEBUG);
    }

    /**
     * Add Log with Event Category.
     */
    @api
    addInfo() {
        return this._newLogBuilder().setCategory(CATEGORY.EVENT);
    }

    /**
     * Save Log with LWC / Aura Category.
     * This method will automatically get the stacktrace from Exception.
     * Type will be obtained from Exception. If blank, a default Frontend Type will be saved
     * Summary is the Exception message.
     * Details will be a combination of Exception String and stacktrace
     */
    @api
    exception(error) {
        return this._newLogBuilder().setError(error);
    }

    /**
     * Save Log with LWC / Aura Category.
     */
    @api
    error(type, area, summary, details) {
        this._newLogBuilder()
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details);
        this.flush();
    }

    /**
     * Save Log with Warning Category.
     */
    @api
    warning(type, area, summary, details) {
        this._newLogBuilder()
            .setCategory(CATEGORY.WARNING)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details);
        this.flush();
    }

    /**
     * Save Log with Debug Category.
     */
    @api
    debug(type, area, summary, details) {
        this._newLogBuilder()
            .setCategory(CATEGORY.DEBUG)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details);
        this.flush();
    }

    /**
     * Save Log with Event Category.
     */
    @api
    info(type, area, summary, details) {
        this._newLogBuilder()
            .setCategory(CATEGORY.EVENT)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details);
        this.flush();
    }

    /**
     * Saves any logs in Logger's buffer, using the specified save method for only this call.
     */
    @api
    flush() {
        saveComponentLogs({
            componentLogs: this.logs
        }).then((data) => {
            this.logs = [];
        }).catch(error => {
            console.error(error);
        });
    }

    _newLogBuilder() {
        let logBuilder = newLogBuilder();
        this.logs.push(logBuilder);
        return logBuilder;
    }

}

/** LOG CATEGORY */
export const CATEGORY = {
    LWC: 'LWC',
    AURA: 'Aura',
    WARNING: 'Warning',
    DEBUG: 'Debug',
    EVENT: 'Event'
};

/** LOG TYPE */
export const TYPE = {
    BACKEND: 'Backend',
    FRONTEND: 'Frontend'
};
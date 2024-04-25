import {LightningElement, api} from 'lwc';
import {newLogBuilder} from 'c/logBuilder';
import saveComponentLogs from '@salesforce/apex/Log.saveComponentLogs';

export default class Logger extends LightningElement {

    /**
     * Logs buffer
     */
    @api
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
        return this._newLogBuilder().setError(error).setLevel(LEVEL.ERROR);
    }

    /**
     * Add Log with LWC / Aura Category.
     */
    @api
    addError() {
        return this._newLogBuilder().setLevel(LEVEL.ERROR);
    }

    /**
     * Add Log with Warning Category.
     */
    @api
    addWarning() {
        return this._newLogBuilder().setCategory(CATEGORY.WARNING).setLevel(LEVEL.WARNING);
    }

    /**
     * Add Log with Debug Category.
     */
    @api
    addDebug() {
        return this._newLogBuilder().setCategory(CATEGORY.DEBUG).setLevel(LEVEL.DEBUG);
    }

    /**
     * Add Log with Event Category.
     */
    @api
    addInfo() {
        return this._newLogBuilder().setCategory(CATEGORY.EVENT).setLevel(LEVEL.INFO);
    }

    /**
     * Save Log with LWC / Aura Category.
     * This method will automatically get the stacktrace from Exception.
     * Type will be obtained from Exception. If blank, a default Frontend Type will be saved
     * Summary is the Exception message.
     * Details will be a combination of Exception String and stacktrace
     */
    @api
    exception(error, transactionId) {
        this._newLogBuilder()
            .setError(error)
            .setLevel(LEVEL.ERROR)
            .setTransactionId(transactionId);
        this.flush();
    }

    /**
     * Save Log with LWC / Aura Category.
     */
    @api
    error(type, area, summary, details, transactionId, component, duration, startTime) {
        this._newLogBuilder()
            .setLevel(LEVEL.ERROR)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details)
            .setTransactionId(transactionId)
            .setComponent(component)
            .setDuration(duration)
            .setCreatedTimestamp(startTime);
        this.flush();
    }

    /**
     * Save Log with Warning Category.
     */
    @api
    warning(type, area, summary, details, transactionId, component, duration, startTime) {
        this._newLogBuilder()
            .setLevel(LEVEL.WARNING)
            .setCategory(CATEGORY.WARNING)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details)
            .setTransactionId(transactionId)
            .setComponent(component)
            .setDuration(duration)
            .setCreatedTimestamp(startTime);
        this.flush();
    }

    /**
     * Save Log with Debug Category.
     */
    @api
    debug(type, area, summary, details, transactionId, component, duration, startTime) {
        this._newLogBuilder()
            .setLevel(LEVEL.DEBUG)
            .setCategory(CATEGORY.DEBUG)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details)
            .setTransactionId(transactionId)
            .setComponent(component)
            .setDuration(duration)
            .setCreatedTimestamp(startTime);
        this.flush();
    }

    /**
     * Save Log with Event Category.
     */
    @api
    info(type, area, summary, details, level, transactionId, component, duration, startTime) {
        this._newLogBuilder()
            .setLevel(level)
            .setCategory(CATEGORY.EVENT)
            .setType(type)
            .setArea(area)
            .setSummary(summary)
            .setDetails(details)
            .setTransactionId(transactionId)
            .setComponent(component)
            .setDuration(duration)
            .setCreatedTimestamp(startTime);
        this.flush();
    }

    /**
     * Commit all logs previously added using the addXXX() methods.
     */
    @api
    flush() {
        saveComponentLogs({
            componentLogs: this.logs
        }).then((data) => {
        }).catch(error => {
            console.error(error);
        });
        this.logs = [];
    }

    _newLogBuilder() {
        let logBuilder = newLogBuilder();
        this.logs.push(logBuilder);
        return logBuilder;
    }

}

/** LOG LEVEL */
export const LEVEL = {
    ERROR: 'ERROR',
    WARNING: 'WARNING',
    INFO: 'INFO',
    DEBUG: 'DEBUG',
    FINE: 'FINE',
    FINER: 'FINER',
    FINEST: 'FINEST'
};

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
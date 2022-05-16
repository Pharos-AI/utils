const LogBuilder = class {

    /**
     * Constructor used to generate each log
     */
    constructor() {
        this._setComponentDetails(new Error().stack);
    }

    /**
     * Sets the log Category field
     */
    setCategory(category) {
        this.category = category;
        return this;
    }

    /**
     * Sets the log Type field
     */
    setType(type) {
        this.type = type;
        return this;
    }

    /**
     * Sets the log Area field
     */
    setArea(area) {
        this.area = area;
        return this;
    }

    /**
     * Sets the log Summary field
     */
    setSummary(summary) {
        this.summary = summary;
        return this;
    }

    /**
     * Sets the log Details field
     */
    setDetails(details) {
        this.details = details;
        return this;
    }

    /**
     * Sets the log RecordId field
     */
    setRecordId(recordId) {
        this.recordId = recordId;
        return this;
    }

    /**
     * Sets the log ObjectApiName field
     */
    setObjectApiName(objectApiName) {
        this.objectApiName = objectApiName;
        return this;
    }

    /**
     * Sets the log Exception field
     */
    setError(error) {
        this.error = {};
        this.error.message = error.message;
        this.error.stack = error.stack;
        this.error.type = error.name;
        this._setComponentDetails(this.error.stack);
        return this;
    }

    _setComponentDetails(stack) {
        if (stack != null) {
            this.component = {}
            let stackTraceLines = [];
            stack.split('\n').filter(
                stackTraceLine => !stackTraceLine.includes('/c/logger.js') && !stackTraceLine.includes('/c/logBuilder.js')
            ).forEach(stackTraceLine => {
                if (!this.component.category && (stackTraceLine.includes('/modules/') || stackTraceLine.includes('/components/'))) {
                    this.component.category = stackTraceLine.includes('/modules/') ? 'LWC' : 'Aura';
                    this.component.name = stackTraceLine.substring(stackTraceLine.lastIndexOf('/') + 1, stackTraceLine.lastIndexOf('.js'));
                    this.component.function = stackTraceLine.substring(stackTraceLine.indexOf(this.component.type === 'LWC' ? '.' : 'at ') + (this.component.type === 'LWC' ? 1 : 3), stackTraceLine.lastIndexOf(' ('));
                }
                stackTraceLines.push(stackTraceLine);
            });
            this.stack = stackTraceLines.join('\n');
        }
    }

}

export function newLogBuilder() {
    return new LogBuilder();
}


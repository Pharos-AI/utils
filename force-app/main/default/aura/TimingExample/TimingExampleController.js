({
    doInit: function(component, event, helper) {
        helper.timingStart(component, 'render');
        helper.getContacts(component);
    },

    onRender: function(component, event, helper) {
        let timing = helper.timingEnd(component, 'render');
        const logger = component.find('logger');
        logger.addInfo()
            .setCategory('Event')
            .setArea('Render')
            .setType('Community')
            .setSummary('TimingExample Rendered: ' + timing)
            .setTotalTime(timing)
            .setUserId(component.get('v.userId'))
            .setComponent('TimingExample')
            .setAction('onRender');
        logger.flush();
    }
});
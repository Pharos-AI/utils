({

    getContacts: function (component) {
        this.timingStart(component, 'getContacts');
        let action = component.get("c.getContacts");
        action.setParams({sizeLimit: 5});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));

                let timing = this.timingEnd(component, 'getContacts');
                const logger = component.find('logger');
                logger.addInfo()
                    .setCategory('Event')
                    .setArea('getContacts')
                    .setType('Community')
                    .setSummary('TimingExample getContacts: ' + timing)
                    .setTotalTime(timing)
                    .setUserId(component.get('v.userId'))
                    .setComponent('TimingExample')
                    .setAction('getContacts');
                logger.flush();

            }
            else if (state === "INCOMPLETE") {
                alert("Continuation action is INCOMPLETE");
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    timingStart: function(component, timingName) {
        component.get('v.timings')[timingName + '_start'] = window.performance.now();
    },

    timingEnd: function(component, timingName) {
        if (!component.get('v.timings')[timingName + '_start'] && component.get('v.timings')[timingName + '_start'] !== 0) return null;
        let timing = window.performance.now() - component.get('v.timings')[timingName + '_start'];
        delete component.get('v.timings')[timingName + '_start'];
        return timing;
    }

});
({
    doInit : function(cmp, event, helper) {
        var consentOptions = [];
        var option = {};
        var device = $A.get("$Browser.formFactor");
		if(device == 'PHONE'){
    		cmp.set("v.activeSections", null);
		}
        option.label = $A.get("$Label.c.GPC_OptIn");
        option.value = "OptIn";
        consentOptions.push(option);
        option = {};
        option.label = $A.get("$Label.c.GPC_OptOut");
        option.value = "OptOut";
        consentOptions.push(option);
        cmp.set("v.consentOptions", consentOptions);

        helper.getConsents(cmp);   
    },

    /*handleManagementOption: function (cmp, event, helper) {
        var selectedButtonValue = event.getSource().get("v.value");
        cmp.set("v.selectedOption", selectedButtonValue);
    },

    handleDontMarket: function(cmp, event, helper) {
        helper.handleDontMarket(cmp);
    },*/

    handleConsentChange: function(cmp, event, helper) {
        var sourceName = event.getSource().get("v.name");
        var consentValue = event.getSource().get("v.value");
        console.log('##sourceName: '+sourceName);
        console.log('##consentValue: '+ consentValue);

        helper.handleConsentChange(cmp, sourceName.split('_')[0], sourceName.split('_')[1], sourceName.split('_')[2], consentValue);
        helper.handleOptAllTopics(cmp, sourceName.split('_')[0]);
    },

    handleOptAllChannelsIn: function(cmp, event, helper) {
        var sourceName = event.getSource().get("v.name");
        var consentValue = "OptIn";
        console.log('##sourceName: '+sourceName);

        helper.handleConsentChange(cmp, sourceName, null, null, consentValue);
        helper.handleOptAllTopics(cmp, sourceName);
    },

    handleOptAllChannelsOut: function(cmp, event, helper) {
        var sourceName = event.getSource().get("v.name");
        var consentValue = "OptOut";
        console.log('##sourceName: '+sourceName);

        helper.handleConsentChange(cmp, sourceName, null, null, consentValue);
        helper.handleOptAllTopics(cmp, sourceName);
    },
    
    handleOptAllIn: function(cmp, event, helper) {
        var sourceName = event.getSource().get("v.name");
        var consentValue = "OptIn";
        console.log('##sourceName: '+sourceName);

        helper.handleConsentChange(cmp, sourceName.split('_')[0], sourceName.split('_')[1], null, consentValue);
        helper.handleOptAllTopics(cmp, sourceName.split('_')[0]);
    },

    handleOptAllOut: function(cmp, event, helper) {
        var sourceName = event.getSource().get("v.name");
        var consentValue = "OptOut";
        console.log('##sourceName: '+sourceName);

        helper.handleConsentChange(cmp, sourceName.split('_')[0], sourceName.split('_')[1], null, consentValue);
        helper.handleOptAllTopics(cmp, sourceName.split('_')[0]);
    }
})
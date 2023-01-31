({
    getConsents: function(cmp) {
        cmp.set("v.loading", true);
        var recordId = cmp.get("v.recordId");

        var action = cmp.get("c.getConsents");
        action.setParams({
            "recordId": recordId
        });

        this.configureMessage(cmp, null, null, false);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var config = response.getReturnValue();
                console.log('##config: '+JSON.stringify(config));
                /*cmp.set("v.dontMarket", config.dontMarket);
                cmp.set("v.originalDontMarket", config.dontMarket);*/
                cmp.set("v.userName", config.userName);
                cmp.set("v.editAccess", config.editAccess);
                cmp.set("v.legalBasisList", config.legalBasisList);
                //cmp.set("v.consentOptions", config.consentOptions);
                if (!config.isIndividual) this.configureMessage(cmp, 'This Page is visible only for Individual Customers.', 'warning', true); 
                if (config.leadConverted != null && config.leadConverted) this.configureMessage(cmp, 'Lead has been converted, please check the related Account.', 'warning', true);
            } else{
                var msg = this.getErrorMessage(response.getError());
                this.configureMessage(cmp, msg, 'error', true); 
            }

            cmp.set("v.loading", false);
        }); 
        $A.enqueueAction(action);           
    },

    /*handleDontMarket: function(cmp) {
        var recordId = cmp.get("v.recordId");
        var dontMarket = cmp.get("v.dontMarket");
        
        cmp.set("v.loading", true);

        var action = cmp.get("c.updateSolicit");
        action.setParams({
            "recordId": recordId,
            "dontMarket": dontMarket
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            } else{
                var msg = this.getErrorMessage(response.getError());
                this.configureMessage(cmp, msg, 'error', true); 
            }

            cmp.set("v.loading", false);
        }); 
        $A.enqueueAction(action);  
    },*/

    handleConsentChange: function(cmp, legalBasisId, channel, purposeId, consent) {
        var recordId = cmp.get("v.recordId");
        
        cmp.set("v.loading", true);

        this.configureMessage(cmp, null, null, false);

        var captureDate = "Just Now";
        var username = cmp.get("v.userName");
        var legalBasisList = cmp.get("v.legalBasisList");
        legalBasisList.forEach(legalBasis => {
            if (legalBasis.id == legalBasisId) {
                legalBasis.channelList.forEach(channelItem => {
                    if (channel == null) {
                        channelItem.optInTotal = 0;
                        channelItem.optOutTotal = 0;
                        if (consent == 'OptIn') channelItem.optInTotal = channelItem.pursposeList.length;
                        if (consent == 'OptOut') channelItem.optOutTotal = channelItem.pursposeList.length;
                        channelItem.pursposeList.forEach(purpose => {
                            purpose.consent = purpose.previousConsent = consent;
                            purpose.captureDate = captureDate;
                            purpose.captureBy = username;
                        });
                    } else if (channelItem.name == channel) {
                        if (purposeId == null) {
                            channelItem.optInTotal = 0;
                            channelItem.optOutTotal = 0;
                            if (consent == 'OptIn') channelItem.optInTotal = channelItem.pursposeList.length;
                            if (consent == 'OptOut') channelItem.optOutTotal = channelItem.pursposeList.length;
                            channelItem.pursposeList.forEach(purpose => {
                                purpose.consent = purpose.previousConsent = consent;
                                purpose.captureDate = captureDate;
                                purpose.captureBy = username;
                            });
                        } else {
                            channelItem.pursposeList.forEach(purpose => {
                                if (purposeId == purpose.id) {
                                    if (purpose.previousConsent == 'OptIn') channelItem.optInTotal--;
                                    if (purpose.previousConsent == 'OptOut') channelItem.optOutTotal--;

                                    purpose.consent = purpose.previousConsent = consent;
                                    purpose.captureDate = captureDate;
                                    purpose.captureBy = username;

                                    if (purpose.consent == 'OptIn') channelItem.optInTotal++;
                                    if (purpose.consent == 'OptOut') channelItem.optOutTotal++;
                                    
                                    return;
                                }
                            });
                        }

                        return;
                    }
                });

                return;
            }
        });

        var action = cmp.get("c.updateConsents");
        action.setParams({
            "recordId": recordId,
            "legalBasisId": legalBasisId,
            "purposeId": purposeId,
            "channel": channel,
            "consent": consent
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
            } else{
                var msg = this.getErrorMessage(response.getError());
                this.configureMessage(cmp, msg, 'error', true); 
            }

            cmp.set("v.loading", false);
        }); 
        $A.enqueueAction(action);  

        cmp.set("v.legalBasisList", legalBasisList);
    },

    handleOptAllTopics : function(cmp, legalBasisId) {
        var legalBasisList = cmp.get("v.legalBasisList");
        legalBasisList.forEach(legalBasis => {
            if (legalBasis.id == legalBasisId) {
                legalBasis.optInTotal = 0;
                legalBasis.optOutTotal = 0;
                legalBasis.channelList.forEach(channel => {
                    legalBasis.optInTotal += channel.optInTotal;
                    legalBasis.optOutTotal += channel.optOutTotal;
                });

                return;
            }
        });

        cmp.set("v.legalBasisList", legalBasisList);
    },

    getErrorMessage : function(errors) {
        var msg = 'Unknown error. Please contact your admin!';
        if (errors != null && errors[0] != null && errors[0].message != null) msg = errors[0].message;
        else if (errors != null && errors[0] != null && errors[0].pageErrors != null && errors[0].pageErrors[0] != null && errors[0].pageErrors[0].message != null) msg = errors[0].pageErrors[0].message;
        else if (errors != null && errors[0] != null && errors[0].fieldErrors != null && errors[0].fieldErrors[Object.keys(errors[0].fieldErrors)[0]] != null && errors[0].fieldErrors[Object.keys(errors[0].fieldErrors)[0]][0].message != null) msg = errors[0].fieldErrors[Object.keys(errors[0].fieldErrors)[0]][0].message;
        
        return msg;

    },

    configureMessage : function(cmp, msg, sev, isMessageSet) {
        cmp.set('v.message', msg);
        cmp.set('v.messageSeverity', sev);
        cmp.set('v.isMessageSet', isMessageSet);

    },
})
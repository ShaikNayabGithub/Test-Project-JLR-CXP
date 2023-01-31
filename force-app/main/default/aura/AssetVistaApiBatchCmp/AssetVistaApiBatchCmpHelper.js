({
    getUserDetails  : function (cmp, event, helper) {
        var action = cmp.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respVal = response.getReturnValue();
                console.log('--> '+respVal);
                var parsedResp = JSON.parse(respVal);
                if(parsedResp){
                    if(parsedResp.showPanel){
                        cmp.set('v.showPanel',parsedResp.showPanel);
                    }
                    if(parsedResp.batchJobId){
                        cmp.set('v.batchJobId',parsedResp.batchJobId);
                        cmp.set('v.showButton',false);
                        var interval = setInterval($A.getCallback(function () {
                            var jobStatus = cmp.get("c.getBatchJobStatus");
                            jobStatus.setParams({ jobID : parsedResp.batchJobId});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    console.log('job --> '+JSON.stringify(job));
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = cmp.get('v.progress');
                                    cmp.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                    if(progress === 100){
                                        cmp.set('v.showButton',true);
                                        cmp.set('v.progress',100);
                                    }
                                }else if (state === "ERROR") {
                                    var errors = response.getError();
                                    cmp.set('v.showButton',true);
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
                            $A.enqueueAction(jobStatus);
                        }), 2000);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    executeBatchHelper  : function (cmp, event, helper) {
        var action = cmp.get("c.ProcessAssetVistaBatch");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respVal = response.getReturnValue();
                console.log('--> '+respVal);
                var parsedResp = JSON.parse(respVal);
                if(parsedResp && parsedResp.message){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": parsedResp.message
                    });
                    toastEvent.fire(); 
                    console.log('--> batchJobId'+parsedResp.batchJobId);
                    console.log('--> '+parsedResp.hasError);
                    if(parsedResp 
                       && parsedResp.batchJobId 
                       && !parsedResp.hasError
                      ){
                        console.log('1 --> ');
                        cmp.set('v.showButton',false);
                        cmp.set('v.batchJobId',parsedResp.batchJobId);
                        var interval = setInterval($A.getCallback(function () {
                            var jobStatus = cmp.get("c.getBatchJobStatus");
                            jobStatus.setParams({ jobID : parsedResp.batchJobId});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    console.log('job --> '+JSON.stringify(job));
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = cmp.get('v.progress');
                                    cmp.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                    if(progress === 100){
                                        cmp.set('v.showButton',true);
                                        cmp.set('v.progress',100);
                                    }
                                }else if (state === "ERROR") {
                                    var errors = response.getError();
                                    cmp.set('v.showButton',true);
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
                            $A.enqueueAction(jobStatus);
                        }), 2000);
                    }
                }
            }else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },    
    abortBatchHelper  : function (cmp, event, helper) {
        var action = cmp.get("c.abortBatchHandler");
        var batchJobId = cmp.get("v.batchJobId");
        action.setParams({ 
            "batchJobId" : batchJobId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respVal = response.getReturnValue();
                console.log('--> '+respVal);
                var parsedResp = JSON.parse(respVal);
                if(parsedResp && parsedResp.message){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": parsedResp.message
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})
({
    doInit : function (cmp, event, helper) {
        helper.getUserDetails(cmp, event, helper);
    },
    executeBatch : function (cmp, event, helper) {
        helper.executeBatchHelper(cmp, event, helper);
    },
    abortBatch : function (cmp, event, helper) {
        helper.abortBatchHelper(cmp, event, helper);
    }
})
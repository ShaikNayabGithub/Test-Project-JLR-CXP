public class AssetVistaBatchController {
    
    static set<String> jobStatusSet = new  set<String>{'Failed','Completed','Aborted'};
        
        @AuraEnabled
        public static String getUserDetails(){
            batchWrapper wrapIns = new batchWrapper();
            wrapIns.showPanel = checkUser('Vista_API_Asset_Align_Records_Permission_Set');
            List<AsyncApexJob> AsyncApexJobList =  [SELECT 
                                                    Id,JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset, CronTriggerId
                                                    FROM 
                                                    AsyncApexJob
                                                    where 
                                                    ApexClass.name = 'AssetVehicleOrderBatch'               
                                                    AND
                                                    Status NOT IN: jobStatusSet
                                                    limit 1];
            if(AsyncApexJobList != null 
               && !AsyncApexJobList.isEmpty()){
                   wrapIns.batchJobId = AsyncApexJobList.get(0).Id;
               }
            
            return json.serialize(wrapIns);
        }    
    
    @AuraEnabled
    public static String ProcessAssetVistaBatch(){
        batchWrapper wrapIns = new batchWrapper();
        try{
            Id batchJobId = database.executeBatch(new AssetVehicleOrderBatch(),1);
            wrapIns.batchJobId = batchJobId;
            wrapIns.hasError = false;
            wrapIns.message = 'Batch has been Executed Successfully!';
            
        }catch(Exception ex){
            wrapIns.hasError = true;
            wrapIns.message = ex.getMessage();
        }
        return json.serialize(wrapIns);
    }
    
    public static  Boolean checkUser(String permissionSetName) {
        Boolean hasPermission = false;
        List<PermissionSetAssignment> psas = [select Id from PermissionSetAssignment 
                                              where 
                                              PermissionSet.name = :permissionSetName
                                              and 
                                              AssigneeId = :userinfo.getUserId()];
        if(psas != null
           && !psas.isEmpty()){
               hasPermission = true;
           }
        return hasPermission;
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems 
                                FROM 
                                AsyncApexJob 
                                WHERE 
                                Id = :jobID];
        return jobInfo;
    }
    
    @AuraEnabled
    public static String abortBatchHandler(Id batchJobId){
        batchWrapper wrapIns = new batchWrapper();
        try{
            System.AbortJob(batchJobId);
            wrapIns.hasError = false;
            wrapIns.message = 'Batch has been Aborted';
        }catch(Exception ex){
            wrapIns.hasError = true;
            wrapIns.message = ex.getMessage();
        }
        return json.serialize(wrapIns);
    }
    
    
    public class batchWrapper{
        public batchWrapper(){
            this.hasError = false;
            this.showPanel = false;
        }
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public Boolean showPanel;
        @AuraEnabled public String message;
        @AuraEnabled public Id batchJobId;
    }
}
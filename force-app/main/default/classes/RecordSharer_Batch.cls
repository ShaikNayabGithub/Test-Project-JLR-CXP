global class RecordSharer_Batch implements Database.Batchable<SObject>, Schedulable, Database.Stateful  {
    
    global List<Result> resultsSuccess = new List<Result>();    
    global List<Result> resultsError = new List<Result>();
    global Long StartTime = System.now().getTime();
    global static Boolean SimulateError = false;
    
    global RecordSharer_Batch() {  
    }
    
    //Gets the batch job to run where status matches BATCH values
    global void execute(System.SchedulableContext sc){
        List<AsyncApexJob> existingJobs = [SELECT Id FROM AsyncApexJob 
                                           where jobtype = 'batchapex' and
                                           apexclass.name = 'RecordSharer_Batch'
                                           and status in ('Holding','Queued','Preparing','Processing') limit 1];
        
        //don't create a new batch if one is already running
        if(existingJobs.size() == 1) return;
        
        RecordSharer_Batch batch = new RecordSharer_Batch();
        Database.executeBatch(batch,1);
    }
    
    /**
* @description gets invoked when the batch job starts
* @param context contains the job ID
* @returns the record set as a QueryLocator object that will be batched for execution
*/ 
    global Database.QueryLocator start(Database.BatchableContext context) {
        
        List<Record_Share__c> settings = [SELECT Id, Status__c, user__r.isActive, delete__c FROM Record_Share__c WHERE status__c = 'pending' or Status__c = 'processing'];
        RecordSharer_Handler.AllowEdit = true;
        for(Record_Share__c setting : settings){
            if(setting.User__r.IsActive == true || setting.Delete__c){          
                setting.status__c = 'Processing';
            }else{
                setting.status__c = 'Inactive User';
            }
            setting.error__c = null;            
        }
        update settings;
        Set<String> ids = SObjectUtilities.GetFieldValues(settings,'id');
        
        return Database.getQueryLocator('SELECT Id, Name, Status__c,Account__c,Account_Case__c,delete__c,Account_Opportunity__c,CreatedBy.Name,  Retailer__c,Retailer__r.Name, User__c,User__r.name, Lead__c, Campaign__c, Account_Previous_Value__c, Case_Previous_Value__c, Opportunity_Previous_Value__c, Lead_Previous_Value__c, Campaign_Previous_Value__c FROM Record_Share__c WHERE id in :ids and User__r.IsActive = true');
    }
    
    /**
* @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
* @param context contains the job ID
* @param scope contains the batch of records to process.
*/ 
    global void execute(Database.BatchableContext context, List<Record_Share__c> scope) {
        RecordSharer_Handler.AllowEdit = true;
        RecordSharer_Handler.AllowDelete = true;
        
        if(scope.size() > 1){
            //throw error, only ever want to process these in batches of 1
        }
        Record_Share__c recordShareDetails = scope[0];
        RecordShareProcesser process = new RecordShareProcesser(scope[0]);
        try{                
            Boolean accountOL = process.ProcessShare(scope[0].Account__c, 'Account', Schema.AccountShare.AccountId.getDescribe());
            Boolean caseOL = process.ProcessShare(scope[0].Account_Case__c, 'Case', Schema.CaseShare.CaseId.getDescribe());
            Boolean opportunityOL = process.ProcessShare(scope[0].Account_Opportunity__c, 'Opportunity', Schema.OpportunityShare.OpportunityId.getDescribe());
            Boolean leadOL = process.ProcessShare(scope[0].Lead__c, 'Lead', Schema.LeadShare.LeadId.getDescribe());
            Boolean campaignOL = process.ProcessShare(scope[0].Campaign__c, 'Campaign', Schema.CampaignShare.CampaignId.getDescribe());

            if(accountOL || caseOL || opportunityOL || leadOL || campaignOL){
                Record_Share__c copiedShare = RecordShareExtension.createNewShareRecord(recordShareDetails);
                insert copiedShare;
            }

            process.result.Success = true;

            if(process.result.DmlLimit){
                scope[0].status__C = 'pending';
                update scope;
            }else{
                if(scope[0].Delete__c){
                    Record_Share__c toDelete = scope[0];
                    delete toDelete;
                }else{
                    scope[0].status__C = 'Completed';
                    update scope;
                }               
            }           
            
            process.result.EndTime = Datetime.now();
            resultsSuccess.add(process.result);
            
            if(SimulateError) Integer i = 1/0;            
        }catch(Exception ex){
            process.result.Success = false;
            scope[0].Status__c = 'Error';
            scope[0].error__c = ex.getMessage();
            scope[0].error__c += '\n\n' + ex.getStackTraceString();
            process.result.Error = scope[0].Error__c;           
            Database.update(scope,false);
            
            process.result.EndTime = Datetime.now();
            resultsError.add(process.result);
        }
    }   
    /**
* @description gets invoked when the batch job finishes. Place any clean up code in this method.
* @param context contains the job ID
*/ 
    global void finish(Database.BatchableContext context) {
        try{
            //notifyFailures();
        }Catch(Exception e){
            throw e;
        }
        for(Result r : resultsSuccess){
            if(r.DmlLimit){
                //We have more shares to process, so run job again
                RecordSharer_Batch batch = new RecordSharer_Batch();
                Database.executeBatch(batch,1);
                return;
            }
        }
    }
    
    public void notifyFailures() {
        
        Set<String> recipients = new Set<String>();     
        System_Settings__mdt errorRecipients = [Select Value__c from System_Settings__mdt 
                                                Where DeveloperName = 'Record_Share_Email_Failure_Alert'];
        
        System_Settings__mdt successRecipients = [Select Value__c from System_Settings__mdt 
                                                  Where DeveloperName = 'Record_Share_Email_Success_Alert'];
        
        if(!resultsError.isEmpty() && String.isNotBlank(errorRecipients.Value__c)){
            recipients.addAll((errorRecipients.Value__c).split(','));
        }
        
        if(String.isNotBlank(successRecipients.Value__c)){
            recipients.addAll((successRecipients.Value__c).split(','));
        }
        
        if(recipients.size() == 0) return;
        if(resultsSuccess.isEmpty() && resultsError.isEmpty()) return; 
        
        String msg;
        try{            
            msg = '<!DOCTYPE html><html>';
            msg += '<b>Job run by :</b> ' + UserInfo.getName();
            
            Long milliseconds = Datetime.now().getTime() - StartTime;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            String timeTaken = hours + ':' + (minutes - (hours * 60)) + ':' + (seconds - (hours * 60 * 60) - (minutes *60)) ;
            
            msg += '<b>Time taken :</b>' + timeTaken;
            msg += '<h2>Success</h2>';
            
            if(resultsSuccess.size() > 0){
                msg += '<table id=\'notif\'><tr><td><b>Id</b></td><td><b>Time</b></td><td><b>Retailer</b></td><td><b>User</b></td><td><b>Created By</b></td>';
                if(resultsSuccess[0].Items != null){
                    for(String fieldName : resultsSuccess[0].Items.keySet()){
                        msg += '<td><b>'+fieldName+'</b></td>';
                    }
                }
                msg += '<td><b>DML Limit Hit</b></td><td><b>Deleted</b></td></tr>';
                
                for(Result result : resultsSuccess){
                    milliseconds = result.EndTime.getTime() - result.StartTime.getTime();
                    seconds = milliseconds / 1000;
                    minutes = seconds / 60;
                    hours = minutes / 60;
                    timeTaken = hours + ':' + minutes + ':' + seconds;
                    
                    msg += '<tr>';
                    msg += '<td>'+result.share.id+'</td>';
                    msg += '<td>'+timeTaken+'</td>';
                    msg += '<td>'+result.share.Retailer__r.name+'</td>';
                    msg += '<td>'+result.share.User__r.Name +'</td>';
                    msg += '<td>'+result.share.CreatedBy.Name+'</td>';
                    
                    if(result.Items != null){
                        for(ResultItem item : result.Items.values()){               
                            msg += '<td>'+ item.Shared + ' added, ' + item.Removed +' removed</td>';                
                        }
                    }
                    msg += '<td>'+ result.DmlLimit +'</td><td>' + String.valueOf(result.share.Delete__c) + '</td>';
                    msg += '</tr>';
                }
                msg += '</table>';
            }
            msg += '<h2>Error</h2><table id=\'notif\'><tr><td><b>Id</b></td><td><b>Retailer</b></td><td><b>User</b></td><td><b>Created By</b></td></tr>';
            
            for(Result result : resultsError){
                msg += '<tr>';
                msg += '<td>'+result.share.id+'</td>';
                msg += '<td>'+result.share.Retailer__r.name+'</td>';
                msg += '<td>'+result.share.User__r.Name +'</td>';
                msg += '<td>'+result.share.CreatedBy.Name+'</td>';
                msg += '</tr>';
                msg += '<tr><td colspan="5">'+result.share.error__c+'</td></tr>';
                
            }
            msg += '</table></body></html>';
        }
        catch (Exception ex){
            msg = ex.getLineNumber() + '\n' + ex.getMessage() + '\n' + ex.getStackTraceString();
        }
        List<String> recipientList = new List<String>();
        recipientList.addAll(recipients);
        if (recipients.size() > 0) EmailUtility.SendEmail(recipientList, 'RecordSharer_Batch', 'Record Sharing Notification', msg, null, 'noreply@jaguarexperience.com', false, null, true);
    }
    
    public class RecordShareProcesser{
        private Record_Share__c shareSetting;
        public Result result;
        public Boolean overLimit= false;
        Map<String,Boolean> returnMap = new Map<String,Boolean>();
        
        public RecordShareProcesser(Record_Share__c shareSetting){
            this.shareSetting = shareSetting;
            this.result = new Result();
            this.result.Share = shareSetting;
            this.result.StartTime = Datetime.now();
        }
        
        private Boolean shareNeedsCreating(String objectName){
            
            String settingAccess;
            String existingShareField;
            
            if(objectName == 'Account'){
                settingAccess = shareSetting.Account__c; 
                existingShareField = shareSetting.Account_Previous_Value__c;
            }
            if(objectName == 'Case'){ 
                settingAccess = shareSetting.Account_Case__c; 
                existingShareField = shareSetting.Case_Previous_Value__c;
            }
            if(objectName == 'Opportunity'){ 
                settingAccess = shareSetting.Account_Opportunity__c; 
                existingShareField = shareSetting.Opportunity_Previous_Value__c;
            }
            if(objectName == 'Campaign'){ 
                settingAccess = shareSetting.Campaign__c; 
                existingShareField = shareSetting.Campaign_Previous_Value__c;
            }
            if(objectName == 'Lead'){ 
                settingAccess = shareSetting.Lead__c; 
                existingShareField = shareSetting.Lead_Previous_Value__c;
            }
            
            if(isShareSettingHigherThanExistingShare(settingAccess,existingShareField) ){
                return true; 
            }           
            
            return false;
        }   
        
        private Boolean isShareSettingHigherThanExistingShare(String settingLevel, String existingShareLevel){
            if(settingLevel == null || settingLevel == 'None') return false;
            if(existingShareLevel == 'Edit') return false;
            if(settingLevel == 'Edit' && existingShareLevel != 'Edit') return true;
            if(settingLevel == 'Read' && existingShareLevel  == 'Read') return false;
            return true;
        } 
        
        private List<User> retailerUsers;
        private List<User> GetRetailerUsers(){
            if(retailerUsers == null){
                retailerUsers = [Select Id from User WHERE Contact.AccountId =: shareSetting.Retailer__c and id !=:shareSetting.User__c];
            }
            return retailerUsers;
        }
        
        private List<SObject> GetExistingRecords(String objectName){
            if(objectName == 'Account') return [SELECT Id from Account WHERE OwnerId in : GetRetailerUsers()];
            if(objectName == 'Case') return [SELECT Id from Case WHERE OwnerId in : GetRetailerUsers()];
            if(objectName == 'Lead') return [SELECT Id from Lead WHERE OwnerId in : GetRetailerUsers()];
            if(objectName == 'Opportunity') return [SELECT Id from Opportunity WHERE OwnerId in : GetRetailerUsers()];
            if(objectName == 'Campaign') return [SELECT Id from Campaign WHERE OwnerId in : GetRetailerUsers()];
            
            return null;
        }       
        private List<SObject> GetExistingShares(String objectName){
            
            if(objectName == 'Account'){
                Integer accountLimit = RecordShareExtension.CountSOQLLimit(objectName, shareSetting);
                if(accountLimit > 9500){
                    overLimit = true;
                }
                return [SELECT Id,AccountId, AccountAccessLevel from AccountShare WHERE UserOrGroupId =: shareSetting.User__c 
                         AND Account.OwnerId in : GetRetailerUsers() LIMIT 9500]; 
            } 
            if(objectName == 'Case'){
                Integer caseLimit = RecordShareExtension.CountSOQLLimit(objectName, shareSetting);
                if(caseLimit > 9500){
                    overLimit = true;
                }
                return [SELECT Id,CaseId, CaseAccessLevel from CaseShare WHERE UserOrGroupId =: shareSetting.User__c 
                          AND Case.OwnerId in : GetRetailerUsers() LIMIT 9500];
            } 
            if(objectName == 'Lead'){
                Integer leadLimit = RecordShareExtension.CountSOQLLimit(objectName, shareSetting);
                if(leadLimit > 9500){
                    overLimit = true;
                }
                return [SELECT Id,LeadId, LeadAccessLevel from LeadShare WHERE UserOrGroupId =: shareSetting.User__c 
                          AND Lead.OwnerId in : GetRetailerUsers() LIMIT 9500];
            } 
            if(objectName == 'Opportunity'){
                Integer opportunityLimit = RecordShareExtension.CountSOQLLimit(objectName, shareSetting);
                if(opportunityLimit > 9500){
                    overLimit = true;
                }
                return [SELECT Id,OpportunityId, OpportunityAccessLevel from OpportunityShare WHERE UserOrGroupId =: shareSetting.User__c 
                          AND Opportunity.OwnerId in : GetRetailerUsers() LIMIT 9500];
            } 
            if(objectName == 'Campaign'){
                Integer campaignLimit = RecordShareExtension.CountSOQLLimit(objectName, shareSetting);
                if(campaignLimit > 9500){
                    overLimit = true;
                }
                return [SELECT Id,CampaignId, CampaignAccessLevel from CampaignShare WHERE UserOrGroupId =: shareSetting.User__c
                          AND Campaign.OwnerId in : GetRetailerUsers() LIMIT 9500]; 
            } 
            return null;
        }
        
        private Sobject GetNewShareRecord(String objectName,Id recordId){
            
            SObject share;
            
            if(objectName == 'Account'){
                share = new AccountShare();
                share.put('AccountAccessLevel', shareSetting.Account__c);
                share.put('OpportunityAccessLevel', 'None');
                share.put('CaseAccessLevel', 'None');
            }
            if(objectName == 'Case'){
                share = new CaseShare();
                share.put('CaseAccessLevel', shareSetting.Account_Case__c);
            }
            if(objectName == 'Lead'){
                share =  new LeadShare();
                share.put('LeadAccessLevel', shareSetting.Lead__c);
            }
            if(objectName == 'Opportunity'){
                share = new OpportunityShare();
                share.put('OpportunityAccessLevel', shareSetting.Account_Opportunity__c);
            }
            if(objectName == 'Campaign'){
                share =  new CampaignShare();
                share.put('CampaignAccessLevel',shareSetting.Campaign__c);
            }
            
            if (share == null) return null;
            
            share.put(objectName + 'id', recordId);
            share.put('RowCause','Manual');
            share.put('UserOrGroupId',shareSetting.user__c);
            return share;
        }
        
        public boolean ProcessShare(String shareSettingField, String objectName, Schema.DescribeFieldResult fieldDescribe){
            result.UpdateResults(objectName,0, 0);
            if(result.DmlLimit) return false;
            
            if(String.isBlank(shareSettingField) && !shareSetting.Delete__c) return false;   
            
            //Get list of users in the retailer
            List<User> users = GetRetailerUsers(); 
            if(users.size() == 0) return false;
            
            List<SObject> existingShares;
            Map<Id, List<SObject>> sharesByRecord;
            List<SObject> sharesToAdd = new List<SObject>();                
            List<SObject> sharesToDelete = new List<SObject>();
            
            //needs to be used for both Create/Delete
            List<SObject> retailerRecords = GetExistingRecords(objectName);
            
            //only fire GetExistingShare method on delete, SF OOTB automatically creates/ignores new share if it exists
            if(shareSetting.Delete__c){
                existingShares = GetExistingShares(objectName);
                sharesByRecord = SObjectUtilities.MapByIdField(existingShares,fieldDescribe);
            }
            
            Set<Id> sharesToKeep = new Set<Id>(); 
            if(shareSetting.delete__c){
                sharesToKeep = keepShareOverride();
            }
            
            Integer dmlRows = Limits.getDmlRows();
            
            for(SObject record : retailerRecords){
                if(dmlRows + sharesToDelete.size() + sharesToAdd.size() > 9990) {
                    result.DmlLimit = true;
                    break;
                }
                
                if(shareSetting.delete__c){
                    List<SObject> existingShareByRecordId = sharesByRecord.get(record.id);
                    if(existingShareByRecordId != null){
                        for(SObject existingShare : existingShareByRecordId){
                            if(!sharesToKeep.contains(existingShare.id)){
                                sharesToDelete.add(existingShare);
                            }
                        }                       
                    }
                }else{
                    if(shareNeedsCreating(objectName)){
                        SObject share = GetNewShareRecord(objectName, record.id);                        
                        sharesToAdd.add(share);
                    }
                }   
            }
            
            delete sharesToDelete;
            insert sharesToAdd;
            
            result.UpdateResults(objectName,sharesToAdd.size(), sharesToDelete.size());
            return overlimit;
        }
        
        private Set<Id> keepShareOverride(){
            return new Set<Id>();
        }   
    }
    
    private class Result{
        Record_Share__c Share {get;set;}
        Boolean Success {get;Set;}
        String Error{get;set;}
        Datetime StartTime {get;set;}
        Datetime EndTime {get;set;}
        Boolean DmlLimit {get;set;}
        
        Map<String, ResultItem> Items {get;set;}
        
        public void UpdateResults(String objectName, Integer shared, Integer removed){
            if(!Items.containsKey(objectName)){
                Items.put(objectName,new ResultItem());
            }
            ResultItem item = Items.get(objectName);
            item.Shared = shared;
            item.Removed = removed;             
        }
        
        public Result(){
            DmlLimit = false;
            Items = new Map<String,ResultItem>();
        } 
    }
    
    private class ResultItem{
        Integer Shared {get;Set;}
        Integer Removed {get;Set;}
    }
}
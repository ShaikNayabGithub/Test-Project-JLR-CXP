global class CampaignMonthlyBatchDelete implements Database.Batchable<sObject>, Schedulable{
  
  global void execute(SchedulableContext SC){
    Database.executeBatch(this);
  }

  global Database.QueryLocator start(Database.BatchableContext info){
      return Database.getQueryLocator([SELECT Id From Campaign WHERE Status = 'Rejected' AND CreatedDate <= LAST_MONTH]);
  }
    
  global void execute(Database.BatchableContext info, List<sObject> recordsForDeletion){
    Database.delete(recordsForDeletion);
  }

  global void finish(Database.BatchableContext info){}
  
}
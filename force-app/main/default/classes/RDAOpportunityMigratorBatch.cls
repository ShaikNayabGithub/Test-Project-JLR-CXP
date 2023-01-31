/*
*  @Name : RDAOpportunityMigratorBatch 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-644
*  @Description : Update the Opportunities from old process to new process

*/

global class RDAOpportunityMigratorBatch implements Database.Batchable<sObject>{
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public String retailerAccountId ;
    public  Map<String,String> opportunityStageMap= new Map<String,String>();
    global RDAOpportunityMigratorBatch(String accountId){
        retailerAccountId = accountId;  
        opportunityStageMap = getOpportunityStageMap();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        List<String> opportunityRecordtypeList = Label.Opportunity_recordtype_List.split(',');
        Set<String> opportunityStageList= opportunityStageMap.keySet();
        system.debug('opportunityRecordtypeList'+ opportunityRecordtypeList);
        system.debug('opportunityStageList'+ opportunityStageList);
        return Database.getQueryLocator('SELECT Id, StageName, Is_New_RDA_Process__c FROM Opportunity WHERE Owner.AccountId = :retailerAccountId' +
                                        ' AND Recordtype.Developername In :opportunityRecordtypeList AND StageName IN :opportunityStageList' );
    }  
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){      
        Id OppRDARcdTypId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Process_with_RDA').getRecordTypeId();
        for(Opportunity opp: (List<Opportunity>) scope){
            opp.StageName = opportunityStageMap.get(opp.StageName);
            opp.Is_New_RDA_Process__c = true;
            opp.RecordtypeId =OppRDARcdTypId;
            system.debug(opp);
        }
        update scope;   
    }
    
    global void finish(Database.BatchableContext BC)
    {       
        system.debug('**** Finish');
    }
    
    global Static Map<String, String> getOpportunityStageMap(){
        Map<String, String> opportunityStageMap = new Map<String, String>();
        for(RDA_Process_Data_Migrate_Setting__mdt mdtSetting : [SELECT Id,New_Stage_Name__c,Object_Name__c,Old_Stage_Name__c FROM RDA_Process_Data_Migrate_Setting__mdt 
                                                                WHERE Object_Name__c ='Opportunity']){                                                                    
                                                                    opportunityStageMap.put(mdtSetting.Old_Stage_Name__c, mdtSetting.New_Stage_Name__c);
                                                                }
        return opportunityStageMap;
    }
}
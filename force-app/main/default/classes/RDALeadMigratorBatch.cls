/*
*  @Name : RDALeadMigratorBatch 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-644
*  @Description : Update the Leads from old process to new process

*/

global class RDALeadMigratorBatch implements Database.Batchable<sObject>{
    public String retailerAccountId ;
    public  Map<String,String> LeadStageMap= new Map<String,String>();
    global RDALeadMigratorBatch(String accountId){
        retailerAccountId = accountId;  
        LeadStageMap = getLeadStageMap();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        List<String> LeadRecordtypeList = Label.Lead_RecordType_List.split(',');
        Set<String> LeadStageList= LeadStageMap.keySet();
        List<User> retailerUserList =[SELECT ID FROM User WHERE AccountId =:retailerAccountId AND IsActive = true];
        system.debug('LeadRecordtypeList'+ LeadRecordtypeList);
        system.debug('LeadStageList'+ LeadStageList);
        return Database.getQueryLocator('SELECT Id, Status,RecordtypeId,Enquiry_Type__c,Recordtype.Developername,Recordtype.Name  FROM Lead WHERE OwnerId IN :retailerUserList' +
                                        ' AND Recordtype.Developername In :LeadRecordtypeList AND Status IN :LeadStageList' );
    }  
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){  
        Id individualRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();
        
        for(Lead lead: (List<Lead>) scope){
            lead.Status = LeadStageMap.get(lead.Status);
            lead.Enquiry_Type__c = lead.Recordtype.Name;
            lead.RecordtypeId = individualRecordType;            
            system.debug(lead);
        }
        update scope;   
    }
    
    global void finish(Database.BatchableContext BC)
    {       
        system.debug('**** Finish');
    }
    
    global Static Map<String, String> getLeadStageMap(){
        Map<String, String> LeadStageMap = new Map<String, String>();
        for(RDA_Process_Data_Migrate_Setting__mdt mdtSetting : [SELECT Id,New_Stage_Name__c,Object_Name__c,Old_Stage_Name__c FROM RDA_Process_Data_Migrate_Setting__mdt 
                                                                WHERE Object_Name__c ='Lead']){                                                                    
                                                                    LeadStageMap.put(mdtSetting.Old_Stage_Name__c, mdtSetting.New_Stage_Name__c);
                                                                }
        return LeadStageMap;
    }
}
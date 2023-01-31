/*
*  @Name : RDAOpportunityMigrator 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-754
*  @Description : Update the new stage if Opportunity gets updated with old stage through DMS

*/
public class OpportunityNewStageUpdateForDMS {
    public static Map<String,String> opportunityNewStageMap = new Map<String,String>();
    public static void preUpdate_OpportunityNewStageUpdateForDMS(List<Opportunity> newTriggerList , Map<Id,Opportunity> oldTriggerMap){ 
        getOpportunityStageMap();
        for(Opportunity newlist: newTriggerList){
            if(newlist.Is_New_RDA_Process__c  && newlist.StageName != oldTriggerMap.get(newlist.Id).StageName &&  !opportunityNewStageMap.containsKey(oldTriggerMap.get(newlist.Id).StageName) && opportunityNewStageMap.containsKey(newlist.StageName)){
                newlist.StageName = opportunityNewStageMap.get(newlist.StageName);
            }            
        }     
    }
    
    public Static void getOpportunityStageMap() {
        /*****
        for(RDA_Process_Data_Migrate_Setting__mdt mdtSetting : [SELECT Id, Old_Stage_Name__c, New_Stage_Name__c, Object_Name__c 
                                                                FROM RDA_Process_Data_Migrate_Setting__mdt 
                                                                WHERE Object_Name__c ='Opportunity']){                                                                    
                                                                    opportunityNewStageMap.put(mdtSetting.Old_Stage_Name__c, mdtSetting.New_Stage_Name__c);
                                                                }
        *****/
        for(RDA_Process_Data_Migrate_Setting__mdt mdtSetting : RDA_Process_Data_Migrate_Setting__mdt.getAll().values()){       
            if(mdtSetting.Object_Name__c == 'Opportunity') {
                opportunityNewStageMap.put(mdtSetting.Old_Stage_Name__c, mdtSetting.New_Stage_Name__c);
            }
        }
    }
}
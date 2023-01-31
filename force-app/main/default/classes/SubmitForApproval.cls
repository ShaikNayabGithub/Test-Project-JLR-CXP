public class SubmitForApproval {
    
    public static Set<Id> opportunitiesAddedForApproval = new Set<Id>();
    
    public static void submit(List<Opportunity> opps) {
        Set<String> exProfileList = new Set<String>();
        for(Excluded_Profiles__mdt excludeProfiles : [Select Label FROM Excluded_Profiles__mdt]){
            exProfileList.add(excludeProfiles.Label);
        }
        ID profileID = system.UserInfo.getProfileId();
        String profileName = [Select name from Profile where id=:profileID limit 1].name;
        
        if(!exProfileList.contains(profileName)){
            for (Opportunity o : opps) {
                if (!Approval.isLocked(o) && !opportunitiesAddedForApproval.contains(o.id))
                {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(o.Id);
                    req.setSubmitterId(o.OwnerId);
                  
                    if(o.StageName == 'Lost' && o.Region_or_Market__c == 'MENA'){
                        req.setProcessDefinitionNameOrId('Opportunity_Retailer_Lost_MENA');
                        
                      }
                      
                      else if (o.StageName == 'Lost' && (o.Region_or_Market__c == 'APIO' || o.Region_or_Market__c == 'IN' || o.Region_or_Market__c == 'BR') && o.Country_ISO_Code__c != 'NZ' && o.Country_ISO_Code__c != 'TW') {
                        req.setProcessDefinitionNameOrId('Opportunity_Retailer_Lost_Streamline_ROW');
                        
                      }  
                      
                      else if (o.StageName == 'Lost' && (o.Region_or_Market__c == 'Mexico' || o.Region_or_Market__c == 'LACRO' || o.Region_or_Market__c == 'Colombia')) {
                        req.setProcessDefinitionNameOrId('Opportunity_Retailer_Lost_Streamline_MX');
                        
                      }
                      
                      
                      else if (o.StageName == 'Lost' && o.Country_ISO_Code__c == 'TW') {
                        req.setProcessDefinitionNameOrId('Opportunity_Retailer_Lost_Streamline_TW');
                        
                      }   
                      
                      else if (o.StageName == 'Lost' && o.Country_ISO_Code__c == 'JP') {
                        req.setProcessDefinitionNameOrId('Opportunity_Retailer_Lost_Streamline_JP');
                        
                      }  

                    
                    else{
                        req.setProcessDefinitionNameOrId('Opportunity_Retailer_Lost_v3');
                    }
                    //req.setSkipEntryCriteria(true);

                    try {
                        Approval.ProcessResult result = Approval.process(req);
                        if(result.isSuccess()){
                            opportunitiesAddedForApproval.add(o.id);
                        }
                    } catch (Exception ex) {

                        if (ex.getMessage().contains('NO_APPLICABLE_PROCESS')){
                            System.debug(LoggingLevel.INFO, req.processDefinitionNameOrId + ' does not exist on this system');
                        }
                        else{
                            throw ex;
                        }
                    }
                    

                }
            }
        }
    }
}
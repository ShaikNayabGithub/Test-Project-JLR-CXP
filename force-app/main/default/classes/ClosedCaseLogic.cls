/*
* @description  Set closed date for cases on update as process builder hit's permission error
* Required for aus but will be needed for all
* Bug around preupdate not having correct isClosed status hence why need to retrieve casestatus
* @author    JPatman 17/02/2020
* @V1.0        JLR
*     
* 
* 
*/

public class ClosedCaseLogic {    
    
    public void setClosedCaseStatusChange(List<Case> cases, Map<Id, Case> oldCaseMap){
        List<Case> closedCases = new List<Case>();
        for(Case newCase : cases){
            if(oldCaseMap.containsKey(newCase.id)){
                Case oldCase = oldCaseMap.get(newCase.Id);
                
                List<CaseStatus> css = [Select Id, MasterLabel, IsClosed, ApiName  From CaseStatus];
                Boolean wasOldStatusClosed;
                Boolean isNewStatusClosed;
                
                for(CaseStatus cs : css){
                    if(cs.ApiName == oldCase.Status){
                        wasOldStatusClosed = cs.IsClosed;
                    }
                    if(cs.ApiName == newCase.Status){
                        isNewStatusClosed = cs.IsClosed;
                    }
                }
            if(newCase.Status == 'Solved' && oldCase.Status != 'Solved' ){
                isNewStatusClosed = true;
            }
                
                
                if(oldCase != null && wasOldStatusClosed != null &&  isNewStatusClosed != null && wasOldStatusClosed == false && isNewStatusClosed == true){
                    
                    if( newCase.Solved_Date__c == null  ){
                        newCase.Solved_Date__c = System.now();
                        newCase.Solved_By__c = UserInfo.getUserId();
                    }
                }
                     if(oldCase != null && wasOldStatusClosed != null &&  isNewStatusClosed != null && wasOldStatusClosed == true && isNewStatusClosed == false){
                    
                  system.Debug('WIPE');
                      newCase.Solved_Date__c = null;
                        newCase.Solved_By__c = null;
                   
                }
            }
                        
        }
    }

                       
        
         public void setClosedCaseStatusCreate(List<Case> cases){
        List<Case> closedCases = new List<Case>();
        for(Case newCase : cases){
           
            
                
                List<CaseStatus> css = [Select Id, MasterLabel, IsClosed, ApiName  From CaseStatus];
             
                Boolean isNewStatusClosed;
                
                for(CaseStatus cs : css){
                  
                    if(cs.ApiName == newCase.Status){
                        isNewStatusClosed = cs.IsClosed;
                    }
                }
            
            if(newCase.Status == 'Solved'){
                isNewStatusClosed = true;
            }
              system.debug('newCase.Status '+newCase.Status); 
             system.debug('newCase.solved '+newCase.Solved_Date__c); 
               system.debug('is closed '+isNewStatusClosed); 
              //  newCase.addError('STOP');
                if(  isNewStatusClosed != null &&  isNewStatusClosed == true){
                    
                    if( newCase.Solved_Date__c == null  ){
                        newCase.Solved_Date__c = System.now();
                        newCase.Solved_By__c = UserInfo.getUserId();
                    }
               
            
            }
                        
        }
           
        
    }
    
    
}
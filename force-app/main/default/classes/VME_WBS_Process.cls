/******************************************************************************************
*  Name        : VME_WBS_Process
*  
*  Company     : Marlabs
*    
*  Purpose     : Class used to run VME_BatchClassWBSMappingTransformation batch class
* 
*  Developer   : Tejashree J
*
*  Created Date: 17/07/2019
----------------------------------------------------------------------
*/
public class VME_WBS_Process {
	@AuraEnabled
    public static Transaction_Wrapper callingBatch(){
    	Transaction_Wrapper return_Wrapper = new Transaction_Wrapper();
        Profile userProfileName = [Select Id,Name from Profile where Id=:UserInfo.getProfileId() LIMIT 1];
        User usr = [Select Id, name, Market__c from User where Id = : UserInfo.getUserId()];
        if(userProfileName.Name == 'Standard Sales User' || userProfileName.Name=='Delegated NSC Administrator'){
        if(usr.Market__c == null){
        		return_Wrapper.statusOfTransaction = 'MARKET-UNAVAILABLE';
             	return_Wrapper.errorMsgOfTransaction = 'Please check the Market value at the User level';
        }else{
        	 List < VME_CXP_Market_Codes__mdt > market_Code = [Select id,Label,Market__c from VME_CXP_Market_Codes__mdt where Market__c =:usr.Market__c];
             if(market_Code.size()==0){
             	return_Wrapper.statusOfTransaction = 'FAIL';
             	return_Wrapper.errorMsgOfTransaction = 'Incorrect Data';
             }else{
             	VME_BatchClassWBSMappingTransformation batch = new VME_BatchClassWBSMappingTransformation();
				Database.executeBatch(batch);
				return_Wrapper.statusOfTransaction = 'SUCCESS';
             	return_Wrapper.errorMsgOfTransaction = 'NO-ERROR';
				List<ApexClass> apList = [Select Id from ApexClass where Name = 'VME_BatchClassWBSMappingTransformation'];
            
				AsyncApexJob jobStatus = [SELECT Id,Status FROM AsyncApexJob 
				                                    WHERE JobType='BatchApex' 
				                                    AND ApexClassID =: apList[0].Id LIMIT 1] ;
				            
				if(jobStatus.Status == 'Completed'){
				//BATCH EXECUTION FINISHED
				return_Wrapper.statusOfTransaction = 'COMPLETED';
             	return_Wrapper.errorMsgOfTransaction = 'NO-ERROR';
				}
				else{
				//BATCH IS ALREADY SCHEDULED - SHOW NOTIFICATION
				return_Wrapper.statusOfTransaction = 'STARTED-PROCESSING';
             	return_Wrapper.errorMsgOfTransaction = 'NO-ERROR';
				}
				             }
        } 
        }else{
                return_Wrapper.statusOfTransaction = 'INSUFFICIENT PRIVILEGES';
                return_Wrapper.errorMsgOfTransaction = 'For further assistance please contact your Administrator';
        }
        return return_Wrapper;  
    }
    public class Transaction_Wrapper{
    	@AuraEnabled public String statusOfTransaction {get;set;}
        @AuraEnabled public String errorMsgOfTransaction {get;set;}
    }
}
//Author : Nayab Shaik
//Date : 23/01/2023
//Description :  
public class pdiRequestTriggerHandler {
   
    //Retrict to create duplicate PDI request with Requested/Approved status
    public void PreInsert(List<PDI_Request__c> pdiRequestRecs){
        pdiRequestTriggerHelper pdiTriggerHelper = new pdiRequestTriggerHelper();
        pdiTriggerHelper.restrictToCreateDuplicatePdiRequests(pdiRequestRecs);
    }
    //When requested delivery date changes then change the PDI status to Requested to be reviewed by PDI Agency.
    public void preUpdate(List<PDI_Request__c> newPdiRequests, Map<Id,PDI_Request__c> mapPdiRequests){
        pdiRequestTriggerHelper pdiTriggerHelper = new pdiRequestTriggerHelper();
        pdiTriggerHelper.ifRequestedDeliverydateChanged(newPdiRequests,mapPdiRequests);
        pdiTriggerHelper.restrictToCreateDuplicatePdiRequests(newPdiRequests);
        //pdiTriggerHelper.restrictToCreateDuplicatePdiRequestsBeforeUpdate(newPdiRequests,mapPdiRequests);
    }
}
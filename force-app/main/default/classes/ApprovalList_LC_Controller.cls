/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		31/05/2021			CXPD-1284: Add Opportunity Stage Name field to wrapper. CXPD-1320: Bug fix query optimization
* 
*/
public without sharing class ApprovalList_LC_Controller {

    @AuraEnabled
    public static List<MyApproval> getApprovalList(String approvalProcess) {
        Set<String> RelevantApprovalProcesses = new Set<String>();
        Map<Id, String> mapIdToOpp = new Map<Id, String>();
        Set<Id> oppIds = new Set<Id>();
        for(String s : approvalProcess.split(',')){
            if(String.IsNotBlank(s)){
                RelevantApprovalProcesses.add(s); 
            }
        }
        List<MyApproval> approvals = new List<MyApproval>();
        for(ProcessInstance eachPi : [SELECT Id, Status, TargetObjectId, TargetObject.Name, ProcessDefinition.DeveloperName, (SELECT Id, CreatedDate, Comments, OriginalActorId, OriginalActor.Name, StepStatus FROM Steps WHERE StepStatus = 'Started'  ORDER BY CreatedDate DESC LIMIT 1), (SELECT Id, ActorId FROM Workitems WHERE ActorId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance WHERE Status = 'Pending']){//1.0
            if(eachPi.Steps.size() > 0 && (RelevantApprovalProcesses.size() == 0 || RelevantApprovalProcesses.contains('' + eachPi.ProcessDefinition.DeveloperName)) && (eachPi.Workitems.size() > 0 && eachPi.Steps.size() > 0 && eachPi.Workitems[0].ActorId == UserInfo.getUserId() && eachPi.Steps[0].StepStatus == 'Started')){
                oppIds.add(eachPi.TargetObjectId);//Get Relevant Opp Id Set
            }
        }
        for(Opportunity eachOpp : [Select Id, StageName from Opportunity Where Id IN :oppIds]){//1.0
            mapIdToOpp.put(eachOpp.Id, eachOpp.StageName);	//Query Opp StageName
        }
        for(ProcessInstance pi : [SELECT Id, Status, TargetObjectId, TargetObject.Name, ProcessDefinition.DeveloperName, (SELECT Id, CreatedDate, Comments, OriginalActorId, OriginalActor.Name, StepStatus FROM Steps WHERE StepStatus = 'Started' ORDER BY CreatedDate DESC LIMIT 1), (SELECT Id, ActorId FROM Workitems  WHERE ActorId = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance WHERE Status = 'Pending' AND TargetObjectId IN :oppIds]){//CXPD-1320
            if(pi.Steps.size() > 0 && (RelevantApprovalProcesses.size() == 0 || RelevantApprovalProcesses.contains('' + pi.ProcessDefinition.DeveloperName)) && (pi.Workitems.size() > 0 && pi.Steps.size() > 0 && pi.Workitems[0].ActorId == UserInfo.getUserId() && pi.Steps[0].StepStatus == 'Started')){
                Date approvalDate = Date.newInstance(pi.Steps[0].CreatedDate.year(), pi.Steps[0].CreatedDate.month(), pi.Steps[0].CreatedDate.day());
                approvals.add(new MyApproval(approvalDate, pi.TargetObjectId, pi.TargetObject.Name, mapIdToOpp.get(pi.TargetObjectId), pi.Steps[0].OriginalActorId, pi.Steps[0].OriginalActor.Name, pi.Steps[0].Comments, pi.Workitems[0].Id));
            }
        }
        return approvals;
    }
    
	@AuraEnabled
    public static String submitApprovalProcess(Id recordId, String comment, String approvalAction) {
		Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
		req2.setComments(comment);
		req2.setAction(approvalAction); //Approve or Reject
		req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
		req2.setWorkitemId(recordId);
        try{
			Approval.ProcessResult result2 = Approval.process(req2);
            return 'success';
        }
        catch(Exception e){
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }
    
    public class MyApproval {
        @AuraEnabled public Date CreatedDate;
        @AuraEnabled public Id OpportunityId;
        @AuraEnabled public String OpportunityName;
        @AuraEnabled public String OpportunityStageName;//1.0
        @AuraEnabled public Id RequesterId;
        @AuraEnabled public String RequesterName;
        @AuraEnabled public String Comments;
        @AuraEnabled public Id WorkItemId;
        @AuraEnabled public boolean IsSelected;
        
        public MyApproval(Date passedCreatedDate, Id passedOpportunityId, String passedOpportunityName, String passedOpportunityStageName, Id passedRequesterId, String passedRequesterName, String passedComments, Id passedWorkitem){
            this.CreatedDate = passedCreatedDate;
            this.OpportunityId = passedOpportunityId;
            this.OpportunityName = passedOpportunityName;
            this.OpportunityStageName = passedOpportunityStageName;//1.0
            this.RequesterId = passedRequesterId;
            this.RequesterName = passedRequesterName;
            this.Comments = passedComments;
            this.WorkItemId = passedWorkitem;
        }
    }    
    
}
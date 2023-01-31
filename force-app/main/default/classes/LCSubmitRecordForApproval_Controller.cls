public class LCSubmitRecordForApproval_Controller {

    @AuraEnabled
    public static void submitForApproval(Id recordId, Id userId, String approvalComment) {
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setComments(approvalComment);
        approvalRequest.setObjectId(recordId);
        approvalRequest.setSubmitterId(userId);
        //approvalRequest.setSubmitterId(UserInfo.getUserId());
        approvalRequest.setSkipEntryCriteria(false);
        if(Test.IsRunningTest()){
            List<Id> currentUserList = new List<Id>();
            currentUserList.add(UserInfo.getUserId());
            approvalRequest.setNextApproverIds(currentUserList);
        }
        Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
    }
    
}
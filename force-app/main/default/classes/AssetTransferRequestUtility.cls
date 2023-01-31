public without sharing class AssetTransferRequestUtility {
public static void SendRequestEmail(Id assetId, Id requestorId, Id approverId) {

	}

	public static void SendRejectEmail(Id assetId, Id requestorId, Id rejectorId) {

	}

	public static void SendApprovalEmail(Id assetId, Id requestorId, Id approverId) {

	}

	public static Boolean RequstAccess(Id assetId, Id submitterUserId, String requestComments) {
		
		// Create an approval request for the asset
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setComments(requestComments);
        submitRequest.setObjectId(assetId);
        
        // Submit on behalf of a specific submitter
        submitRequest.setSubmitterId(submitterUserId); 
        
        // Submit the record to specific process and skip the criteria evaluation
        submitRequest.setProcessDefinitionNameOrId('Vehicle_Request_Approval');
        submitRequest.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(submitRequest);

        if (!result.isSuccess()) {
        	return false;
        }

        List<Id> userIds = result.getActorIds();

        return true;
	}
}
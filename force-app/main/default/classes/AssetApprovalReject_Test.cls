@isTest
private class AssetApprovalReject_Test {

    static testmethod void CurrentApproval_GivenValidRequest_ReturnsCorrectApproval(){
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Status = 'Transfer Requested';
        insert vehicle;
        
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(vehicle.Id);
		req.setSubmitterId(thisUser.Id);
		req.setNextApproverIds(new List<Id>{thisUser.Id});
		req.setProcessDefinitionNameOrId('Vehicle_Request_Approval');
		req.setSkipEntryCriteria(false);
		req.setComments('test approval process');
		Approval.process(req);

		AssetApprovalReject aar = new AssetApprovalReject();
		aar.assetIds = vehicle.Id;
		System.assertEquals('test approval process', aar.CurrentApprovalRequest.Comments);
    }
    
    static testmethod void OriginalRequestor_GivenValidRequest_ReturnsCorrectRequestor(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Status = 'Transfer Requested';
       	insert vehicle;
       	
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(vehicle.Id);
		req.setSubmitterId(thisUser.Id);
		req.setNextApproverIds(new List<Id>{thisUser.Id});
		req.setProcessDefinitionNameOrId('Vehicle_Request_Approval');
		req.setSkipEntryCriteria(false);
		req.setComments('test approval process');
		Approval.process(req);

		AssetApprovalReject aar = new AssetApprovalReject();
		aar.assetIds = vehicle.Id;
		System.assertEquals(thisUser.Id, aar.OriginalRequestor.Id);
    }
    
    static testmethod void GetAsset_GivenValidRequests_ReturnsFirstAsset(){
        Group g = new Group(Name='TestGroup', Type='Queue', Email='test@test.com');
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            insert g;
            GroupMember gm = new GroupMember(
                GroupId = g.Id,
                UserOrGroupId = UserInfo.getUserId()
            );
            insert gm;
        }

        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3);
        for(Asset v : vehicles){
       		v.Status = 'For Sale';
        }
        Account retailer = [SELECT Queue_ID__c, Region_or_Market__c FROM Account WHERE Id = :vehicles[0].AccountId];
       	retailer.Queue_ID__c = g.Id;
       	retailer.Region_or_Market__c = currentUserIsoCode;
       	update retailer;
       	insert vehicles;

        StockSearchController ssc = new StockSearchController(); //setup search controller
   	    ssc.InitialSearch();
       	for(StockSearchController.SelectVehicle sv : ssc.getVehicles()){
           	sv.isSelected = true;
       	}
       	ssc.TransferNotes = 'test notes';
       	ssc.RequestApproval();

		AssetApprovalReject aar = new AssetApprovalReject();
		aar.assetIds = vehicles[0].Id;
		aar.getAssets();
		System.assertNotEquals(null, aar.thisAsset);
    }
    
    static testmethod void GetURL_AsNonPartnerUser_ReturnsURL(){
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Status = 'Transfer Requested';
        insert vehicle;
        
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(vehicle.Id);
		req.setSubmitterId(thisUser.Id);
		req.setNextApproverIds(new List<Id>{thisUser.Id});
		req.setProcessDefinitionNameOrId('Vehicle_Request_Approval');
		req.setSkipEntryCriteria(false);
		req.setComments('test approval process');
		Approval.process(req);

		AssetApprovalReject aar = new AssetApprovalReject();
		aar.assetIds = vehicle.Id;
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		System.assertEquals(baseURL + '/' + vehicle.Id, aar.getURL());
    }
    
    static String currentUserIsoCode{
        get{
            if(currentUserIsoCode == null){
                User currentUser = [SELECT Market__c FROM User WHERE Id = :UserInfo.getUserId()];
                currentUserIsoCode = currentUser.Market__c;
            }
            return currentUserIsoCode;
        }
        set;
    } 
    
}
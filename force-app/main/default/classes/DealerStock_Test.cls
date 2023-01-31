@isTest
public class DealerStock_Test{
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
    
    static void SetupVehicle(Asset vehicle, String modelName, String accountRegion, boolean isNSC){
        Product2 modelProd = [SELECT Id, Name FROM Product2 WHERE Id = :vehicle.Model__c];
        modelProd.Name = modelName; //hi
        update modelProd;
        //vehicle.Name = 'TestVehicle';
        vehicle.New_or_Used__c = 'New';
        Integer modelYear = Date.today().year()-2; //set Model Year to 2 years ago
        vehicle.Model_Year__c = String.valueOf(modelYear);
        vehicle.Status = 'For Sale';
        Account retailer = [SELECT Region_or_Market__c, NSC_Importer__c FROM Account WHERE Id = :vehicle.AccountId]; //pull back the Asset Account and set the Region to the passed value, and assign if NSC
        retailer.Region_or_Market__c = accountRegion;
        retailer.NSC_Importer__c = isNSC ? 'NSC' : '';
        update retailer;
    }

    static testmethod void NSCSearch_NoAssetNoSearch_ReturnsNoResults(){
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromNSC(); //tell the controller we are running this for NSC
        System.assertEquals(0, ssc.getVehicles().size());
    }
    
    static testmethod void NSCSearch_OneAssetNoSearch_ReturnsOneResult(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, true); //set the search criteria on the vehicle (in my region, NSC)
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromNSC(); //tell the controller we are running this for NSC
        System.assertEquals('TestVehicle', ssc.getVehicles()[0].vehicle.Name);
    }
    
    /*static testmethod void NSCSearch_OneAssetValidSearch_ReturnsOneResult(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, true); //set the search criteria on the vehicle (in my region, NSC)
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromNSC(); //tell the controller we are running this for NSC
        ssc.asf.searchFields[0] = 'Model__c';
        ssc.asf.searchCriteria[0] = 'equals';
        ssc.asf.searchValues[0] = 'first car';
        ssc.asf.PerformSearch();
        System.assertEquals('TestVehicle', ssc.getVehicles()[0].vehicle.Name);
    }*/
    
    static testmethod void StockSearch_NoAssetNoSearch_ReturnsNoResults(){
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromRetailer(); //tell the controller we are running this for Retailer
        System.assertEquals(0, ssc.getVehicles().size());
    }
    
    static testmethod void StockSearch_OneAssetNoSearch_ReturnsOneResult(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false); //set the search criteria on the vehicle (in my region, not NSC)
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromRetailer(); //tell the controller we are running this for Retailer
        ssc.asf.searchName = 'TestVehicle';
        ssc.asf.PerformSearch();
        System.assertEquals(vehicle.Id, ssc.getVehicles()[0].vehicle.Id);
    }
        
    static testmethod void NSCSearchNonRegion_OneAssetNoSearch_ReturnsOneResult(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', 'ZZ', true); //set the search criteria on the vehicle (out of my region, NSC)
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromNSC(); //tell the controller we are running this for NSC
        System.assertEquals(0, ssc.getVehicles().size());
    }
    
    static testmethod void StockSearch_NoModelSearch_ReturnsNoResults(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false); //set the search criteria on the vehicle (out of my region, not NSC)
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromNSC();
        System.assertEquals(0, ssc.getVehicles().size());
    }
    
    static testmethod void StockSearchNonRegion_OneAssetNoSearch_ReturnsNoResults(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', 'ZZ', false); //set the search criteria on the vehicle (out of my region, not NSC)
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.FromRetailer(); //tell the controller we are running this for Retailer
        ssc.asf.searchName = 'First Car';
        System.assertEquals(0, ssc.getVehicles().size());
    }
    
    static testmethod void Search_OneLockedAssetNoSearch_ReturnsLockedResult(){
        //if a vehicle is already in an approval process it will be locked - test that the Map correctly picks this up
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false); //set the search criteria on the vehicle
        insert vehicle;
        Approval.Lock(vehicle); //'lock' the vehicle
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.InitialSearch();
        //test that the one vehicle returned is locked
        System.assertEquals(true, ssc.getVehicleLocked().get(vehicle.Id));
    }

    static testmethod void ShowPopUp_NoneSelected_Fails(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false); //set the search criteria on the vehicle
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.InitialSearch();
        ssc.ShowPopup(); //try to show popup without selecting any vehicles
        System.assertEquals(false, ssc.ShowPopup);
    }
    
    static testmethod void ShowPopUp_OneSelected_Succeeds(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false); //set the search criteria on the vehicle
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.InitialSearch();
        ssc.getVehicles()[0].isSelected = true; //select the vehicle
        ssc.ShowPopup();
        System.assertEquals(true, ssc.ShowPopup);
    }
    
    static testmethod void ShowPopUp_CancelPopup_Succeeds(){
        StockSearchController ssc = new StockSearchController();
        ssc.ShowPopup = true;
        ssc.CancelPopup();
        System.assertEquals(false, ssc.ShowPopup);
    }
    
    static testmethod void SelectSingleVehicle_Succeeds(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false); //set the search criteria on the vehicle
        vehicle.Price = 1000;
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.InitialSearch();
        ssc.singleVehicleId = ssc.getVehicles()[0].vehicle.Id;
        ssc.SelectSingleVehicle();
        System.assertEquals(1, ssc.getSelectedVehicles().size());
        System.assertEquals(ssc.singleVehicleId, ssc.getSelectedVehicles()[0].Id);
    }
    
    static testmethod void ApprovalProcess_NoTransferNotes_RequestFails(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false);
        //in order to set up the Approval Process, we need to set the Queue Id of the Retailer
        Group g = new Group(Name='TestGroup', Type='Queue', Email='test@test.com');
        insert g;
        Account retailer = [SELECT Queue_ID__c FROM Account WHERE Id = :vehicle.AccountId];
        retailer.Queue_ID__c = g.Id;
        update retailer;
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.InitialSearch();
        ssc.getVehicles()[0].isSelected = true; //select the vehicle (checkbox) and then request approval
        ssc.RequestApproval();
        Id vehicleId = ssc.getVehicles()[0].vehicle.Id;
        List<ProcessInstance> approvalInstances = [SELECT Id FROM ProcessInstance WHERE Status = 'Pending' AND TargetObjectId = :vehicleId AND CreatedDate = TODAY];
        System.assertEquals(0, approvalInstances.size()); //Transfer Notes have not been provided and therefore we will not create the Approval
    }

    static testmethod void ApprovalProcess_ValidRequest_RequestPasses(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        SetupVehicle(vehicle, 'First Car', currentUserIsoCode, false);
        //in order to set up the Approval Process, we need to set the Queue Id of the Retailer
        Group g = new Group(Name='TestGroup', Type='Queue', Email='test@test.com');
        insert g;
        Account retailer = [SELECT Queue_ID__c FROM Account WHERE Id = :vehicle.AccountId];
        retailer.Queue_ID__c = g.Id;
        update retailer;
        insert vehicle;
        StockSearchController ssc = new StockSearchController(); //setup search controller
        ssc.InitialSearch();
        ssc.getVehicles()[0].isSelected = true; //select the vehicle (checkbox) and then request approval
        ssc.TransferNotes = 'some test transfer notes';
        ssc.RequestApproval();
        List<ProcessInstance> approvalInstances = [SELECT TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND ProcessDefinition.DeveloperName = 'Vehicle_Request_Approval' AND CreatedDate = TODAY];
        System.assertEquals(vehicle.Id, approvalInstances[0].TargetObjectId);
    }
    
    static testmethod void ApprovalProcess_ValidRequests_RequestsPass(){
        //in order to set up the Approval Process, we need to set the Queue Id of the Retailer

        Group g = new Group(Name='TestGroup', Type='Queue', Email='test@test.com');
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            
            insert g;
            
            GroupMember gm = new GroupMember(
                GroupId = g.Id,
                UserOrGroupId = UserInfo.getUserId()
            );
            insert gm;
        }

        Test.startTest();

        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(28);
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
        ssc.TransferNotes = 'some test transfer notes';
        ssc.RequestApproval();

        Test.stopTest();
        Set<Id> approvedVehicles = new Set<Id>{vehicles[0].Id, vehicles[1].Id};
        List<ProcessInstance> approvalInstances = [SELECT Id FROM ProcessInstance WHERE Status = 'Pending' AND ProcessDefinition.DeveloperName = 'Vehicle_Request_Approval' AND TargetObjectId IN :approvedVehicles AND CreatedDate = TODAY];
        System.assertEquals(2, approvalInstances.size());
    }
    
    static testmethod void Page_CancelPage_Succeeds(){
        StockSearchController ssc = new StockSearchController();
        System.assertNotEquals(null, ssc.Cancel());
    }

}
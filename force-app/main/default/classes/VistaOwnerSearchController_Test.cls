@isTest
public with sharing class VistaOwnerSearchController_Test {
     
    static testmethod void Search_GivenValidModel_ReturnsModelOwner(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.modelId = vehicle.Model__c;
        vista.Search();
        System.assertEquals(vehicle.Model__c, vista.getSearchResults()[0].Vehicle__r.Model__c);
    } 
    
    static testmethod void Search_GivenValidModel_ReturnsMaxResults(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(2);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        System.assertEquals(2, vista.getSearchResults().size());
    }
    
    static testmethod void Search_GivenValidModel_ReturnsAllPages(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(2);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        System.assertEquals(2, vista.getTotalPages());
    }
    
    static testmethod void Search_GivenValidModel_HasNextPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(2);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        System.assertEquals(true, vista.getHasNextPage());
    }
    
    static testmethod void Search_GivenValidModel_HasPreviousPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(2);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        vista.ShowNextPage();
        System.assertEquals(true, vista.getHasPreviousPage());
    }
    
    static testmethod void Search_GivenValidModel_ShowsCorrectResultsOnNextPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(2, true);
        vehicles[0].Name = 'first';
        vehicles[1].Name = 'second';
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(1);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        vista.ShowNextPage();
        System.assertEquals('second', vista.getSearchResults()[0].Vehicle__r.Name);
    }

    static testmethod void Search_GivenValidModel_ShowsCorrectResultsOnPreviousPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(2, true);
        vehicles[0].Name = 'first';
        vehicles[1].Name = 'second';
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(1);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        vista.ShowNextPage();
        vista.ShowPreviousPage();
        System.assertEquals('first', vista.getSearchResults()[0].Vehicle__r.Name);
    }
    
    static testmethod void Search_GivenValidModel_ShowsCorrectResultsOnLastPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        vehicles[0].Name = 'first';
        vehicles[1].Name = 'second';
        vehicles[2].Name = 'third';
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(1);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        vista.ShowLastPage();
        System.assertEquals('third', vista.getSearchResults()[0].Vehicle__r.Name);
    }

    static testmethod void Search_GivenValidModel_ShowsCorrectResultsOnFirstPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(2, true);
        vehicles[0].Name = 'first';
        vehicles[1].Name = 'second';
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(1);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        vista.ShowFirstPage();
        System.assertEquals('first', vista.getSearchResults()[0].Vehicle__r.Name);
    }
    
    static testmethod void Search_GivenValidModel_ShowsCorrectPage(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(2);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        vista.ShowNextPage();
        System.assertEquals(2, vista.getCurrentPage());
    }
    
    static testmethod void Search_GivenValidModel_ShowsCorrectPageOfPages(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxResults(1);
        vista.modelId = vehicles[0].Model__c;
        vista.Search();
        System.assertEquals(String.format(System.Label.Vista_Page_of_Pages, new List<String>{'1', '3'}), vista.getCurrentPageOfTotalPages());
    }
    
    static testmethod void Search_GivenValidModelAndOwnership_ReturnsModelOwner(){
        /*DateTime created=System.now().addDays(-(idx*10));
            Test.setCreatedDate(cases[idx-1].Id, created);*/
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        Role__c assetRole = [SELECT Id FROM Role__c WHERE Vehicle__c = :vehicle.Id LIMIT 1];
        //Test.setCreatedDate(assetRole.Id, System.now().addDays(-62)); //two months ago
        DateTime dtCreated = System.now().addDays(-62);
        assetRole.Role_Created__c =  date.newinstance(dtCreated.year(), dtCreated.month(), dtCreated.day());
        update assetRole;
        assetRole = [SELECT Id, Role_Created__c FROM Role__c];
        Test.startTest();
            VistaOwnerSearchController vista = new VistaOwnerSearchController();
            vista.modelId = vehicle.Model__c;
            vista.ownershipFrom = '1';
            vista.ownershipTo = '3';
            vista.Search();
        Test.stopTest();
        System.assertEquals(vehicle.Name, vista.getSearchResults()[0].Vehicle__r.Name);
    }
    
    static testmethod void Search_GivenValidModelAndInvalidOwnership_ReturnsNoResults(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        Role__c assetRole = [SELECT Id FROM Role__c WHERE Vehicle__c = :vehicle.Id LIMIT 1];
        //Test.setCreatedDate(assetRole.Id, System.now().addDays(-93)); //three months ago
        DateTime dtCreated = System.now().addDays(-93);
        assetRole.Role_Created__c = date.newinstance(dtCreated.year(), dtCreated.month(), dtCreated.day());
        assetRole = [SELECT Id, Role_Created__c FROM Role__c];
        Test.startTest();
            VistaOwnerSearchController vista = new VistaOwnerSearchController();
            vista.modelId = vehicle.Model__c;
            vista.ownershipFrom = '1';
            vista.ownershipTo = '2';
            vista.Search();
        Test.stopTest();
        System.assertEquals(0, vista.getSearchResults().size());
    }
    
    static testmethod void SearchCriteriaCheck_GivenInvalidOwnershipFrom_GivesError(){
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.ownershipFrom = 'a';
        System.assertEquals(false, vista.IsSearchCriteriaValid());
    }
    
    static testmethod void SearchCriteriaCheck_GivenInvalidOwnershipTo_GivesError(){
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.ownershipTo = 'a';
        System.assertEquals(false, vista.IsSearchCriteriaValid());
    }
    
    static testmethod void Setup_FeatureNamesCreated_True(){
        BRS_FeatureGroupFieldMappingByCode__c featureGroup = new BRS_FeatureGroupFieldMappingByCode__c(Name='PCOL', Field_Name__c='Exterior_Colour_Code__c');
        insert featureGroup;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        System.assertEquals(1, vista.FeatureNames.size());
    }
    
    static testmethod void Setup_FeatureLabelsCreated_True(){
        BRS_FeatureGroupFieldMappingByCode__c featureGroup = new BRS_FeatureGroupFieldMappingByCode__c(Name='PCOL', Field_Name__c='Exterior_Colour_Code__c');
        insert featureGroup;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        System.assertEquals(Asset.Exterior_Colour_Code__c.getDescribe().getLabel(), vista.FeatureLabels.get('Exterior_Colour_Code__c'));
    }
    
    static testmethod void Search_GivenValidFeature_ReturnsModelOwner(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        vehicle.Transmission__c = 'Manual';
        insert vehicle;
        BRS_FeatureGroupFieldMappingByCode__c featureGroup = new BRS_FeatureGroupFieldMappingByCode__c(Name='PTR', Field_Name__c='Transmission__c');
        insert featureGroup;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.FeatureValues.put('Transmission__c', '[Manual]');
        vista.Search();
        System.assertEquals(vehicle.Name, vista.getSearchResults()[0].Vehicle__r.Name);
    }
    
    static testmethod void Search_GivenInvalidFeature_ReturnsNoResults(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        vehicle.Transmission__c = 'Manual';
        insert vehicle;
        BRS_FeatureGroupFieldMappingByCode__c featureGroup = new BRS_FeatureGroupFieldMappingByCode__c(Name='PTR', Field_Name__c='Transmission__c');
        insert featureGroup;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.FeatureValues.put('Transmission__c', '[Automatic]');
        vista.Search();
        System.assertEquals(0, vista.getSearchResults().size());
    }
    
    static testmethod void Setup_ChannelPreferencesCreated_True(){
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        System.assertEquals(4, vista.ChannelPreferencePicklist.size());
    }
    
    static testmethod void Search_GivenValidChannelPreference_ReturnsModelOwner(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.channelPreference = 'PersonHasOptedOutOfEmail';
        vista.Search();
        System.assertEquals(vehicle.Name, vista.getSearchResults()[0].Vehicle__r.Name);
    }
    
    static testmethod void Search_GivenInvalidChannelPreference_ReturnsNoResults(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        Account owner = [SELECT Jaguar_Email_Opt_Out__pc FROM Account WHERE Id = :vehicle.AccountId LIMIT 1];
        owner.PersonHasOptedOutOfEmail = true;
        update owner;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.channelPreference = 'PersonHasOptedOutOfEmail';
        vista.Search();
        System.assertEquals(0, vista.getSearchResults().size());
    }
    
    static testmethod void AddToCampaign_WithResultsReturned_AllAddedToCampaign(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.Search();
        Campaign newCampaign = TestClass_CampaignBuilder.BuildCampaign();
        insert newCampaign;
        vista.campaignId =  newCampaign.Id;
        vista.AddToCampaign();
        List<CampaignMember> members = [SELECT Id FROM CampaignMember WHERE CampaignId = :newCampaign.Id];
        System.assertEquals(1, members.size());
    }
    
    static testmethod void AddToCampaign_WithResultsReturnedAndMemberAlreadyInCampaign_DisplaysError(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        Test.setCurrentPage(Page.VistaOwnerSearch);
        vista.Search();
        Campaign newCampaign = TestClass_CampaignBuilder.BuildCampaign();
        insert newCampaign;
        CampaignMember newMember = new CampaignMember(CampaignId=newCampaign.Id, ContactId=vista.getSearchResults()[0].Account__r.PersonContactId);
        insert newMember;
        vista.campaignId =  newCampaign.Id;
        vista.AddToCampaign();
        System.assertEquals(1, ApexPages.getMessages().size());
    }
    
    static testmethod void AddToCampaign_WithResultsExceedingMaxCampaignMembers_CanAddToCampaignFalse(){
        List<Asset> vehicles = TestClass_AssetBuilder.BuildVehicles(3, true);
        insert vehicles;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.SetMaxCampaignMembers(2);
        vista.Search();
        System.assertEquals(false, vista.getCanAddCampaignMembers());
    }
    
    static testmethod void RemoveFromCampaign_WithResultsReturned_AllRemovedFromCampaign(){
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        insert vehicle;
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        vista.Search();
        Campaign newCampaign = TestClass_CampaignBuilder.BuildCampaign();
        insert newCampaign;
        CampaignMember newMember = new CampaignMember(CampaignId=newCampaign.Id, ContactId=vista.getSearchResults()[0].Account__r.PersonContactId);
        insert newMember;
        vista.campaignId =  newCampaign.Id;
        vista.RemoveFromCampaign();
        List<CampaignMember> members = [SELECT Id FROM CampaignMember WHERE CampaignId = :newCampaign.Id];
        System.assertEquals(0, members.size());
    }
    
    static testmethod void Setup_RunAsMarketingUser_ShowsChannelPreferenceTrue(){
        List<User> u =  [SELECT Id FROM User WHERE UserPermissionsMarketingUser = true AND IsActive = true LIMIT 1];
        if(u.size() > 0){
            System.runAs(u[0]){
                VistaOwnerSearchController vista = new VistaOwnerSearchController();
                System.assertEquals(true, vista.getUserIsMarketing());
            }
        }
    }
    
    static testmethod void Setup_RunAsNonMarketingUser_ShowsChannelPreferenceFalse(){
        List<User> u =  [SELECT Id FROM User WHERE UserPermissionsMarketingUser = false AND IsActive = true LIMIT 1];
        if(u.size() > 0){
            System.runAs(u[0]){
                VistaOwnerSearchController vista = new VistaOwnerSearchController();
                System.assertEquals(false, vista.getUserIsMarketing());
            }
        }
    }
    
    static testmethod void Setup_RunAsAPIOUser_ShowsCountriesFalse(){
        List<User> u =  [SELECT Id FROM User WHERE Market__c = 'APIO' AND IsActive = true LIMIT 1];
        if(u.size() > 0){
            System.runAs(u[0]){
                VistaOwnerSearchController vista = new VistaOwnerSearchController();
                System.assertEquals(true, vista.getShowCountryPicklist());
            }
        }
    }
    
    static testmethod void Setup_DependentPicklist_ShowsCorrectValues(){
        VistaOwnerSearchController vista = new VistaOwnerSearchController();
        System.assert(vista.GetDependentOptions('Asset', 'Model__c', 'Brand__c').size() > 0);
    }

}
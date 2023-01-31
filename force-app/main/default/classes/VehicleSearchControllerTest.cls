@isTest
private class VehicleSearchControllerTest {

    static testMethod void testScrollVehicleList() {
        
        
        CreateTestData tdata = new CreateTestData();
        tdata.loadJUDAANMarketSettingsData();
        String market = 'JP';
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(market);
        
        List <Colour_Group_Mapping__c> colourGroups = [select name,colour_Group__c from Colour_Group_Mapping__c ];
        System.assertEquals(1,colourGroups.size());
        
        System.assertEquals('Bluefire',colourGroups[0].Name);
        System.assertEquals('Blue',colourGroups[0].Colour_Group__c); 
        
        List <Vehicle_Specification__c> specs = [select name from Vehicle_Specification__c];
        System.assertEquals(1,specs.size());
        System.assertEquals('Land Rover',specs[0].Name);
        
        Id rtIdforModel = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        List<Product2> models = [select id from Product2 where RecordTypeId = : rtIDforModel]; 
        
        System.assertEquals(1,models.size() );
        Id rtIdforDerivative = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        List<Product2> derivatives = [select id from Product2 where Model__c = : models[0].id and RecordTypeId = : rtIDforDerivative]; 
        //System.assertEquals(0,derivatives.size());
        System.assertEquals(1,derivatives.size());
        
        List<Asset> assets = [select id from Asset ];
        
        System.assertEquals(1,assets.size() );
        
        ApexPages.currentPage().getParameters().put( 'market' , 'jp');
        
        VehicleSearchController ctrl = new VehicleSearchController();
        ctrl.dispatch();
        
        
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
        ctrl.LoadModels();
        
        
        //System.assertEquals(System.label.DEFAULT_LANGUAGE,ctrl.bean.selectedLanguage); 
        System.assertEquals(System.label.Model_FB,ctrl.bean.selectedModelStr); 
        System.assertEquals(System.label.Engine_FB,ctrl.bean.selectedEngineStr); 
        System.assertEquals(System.label.Colour_FB,ctrl.bean.selectedColourStr); 
        System.assertEquals(System.label.Price_FB,ctrl.bean.selectedPriceStr); 
        System.assertEquals(System.label.Features_FB,ctrl.bean.selectedOptionStr); 
        System.assertEquals(System.label.Specification_FB,ctrl.bean.selectedSpecificationStr);  
        System.assertEquals(2,ctrl.bean.brands.size());  
        
        System.assertEquals(17,ctrl.bean.paymentSelector.types.size());
        System.assertEquals(false,ctrl.bean.decidedBudget);  
        //System.assertEquals(2,ctrl.bean.models.size()); 
        System.assertEquals(1,ctrl.bean.models.size()); 
        System.assertEquals(1,ctrl.bean.vehicleCount);  
        
        System.assert( ctrl.bean.vehicles == null );   
        
        ctrl.scrollVehicleList();
        
        
        
        System.assertEquals(IntegerUtil.getValue(null),IntegerUtil.getValue(0)); 
        
    }

   
     static testMethod void testFilterAndLoadVehicles() {
        
        CreateTestData tdata = new CreateTestData();
        String market = 'JP';
        
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(market);
        tdata.createCampaign();
        
       
        JUDAANMarketSettings__c setting=JUDAANMarketSettings__c.getOrgDefaults();    
        setting.Default_Language__c = 'ja';
        
        setting.Name = 'jp';
        upsert setting;
        
        JUDAANMarketSettings__c setting1=JUDAANMarketSettings__c.getOrgDefaults();
        setting1.Default_Language__c = 'en';
        setting1.Dealer_Locator_JG_Link__c = 'Test JAG';
        setting1.Dealer_Locator_LR_Link__c   = 'Test LR';
        setting1.Name = 'sg';
        upsert setting1;
        
        PageReference vehiclesearch= Page.VehicleSearch;
        Test.setCurrentPage(vehiclesearch);
        
        List<JUDAAN_Campaign__c> campaigns = [select id from JUDAAN_Campaign__c];
        
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        
        VehicleSearchController ctrl = new VehicleSearchController();
        
        System.assertEquals(null,ctrl.bean.selectedModelStr);
        PageReference p = ctrl.dispatch();
        ctrl.LoadModels(); 
        
        System.assertEquals(System.label.Model_FB,ctrl.bean.selectedModelStr);  
        System.assertEquals(true,ctrl.bean.getCheckedModels().isEmpty()); 
        
        System.assertEquals(null,ctrl.bean.selectedBodyStyleStr); 
        
        ctrl.LoadBodyStyles();
        
        System.assertEquals(null,ctrl.bean.selectedBodyStyleStr);
        System.assertEquals(System.label.Model_FB,ctrl.bean.selectedModelStr);
        System.assertEquals(true,ctrl.bean.getCheckedModels().isEmpty());  
        
        for( VehicleSearchBean.SearchSection tmp : ctrl.bean.models ) tmp.checked = true;
        
        System.assertEquals(false,ctrl.bean.getCheckedModels().isEmpty());    
        
        ctrl.LoadBodyStyles(); 
        
        System.assertEquals(tdata.modelName,ctrl.bean.selectedModelStr.toUpperCase()); //ctrl.bean.selectedMofelStr is bringing in a translated picklist value of Asset.Product2.Model_Alternative__c hence the toUpperCase() function
         Test.StartTest();
        ctrl.LoadEngines();
        for( VehicleSearchBean.SearchSection tmp : ctrl.bean.bodyStyles ) {
            tmp.checked = true;
        }
        ctrl.LoadEngines();
        ctrl.advancedSearch();
        
        ctrl.LoadExteriorColor();
        for( VehicleSearchBean.SearchSection tmp : ctrl.bean.engines ) {
            tmp.checked = true;
        }
        ctrl.LoadExteriorColor();
        
        ctrl.LoadExteriorDetailColor();   
        
        if(ctrl.bean.exteriorGroupColours != null){     
            for( VehicleSearchBean.SearchSection tmp : ctrl.bean.exteriorGroupColours ) {
                tmp.checked = true;
            }
        }
        ctrl.LoadExteriorDetailColor();        
        
        ctrl.LoadInteriorColor();  
        if(ctrl.bean.exteriorColours != null){     
            for( VehicleSearchBean.SearchSection tmp : ctrl.bean.exteriorColours ) {
                tmp.checked = true;
            }
        }
        ctrl.LoadInteriorColor();        
        
        ctrl.LoadSpecs();  
        
        if(ctrl.bean.interiorColours != null){
            for( VehicleSearchBean.SearchSection tmp : ctrl.bean.interiorColours ) {
                tmp.checked = true;
            }
        }
        ctrl.LoadSpecs();
        ctrl.deloadSpecs();
        ctrl.LoadSpecs();
        ctrl.LoadOptions(); 
        
        
        if(ctrl.bean.specifications != null){
            for( VehicleSearchBean.SearchSection tmp : ctrl.bean.specifications ) {
                tmp.checked = true;
            }
        }
        ctrl.LoadOptions(); 
        if(ctrl.bean.options != null){
            for( VehicleSearchBean.SearchSection tmp : ctrl.bean.options ) {
                tmp.checked = true;
            }
        }
        
        ctrl.bean.paymentSelector.selectedType = '48';
        ctrl.bean.paymentSelector.selectedBudget = '500000';
        ctrl.bean.paymentSelector.selectedDeposit = '200000';
        ctrl.bean.paymentSelector.selectedTradeinvalue = '0';
        ctrl.LoadBudget();
        
        Id assetId;
        if(ctrl.bean.vehicles != null ){
            for(VehicleSearchBean.vehicle tmp : ctrl.bean.vehicles){
                assetId  = ctrl.bean.vehicles.get(0).vehicleId;  
                
                tdata.createCampaign(tmp.productid); 
                testmultipleCampaign(tmp);
            }
        }
        ApexPages.currentPage().getParameters().put( 'assetId' , assetId   );
        ctrl.setAssetIdToDtoClass();
        
        ctrl.clearBudget();
        
        ctrl.restartSearch();
        
        Account guestAccount = tdata.createPersonalAccount();
        insert guestAccount;
        
        Id rtIDforDealer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        List<Account> dealers = [select id from account where RecordTypeId = : rtIDforDealer];
        System.assertEquals(1,dealers.size());
        
        User comUser;
        System.runAs( new User( Id = UserInfo.getUserId() ) ) {
            comUser = tdata.createCustomerCommunityUser( guestAccount );
            insert comUser;
        }
        
        List<User> comUsers = [select id from user where contact.account.id = : guestAccount.id];
        System.assertEquals(1,comUsers.size());
        
        
        List<Saved_Vehicle_for_Lead__c> savedVehicles = [select id from Saved_Vehicle_for_Lead__c ]; 
        system.assertEquals(0,savedVehicles.size());
        
        
        System.runAs( comUser ) {
            
            ApexPages.currentPage().getParameters().put( 'assetId' , assetId );
            //ctrl.setAssetIdToDtoClass();
            
            ctrl.showDetail();
            ctrl.save();
            ctrl.selectOption();
            ctrl.switchBrand();
        }
        
        VehicleSearchInputParameters inputParams = new VehicleSearchInputParameters();
        inputParams.inputBonusAmount = '200000';
        Integer bonus = inputParams.getBonusAmount();
        
        Test.StopTest();
    }
    
    static testMethod void testFilterAndLoadVehiclesSpecial() {
        
        String market = 'JP';
        JUDAANMarketSettings__c setting=JUDAANMarketSettings__c.getOrgDefaults();
        setting.Default_Language__c = 'en';
        setting.Name = 'jp';
        upsert setting;
        PageReference vehiclesearch= Page.VehicleSearch;
        Test.setCurrentPage(vehiclesearch);
        
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(market);
        //tdata.createCampaign();
        
        
        
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        
        VehicleSearchController ctrl = new VehicleSearchController();
        
        System.assertEquals(null,ctrl.bean.selectedModelStr);
        PageReference p = ctrl.dispatch();
        ctrl.LoadModels(); 
        
        System.assertEquals(System.label.Model_FB,ctrl.bean.selectedModelStr);  
        System.assertEquals(true,ctrl.bean.getCheckedModels().isEmpty()); 
        
        System.assertEquals(null,ctrl.bean.selectedBodyStyleStr); 
        
        ctrl.LoadBodyStyles();
        
        System.assertEquals(null,ctrl.bean.selectedBodyStyleStr);
        System.assertEquals(System.label.Model_FB,ctrl.bean.selectedModelStr);
        System.assertEquals(true,ctrl.bean.getCheckedModels().isEmpty());  
        
        
        for( VehicleSearchBean.Model tmp : ctrl.bean.models ) {
            
            tmp.checked = true;
            tdata.createCampaign(tmp.productid); 
            ApexPages.currentPage().getParameters().put( 'modelname' , tmp.modelname );
            ApexPages.currentPage().getParameters().put( 'specialmodel' , 'special' );
        }
         List<Asset> assets = [select id from Asset ];
        List<JUDAAN_Campaign__c>  lstCampaign =  [Select Id,recordTypeId,Market__c  from JUDAAN_Campaign__c  limit 1]; 
        lstCampaign[0].Market__c   = 'jp';
        lstCampaign[0].VIN_Asset_Level_ID__c  =  assets[0].id ;
        lstCampaign[0].VIN_Level_Campaign_Text__c = 'Test';
        
        update lstCampaign;
        
        System.assertEquals(false,ctrl.bean.getCheckedModels().isEmpty());    
        
        Test.startTest();
        ctrl.specialVehicleLst();
        System.assertEquals(ctrl.bean.vehicleCount, 1);    
        
        Id assetId;
        if(ctrl.bean.vehicles != null && ctrl.bean.vehicles.size()>0 )
        {
            for(VehicleSearchBean.vehicle tmp : ctrl.bean.vehicles){
                
                testmultipleCampaign(tmp);
            }
            assetId = ctrl.bean.vehicles.get(0).vehicleId;
        }
        
        Test.stopTest();
        
        
    }
    
    static testMethod void testFilterAndLoadVehiclesRecommended() {
        
        String market = 'JP';
        JUDAANMarketSettings__c setting=JUDAANMarketSettings__c.getOrgDefaults();
        setting.Default_Language__c = 'en';
        setting.Name = 'jp';
        upsert setting;
        PageReference vehiclesearch= Page.VehicleSearch;
        Test.setCurrentPage(vehiclesearch);
        
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(market);
        
        
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        
        
        
        VehicleSearchController ctrl = new VehicleSearchController();
        
        System.assertEquals(null,ctrl.bean.selectedModelStr);
        PageReference p = ctrl.dispatch();
        ctrl.LoadModels(); 
        
        for( VehicleSearchBean.Model tmp : ctrl.bean.models ) {
            
            tmp.checked = true;
            tdata.createCampaign(tmp.productid); 
            ApexPages.currentPage().getParameters().put( 'modelname' , tmp.modelname );
            ApexPages.currentPage().getParameters().put( 'isRecommended' , 'true' );
            ApexPages.currentPage().getParameters().put( 'models' , tmp.modelname );
            
            
        }
        
        
        System.assertEquals(System.label.Model_FB,ctrl.bean.selectedModelStr);  
        
        
        System.assertEquals(null,ctrl.bean.selectedBodyStyleStr); 
        
        List<JUDAAN_Campaign__c>  lstCampaign =  [Select Id,recordTypeId,Market__c  from JUDAAN_Campaign__c  limit 1]; 
        lstCampaign[0].Market__c   = 'jp';
        Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Recommended_Choice).getRecordTypeId();
        lstCampaign[0].recordTypeId = campaignRecordTypeId ;
        update lstCampaign;
        ctrl.LoadBodyStyles();
        
        System.assertEquals(null,ctrl.bean.selectedBodyStyleStr);
        System.assertEquals('Discovery',ctrl.bean.selectedModelStr);
        System.assertEquals(false,ctrl.bean.getCheckedModels().isEmpty());  
        
        
        
        
        
        System.assertEquals(false,ctrl.bean.getCheckedModels().isEmpty());    
        
        Test.startTest();
        
        
        System.debug( '------ ctrl.bean.vehicles = ' + ctrl.bean);
        
        
        Test.stopTest();
        
        
    }
    
    private static void testmultipleCampaign(VehicleSearchBean.Vehicle ast)
    {
        
        VehicleSearchController ctrl = new VehicleSearchController();
        List<JUDAAN_Campaign__c>  lstCampaign= [select Id,Body_Style__c,Specification_Pack_Alternative__c,model_year__c  from JUDAAN_Campaign__c limit 1];
        string mark='jp';
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
        lstCampaign[0].body_style__c =  '5 DOOR SUV';
        lstCampaign[0].model_year__c=  '2017';
        lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
        system.assert(lstCampaign[0].body_style__c == ast.bodystyle);
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
        lstCampaign[0].body_style__c = '';
        lstCampaign[0].model_year__c=  '2017';
        lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        system.assert(lstCampaign[0].body_style__c != ast.bodystyle);
        
        lstCampaign[0].body_style__c = '';
        lstCampaign[0].model_year__c=  '2017';
        lstCampaign[0].Specification_Pack_Alternative__c = '';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        system.assert(lstCampaign[0].body_style__c != ast.bodystyle);
        
        lstCampaign[0].body_style__c = '';
        lstCampaign[0].model_year__c=  '';
        lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        system.assert(lstCampaign[0].Specification_Pack_Alternative__c == ast.specification);
        
        
        lstCampaign[0].body_style__c = '5 DOOR SUV';
        lstCampaign[0].model_year__c =  '';
        lstCampaign[0].Specification_Pack_Alternative__c = '';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
        lstCampaign[0].body_style__c = '5 DOOR SUV';
        lstCampaign[0].model_year__c =  '';
        lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
        lstCampaign[0].body_style__c = '5 DOOR SUV';
        lstCampaign[0].model_year__c =  '';
        lstCampaign[0].Specification_Pack_Alternative__c = '';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
        lstCampaign[0].body_style__c = '';
        lstCampaign[0].model_year__c =  '2017';
        lstCampaign[0].Specification_Pack_Alternative__c = '';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
        lstCampaign[0].body_style__c = '5 DOOR SUV';
        lstCampaign[0].model_year__c=  '2017';
        lstCampaign[0].Specification_Pack_Alternative__c = '';
        
        
        
        ctrl.checkCampaign(ast  ,lstCampaign);
        
    }
    
    static testMethod void testsetDeserializedBean() {
        test.startTest(); 
            String market = 'JP';
            JUDAANMarketSettings__c setting=JUDAANMarketSettings__c.getOrgDefaults();
            setting.Default_Language__c = 'en';
            setting.Name = 'jp';
            upsert setting;
            VehicleSearchBean searchBean = new VehicleSearchBean();
            VehicleSearchBeanSelectedOnly vsbs = new VehicleSearchBeanSelectedOnly(searchBean);
            searchBean.setDeserializedBean(vsbs);
            AttachmentDao objAttachmentDao= new AttachmentDao();
        test.stopTest();
        
    }
    
    

}
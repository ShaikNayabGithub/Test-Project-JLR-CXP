@isTest(Seealldata = false)
private class VehicleSingleControllerTest {

    public User u { get; set; }
    public Asset ass { get; set; }
    public string personAccStr;
    
    @testSetup static void createData() {
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createCampaign();
        tdata.loadJUDAANMarketSettingsData();
        List<Asset> assets = tdata.createAssets();
        Account  personAcc = new Account();
        personAcc = tdata.createPersonalAccount();
        insert personAcc;
        
        User u = tdata.createCustomerCommunityUser(personAcc);
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
            insert u;
        }
    }
    
    static testMethod void testExecute() {
        
        Test.startTest();
            Asset ast = [select Id,accountid from Asset limit 1];
            User u = [select Id from User limit 1];
            TestClass_PrefectureWardsBuilder.generatePrefectureWardsMapping('埼玉県', new List<String> { 'さいたま市', '三芳町'});
            ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
            ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
            
            VehicleSingleController ctrl = new VehicleSingleController();
            
            System.runAs(u) {
                ctrl.getRecords();
                ctrl.goBack();
                ctrl.showCheckoutPage();
                
                system.assert(ctrl.showCheckoutPage().getUrl().contains('checkout'));
                ctrl.showMoreVehicle();
                ctrl.setAssetIdToDtoClass();
                
                ctrl.Prefecture2 = '埼玉県';
                ctrl.filterWards();
                
                ctrl.Ward2 = '三芳町';
                ctrl.searchRetailers();
                ctrl.Ward2 = 'さいたま市';
                ctrl.searchRetailers();
                
                ctrl.objcase.description ='Test';
                ctrl.objcase.type='General Enquiry';
                ctrl.isEmail =true;
                ctrl.isSMS =true;
                ctrl.isPhone =true;
                
                system.assert(ctrl.wrapper.isSavedVehicle == true);
                ctrl.saveEnquiryform();
                EnquiryformAPOSingle objEnquriry = new EnquiryformAPOSingle();
                //Id retailerid = objEnquriry.getOwner(String.valueof(ast.accountid));
                ctrl.save();
                
            }
        Test.stopTest();
    }
    
    static testMethod void testduplicateSaveVehicle() {
        
        Test.startTest();
            CreateTestData tdata = new CreateTestData();
            Asset ast = [select Id from Asset limit 1];
            
            List<Account> accList = new List<Account>();
            //Account acc = tdata.createPersonalAccount();
            //accList.add(acc);
            //insert acc;
            Account dealerAcc = tdata.createDealer();
            accList.add(dealerAcc);
            //insert dealerAcc;
            insert accList;
            Account objPer = [select id from account where PersonEmail  ='testCommunityUser@jlr.com' ];
            system.debug('--objPer'+objPer );
            // List<User> testUser = [Select id from user where profileid= : ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name) limit 1];
            User u = [select Id from User limit 1];
            RecordSharer.DisableRecordSharing= true;
            //Lead testLead = tdata.createLead(accList.get(0),accList.get(1));
            //insert testLead;
            //Saved_Vehicle_for_Lead__c testSavedVehicle = tdata.createSavedVehicleForLead(testLead,ast);
            //insert testSavedVehicle;
            
            
            ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
            ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
            ApexPages.currentPage().getParameters().put( 'brand' , 'Land Rover' );
            ApexPages.currentPage().getParameters().put( 'isRecomm' , 'true' );
            ApexPages.currentPage().getParameters().put( 'isFeature' , 'true' );
            ApexPages.currentPage().getParameters().put( 'isSpecial' , 'true' );
            VehicleSingleController ctrl = new VehicleSingleController();
            System.runAs(u){
                ctrl.getRecords();
                ctrl.save();
                system.assert(ast.Id ==ctrl.dto.assetId );
            }
        Test.stopTest();
    }
    
    static testMethod void testExecuteNoLanguage() {
        ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        VehicleSingleController ctrl = new VehicleSingleController();
        system.assert(ctrl.language  == System.label.DEFAULT_LANGUAGE);
    }
    
    static testMethod void getCampaignTest() {        
        ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        CreateTestData tdata = new CreateTestData();
        tdata.createMaker();
        List<product2> pList = tdata.createProducts();
        tdata.createCampaign();
        VehicleSingleController ctrl = new VehicleSingleController();
        ctrl.getCampaign(pList.get(0).id , 'jp' );
    }
    
    static testMethod void noSavedVehicleIdTest() {
        
        Test.startTest();
            Asset ast = [select Id from Asset limit 1];
            //User u = [select Id from User limit 1];
            ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
            ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
            
            VehicleSingleController ctrl = new VehicleSingleController();
            
            ctrl.getRecords();
            
            ctrl.goBack();
            ctrl.showCheckoutPage();
            ctrl.showMoreVehicle();
            ctrl.setAssetIdToDtoClass();
            ctrl.save();
        Test.stopTest();
    }

    static testMethod void testGetCampaign()
    {
          Test.startTest();
        Map<Id, JUDAAN_Campaign__c> camp1 = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdList( new List<String>());
        Map<Id, JUDAAN_Campaign__c> camp2 = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdList( new List<String>(), 'jp');
        List<JUDAAN_Campaign__c> camp3 = JUDAAN_CampaignDao.getActiveCampaignByProductId('xxxxxxxxxxx');
        List<JUDAAN_Campaign__c> camp4 = JUDAAN_CampaignDao.getActiveCampaignByProductId( 'zzzzzzzzzz', 'jp');
        test.stopTest();
    }
    
    static testMethod void testmultipleCampaign() {
        
        Test.startTest();
            CreateTestData tdata = new CreateTestData();
            Asset ast = [select Id,Product2Id,ToLabel(Product2.BodyStyle_Alternative__c),ToLabel(Product2.Specification_Pack_Alternative__c),Product2.Registration_Year_Alternative__c  from Asset limit 1];
            tdata.createMaker();
            List<product2> pList = tdata.createProducts();
            tdata.createCampaign();
            List<JUDAAN_Campaign__c>  lstCampaign= [select Id,Body_Style__c,Specification_Pack_Alternative__c,model_year__c  from JUDAAN_Campaign__c limit 1];
        
            ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
            ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
            VehicleSingleController ctrl = new VehicleSingleController();
            ctrl.checkCampaign(ast, lstCampaign);
            
            lstCampaign[0].body_style__c = '5 DOOR SUV';
            lstCampaign[0].model_year__c = '2017';
            lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
            
            update lstCampaign[0];
            
            ctrl.checkCampaign(ast, lstCampaign);
            system.assert(lstCampaign[0].body_style__c == ast.Product2.BodyStyle_Alternative__c);
            
            lstCampaign[0].body_style__c = '';
            lstCampaign[0].model_year__c = '2017';
            lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
            
            update lstCampaign[0];
            
            ctrl.checkCampaign(ast, lstCampaign);
              system.assert(lstCampaign[0].Specification_Pack_Alternative__c == ast.Product2.Specification_Pack_Alternative__c);
            
            lstCampaign[0].body_style__c = '';
            lstCampaign[0].model_year__c = '';
            lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
            
            update lstCampaign[0];
            
            ctrl.checkCampaign(ast, lstCampaign);
            
            
             lstCampaign[0].body_style__c = '5 DOOR SUV';
            lstCampaign[0].model_year__c = '';
            lstCampaign[0].Specification_Pack_Alternative__c = 'HSE';
            
            update lstCampaign[0];
            
            ctrl.checkCampaign(ast, lstCampaign);
            
            lstCampaign[0].body_style__c = '5 DOOR SUV';
            lstCampaign[0].model_year__c = '2017';
            lstCampaign[0].Specification_Pack_Alternative__c = '';
            
            update lstCampaign[0];
            
            ctrl.checkCampaign(ast, lstCampaign);
            
            lstCampaign[0].body_style__c = '';
            lstCampaign[0].model_year__c = '2017';
            lstCampaign[0].Specification_Pack_Alternative__c = '';
            
            update lstCampaign[0];
            
            ctrl.checkCampaign(ast, lstCampaign);
            
            lstCampaign[0].body_style__c = '5 DOOR SUV';
            lstCampaign[0].model_year__c = '';
            lstCampaign[0].Specification_Pack_Alternative__c = '';
            ctrl.checkCampaign(ast, lstCampaign);
        
        Test.stopTest();
    }
    
}
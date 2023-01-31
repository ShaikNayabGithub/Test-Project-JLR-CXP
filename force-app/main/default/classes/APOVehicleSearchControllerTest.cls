/* *************************************************************************************************************    
Class Name    : APOVehicleSearchController
Description   : This class is used for testing functionality of APOVehicleSearchController 
CreatedDate   : 09 Mar 2018         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                

***************************************************************************************************************** */
@isTest
private class APOVehicleSearchControllerTest {

    Static List<Asset> assetList = new List<Asset>();
    Static User usr = new User();
    Static Saved_Vehicle_for_Lead__c savedVehLead = new Saved_Vehicle_for_Lead__c ();
  
    /* **************************************************
    Method Name: loadData
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to create test data
    //DJB - this doesn't need to be a testMethod - should be a testSetup method - and doesn't need any System.asserts
    ****************************************************** */  
    @testSetup static void loadData() {
        
        CreateTestData tdata = new CreateTestData();
        // Call load method for JUAAAN market Custom Settings
        tdata.loadJUDAANMarketSettingsData();
        
        Account acc = tdata.createPersonalAccount();
        insert acc;
        
        Lead leadRec = tdata.createLead(acc);
        insert leadRec;
        
        usr = tdata.createCustomerCommunityUser(acc);
        System.RunAs(new User(Id=userinfo.getUserId())){ 
            insert usr;
        }
        
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(); //why are we calling createAssets when we only want one Asset anyway?
        
        //Query inserted Assets
        assetList = [select id,Product2.Make__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset ];
        
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Product2.Model_Alternative__c='RANGE ROVER';
        assetList[0].highlighted_base__c = '"A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera"';
        AssetHandler.IgnoreMMIT = true;
        update assetList[0];
        
        Saved_Vehicle_for_Account__c savedVehAcc = tdata.createSavedVehicleForAccount( acc,assetList[0]);
        savedVehLead = tdata.createSavedVehicleForLead( leadRec, assetList[0]);  
        
        Id rtIDforModel = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        
        Id rtIDforDerivative = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        
        insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
        
    }
     
    /* **************************************************
    Method Name: testAPOsearchScenario
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to test search vehicle based on selected filter
    ****************************************************** */  
    static testMethod void testAPOsearchScenario() { 
        usr = [SELECT Id FROM User WHERE Email = 'testCommunityUser@jlr.com' LIMIT 1];
        assetList = [select id,Product2.Make__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Exterior_Colour__c,Interior_Color__c,highlighted_base__c from Asset ];
        List<Saved_Vehicle_for_Lead__c> savedVehLead = [Select Id, Saved_Vehicle__c from Saved_Vehicle_for_Lead__c where Saved_Vehicle__c=:assetList.get(0).Id];
        System.assertEquals(1,savedVehLead.size());
        List<Saved_Vehicle_for_Account__c > savedVehAcc = [Select Id, Saved_Vehicle__c from Saved_Vehicle_for_Account__c  where Saved_Vehicle__c=:assetList.get(0).Id];
        System.assertEquals(1,savedVehAcc.size());
        APOVehicleSearchBean bean = new APOVehicleSearchBean();
        bean.selectedMinPrice='21111';
        bean.selectedBodyStyles = new Set<String>();
        bean.selectedSpecifications = new Set<String>();
        bean.selectedTransmission = new Set<String>();
        bean.selectedFuel = new Set<String>();
        bean.selectedExteriorGroupColours =new Set<String>();
        bean.selectedInteriorColours = new Set<String>();
        bean.selectedMinModelYear ='2018';
        bean.selectedMaxModelYear ='2018';
        bean.selectedMinEngine ='';
        bean.selectedMaxEngine = '';
        bean.selectedEquipment =new Set<String>();
        bean.selectedModels2 = new Set<String>();
        bean.selectedMinMileage = '1200';
        bean.selectedMaxMileage = '2400';
        bean.selectedMaxPrice = '50000';
        bean.selectedMinAge = '2017';
        bean.selectedMaxAge = '2018';
        bean.selectedSortBy = '';
        bean.selectedLocation='Shinagawa';
        bean.selectedLocationDistance ='';
        bean.AddressForLocation =new List<String>();
        bean.SearchLocationFlag=false;
        
        System.runAs(usr){
            Test.startTest();
            APOVehicleSearchController ctrl = new APOVehicleSearchController();        
            ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
            ctrl.init();
            
            ApexPages.currentPage().getParameters().put( 'lang' , 'en' );        
            ApexPages.currentPage().getParameters().put( 'brand' , 'landrover' );
            ApexPages.currentPage().getParameters().put( 'id' , assetList.get(0).Id );
            ApexPages.currentPage().getParameters().put( 'assetid' , assetList.get(0).Id );
            ApexPages.currentPage().getParameters().put( 'index' , '9' );
            ApexPages.currentPage().getParameters().put( 'clearvar','price');
            system.assertEquals(null, ctrl.init());
            ApexPages.currentPage().getParameters().put( 'id',savedVehLead.get(0).id);
            APOVehicleSearchController.Vehiclewrapper wrapObj = new APOVehicleSearchController.Vehiclewrapper(assetList[0],false,false);
            ctrl.mobilesort ='false';
            ctrl.selectedfromAgeVal ='2013';
            ctrl.selectedtoAgeVal ='2018';
            ctrl.minprice ='20000';
            ctrl.maxprice ='40000';
            ctrl.minmileage= '2000'; 
            ctrl.maxmileage= '2000'; 
            ctrl.clearfilters = 'false';
            
            ctrl.selectedfromModelYear ='2013';
            ctrl.selectedtoModelYear ='2018';
            ctrl.selectedfromEngine ='XE';
            ctrl.selectedtoEngine ='XE';
            ctrl.sortbyvalue ='PRICE HIGH TO LOW';
            ctrl.paramValue ='2013';
            ctrl.showpanel = true;
            ctrl.agepanel = true;
            ctrl.pricepanel = true;
            ctrl.mileagepanel = true;
            ctrl.jaguarhero = true;
            ctrl.InLoadDetails = 'true';
            
            ctrl.LoadDetails();
            ctrl.setSelectedValues();
            ctrl.getSelectedValues();
            ctrl.ProcessSelected();
            ctrl.setDefaultSelectedValues();
            ctrl.showMore();
            
            System.assert(ctrl.showMore().getURL().contains('/apovehiclesingle'));
            
            ctrl.setAssetIdToDtoClass();
            
            ctrl.save();
            System.assert(ctrl.save().getURL().contains('/apovehiclesearch'));
            ctrl.getEquips('{"B28J":"Power Heated Door Mirrors","C11A":"Rear Parking Aid"}');
            //ctrl.getEquips('Rear View Camera,All wheel Drive');
            ctrl.checkSaved();
            ApexPages.currentPage().getParameters().put( 'assetId',savedVehLead.get(0).id);
            ctrl.removeAsset();
            System.assert(ctrl.removeAsset().getURL().contains('/apovehiclesearch'));
            ctrl.reset();
            System.assertEquals(ctrl.reset(), null);
        }
        Test.stopTest();
        
    }
    
    static testMethod void testAPOsearchScenarioMobileSort() {
        
        usr = [SELECT Id FROM User WHERE Email = 'testCommunityUser@jlr.com' LIMIT 1];
        assetList = [select id,Product2.Make__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Exterior_Colour__c,Interior_Color__c,highlighted_base__c from Asset ];
        List<Saved_Vehicle_for_Lead__c> savedVehLead = [Select Id, Saved_Vehicle__c from Saved_Vehicle_for_Lead__c where Saved_Vehicle__c=:assetList.get(0).Id];
        System.assertEquals(1,savedVehLead.size());
        
        List<Saved_Vehicle_for_Account__c > savedVehAcc = [Select Id, Saved_Vehicle__c from Saved_Vehicle_for_Account__c  where Saved_Vehicle__c=:assetList.get(0).Id];
        System.assertEquals(1,savedVehAcc.size());
        
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'id' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'index' , '9' );
        ApexPages.currentPage().getParameters().put( 'clearvar','price');
        
        System.debug('assetList.get(0).Id '+assetList.get(0).Id );
        Test.startTest();
            APOVehicleSearchController ctrl = new APOVehicleSearchController();
            APOVehicleSearchController.Vehiclewrapper wrapObj = new APOVehicleSearchController.Vehiclewrapper(assetList[0],false,true);
            ctrl.mobilesort ='true';
            ctrl.selectedfromAgeVal ='2013';
            ctrl.selectedtoAgeVal ='2018';
            ctrl.minprice ='20000';
            ctrl.maxprice ='40000';
            ctrl.minmileage= '2000'; 
            ctrl.maxmileage= '2000'; 
            ctrl.clearfilters = 'false';
            
            ctrl.selectedfromModelYear ='2013';
            ctrl.selectedtoModelYear ='2018';
            ctrl.selectedfromEngine ='XE';
            ctrl.selectedtoEngine ='XE';
            ctrl.sortbyvalue ='PRICE HIGH TO LOW';
            ctrl.paramValue ='2013';
            ctrl.showpanel = true;
            ctrl.agepanel = true;
            ctrl.pricepanel = true;
            ctrl.mileagepanel = true;
            ctrl.jaguarhero = true;
            ctrl.InLoadDetails = 'true';
            
            System.runAs(usr){
                ctrl.LoadDetails();
                ctrl.setSelectedValues();
                ctrl.getSelectedValues();
                ctrl.ProcessSelected();
                ctrl.showMore();
                System.assert(ctrl.showMore().getURL().contains('/apovehiclesingle'));
                ctrl.setAssetIdToDtoClass();
                ctrl.save();
                System.assert(ctrl.save().getURL().contains('/apovehiclesearch'));
                Set<String> equipSet =  ctrl.getEquips('{"B28J":"Power Heated Door Mirrors","C11A":"Rear Parking Aid"}');
                System.assertEquals(2, equipSet.size());
                ctrl.checkSaved();
                ApexPages.currentPage().getParameters().put( 'assetId',savedVehLead.get(0).id); 
                ctrl.removeAsset();
                System.assert(ctrl.removeAsset().getURL().contains('/apovehiclesearch'));
                ctrl.reset();
                System.assertEquals(ctrl.reset(), null);
            }
        Test.stopTest();
    }
    
    /* **************************************************
    Method Name: testAPOsearchAdvance
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to test search vehicle on advanced section 
    ****************************************************** */  
    static testMethod void testAPOsearchAdvance() {
        
        usr = [SELECT Id FROM User WHERE Email = 'testCommunityUser@jlr.com' LIMIT 1];
        assetList = [select id,Product2.Make__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,Exterior_Colour__c, highlighted_local__c ,highlighted_base__c from Asset ];
    
        insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
        ApexPages.currentPage().getParameters().put( 'lang' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'id' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'index' , '1' );
        ApexPages.currentPage().getParameters().put( 'selectedValues' , 'XE' );
        ApexPages.currentPage().getParameters().put( 'clearvar','advance');
        
        System.debug('assetList.get(0).Id '+assetList.get(0).Id );
        Test.startTest();
            APOVehicleSearchController ctrl = new APOVehicleSearchController();
            APOVehicleSearchController.Vehiclewrapper wrapObj = new APOVehicleSearchController.Vehiclewrapper(assetList[0],false,false);
            System.runAs(usr){
                ctrl.LoadMore();
                System.assert(ctrl.isLoaded == true);
                ctrl.getSelectedValues();
                Set<String> equipSet = ctrl.getEquips(assetList[0].highlighted_base__c);
                System.assertEquals(equipSet.size(),2);
                ctrl.LoadPrice();
                ctrl.clear();
                System.assert(ctrl.dynamicLoad == '1'); 
                ctrl.reset();
                System.assertEquals(ctrl.reset(), null); 
            }
        Test.stopTest();
        
    }
     /* **************************************************
    Method Name: testClearFilters
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to test clear all filters 
    ****************************************************** */  
    static testMethod void testClearFilters() {
        usr = [SELECT Id FROM User WHERE Email = 'testCommunityUser@jlr.com' LIMIT 1];
        assetList = [select id,Product2.Make__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Exterior_Colour__c,Interior_Color__c,highlighted_base__c,highlighted_local__c from Asset ];
        ApexPages.currentPage().getParameters().put( 'lang' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'id' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'index' , '1' );
        ApexPages.currentPage().getParameters().put( 'selectedValues' , 'XE' );
        ApexPages.currentPage().getParameters().put( 'clearvar','advance');
        
        System.debug('assetList.get(0).Id '+assetList.get(0).Id );
        Test.startTest();
            insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
            APOVehicleSearchController ctrl = new APOVehicleSearchController();
            APOVehicleSearchController.Vehiclewrapper wrapObj = new APOVehicleSearchController.Vehiclewrapper(assetList[0],false,false);
            System.runAs(usr){
                ctrl.clearfilters = 'true';
                ctrl.LoadDetails();
                ctrl.LoadPrice();
                ctrl.clear();
                System.assert(ctrl.dynamicLoad == '1'); 
                ctrl.reset();
                System.assertEquals(ctrl.reset(), null);  
            }
        Test.stopTest();
    }
    
    static testMethod void testCreateLead() { 
        
        //Query inserted Assets
        assetList = [select id,Product2.Make__c,APO_Display__c,Account.RecordType.DeveloperName,Registration_Number__c,Order_Number__c,Name,Brand__c,Product2Id,Mileage__c,Price_Retail__c,Account.Dealer_CI_Code__c,Account.Dealer_CI_Code_2__c,APO_Stock_Status__c,Approved_On_Udaan__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,Local_price__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Exterior_Colour__c,Product2.APO_Body_Style_Alternative__c,Interior_Color__c,highlighted_base__c from Asset ];
        
        assetList[0].APO__c = true;
        assetList[0].Approved_On_Udaan__c = true ;
        assetList[0].Product2.Make__r.Name = 'jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Product2.Model_Alternative__c='RANGE ROVER';
        // update assetList[0];
        system.debug('----assetList[0]'+assetList[0].product2);
        system.debug('----assetListmarket'+assetList[0].Product2.Make__r.Name);
        system.debug('----assetList[0]----'+assetList[0]);
        Test.startTest();
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        
        APOVehicleSearchController ctrl = new APOVehicleSearchController();
        ctrl.LoadDetails();
        ApexPages.currentPage().getParameters().put('assetId', assetList.get(0).Id);
        delete [select id from lead limit 1];
        ctrl.save();
        
        Test.stopTest();
        //DJB - there is no test running here?!
    }
    
    static testMethod void testOpportunityDAO() {
        List<Opportunity> quotes = OpportunityDAO.getSaveQuotes('xxxxxxxxxx', 'jaguar');
        List<Opportunity> reserves = OpportunityDAO.getReserve('zzzzzzzzzz', 'jaguar');
        system.assertEquals(0, quotes.size());
        system.assertEquals(0, reserves.size());
    }
    
    /*static testMethod void testSavedVehicleDAO() {
        List<Saved_Vehicle_for_Account__c>  saved4Acc = SavedVehicleDAO.getSavedVehicleForAccountByAccountId('xxxxxxxxxx', 'jaguar');
        List<Saved_Vehicle_for_Lead__c> saved4Lead = SavedVehicleDAO.getSavedVehicleForLeadByAccountId('xxxxxxxxxx', 'jaguar');
        
        system.assertEquals(0, saved4Acc.size());
        system.assertEquals(0, saved4Lead.size());
    }*/
    //start
    static testMethod void testAPOAdvance() {
        
        usr = [SELECT Id FROM User WHERE Email = 'testCommunityUser@jlr.com' LIMIT 1];
        assetList = [select id,Product2.Make__c,Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Exterior_Colour__c,Interior_Color__c,highlighted_base__c,highlighted_local__c from Asset ];
 
        Test.startTest();
        ApexPages.currentPage().getParameters().put( 'lang' , 'jp' );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        ApexPages.currentPage().getParameters().put( 'id' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'index' , '1' );
        ApexPages.currentPage().getParameters().put( 'selectedValues' , 'XE' );
        ApexPages.currentPage().getParameters().put( 'clearvar','advance');
        ApexPages.currentPage().getParameters().put( 'brand','landrover');
        ApexPages.currentPage().getParameters().put( 'mobilesort','true');
        ApexPages.currentPage().getParameters().put( 'id1','02i0E000000OXXO');
        ApexPages.currentPage().getParameters().put( 'id2','02i0E000000OXXO');
        ApexPages.currentPage().getParameters().put( 'id3','02i0E000000OXXO');
        ApexPages.currentPage().getParameters().put( 'id','02i0E000000OXXO');
        String NodeStr = '["02i0E000000OXXO","02i0E000000OXXO","02i0E000000OXXO"]';
        NodeStr = String.valueOf(NodeStr);
        System.debug('assetList.get(0).Id '+assetList.get(0).Id );
        
        insert new JUDAANMarketSettings__c(Name='jp',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
        APOVehicleSearchController ctrl = new APOVehicleSearchController();
        APOVehicleSearchController.Vehiclewrapper wrapObj = new APOVehicleSearchController.Vehiclewrapper(assetList[0],false,false);
        
        System.runAs(usr){
            ctrl.LoadMore();
            ctrl.setSelectedValues();
            ctrl.getSelectedValues();
            Set<String> equipSet = ctrl.getEquips(assetList[0].highlighted_base__c);
            ctrl.LoadPrice();
            ctrl.clear();
            ctrl.reset();
            ctrl.LocationStr='["A60R","Rear Wheel Drive","C14A","Reverse Parking Camera"]';
            ctrl.checkboxval='test';
            ctrl.selectedVal='test';
            ctrl.selectedmileage='test';
            ctrl.clear='test';
            ctrl.CompareStrtoShow='test';
            ctrl.hasLocation=true;
            ctrl.Models2='test';
            ctrl.setDefaultSelectedValues();
            ctrl.selectfinal=true;
            ctrl.assetToShow();
            System.assert(ctrl.AddressForAccount != null);
            ctrl.CompareStrtoShow ='test';
            ctrl.CompareData();
            System.assert(ctrl.CompareData().getURL().contains('/apovehiclecompare'));
            ctrl.setAssetIdToDtoClass();
            ctrl.loadModels();
            ctrl.loadAge();
            ctrl.getSelectedCompare(NodeStr,ApexPages.currentPage());
            System.assert(ApexPages.currentPage().getParameters().get('id1') != null);
        }
        Test.stopTest();
    }
}
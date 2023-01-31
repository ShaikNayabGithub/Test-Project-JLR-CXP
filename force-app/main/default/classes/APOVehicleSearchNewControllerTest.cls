@isTest
private class APOVehicleSearchNewControllerTest {

    static testMethod void testScrollVehicleList() {
        
        
        CreateTestData tdata = new CreateTestData();
        tdata.loadJUDAANMarketSettingsData();
        String market = 'JP';
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        //for(Integer i=0; i<10; i++){
        tdata.createAssets();
        //}
        
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
        
        List<Asset> assetList = [select id,APO__c ,Model__c,highlighted_base__c ,Product2.Make__r.Name,Account.Country_ISO_Code__c,Product2.Model_Alternative__c from Asset ];
        assetList[0].APO__c = true;
        //assetList[0].Approved_On_Udaan__c = true ;
        assetList[0].Product2.Make__r.Name = 'jaguar';
        assetList[0].Account.Country_ISO_Code__c ='JP';
        assetList[0].Product2.Model_Alternative__c='RANGE ROVER';
        assetList[0].highlighted_base__c = '"A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera"';
        AssetHandler.IgnoreMMIT = true;
        update assetList[0];
        System.assertEquals(1,assetList.size() );
        
        ApexPages.currentPage().getParameters().put( 'market' , 'jp');
        ApexPages.currentPage().getParameters().put( 'model' , 'XE');
         ApexPages.currentPage().getParameters().put( 'isAPO' , 'true');
        
        APOVehicleSearchNewController      ctrl = new APOVehicleSearchNewController    ();
        Test.startTest();
        ctrl.dispatch();
        //ctrl.setStateValues();
        ctrl.loadAllVehicleData();
        
        ctrl.wrapClassList[0].flag = true;
        //ctrl.wrapClassList[0].modelLst[0].flag = true;
        ctrl.processSelected();
                ctrl.getLocalPriceList();
           ctrl.getMonthlyPriceList();
           ctrl.getRegYearList(); 
           ctrl.getmileagePriceList();     
        
        //ctrl.wrapClassList;
        system.debug('---lstWrap'+ctrl.wrapClassList);
        
         Test.stopTest();
        
        
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
       
        System.assertEquals(1,ctrl.bean.vehicleCount);  
        System.assert( ctrl.bean.vehicles == null );   
        
        
        
        ctrl.selectedmodel = 'DISCOVERY';
        ctrl.loadvehicleSearch();
        
        
        ctrl.start = 10;
        ctrl.index = 10;
        ctrl.previous();
        ctrl.restartSearch();
        System.assertEquals(IntegerUtil.getValue(null),IntegerUtil.getValue(0)); 
    }

   
      static testMethod void testpaginationprevList() {
        
        
        CreateTestData tdata = new CreateTestData();
        tdata.loadJUDAANMarketSettingsData();
        String market = 'JP';
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        //for(Integer i=0; i<10; i++){
        tdata.createAssets(market);
        //}
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
        
        List<Asset> assetList = [select id,APO__c ,highlighted_base__c ,Product2.Make__r.Name,Account.Country_ISO_Code__c,Product2.Model_Alternative__c from Asset ];
        assetList[0].APO__c = true;
        //assetList[0].Approved_On_Udaan__c = true ;
        assetList[0].Product2.Make__r.Name = 'jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Product2.Model_Alternative__c='RANGE ROVER';
        assetList[0].highlighted_base__c = '"A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera"';
        AssetHandler.IgnoreMMIT = true;
        update assetList[0];
        System.assertEquals(1,assetList.size() );
        
        ApexPages.currentPage().getParameters().put( 'market' , 'jp');
           ApexPages.currentPage().getParameters().put( 'isAPO' , 'true');
        APOVehicleSearchNewController      ctrl = new APOVehicleSearchNewController  ();
        
        ctrl.dispatch();
        ctrl.getStateValues();
        ctrl.setStateValues();
        
        ctrl.setStateValuesBR();
        ctrl.loadAllVehicleData();

        ctrl.wrapClassList[0].flag = true;
     
        ctrl.processSelected();
       
        System.assertEquals(IntegerUtil.getValue(null),IntegerUtil.getValue(0)); 
        ctrl.selectedmodel = 'DISCOVERY';
        ctrl.loadvehicleSearch();
        
        
        if(ctrl.bean.vehicles != null && ctrl.bean.vehicles.size()>0 )
        {
            for(VehicleSearchBean.vehicle tmp : ctrl.bean.vehicles){
                system.debug('---tmp '+tmp );
                testmultipleCampaign(tmp);
            }
            
        }
        
        
        ctrl.start = 10;
        ctrl.index = 10;
        ctrl.previous();
        
        
        ctrl.start = -10;
        ctrl.index = 10;
        ctrl.next();
        
        
    }
    
    
       static testMethod void testcampaignList() {
        
        
        CreateTestData tdata = new CreateTestData();
        tdata.loadJUDAANMarketSettingsData();
        String market = 'JP';
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        //for(Integer i=0; i<10; i++){
        tdata.createAssets(market);
        //}
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
        
       List<Asset> assetList = [select id,APO__c ,Model__c,highlighted_base__c ,Product2.Make__r.Name,Account.Country_ISO_Code__c,Product2.Model_Alternative__c from Asset ];
        assetList[0].APO__c = true;
        //assetList[0].Approved_On_Udaan__c = true ;
        assetList[0].Product2.Make__r.Name = 'jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Product2.Model_Alternative__c='RANGE ROVER';
        assetList[0].highlighted_base__c = '"A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera"';
        AssetHandler.IgnoreMMIT = true;
        update assetList[0];
        System.assertEquals(1,assetList.size() );
        
        tdata.createCampaign(assetList[0].model__c);
                
                 
                List<JUDAAN_Campaign__c>  lstCampaign1 =  [Select Id,recordTypeId,Market__c  from JUDAAN_Campaign__c  limit 1]; 
                lstCampaign1[0].Market__c   = 'jp';
                lstCampaign1[0].VIN_Asset_Level_ID__c  =  assetList[0].id ;
                lstCampaign1[0].VIN_Level_Campaign_Text__c = 'Test';
                
                update lstCampaign1;
                system.debug('--111tmp.lstCampaign1'+lstCampaign1);
        
        ApexPages.currentPage().getParameters().put( 'market' , 'jp');
        ApexPages.currentPage().getParameters().put( 'isNew' , 'false');
        ApexPages.currentPage().getParameters().put( 'isAPO' , 'true');
        
        APOVehicleSearchNewController      ctrl = new APOVehicleSearchNewController  ();
        
        ctrl.dispatch();
        ctrl.setStateValues();
        ctrl.loadAllVehicleData();

        ctrl.wrapClassList[0].flag = true;
        ctrl.processSelected();
        ctrl.switch();
        System.assertEquals(IntegerUtil.getValue(null),IntegerUtil.getValue(0)); 
        
        ApexPages.currentPage().getParameters().put( 'isNew' , 'true');
        ctrl.tabSelected();

        ctrl.selectedmodel = 'DISCOVERY';
        ctrl.loadvehicleSearch();
        ctrl.dispatchlanding();
        ctrl.loadmodels();
         
       
               
                
               // testmultipleCampaign(ctrl.bean.vehicles[0]);
          
            //ApexPages.currentPage().getParameters().put( 'modelname' , tmp.modelname );
            //ApexPages.currentPage().getParameters().put( 'specialmodel' , 'special' );
        
        
        
        if(ctrl.bean.vehicles != null ){
            for(VehicleSearchBean.vehicle tmp : ctrl.bean.vehicles){
                //assetId  = ctrl.bean.vehicles.get(0).vehicleId;  
                system.debug('---tmp.productid'+tmp.productid);
                tdata.createCampaign(tmp.productid);
                
                 
                List<JUDAAN_Campaign__c>  lstCampaign =  [Select Id,recordTypeId,Market__c  from JUDAAN_Campaign__c  limit 1]; 
                lstCampaign[0].Market__c   = 'jp';
                lstCampaign[0].VIN_Asset_Level_ID__c  =  assetList[0].id ;
                lstCampaign[0].VIN_Level_Campaign_Text__c = 'Test';
                
                update lstCampaign;
                 system.debug('---tmp.lstCampaign'+lstCampaign);
                //tdata.createCampaign(tmp.productid); 
                testmultipleCampaign(tmp);
            }
        }
        
        
       
        
        
    }


    private static void testmultipleCampaign(VehicleSearchBean.Vehicle ast)
    {
        
        APOVehicleSearchNewController      ctrl = new APOVehicleSearchNewController  ();
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


    
}
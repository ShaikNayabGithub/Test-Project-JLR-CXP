@isTest
public class HeaderComponentController_Test {
    //Public String brandvalue= 'jaguar';
    
    static testMethod void HeaderController1() {
        // Call load method for JUAAAN market Custom Settings
        //CreateTestData.loadJUDAANMarketSettingsData();
        
        Test.startTest();
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.loadJUDAANMarketSettingsData();
        List<Asset> assets = tdata.createAssets();
        
        List<Asset> assetList = [Select Id from Asset where id =:assets[0].id];
        System.assertEquals(1,assetList.size());
        
        Test.stopTest();
        PageReference pageRef = Page.CustomerAccountPage;
        //pageRef.getParameters().put('brand', 'jaguar');
        //pageRef.getParameters().put('lang', 'en');
        pageRef.getParameters().put('market', 'jp');
        pageRef.getParameters().put('id', assets.get(0).Id );
        pageRef.getParameters().put('vid', assets.get(0).Id );
        pageRef.getParameters().put('svid', assets.get(0).Id );
        Test.setCurrentPage(pageRef);
        
        HeaderComponentController header = new HeaderComponentController();
        header.dto = new CreateSavedVehicleDto();
        header.APOSwitch();
        System.assert(header.APOSwitch().getURL().contains('/VehicleSearch'));
        header.goVehicleSearchPage();
        System.assert(header.APOSwitch().getURL().contains('/VehicleSearch'));
        header.changeLanguage();
        System.assert(header.changeLanguage().getURL().contains('en'));
        header.brandSwitch(); 
        System.assert(header.brandSwitch().getURL().contains('jaguar'));
        header.mainSite();
        System.assert(header.mainSite().getURL().contains('landrover.co'));
        header.setImplClassToDto();
        header.goAccountPage();
        System.assert(header.brandSwitch().getURL().contains('/customeraccountpage'));
        header.comment = 'test comment';
        header.submitFeedback();
        System.assert(header.isFeedbackSaved == 'true');
        
        header.saveAccountDetails();
    }
    
    static testMethod void HeaderController2() {
        // Call load method for JUAAAN market Custom Settings
        //CreateTestData.loadJUDAANMarketSettingsData();
        
        Test.startTest();
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.loadJUDAANMarketSettingsData();
        List<Asset> assets = tdata.createAssets();
        
        List<Asset> assetList = [Select Id,APO__c from Asset where id =:assets[0].id];
        System.assertEquals(1,assetList.size());
        
        
        PageReference pageRef = Page.CustomerAccountPage;
        pageRef.getParameters().put('brand', 'Land Rover');
        pageRef.getParameters().put('lang', 'jp');
        pageRef.getParameters().put('market', 'sg');
        pageRef.getParameters().put('id', assets.get(0).Id );
        pageRef.getParameters().put('vid', assets.get(0).Id );
        pageRef.getParameters().put('svid', assets.get(0).Id );
        pageRef.getParameters().put('id1', assets.get(0).Id );
        pageRef.getParameters().put('id2', assets.get(0).Id );
        pageRef.getParameters().put('id3', assets.get(0).Id );
        Test.setCurrentPage(pageRef);
        
        HeaderComponentController header = new HeaderComponentController();
        header.dto = new CreateSavedVehicleDto();
        header.goVehicleSearchPage();
        System.assert(header.APOSwitch().getURL().contains('/VehicleSearch'));
        header.changeLanguage();
        System.assert(header.changeLanguage().getURL().contains('en'));
        header.brandSwitch(); 
        System.assert(header.brandSwitch().getURL().contains('jaguar'));
        header.mainSite();
        System.assert(header.mainSite().getURL().contains('landrover.co'));
        header.setImplClassToDto();
        header.goAccountPage();
        System.assert(header.brandSwitch().getURL().contains('/customeraccountpage'));
        header.submitFeedback();
        System.assert(header.isCommentBlank == 'true');
        header.emailOptedOut = false;
        header.getSubmittedFeedback();
        header.saveAccountDetails();
        Test.stopTest();
    }
    
    static testMethod void HeaderController3() {
        // Call load method for JUAAAN market Custom Settings
        
        Test.startTest();
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.loadJUDAANMarketSettingsData();
        List<Asset> assets = tdata.createAssets();
        
        List<Asset> assetList = [Select Id,APO__c from Asset where id =:assets[0].id];
        System.assertEquals(1,assetList.size());
        
        
        PageReference pageRef = Page.CustomerAccountPage;
        pageRef.getParameters().put('brand', 'Land Rover');
        pageRef.getParameters().put('lang', 'en');
        pageRef.getParameters().put('market', 'th');
        pageRef.getParameters().put('id', assets.get(0).Id );
        Test.setCurrentPage(pageRef);
        
        HeaderComponentController header = new HeaderComponentController();
        header.getVehicleTypes();
        header.selectedVehicleType = 'VehicleSearch';
        header.getVehicleTypeSwitch();
        header.switchVehicleTypePage();
        Test.stopTest();
    }

}
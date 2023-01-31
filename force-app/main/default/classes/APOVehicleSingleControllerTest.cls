/* *************************************************************************************************************    
Class Name    : APOVehicleSingleControllerTest
Description   : Class is used for testing functionality of APOVehicleSingleController.cls. 
CreatedDate   : 07 Mar 2018         
Version       : 1.0     
Author        : TCS
***************************************************************************************************************** */
@isTest(SeeAllData = false)
private class APOVehicleSingleControllerTest {
    
    
    @testSetup static void createData()
    {
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createCampaign();
        tdata.loadJUDAANMarketSettingsData();
        List<Asset> assets = tdata.createAssets();
        Account acc = tdata.createPersonalAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        insert acc;
        //system.debug('---new acc id:' + acc.Id);
        Lead ld = tdata.createLead(acc); 
        try{
        insert ld;
        //system.debug('---new lead id:' + ld.Id);
            }catch(Exception ex)
                {
                    system.debug('--ex:' + ex.getMessage());
                }
        User u = tdata.createCustomerCommunityUser(acc);
        try{
            User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
                        System.runAs(usrAdmin) {
        insert u;
            }
        }catch(Exception e)
            {
                system.debug('---exx:' + e.getMessage());
            }

        tdata.createSavedVehicleForAccount(acc, assets[0]);
        tdata.createSavedVehicleForLead(ld, assets[0]);
    }
    
    static testMethod void testExecute() {
        
        Asset ast = [select Id from Asset limit 1];
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        //system.debug('---ast:' + ast);
        //system.debug('---RecordType: ' + rtypeId);
        
        Account acc = [select Id from Account where RecordTypeId = :rtypeId limit 1];
        //system.debug('---acc:' + acc);
        //system.debug('---lead:' + [select Id from lead where Account__c = :acc.Id limit 1]);
        //User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
        //system.debug('---running user:' + [select Id, Email, Contact.AccountId from User where Contact.AccountId = :acc.Id limit 1].Contact.AccountId);
        User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
        Test.startTest();
        
        //ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
        ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        insert new JUDAANMarketSettings__c(Name='jp',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
        
        
        System.runAs(u){
            APOVehicleSingleController ctrl = new APOVehicleSingleController();
            ctrl.getRecords();
    
            ctrl.goBack();
            System.assert(ctrl.goBack().getURL().contains('/apovehiclesearch'));
            ctrl.showCheckoutPage();
            System.assert(ctrl.showCheckoutPage().getURL().contains('/checkout'));
            ctrl.showMoreVehicle();
            System.assert(ctrl.showMoreVehicle().getURL().contains('/apovehiclesingle'));
            ctrl.setAssetIdToDtoClass();
            ctrl.setAssetVehicleToDtoClass();
            ctrl.save();
            System.assert(ctrl.save().getURL().contains('/apovehiclesingle'));
        }
        Test.stopTest();
        
    }
    
   
    static testMethod void getCampaignTest(){
        CreateTestData tdata = new CreateTestData();
        tdata.createMaker();
        List<product2> pList = tdata.createProducts();
        tdata.createCampaign();
        string mark='jp';

        Asset ast = [select Id from Asset limit 1];
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        //system.debug('---ast:' + ast);
        
        Account acc = [select Id from Account where RecordTypeId = :rtypeId limit 1];
        //system.debug('---acc:' + acc);
        //system.debug('---lead:' + [select Id from lead where Account__c = :acc.Id limit 1]);
        //User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
        //system.debug('---running user:' + [select Id, Email, Contact.AccountId from User where Contact.AccountId = :acc.Id limit 1].Contact.AccountId);
        User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
        Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
        JUDAAN_Campaign__c objCampaign = new JUDAAN_Campaign__c(Product__c = pList.get(0).Model__c,StartDate__c = system.today(),EndDate__c = system.today(),Market__c =mark,RecordTypeId = campaignRecordTypeId);
        insert objCampaign;
        Test.startTest();
        insert new JUDAANMarketSettings__c(Name='jp',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy',JG_Cname__c = 'https://osadev-retailers.cs107.force.com/Udaan?brand=jaguar&market=jp',LR_Cname__c ='https://osadev-retailers.cs107.force.com/Udaan?brand=landrover&market=jp');
        //User u = [select Id from User limit 1];
        
        //Asset ast = [select Id from Asset limit 1];
        if(ast!=null){
            ast.Features_Base__c = '{ "A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera" }';
            update ast;
        }
        ApexPages.currentPage().getParameters().put( 'lang' , 'jp' );
        ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        
        System.runAs(u){
            APOVehicleSingleController ctrl = new APOVehicleSingleController();
            ctrl.getCampaign(pList.get(0).Model__c ,mark );
            System.assert(ctrl.getCampaign(pList.get(0).Model__c ,mark ) != null);
            ctrl.objcase.description ='Test';
            ctrl.objcase.type='General Enquiry';
            ctrl.isEmail =true;
            ctrl.isSMS =true;
            ctrl.isPhone =true;
            ctrl.saveEnquiryform();
            ctrl.removeAsset(); 
            System.assert(ctrl.removeAsset().getURL().contains('/apovehiclesingle'));
             Set<String> featureSet= ctrl.getFeatures(ast.Features_Base__c);
        }
        Test.stopTest();
        
    }
    
    //start
    static testMethod void getCampaignTest1(){
        CreateTestData tdata = new CreateTestData();
        tdata.createMaker();
        List<product2> pList = tdata.createProducts();
        tdata.createCampaign();
        string mark='sg';

        Asset ast = [select Id from Asset limit 1];
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        //system.debug('---ast:' + ast);
        
        Account acc = [select Id from Account where RecordTypeId = :rtypeId limit 1];
        //system.debug('---acc:' + acc);
        //system.debug('---lead:' + [select Id from lead where Account__c = :acc.Id limit 1]);
        //User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
        //system.debug('---running user:' + [select Id, Email, Contact.AccountId from User where Contact.AccountId = :acc.Id limit 1].Contact.AccountId);
        User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
        Test.startTest();
        insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy');
         Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
        JUDAAN_Campaign__c objCampaign = new JUDAAN_Campaign__c(Product__c = pList.get(0).Model__c,StartDate__c = system.today(),EndDate__c = system.today(),Market__c =mark,RecordTypeId = campaignRecordTypeId);
        insert objCampaign;
        //User u = [select Id from User limit 1];
        
        //Asset ast = [select Id from Asset limit 1];
        if(ast!=null){
            ast.Features_Base__c = '{ "A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera" }';
            update ast;
        }
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
         ApexPages.currentPage().getParameters().put( 'brand' , 'landrover' );
        
        System.runAs(u){
            APOVehicleSingleController ctrl = new APOVehicleSingleController();
            ctrl.showMoreVehicle();
            System.assert(ctrl.showMoreVehicle().getURL().contains('/apovehiclesingle'));
            ctrl.getCampaign(pList.get(0).id ,mark );
            System.assert(ctrl.getCampaign(pList.get(0).Model__c ,mark )!=null);
            ctrl.getRecords();
            ctrl.availability='test';
            ctrl.showCheckoutPage();
            System.assert(ctrl.showCheckoutPage().getURL().contains('/sgcheckout'));
            ctrl.removeAsset(); 
            System.assert(ctrl.removeAsset().getURL().contains('/apovehiclesingle'));
             Set<String> featureSet= ctrl.getFeatures(ast.Features_Base__c);
        }
        Test.stopTest();
        
    }
    //end
     
    
}
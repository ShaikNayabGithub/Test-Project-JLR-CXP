/* *************************************************************************************************************    
Class Name    : APOVehicleCompareController
Description   : This class is used for testing functionality of APOVehicleCompareController 
CreatedDate   : 03 July 2018         
Version       : 1.0     
Author        : TCS Japan
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                

***************************************************************************************************************** */
@isTest
private class APOVehicleCompareControllerTest {
     @testSetup static void createData()
    {
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createCampaign();
        tdata.loadJUDAANMarketSettingsData();
        List<Asset> assets = tdata.createAssets();
        for(Asset ast : assets){
            ast.Features_Base__c = '{ "A60R":"Rear Wheel Drive","C14A":"Reverse Parking Camera" }';
        }
        update assets;
        Test.startTest();
        Account acc = tdata.createPersonalAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        insert acc;
        system.debug('---new acc id:' + acc.Id);
        Lead ld = tdata.createLead(acc); 
        try{
        insert ld;
        system.debug('---new lead id:' + ld.Id);
            }catch(Exception ex)
                {
                    system.debug('--ex:' + ex.getMessage());
                }
        Test.stopTest();
        User u = tdata.createCustomerCommunityUser(acc);
        try{
            User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
                        System.runAs(usrAdmin) {
        insert u;
                        }
            }
        catch(Exception e)
            {
                system.debug('---exx:' + e.getMessage());
            }

        tdata.createSavedVehicleForAccount(acc, assets[0]);
        tdata.createSavedVehicleForLead(ld, assets[0]);
    }
    /***************************************************
    Method Name: testAPOCompareScenario1
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to test Compare vehicle based on selection
    *******************************************************/  
    static testMethod void testAPOCompareScenario1() {
        //CreateTestData tdata = new CreateTestData();
      Test.startTest();
        Asset ast = [select Id,Product2.APO_Body_Style_Alternative__c from Asset limit 1];
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        system.debug('---ast:' + ast);
        
        Account acc = [select Id from Account where RecordTypeId = :rtypeId limit 1];
        system.debug('---acc:' + acc);
        //system.debug('---lead:' + [select Id from lead where Account__c = :acc.Id limit 1]);
        //system.debug('---running user:' + [select Id, Email, Contact.AccountId from User where Contact.AccountId = :acc.Id limit 1].Contact.AccountId);
        User usr = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
    insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy');
        System.runAs(usr){
            PageReference pageRef = Page.APOVehicleCompare;
            Test.setCurrentPage(pageRef);        
            ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
            ApexPages.currentPage().getParameters().put( 'lang' , 'jp' );        
            ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
            ApexPages.currentPage().getParameters().put( 'id1' , ast.Id );
            //ApexPages.currentPage().getParameters().put( 'id2' , assetForCompare.Id );
            ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
            APOVehicleCompareController ctrl = new APOVehicleCompareController();
            ctrl.LoadCompareData();
      System.assertEquals(ctrl.bodystyle1, ast.Product2.APO_Body_Style_Alternative__c);
            ctrl.goBack();
      System.assert(ctrl.goBack().getURL().contains('/apovehiclesearch'));
            ctrl.showMore();
      System.assert(ctrl.showMore().getURL().contains('/apovehiclesingle'));

        }
        Test.StopTest();

    }
    /***************************************************
    Method Name: testAPOCompareScenario2
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to test Compare vehicle based on selection
    *******************************************************/  
    static testMethod void testAPOCompareScenario2() {
        //CreateTestData tdata = new CreateTestData();
    Test.startTest();
        Asset ast = [select Id,Product2.APO_Body_Style_Alternative__c from Asset limit 1];
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        system.debug('---ast:' + ast);
        
        Account acc = [select Id from Account where RecordTypeId = :rtypeId limit 1];
        system.debug('---acc:' + acc);
        //system.debug('---lead:' + [select Id from lead where Account__c = :acc.Id limit 1]);
        //system.debug('---running user:' + [select Id, Email, Contact.AccountId from User where Contact.AccountId = :acc.Id limit 1].Contact.AccountId);
        User usr = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];
         insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy');

        System.runAs(usr){
            PageReference pageRef = Page.APOVehicleCompare;
            Test.setCurrentPage(pageRef);        
            ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
            //ApexPages.currentPage().getParameters().put( 'lang' , 'en' );        
            ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
            ApexPages.currentPage().getParameters().put( 'id2' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'id3' , ast.Id );
            ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
            APOVehicleCompareController ctrl = new APOVehicleCompareController();
            ctrl.LoadCompareData();
      System.assertEquals(ctrl.bodystyle2, ast.Product2.APO_Body_Style_Alternative__c);
            System.assertEquals(ctrl.bodystyle3, ast.Product2.APO_Body_Style_Alternative__c);
            ctrl.goBack();
      System.assert(ctrl.goBack().getURL().contains('/apovehiclesearch'));
            ctrl.showMore();
      System.assert(ctrl.showMore().getURL().contains('/apovehiclesingle'));
            String languageVal= ctrl.getLanguage();
      System.assertEquals(null, languageVal);

        }
        Test.StopTest();

    }

}
@isTest(seeAllData=false)
public class Batch_CVoiceRDAExport_Test {
    
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id onSellRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    
    static testmethod void testPurchaseRda()
    {
        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c='Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c='Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE', Translatable_Value__c = 'Surveys and Research'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', CXP_Name__c = 'Test DataUse', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE', Translatable_Value__c = 'Surveys and Research'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, CXP_Name__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE', Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, CXP_Name__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE', Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c));
        insert dupList;

        User portalUser = TestUtility.createPortaluser('Australia','Sales Executive');
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'AustraliaTest', Description = 'AustraliaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
        insert p2;
        system.runAs(portalUser)
        {
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '1234567890';
        account.OwnerId = portalUser.id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
      	
        account assetAccount =[select Id from account where RecordType.Name='Individual'];
        
        Asset testasset = new Asset();
        testasset.Name = 'TestAsset';
        testasset.AccountId = assetAccount.Id;
        testasset.Brand__c = makeVehicle.Id;
        testasset.product2Id =p2.Id;
        testasset.Derivative__c  =p2.Id;
        testasset.Common_Sale_Type__c='Demonstrator';
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        // testasset.ProductCode = '3762457362';
        testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        insert testasset;
        Opportunity opportunity = new Opportunity(AccountId = assetAccount.Id, 
                                                  Name= 'Test Opp' , 
                                                  StageName ='Vehicle Selection',
                                                  Primary_Model_Interest__c = modelVehicle.Id,
                                                  Brand__c = modelVehicle.Make__c,
                                                  closedate = system.today().adddays(30),
                                                  Purchase_Type__c = 'New Vehicle',
                                                  Type = 'Product',
                                                  Sub_Type__c = 'Retail',
                                                  pricebook2id=standardPB.Id,
                                                  OwnerId=portalUser.id,
                                                  Handover_Date__c = system.today(),
                                                  Is_New_RDA_Process__c = true);
        insert opportunity; 
       Test.startTest();
       RDA__c NewRetailerRda= new RDA__c(recordtypeId =newRetailRecordTypeId, Opportunity__c=opportunity.Id, account__c=assetAccount.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today()-3, Common_Sale_Type__c='Dealer Based Rental',
                                   Registration_Number__c='TEST123', Retail_Offer__c='Loyalty Program',Add_Extended_Warranty__c = true,
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM');
        Insert NewRetailerRda;
        }
        
        
        database.executeBatch(new Batch_CVoiceRDAExport());
        Test.stopTest();
    }
}
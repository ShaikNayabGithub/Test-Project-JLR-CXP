@isTest
Public class Batch_UpdateCXPInboundOppsTEST{
    @testSetup
    Public static void createData(){        
        
        // insert product
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry For Product';
        p.productCode = 'SFDCPanther-123';
        p.isActive = true;
        insert p;
        
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rovsser', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        List<MENA_CDK_Opportunity__c> oppList = new List<MENA_CDK_Opportunity__c>();       
        MENA_CDK_Opportunity__c cdkOpp = new MENA_CDK_Opportunity__c( Customer_unique_Number__c = '152368',
               Brand__c = 'LANDROV',Model__c = 'L560VELAR',Industry__c = '' ,Account_Owner__c = 'Abdulmajeed Anjilath',
               Delivery_Date_Text__c = '16/09/2021',Invoice_Date_Text__c = '14/09/2021',Registration_Date_Text__c = '15/09/2021',
               Lost_Date_Text__c = '16/09/2021',Event_Type__c = '',Lost_Sale_Ref__c = '', Nationality_Code__c = '',
               Address_3__c = '',Order_Date_Text__c = '--/--/----',Quote_Date_Text__c = '--/--/----',Demo_Date_Text__c = '--/--/----', 
               Price__c = 1000,Type_NEWUSED__c = '',Last_Edit_Date_Text__c = '12/12/2012',Company_Name__c = '',Salutation__c = '',
               Gender__c = '',Language__c = '',Employment_Status__c = '',Occupation__c = '',Mobile__c = '21423532542',Phone__c = '',
               Home_Phone__c = '',Email__c = 'ramy.updatetest3@changi.com',Email_2__c = '', Lead_Hub_ID__c = '998812',VAT__c = 1234, Address_2__c = '',
               VIN__c = '5432',First_Name__c = 'test', Surname__c = 'name',Lead_Source__c = '',Enquiry_Source__c = '', Enquiry_Number__c='test1234', Country_ISO_Code__c = 'SA' );
        oppList.add( cdkOpp );
        
        cdkOpp = new MENA_CDK_Opportunity__c( Customer_unique_Number__c = '152368',
               Brand__c = 'LANDROV',Model__c = 'L560VELAR',Industry__c = '' ,Account_Owner__c = 'Abdulmajeed Anjilath',
               Delivery_Date_Text__c = '16/09/2021',Invoice_Date_Text__c = '14/09/2021',Registration_Date_Text__c = '15/09/2021',
               Lost_Date_Text__c = '16/09/2021',Event_Type__c = '',Lost_Sale_Ref__c = '', Nationality_Code__c = '',
               Address_3__c = '',Order_Date_Text__c = '--/--/----',Quote_Date_Text__c = '--/--/----',Demo_Date_Text__c = '--/--/----',
               Price__c = 1000,Type_NEWUSED__c = '',Last_Edit_Date_Text__c = '12/12/2012',Company_Name__c = '',Salutation__c = '',
               Gender__c = '',Language__c = '',Employment_Status__c = '',Occupation__c = '',Mobile__c = '21423532542',Phone__c = '',
               Home_Phone__c = '',Email__c = 'ramy.updatetest5@changi.com',Email_2__c = '', Lead_Hub_ID__c = '998813',VAT__c = 1234, Address_2__c = '',
               VIN__c = '5432',First_Name__c = 'test1', Surname__c = 'name1',Lead_Source__c = '',Enquiry_Source__c = '', Enquiry_Number__c='test4321', Country_ISO_Code__c = 'SA'  );
        oppList.add( cdkOpp );
        
        cdkOpp = new MENA_CDK_Opportunity__c( Customer_unique_Number__c = '152368',
               Brand__c = 'LANDROV',Model__c = 'L560VELAR',Industry__c = '' ,Account_Owner__c = 'Abdulmajeed Anjilath',
               Delivery_Date_Text__c = '16/09/2021',Invoice_Date_Text__c = '14/09/2021',Registration_Date_Text__c = '15/09/2021',
               Lost_Date_Text__c = '16/09/2021',Event_Type__c = '',Lost_Sale_Ref__c = '', Nationality_Code__c = '',
               Address_3__c = '',Order_Date_Text__c = '--/--/----',Quote_Date_Text__c = '--/--/----',Demo_Date_Text__c = '--/--/----',
               Price__c = 1000,Type_NEWUSED__c = '',Last_Edit_Date_Text__c = '12/12/2012',Company_Name__c = '',Salutation__c = '',
               Gender__c = '',Language__c = '',Employment_Status__c = '',Occupation__c = '',Mobile__c = '21423532542',Phone__c = '',
               Home_Phone__c = '',Email__c = 'ramy.updatetest4@changi.com',Email_2__c = '', Lead_Hub_ID__c = '998814',VAT__c = 1234, Address_2__c = '',
               VIN__c = '5432',First_Name__c = 'test2', Surname__c = 'mname2',Lead_Source__c = '',Enquiry_Source__c = '', Enquiry_Number__c='test9876', Country_ISO_Code__c = 'SA'  );
        oppList.add( cdkOpp );
                           
        Insert oppList;    
        
        Account testAccount1 = new Account();
        testAccount1.name = 'Testrec Account Name1';
        testAccount1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Retailer' AND SobjectType = 'Account' LIMIT 1];
        insert testAccount1;
        
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'Generic' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(DMS_ID__c  = '998812', Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        
        Contact con =  new Contact(firstname = 'abc', lastname = 'def', accountId = testAccount1.id, email = 'abc@def.com');
        insert con;
        
        opportunity oppNew = new Opportunity( Name='TestOpp', closeDate = System.today(), accountId = testAccount1.id,                                                
                                              stagename = 'Contacted', VIN__c = '5432', ContactId = con.id );
                                              
                                                              
        Insert oppNew;                                
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppNew.Id;
        oppLineItem.PricebookEntryId = standardPrice.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;              
                
        
                           
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        System.debug( 'Number_of_opp_products_with_asset__c --> '+oppsList[0].Number_of_opp_products_with_asset__c );
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Contact_Method__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c, FailReason__c, Country_ISO_Code__c  
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() );
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() );
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() );
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() );
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        update cdkOppsList;
        
        cdkOppsList[1].Lost_Date_Text__c = '12/12/2012';       
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        /*
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '11/11/2011';       
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps( cdkOppsList[1].id ) ); 
        
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '11/11/2011';       
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps( cdkOppsList[1].id ) ); 
        
        cdkOppsList[1].Quote_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Demo_Date_Text__c = '11/11/2011';       
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps( cdkOppsList[1].id ) ); 
        */
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps1(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c 
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '11/11/2011';       
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps2(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c  
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '11/11/2011';       
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps3(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c ,Contact_Method__c,FailReason__c, Country_ISO_Code__c 
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Demo_Date_Text__c = '11/11/2011'; 
        cdkOppsList[1].Last_Edit_Date_Text__c = '--/--/----';
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps4(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c, Contact_Method__c, FailReason__c, Country_ISO_Code__c 
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Demo_Date_Text__c = '11/11/2011'; 
        cdkOppsList[1].Last_Edit_Date_Text__c = '--/--/----';
        
        update cdkOppsList;
        
        oppsList[0].AccountId = null;
        update oppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
                
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps5(){
        /*RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'Generic' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(DMS_ID__c  = '998812', Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, Mapping_Brand__c = 'Jaguar');
        insert webToLead;*/
        
        MENA_CDK_Lead__c crtLead = new MENA_CDK_Lead__c( 
        Lead_Hub_ID__c = 'e735ec09-62f9-48d5-b9d8-4bbf2e08b767',First_Name__c = 'Test',
        Enquiry_Type__c = 'GENERAL_SALES_INQUIRY',Surname__c = 'Test',Lost_Lead_Comments__c = '',
        Mobile__c = '',Phone__c = '2323232323',Email__c = 'ayman@sdfdsfsdfsdfds.com',Edited_On__c = '17/06/2021',
        Task_Action_Owner__c = 'Ahmad Abu Hawili',LeadUpdateStatus__c = '', FailReason__c = '' );
        
        insert crtLead;
        
        List<MENA_CDK_Lead__c> cdkLeadList = [SELECT id,External_Oem_Reference_ID__c,Lead_Hub_ID__c,First_Name__c,
                         Enquiry_Type__c,Surname__c,Lost_Lead_Comments__c,Mobile__c,Phone__c,
                         Email__c,Edited_On__c,Task_Action_Owner__c,Status__c,LeadUpdateStatus__c, 
                         FailReason__c 
                    FROM MENA_CDK_Lead__c];
        Database.executeBatch( new Batch_UpdateCXPInboundLeads() );
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c, Contact_Method__c, FailReason__c, Country_ISO_Code__c 
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Demo_Date_Text__c = '11/11/2011'; 
        cdkOppsList[1].Last_Edit_Date_Text__c = '--/--/----';
        
        update cdkOppsList;
        
        oppsList[0].AccountId = null;
        update oppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
                
        test.stopTest();
        
    }
    @istest
    Public static void Batch_UpdateCXPInboundOpps7(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c  
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '11/11/2011';
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps6(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c  
                                FROM MENA_CDK_Opportunity__c];
        String ids = String.valueOf( cdkOppsList[0].id )+','+String.valueOf( cdkOppsList[1].id )+','+String.valueOf( cdkOppsList[2].id );                         
        
        test.startTest();
        
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '11/11/2011';
        cdkOppsList[1].Brand__c = 'Non Franchise';
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        
        test.stopTest();
    }
        
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps8(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c, Enquiry_Number__c,Matching_ID__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c  
                                FROM MENA_CDK_Opportunity__c];
        delete cdkOppsList[2];
        delete cdkOppsList[1];
        update new Opportunity(id = oppsList[0].id, CDK_Enquiry_Number__c= cdkOppsList[0].Enquiry_Number__c);
        test.startTest();
        
        cdkOppsList[0].Delivery_Date_Text__c = '11/11/2011';
        cdkOppsList[0].Registration_Date_Text__c = '11/11/2011';
        cdkOppsList[0].Invoice_Date_Text__c = '11/11/2011';       
        cdkOppsList[0].Lost_Date_Text__c = '11/11/2011';       
        cdkOppsList[0].Quote_Date_Text__c = '11/11/2011';       
        cdkOppsList[0].Order_Date_Text__c = '11/11/2011';
        cdkOppsList[0].Demo_Date_Text__c = '11/11/2011';
        update cdkOppsList[0];
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        
        test.stopTest();
        
        List<opportunity> oppsList1 = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, 
                                       VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        
        cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c ,Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,Order_Date_Text__c, Matching_ID__c,
                                                     Quote_Date_Text__c,Demo_Date_Text__c,Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,Salutation__c,Gender__c,Language__c,
                                                     Employment_Status__c,Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,First_Name__c, 
                                                     Surname__c,Lead_Source__c,Enquiry_Source__c, Enquiry_Number__c, Contact_Method__c, FailReason__c, Country_ISO_Code__c FROM MENA_CDK_Opportunity__c];
        system.debug('oppsList1::'+oppsList1);
        system.debug('account.IsPersonAccount::'+account.IsPersonAccount);

    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps10(){
        
        List<OpportunityLineItem> oliList = [SELECT id,OpportunityId FROM OpportunityLineItem];
        List<opportunity> oppsList = [Select id, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity];
        List<Lead> leadList = [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead];
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c,
                                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c  
                                                     FROM MENA_CDK_Opportunity__c];
        
        test.startTest();
        
        cdkOppsList[2].Country_ISO_Code__c = '';
        cdkOppsList[1].Delivery_Date_Text__c = '--/--/----';
        cdkOppsList[1].Registration_Date_Text__c = '--/--/----';
        cdkOppsList[1].Invoice_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Lost_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Order_Date_Text__c = '--/--/----';       
        cdkOppsList[1].Quote_Date_Text__c = '11/11/2011';
        update cdkOppsList;
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        
        
        test.stopTest();
    }
    
    @istest
    Public static void Batch_UpdateCXPInboundOpps11(){
        List<MENA_CDK_Opportunity__c> cdkOppsList = [SELECT id,Customer_unique_Number__c,Brand__c,Model__c,Industry__c,
                                     Account_Owner__c,Delivery_Date_Text__c,Invoice_Date_Text__c,
                                     Registration_Date_Text__c,Lost_Date_Text__c,Event_Type__c,
                                     Lost_Sale_Ref__c, Nationality_Code__c,Address_3__c,
                                     Order_Date_Text__c,Quote_Date_Text__c,Demo_Date_Text__c,
                                     Price__c,Type_NEWUSED__c,Last_Edit_Date_Text__c,Company_Name__c,
                                     Salutation__c,Gender__c,Language__c,Employment_Status__c,
                                     Occupation__c,Mobile__c,Phone__c,Home_Phone__c,Email__c,
                                     Email_2__c, Lead_Hub_ID__c,VAT__c, Address_2__c,VIN__c, Enquiry_Number__c,Matching_ID__c,
                                     First_Name__c, Surname__c,Lead_Source__c,Enquiry_Source__c,Contact_Method__c, FailReason__c, Country_ISO_Code__c  
                                FROM MENA_CDK_Opportunity__c];
        cdkOppsList[2].Enquiry_Number__c = 'i93y39';
        cdkOppsList[2].Lead_Hub_ID__c = 'i93y3239';
        cdkOppsList[2].Surname__c = '';
        update cdkOppsList;
        test.startTest();
        Database.executeBatch( new Batch_UpdateCXPInboundOpps() ); 
        test.stopTest();
    }
    
}
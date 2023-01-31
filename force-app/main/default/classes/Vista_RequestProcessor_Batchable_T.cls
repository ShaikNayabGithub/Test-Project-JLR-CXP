@isTest
public class Vista_RequestProcessor_Batchable_T {
    
    @testSetup static void testSetup(){
        Sales_Person_CI_Code_Mapping__c salesPerson = new Sales_Person_CI_Code_Mapping__c(Country_ISO_Code__c = 'mx', Name ='C-LIM8');
        insert salesPerson;
        /*aop_NationalityToISOCode__c newNationalityToIso = new aop_NationalityToISOCode__c(aop_ISO_Code__c = 'ABC', Name = 'ABC');
        insert newNationalityToIso;*/
    }
    static testmethod void Execute_MarksRequests200AsError_Given200InvalidRequests()
    {
        String productCode = 'p1';
        String marketName = 'Singapore';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Product2 derivative = CreateDerivative(productCode);
        CreatePricebookEntry(marketName, derivative);
        
        List<String> orderNumbers = new List<String>();
        List<Vista_Request__c> requests = new List<Vista_Request__c>();
        Integer orderCount = 10;
        
        for(Integer i = 0; i < orderCount; i++) {
            String orderNumber = String.valueOf(123);
            orderNumbers.add(orderNumber);
            
            Vista_Request__c request = new Vista_Request__c(MetaOrderNumber__c=orderNumber);
            request.Vehicle_Orders__c = '[{"Vehicle":{"VIN":"SALCA2AG7HH680616+i","VehicleId":null,"ShortVIN":"CA680616","EngineNumber":"015113135456204PT","ChassisNumber":"680616"},"Status":null,"specification":{"SpecificationMarket":null,"Features":[{"OptionalityIndicator":"O","FeatureType":"DPCK","Features":null,"FeatureCode":"350QC"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"},{"OptionalityIndicator":"O","FeatureType":"YEAR","Features":null,"FeatureCode":"001CF"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"}],'+
                '"DescriptionGroupID":"'+'INVALID PRODUCT CODE'+'"},"Registration":{"RegistrationNo":null,"RegistrationDate":"2017-04-25"},"Misc":{"OrderCreatedDate":"2016-11-30","LastConfirmationResponseDate":null,"FrozenIndicator":null,"CommonStatusPoint":"Customer Handover","CommonOrderType":"1"},'+
                '"MetaOrderNumber":"'+orderNumber+'","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2017-03-31","CurrentPlannedDeliveryDate":"2017-03-10","CurrentPlannedBuildDate":"2017-01-26","BrandCurrentPlannedDeliveryDate":null,"AsapIndicator":"Y","AllocationPeriodStartDate":"2016-12-31","AllocationPeriodEndDate":"2017-01-27","AcceptedDeliveryDate":"2017-03-31","AcceptedBuildDate":null},"LastDayForSpecificationChange":"2017-01-05","FactoryCompleteDate":"2017-02-02"},"EventDateTime":"2017-04-25T00:00:00","Eventcode":"HANDOVER","Distribution":{"NSC":{"NSCOrderNumber":"812854"},"DistributionChannel"'+
                ':{"PartnerUniqueID":"'+'INVALID RETAILER'+'","DistributorUniqueID":"SALM0142","BrandOrderType":"RET"}},"Customer":{"CustomerHandoverDate":"2017-04-25","CommonTypeOfSale":"Retail Sold"},"Contract":{"SalesTypeCode":"1B","Salesman":"C-LIM8","PredicatedReplacementMileage":null,"PredicatedReplacementDate":null,"PaymentType":null,"ContractNumber":null,"ContractDate":"2017-04-19","ContractCancelledIndicator":null}}]';
            request.Market_Description__c = marketName;
            request.Status__c = 'Unprocessed';
            request.Brand__c = 'Land Rover';
            request.Short_Brand__c = 'LR';
            request.Market__c = 'MX';
            
            requests.add(request);
        }
        
        insert requests;
        
        
        Test.startTest();
        Vista_RequestProcessor_Batchable processor = new Vista_RequestProcessor_Batchable();
        Database.executeBatch(processor,1);
        
        Test.stopTest();
        
        Map<Id, Vista_Request__c> requestMap = new Map<Id, Vista_Request__c>(requests);
        requests = [SELECT Id FROM Vista_Request__c WHERE Id IN: requestMap.keySet() AND Status__c = 'Error'];
        
        System.assertEquals(10, requests.Size());
    }
    
    static testmethod void Execute_Creates200orders_Given200validRequests()
    {
        String productCode = 'p1';
        String STANDARD_PRICE_BOOK='Standard Price Book';
        String marketName = 'Mexico';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Product2 derivative = CreateDerivative(productCode);
        Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook(STANDARD_PRICE_BOOK);
        CreatePricebookEntry(marketName, derivative);
        String vin;
        
        Interior_colour__c intColour= new Interior_colour__c();
        intColour.source_code__c='078CU';
        intColour.cxp_code__c='CPX';
        intColour.market__c='mx';
        insert intColour;
        
        Interior_Colour_Map__c whiteMap = new Interior_Colour_Map__c();
        whiteMap.Source_Code__c = '078CU';
        whiteMap.Source_description__c = 'White';
        whiteMap.CXP_Code__c = 'CPX';
        whiteMap.CXP_Base_Description__c = 'Tan';
        insert whiteMap;
        
        List<String> orderNumbers = new List<String>();
        List<Vista_Request__c> requests = new List<Vista_Request__c>();
        Integer orderCount = 1;
        
        for(Integer i = 0; i < orderCount; i++) {
            String orderNumber = String.valueOf(i);
            orderNumbers.add(orderNumber);
            vin='"SALCA2AAGHFJKD'+i+'"';
            
            Vista_Request__c request = new Vista_Request__c(MetaOrderNumber__c=orderNumber);
            request.Vehicle_Orders__c = '[{"Vehicle":{"VIN":'+vin+',"VehicleId":null,"ShortVIN":"CA680616","EngineNumber":"015113135456204PT","ChassisNumber":"680616"},"Status":null,"specification":{"SpecificationMarket":null,"Features":[{"OptionalityIndicator":"O","FeatureType":"DPCK","Features":null,"FeatureCode":"350QC"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"},{"OptionalityIndicator":"O","FeatureType":"YEAR","Features":null,"FeatureCode":"001CF"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"}],'+
                '"DescriptionGroupID":"'+'p1'+'"},"Registration":{"RegistrationNo":null,"RegistrationDate":"2017-04-25"},"Misc":{"OrderCreatedDate":"2016-11-30","LastConfirmationResponseDate":null,"FrozenIndicator":null,"CommonStatusPoint":"Customer Handover","CommonOrderType":"1"},'+
                '"MetaOrderNumber":"'+orderNumber+'","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2017-03-31","CurrentPlannedDeliveryDate":"2017-03-10","CurrentPlannedBuildDate":"2017-01-26","BrandCurrentPlannedDeliveryDate":null,"AsapIndicator":"Y","AllocationPeriodStartDate":"2016-12-31","AllocationPeriodEndDate":"2017-01-27","AcceptedDeliveryDate":"2017-03-31","AcceptedBuildDate":null},"LastDayForSpecificationChange":"2017-01-05","FactoryCompleteDate":"2017-02-02"},"EventDateTime":"2017-04-25T00:00:00","Eventcode":"HANDOVER","Distribution":{"NSC":{"NSCOrderNumber":"812854"},"DistributionChannel"'+
                ':{"PartnerUniqueID":"'+retailer.Primary_Dealer_Code__c+'","DistributorUniqueID":"SALM0142","BrandOrderType":"RET"}},"Customer":{"CustomerHandoverDate":"2017-04-25","CommonTypeOfSale":"Retail Sold"},"Contract":{"SalesTypeCode":"1B","Salesman":"C-LIM8","PredicatedReplacementMileage":null,"PredicatedReplacementDate":null,"PaymentType":null,"ContractNumber":null,"ContractDate":"2017-04-19","ContractCancelledIndicator":null}}]';
            request.Market_Description__c = marketName;
            request.Status__c = 'Unprocessed';
            request.Brand__c = 'Land Rover';
            request.Short_Brand__c = 'LR';
            request.Market__c = 'MX';
            
            requests.add(request);
        }
        
        insert requests;
        
        Test.startTest();
        Vista_RequestProcessor_Batchable processor = new Vista_RequestProcessor_Batchable();
        Database.executeBatch(processor,1);
        Test.stopTest();
        
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE Order.Vista_Order_Number__c IN:orderNumbers];
        System.debug('orderNumbers :: '+orderNumbers);
        System.debug('orderItems :: '+orderItems.size());
        System.assertEquals(orderCount, orderItems.size());
    }
    
        static testmethod void Execute_Creates200orders_Given200validRequests_1()
    {
        String productCode = 'p1';
        String STANDARD_PRICE_BOOK='Standard Price Book';
        String marketName = 'Mexico';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Product2 derivative = CreateDerivative(productCode);
        Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook(STANDARD_PRICE_BOOK);
        CreatePricebookEntry(marketName, derivative);
        String vin;
        
        Interior_colour__c intColour= new Interior_colour__c();
        intColour.source_code__c='078CU';
        intColour.cxp_code__c='CPX';
        intColour.market__c='mx';
        insert intColour;
        
        Interior_Colour_Map__c whiteMap = new Interior_Colour_Map__c();
        whiteMap.Source_Code__c = '078CU';
        whiteMap.Source_description__c = 'White';
        whiteMap.CXP_Code__c = 'CPX';
        whiteMap.CXP_Base_Description__c = 'Tan';
        insert whiteMap;
        
         
        
        List<String> orderNumbers = new List<String>();
        List<Vista_Request__c> requests = new List<Vista_Request__c>();
        Integer orderCount = 1;
        
        for(Integer i = 0; i < orderCount; i++) {
            String orderNumber = String.valueOf(i);
            orderNumbers.add(orderNumber);
            vin='"SALCA2AAGHFJKD'+i+'"';
            
            Vista_Request__c request = new Vista_Request__c(MetaOrderNumber__c=orderNumber);
            request.Vehicle_Orders__c = '[{"Vehicle":{"VIN":'+vin+',"VehicleId":null,"ShortVIN":"CA680616","EngineNumber":"015113135456204PT","ChassisNumber":"680616"},"Status":null,"specification":{"SpecificationMarket":null,"Features":[{"OptionalityIndicator":"O","FeatureType":"DPCK","Features":null,"FeatureCode":"350QC"},{"OptionalityIndicator":"O","FeatureType":"YEAR","Features":null,"FeatureCode":"001CF"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"},{"OptionalityIndicator":"O","FeatureType":"TRIM","Features":null,"FeatureCode":"300NY"},{"OptionalityIndicator":"O","FeatureType":"PCOL","Features":null,"FeatureCode":"1DJ"},{"OptionalityIndicator":"S","FeatureType":"TRAN","Features":null,"FeatureCode":"078CU"}],'+
                '"DescriptionGroupID":"'+'p1'+'"},"Registration":{"RegistrationNo":null,"RegistrationDate":"2017-04-25"},"Misc":{"OrderCreatedDate":"2016-11-30","LastConfirmationResponseDate":null,"FrozenIndicator":null,"CommonStatusPoint":"Customer Handover","CommonOrderType":"1"},'+
                '"MetaOrderNumber":"'+orderNumber+'","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2017-03-31","CurrentPlannedDeliveryDate":"2017-03-10","CurrentPlannedBuildDate":"2017-01-26","BrandCurrentPlannedDeliveryDate":null,"AsapIndicator":"Y","AllocationPeriodStartDate":"2016-12-31","AllocationPeriodEndDate":"2017-01-27","AcceptedDeliveryDate":"2017-03-31","AcceptedBuildDate":null},"LastDayForSpecificationChange":"2017-01-05","FactoryCompleteDate":"2017-02-02"},"EventDateTime":"2017-04-25T00:00:00","Eventcode":"HANDOVER","Distribution":{"NSC":{"NSCOrderNumber":"812854"},"DistributionChannel"'+
                ':{"PartnerUniqueID":"'+retailer.Primary_Dealer_Code__c+'","DistributorUniqueID":"SALM0142","BrandOrderType":"RET"}},"Customer":{"CustomerHandoverDate":"2017-04-25","CommonTypeOfSale":"Retail Sold"},"Contract":{"SalesTypeCode":"1B","Salesman":"C-LIM8","PredicatedReplacementMileage":null,"PredicatedReplacementDate":null,"PaymentType":null,"ContractNumber":null,"ContractDate":"2017-04-19","ContractCancelledIndicator":null}}]';
            request.Market_Description__c = marketName;
            request.Status__c = 'Unprocessed';
            request.Brand__c = 'Land Rover';
            request.Short_Brand__c = 'LR';
            request.Market__c = 'mx';
            request.vin__c = '"SALCA2AAGHFJKD0"';
            
            requests.add(request);
        }
        
        insert requests;
        
         Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.VIN__c = '"SALCA2AAGHFJKD0"';
        assetIns.Order_Number__c = orderNumbers.get(0);
        update assetIns;
        
        Test.startTest();
        Vista_RequestProcessor_Batchable processor = new Vista_RequestProcessor_Batchable();
        Database.executeBatch(processor,1);
        Test.stopTest();
        
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE Order.Vista_Order_Number__c IN:orderNumbers];
        System.debug('orderNumbers :: '+orderNumbers);
        System.debug('orderItems :: '+orderItems.size());
        System.assertEquals(orderCount, orderItems.size());
    }
    
     static testmethod void Execute_Creates200orders_Given200validRequests_2()
    {
        String productCode = 'p1';
        String STANDARD_PRICE_BOOK='Standard Price Book';
        String marketName = 'Mexico';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Product2 derivative = CreateDerivative(productCode);
        Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook(STANDARD_PRICE_BOOK);
        CreatePricebookEntry(marketName, derivative);
        String vin;
        
        Interior_colour__c intColour= new Interior_colour__c();
        intColour.source_code__c='078CU';
        intColour.cxp_code__c='CPX';
        intColour.market__c='mx';
        insert intColour;
        
        Interior_Colour_Map__c whiteMap = new Interior_Colour_Map__c();
        whiteMap.Source_Code__c = '078CU';
        whiteMap.Source_description__c = 'White';
        whiteMap.CXP_Code__c = 'CPX';
        whiteMap.CXP_Base_Description__c = 'Tan';
        insert whiteMap;
        
         
        
        List<String> orderNumbers = new List<String>();
        List<Vista_Request__c> requests = new List<Vista_Request__c>();
        Integer orderCount = 1;
        
        for(Integer i = 0; i < orderCount; i++) {
            String orderNumber = String.valueOf(i);
            orderNumbers.add(orderNumber);
            vin='"SALCA2AAGHFJKD'+i+'"';
            
            Vista_Request__c request = new Vista_Request__c(MetaOrderNumber__c=orderNumber);
            request.Vehicle_Orders__c = '[{"Vehicle":{"VIN":'+vin+',"VehicleId":null,"ShortVIN":"CA680616","EngineNumber":"015113135456204PT","ChassisNumber":"680616"},"Status":null,"specification":{"SpecificationMarket":null,"Features":[{"OptionalityIndicator":"O","FeatureType":"DPCK","Features":null,"FeatureCode":"350QC"},{"OptionalityIndicator":"O","FeatureType":"YEAR","Features":null,"FeatureCode":"001CF"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"},{"OptionalityIndicator":"O","FeatureType":"TRIM","Features":null,"FeatureCode":"300NY"},{"OptionalityIndicator":"O","FeatureType":"PCOL","Features":null,"FeatureCode":"1DJ"},{"OptionalityIndicator":"S","FeatureType":"TRAN","Features":null,"FeatureCode":"078CU"}],'+
                '"DescriptionGroupID":"'+'p1'+'"},"Registration":{"RegistrationNo":null,"RegistrationDate":"2017-04-25"},"Misc":{"OrderCreatedDate":"2016-11-30","LastConfirmationResponseDate":null,"FrozenIndicator":null,"CommonStatusPoint":"Customer Handover","CommonOrderType":"1"},'+
                '"MetaOrderNumber":"'+orderNumber+'","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2017-03-31","CurrentPlannedDeliveryDate":"2017-03-10","CurrentPlannedBuildDate":"2017-01-26","BrandCurrentPlannedDeliveryDate":null,"AsapIndicator":"Y","AllocationPeriodStartDate":"2016-12-31","AllocationPeriodEndDate":"2017-01-27","AcceptedDeliveryDate":"2017-03-31","AcceptedBuildDate":null},"LastDayForSpecificationChange":"2017-01-05","FactoryCompleteDate":"2017-02-02"},"EventDateTime":"2017-04-25T00:00:00","Eventcode":"HANDOVER","Distribution":{"NSC":{"NSCOrderNumber":"812854"},"DistributionChannel"'+
                ':{"PartnerUniqueID":"'+retailer.Primary_Dealer_Code__c+'","DistributorUniqueID":"SALM0142","BrandOrderType":"RET"}},"Customer":{"CustomerHandoverDate":"2017-04-25","CommonTypeOfSale":"Retail Sold"},"Contract":{"SalesTypeCode":"1B","Salesman":"C-LIM8","PredicatedReplacementMileage":null,"PredicatedReplacementDate":null,"PaymentType":null,"ContractNumber":null,"ContractDate":"2017-04-19","ContractCancelledIndicator":null}}]';
            request.Market_Description__c = marketName;
            request.Status__c = 'Unprocessed';
            request.Brand__c = 'Land Rover';
            request.Short_Brand__c = 'LR';
            request.Market__c = 'mx';
            request.vin__c = '"SALCA2AAGHFJKD0"';
            
            requests.add(request);
        }
        
        insert requests;
        
         Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.VIN__c = '"SALCA2AAGHFJKD1"';
        assetIns.Order_Number__c = orderNumbers.get(0)+'1';
        update assetIns;
        
        Test.startTest();
        Vista_RequestProcessor_Batchable processor = new Vista_RequestProcessor_Batchable();
        Database.executeBatch(processor,1);
        Test.stopTest();
        
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE Order.Vista_Order_Number__c IN:orderNumbers];
        System.debug('orderNumbers :: '+orderNumbers);
        System.debug('orderItems :: '+orderItems.size());
        System.assertEquals(orderCount, orderItems.size());
    }
    
    static testmethod void Execute_Creates200assets_Given200validRequests()
    {
        String productCode = 'p1';
        String STANDARD_PRICE_BOOK='Standard Price Book';
        String marketName = 'Mexico';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Product2 derivative = CreateDerivative(productCode);
        Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook(STANDARD_PRICE_BOOK);
        CreatePricebookEntry(marketName, derivative);
        
        List<String> orderNumbers = new List<String>();
        List<Vista_Request__c> requests = new List<Vista_Request__c>();
        Integer orderCount = 1;
        
        for(Integer i = 0; i < orderCount; i++) {
            String orderNumber = String.valueOf(i);
            String vin;
            vin='"SALCA2AAGHFJKD'+i+'"';
            orderNumbers.add(orderNumber);
            
            Vista_Request__c request = new Vista_Request__c(MetaOrderNumber__c=orderNumber);
            request.Vehicle_Orders__c = '[{"Vehicle":{"VIN":'+vin+',"VehicleId":null,"ShortVIN":"CA680616","EngineNumber":"015113135456204PT","ChassisNumber":"680616"},"Status":null,"specification":{"SpecificationMarket":null,"Features":[{"OptionalityIndicator":"O","FeatureType":"DPCK","Features":null,"FeatureCode":"350QC"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"},{"OptionalityIndicator":"O","FeatureType":"YEAR","Features":null,"FeatureCode":"001CF"},{"OptionalityIndicator":"O","FeatureType":"MSCH","Features":null,"FeatureCode":"001BY"}],'+
                '"DescriptionGroupID":"'+'p1'+'"},"Registration":{"RegistrationNo":null,"RegistrationDate":"2017-04-25"},"Misc":{"OrderCreatedDate":"2016-11-30","LastConfirmationResponseDate":null,"FrozenIndicator":null,"CommonStatusPoint":"Customer Handover","CommonOrderType":"1"},'+
                '"MetaOrderNumber":"'+orderNumber+'","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2017-03-31","CurrentPlannedDeliveryDate":"2017-03-10","CurrentPlannedBuildDate":"2017-01-26","BrandCurrentPlannedDeliveryDate":null,"AsapIndicator":"Y","AllocationPeriodStartDate":"2016-12-31","AllocationPeriodEndDate":"2017-01-27","AcceptedDeliveryDate":"2017-03-31","AcceptedBuildDate":null},"LastDayForSpecificationChange":"2017-01-05","FactoryCompleteDate":"2017-02-02"},"EventDateTime":"2017-04-25T00:00:00","Eventcode":"HANDOVER","Distribution":{"NSC":{"NSCOrderNumber":"812854"},"DistributionChannel"'+
                ':{"PartnerUniqueID":"'+retailer.Primary_Dealer_Code__c+'","DistributorUniqueID":"SALM0142","BrandOrderType":"RET"}},"Customer":{"CustomerHandoverDate":"2017-04-25","CommonTypeOfSale":"Retail Sold"},"Contract":{"SalesTypeCode":"1B","Salesman":"C-LIM8","PredicatedReplacementMileage":null,"PredicatedReplacementDate":null,"PaymentType":null,"ContractNumber":null,"ContractDate":"2017-04-19","ContractCancelledIndicator":null}}]';
            request.Market_Description__c = marketName;
            request.Status__c = 'Unprocessed';
            request.Brand__c = 'Land Rover';
            request.Short_Brand__c = 'LR';
            request.Market__c = 'mx';
            
            requests.add(request);
        }
        
        insert requests;
        
        Test.startTest();
        Vista_RequestProcessor_Batchable processor = new Vista_RequestProcessor_Batchable();
        Database.executeBatch(processor,1);
        Test.stopTest();
        
        
        List<asset> orderItems = [SELECT Id FROM asset WHERE asset.Order_Number__c IN:orderNumbers];
        
        System.assertEquals(orderCount, orderItems.size());
    }
    
    private static Product2 CreateDerivative(String productCode)
    {
        Vehicle_Specification__c brand = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2 model = TestClass_ProductBuilder.BuildModel(brand);
        
        Product2 derivative = new Product2();
        derivative.RecordTypeId = [SELECT ID FROM RecordType WHERE DeveloperName = 'Derivative' AND SobjectType = 'Product2'].Id;
        derivative.Name = 'test';
        derivative.Make__c = brand.Id;
        derivative.Model__c = model.Id;
        derivative.ProductCode = productCode;
        
        insert derivative;
        return derivative;
    }
    
    private static void CreatePricebookEntry(String market, Product2 derivative)
    {
        Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook(market);
        TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(pricebook, derivative);
    }
}
@isTest
public class VistaSubscriptionEventProcessor_Test { 
    
    @isTest static void testSubscriptionEvenValidOrder(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Unprocessed'),1);
        Test.stopTest();
    }
    @isTest static void testSubscriptionEvenInValidOrder(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'InValidOrder'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Unprocessed'),1);
        Test.stopTest();
    }
    
    @isTest static void testSubscriptionErrorEvent(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,400,'InValidOrder'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Unprocessed'),1);
        Test.stopTest();
    }
    
    @isTest static void testSubscriptionErrorEventWithoutCurrentStatus(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'WithoutCurrentStatus'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Unprocessed'),1);
        Test.stopTest();
    }
    
     @isTest static void testSubscriptionErrorEventWithoutCurrentStatusAus(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'WithoutCurrentStatus'));
        createSubscription();
         createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Unprocessed'),1);
        Test.stopTest();
    }
    
     @isTest static void testSubscriptionEvenValidOrder1(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Invalid Response'),1);
        Test.stopTest();
    }
    @isTest static void testSubscriptionEvenInValidOrder1(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'InValidOrder'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Invalid Response'),1);
        Test.stopTest();
    }
    
    @isTest static void testSubscriptionErrorEvent1(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,400,'InValidOrder'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Invalid Response'),1);
        Test.stopTest();
    }
    
    @isTest static void testSubscriptionErrorEventWithoutCurrentStatus1(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'WithoutCurrentStatus'));
        createSubscription();
        createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Invalid Response'),1);
        Test.stopTest();
    }
    
     @isTest static void testSubscriptionErrorEventWithoutCurrentStatusAus1(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'WithoutCurrentStatus'));
        createSubscription();
         createInvalidSubscription();
        createMake();        
        Account parentIns = createParentAccount();
        Account childIns = createChildAccount(parentIns.Id); 
        Test.startTest();
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch('Invalid Response'),1);
        Test.stopTest();
    }
    @isTest static void testVistaSubscriptionEventHandler(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/VistaSubscriptionEvent/';       
        String JsonMsg = '{"event":"LIFECYCL","source":"VISTA","sourceId":"67096","uri":"/vehicle-orders/67096","timestamp":"2020-10-30T10:07:37Z","subscription":"1245","subscriptionType":"VEHICLE_ORDER_EVENTS","eventData":[{"key":"orderEventNo","value":"169338"},{"key":"commonOrderNo","value":"97304"},{"key":"eventCode","value":"LIFECYCL"},{"key":"createdSystem","value":"CONVERT"},{"key":"createdBy","value":"CONVERT"},{"key":"createdTs","value":"2006-04-08 17:12:55"},{"key":"updatedTs","value":"2006-09-26 01:03:59"},{"key":"updatedBy","value":"Order Archive"},{"key":"orderMarket","value":"UB"},{"key":"placingOrganisationId","value":"SALM2400N1181"},{"key":"retailerReference","value":""},{"key":"brand","value":"SAL"},{"key":"commonOrderType","value":"1"},{"key":"typeOfSale","value":"AAA"},{"key":"brandOrderType","value":"RET"},{"key":"vin","value":"SALLDHMF83A662613"},{"key":"iso3Country","value":"IN"},{"key":"currentStatus","value":"10"},{"key":"productId","value":"5000682599"},{"key":"programCode","value":"X761"},{"key":"year","value":"2022"}]}';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        VistaSubscriptionEventHandler.doPost();
        String requestString = '{"event":"LIFECYCL","source":"VISTA","sourceId":"67096","uri":"/vehicle-orders/67096","timestamp":"2020-10-30T10:07:37Z","subscription":"1245","subscriptionType":"VEHICLE_ORDER_EVENTS","eventData":[{"key":"_orderEventNo","value":"169338"},{"key":"commonOrderNo","value":"97304"},{"key":"eventCode","value":"LIFECYCL"},{"key":"createdSystem","value":"CONVERT"},{"key":"createdBy","value":"CONVERT"},{"key":"createdTs","value":"2006-04-08 17:12:55"},{"key":"updatedTs","value":"2006-09-26 01:03:59"},{"key":"updatedBy","value":"Order Archive"},{"key":"orderMarket","value":"UB"},{"key":"placingOrganisationId","value":"SALM2400N1181"},{"key":"retailerReference","value":""},{"key":"brand","value":"SAL"},{"key":"commonOrderType","value":"1"},{"key":"typeOfSale","value":"AAA"},{"key":"brandOrderType","value":"RET"},{"key":"vin","value":"SALLDHMF83A662613"}]}';
        VistaSubscriptionEventWrapper eventResp = (VistaSubscriptionEventWrapper)JSON.deserialize(requestString,VistaSubscriptionEventWrapper.class);
        Test.stopTest();        
    }
    
    
    public static void createMake(){
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id derivativeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Product2 model = new Product2(Name='H3',productCode = 'H3', Make__c=makeVehicle.Id, RecordTypeId=modelRecordTypeId);
        insert model;
        Product2 derivativeIns = new Product2(Name='H3',productCode = '5000704867', Make__c=makeVehicle.Id, RecordTypeId=derivativeRecordTypeId);
        insert derivativeIns; 
    }
    public static void createSubscription(){
        Vista_Subscription_Event__c eve = new Vista_Subscription_Event__c();
        eve.Event__c = 'NEWORDER';
        eve.Source__c = 'VISTA';
        eve.Status__c = 'Unprocessed';
        eve.OrderNo__c = '97304';
        eve.iso3Country__c = 'AUS';
        eve.Event_Data__c = '{"event":"NEWORDER","sourceId":"16542852","source":"VehicleOrders","uri":"16542852","subscriptionType":"VEHICLE_ORDER_EVENT","subscriber":"CXP","subscriptionId":"12","subscriberId":"12","messageTimestamp":"1645196976693","eventData":[{"key":"_orderEventNo","value":"530526508"},{"key":"commonOrderNo","value":"16542852"},{"key":"eventCode","value":"NEWORDER"},{"key":"createdTs","value":"2022-03-09 17:06:20"},{"key":"orderMarket","value":"AJ"},{"key":"iso3Country","value":"AUS"},{"key":"placingOrganisationId","value":"SALM797801440"},{"key":"retailerCode","value":"01440"},{"key":"distributorCode","value":"M7978"},{"key":"retailerReference","value":"Retailer Ref"},{"key":"brand","value":"SAL"},{"key":"commonOrderType","value":"3"},{"key":"typeOfSale","value":"XXX"},{"key":"brandOrderType","value":"STK"},{"key":"vin","value":""},{"key":"currentStatus","value":"10"},{"key":"currentStatusTs","value":"2022-03-09 17:06:20"},{"key":"globalSalesType","value":"S"},{"key":"model","value":"H3"},{"key":"modelYear","value":"001CJ"},{"key":"make","value":"SAL"},{"key":"licenseNo","value":""},{"key":"productId","value":"5000704867"},{"key":"iso2Country","value":"AU"},{"key":"features","value":""},{"key":"modelDesc","value":"New Range Rover Sport"},{"key":"programCode","value":"L461"},{"key":"year","value":"2023"}]}';
        insert eve;
    }
    public static void createInvalidSubscription(){
        Vista_Subscription_Event__c eve = new Vista_Subscription_Event__c();
        eve.Event__c = 'NEWORDER';
        eve.Source__c = 'VISTA';
        eve.Status__c = 'Invalid Response';
        eve.OrderNo__c = '97304';
        eve.iso3Country__c = 'AUS';
        eve.Event_Data__c = '{"event":"NEWORDER","sourceId":"16542852","source":"VehicleOrders","uri":"16542852","subscriptionType":"VEHICLE_ORDER_EVENT","subscriber":"CXP","subscriptionId":"12","subscriberId":"12","messageTimestamp":"1645196976693","eventData":[{"key":"_orderEventNo","value":"530526508"},{"key":"commonOrderNo","value":"16542852"},{"key":"eventCode","value":"NEWORDER"},{"key":"createdTs","value":"2022-03-09 17:06:20"},{"key":"orderMarket","value":"AJ"},{"key":"iso3Country","value":"AUS"},{"key":"placingOrganisationId","value":"SALM797801440"},{"key":"retailerCode","value":"01440"},{"key":"distributorCode","value":"M7978"},{"key":"retailerReference","value":"Retailer Ref"},{"key":"brand","value":"SAL"},{"key":"commonOrderType","value":"3"},{"key":"typeOfSale","value":"XXX"},{"key":"brandOrderType","value":"STK"},{"key":"vin","value":""},{"key":"currentStatus","value":"10"},{"key":"currentStatusTs","value":"2022-03-09 17:06:20"},{"key":"globalSalesType","value":"S"},{"key":"model","value":"H3"},{"key":"modelYear","value":"001CJ"},{"key":"make","value":"SAL"},{"key":"licenseNo","value":""},{"key":"productId","value":"5000704867"},{"key":"iso2Country","value":"AU"},{"key":"features","value":""},{"key":"modelDesc","value":"New Range Rover Sport"},{"key":"programCode","value":"L461"},{"key":"year","value":"2023"}]}';
        insert eve;
    }
    public static account createChildAccount(id parentId){
        Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account account = new Account();        
        account.RecordTypeId = RetailerRecordType;
        account.parentid = parentId;
        account.Primary_Dealer_Code__c = 'LRM797801440';
        account.Name = 'Child Firstname';
        account.BillingStreet = 'Child Street';
        account.BillingPostalCode = '6543210';
        account.BillingState = 'Child State';
        account.BillingCity = 'Child City';        
        account.Retailer_Email__c = 'testjlrdevChild@testjlr1.comdev';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '1234567890';
        insert account;
        return account;
    }
    
    public static account createParentAccount(){
        Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account account = new Account();        
        account.RecordTypeId = RetailerRecordType;
        account.Name = 'Parent Firstname';
        account.BillingStreet = 'Parent Street';
        account.BillingPostalCode = '123456';
        account.BillingState = 'Parent State';
        account.BillingCity = 'Parent City';        
        account.Retailer_Email__c = 'testjlrdevParent@testjlr1.comdev';      
        account.Country_ISO_Code__c = 'AU';  
        account.Is_Primary__c = false;
        account.Phone = '123000890';
        insert account;
        return account;
    }
    @isTest static void VistaSubscriptionEventSchedulerTest(){
        Test.startTest();
        VistaSubscriptionEventScheduler sch = new VistaSubscriptionEventScheduler('Unprocessed');
        sch.execute(null);
        Test.stopTest();
    }
}
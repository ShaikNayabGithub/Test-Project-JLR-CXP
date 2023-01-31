@isTest
public class D42_UpdateVehicleTest{

    static testmethod void UpsertVistaGivenValidOrder() {
        D42_UpdateVehicle.UpsertVistaOrders(null);
        D42_UpdateVehicle veh = new D42_UpdateVehicle();
        D42_UpdateVehicle.Response veh1 = new D42_UpdateVehicle.Response();
    }
 
    /*
 static testmethod void UpsertVistaGivenValidOrder() 
    {
        Test.startTest();
        D42_UpdateVehicle.WsdlVersion_0_1();
        List<D42_UpdateVehicle.ExportDetails> exportDetails = new List<D42_UpdateVehicle.ExportDetails>();
        D42_UpdateVehicle.ExportDetails vistaExport = BuildValidVistaExport();
        vistaExport.VehicleOrders = new List<D42_UpdateVehicle.VehicleOrder>();
        D42_UpdateVehicle.VehicleOrder vehicleOrder = new D42_UpdateVehicle.VehicleOrder();
        vehicleOrder.Misc=new D42_UpdateVehicle.Misc();
        vehicleOrder.EventDateTime='2018-08-31T00:00:00';
        vehicleOrder.Misc.CommonStatusPoint='155';
        vehicleOrder.MetaOrderNumber = '1';
        vehicleOrder.EventCode = 'DELETE';
        vehicleOrder.Vehicle= new D42_UpdateVehicle.Vehicle();
        vehicleOrder.Vehicle.vin='SALJAX23423';
        vehicleOrder.Status=NEW D42_UpdateVehicle.status();
        vehicleOrder.Manufacture=new D42_UpdateVehicle.Manufacture();
        //specification
        vehicleOrder.Specification=new D42_UpdateVehicle.Specification();
        //listfeature
        vehicleOrder.Specification.Features= new List<D42_UpdateVehicle.Feature>();
        
        //feature
        D42_UpdateVehicle.Feature feature=new D42_UpdateVehicle.feature();
        feature.FeatureType='test1';
        feature.FeatureCode='code';
        feature.OptionalityIndicator='optional';
        vehicleOrder.Specification.Features.add(feature);
        vistaExport.VehicleOrders.Add(vehicleOrder);
        exportDetails.add(vistaExport);
     
        Account retailer= new account();
        retailer.phone='3433400877';
        retailer.name='fdsafsdretailer';
        retailer.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id;
        insert retailer;
      
        contact contact=new contact();
        contact.firstname='testdd';
        contact.accountid=retailer.id;
        contact.email='contatest@emailtest1.com';
        contact.lastname='testinglastname';
        insert contact;
        System.RunAs(new User(Id=userinfo.getUserId())){
        user uu= TestClass_UserCreator.CreateRetailerUser(contact);
        }
        account acc=new account();
        acc.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        insert acc;
        
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;

        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        asset.accountid=retailer.id;
        insert asset;

      
        D42_UpdateVehicle.Response response=D42_UpdateVehicle.UpsertVistaOrders (exportDetails);
        
        Integer retrievedRequestCount = [Select COUNT() From Asset where vin__c='test123'];
        
         Test.stopTest();
        
       // System.AssertNotEquals(RESPONSE, null);
    }
    

    static testmethod void UpsertVistaOrdersGivenValidOrder()
    {
      
        AssetHandler.ignoreMMIT=true;
        D42_UpdateVehicle.WsdlVersion_0_1();
        List<D42_UpdateVehicle.ExportDetails> exportDetails = new List<D42_UpdateVehicle.ExportDetails>();
        D42_UpdateVehicle.ExportDetails vistaExport = BuildValidVistaExport();
        vistaExport.VehicleOrders = new List<D42_UpdateVehicle.VehicleOrder>();
        D42_UpdateVehicle.VehicleOrder vehicleOrder = new D42_UpdateVehicle.VehicleOrder();
        vehicleOrder.Misc=new D42_UpdateVehicle.Misc();
        vehicleOrder.EventDateTime='2018-08-31T00:00:00';
        vehicleOrder.Misc.CommonStatusPoint='155';
        vehicleOrder.MetaOrderNumber = '1xxx';
        vehicleOrder.EventCode = 'DELETE';
        vehicleOrder.Vehicle= new D42_UpdateVehicle.Vehicle();
        vehicleOrder.Vehicle.vin='SALJAX23423';
        vehicleOrder.Status=NEW D42_UpdateVehicle.status();
        vehicleOrder.Manufacture=new D42_UpdateVehicle.Manufacture();
        vehicleOrder.Specification=new D42_UpdateVehicle.Specification();
        vistaExport.VehicleOrders.Add(vehicleOrder);
        exportDetails.add(vistaExport);
     
        Account retailer= new account();
        retailer.phone='3433400877';
        retailer.name='fdsafsdretailer';
        retailer.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id;
        insert retailer;
      
        contact contact=new contact();
        contact.firstname='testdd';
        contact.accountid=retailer.id;
        contact.email='contatest@emailtest1.com';
        contact.lastname='testinglastname';
        insert contact;
		User uu = new user();
        System.RunAs(new User(Id=userinfo.getUserId())){
        uu= TestClass_UserCreator.CreateRetailerUser(contact);
        }
        vehicle_specification__c vs=new vehicle_specification__c();
        vs.name='Land Rover';
        insert vs;
        
        asset asset=new asset();
        asset.vin__c='SALJAX23423';
        asset.name='SALJAX23423';
        asset.brand__c=VehicleSpecificationUtilities.brands.get('land rover').id;
        asset.accountid=retailer.id;
        asset.order_number__c='33333';
        insert asset;
    
        account acc=new account();
        acc.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Individual').Id;
        acc.firstname='individual';
        acc.lastname='dfsdf';
        acc.personemail='invidivudal@fafds.com';
        insert acc;
       
        
        pricebook2 pricebook=new pricebook2();
        pricebook.name='pricebook name';
       
        insert pricebook;
        
         
        product2 prod2=new product2();
        prod2.name='prod1';
  
        insert prod2;
        
        opportunity opp= new opportunity();
        opp.ownerid=uu.id;
        opp.stagename='ORDER';
        opp.name='test opp';
        opp.accountid=acc.id;
        opp.closedate=system.today();
        opp.pricebook2id=pricebook.id;
        insert opp;
       
        
       PricebookEntry pbentry= new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId() , Product2Id = prod2.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);       
       insert pbentry;
        
        
        pricebookentry pbentry2=new pricebookentry(pricebook2id=pricebook.id,unitprice=1000,product2id=prod2.id,isactive=true);
        insert pbentry2;
        
        OpportunityLineItem oppItem= new OpportunityLineItem();
        oppitem.Vista_Order_Number__c='33333';
        oppitem.quantity=1;
        oppItem.opportunityid=opp.id;
        oppitem.totalprice=4343;
        oppitem.product2=prod2;
        oppitem.PricebookEntryId =pbentry2.id;
        
       insert oppitem;
       
        Test.startTest();
       D42UpdateVehicleProcessor processor= new D42UpdateVehicleProcessor();
      
       asset asset2=processor.createAsset('SALJs34s34vv','33333');
       processor.updateStatusPoint('155',asset2,'2018-08-31T00:00:00');
       processor.updateStatusPoint('165',asset2,'2018-08-31T00:00:00');
       
       Test.stopTest();
        
       System.AssertNotEquals(asset2, null);
    }
    
    static testMethod void UpsertVistaOrders_GivenInvalidOrder()
    {
        List<D42_UpdateVehicle.ExportDetails> exportDetails = new List<D42_UpdateVehicle.ExportDetails>();
        D42_UpdateVehicle.ExportDetails vistaExport = BuildValidVistaExport();
        vistaExport.VehicleOrders = new List<D42_UpdateVehicle.VehicleOrder>();
        D42_UpdateVehicle.VehicleOrder vehicleOrder = new D42_UpdateVehicle.VehicleOrder();
        vistaExport.VehicleOrders.Add(vehicleOrder);
        exportDetails.add(vistaExport);
        
        D42_UpdateVehicle.Response response = D42_UpdateVehicle.UpsertVistaOrders (exportDetails);
        D42_UpdateVehicle.Response respexpected= D42_UpdateVehicle.UpsertVistaOrders (exportDetails); 
        respexpected.ResponseMessage='Error';
        
        System.AssertEquals(respexpected.ResponseMessage, response.ResponseMessage);
    }
    
    static testMethod void UpsertVistaOrdersReturnsResponseWithIsSuccess()
    {
        D42_UpdateVehicle.ExportDetails details = new D42_UpdateVehicle.ExportDetails();
        List<D42_UpdateVehicle.ExportDetails> exportDetails = new List<D42_UpdateVehicle.ExportDetails>{details};
        D42_UpdateVehicle.Response response = D42_UpdateVehicle.UpsertVistaOrders (exportDetails);
        
        system.assertEquals(true, response.isSuccess);
    }
      
    static testmethod void testExportDetails()
    {
        D42_UpdateVehicle.ExportDetails vistaExport = new D42_UpdateVehicle.ExportDetails();
        D42_UpdateVehicle test= new D42_UpdateVehicle();      
        List<D42_UpdateVehicle.ExportDetails> exportDetails = new List<D42_UpdateVehicle.ExportDetails>();   
       
        //vistaExport.Serial = 1234;
        vistaExport.Market = 'te';
        vistaExport.MarketDescription = 'MarketDescription';
        vistaExport.Brand = 'Test';
        
        vistaExport.ShortBrand='LR';
        vistaExport.AcceptedBySaleDate='2018-08-31T00:00:00';
        vistaExport.ArrivedPortEntryDate='2018-08-31T00:00:00';
        vistaExport.DispatchDate='2018-08-31T00:00:00';
        vistaExport.ArrivdPortExitDate='2018-08-31T00:00:00';
        vistaExport.TransitToDealerDate='2018-08-31T00:00:00';
        
      //  exportDetails.add(vistaexport);
      //  D42_UpdateVehicle.UpsertVistaOrders (exportDetails);
        
    }

    public static testmethod D42_UpdateVehicle.ExportDetails BuildValidVistaExport()
    {

        D42_UpdateVehicle test= new D42_UpdateVehicle();         
        D42_UpdateVehicle.ExportDetails vistaExport = new D42_UpdateVehicle.ExportDetails();
        
         D42_UpdateVehicle.response resp=new  D42_UpdateVehicle.response();
         
        //vistaExport.Serial = 1234;
        vistaExport.Market = 'te';
        vistaExport.MarketDescription = 'MarketDescription';
        vistaExport.Brand = 'Test';
        
        vistaExport.ShortBrand='LR';
        vistaExport.AcceptedBySaleDate='2018-08-31T00:00:00';
        vistaExport.ArrivedPortEntryDate='2018-08-31T00:00:00';
        vistaExport.DispatchDate='2018-08-31T00:00:00';
        vistaExport.ArrivdPortExitDate='2018-08-31T00:00:00';
        vistaExport.TransitToDealerDate='2018-08-31T00:00:00';
        
        
        
        return vistaExport;
    } */
}
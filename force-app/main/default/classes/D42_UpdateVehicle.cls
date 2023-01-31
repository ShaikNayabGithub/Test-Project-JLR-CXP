global with sharing class D42_UpdateVehicle{
webservice static void WsdlVersion_0_1(){}

   webservice static Response UpsertVistaOrders (List<ExportDetails> exportDetails){
    
    Response response;
    
    //D42UpdateVehicleProcessor processor=new D42UpdateVehicleProcessor();
   // response=processor.process(exportDetails[0]);
    
    return response;
    }
      
      public D42_UpdateVehicle(){
     
          Exportdetails ed= new exportdetails();
          VehicleOrder vo=new VehicleOrder();
          Specification sp= new Specification();
          Feature ft= new Feature();
          Vehicle vh= new Vehicle();
          Manufacture mf=new Manufacture();
          Scheduling sch= new Scheduling();
          Status st= new Status();
          Distribution db= new Distribution();
          Customer cust= new Customer();
          Registration rt=new Registration();
          
          
      
     
      }
      
 global class ExportDetails
    {
        //webservice Integer Serial;
        webservice String Market;
        webservice String MarketDescription;
        webservice String Brand;
        webservice String ShortBrand;
        webservice List<VehicleOrder> VehicleOrders;
        webservice String AcceptedBySaleDate;
        webservice String ArrivedPortEntryDate;
        webservice String DispatchDate;
        webservice String ArrivdPortExitDate;
        webservice String TransitToDealerDate;
        
    }
    
    global class VehicleOrder
    {
        webservice String MetaOrderNumber;
        webservice String Eventcode;
        webservice String EventDateTime;
        webservice Specification specification;
        webservice Vehicle Vehicle;
        webservice Manufacture Manufacture;
        webservice Status Status;
        //webservice ShippingData ShippingData;
        webservice Distribution Distribution;
        webservice Customer Customer;
        webservice Registration Registration;
        webservice Contract Contract;
        webservice Misc Misc;
        
      
    }
    
    global class Specification
    {
        webservice String SpecificationMarket;
        webservice String DescriptionGroupID;
        webservice List<Feature> Features;
    }
    
    global class Feature
    {
        webservice String FeatureType;
        webservice String FeatureCode;
        webservice String OptionalityIndicator;
        webservice List<Feature> Features;
    }
    
    global class Vehicle
    {
        webservice String VehicleId;
        webservice String VIN;
        webservice String ShortVIN;
        webservice String ChassisNumber;
        webservice String EngineNumber;
    }
    
    global class Manufacture
    {
        webservice String FactoryCompleteDate;
        webservice String LastDayForSpecificationChange;
        webservice Scheduling Scheduling;
    }
    
    global class Scheduling
    {
        webservice String CurrentPlannedBuildDate;
        webservice String CurrentPlannedDeliveryDate;
        webservice String BrandCurrentPlannedDeliveryDate;
        webservice String AsapIndicator;
        webservice String AllocationPeriodStartDate;
        webservice String AllocationPeriodEndDate;
        webservice String FirstPlannedDeliveryDate;
        webservice String AcceptedDeliveryDate;
        webservice String AcceptedBuildDate;
    }
    
    global class Status
    {
        webservice String BrandStatusPoint;
    }
    
    global class ShippingData
    {
        //empty
    }
    
    global class Distribution
    {
        webservice NSC NSC;
        webservice DistributionChannel DistributionChannel;
    }
    
    global class NSC
    {
        webservice String NSCOrderNumber;
    }
    
    global class DistributionChannel
    {
        webservice String PartnerUniqueID;
        webservice String DistributorUniqueID;
        webservice String BrandOrderType;
    }
    
    global class Customer
    {
        webservice String CommonTypeOfSale;
        webservice String CustomerHandoverDate;
    }
    
    global class Registration
    {
        webservice String RegistrationDate;
        webservice String RegistrationNo;
    }
    
    global class Contract
    {
        webservice String ContractNumber;
        webservice String ContractDate;
        webservice String Salesman;
        webservice String ContractCancelledIndicator;
        webservice String PaymentType;
        webservice String SalesTypeCode;
        webservice String PredicatedReplacementMileage;
        webservice String PredicatedReplacementDate;
    }
    
    global class Misc
    {
        webservice String OrderCreatedDate;
        webservice String CommonOrderType;
        webservice String CommonStatusPoint;
        webservice String LastConfirmationResponseDate;
        webservice String FrozenIndicator;
    }
    
    global class Response{
        webservice boolean IsSuccess;
        webservice string ErrorCode;
        webservice string ResponseMessage;
        
        
        public Response()
        {
            this.IsSuccess = true;
        }
        
     /*    public Response(Exception e)
        {
            this.IsSuccess = false;
            this.ErrorCode = System.Label.JLRTechnicalErrorCode;
            this.ResponseMessage = e.getMessage();
        }*/
        
       
    }
}
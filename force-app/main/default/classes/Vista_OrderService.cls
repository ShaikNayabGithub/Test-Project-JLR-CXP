global with sharing class Vista_OrderService {
    webservice static void WsdlVersion_0_1(){}
    
    webservice static Response UpsertVistaOrders(List<ExportDetails> exportDetails)
    {
        try
        {    
            Vista_RequestCreator requestCreator = new Vista_RequestCreator();           
            requestCreator.CreateRequests(exportDetails);
        }
        catch(Vista_OrderValidator.InvalidVistaDataException invalidE)
        {
            Response returnResponse = new Response();
            returnResponse.ErrorCode = System.Label.Vista_DataErrorCode;
            returnResponse.IsSuccess = false;
            returnResponse.ResponseMessage = invalidE.getMessage();
            return returnResponse;
        }
        catch(Exception e)
        {
            return new Response(e);
        }
        return new Response();
    }
    
    
    global class ExportDetails
    {
        //webservice Integer Serial;
        webservice String Market;
        webservice String MarketDescription;
        webservice String Brand;
        webservice String ShortBrand;
        webservice List<VehicleOrder> VehicleOrders;
    }
    
    global class VehicleOrder implements I_Serializable
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
        
        public Boolean IsEmpty()
        {
            return (String.isEmpty(MetaOrderNumber));
        }
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
        
        public Response(Exception e)
        {
            this.IsSuccess = false;
            this.ErrorCode = System.Label.JLRTechnicalErrorCode;
            this.ResponseMessage = e.getMessage();
        }
    }
}
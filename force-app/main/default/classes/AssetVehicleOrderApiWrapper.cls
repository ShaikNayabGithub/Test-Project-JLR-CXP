public class AssetVehicleOrderApiWrapper {
    public AssetVehicleOrderApiWrapper(){}
    public String vin {get;set;} 
    public String shortVin {get;set;} 
    public PlacingOrganisationId placingOrganisationId {get;set;} 
    public String plant {get;set;} 
    public OrderMarket orderMarket {get;set;} 
    public OrderMarket brandOrderStatus {get;set;} 
    public GlobalSalesType globalSalesType {get;set;} 
    public String financialStatus {get;set;} 
    public OrderMarket commonOrderType {get;set;} 
    public Boolean orderFrozenIndicator {get;set;} 
    public OrderMarket typeOfSale {get;set;} 
    public Boolean autoTradeIndicator {get;set;} 
    public OrderMarket brandOrderType {get;set;} 
    public CurrentStatus currentStatus {get;set;} 
    public Boolean onlineSalesIndicator {get;set;} 
    public Boolean svoIndicator {get;set;} 
    public Boolean wltpSensitiveIndicator {get;set;} 
    public Boolean archiveStatus {get;set;} 
    public String orderDate {get;set;} 
    public String orderConfirmedDate {get;set;} 
    public String lastNormalSpecificationChangeDate {get;set;} 
    public String lastConfirmationResponseDate {get;set;} 
    public String currentPlannedBuildDate {get;set;} 
    public String acceptedBuildDate {get;set;} 
    public String firstPlannedDeliveryDate {get;set;} 
    public String currentPlannedDeliveryDate {get;set;} 
    public String acceptedDeliveryDate {get;set;} 
    public String plannedHandoverDate {get;set;} 
    public String handoverDate {get;set;}  
    public String factoryCompleteDate {get;set;} 
    public String intermediateDestinationDate {get;set;} 
    public String deliveryDate {get;set;}
    public String rccUrl {get;set;} 
    public String commonOrderNo {get;set;} 
    public String retailerRef {get;set;} 
    public String distributorRef {get;set;} 
    public String plantOrderNo {get;set;} 
    public Boolean manufactureASAPIndicator {get;set;} 
    public Embedded x_embedded {get;set;} // in json: _embedded
    
    public class CurrentStatus {
        public String id {get;set;} 
        public String descr {get;set;} 
        public String lang {get;set;} 
        public String timestamp {get;set;} 
    }
    public class Product {
        public String id {get;set;} 
        public String descr {get;set;}
    }
    
    public class FinalDestination {
        public String id {get;set;} 
        public String desc_Z {get;set;} // in json: desc
        public String orgLevel {get;set;} 
    }
    
    public class Vehicle {
        public SteeringCode steeringCode {get;set;} 
        public String vin {get;set;} 
        public String shortVin {get;set;} 
        public String specificationLock {get;set;} 
        public SteeringCode specificationMarket {get;set;} 
        public GlobalSalesType model {get;set;} 
        public String programId {get;set;} 
        public GlobalSalesType modelYear {get;set;} 
        public OrderMarket brand {get;set;} 
        public SteeringCode brochureModel {get;set;} 
        public Product product {get;set;} 
        public SteeringCode derivativePack {get;set;} 
        public Derivative derivative {get;set;} 
        public SteeringCode engineType {get;set;} 
        public SteeringCode bodyStyle {get;set;} 
        public SteeringCode drive {get;set;} 
        public SteeringCode wheelBase {get;set;} 
        public SteeringCode exteriorColour {get;set;} 
        public SteeringCode trim {get;set;} 
        public SteeringCode transmission {get;set;} 
        public SteeringCode fuelType {get;set;}
        public SteeringCode x_embedded {get;set;} // in json: _embedded
        public String engineNo {get;set;} 
        public String chassisNo {get;set;} 
        public String registrationNo {get;set;} 
        public String pedVersion {get;set;} 
        public String pedCertificateStatus {get;set;} 
    }
    public class Prices {
        public String priceType {get;set;} 
        public Double priceValue {get;set;} 
        public String source {get;set;} 
    }
    public class PlacingOrganisationId {
        public String id {get;set;} 
        public String organisationId {get;set;} 
        public String name {get;set;} 
        public String addressLine1 {get;set;} 
        public String city {get;set;} 
        public String postCode {get;set;} 
        public String countryCode {get;set;} 
    }
    
    public class Distribution {
        public String commonOrderNo {get;set;} 
        public String actualVesselName {get;set;}
        public String plannedSailDate {get;set;}
        public String shippingBillOfLadingId {get;set;} 
        public IntermediateDestination intermediateDestination {get;set;} 
        public String plannedIntermediateDestinationDate {get;set;}
        public String intermediateDestinationDate {get;set;}
        public FinalDestination finalDestination {get;set;} 
        public String requestedDeliveryDate {get;set;}
        public String plannedDeliveryDate {get;set;} 
        public String acceptedDeliveryDate {get;set;} 
        public String deliveryDate {get;set;}
        public String calloverIndicator {get;set;} 
    }
    public class Derivative {
        public String type_Z {get;set;} 
        public String id {get;set;} 
        public String group_Z {get;set;} // in json: group
        public String descr {get;set;} 
        public String lang {get;set;} 
    }
    public class IntermediateDestination {
        public String orgLevel {get;set;} 
    }
    public class SteeringCode {
        public String id;
        public String descr;
    }
    public class GlobalSalesType {
        public String id {get;set;}
        public String descr;
    }
    public class OrderMarket {
        public String id {get;set;} 
        public String descr {get;set;} 
        public String lang {get;set;} 
    }
    public class Embedded {
        // public List<Prices> prices {get;set;} 
        public Distribution distribution {get;set;} 
        public Vehicle vehicle {get;set;} 
    }
    public class ResponseWrapper{
        public String message;
        public String accessToken;
        public String callType;
        public Asset assetIns;
        public Integer statusCode;
    }
}
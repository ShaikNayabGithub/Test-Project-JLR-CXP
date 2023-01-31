/**
 * Created by caleb on 26/09/2019.
 */

public with sharing class ServiceEventAttributesDto
{
    public String DatabaseReferenceId {get; set;}

    public String CorporateAccIndicator {get; set;}

    public String CompanyName {get; set;}

    public String ContactTitle {get; set;}

    public String ContactNameFirst {get; set;}

    public String ContactNameLast {get; set;}

    public String ContactEmail {get; set;}

    public String ContactPhoneMobile {get; set;}

    public String ContactPhoneHome {get; set;}

    public String ContactPhoneWork {get; set;}

    public String AddressLine1 {get; set;}

    public String AddressLine2 {get; set;}

    public String AddressSuburb {get; set;}

    public String AddressState {get; set;}

    public String AddressPostCode {get; set;}

    public String AddressCountry {get; set;}

    public String VehicleType {get; set;}

    public String VehicleIdentificationNumber {get; set;}

    public String VehicleRegistrationNumber {get; set;}

    public String VehicleBrand {get; set;}

    public String VehicleModel {get; set;}

    public String VehicleDerivative {get; set;}

    public String VehicleDmsId {get; set;}

    public String VehicleDmsInvoiceRefId {get; set;}

    public String RepairOrderNumber {get; set;}

    public String EventDateJobBooked {get; set;}

    public String EventDateRepaired {get; set;}

    public String EventDealerCodeJlr {get; set;}

    public String EventRepairingRetailerName {get; set;}

    public String SrType {get; set;}

    public String Description {get; set;}

    public String VehicleMileage {get; set;}

    public String VehicleMileageDate {get; set;}

    public String VehicleMileageUnitOfMeasure {get; set;}

    public String PriceInvoice {get; set;}

    public String PriceParts {get; set;}

    public String PriceLabour {get; set;}

    public String VehicleRoadworthinessInspectionDate {get; set;}

    public String VehicleLatestRegistrationDate {get; set;}

    public String JobCode {get; set;}

    public String PrivacyCode {get; set;}

    public Boolean IsRepeatRepair {get; set;}

    public String ServiceAdvisorName {get; set;}

    public String WorkOrderContactTitle {get; set;}

    public String WorkOrderContactFirstName {get; set;}

    public String WorkOrderContactLastName {get; set;}

    public String WorkOrderContactPhoneHome {get; set;}

    public String WorkOrderContactPhoneWork {get; set;}

    public String WorkOrderContactPhoneMobile {get; set;}

    public String WorkOrderContactEmail {get; set;}
}
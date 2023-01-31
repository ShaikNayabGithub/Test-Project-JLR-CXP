/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

public with sharing class VehicleOwnerAttributesDto  extends AttributesDto
{
    public String UpdateType {get; set;}
    public Boolean EmailOptOut {get; set;}
    public Boolean DirectMailOptOut {get; set;}
    public String BuyerType {get; set;}

    //VIN
    public String VehicleIdentificationNumber {get; set;}
    public String VehicleMake {get; set;}
    public String VehicleModel {get; set;}
    //5000 code / Description Group ID
    public String VehicleProductCode {get; set;}
    public String VehicleGroupDescription {get; set;}
    public String VehicleDateWarrantyStart {get; set;}
    public String VehicleDateRegistrationStart {get; set;}
    public String VehicleRegistrationNumber {get; set;}

    //OWNER Details
    public String OwnerNameCompany {get; set;}
    public String OwnerTitle {get; set;}
    public String OwnerNameFirst {get; set;}
    public String OwnerNameLast {get; set;}
    public String OwnerAddressLine1 {get; set;}
    public String OwnerAddressLine2 {get; set;}
    public String OwnerAddressSuburb {get; set;}
    public String OwnerAddressState {get; set;}
    public String OwnerAddressPostcode {get; set;}
    public String OwnerPhoneWork {get; set;}
    public String OwnerPhoneHome {get; set;}
    public String OwnerPhoneMobile {get; set;}
    public String OwnerEmail {get; set;}

    //Dealer
    public String DealerCode {get; set;}
    public String DealerName {get; set;}

    // new fields
    public string OwnerType {get; set;}
}
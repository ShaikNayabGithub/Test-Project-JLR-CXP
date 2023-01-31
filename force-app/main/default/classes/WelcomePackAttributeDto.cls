/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 18/10/2019.
 */

public with sharing class WelcomePackAttributeDto {

    public string ContactId {get; set;}

    public string ContactTitle {get; set;}

    public string ContactNameFirst {get; set;}

    public string ContactNameLast {get; set;}

    public string ContactEmail {get; set;}

    public string ContactCompanyName {get; set;}

    public string ContactPhoneMobile {get; set;}

    public string ContactPhoneHome {get; set;}

    public string ContactPhoneWork {get; set;}

    public string ContactDateOfBirth {get; set;}

    public string AddressLine1 {get; set;}

    public string AddressLine2 {get; set;}

    public string AddressSuburb {get; set;}

    public string AddressState {get; set;}

    public string AddressPostCode {get; set;}

    public string AddressCountry {get; set;}

    public string VehicleIdentificationNumber {get; set;}

    public string VehicleMake {get; set;}

    public string VehicleModel {get; set;}

    public string VehicleModelDetail {get; set;}

    public string VehicleDerivative {get; set;}

    public string VehicleRegistrationNumber {get; set;}

    public string VehicleDateWarrantyStart {get; set;}

    public string VehicleDateWarrantyExpire {get; set;}

    public boolean PreviousJlrVehicle {get; set;}
}
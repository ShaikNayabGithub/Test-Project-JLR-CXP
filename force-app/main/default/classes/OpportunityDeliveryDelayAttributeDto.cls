/**
 * Created by caleb@argologic.com.au on 17/06/2021.
 */

global with sharing class OpportunityDeliveryDelayAttributeDto
{
    public string OpportunityId {get; set;}

    public string ContactFirstName {get; set;}
    public string ContactLastName {get; set;}
    public string ContactMailingStreet {get; set;}
    public string ContactMailingCity {get; set;}
    public string ContactMailingState {get; set;}
    public string ContactMailingPostCode {get; set;}

    public string CompanyName {get; set;}

    public string VehicleBrand {get; set;}
    public string VehicleModel {get; set;}

    public string VehicleModelText {get; set;}

    public string VehicleModelPosition {get; set;}

    public string RetailerName {get; set;}
}
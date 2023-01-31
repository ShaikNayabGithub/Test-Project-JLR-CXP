/**
 * Created by Nick on 1/11/2019.
 */

public with sharing class SalesMatchAttributesDto extends AttributesDto{

    public string Id {get; set;}
    public string Name {get; set;}
    public Date CreatedDate {get; set;}
    public Date WarrantyStartDate {get; set;}
    public string RetailDealerCode {get; set;}// "Acc",
    public string Title {get; set;}// "Acc",
    public string FirstName {get; set;}// "Acc",
    public string LastName {get; set;}// "Acc",
    public string AddressLine1 {get; set;}// "Acc",
    public string AddressLine2 {get; set;}// "Acc",
    public string LocalityOfCustomer {get; set;}// "Acc",
    public string State {get; set;}// "Acc",
    public string PostcodeOfCustomer {get; set;}// "Acc",
    public string WorkPhone {get; set;}// "Acc",
    public string HomePhone {get; set;}// "Acc",
    public string CustomerEmail {get; set;}// "Acc",
    public string SubmissionType {get; set;}// "RDA (Order)",
    public string MobilePhone {get; set;}// "acc",
    public string DescriptionGroupDescription {get; set;}// "Asset",
    public string Nameplate {get; set;}// "Asset",
    public string RetailDealerName {get; set;}// "acc"
    public string RecordTypeName {get; set;}// "acc"
    public string Brand {get; set;}
    public string DealerCode1 {get; set;}
    public string DealerCode2 {get; set;}
    public string CampaignName {get; set;}
    public string Source {get; set;}
    public string EnquiryType {get; set;}
    public DateTime OpportunityDate {get; set;}
}
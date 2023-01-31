/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/11/2019.
 */

global with sharing class RetailDeliveryAttributeDto
{
    global Date HandoverDate {get; set;}

    global String AccountName {get; set;}

    global String Title {get; set;}

    global String FirstName {get; set;}

    global String LastName {get; set;}

    global String ContactID {get; set;}

    global String BillingStreet {get; set;}

    global String BillingStateProvince {get; set;}

    global String LocalityOfCustomer {get; set;}

    global String PostcodeOfCustomer {get; set;}

    global String Mobile {get; set;}

    global String Email {get; set;}

    global String RegistrationNumber {get; set;}

    global String Vin {get; set;}

    global String DescriptionGroupDescription {get; set;}

    global String DescriptionGroupId {get; set;}

    global String RetailDealerName {get; set;}

    global String Brand {get; set;}

    global String BuyerTypeNumber {get; set;}

    global String BuyerTypeDescription {get; set;}

    global String MarketingIndicator {get; set;}

    global String RetailDealerCode {get; set;}
}
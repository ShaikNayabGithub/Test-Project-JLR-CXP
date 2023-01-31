/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class ContactAttributesDto extends AttributesDto{

    @AuraEnabled
    global String NameLast {get; set;}

    @AuraEnabled
    global String NameFirst {get; set;}

    @AuraEnabled
    global String QantasFrequentFlyerNumber {get; set;}

    @AuraEnabled
    global String Status {get; set;}

    @AuraEnabled
    global String Message {get; set;}

    @AuraEnabled
    global String NameCompany {get; set;}

    @AuraEnabled
    global Boolean IsPersonAccount {get; set;}

    @AuraEnabled
    global Boolean IsCorporateContact {get; set;}

    @AuraEnabled
    global String PhoneMobile {get; set;}

    @AuraEnabled
    global String Email {get; set;}

    @AuraEnabled
    global String AccountId {get; set;}
}
/**
 * Created by caleb@argologic.com.au on 25/06/2021.
 */

public with sharing class ContactMailingDetailsResponseDto
{
    @AuraEnabled
    public string Email {get;set;}

    @AuraEnabled
    public string MobilePhone {get;set;}

    @AuraEnabled
    public string MailingStreet {get;set;}

    @AuraEnabled
    public string MailingCity {get;set;}

    @AuraEnabled
    public string MailingState {get;set;}

    @AuraEnabled
    public string MailingPostCode {get;set;}

    @AuraEnabled
    public string MailingCountry {get;set;}

    @AuraEnabled
    public Boolean LetterOptOut {get;set;}

    @AuraEnabled
    public Boolean WillSendLetter {get;set;}
}
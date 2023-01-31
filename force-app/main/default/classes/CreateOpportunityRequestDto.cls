/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

public with sharing class CreateOpportunityRequestDto extends BaseOpportunityRequestDto
{


    @AuraEnabled
    public String NameFirst {get; set;}

    @AuraEnabled
    public String NameLast {get; set;}

    @AuraEnabled
    public String Email {get; set;}

    @AuraEnabled
    public String PhoneMobile {get; set;}

    @AuraEnabled
    public String AccountId {get; set;}

    @AuraEnabled
    public String Company {get; set;}

    @AuraEnabled
    public String LeadSource {get; set;}

    @AuraEnabled
    public String CampaignId {get; set;}

    @AuraEnabled
    public String RelatedMilestoneId {get; set;}

    @AuraEnabled
    public String RelatedMilestoneName {get; set;}

    @AuraEnabled
    public String ActivityType {get; set;}

    @AuraEnabled
    public String ActivityDescription {get; set;}

    @AuraEnabled
    public Boolean IsOpportunityQualified {get; set;}

    @AuraEnabled
    public Boolean DoSetReminder {get; set;}

    @AuraEnabled
    public String PricebookId {get; set;}

    @AuraEnabled
    public String ReminderDateTime {get; set;}

    @AuraEnabled
    public String EventDateTimeStart {get; set;}

    @AuraEnabled
    public String EventDateTimeEnd {get; set;}

    @AuraEnabled
    public String DueDate {get; set;}

    @AuraEnabled
    public String existingAccountId {get; set;}

    @AuraEnabled
    public String existingContactId {get; set;}

    @AuraEnabled
    public String MakeId {get; set;}

    @AuraEnabled
    public String ModelId {get; set;}

    @AuraEnabled
    public String EnquiryType {get; set;}

    @AuraEnabled
    public String InitialSalesType {get; set;}


}
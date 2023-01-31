/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 15/11/2019.
 */

public with sharing class CreateActivityRequestDto {


    @AuraEnabled
    public String ActivityType {get; set;}

    @AuraEnabled
    public String OpportunityId {get; set;}

    @AuraEnabled
    public String TaskType {get; set;}

    @AuraEnabled
    public String EventType {get; set;}

    @AuraEnabled
    public String Subject {get; set;}

    @AuraEnabled
    public String DueDateTime {get; set;}

    @AuraEnabled
    public String StartDateTime {get; set;}

    @AuraEnabled
    public String EndDateTime {get; set;}

    @AuraEnabled
    public Boolean DoSetReminder {get; set;}

    @AuraEnabled
    public String ReminderDateTime {get; set;}

    @AuraEnabled
    public String Comments {get; set;}

    @AuraEnabled
    public String RelatedMilestone {get; set;}

    @AuraEnabled
    public String WhatId {get; set;}

    @AuraEnabled
    public String WhoId {get; set;}
}
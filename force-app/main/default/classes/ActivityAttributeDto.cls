/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 18/11/2019.
 */

public with sharing class ActivityAttributeDto {

    @AuraEnabled
    public String Subject {get; set;}

    @AuraEnabled
    public String Description {get; set;}

    @AuraEnabled
    public String DateCreated {get; set;}

    @AuraEnabled
    public String ActivityType {get; set;}

    @AuraEnabled
    public String WhatId {get; set;}

}
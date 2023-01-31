/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class MatchingContactAttributeDto implements Comparable
{
    @AuraEnabled
    public string Id {get; set;}
    @AuraEnabled
    public string ContactName {get; set;}
    @AuraEnabled
    public String ContactFirstName {get; set;}
    @AuraEnabled
    public String ContactLastName {get; set;}
    @AuraEnabled
    public string ContactEmail {get; set;}
    @AuraEnabled
    public string ContactPhoneMobile {get; set;}
    @AuraEnabled
    public Double MatchScore {get; set;}

    public Integer compareTo(Object compareTo) {
        MatchingContactAttributeDto compareToContact = (MatchingContactAttributeDto)compareTo;

        if (MatchScore - compareToContact.MatchScore > 0) return 1;
        if (MatchScore - compareToContact.MatchScore < 0) return -1;
        return 0;
    }
}
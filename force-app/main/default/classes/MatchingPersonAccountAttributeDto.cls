/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class MatchingPersonAccountAttributeDto implements Comparable
{
    @AuraEnabled
    public string Id {get; set;}
    @AuraEnabled
    public string PersonContactId {get; set;}
    @AuraEnabled
    public string PersonName {get; set;}
    @AuraEnabled
    public String PersonFirstName {get; set;}
    @AuraEnabled
    public String PersonLastName {get; set;}
    @AuraEnabled
    public string PersonEmail {get; set;}
    @AuraEnabled
    public string PersonPhoneMobile {get; set;}
    @AuraEnabled
    public Double MatchScore {get; set;}

    public Integer compareTo(Object compareTo)
    {
        MatchingPersonAccountAttributeDto compareToAcc = (MatchingPersonAccountAttributeDto)compareTo;
        if (MatchScore - compareToAcc.MatchScore > 0) return 1;
        if (MatchScore - compareToAcc.MatchScore < 0) return -1;
        return 0;
    }
}
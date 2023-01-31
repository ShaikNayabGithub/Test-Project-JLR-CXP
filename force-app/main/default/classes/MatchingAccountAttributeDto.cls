/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class MatchingAccountAttributeDto implements Comparable
{
    @AuraEnabled
    public string Id {get; set;}
    @AuraEnabled
    public string AccountName {get; set;}
    @AuraEnabled
    public Double MatchScore {get; set;}
    @AuraEnabled
    public List<MatchingContactAttributeDto> Contacts {get; set;}

    public Integer compareTo(Object compareTo) {
        MatchingAccountAttributeDto compareToAccount = (MatchingAccountAttributeDto)compareTo;

        if (MatchScore - compareToAccount.MatchScore > 0) return 1;
        if (MatchScore - compareToAccount.MatchScore < 0) return -1;
        return 0;
    }

    public void OrderContactsByMatchScore() {
        if (Contacts.size() > 0) {
            Contacts.sort();
        }
    }

    public Double GetContactsBestMatchScore() {
        if (Contacts.size() > 0) {
            Contacts.sort();

            return Contacts.get(0).MatchScore;
        }

        return 0;
    }
}
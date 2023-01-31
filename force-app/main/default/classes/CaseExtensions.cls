public class CaseExtensions {
    public static Boolean MatchCaseToContactByEmail(Case caseRecord, List<Contact> contacts)
    {
        integer matchedContactIndex;        
        for(integer i = 0; i < contacts.size(); i++){            
            if(caseRecord.Case_Contact_Email__c == contacts[i].Email && (caseRecord.Owner_ISO_Code__c == contacts[i].account.Country_ISO_Code__c )){
                caseRecord.ContactId = contacts[i].Id;
                matchedContactIndex = i;
                break;
            }
        }
        
        if(matchedContactIndex != null){
            contacts.remove(matchedContactIndex);
            return true;
        }
        return false;
    }
    
    
    public static Boolean MatchCaseToContactByPhone(Case caseRecord, List<Contact> contacts)
    {
        integer matchedContactIndex;
        
        for(integer i = 0; i < contacts.size(); i++){
            if(caseRecord.Case_Contact_Phone__c == contacts[i].Phone && (caseRecord.Owner_ISO_Code__c == contacts[i].account.Country_ISO_Code__c )){
                caseRecord.ContactId = contacts[i].Id;
                matchedContactIndex = i;
                break;
            }
            
        }
        
        if(matchedContactIndex != null){
            contacts.remove(matchedContactIndex);
            return true;
        }
        return false;
    }
    
    public static Boolean MatchCaseToContactByMobile(Case caseRecord, List<Contact> contacts)
    {
        integer matchedContactIndex;
        
        for(integer i = 0; i < contacts.size(); i++){
            if(caseRecord.Case_Contact_Phone__c == contacts[i].MobilePhone && (caseRecord.Owner_ISO_Code__c == contacts[i].account.Country_ISO_Code__c )){
                caseRecord.ContactId = contacts[i].Id;
                matchedContactIndex = i;
                break;
            }
            
        }
        
        if(matchedContactIndex != null){
            contacts.remove(matchedContactIndex);
            return true;
        }
        return false;
    }
}
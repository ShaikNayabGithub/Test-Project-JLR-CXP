/*
    Apex class to strip invalid characters from lead phone numbers
    This a requirement to help users scan business cards in india using the ScanBizCard app   
    Luke Brindle 26/01/2017
*/
public with sharing class LeadNumberCleanupSetter {
    private List<Lead> leads;
    private Map<Id, User> owners;
    //private RecordType recType;     
    private Set<String> allowedChars  = new Set<String>{'0','1','2','3','4','5','6','7','8','9'};    
    
    public LeadNumberCleanupSetter (List<Lead> leads){ // (Map<Id, Lead> leads){
        if(leads != null){
            this.leads = leads;
            this.owners = SObjectUtilities.GetOwnerMap(leads);                                
        }
    }
    
    public List<Lead> clean(){
        for(Lead lead : leads){
            User u = owners.get(lead.ownerId);
            if(u != null && String.isNotBlank(u.Country_ISO_Code__c )){
                lead = cleanLead(lead);
            }            
        }   
        
        return leads; 
    }
    
    private Lead cleanLead(Lead lead){
        lead.Phone = cleanNumber(lead.Phone);
        lead.MobilePhone = cleanNumber(lead.MobilePhone);
        return lead;
    }   
    
    public String cleanNumber(String phoneNumber){
        if(phoneNumber == null || string.isBlank(phoneNumber)) 
            return phoneNumber;
    
        String cleanedNumber = '';
        for(Integer i = 0; i < phoneNumber.length(); i++){
            String digit = phoneNumber.substring(i,i+1);
            if(allowedChars.contains(digit)){
                cleanedNumber += digit;
            }
        }
        return cleanedNumber;
    } 
    
}
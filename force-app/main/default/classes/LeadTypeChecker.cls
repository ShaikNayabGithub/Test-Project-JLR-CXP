/*
    Apex class to replace the lead validation rule that enforces a lead to have a purchase type when the type is Product
    Guy Bannister 3/5/2017
*/
public with sharing class LeadTypeChecker {
    private List<Lead> leads;
    private Map<Id, User> owners;   
    private String leadType = 'Product';
    
    public LeadTypeChecker (List<Lead> leads){
        if(leads != null){
            this.leads = leads;
            this.owners = SObjectUtilities.GetOwnerMap(leads);                                
        }
    }
    
    public List<Lead> check(){
        for(Lead lead : leads){
            User u = owners.get(lead.ownerId);
            if(u != null){
                if(lead.Type__c == leadType && String.isBlank(lead.Purchase_Type__c)){
                    lead.addError(Label.Please_select_a_purchase_type);
                }
            }            
        }   
        
        return leads; 
    }
    
}
public without sharing class AssetSearch_Controller {
    
    @AuraEnabled
    public static Asset searchForIds(string searchText){
        Asset asse;
        
        List<Asset> asses = [SELECT Id, Name, Model__c,  Brand__r.Name, Model__r.Name, Product2.Model_Year__c,  AccountId, Registration_Number__c, VIN__c FROM Asset WHERE (Registration_Number__c LIKE :searchText OR VIN__c LIKE :searchText OR Name Like :searchText) AND Account.Country_Iso_code__c = 'AU' limit 10 ];
        //System.debug('asses'+asses);
        if(asses != null && asses.size() == 1){
            asse = asses[0];
            if(asse.Registration_Number__c  == null || asse.Registration_Number__c == '' ){
                asse.Registration_Number__c = 'Empty'; 
            }          
            
        }
        
        
        return asse;
        
        
    }
    
    @AuraEnabled
    public static void transferAsset(String assId){     
        
        Asset assUp = new Asset(); 
        if(assId != null && assId != ''){
            assUp.Id = assId;  
        }      

        Id meId = UserInfo.getUserId();        
        List<User> me = [Select id, ContactId,  Contact.AccountId  From User where Id = :meId];        
        
        if(me != null && me[0].ContactId  != null && assId != null && assId != ''){     
            assUp.AccountId =  me[0].Contact.AccountId ;              
            update assUp;           
        }
        
        
        
        
    }
    
    
    
    
}
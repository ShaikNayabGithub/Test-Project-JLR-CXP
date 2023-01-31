public class VehicleSelectionOnOpportunityController {
    public static User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, CurrencyIsoCode, Country FROM User WHERE Id = :userinfo.getUserId()];// AND ContactId != null];
    
    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId){   
        return [SELECT Id, Name, StageName,Pricebook2Id, Asset__c, Primary_Model_Interest__c, (SELECT Id, Asset__c, Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE Id =:opportunityId AND Is_New_RDA_Process__c =true];        
    }
    
    @AuraEnabled
    public static String removeOpportunityProduct(String opportunityId){    
        string successmessage = 'Success';
        try{
            OpportunityLineItem opportunityProduct = [SELECT Id, Asset__c FROM OpportunityLineItem Where OpportunityId =:opportunityId LIMIT 1];
            TriggerFramework__c tf = TriggerFramework__c.getInstance(userinfo.getUserId());
            Boolean tfPreviousValue = tf.Asset_SkipValidations__c;
            String tfId = tf.Id;
            if(!tfPreviousValue) {
                tf.Asset_SkipValidations__c = true;
                upsert tf;
            }
            //Asset opportunityAsset = [SELECT Id,AccountId FROM Asset WHERE Id=:opportunityProduct.Asset__c];
            //opportunityAsset.AccountId = loggedinUser.AccountId; //'0010Q00000QOXKdQAP'; 
            delete opportunityProduct;
            if(tfId == null) {
                delete tf;
            } else {
                tf.Asset_SkipValidations__c = tfPreviousValue;
                update tf;
            }
            // update opportunityAsset;
            
        } catch(DmlException e) {
            successmessage = ''+e.getMessage();
        }      
        return successmessage;
    }
       
    @AuraEnabled
    public static List< Map<String,String>> getPriceBookList(){
        List< Map<String,String>> optionsList= new List<Map<String,String>>();
        system.debug(loggedinUser);
        for(CountryToPricebook__mdt pb: [SELECT Id, Label, DeveloperName, Pricebook_Name__c FROM CountryToPricebook__mdt WHERE Label = :loggedinUser.Country] ){ //'India'
            system.debug(pb);
            for(String pbName: pb.Pricebook_Name__c.split(';') ){
                Map<String,String> optionsmap= new Map<String,String>();
                optionsmap.put('label', pbName);
                optionsmap.put('value', pbName);           
                optionsList.add(optionsmap);
            }
            
        } 
        return optionsList;        
    }
     
    @AuraEnabled
    public static String updateOpportunity(String opportunityId, String priceBookName ){ 
        string successmessage = 'Success';
        try {             
            PriceBook2 localPriceBook = [SELECT Id, Name FROM PriceBook2 WHERE Name =:priceBookName AND IsActive = true Limit 1];
            Opportunity updateOpportunity = new Opportunity(Id=opportunityId, PriceBook2Id = localPriceBook.Id);
            update updateOpportunity;             
            system.debug(updateOpportunity);
        } catch(DmlException e) {
            successmessage = ''+e.getMessage();
            system.debug('successmessage'+e.getMessage());
        }      
        return successmessage;
    }
}
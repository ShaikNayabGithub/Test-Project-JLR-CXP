public without sharing class AutoCompleteController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords, boolean isPerson,String Derivative_Product2Id){
        Id Service_Plan_Product2Id; 
        List<Offers__c> offsCorporate;
        string valueType = '';
        searchString = String.escapeSingleQuotes(searchString);
        searchString = '%'+searchString+'%';
        objectApiName = String.escapeSingleQuotes(objectApiName);
        idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
        valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
        System.debug('Derivative_Product2Id '+Derivative_Product2Id);   
        System.debug('extendedWhereClause '+extendedWhereClause);   
        if(extendedWhereClause == null){
            extendedWhereClause = ' ';            
        }       
                
        offsCorporate = [SELECT Id, Type__c, Service_Plan_Product2Id__c,AccountName__c, Corporate_Partner__c FROM Offers__c WHERE ( AccountName__c LIKE :searchString AND Start_Date__c <:System.today() AND ( End_Date__c = null  or End_Date__c >:System.today()  ) AND Type__c = 'Corporate')  ];
        List<Product2> prds = [SELECT Id, Service_Plan__c  FROM Product2 where Id =:Derivative_Product2Id and Service_Plan__c != null];
    
        if(prds != null && prds.size() > 0 ){
            Service_Plan_Product2Id = prds[0].Service_Plan__c; 
        }
        
        if(offsCorporate !=  null && offsCorporate.size() > 0 && Service_Plan_Product2Id != null){
            for(Offers__c off : offsCorporate){
                off.Service_Plan_Product2Id__c = Service_Plan_Product2Id;
            }
        }
        
        Return offsCorporate;// [SELECT Id, Service_Plan_Product2Id__c,AccountName__c FROM Offers__c WHERE AccountName__c LIKE :searchString AND Start_Date__c <:System.today() AND ( End_Date__c = null  or End_Date__c >:System.today()  ) AND Type__c = 'Corporate' ];
        
    }
}
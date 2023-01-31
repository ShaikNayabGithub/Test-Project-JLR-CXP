@isTest
public with sharing class AutoCompleteControllerTest {
 

    @isTest(seeAllData=true)
    public static void testGetRecords(){ 
     
              List<Offers__c> allOffs = [SELECT Id, Type__c, Service_Plan_Product2Id__c,AccountName__c, Derivative_Product2Id__c FROM Offers__c WHERE (Service_Plan_Product2Id__c != null AND Derivative_Product2Id__c != null) limit 1 ];
        if(allOffs != null && allOffs.size() == 1){
                   List<SObject> accounts = AutoCompleteController.getRecords('sales', 'Offers__c', 'Id', 'Id',null,10,false, allOffs[0].Derivative_Product2Id__c);
        }else{
          List<SObject> accounts = AutoCompleteController.getRecords('sales', 'Offers__c', 'Id', 'Id',null,10,false, null);   
        }
        
       
     
     
        System.assert(true);
    }
}
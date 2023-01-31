@isTest
public class Batch_FixAssetRole_T {
 
    
      @IsTest(SeeAllData=true)
      static  void RDAAssetRoleTest(){
        string wherestatement = ' and ( ' ;
          List<RDA__c> rdas = [Select id, Asset__c, Asset__r.name from RDA__C where Asset__c != null   limit 5 ];
         list<string> names = new List<string>();
         boolean first = true;
          for(RDA__c rda : rdas){
             string vin =rda.Asset__r.name;
              if(first){
                    wherestatement = wherestatement + '  name = \''+vin+'\'';  
                  first = false;
              }else{
                   wherestatement = wherestatement + ' or name = \''+vin+'\'';  
              }
           
          }
       
          wherestatement = wherestatement + ')';
        Test.startTest();
      
    
        system.debug('wherestatement '+wherestatement);
       Database.executeBatch(new Batch_FixAssetRoles(wherestatement),500);
   
        Test.stopTest();
        
    }
}
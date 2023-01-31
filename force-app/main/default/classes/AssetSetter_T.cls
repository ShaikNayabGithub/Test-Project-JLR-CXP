@isTest 
private class AssetSetter_T {
    static testMethod void SetAssetWithLicencePlateNumber() {
      
       AssetSetter assetSetter= new AssetSetter();
      
       Account account1 = TestClass_AccountCreator.CreatePersonAccount();
         
       Vehicle_Specification__c vs=new Vehicle_Specification__c();
       vs.name='Jaguar';
       insert vs;
       
       Asset asset=new Asset();
       asset.accountId=account1.id;
       asset.registration_Number__c='test12dd3';
       asset.name='SAJXXX13484734923';
       asset.Brand__c = VehicleSpecificationUtilities.Brands.get('jaguar').Id;
       
       insert asset;
       
       Case newCase = new Case();
       newCase.Licence_Plate_text__c='test12dd3';
       insert newCase;
       
       Case oldCase = new Case();
       //insert oldCase;

       List<Case> listCases=new List<Case>();
       listCases.add(newCase);        
             
       Map<Id,Case>oldCaseMap=new Map<Id,Case>(); 
       oldCaseMap.put(oldCase.id,oldCase);
                    
       assetSetter.SetAssetWithLicencePlateNumber(listCases,new Map<Id,Case>());
       
       listCases=[select id,assetid from case where id=:newcase.id];
       Case updatedCase=listCases[0];
       
       System.debug('updated Case: '+updatedCase);
           
       // Test that the trigger correctly updated case with the assetid 
       System.assertNotEquals(updatedCase.assetid, null);
       System.assertEquals(updatedCase.assetId,asset.id);
    }
}
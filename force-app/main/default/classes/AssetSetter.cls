public with Sharing class AssetSetter {

 private static final Schema.DescribeFieldResult CASE_ASSET_FIELD = Schema.Case.AssetId.getDescribe();
    Map<String,Asset> assetsByRegNumber= new Map<String,Asset>();

    public void SetAssetWithLicencePlateNumber(List<Case> newCases,Map<Id,Case>oldCaseMap)
    { 
       List<Case> cases= new List<Case>();

       //process only the updated cases with a different licence plate than the old case 
       
       for(Case caseRecord : newCases) {
         boolean addToList;
         Case oldCase = oldCaseMap.get(caseRecord.Id);
         
         if(oldCase!=null)          
             if( oldCase.Licence_Plate_text__c!=caseRecord.Licence_Plate_text__c && caseRecord.Licence_Plate_text__c!=null) {
                 addToList=true;
             }
             
         if(caseRecord!=null)
             if(caseRecord.assetId==null && caseRecord.Licence_Plate_text__c!=null)
                 addToList=true;
                     
         if(addToList==true)
             cases.add(caseRecord);                                   
       } 
        
       Set<String> assetIds = SObjectUtilities.GetFieldValues(cases, CASE_ASSET_FIELD.getName());
       Map<Id,Asset> mapAssets=new Map<Id,asset>();
        
       Set<String> registrationNumbers=new Set<String>(); 
           
       for(Case caseInstance:cases)
           if(caseInstance.Licence_Plate_text__c!=null)     
               registrationNumbers.add(caseInstance.Licence_Plate_text__c);
  
       // List<Asset> tmp =  Database.query(q);
       List<Asset> tmp =   [SELECT Id,Registration_Number__c FROM asset where Registration_Number__c IN :registrationNumbers];
        
        if (!tmp.isEmpty()) {
            mapAssets=new Map<Id,Asset>(tmp);
            System.debug('mapAssets: '+mapAssets);
       
           for(Asset Asset:mapAssets.values())
           {
               assetsByRegNumber.put(asset.Registration_Number__c,asset);
               assetIds.add(String.valueOf(asset.id));
           }
        } 
       
       List<Asset> assets = new List<Asset>();
       Map<Id, Asset> assetsById = new Map<Id, Asset>();
        
        if (!assetIds.isEmpty()) {
            assets = [SELECT Id, Brand__r.Name FROM Asset WHERE Id IN: assetIds];
            assetsById = new Map<Id, Asset>(assets);
        }        
              
       for(Case caseRecord : cases) {
            
           if(mapAssets.isEmpty() && caseRecord.Licence_Plate_text__c!=NULL)
           {
               caseRecord.Licence_Plate_text__c.addError('No records found: You don\'t have permission to see any of the records or There are no records of this type.');
              
           }
            
            Asset assetFromMap=assetsByRegNumber.get(caseRecord.Licence_Plate_text__c);
            
            if(assetFromMap!=null)
                caseRecord.assetId=assetFromMap.id;
            
            if(String.isEmpty(caseRecord.AssetId)) continue;
            
            System.debug('caseRecord after updating assetid: '+caseRecord);

            Asset caseAsset = new Asset();
            if (!assetsById.isEmpty()) caseAsset = assetsById.get(caseRecord.AssetId);
            
            //if(caseAsset == null) continue;

            if (caseAsset != null && caseAsset.Brand__c != null) 
                    caseRecord.Brand2__c = caseAsset.Brand__r.Name;
  
        }
     }
}
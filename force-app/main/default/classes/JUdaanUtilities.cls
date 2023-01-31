/*
Requirement : Vehical Selector 
Describtion: 
Apply To: JPN
Author : amita.patil1@tcs.com
Test class: 
Create Date: 2017-05-26
Description: Central class for all generic methods
*/
public class JUdaanUtilities {

    public static Boolean FirstCall { get; set; }
    
    // Calculate the Lowest price for resultset
    public Map<String,Decimal> getAssetLowestPrice(List<Asset> assetList, Set<String> filterParameter,String section){
    
        Decimal lowestPriceResults;
            
        Map<String,Decimal> result = new Map<String,Decimal>();
        AggregateResult[] lowestPrice;       
        Set<Id> assetId = new Set<Id> ();
        Set<String> multipleSelection = new Set<String>();
        
        
        for (Asset asset: assetList){
            assetId.add(asset.Id); 
        }
        system.debug('#inner method assetId '+ assetId);
        
        if (section == 'NamePlate'){ 
        List<AggregateResult> arlist = new List<AggregateResult>();
        String query = 'SELECT Name_Plate__c,MIN(Price) p FROM Asset  where  Id IN :assetId   and Price != null   and  Name_Plate__C != null  GROUP BY Name_Plate__c';   
        lowestPrice = database.query(query);
        //lowestPrice = [SELECT Name_Plate__c,MIN(Price) p FROM Asset  where  Id IN :assetId   and Price != null   and  Name_Plate__C != null  GROUP BY Name_Plate__c];
         Map<String,List<AggregateResult>> result1 = new Map<String,List<AggregateResult>>();
         system.debug('###inner method If cond'+ lowestPrice);
            for(AggregateResult ar : lowestPrice){
                result.put((String)ar.get('Name_Plate__c'), (Decimal)ar.get('p'));
                arlist.add(ar);
                result1.put((String)ar.get('Name_Plate__c'), lowestPrice);
            }
            system.debug('--' +result1 );
            system.debug('------' +result );
        
        }
        
        if (section == 'BodyStyle' && assetId.size() > 0 && filterParameter.size() > 0 ){ 
        
            String query = 'SELECT Body_Style__c,MIN(Price) p FROM Asset Where Name_Plate__c IN :filterParameter and Price != null  And Id IN :assetId  GROUP BY Body_Style__c';   
            lowestPrice = database.query(query);
            
            //lowestPrice = [SELECT Body_Style__c,MIN(Price) p FROM Asset Where Name_Plate__c IN :filterParameter and Price != null  And Id IN :assetId  GROUP BY Body_Style__c];
            
        
            for(AggregateResult ar : lowestPrice){
                result.put((String)ar.get('Body_Style__c'), (Decimal)ar.get('p'));
            }
        
            system.debug('------' +result );
        
        }
        
         if (section == 'Engine' && assetId.size() > 0 ){
            
            String query = 'SELECT MIN(Price) p,Engine__c FROM Asset Where Body_Style__c IN:filterParameter and Price != null  AND Id IN :assetId GROUP BY Engine__c';   
            lowestPrice = database.query(query);
             
            //lowestPrice = [SELECT MIN(Price) p,Engine__c FROM Asset Where Body_Style__c IN:filterParameter and Price != null  AND Id IN :assetId GROUP BY Engine__c ];
            system.debug('lowestPrice ------' +lowestPrice );
            for(AggregateResult ar : lowestPrice){
                result.put((String)ar.get('Engine__c'), (Decimal)ar.get('p'));
            }
            system.debug('Engine ------' +result );
        }
        
        /*if (section == 'Colour' && assetId.size() > 0 ){
         
            lowestPrice = [SELECT Id,MIN(Price) p,Engine__c, Transmission__c ,Master_Colour__c,Colour__c FROM Asset Where Engine__c IN:filterParameter And Price != null And Id IN :assetId GROUP BY Engine__c,Master_Colour__c, Colour__c, Transmission__c ,Id ];
            for(AggregateResult ar : lowestPrice){
                result.put((String)ar.get('Master_Colour__c'), (Decimal)ar.get('p'));
            }
            system.debug('------' +result );
        }
        if (section == 'Colour2' && assetId.size() > 0 ){
         
            lowestPrice = [SELECT Id,MIN(Price) p,Engine__c, Transmission__c, Master_Colour__c, Colour__c FROM Asset Where Master_Colour__c IN:filterParameter And Price != null And Id IN :assetId GROUP BY Engine__c,Master_Colour__c, Colour__c, Transmission__c ,Id ];
            for(AggregateResult ar : lowestPrice){
                result.put((String)ar.get('Colour__c'), (Decimal)ar.get('p'));
            }
            system.debug('------' +result );
        } */
        
        return result ;
        
    }
    
    public Map<String,SET<Asset>> showALL(List<Asset> assetList, Set<String> filterParameter,String section){
    
        
        List<Asset> showallList;  
        SET<Asset> showallSet;
        Map<String,SET<Asset>> resultAll = new Map<String,SET<Asset>>();                
        Set<Id> assetId = new Set<Id> ();
        Set<String> multipleSelection = new Set<String>();
        
         for (Asset asset: assetList){
            assetId.add(asset.Id); 
        }
                     
        showallList = new List<Asset>([select id, Name,Master_Colour__c,Model__c,colour__c,Exterior_Colour_Code__c,Body_Style_Image_M__c,Fuel_Type__c,Interior_Color__c, Name_Plate__c,Body_Style__c ,Engine__c,Transmission__c,Asset_Specification_Pack__c,Asset_Detail_Specification_Pack__c, Price from Asset where Name_Plate__c != null  and Engine__c != null and Master_Colour__c!=null and Interior_Color__c!=null]);
        System.debug('showallList has values--------'+showallList);
        showallSet = new SET<Asset> () ;                          
        if (section == 'Engine'){              
            for(Asset r : showallList){
                if (filterParameter.contains(r.Body_Style__c)){
                showallSet.add(r);   
                 resultAll.put((String)r.get('Engine__c'),showallSet);
                }
            }                        
        }
        
        if (section == 'ExteriorColour'){
            for(Asset r : showallList){
                if (filterParameter.contains(r.Engine__c)){
                showallSet.add(r);   
                 resultAll.put((String)r.get('Master_Colour__c'),showallSet);
                }
            }
        }
            
        if (section == 'InteriorColour'){
            for(Asset r : showallList){
                if (filterParameter.contains(r.Exterior_Colour__c)){
                    showallSet.add(r);   
                    resultAll.put((String)r.get('Interior_Color__c'),showallSet); 
                }
            }
        }
        
        if (section == 'Specification'){
            for(Asset r : showallList){
               if(r.Asset_Specification_Pack__c !=null){
                   if (filterParameter.contains(r.Interior_Color__c)){
                        showallSet.add(r);   
                        resultAll.put((String)r.get('Asset_Specification_Pack__c'),showallSet);  
                   }
                }
            }
       }
        
    return resultAll;        
    }
}
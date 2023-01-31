public class InteriorColourHandler{    
   
    public void updateAssetsWithNewColour(List<Interior_Colour__c> listIntColour,Map<Id,Interior_Colour__c> oldMapIntColour){
    
    //get new colour values
    //get all the assets with that source code value and update the simplified codes.
    Set<String> sourceCode=new Set<String>();
    Set<String> countries=new Set<String>();
    Map<String,Interior_colour__c> mapSourceCodeToIntColour=new Map<String,Interior_colour__c>();  
    Map<id,interior_colour__c> alreadyExistingColors=Interior_Colour.GetMapPopulatedWithCodeByMarket(listIntColour);
    Interior_colour__c existingColour;
    
    for(Interior_colour__c intCol:listIntColour)
    {
         mapSourceCodeToIntColour.put(intCol.source_code__c,intCol);
            
    }
    
    if(alreadyExistingColors!=null && oldMapIntColour==null)
    {
        
        for(Interior_colour__c intColour:alreadyExistingColors.values()){
            
            existingColour=mapSourceCodeToIntColour.get(intColour.source_code__c);
            if(intColour!=null)
                if(intColour.market__c==existingColour.market__C)
                    existingColour.addError('This source code already exists for this market'); 
        
        }
        
    }    
    
    //create a list of sourcode from the map so we can query the assets from the db
    for(Interior_Colour__c colour:listIntColour){
    
             
        if(oldMapIntColour!=null)
        {        
            if(oldmapIntColour.get(colour.Id).CXP_Code__c!= colour.CXP_Code__c || oldmapIntColour.get(colour.Id).CXP_Description__c!= colour.CXP_Description__c) {
                
                if(!String.isBlank(colour.Source_code__c))
                    sourceCode.add(colour.Source_Code__c);
                    
                if(!String.isBlank(colour.market__c))
                    countries.add(colour.market__c);
            
            }
        }
        else{
            if(!String.isBlank(colour.Source_code__c))
                sourceCode.add(colour.Source_Code__c);
                
            if(!String.isBlank(colour.market__c))    
                countries.add(colour.market__c);
        
        }
        
    }
    
    System.debug('values in countries: '+countries);
    System.debug('values in codes: '+sourceCode);
    //query asset with that source code and the market from the colour market.
    List<Asset> listAssets=[select id,account.country_iso_code__c,Interior_Colour_Code_Vista__c from asset where Interior_Colour_Code_Vista__c in:sourceCode and Interior_Colour_Code_Vista__c!=' ' and account.country_iso_code__c!=null and account.country_iso_code__c IN:countries ];
    Interior_colour__c intColour;
    List<Asset>assetsToUpdate=new List<Asset>();
        
    for(Asset assetToUpdate:listAssets)
    {
        
        intColour=mapSourceCodeToIntColour.get(assetToUpdate.Interior_Colour_Code_Vista__c );
        if(assetToUpdate!=null && assetToUpdate.account.country_iso_code__c==intColour.market__c)
        {    
            
            assetToUpdate.Interior_Color__c= intColour.CXP_description__c;
            assetToUpdate.Interior_colour_code__c=intColour.cxp_code__c;
            assetsToUpdate.add(assetToUpdate);
    
        }
    
    }
    
    if(!assetsToUpdate.isEmpty())
        update assetsToUpdate;
    
   }   
   
}
/**
 * Created by lbrindle on 04/09/2018.
 */

public with sharing class Interior_Colour {

    //static Map<String,List<Interior_Colour_Map__c>> colourMaps;

    public Interior_Colour(){
      //  List<Interior_Colour_Map__c> colourMapList = [Select Id, Source_Code__c, Source_description__c, CXP_Code__c, CXP_Base_Description__c
        //                From Interior_Colour_Map__c];

        //colourMaps = SObjectUtilities.MapByField(colourMapList,Schema.Interior_Colour_Map__c.Source_Code__c.getDescribe());
        
    }
    
    
     public static Map<String ,Interior_Colour_Map__c> colourMaps{ get {
         if(colourMaps==null)
         {
             colourMaps= new Map<String ,Interior_Colour_Map__c>();
             List<Interior_Colour_Map__c> colourMapList = [Select Id, Source_Code__c, Source_description__c, CXP_Code__c, CXP_Base_Description__c
                            From Interior_Colour_Map__c];
    		
             for(Interior_Colour_Map__c IColour: colourMapList){
                colourMaps.put(IColour.Source_Code__c,IColour); 
             }
            //colourMaps = SObjectUtilities.MapByField(colourMapList,Schema.Interior_Colour_Map__c.Source_Code__c.getDescribe());
          }  
        return colourMaps ;
    } private set; }
    
    
    public static Map<String ,Map<String, Interior_Colour__c>> colourMapMarkets{ get {
        if(colourMapMarkets == null) {
            colourMapMarkets = new Map<String,Map<String, Interior_Colour__c>>();
             List<Interior_Colour__c> listColours = [Select Id, CXP_Code__c, CXP_Description__c,Source_Code__c,market__c,source_description__c
                                                    From Interior_Colour__c];
            Map<String,interior_colour__c> tempMap;
                                                    
            for(Interior_colour__c intCol: listColours)
            {
                    tempMap=colourMapMarkets.get(intCol.market__c);
                    
                    if(tempMap==null)
                        tempMap=new Map<String,interior_colour__c>();
                        
                    tempMap.put(intCol.source_code__c,intCol);
                    
                    colourMapMarkets.put(intCol.market__c, tempMap);
                
               
            }
        }
       
        return colourMapMarkets;
    } private set; }


    public void AddInteriorsColoursToMarkets(List<Interior_Colour_Map__c> newMaps){
        Map<String,List<Object>> newSourceCodes = SObjectUtilities.MapByField(newMaps, Schema.Interior_Colour_Map__c.Source_Code__c.getDescribe());

        List<Interior_Colour__c> existingColourRecords = [Select Source_Code__c, Market__c
                                                            From Interior_Colour__c
                                                            Where Source_Code__c in: newSourceCodes.keySet() ];

        Map<String,List<Object>> existingColourRecordsByMarket = SObjectUtilities.MapByField(existingColourRecords,Schema.Interior_Colour__c.Market__c.getDescribe());

        //Select unique markets
        List<AggregateResult> uniqueMArkets = [Select Market__c
                                                From Interior_Colour__c
                                                Group by Market__c];

        List<Interior_Colour__c> toInsert = new List<Interior_Colour__c>();
        for(AggregateResult ar : uniqueMarkets){
            String market = string.valueOf(ar.get('market__c'));

            for(Interior_Colour_Map__c newMap : newMaps){
                List<Interior_Colour__c> existingsMarketColours = (List<Interior_Colour__c>) existingColourRecordsByMarket.get(market);
                Boolean found = false;

                for(Interior_Colour__c existingsMarketColour : existingsMarketColours){
                    if(existingsMarketColour.Source_Code__c == newMap.Source_Code__c){
                        found = true;
                        break;
                    }
                }
                if(!found){
                    Interior_Colour__c colour = new Interior_Colour__c();
                    colour.Source_Code__c = newMap.Source_Code__c;
                    colour.Market__c = market;
                    colour.CXP_Code__c = newMap.CXP_Code__c;
                    colour.CXP_Description__c = newMAp.CXP_Base_Description__c;
                    toInsert.add(colour);
                }
            }
        }
        insert toInsert;
    }


    /*
        Use this for bulk updates to BRS codes
        The parameter brsColourCode expects the key to be the brs code, and the value to be the BRS description
     */
    public static Map<String,Interior_Colour_Map__c> UpdateSourceDescription(Map<String,String> brsColourCode) {
        Map<String,Interior_Colour_Map__c> recordsToUpdateMap = new Map<String,Interior_Colour_Map__c>();
        system.debug('@@@colourMaps'+colourMaps);
        for(String key : brsColourCode.keySet()){
            Interior_Colour_Map__c colourMap;
            if(!colourMaps.containsKey(key)) {
                colourMap=  new Interior_Colour_Map__c(source_code__c=key);
                colourMaps.put(key,colourMap);
            }else{
             colourMap= colourMaps.get(key);
            }
            colourMap.Source_description__c = brsColourCode.get(key);
            recordsToUpdateMap.put(colourMap.Source_Code__c,colourMap);
        }
        system.debug('Updating');
        return recordsToUpdateMap;
        //colourMaps = SObjectUtilities.MapByField(recordsToUpdate,Schema.Interior_Colour_Map__c.Source_Code__c.getDescribe());
        
    }

    /*
        Use this function when processing BRS messages
     */
    public static void UpdateSourceDescription(String code, String description){
        Interior_Colour_Map__c colourMap = GetColourMap(code);
        colourMap.Source_description__c = description;
        update colourMap;
    }

    public  Interior_Colour__c GetCodeForMarket(String code, String market){
    
        Interior_Colour__c colourMap;
     
        if(!String.isBlank(market) && !String.isBlank(code))
        {
            colourMap = GetCodeByMarket(code,market);
            if(colourMap == null) colourMap = CreateMarketCode(code, market);
        }
        return colourMap;
        
    }


    private static Interior_Colour_Map__c GetColourMap(String code){
        System.debug('colurMaps: '+colourMaps);
        if(!colourMaps.containsKey(code)) {
            Interior_Colour_Map__c colourMap = new Interior_Colour_Map__c(Source_Code__c = code);
            try{
                upsert colourMap;
            }
            catch(Exception e){
                
                colourMap=[select id,source_code__c from Interior_Colour_Map__c where source_code__c=:code limit 1];
                colourMaps.put(code,colourMap);
                return colourMap;    
                
            }
            colourMaps.put(code,colourMap);
            
        }
        return colourMaps.get(code);
    }

    public static Interior_Colour__c GetCodeByMarket(String code, String market){
     
        //List<Interior_Colour__c> colourMaps = [Select Id, CXP_Code__c, CXP_Description__c,Source_Code__c,market__c,source_description__c
          //                                          From Interior_Colour__c
            //                                        Where Source_Code__c=: code
              //                                      And Market__c=: market];

        //if(colourMaps.size() == 0) return null;
        //return colourMaps[0];
        Map<String,interior_colour__c> mapMarketToInteriorColour=colourMapMarkets.get(market);
        if(mapMarketToInteriorColour!=null)
            return mapMarketToInteriorColour.get(code);
        else
            return null;    
    }
    
    public static Map<Id,interior_Colour__c> GetMapPopulatedWithCodeByMarket(List<Interior_colour__c> listColours){
    
        Set<String> codes=new Set<String>();
        Set<String> markets=new Set<String>();
    
        for(Interior_colour__c colour:listColours)
        {
             codes.add(colour.Source_Code__c);
             markets.add(colour.market__c);
        
        }
     
        List<Interior_Colour__c> coloursList = [Select Id, CXP_Code__c, CXP_Description__c,Source_Code__c,market__c
                                                    From Interior_Colour__c
                                                    Where Source_Code__c in: codes
                                                    And Market__c in: markets];

        if(coloursList.size() == 0) return null;
            return new Map<id,interior_colour__c>(coloursList);
    }

    private  Interior_Colour__c CreateMarketCode(String code, String merket){
        //Get
        Interior_Colour_Map__c colourMap = GetColourMap(code);
        if(colourMap.CXP_Code__c == null || colourMap.CXP_Base_Description__c == null) return null;

        Interior_Colour__c interiorColour = new Interior_Colour__c();
        interiorColour.Source_Code__c = code;
        interiorColour.CXP_Code__c = colourMap.CXP_Code__c;
        interiorColour.CXP_Description__c = colourMap.CXP_Base_Description__c;
        interiorColour.source_description__c=colourMap.source_description__c;
        interiorColour.Market__c = merket;
        //insert interiorColour;
        
        Map<String,interior_colour__c> mapForMarket=new Map<String,interior_colour__c>();
        mapForMarket.put(interiorcolour.source_code__c,interiorColour);
        colourMapMarkets.put(merket,mapForMarket);
        
        return interiorColour;
    }


    /*
        Use this function to create missing interior colour records for a given market
     */
    public static void CreateMissingColourRecords(String country){
        List<Interior_Colour__c> colours = [Select Id, CXP_Code__c, CXP_Description__c, Source_Code__c
                                                From Interior_Colour__c
                                                Where Market__c=: country];

        Map<String,List<Interior_Colour__c>> coloursByCode = SObjectUtilities.MapByField(colours,Schema.Interior_Colour__c.Source_Code__c.getDescribe());

        List<Interior_Colour_Map__c> colourMaps = [Select Id, Source_Code__c, Source_description__c, CXP_Code__c, CXP_Base_Description__c
                                                    From Interior_Colour_Map__c];

        List<Interior_Colour__c> newColours = new List<Interior_Colour__c>();

        //Add new colours for this market
        for(Interior_Colour_Map__c colourMap : colourMaps){
            if(!coloursByCode.containsKey(colourMap.Source_Code__c)){
                if(colourMap.CXP_Code__c == null) continue;

                //need to create an entry for this market
                Interior_Colour__c newColour = new Interior_Colour__c();
                newColour.Source_Code__c = colourMap.Source_Code__c;
                newColour.CXP_Code__c = colourMap.CXP_Code__c;
                newColour.Market__c = country;
                newColour.CXP_Description__c = colourMap.CXP_Base_Description__c;
                newColour.source_description__c=colourMap.source_description__c;
                newColours.add(newColour);
            }
        }
        if(newColours.size() > 0 ) {
            insert newColours;
        }
    }
}
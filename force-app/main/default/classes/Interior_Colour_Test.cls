/**
 * Created by lbrindle on 06/09/2018.
 */
@IsTest
public with sharing class Interior_Colour_Test {

    public static testmethod void CreateMapRecord_WhenDoesNotExist(){
       // Interior_Colour colour = new Interior_Colour();
        Interior_Colour.UpdateSourceDescription('AAA','White');

        List<Interior_Colour_Map__c> colourMaps = [Select Source_Code__c, Source_description__c
                                                    From Interior_Colour_Map__c];

        system.assert(colourMaps.size() == 1);
    }

    public static testMethod void CreateColourSetting_WhenItIsMissing(){
        Interior_Colour_Map__c whiteMap = new Interior_Colour_Map__c();
        whiteMap.Source_Code__c = 'AAA';
        whiteMap.Source_description__c = 'White';
        whiteMap.CXP_Code__c = 'WHI';
        whiteMap.CXP_Base_Description__c = 'Tan';
        insert whiteMap;

        Interior_Colour colour = new Interior_Colour();
        colour.GetCodeForMarket('AAA','JP');
        colour.GetCodeForMarket('AAA','JP');
    }

    public static testmethod void CreateMultipleMapRecord_WhenDoesNotExist(){
        Interior_Colour colour = new Interior_Colour();
        Map<String,String> colourCodes = new Map<String,String>();
        colourCodes.put('AAA','White');
        colourCodes.put('AAB','Black');

        Map<String,Interior_Colour_Map__c> insertedMap=Interior_Colour.UpdateSourceDescription(colourCodes);

        system.assert(insertedMap.size() == 2);
    }

    public static testmethod void UpdateMapRecord_WhenDoesNotExist(){
        Interior_Colour colour = new Interior_Colour();
        Interior_Colour.UpdateSourceDescription('AAA','White');

        List<Interior_Colour_Map__c> colourMaps = [Select Source_Code__c, Source_description__c
                                                    From Interior_Colour_Map__c];
        system.assert(colourMaps.size() == 1);

        Interior_Colour.UpdateSourceDescription('AAB','Black');

        colourMaps = [Select Source_Code__c, Source_description__c
                        From Interior_Colour_Map__c];
        system.assert(colourMaps.size() == 2);

        //update the first code description
        Interior_Colour.UpdateSourceDescription('AAA','White/Red');

        colourMaps = [Select Source_Code__c, Source_description__c
        From Interior_Colour_Map__c];
        system.assert(colourMaps.size() == 2);
        system.assert(colourMaps[0].Source_description__c == 'White/Red');
    }

    public static testmethod void CreateRecordForMarket_WhenDoesNotExist(){
        List<Interior_Colour_Map__c> colourMapsToInsert = new List<Interior_Colour_Map__c>();

        Interior_Colour_Map__c whiteMap = new Interior_Colour_Map__c();
        whiteMap.Source_Code__c = 'AAA';
        whiteMap.Source_description__c = 'White';
        whiteMap.CXP_Code__c = 'WHI';
        whiteMap.CXP_Base_Description__c = 'Tan';
        colourMapsToInsert.add(whiteMap);

        Interior_Colour_Map__c redMap = new Interior_Colour_Map__c();
        redMap.Source_Code__c = 'AAB';
        redMap.Source_description__c = 'Red';
        redMap.CXP_Code__c = 'RED';
        redMap.CXP_Base_Description__c = 'Red';
        colourMapsToInsert.add(redMap);

        insert colourMapsToInsert;

        Interior_Colour.CreateMissingColourRecords('JP');

        List<Interior_Colour__c> colourMaps = [Select Source_Code__c, CXP_Description__c
                                                From Interior_Colour__c
                                                Where Market__c = 'JP' ];

        system.assert(colourMaps.size() == 2);
    }
    
    public static testmethod void test1(){
       Interior_Colour__c colour = new Interior_Colour__c();
       colour.CXP_Code__c='AAA';
       colour.Source_Code__c='BBB';
       colour.market__c='AU';
       Insert colour;
       Map<String ,Map<String, Interior_Colour__c>> InteriorColourMap=Interior_Colour.colourMapMarkets;
    }
}
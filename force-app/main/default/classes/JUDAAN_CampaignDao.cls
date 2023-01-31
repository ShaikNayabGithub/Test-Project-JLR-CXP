public without sharing class JUDAAN_CampaignDao {
        

    
    public static Map<Id, JUDAAN_Campaign__c> getActiveCampaignMapByProductIdList(List<String> productIdList){
      
       Datetime startdatetime = system.now();

System.debug('----startdatetime'+startdatetime);

String strdate=  startdatetime.format('yyyy-MM-dd' ,
                  'Asia/Singapore');
  
                  


     List<JUDAAN_Campaign__c> campaignList = [Select
                          Id
                                                    ,StartDate__c
                                                    ,EndDate__c
                           ,Product__c
                          ,EnglishDescription__c
                          ,JapaneseDescription__c,Campaign_Url_Text__c
                          ,RecordTypeId
                          ,RecordType.name
                           ,VIN_Asset_Level_ID__c
                          ,VIN_Level_Campaign_Text__c
                        From
                          JUDAAN_Campaign__c
                        Where
                          Product__c In :productIdList
                        And
                          StartDate__c <= :Date.valueof(strdate)
                        And
                          EndDate__c >= :Date.valueof(strdate)
                          And recordtype.name =: Label.Promotional_Banner  ];
    Map<Id, JUDAAN_Campaign__c> resultMap = new Map<Id, JUDAAN_Campaign__c>();
    for(JUDAAN_Campaign__c campaign : campaignList){
      resultMap.put(campaign.Product__c , campaign);
    }
    return resultMap;
    }
    
    public static Map<Id, JUDAAN_Campaign__c> getActiveCampaignMapByProductIdList(List<String> productIdList,string selectedMarket){
     system.debug('selmarketval==>'+selectedMarket);
     Datetime startdatetime = system.now(); 
   
   
  String osaMarket = selectedMarket == 'sg' ? 'Asia/Singapore' : selectedMarket == 'jp' ?  'Asia/Tokyo'  : selectedMarket == 'hk' ?  'Asia/Hong_Kong' : 'Europe/London' ; 

System.debug('----startdatetime'+startdatetime);

String strdate=  startdatetime.format('yyyy-MM-dd' ,
                  osaMarket);

      List<JUDAAN_Campaign__c> campaignList = [Select
                          Id
                                                    ,StartDate__c
                                                    ,EndDate__c
                           ,Product__c
                          ,EnglishDescription__c
                          ,JapaneseDescription__c,Campaign_Url_Text__c
                          ,RecordTypeId
                          ,RecordType.name
                          ,VIN_Asset_Level_ID__c
                          ,VIN_Level_Campaign_Text__c
                        From
                          JUDAAN_Campaign__c
                        Where
                          Product__c In :productIdList
                        And
                          StartDate__c <= :Date.valueof(strdate)
                        And
                          EndDate__c >= :Date.valueof(strdate)
                        And Market__c=:selectedMarket
                        And recordtype.name =: Label.Promotional_Banner];
    Map<Id, JUDAAN_Campaign__c> resultMap = new Map<Id, JUDAAN_Campaign__c>();
    for(JUDAAN_Campaign__c campaign : campaignList){
      resultMap.put(campaign.Product__c , campaign);
    }
    return resultMap;
    }
    
    public static List<JUDAAN_Campaign__c> getActiveCampaignByProductId(String productId){
    
    Datetime startdatetime = system.now();

    System.debug('----startdatetime'+startdatetime);

    String strdate=  startdatetime.format('yyyy-MM-dd' ,
                  'Asia/Singapore');
                  
                  
                  
   
     
      return [Select
          Id 
                    ,StartDate__c 
                    ,EndDate__c
           ,Product__c
          ,EnglishDescription__c
          ,JapaneseDescription__c,Market__c,Campaign_Url_Text__c
          ,Body_Style__c 
                          ,Model_Year__c 
                         ,RecordTypeId
                          ,RecordType.name
                          ,Specification_Pack_Alternative__c
                           ,VIN_Asset_Level_ID__c
                          ,VIN_Level_Campaign_Text__c
        From
          JUDAAN_Campaign__c
        Where
          Product__c = :productId
        And
          StartDate__c <= :Date.valueof(strdate)
        And
          EndDate__c >= :Date.valueof(strdate)
          And recordtype.name =: Label.Promotional_Banner
        ];
  }
  
  public static List<JUDAAN_Campaign__c> getActiveCampaignByProductId(String productId, string selectedMarket){
   
   
   Datetime startdatetime = system.now(); 
   
   
  String osaMarket = selectedMarket == 'sg' ? 'Asia/Singapore' : selectedMarket == 'jp' ?  'Asia/Tokyo'  : selectedMarket == 'hk' ?  'Asia/Hong_Kong' : 'Europe/London' ; 

System.debug('----startdatetime'+startdatetime);

String strdate=  startdatetime.format('yyyy-MM-dd' ,
                  osaMarket);
                  
                  

      return [Select
          Id 
                    ,StartDate__c 
                    ,EndDate__c
           ,Product__c
          ,EnglishDescription__c
          ,JapaneseDescription__c,Market__c,Campaign_Url_Text__c
          ,Body_Style__c 
                          ,Model_Year__c 
                         ,RecordTypeId
                          ,RecordType.name
                          ,Specification_Pack_Alternative__c
                           ,VIN_Asset_Level_ID__c
                          ,VIN_Level_Campaign_Text__c
        From
          JUDAAN_Campaign__c
        Where
          Product__c = :productId
        And
          StartDate__c <= :Date.valueof(strdate)
        And
          EndDate__c >= :Date.valueof(strdate)
        And
            Market__c =:selectedMarket
            And recordtype.name =: Label.Promotional_Banner];
  }
  
   public static Map<Id, List<JUDAAN_Campaign__c>> getActiveCampaignMapByProductIdListCampaign(List<String> productIdList,string selectedMarket,String recordTypeName){
     system.debug('selmarketval==>'+selectedMarket);
  Datetime startdatetime = system.now(); 
   
   
  String osaMarket = selectedMarket == 'sg' ? 'Asia/Singapore' : selectedMarket == 'jp' ?  'Asia/Tokyo'  : selectedMarket == 'hk' ?  'Asia/Hong_Kong' : 'Europe/London' ; 

System.debug('----startdatetime'+startdatetime);

String strdate=  startdatetime.format('yyyy-MM-dd' ,
                  osaMarket);

      List<JUDAAN_Campaign__c> campaignList = [Select
                          Id
                                                    ,StartDate__c
                                                    ,EndDate__c
                                                    
                           ,Product__c
                           ,Campaign_Url_Text__c
                          ,EnglishDescription__c
                          ,JapaneseDescription__c
                          ,Body_Style__c 
                          ,Model_Year__c 
                          ,RecordTypeId
                          ,RecordType.name
                          ,Specification_Pack_Alternative__c
                          ,VIN_Asset_Level_ID__c
                          ,VIN_Level_Campaign_Text__c
                        From
                          JUDAAN_Campaign__c
                        Where
                          Product__c In :productIdList
                        And
                          StartDate__c <= :Date.valueof(strdate)
                        And
                          EndDate__c >= :Date.valueof(strdate)
                        And Market__c=:selectedMarket
                        And recordtype.name =: recordTypeName];
    Map<Id, List<JUDAAN_Campaign__c>> resultMap = new Map<Id, List<JUDAAN_Campaign__c>>();
    for(JUDAAN_Campaign__c campaign : campaignList){
     
      if(!resultMap.containskey(campaign.Product__c ))
      resultMap.put(campaign.Product__c, new List<JUDAAN_Campaign__c> {campaign});
      else{
       resultMap.get(campaign.Product__c).add(campaign);
       
      }
      
    }
    return resultMap;
    }
    
    
    
    public static List<JUDAAN_Campaign__c> getActiveCampaignListByProductId(List<String> productIdList,string selectedMarket,String recordTypeName){
     
       Datetime startdatetime = system.now(); 
   
   
  String osaMarket = selectedMarket == 'sg' ? 'Asia/Singapore' : selectedMarket == 'jp' ?  'Asia/Tokyo'  : selectedMarket == 'hk' ?  'Asia/Hong_Kong' : 'Europe/London' ; 

System.debug('----startdatetime'+startdatetime);

String strdate=  startdatetime.format('yyyy-MM-dd' ,
                  osaMarket);
                  
       return [Select
          Id 
                    ,StartDate__c 
                    ,EndDate__c
                    ,Interior_Colour__c
                     
                    ,Exterior_Colour__c    
           ,Product__c
          ,EnglishDescription__c
          ,JapaneseDescription__c,Market__c,Campaign_Url_Text__c
          ,Body_Style__c 
          ,RecordTypeId
          ,recordtype.name
                          ,Model_Year__c 
                         
                          ,Specification_Pack_Alternative__c,
                          VIN_Asset_Level_ID__c,
                          VIN_Level_Campaign_Text__c
        From
          JUDAAN_Campaign__c
        Where
          Product__c  in :productIdList
        And
          StartDate__c <= :Date.valueof(strdate)
        And
          EndDate__c >= :Date.valueof(strdate)
          and
            Market__c =:selectedMarket
        And recordtype.name =: recordTypeName
        ];
  }
}
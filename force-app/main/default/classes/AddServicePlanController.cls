public without sharing class AddServicePlanController {
    @AuraEnabled
    public static Product2 getServicePlans(string assetId){
        Asset singleAsset = [SELECT Id,AccountId,Has_been_a_Rental__c, Account.RecordtypeId,Account.Name, Account.Owner.AccountId, Account.Region_or_Market__c,Handover_Date__c,warranty_start_date__c, Original_Handover_Date__c,
                             Brand__c,Model__c,Model__r.Service_Plan__c, Model__r.Service_Plan__r.Months__c, Country_ISO_Code__c,
                             Model__r.Service_Plan__r.Service_Interval_Distance__c, Model__r.Service_Plan__r.Service_Interval_Time__c,Model__r.Service_Plan__r.Number_of_Services__c
                             FROM Asset WHERE Id = :assetId AND Brand__c != null AND Model__c != null];
        User loggedUser = [SELECT Id,Name,Market__c,ContactId,Country_ISO_Code__c, profile.Name,Contact.Account.Country_ISO_Code__c,Contact.AccountId,Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        List<Service_Plan_Market_Setting__mdt> marketSetList = [select id,Country_ISO_Code__c,Service_Plan_Level__c,Region__c 
                                                                from Service_Plan_Market_Setting__mdt
                                                                WHERE Country_ISO_Code__c =: loggedUser.Country_ISO_Code__c 
                                                                AND Region__c =: loggedUser.Market__c];
        if(marketSetList != null && !marketSetList.isEmpty()){
            Service_Plan_Market_Setting__mdt marktSetIns = marketSetList.get(0);
            if(marktSetIns != null 
               && marktSetIns.Service_Plan_Level__c != null
               && marktSetIns.Service_Plan_Level__c == 'Model'){
                   List<Service_Plans_Model__c> modelList = [select 
                                                             id,Auto_Add_Extended_Plan__c,Brand__c,Complementary_Service_Plan__c,
                                                             Complementary_Service_Plan__r.name,
                                                             Complementary_Service_Plan__r.Months__c,
                                                             Complementary_Service_Plan__r.CurrencyIsoCode,
                                                             Complementary_Service_Plan__r.Service_Interval_Distance__c,
                                                             Complementary_Service_Plan__r.Service_Interval_Time__c,
                                                             Complementary_Service_Plan__r.Number_of_Services__c,
                                                             Complementary_Service_Plan__r.Mileage_Months__c,                                                            
                                                             Complementary_Service_Plan__r.Mileage_Measure__c,
                                                             Complementary_Service_Plan__r.Service_Plan_Type__c,
                                                             Complementary_Service_Plan__r.Miles_Kilometers__c
                                                             FROM Service_Plans_Model__c
                                                             WHERE Brand__c =: singleAsset.Brand__c
                                                             AND Brand__c != null
                                                             AND Region_or_Market__c =: loggedUser.Market__c
                                                             AND Model__c =: singleAsset.Model__c];
                   if(modelList != null && !modelList.isEmpty()){
                       Service_Plans_Model__c spmModel = modelList.get(0);
                       Product2 servicePlan = [select 
                                               id,Name,Service_Plan__c,Months__c,Mileage_Months__c,Miles_Kilometers__c,Mileage_Measure__c,
                                               Number_of_Services__c,Service_Interval_Distance__c,Service_Interval_Time__c,Service_Plan_Type__c
                                               from Product2 where id =: spmModel.Complementary_Service_Plan__c];
                       return servicePlan;
                   }
               }
        }
        return null;
    }
    
    @AuraEnabled
    public static AddServicePlanWrap addForServicePlanContract(boolean isRetailer, boolean isCorporate, string offerId, string assetId, Date startDate, boolean isCompSp){
        System.debug('ENTERED addForServicePlanContract'+isCompSp +isRetailer);
        System.debug('startDate --> '+startDate);
        AddServicePlanWrap AddServicePlanWrapIns = new AddServicePlanWrap();
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        User loggedUser = [SELECT Id,Name,Market__c,ContactId,Country_ISO_Code__c, profile.Name,Contact.Account.Country_ISO_Code__c,Contact.AccountId,Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        Asset singleAsset = [SELECT Id,AccountId,Has_been_a_Rental__c, Account.RecordtypeId,Account.Name, Account.Owner.AccountId, Account.Region_or_Market__c,Handover_Date__c,warranty_start_date__c, Original_Handover_Date__c,
                             Derivative__c,Derivative__r.Service_Plan__c, Derivative__r.Service_Plan__r.Months__c, Derivative__r.Service_Plan__r.Mileage_Months__c,
                             Derivative__r.Service_Plan__r.Miles_Kilometers__c,Derivative__r.Service_Plan__r.Mileage_Measure__c,Derivative__r.Service_Plan__r.Service_Plan_Type__c,
                             Derivative__r.Service_Plan__r.Service_Interval_Distance__c, Derivative__r.Service_Plan__r.Service_Interval_Time__c,Derivative__r.Service_Plan__r.Number_of_Services__c,
                             Brand__c,Model__c,Model__r.Service_Plan__c, Model__r.Service_Plan__r.Months__c, 
                             Model__r.Service_Plan__r.Service_Interval_Distance__c, Model__r.Service_Plan__r.Service_Interval_Time__c,Model__r.Service_Plan__r.Number_of_Services__c
                             FROM Asset WHERE Id = :assetId ];
        
        Product2 servicePlan;
        Product2 extendedServicePlan;
        Boolean autoAddExtendedServicePlan = false;
        List<Service_Plans_Model__c> sevicePlanList = [SELECT Id, OwnerId,Auto_Add_Extended_Plan__c,Extended_Service_Plan__c, IsDeleted, Name, Brand__c, Model__c, Region_or_Market__c, Complementary_Service_Plan__c
                                                       FROM 
                                                       Service_Plans_Model__c 
                                                       where 
                                                       Brand__c =: singleAsset.Brand__c 
                                                       AND Model__c =: singleAsset.Model__c
                                                       AND Region_or_Market__c =: loggedUser.Market__c
                                                       AND Complementary_Service_Plan__c != null];
        system.debug('sevicePlanList --> '+json.serializePretty(sevicePlanList));
        
        if(sevicePlanList != null && !sevicePlanList.isEmpty()){
            servicePlan = [select 
                           id,Service_Plan__c,Months__c,Mileage_Months__c,Miles_Kilometers__c,Mileage_Measure__c,
                           Number_of_Services__c,Service_Interval_Distance__c,Service_Interval_Time__c,Service_Plan_Type__c
                           from Product2 where id =: sevicePlanList.get(0).Complementary_Service_Plan__c];
            
            if(sevicePlanList.get(0).Extended_Service_Plan__c != null){
                autoAddExtendedServicePlan = sevicePlanList.get(0).Auto_Add_Extended_Plan__c;
                if(autoAddExtendedServicePlan){
                    extendedServicePlan = [select 
                                           id,Service_Plan__c,Months__c,Mileage_Months__c,Miles_Kilometers__c,Mileage_Measure__c,
                                           Number_of_Services__c,Service_Interval_Distance__c,Service_Interval_Time__c,Service_Plan_Type__c
                                           from Product2 where id =: sevicePlanList.get(0).Extended_Service_Plan__c];
                }
            }
            system.debug('extendedServicePlan --> '+json.serializePretty(extendedServicePlan));
            system.debug('autoAddExtendedServicePlan --> '+autoAddExtendedServicePlan);
        }
        
        Service_Plan_Market_Setting__mdt marktSetIns;
        
        List<Service_Plan_Market_Setting__mdt> marketSetList = [select id,Country_ISO_Code__c,Service_Plan_Level__c,Region__c 
                                                                from Service_Plan_Market_Setting__mdt
                                                                WHERE Country_ISO_Code__c =: loggedUser.Country_ISO_Code__c 
                                                                AND Region__c =: loggedUser.Market__c];
        if(marketSetList != null && !marketSetList.isEmpty()){
            marktSetIns = marketSetList.get(0);
        }
        system.debug('marktSetIns --> '+json.serializePretty(marktSetIns));
        string countrIsoCode;
        if(loggedUser.profile.Name.endsWithIgnoreCase('AUS') || loggedUser.profile.Name=='JLR System Administrator (Super)')
            countrIsoCode='AU';
        else if(loggedUser.Country_ISO_Code__c !=null) 
            countrIsoCode=loggedUser.Country_ISO_Code__c;
        else if(loggedUser.ContactId !=null && loggedUser.Contact.Account.Country_ISO_Code__c !=null)
            countrIsoCode=loggedUser.Contact.Account.Country_ISO_Code__c;
        
        Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
        spc.Service_Plan_Contract_Status__c = 'Submitted';
        Service_Plan_Contract__c extenspc = new Service_Plan_Contract__c();
        extenspc.Service_Plan_Contract_Status__c = 'Submitted';
        if(loggedUser != null && loggedUser.ContactId != null){
            spc.Retailer_Id__c = loggedUser.Contact.AccountId;
            if(autoAddExtendedServicePlan) extenspc.Retailer_Id__c = loggedUser.Contact.AccountId;
        }else if(loggedUser !=null)
        {
            spc.Retailer_Id__c =singleAsset.Account.RecordtypeId == retailerRecordTypeId ? singleAsset.AccountId :singleAsset.Account.Owner.AccountId;
            if(autoAddExtendedServicePlan) extenspc.Retailer_Id__c = singleAsset.Account.RecordtypeId == retailerRecordTypeId ? singleAsset.AccountId :singleAsset.Account.Owner.AccountId;
        }
        
        spc.Vehicle_Id__c = singleAsset.Id; 
        if(autoAddExtendedServicePlan) extenspc.Vehicle_Id__c = singleAsset.Id; 
        
        if(startDate !=null)
        {
            spc.Start_Date__c = startDate; 
            spc.Country_ISO_Code__c=countrIsoCode;
            spc.Market__c=loggedUser.Market__c !=null ?loggedUser.Market__c: singleAsset.Account.Region_or_Market__c;  
            
        }else if(singleAsset.warranty_start_date__c != null){
            spc.Start_Date__c = singleAsset.warranty_start_date__c;
        }else{
            spc.Start_Date__c = singleAsset.Handover_Date__c ;
        }
        
        if(isCompSp)
        {
            spc.Country_ISO_Code__c=countrIsoCode;
            spc.Market__c=loggedUser.Market__c !=null ?loggedUser.Market__c: singleAsset.Account.Region_or_Market__c;
            system.debug('autoAddExtendedServicePlan --> '+autoAddExtendedServicePlan);
            if(autoAddExtendedServicePlan){
                extenspc.Country_ISO_Code__c=countrIsoCode; 
                extenspc.Market__c=loggedUser.Market__c !=null ?loggedUser.Market__c: singleAsset.Account.Region_or_Market__c;  
                system.debug('extenspc --> '+json.serializePretty(extenspc));
            }
            if(spc.Market__c=='APIO' && ! system.label.CXP_AUTO_SPC_ON_HANDOVER.contains(countrIsoCode))
                throw new AuraHandledException(label.SPC_Complimentary_service_plan_is_not_applicable);
        }
        
        
        if(marktSetIns != null 
           && marktSetIns.Service_Plan_Level__c != null
           && marktSetIns.Service_Plan_Level__c == 'Derivative'
           && singleAsset.Derivative__c  != null 
           && singleAsset.Derivative__r.Service_Plan__c  != null 
           && singleAsset.Derivative__r.Service_Plan__r.Months__c != null ){
               
               if( spc.Start_Date__c != null ){
                   spc.End_Date__c = spc.Start_Date__c.addMonths(singleAsset.Derivative__r.Service_Plan__r.Months__c.intValue()).addDays(-1);  
               }
               
               spc.Contract_Term_Months__c = singleAsset.Derivative__r.Service_Plan__r.Months__c.intValue();
               spc.Service_Plan_Product__c =  singleAsset.Derivative__r.Service_Plan__c;
               
           }else if(marktSetIns != null 
                    && marktSetIns.Service_Plan_Level__c != null
                    && marktSetIns.Service_Plan_Level__c == 'Model' 
                    && servicePlan  != null 
                    && servicePlan != null 
                    && servicePlan.Months__c != null ){
                        
                        if( spc.Start_Date__c != null ){
                            spc.End_Date__c = spc.Start_Date__c.addMonths(servicePlan.Months__c.intValue()).addDays(-1);  
                        }
                        
                        spc.Contract_Term_Months__c = servicePlan.Months__c.intValue();
                        spc.Service_Plan_Product__c =  servicePlan.Id;
                        
                        if(autoAddExtendedServicePlan  
                           && extendedServicePlan  != null 
                           && extendedServicePlan != null 
                           && extendedServicePlan.Months__c != null){
                               
                               if( spc.End_Date__c != null ){
                                   extenspc.Start_Date__c = spc.End_Date__c.addDays(1);  
                               }
                               
                               if( extenspc.Start_Date__c != null ){
                                   extenspc.End_Date__c = spc.End_Date__c.addMonths(extendedServicePlan.Months__c.intValue()).addDays(-1);  
                               }
                               
                               extenspc.Contract_Term_Months__c = extendedServicePlan.Months__c.intValue();
                               extenspc.Service_Plan_Product__c =  extendedServicePlan.Id;
                               System.debug('extenspc1 '+Json.serializePretty(extenspc));
                           }
                    }      
        
        
        if(isCorporate){
            spc.Assignment_Type__c = 'Corporate';  
            if(offerId != null && offerId != ''){
                Offers__c off =  [SELECT Id,Corporate_Partner__c  FROM Offers__c WHERE Id = :offerId  ];
                spc.Corporate_Partner__c = off.Corporate_Partner__c; 
            }   
            
        } 
        
        if(marktSetIns != null 
           && marktSetIns.Service_Plan_Level__c != null
           && marktSetIns.Service_Plan_Level__c == 'Derivative'){
               if(isRetailer || isCompSp){
                   string spProductId=singleAsset.Derivative__r.Service_Plan__c;    
                   string querystring= 'select id, Product2Id, UnitPrice,CurrencyIsoCode  from PriceBookEntry where priceBook2.IsActive=true AND IsActive=true AND product2Id=:spProductId ';
                   if(countrIsoCode=='AU')
                   {
                       querystring+=' AND priceBook2.Name= \'Australia\'';
                   }else{
                       querystring+=' AND priceBook2.Country_Iso_Code__c=:countrIsoCode';
                   }
                   
                   Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id,PriceBookEntry>();  
                   for(PricebookEntry pbe : database.query(querystring)){
                       system.debug('PricebookEntry '+json.serialize(pbe));
                       priceBookEntryMap.put(pbe.Product2Id, pbe);               
                   }
                   decimal  price = 0;
                   if(isRetailer && singleAsset.Derivative__c != null && singleAsset.Derivative__r.Service_Plan__c != null && priceBookEntryMap.containsKey(singleAsset.Derivative__r.Service_Plan__c) && priceBookEntryMap.get(singleAsset.Derivative__r.Service_Plan__c ).UnitPrice != null){
                       price = priceBookEntryMap.get(singleAsset.Derivative__r.Service_Plan__c ).UnitPrice;
                   }
                   else if(!priceBookEntryMap.containsKey(singleAsset.Derivative__r.Service_Plan__c) && spc.Market__c=='APIO')
                       throw new AuraHandledException(label.SPC_Service_plan_is_not_active_in_the_pricebook);
                   
                   
                   
                   system.debug('Did price right'+price);
                   spc.Assignment_Type__c = isCompSp ? 'Complimentary':'Retail';    
                 //  spc.Retail_Purchase_Price__c = isCompSp ? null:price;
                   spc.Service_Interval_Distance__c=singleAsset.Derivative__r.Service_Plan__r.Service_Interval_Distance__c;
                   spc.Service_Interval_Time__c=singleAsset.Derivative__r.Service_Plan__r.Service_Interval_Time__c;
                   spc.Number_of_Services__c=singleAsset.Derivative__r.Service_Plan__r.Number_of_Services__c;
                   spc.Retailer_Name__c = singleAsset.Account.Name;
                   spc.Purchased_Date__c = system.today();
                   if(!isCompSp) spc.Sold_By__c = loggedUser.Name;
                   spc.Activated_By__c = loggedUser.Id;
                   
                   spc.Mileage_Months_SPC__c = singleAsset.Derivative__r.Service_Plan__r.Mileage_Months__c;
                   if(singleAsset.Derivative__r.Service_Plan__r.Miles_Kilometers__c != null && singleAsset.Derivative__r.Service_Plan__r.Mileage_Measure__c != null){
                       spc.Mileage_SPC__c = String.valueOf(singleAsset.Derivative__r.Service_Plan__r.Miles_Kilometers__c)+''+String.valueOf(singleAsset.Derivative__r.Service_Plan__r.Mileage_Measure__c);
                   }
                   spc.Months_spc__c = singleAsset.Derivative__r.Service_Plan__r.Months__c;
                   spc.Service_Plan_Type_SPC__c = singleAsset.Derivative__r.Service_Plan__r.Service_Plan_Type__c;
                   if(spc.Vehicle_Id__c != null && spc.Vehicle_Id__r.VIN__c != null && spc.Service_Plan_Incremental__c != null){
                       spc.Service_Plan_Reference_spc__c = spc.Vehicle_Id__r.VIN__c.mid(4,2)+'-CXP-'+spc.Vehicle_Id__r.VIN__c.right(6)+'-'+spc.Service_Plan_Incremental__c;
                   }
                   if(spc.End_Date__c != null && spc.Start_Date__c != null){
                       spc.Service_Plan_Length_Check_SPC__c = (spc.End_Date__c.daysBetween(spc.Start_Date__c))/365;
                   }
                   
               }  
           }else  if(marktSetIns != null 
                     && marktSetIns.Service_Plan_Level__c != null
                     && marktSetIns.Service_Plan_Level__c == 'Model'){ 
                         if(isRetailer || isCompSp){
                             string spProductId=servicePlan.Id;    
                             string querystring= 'select id, Product2Id, UnitPrice,CurrencyIsoCode  from PriceBookEntry where priceBook2.IsActive=true AND IsActive=true AND product2Id=:spProductId ';
                             if(countrIsoCode=='AU')
                             {
                                 querystring+=' AND priceBook2.Name= \'Australia\'';
                             }else{
                                 querystring+=' AND priceBook2.Country_Iso_Code__c=:countrIsoCode';
                             }
                             
                             Map<Id, PriceBookEntry> priceBookEntryMap = new Map<Id,PriceBookEntry>();  
                             for(PricebookEntry pbe : database.query(querystring)){
                                 system.debug('PricebookEntry '+json.serialize(pbe));
                                 priceBookEntryMap.put(pbe.Product2Id, pbe);               
                             }
                             decimal  price = 0;
                             if(isRetailer && singleAsset.Model__c != null && servicePlan.Id != null && priceBookEntryMap.containsKey(servicePlan.Id) && priceBookEntryMap.get(servicePlan.Id ).UnitPrice != null){
                                 price = priceBookEntryMap.get(servicePlan.Id ).UnitPrice;
                             }
                             if(isRetailer && singleAsset.Model__c != null && servicePlan.Id != null && priceBookEntryMap.containsKey(servicePlan.Id) && priceBookEntryMap.get(servicePlan.Id ).currencyisocode != null){
                                 spc.currencyisocode = priceBookEntryMap.get(servicePlan.Id ).currencyisocode;
                             }
                             else if(!priceBookEntryMap.containsKey(servicePlan.Service_Plan__c) && spc.Market__c=='APIO')
                                 throw new AuraHandledException(label.SPC_Service_plan_is_not_active_in_the_pricebook);
                             
                             
                             
                             system.debug('AP Did price right'+price);
                             spc.Assignment_Type__c = isCompSp ? 'Complimentary':'Retail';    
                           //  spc.Retail_Purchase_Price__c = isCompSp ? null:price;
                             spc.Service_Interval_Distance__c=servicePlan.Service_Interval_Distance__c;
                             spc.Service_Interval_Time__c=servicePlan.Service_Interval_Time__c;
                             spc.Number_of_Services__c=servicePlan.Number_of_Services__c;
                             spc.Retailer_Name__c = singleAsset.Account.Name;
                             spc.Rental_Car__c = singleAsset.Has_been_a_Rental__c;
                             spc.Purchased_Date__c = system.today();
                             if(!isCompSp) spc.Sold_By__c = loggedUser.Name;
                             spc.Activated_By__c = loggedUser.Id;
                             
                             
                             spc.Mileage_Months_SPC__c = servicePlan.Mileage_Months__c;
                             if(servicePlan.Miles_Kilometers__c != null && servicePlan.Mileage_Measure__c != null){
                                 spc.Mileage_SPC__c = String.valueOf(servicePlan.Miles_Kilometers__c)+' '+String.valueOf(servicePlan.Mileage_Measure__c);
                             }
                             spc.Months_spc__c = servicePlan.Months__c;
                             spc.Service_Plan_Type_SPC__c = servicePlan.Service_Plan_Type__c;
                             if(spc.Vehicle_Id__c != null && spc.Vehicle_Id__r.VIN__c != null && spc.Service_Plan_Incremental__c != null){
                                 spc.Service_Plan_Reference_spc__c = spc.Vehicle_Id__r.VIN__c.mid(4,2)+'-CXP-'+spc.Vehicle_Id__r.VIN__c.right(6)+'-'+spc.Service_Plan_Incremental__c;
                             }
                             if(spc.End_Date__c != null && spc.Start_Date__c != null){
                                 spc.Service_Plan_Length_Check_SPC__c = (spc.End_Date__c.daysBetween(spc.Start_Date__c))/365;
                             }
                             
                             
                             if(autoAddExtendedServicePlan){
                                 system.debug('extenspc --> '+json.serializePretty(extenspc));
                                 decimal  extprice = 0;
                                 if(isRetailer && extendedServicePlan.Model__c != null && extendedServicePlan.Id != null && priceBookEntryMap.containsKey(extendedServicePlan.Id) && priceBookEntryMap.get(extendedServicePlan.Id ).UnitPrice != null){
                                     extprice = priceBookEntryMap.get(servicePlan.Id ).UnitPrice;
                                 }
                                 system.debug('Did Ext price right'+extprice);
                                 extenspc.Assignment_Type__c = 'Extended';    
                                 extenspc.Retail_Purchase_Price__c = extprice; 
                                 extenspc.Service_Interval_Distance__c=extendedServicePlan.Service_Interval_Distance__c;
                                 extenspc.Service_Interval_Time__c=extendedServicePlan.Service_Interval_Time__c;
                                 extenspc.Number_of_Services__c=extendedServicePlan.Number_of_Services__c;
                                 extenspc.Retailer_Name__c = singleAsset.Account.Name;
                                 extenspc.Purchased_Date__c = system.today();
                                 if(!isCompSp) extenspc.Sold_By__c = loggedUser.Name;
                                 extenspc.Activated_By__c = loggedUser.Id;
                                 
                                 extenspc.Mileage_Months_SPC__c = extendedServicePlan.Mileage_Months__c;
                                 if(extendedServicePlan.Miles_Kilometers__c != null
                                    && extendedServicePlan.Mileage_Measure__c != null){
                                        extenspc.Mileage_SPC__c = String.valueOf(extendedServicePlan.Miles_Kilometers__c)+' '+String.valueOf(extendedServicePlan.Mileage_Measure__c);
                                    }
                                 extenspc.Months_spc__c = extendedServicePlan.Months__c;
                                 extenspc.Service_Plan_Type_SPC__c = extendedServicePlan.Service_Plan_Type__c;
                                 if(extenspc.Vehicle_Id__c != null
                                    && extenspc.Vehicle_Id__r.VIN__c != null
                                    && extenspc.Service_Plan_Incremental__c != null){
                                        extenspc.Service_Plan_Reference_spc__c = extenspc.Vehicle_Id__r.VIN__c.mid(4,2)+'-CXP-'+extenspc.Vehicle_Id__r.VIN__c.right(6)+'-'+extenspc.Service_Plan_Incremental__c;
                                    }
                                 if(extenspc.End_Date__c != null && extenspc.Start_Date__c != null){
                                     extenspc.Service_Plan_Length_Check_SPC__c = (extenspc.End_Date__c.daysBetween(extenspc.Start_Date__c))/365;
                                 }
                             }
                         }
                     }
        
        System.debug('spc '+Json.serializePretty(spc));
        System.debug('extenspc '+Json.serializePretty(extenspc));
        System.debug('FINISHED addForServicePlanContract');
        try{
            insert spc;
            
            Service_Plan_Contract__c updatedSpc = [select id,Service_Plan_Reference__c,Service_Plan_Incremental__c,Service_Plan_Length_Check__c 
                                                   from Service_Plan_Contract__c where id =: spc.Id];
            if(updatedSpc.Service_Plan_Reference__c != null){
                spc.Service_Plan_Reference_spc__c  = updatedSpc.Service_Plan_Reference__c;
            }
            if(updatedSpc.Service_Plan_Length_Check__c != null){
                spc.Service_Plan_Length_Check_SPC__c = updatedSpc.Service_Plan_Length_Check__c;
            }
            update spc;
            
            if(autoAddExtendedServicePlan){
                AddServicePlanWrapIns.autoAddExtService = true;
                insert extenspc;
                
                Service_Plan_Contract__c updatedExtSpc = [select id,Service_Plan_Reference__c,Service_Plan_Incremental__c,Service_Plan_Length_Check__c 
                                                          from Service_Plan_Contract__c where id =: extenspc.Id];
                if(updatedExtSpc.Service_Plan_Reference__c != null){
                    extenspc.Service_Plan_Reference_spc__c  = updatedExtSpc.Service_Plan_Reference__c;
                }
                if(updatedExtSpc.Service_Plan_Length_Check__c != null){
                    extenspc.Service_Plan_Length_Check_SPC__c = updatedExtSpc.Service_Plan_Length_Check__c;
                }
                update extenspc;
                
            }else{
                AddServicePlanWrapIns.autoAddExtService = false;
            }
            AddServicePlanWrapIns.servicePlanContractId = spc.Id; 
        }catch(exception e){
            system.debug('Ex --> '+e.getMessage());
            system.debug('Ex1 --> '+e.getStackTraceString());
            if(e.getMessage().contains(system.label.SPC_Duplicate_validation_Erorr))
                throw new AuraHandledException(system.label.SPC_Duplicate_validation_Erorr);
        }
        return AddServicePlanWrapIns;
    }   
    
    public class AddServicePlanWrap{
        @AuraEnabled public Boolean autoAddExtService;
        @AuraEnabled public String message;
        @AuraEnabled public id servicePlanContractId;
    }
}
public without sharing class ExtendServicePlanController {
    
    @AuraEnabled
    public static date getPolicyEndDate(string assetId){
        date policyEndDate;
        user u=[select id, Market__c, profile.Name, Contact.Account.Country_ISO_Code__c, Country_ISO_Code__c from user where ID=:userinfo.getUserId()];
        string countrIsoCode;
        if(u.Country_ISO_Code__c !=null)
            countrIsoCode=u.Country_ISO_Code__c;
        else if(u.ContactId !=null && u.Contact.Account.Country_ISO_Code__c !=null)
            countrIsoCode=u.Contact.Account.Country_ISO_Code__c;
        list<Service_Plan_Contract__c> spcLst=[SELECT Id, 
                                               Actual_End_Date__c, 
                                               Country_ISO_Code__c, 
                                               Is_Active__c 
                                               FROM Service_Plan_Contract__c  
                                               WHERE Vehicle_Id__c = :assetId
                                               AND Country_ISO_Code__c=:countrIsoCode
                                               Order by Actual_End_Date__c DESC nulls last LIMIT 1];
        if(!spcLst.isEmpty())
            policyEndDate=spcLst[0].Actual_End_Date__c+1;
        return policyEndDate;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PriceBookEntry> getRecords(String searchString){
        searchString = String.escapeSingleQuotes(searchString);
        searchString = '%'+searchString+'%';
        
        user u=[select id, Market__c, profile.Name, Contact.Account.Country_ISO_Code__c, Country_ISO_Code__c from user where ID=:userinfo.getUserId()];
        string countrIsoCode;
        if(u.Country_ISO_Code__c !=null)
            countrIsoCode=u.Country_ISO_Code__c;
        else if(u.ContactId !=null && u.Contact.Account.Country_ISO_Code__c !=null)
            countrIsoCode=u.Contact.Account.Country_ISO_Code__c;
        
        Id servicePlanRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
        
        
        List<PriceBookEntry> pbe=[select id, 
                                  product2Id, 
                                  product2.Name,
                                  product2.ProductCode,
                                  product2.Service_Interval_Distance__c,
                                  product2.Service_Interval_Time__c,
                                  product2.Number_of_Services__c,
                                  Pricebook2Id 
                                  from PriceBookEntry 
                                  Where priceBook2.Country_Iso_Code__c=:countrIsoCode AND 
                                  product2.recordTypeId=:servicePlanRecordTypeId AND 
                                  product2.Service_Plan_Type__c='Extended' AND 
                                  priceBook2.IsActive=true AND 
                                  IsActive=true AND
                                  (product2.Name LIKE :searchString OR product2.ProductCode LIKE:searchString)];
        
        Return pbe;
    }
    
    @AuraEnabled
    public static string addForServicePlanContract(string assetId, string productId, Date startDate,Boolean rentalCar){
        System.debug('ENTERED addForServicePlanContract');
        System.debug('rentalCar --> '+rentalCar);
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        User loggedUser = [SELECT Id,Name,ContactId,Contact.AccountId, Market__c, Contact.Account.Country_ISO_Code__c, Country_ISO_Code__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        asset selectedAsset=[select id, accountId,Account.Name, Account.Region_or_Market__c, account.recordTypeId from asset Where Id=:assetId limit 1];
        
        string countrIsoCode;
        if(loggedUser.Country_ISO_Code__c !=null)
            countrIsoCode=loggedUser.Country_ISO_Code__c;
        else if(loggedUser.ContactId !=null && loggedUser.Contact.Account.Country_ISO_Code__c !=null)
            countrIsoCode=loggedUser.Contact.Account.Country_ISO_Code__c;
        
        List<PriceBookEntry> pbe=[select id, 
                                  product2Id,
                                  UnitPrice,
                                  currencyisocode,
                                  product2.Months__c,
                                  product2.Service_Interval_Distance__c,
                                  product2.Service_Interval_Time__c,
                                  product2.Number_of_Services__c,
                                  product2.Mileage_Months__c,
                                  product2.Mileage_Measure__c,
                                  product2.Service_Plan_Type__c,
                                  product2.Miles_Kilometers__c
                                  from PriceBookEntry 
                                  Where priceBook2.Country_Iso_Code__c=:countrIsoCode AND 
                                  product2.Service_Plan_Type__c='Extended' AND 
                                  priceBook2.IsActive=true AND 
                                  IsActive=true AND
                                  product2Id=:productId];
        
        if(!pbe.isEmpty())   
        {
            Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
            spc.Retailer_Id__c = loggedUser.Contact.AccountId;
            spc.Vehicle_Id__c = assetId; 
            spc.Start_Date__c = startDate;
            if(rentalCar != null){
                spc.Rental_Car__c = rentalCar;
            }
            spc.CurrencyIsoCode = pbe[0].currencyisocode;
            spc.Retailer_Name__c = selectedAsset.Account.Name;
            spc.Purchased_Date__c = system.today();
            spc.Sold_By__c = loggedUser.Name;
            spc.Activated_By__c = loggedUser.Id;
            
            if(pbe[0].Product2.Months__c != null ){
                if( spc.Start_Date__c != null ){
                    spc.End_Date__c = spc.Start_Date__c.addMonths(pbe[0].Product2.Months__c.intValue()).addDays(-1);  
                }
                
                spc.Contract_Term_Months__c = pbe[0].Product2.Months__c.intValue();
            }           
            
            spc.Service_Plan_Product__c =  productId;
            spc.Assignment_Type__c = 'Extended';  
            decimal  price = 0;
            if(pbe[0].UnitPrice != null){
                price = pbe[0].UnitPrice;
            }
            spc.Retail_Purchase_Price__c = price;
            spc.Country_ISO_Code__c=countrIsoCode;
            spc.Market__c=loggedUser.Market__c !=null ?loggedUser.Market__c: selectedAsset.Account.Region_or_Market__c;
            
            spc.Service_Interval_Distance__c=pbe[0].product2.Service_Interval_Distance__c;
            spc.Service_Interval_Time__c=pbe[0].product2.Service_Interval_Time__c;
            spc.Number_of_Services__c=pbe[0].product2.Number_of_Services__c;
            
            spc.Mileage_Months_SPC__c = pbe[0].product2.Mileage_Months__c;
            if(pbe[0].product2.Miles_Kilometers__c != null
               && pbe[0].product2.Mileage_Measure__c != null){
                   spc.Mileage_SPC__c = String.valueOf(pbe[0].product2.Miles_Kilometers__c)+' '+String.valueOf(pbe[0].product2.Mileage_Measure__c);
               }
            spc.Months_spc__c = pbe[0].product2.Months__c;
            spc.Service_Plan_Type_SPC__c = pbe[0].product2.Service_Plan_Type__c;
            if(spc.Vehicle_Id__c != null && spc.Vehicle_Id__r.VIN__c != null && spc.Service_Plan_Incremental__c != null){
                spc.Service_Plan_Reference_spc__c = spc.Vehicle_Id__r.VIN__c.mid(4,2)+'-CXP-'+spc.Vehicle_Id__r.VIN__c.right(6)+'-'+spc.Service_Plan_Incremental__c;
            }
            if(spc.End_Date__c != null && spc.Start_Date__c != null){
                spc.Service_Plan_Length_Check_SPC__c = (spc.End_Date__c.daysBetween(spc.Start_Date__c))/365;
            }
            
            System.debug('spc '+Json.serializePretty(spc));
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
                if(assetId != null && spc.Rental_Car__c){
                    Asset assetIns = new Asset();
                    assetIns.Id = assetId;
                    assetIns.Has_been_a_Rental__c = spc.Rental_Car__c;
                    update assetIns;
                }
                
                return spc.Id; 
            }catch(exception e){
                system.debug('--> '+e.getLineNumber()+' -- '+e.getStackTraceString());
                if(e.getMessage().contains(system.label.SPC_Duplicate_validation_Erorr))
                    throw new AuraHandledException(system.label.SPC_Duplicate_validation_Erorr);
            }
        }
        return null;
    }
    @AuraEnabled
    public static ExtendServicePlanWrap getAssetData(string assetId){
        ExtendServicePlanWrap ExtendServicePlanWrapIns = new ExtendServicePlanWrap();
        Asset assetIns = new Asset();
        User loggedUser = [SELECT Id,Name,Market__c,ContactId,Country_ISO_Code__c, profile.Name,Contact.Account.Country_ISO_Code__c,Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        
        List<Asset> asses = [SELECT Id,Has_been_a_Rental__c,Product2.Product_Description__c,is_New_Vehicle__c, Name, Model__c,  Brand__r.Name, Model__r.Name, Product2.Model_Year__c,Account.Country_Iso_code__c,
                             AccountId,AccountCountryCode__c, Registration_Number__c, VIN__c,  Handover_Date__c, Warranty_End_Date__c, Warranty_Start_Date__c, Extended_Warranty_End_Date__c, Original_Handover_Date__c,
                             Derivative__r.Name, Derivative__r.Service_Plan__c, Derivative__r.Service_Plan__r.Service_Plan_Type__c, Derivative__r.Service_Plan__r.Name, Model_Year__c, Transmission__c, Exterior_Colour__c, Model_Code__c,Vista_Status__c,Common_Sale_Type__c,Sale_Type_Code__c
                             FROM Asset WHERE id =: assetId ];
        if(asses != null && !asses.isEmpty())
            assetIns =  asses.get(0);
        List<Service_Plans_Model__c> sevicePlanList = [SELECT Id, OwnerId,Auto_Add_Extended_Plan__c,
                                                       Extended_Service_Plan__r.Name,Extended_Service_Plan__c, IsDeleted, Name, Brand__c, Model__c, Region_or_Market__c, Complementary_Service_Plan__c
                                                       FROM 
                                                       Service_Plans_Model__c 
                                                       where 
                                                       Brand__c =: assetIns.Brand__c 
                                                       AND Model__c =: assetIns.Model__c
                                                       AND Region_or_Market__c =: loggedUser.Market__c
                                                       AND Complementary_Service_Plan__c != null];
        if(sevicePlanList != null && !sevicePlanList.isEmpty()){
            ExtendServicePlanWrapIns.assetIns = assetIns;
            ExtendServicePlanWrapIns.ExtSerPlanAvailable = true;
            ExtendServicePlanWrapIns.servPlanModel = sevicePlanList.get(0);
        }else{
            ExtendServicePlanWrapIns.ExtSerPlanAvailable = false;
        }
        return ExtendServicePlanWrapIns;
    }
    
    public class ExtendServicePlanWrap{
        @AuraEnabled public Asset assetIns;
        @AuraEnabled public Service_Plans_Model__c servPlanModel;
        @AuraEnabled public Boolean ExtSerPlanAvailable;
    }
}
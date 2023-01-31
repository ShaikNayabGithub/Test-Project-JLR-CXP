public class VistaSubscriptionEventDataHelper {
    
    
    public static Account getPrimaryDelaerCode(String dealerCode){
        if(dealerCode.substring(0,3) == 'SAL'){
            dealerCode = dealerCode.replaceFirst('SAL','LR');
        }else if(dealerCode.substring(0,3) == 'SAJ'){
            dealerCode = dealerCode.replaceFirst('SAJ','J');
        }else  if(dealerCode.substring(0,3) == 'SAD'){
            dealerCode = dealerCode.replaceFirst('SAD','J');
        }
        system.debug('dealerCode --> '+dealerCode);
        List<Account> accList =  [select id,ParentID,Parent.ownerid,Primary_Dealer_Code__c 
                                  from Account
                                  where Primary_Dealer_Code__c != null
                                  and ParentID != null
                                  and Parent.ownerid != null
                                  and Primary_Dealer_Code__c =:dealerCode];
        system.debug('accList --> '+accList);
        if(accList != null
           && !accList.isEmpty()){
               return accList.get(0);
           }
        return null;
    }
    
    public static Vehicle_Specification__c getBrandDetails(String brandCode){
        if(brandCode == 'SAJ'){
            brandCode = 'Jaguar';
        }else  if(brandCode == 'SAD'){
            brandCode = 'Jaguar';
        }else if(brandCode == 'SAL'){
            brandCode = 'Land Rover';
        }
        Id makeRecTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        List<Vehicle_Specification__c> vehSpecList = [select id,name 
                                                      from Vehicle_Specification__c 
                                                      where recordTypeId =:makeRecTypeId 
                                                      and name =: brandCode];
        if(vehSpecList != null
           && !vehSpecList.isEmpty()){
               return vehSpecList.get(0);
           }
        return null;
    }
    public static Product2 getProdData(String modelId,String brandId){
        Id modelRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        List<product2> prodList =  [select id,name from product2 
                                    where recordtypeId =: modelRecTypeId 
                                    and ProductCode =: modelId
                                    and Make__c =: brandId];
        if(prodList != null && !prodList.isEmpty()){
            return prodList.get(0);
        }
        return null;
    }
    
    public static Product2 getDerivativeProdData(String ProductCodeId,String modelId){
        Id DerivativeRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        List<product2> prodList =  [select id,name from product2 
                                    where recordtypeId =: DerivativeRecTypeId 
                                    and ProductCode =: ProductCodeId
                                    and Model__c =: modelId];
        if(prodList != null && !prodList.isEmpty()){
            return prodList.get(0);
        }
        return null;
    }
    
    public static Ordering_Market_Country_ISO_Code__mdt getOrderingMarket(String vistaCode){
        List<Ordering_Market_Country_ISO_Code__mdt> orderingMarketList =   [SELECT 
                                                                            Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Country_Code__c, Country__c, Vista_Country_Code__c 
                                                                            FROM 
                                                                            Ordering_Market_Country_ISO_Code__mdt
                                                                            where Vista_Country_Code__c =:vistaCode and Country_Code__c != null];
        if(orderingMarketList != null && !orderingMarketList.isEmpty()){
            return orderingMarketList.get(0);
        }
        return null;
    }
    
    public static Asset getAsset(String orderNo){
        List<Asset> assetList =  [select Id,Name,Order_Number__c,Vin__c,
                                  Current_Status_ID__c,AccountId,Product2Id,Description_Group_ID__c,
                                  Current_Vista_Status_ID__c,Vista_Status__c,Brand_Order_Status_ID__c,
                                  Brand_Order_Status__c,Sale_Type_Code__c,Global_Sales_Type__c,Common_Order_Type__c,Common_Sale_Type__c,
                                  Type_Of_Sale_ID__c,Type_of_Sale__c,Ordering_Market__c,Model__c,Model_Year_Code__c,Handover_Date__c,
                                  Registration_Number__c,brand__c, Product2.Warranty_Length__c, Arrived_at_Dealer_Date__c, Built_Date__c, 
                                  Engine_Number__c
                                  from Asset where  (Order_Number__c != null AND Order_Number__c =:orderNo)];
        if(assetList != null && !assetList.isEmpty()){
            return assetList.get(0);
        }else{
            return new Asset();
        }
    } 
    
}
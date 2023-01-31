/*
* S.No.    Name    Date(DD/MM/YYYY)  Change 
* 1.0    Ashwin    16/06/2021      CXPD-1334: Remove Cancelled Service Plans under Add Service Plan menu
* 
*/
public without sharing class AllAssetSearch_Controller {
    
    public static String Complimentary = Label.SPC_Complimentary;
    public static String Extended = Label.SPC_Extended;
    
    @AuraEnabled 
    public static AssetDetail searchForIds(string searchText){
        user u=[select id, Market__c, profile.Name, Contact.Account.Country_ISO_Code__c, Country_ISO_Code__c from user where ID=:userinfo.getUserId()];
        string countrIsoCode; 
        if(u.profile.Name.endsWithIgnoreCase('AUS'))
            countrIsoCode='AU';
        else if(u.Country_ISO_Code__c !=null)
            countrIsoCode=u.Country_ISO_Code__c;
        else if(u.ContactId !=null && u.Contact.Account.Country_ISO_Code__c !=null)
            countrIsoCode=u.Contact.Account.Country_ISO_Code__c;
        system.debug('countrIsoCode --> '+countrIsoCode);
        system.debug('searchText --> '+searchText);
        AssetDetail assetDetailsOb = new AssetDetail();
        assetDetailsOb.hasActiveServicePlan = false;
        //  searchText = searchText+'%';
        List<Asset> asses = [SELECT Id,Interior_Color__c,Product2.Product_Description__c,is_New_Vehicle__c, Name, Model__c,  Brand__r.Name, Model__r.Name, Product2.Model_Year__c,Account.Country_Iso_code__c,
                             AccountId,AccountCountryCode__c, Registration_Number__c, VIN__c,  Handover_Date__c, Warranty_End_Date__c, Warranty_Start_Date__c, Extended_Warranty_End_Date__c, Original_Handover_Date__c,
                             Derivative__r.Name,Refund__c,Derivative__r.Service_Plan__c, Derivative__r.Service_Plan__r.Service_Plan_Type__c, Derivative__r.Service_Plan__r.Name, Model_Year__c, Transmission__c, Exterior_Colour__c, Model_Code__c,Vista_Status__c,Common_Sale_Type__c,Sale_Type_Code__c
                             FROM Asset WHERE (Registration_Number__c LIKE :searchText OR VIN__c LIKE :searchText OR Name Like :searchText) AND Account.Country_Iso_code__c =: countrIsoCode limit 10 ];
        
        if(asses != null && asses.size() == 1){
            
            if(asses[0].Original_Handover_Date__c == null && asses[0].Warranty_Start_Date__c == null  ){
                assetDetailsOb.missingDateInfo = true;
            }
            
            assetDetailsOb.spcs =  [SELECT Id,  Name, Cancellation_Date__c,Auto_Added__c, Refund__c,toLabel(Service_Plan_Contract_Status__c),
                                    Contract_Term_Months__c, Disposal_Date__c, End_Date__c, Mileage_Months__c, Actual_End_Date__c, Mileage__c, Months__c, Policy_Number__c, Retailer_Id__c, Service_Plan_Product__c,Service_Plan_Product__r.Name, Service_Plan_Type__c, Start_Date__c,  
                                    Vehicle_Id__c, Previous_Asset__c, toLabel(Assignment_Type__c), Corporate_Partner__c,Corporate_Partner__r.Name, Retail_Purchase_Price__c,Country_ISO_Code__c,
                                    Service_Plan_Incremental__c, Service_Plan_Reference__c, Month_Submitted__c, RDA__c, Is_Active__c,
                                    Retailer_Name__c,Purchased_Date__c,Rental_Car__c,Sold_By__c,Activated_By__c,Activated_By__r.Name,CurrencyIsoCode,
                                    Mileage_Months_SPC__c,Mileage_SPC__c,Months_spc__c,Service_Plan_Type_SPC__c,Service_Plan_Reference_spc__c,Service_Plan_Length_Check_SPC__c  
                                    FROM Service_Plan_Contract__c  WHERE Vehicle_Id__c = :asses[0].id  ORDER BY Start_Date__c ASC];//1.0 AND Is_Active__c = true
            
            set<ID> adminIdsSet = new  set<ID>();
            for(PermissionSetAssignment permassign: [SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CXP_Service_Plan_Admins']){
                adminIdsSet.add(permassign.AssigneeId);
            }
            
            for(Service_Plan_Contract__c spc : assetDetailsOb.spcs){
                if((u.Market__c=='APIO' || u.Market__c=='JP') && countrIsoCode !='AU') {
                    if(!assetDetailsOb.isAutoAdded && spc.Assignment_Type__c != Complimentary ){
                        assetDetailsOb.isAutoAdded = spc.Auto_Added__c;
                    }
                    if(spc.Cancellation_Date__c ==null 
                       && countrIsoCode==spc.Country_ISO_Code__c){
                           if(spc.Assignment_Type__c != Complimentary){
                               assetDetailsOb.showCancelButton=true;
                           }
                       }
                    //  system.debug('spc.Assignment_Type__c --> '+spc.Assignment_Type__c);
                    //  system.debug('showExtendedButton --> '+assetDetailsOb.showExtendedButton);
                    //  system.debug('111 --> '+spc.End_Date__c.addDays(30));
                    //  system.debug('22 --> '+system.today());
                    if(spc.Assignment_Type__c == Complimentary 
                       && spc.End_Date__c != null 
                       && u.Market__c=='JP'
                       && (spc.End_Date__c >= system.today() || spc.End_Date__c.addDays(29) >= system.today())){
                           assetDetailsOb.showExtendedButton=true; 
                           assetDetailsOb.showExtendedButtonForExpired=true; 
                       }
                    if(spc.Assignment_Type__c == Extended || spc.Assignment_Type__c == Complimentary){
                        assetDetailsOb.showNewSP=false; 
                        
                    }
                    if(spc.Assignment_Type__c == Extended && spc.Cancellation_Date__c ==null){
                        assetDetailsOb.showExtendedButton=false; 
                        assetDetailsOb.showExtendedButtonForExpired=false;
                    }
                    if(spc.Is_Active__c 
                       && countrIsoCode == spc.Country_ISO_Code__c) {
                           assetDetailsOb.hasActiveServicePlan = true;
                           // break;
                       }
                }else if(spc.Is_Active__c){
                    assetDetailsOb.hasActiveServicePlan = true;
                    // break;
                }
                if(spc.Retail_Purchase_Price__c != null 
                   && spc.Retail_Purchase_Price__c > 0
                   && spc.Country_ISO_Code__c == 'JP'){
                       spc.Retail_Purchase_Price__c = spc.Retail_Purchase_Price__c.setscale(0);
                   }
            }
            
            if(adminIdsSet.contains(u.Id)){
                assetDetailsOb.showExtendedButton=true; 
                assetDetailsOb.showExtendedButtonForExpired=true; 
            }
            
            assetDetailsOb.Asset = asses[0];
            assetDetailsOb.currentUser=u;
            system.debug('assetDetailsOb --> '+json.serialize(assetDetailsOb));
            return assetDetailsOb;
        }else{
            return null;
        }              
    }
    
    public class AssetDetail {
        public AssetDetail(){
            missingDateInfo = false;
            showCancelButton = false;
            showExtendedButton = false;
            isAutoAdded = false;
            showExtendedButtonForExpired = false;
            showNewSP = true; 
        }
        @AuraEnabled public Asset asset;
        @AuraEnabled public List<Service_Plan_Contract__c> spcs;
        @AuraEnabled public Boolean hasActiveServicePlan;
        @AuraEnabled public user currentUser;
        @AuraEnabled public Boolean missingDateInfo;
        @AuraEnabled public Boolean showCancelButton;
        @AuraEnabled public Boolean showExtendedButton;
        @AuraEnabled public Boolean isAutoAdded;
        @AuraEnabled public Boolean showNewSP;
        @AuraEnabled public Boolean showExtendedButtonForExpired;
    }
}
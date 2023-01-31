/*
*  @Name : RDATriggerHandler 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-446
*  @Description : Handler Class for RDA__c object Trigger  
*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		25/05/2021			CXPD-1221: Added Logic to cancel Service Plan Contract when RDA is cancelled
* 
*/

public class RDATriggerHandler {
    public static  Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static     Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static     Id individualPrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    public static     Id CorporatePrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    //On_Sell
    public static Id onSellRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    public static Id dealerOwnedRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    public static Id OUVRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId();
    public static Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id tradeInRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Trade_In').getRecordTypeId();
    public static Id ServiceRecordtypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
    public static User loggedInUser = [SELECT Id, ContactId,Country_ISO_Code__c , profile.Name FROM User WHERE Id = :userinfo.getUserId()];
    private static Map<String, String> commonSaleTypeCodes = null;
    private static Map<String, String> commonBuyerTypeCodes = null;
    private static Map<String, String> commonBuyerTypeNumbers = null;
    private static Map<String, Common_Type_of_Sale_Code__mdt> commonSaleTypes = null;
    private static Map<Id, Opportunity> opportunityMap = null;
    
    public static void PreCreate(List<RDA__c> triggerNewList, Map<Id,RDA__c> triggerNewMap){
        List<Asset> updateTradeAssetsList = new List<Asset>();
        Map<Id,Asset> updateTradedInCSTAssetsList = new Map<Id,Asset>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> compAssetIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> servicePlanIds = new Set<Id>();
        Set<Id> locIds = new Set<Id>();
        List<String> cityList = new  List<String>();
        Map<String,AU_Locality__c> cityKeyLocValueMap = new    Map<String,AU_Locality__c>();
        set<Id> tradeInAssetIds =  new Set<Id>();
        
        for(RDA__c RDANew : triggerNewList){
            
            
            if(RDANew.VIN__c != null){
                tradeInAssetIds.add(RDANew.VIN__c);
            }
            
            if(RDANew.Asset__c != null){
                assetIds.add(RDANew.Asset__c);
                
            }
            if(RDANew.Account__c != null){
                accIds.add(RDANew.Account__c);
            }
            
            if(RDANew.Opportunity__c != null){
                oppIds.add(RDANew.Opportunity__c);
            }
            if(RDANew.AU_Locality__c != null){
                locIds.add(RDANew.AU_Locality__c);
            }
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if(oppIds.size() > 0){
            oppMap = new Map<Id, Opportunity>();
            for(Opportunity opp : [SELECT Id, Handover_Date__c,Trade_In__c ,Corporate_Partner_Account__c, OwnerId, owner.name, Primary_Contact__c, Primary_Contact__r.Name ,Primary_Contact__r.MailingCity ,Primary_Contact__r.MailingPostalCode ,Primary_Contact__r.MailingState ,Primary_Contact__r.MobilePhone ,Primary_Contact__r.Email FROM Opportunity WHERE Handover_Date__c != null and Id in:oppIds]){
                oppMap.put(opp.Id, opp);
                if(opp.Primary_Contact__c != null && opp.Primary_Contact__r.MailingCity != null){
                    cityList.add(opp.Primary_Contact__r.MailingCity);
                }
            }
        } 
        
        Map<Id, Asset> assMap = new Map<Id, Asset>();
        if(assetIds.size() > 0){
            assMap = new Map<Id, Asset>();
            for(Asset ass : [SELECT Id,Common_Sale_Type__c ,Model__c,Vin__c,Name,Model__r.name,Product2.Model_Alternative__c,Derivative__c, Derivative__r.Service_Plan__c, Sold_Date_Vista__c,Into_Port_of_Entry_Date__c,  Warranty_Start_Date__c, Warranty_End_Date__c  FROM Asset WHERE id in: assetIds]){
                assMap.put(ass.Id, ass);
                
            }
        }
        Map<Id, Asset> tradeAssMap = new Map<Id, Asset>();
        if(tradeInAssetIds.size() > 0){
            tradeAssMap = new Map<Id, Asset>();
            for(Asset ass : [SELECT Id,AccountId,brand__c, model__c,model__r.Model_Vehicle_spec__c  FROM Asset WHERE id in: tradeInAssetIds]){
                tradeAssMap.put(ass.Id, ass);
            }
        }
        Map<Id, Account> accMap = new Map<Id, Account>();
        if(accIds.size() > 0){
            accMap = new Map<Id, Account>();
            for(Account acc : [SELECT Id,IsPersonAccount, name,PersonEmail, recordtypeId, Retailer_Email__c, BillingPostalCode, firstname,BillingCity, lastname,Phone FROM Account where id in:accIds ]){
                accMap.put(acc.Id, acc);
                if(acc.BillingCity != null){
                    cityList.add(acc.BillingCity);
                }
            }
        }
        
        
        
        Map<Id, AU_Locality__c> locMap = new Map<Id, AU_Locality__c>();
        if(locIds.size() > 0 || cityList.size() > 0){
            locMap = new Map<Id, AU_Locality__c>();
            for(AU_Locality__c loc : [SELECT Id, Name,State__c,PMA_Postcode__r.Name FROM AU_Locality__c where id in:locIds or Name in :cityList]){                  
                locMap.put(loc.Id, loc);              
                string keystring = loc.Name.toUpperCase() +loc.PMA_Postcode__r.Name.toUpperCase();
                cityKeyLocValueMap.put(keystring, loc);
            }
        }
        
        for(RDA__c RDANew : triggerNewList){ 
            
            //  system.debug('RDA SUBMITTED '+Json.serializePretty(RDANew));
            //  RDANew.addError('Stop');
            
            
            
            
            if(rdaNew.Add_Extended_Warranty__c == true && RDANew.Extended_Warranty__c == null  ){
                RDANew.Extended_Warranty__c = 'Two years and Unlimited Km';
                
            }
            if(rdaNew.Add_Extended_Warranty__c == null && RDANew.Extended_Warranty__c != null &&  RDANew.Extended_Warranty__c =='Two years and Unlimited Km'){
                RDANew.Add_Extended_Warranty__c =true;
                
            }
            if(RDANew.Asset__c != null){
                Asset ass = assMap.get(RDANew.Asset__c );
                if(RDANew.Assignment_Type__c != null && RDANew.Assignment_Type__c == 'Complimentary' && ass.Derivative__c != null && ass.Derivative__r.Service_Plan__c != null){
                    RDANew.Service_Plan_Type__c =  ass.Derivative__r.Service_Plan__c ;
                }
                
                
                
                RDANew.Asset_VIN__c = ass.Vin__c;
                RDANew.Asset_Model__c = ass.Product2.Model_Alternative__c;
                system.debug('FOUND Common_Sale_Type__c '+RDANew.Common_Sale_Type__c);
                system.debug('FOUND  ass.Common_Sale_Type__c '+ ass.Common_Sale_Type__c);
                if(RDANew.Common_Sale_Type__c == null && ass.Common_Sale_Type__c != null  ){
                    RDANew.Common_Sale_Type__c = ass.Common_Sale_Type__c;
                    system.debug('FOUND Common_Sale_Type__c '+RDANew.Common_Sale_Type__c);
                }
                if(ass.Warranty_Start_Date__c != null){
                    RDANew.Warranty_Start_Date__c = ass.Warranty_Start_Date__c;
                }else{
                    if(RDANew.RecordtypeId == newRetailRecordTypeId || RDANew.RecordtypeId == OUVRecordTypeId || RDANew.RecordtypeId == dealerOwnedRecordTypeId){
                        RDANew.Warranty_Start_Date__c = RDANew.Handover_Date__c;
                        
                        
                        
                    }
                }
                
                
            }
            if(RDANew.AU_Locality__c != null){
                AU_Locality__c loc = locMap.get(RDANew.AU_Locality__c );
                if( RDANew.AU_Locality_City__c == null){
                    RDANew.AU_Locality_City__c = loc.Name; 
                }
                if(  RDANew.AU_Locality_Postcode__c  == null){
                    RDANew.AU_Locality_Postcode__c = loc.PMA_Postcode__r.Name;  
                }
                if(  RDANew.AU_Locality_State__c  == null){
                    RDANew.AU_Locality_State__c = loc.State__c;  
                }
                
                
                
            }else{
                
                if(RDANew.Account__c != null ){
                    
                    Account acc = accMap.get(RDANew.Account__c);
                    if(acc.recordtypeId != CorporateId && acc.recordtypeId != CorporatePrimaryId &&  acc.BillingPostalCode != null && acc.BillingCity != null && cityKeyLocValueMap.containsKey(acc.BillingCity.toUpperCase()+acc.BillingPostalCode.toUpperCase()) ){
                        AU_Locality__c loc2 = cityKeyLocValueMap.get(acc.BillingCity.toUpperCase()+acc.BillingPostalCode.toUpperCase());
                        system.debug('has loc2'+loc2);
                        if( RDANew.AU_Locality_City__c == null){
                            RDANew.AU_Locality_City__c = loc2.Name; 
                        }
                        if(  RDANew.AU_Locality_Postcode__c  == null){
                            RDANew.AU_Locality_Postcode__c = loc2.PMA_Postcode__r.Name;  
                        }
                        if(  RDANew.AU_Locality_State__c  == null){
                            RDANew.AU_Locality_State__c = loc2.State__c;  
                        }
                        if(RDANew.AU_Locality__c  == null){
                            RDANew.AU_Locality__c = loc2.Id;
                        }
                        
                        
                        
                        
                        
                    }
                    
                    
                }
            }
            if(RDANew.Account__c != null){
                Account acc = accMap.get(RDANew.Account__c);
                RDANew.Account_Fixed__c = acc.Name;
                RDANew.Phone_RDA__c = acc.Phone;
                if(acc.IsPersonAccount){
                    RDANew.Email_RDA__c = acc.PersonEmail;                    
                }else{
                    RDANew.Email_RDA__c = acc.Retailer_Email__c;
                }
            }
            
            if(RDANew.Opportunity__c != null){
                Opportunity opp = oppMap.get(RDANew.Opportunity__c);
                if(opp != null && opp.OwnerId != null && opp.Owner.name != null ){
                    RDANew.Sales_Person_RDA__c = opp.Owner.name;
                }
                if(opp != null && opp.Corporate_Partner_Account__c != null && RDANew.Corporate_Account__c == null && RDANew.Assignment_Type__c == 'Corporate' && RDANew.Offer__c == null ){
                    RDANew.Corporate_Account__c = opp.Corporate_Partner_Account__c;
                    
                }
                List<String> localityExcludedCountries = new List<String>{'KR'};
                Boolean excludeLocalities = localityExcludedCountries.contains(loggedInUser.Country_ISO_Code__c);
                if(opp != null && opp.Primary_Contact__c != null  && !excludeLocalities ){
                    if(RDANew.Contact__c == null){
                        RDANew.Contact__c = opp.Primary_Contact__c;
                    }
                    
                    if(RDANew.AU_Locality__c == null && opp.Primary_Contact__r.MailingCity != null && opp.Primary_Contact__r.MailingPostalCode != null  ){
                        AU_Locality__c loc2 = cityKeyLocValueMap.get(opp.Primary_Contact__r.MailingCity.toUpperCase()+opp.Primary_Contact__r.MailingPostalCode.toUpperCase());
                        system.debug('has loc2'+loc2);
                        if( RDANew.AU_Locality_City__c == null){
                            RDANew.AU_Locality_City__c = loc2.Name; 
                        }
                        if(  RDANew.AU_Locality_Postcode__c  == null){
                            RDANew.AU_Locality_Postcode__c = loc2.PMA_Postcode__r.Name;  
                        }
                        if(  RDANew.AU_Locality_State__c  == null){
                            RDANew.AU_Locality_State__c = loc2.State__c;  
                        }
                        if(RDANew.AU_Locality__c  == null){
                            RDANew.AU_Locality__c = loc2.Id;
                        }
                        
                        
                    }         
                    
                }
            }
            
            if(FieldsCompletedForSubmission(RDANew)){
                if(RDANew.Submitted_Status__c != 'Completed') RDANew.Submitted_Status__c = 'Submitted';
                RDANew.Submitted_Date__c = system.today();
            }
            
            //demonstrator                                  //DAA
            if(RDANew.Common_Sale_Type__c != null &&   RDANew.Common_Type_of_Sale_Code__c == null && getCommonTypeOfSaleCodeMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){             
                system.debug(' Common_Sale_Type__c IS NOT NULL Common_Type_of_Sale_Code__c is NULL and in keyset');
                RDANew.Common_Type_of_Sale_Code__c = getCommonTypeOfSaleCodeMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() ).Common_Sale_Type_Code__c;
                //       system.debug('FOUND Common_Type_of_Sale_Code__c '+  RDANew.Common_Type_of_Sale_Code__c );
            }
            //DAA                                               //
            if(   RDANew.Common_Type_of_Sale_Code__c != null && RDANew.Common_Sale_Type__c == null && getCommonTypeOfSaleMetadata().containsKey( RDANew.Common_Type_of_Sale_Code__c.toUpperCase()) ){                
                
                //      system.debug(' Common_Sale_Type__c IS NULL Common_Type_of_Sale_Code__c is NOT NULL and in keyset');
                RDANew.Common_Sale_Type__c  = getCommonTypeOfSaleMetadata().get(RDANew.Common_Type_of_Sale_Code__c.toUpperCase());
                //     system.debug('FOUND Common_Sale_Type__c '+  RDANew.Common_Sale_Type__c );
            }
            
            //Demonstrator                                  //43
            if(RDANew.Common_Sale_Type__c != null &&  RDANew.Buyer_Type_Number__c == null && getBuyerTypeNumberFromMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){
                string xx = getBuyerTypeNumberFromMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() );              
                //     system.debug(' Common_Sale_Type__c IS NOT NULL Buyer_Type_Number__c is  NULL and in keyset');
                RDANew.Buyer_Type_Number__c = decimal.valueOf(xx);
                //      system.debug('FOUND Buyer_Type_Number__c '+  RDANew.Buyer_Type_Number__c );
            }
            if(RDANew.Common_Sale_Type__c != null  &&  RDANew.Buyer_Type__c == null && getBuyerTypeFromMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){      
                //  system.debug(' Common_Sale_Type__c IS NOT NULL Buyer_Type__c is  NULL and in keyset');
                RDANew.Buyer_Type__c = getBuyerTypeFromMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() );
                //       system.debug(' FOUND Buyer_Type__c '+ RDANew.Buyer_Type__c);
            }
            //CXPD-626  
            if(RDANew.RecordtypeId == tradeInRecordTypeId && RDANew.Common_Sale_Type__c != null ){
                RDANew.Common_Sale_Type_Select__c =  RDANew.Common_Sale_Type__c;
            }
            
            if(RDANew.VIN__c !=  null){
                Asset tradeAss =  tradeAssMap.get(RDANew.VIN__c );  
                if(tradeAss != null && tradeAss.brand__c != null){
                    RDANew.Trade_In_Make__c = tradeAss.brand__c;
                }
                if(tradeAss != null && tradeAss.Model__c != null && tradeAss.model__r.Model_Vehicle_spec__c != null){
                    RDANew.Trade_In_Model__c =tradeAss.model__r.Model_Vehicle_spec__c; 
                }
                
                System.debug('getUserType() '+ UserInfo.getUserType());
                if(UserInfo.getUserType() == 'PowerPartner'){
                    User me = [SELECT id,Contact.AccountId FROM User WHERE Id =:UserInfo.getUserId()];
                    if( tradeAss.accountId != me.Contact.AccountId){
                        tradeAss.accountId = me.Contact.AccountId; 
                        tradeAss.Traded_In__c = true;
                        updateTradeAssetsList.add(tradeAss);
                    }
                    
                }
                
                
            }
            if(validateEnteredHandoverDate(RDANew, assMap, loggedInUser.Country_ISO_Code__c)){
                RDANew.addError(Label.RDA_Handover_Validation_Error);
            }
            
            // system.debug('RDA SUBMITTED aus marketing'+Json.serializePretty(RDANew.Marketing_Indicator__c));
            //   system.debug('RDA OI SUBMITTED ');
            // system.debug('RDA Assignment_Type__c '+RDANew.Assignment_Type__c);
            //    system.debug('RDA Offer__c '+RDANew.Offer__c);
            //    system.debug('RDA Corporate_Account__c '+RDANew.Corporate_Account__c);
            //  system.debug('RDA SUBMITTED '+Json.serializePretty(RDANew));
            
            // RDANew.addError('Stop TESTING');
            
        }
        if(updateTradeAssetsList != null && updateTradeAssetsList.size() > 0){
            update updateTradeAssetsList;
        }
    }
    
    public static void PostCreate(List<RDA__c> triggerNewList,  Map<Id,RDA__c> triggerNewMap, Map<Id,RDA__c> triggerOldMap){
        List<RDA__c> submittedRDAList = new List<RDA__c>();
        List<RDA__c> cancelledRDAList = new List<RDA__c>();
        List<RDA__c> completedRDAList = new List<RDA__c>();
    //    List<Roles__c> assetRoles = new List<Roles__c>();
        List<Id> serviceplanRDAList = new List<Id>();
        Set<Id> updateOpportunityIdList = new Set<Id>();
        Set<Id> updateAssetIdList = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        
        Set<Id> accIds = new Set<Id>();
        Set<Id> locIds = new Set<Id>();
        List<String> cityList = new  List<String>();
        
        set<Id> tradeInAssetIds =  new Set<Id>();
        for(RDA__c RDANew : triggerNewList){
            
            
            if(RDANew.Account__c != null){
                accIds.add(RDANew.Account__c);
            }
            
            if(RDANew.Opportunity__c != null){
                oppIds.add(RDANew.Opportunity__c);
            }
            
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if(oppIds.size() > 0){
            oppMap = new Map<Id, Opportunity>();
            for(Opportunity opp : [SELECT Id, Handover_Date__c,Corporate_Partner_Account__c, OwnerId, owner.name, Primary_Contact__c, Primary_Contact__r.Name ,Primary_Contact__r.MailingCity ,Primary_Contact__r.MailingPostalCode ,Primary_Contact__r.MailingState ,Primary_Contact__r.MobilePhone ,Primary_Contact__r.Email FROM Opportunity WHERE Handover_Date__c != null and Id in:oppIds]){
                oppMap.put(opp.Id, opp);
                
            }
        } 
        
        Map<Id, Account> accMap = new Map<Id, Account>();
        if(accIds.size() > 0){
            accMap = new Map<Id, Account>();
            for(Account acc : [SELECT Id,IsPersonAccount, name,PersonEmail, recordtypeId, Retailer_Email__c, BillingPostalCode, firstname,BillingCity, lastname,Phone FROM Account where id in:accIds ]){
                accMap.put(acc.Id, acc);
                if(acc.BillingCity != null){
                    cityList.add(acc.BillingCity);
                }
            }
        }
        
        
        
        
        
        
        
        List<RDA__C> toUpdate = new List<RDA__c>();
        for(RDA__c RDANew : triggerNewList){
            if((RDANew.RecordTypeId != dealerOwnedRecordTypeId || RDANew.RecordTypeId != OUVRecordTypeId) && RDANew.Asset__c != null){
                updateAssetIdList.add(RDANew.Asset__c);
                if(RDANew.Submitted_Status__c == 'Submitted'){
                    submittedRDAList.add(RDANew);   
                } 
                else if(RDANew.Submitted_Status__c == 'Cancelled'){
                    cancelledRDAList.add(RDANew);   
                }
                
                if(RDANew.Submitted_Status__c == 'Completed'){
                    completedRDAList.add(RDANew);   
                }
                
                
            } 
            if(Test.isRunningTest() ||(RDANew.Vital_RDA_Ref__c == null &&  RDANew.Service_Plan_Type__c != null && RDANew.Assignment_Type__c != null && RDANew.Service_Plan_Policy_Contract__c == null)){
                serviceplanRDAList.add(RDANew.Id);
            }
            
            ////  
            if(RDANew.Opportunity__c != null && RDANew.Account__c != null ){
                Opportunity opp = oppMap.get(RDANew.Opportunity__c);
                Boolean addtolist = false;
                RDA__c rda = new RDA__c();
                rda.Id = RDANew.id;
                if(opp != null && opp.Primary_Contact__c != null && ((RDANew.Contact_Fixed__c !=  null &&  RDANew.Contact_Fixed__c != opp.Primary_Contact__r.Name)||RDANew.Contact_Fixed__c ==  null)){
                    rda.Contact_Fixed__c = opp.Primary_Contact__r.Name;
                    addtolist = true;
                }
                
                if(accMap.get(RDANew.Account__c).recordtypeid == CorporateId){
                    if(opp != null && opp.Primary_Contact__c != null && opp.Primary_Contact__r.MobilePhone != null && RDANew.Phone_RDA__c != opp.Primary_Contact__r.MobilePhone){
                        rda.Phone_RDA__c = opp.Primary_Contact__r.MobilePhone; 
                        addtolist = true;
                    }
                    if(opp != null && opp.Primary_Contact__c != null && opp.Primary_Contact__r.Email != null && RDANew.Email_RDA__c != opp.Primary_Contact__r.Email){
                        rda.Email_RDA__c = opp.Primary_Contact__r.Email; 
                        addtolist = true;
                    }
                    
                    
                    
                }   
                if(addtolist){
                    toUpdate.add(rda);
                }
                
            }
            
            ///
            
            
            
        }
        
        if(submittedRDAList.size() > 0 || cancelledRDAList.size() > 0){
            UpdateRDAAssets(submittedRDAList, cancelledRDAList, updateAssetIdList, triggerNewMap, null);
        } 
        
        if(completedRDAList.size() > 0 ){
            UpdateCompletedRDAAssets(completedRDAList, updateAssetIdList, triggerNewMap, null);
        } 
        
        if(serviceplanRDAList !=  null && serviceplanRDAList.size() > 0 && !System.isFuture()){
            
            ServicePlanContractCreationLogic.createNewServicePlanContract(serviceplanRDAList);  
        }
        
        
        
        if(triggerNewList.size() > 0 && !RDALoyaltypointsCaliculation.isLoyaltyPointsCaliculated)  RDALoyaltypointsCaliculation.LoyaltypointsCaliculation(triggerNewList);
        
        if(toUpdate != null && toUpdate.size() > 0){
            update toUpdate;
        }
    }
    
    public static void PreUpdate(List<RDA__c> triggerNewList, Map<Id,RDA__c> triggerNewMap, List<RDA__c> triggerOldList,  Map<Id,RDA__c> triggerOldMap){
        system.debug('preupdate');
        Set<Id> RDAAsset = new Set<Id>();
        Set<Id> RDAAccount = new Set<Id>();
        List<RDA__c> LoyaltyRDAs = new List<RDA__c>();
        List<RDA__c> ServiceplanRDAs = new List<RDA__c>();
        Map<Id,Id> ServiceplanProds = new Map<Id,Id>();
        List<Product2> serviceplans = new List<Product2>();
        Boolean FromLoyaltypoints = FALSE;
        Boolean Donotcalcserviceplan = FALSE;
        Boolean Useupdatestmnt = FALSE;
        
        Set<Id> oppIds = new Set<Id>();
        for(RDA__c RDANew : triggerNewList){
            if(RDANew.Opportunity__c != null){
                oppIds.add(RDANew.Opportunity__c);
            }
        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        if(oppIds.size() > 0){
            oppMap = new Map<Id, Opportunity>();
            for(Opportunity opp : [SELECT Id, Handover_Date__c FROM Opportunity WHERE Handover_Date__c != null and Id in:oppIds]){
                oppMap.put(opp.Id, opp);
            }
        }
        for(RDA__c RDANew : triggerNewList){
            system.debug('RDANEW '+RDANEW);
            system.debug('RDANEW '+ RDANew.Common_Sale_Type__c);
            //CXPD-626  
            if(RDANew.RecordtypeId == tradeInRecordTypeId && RDANew.Common_Sale_Type__c != null && RDANew.Common_Sale_Type_Select__c != null ){
                RDANew.Common_Sale_Type__c =  RDANew.Common_Sale_Type_Select__c;
                system.Debug('RDANew.Common_Sale_Type__c '+RDANew.Common_Sale_Type__c);
                system.Debug('getCommonTypeOfSaleCodeMetadata() '+getCommonTypeOfSaleCodeMetadata());
               //   if(getCommonTypeOfSaleCodeMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){
                       if(RDANew != null && RDANew.Common_Sale_Type__c != null && getCommonTypeOfSaleCodeMetadata() != null ){
                           if(getCommonTypeOfSaleCodeMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() ) != null ){
                              RDANew.Common_Type_of_Sale_Code__c = getCommonTypeOfSaleCodeMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() ).Common_Sale_Type_Code__c;  
                           }
               
                 }
                
                string xx = getBuyerTypeNumberFromMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() );              
                if(xx != null && xx != ''){
                    RDANew.Buyer_Type_Number__c = decimal.valueOf(xx);  
                }
              if(RDANew != null && RDANew.Common_Sale_Type__c != null && getCommonTypeOfSaleCodeMetadata() != null && getBuyerTypeFromMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){
                RDANew.Buyer_Type__c = getBuyerTypeFromMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() );
              }
            }
            
            if(rdaNew.Add_Extended_Warranty__c == true && (RDANew.Extended_Warranty__c == null ||    RDANew.Extended_Warranty__c != 'Two years and Unlimited Km') ){
                RDANew.Extended_Warranty__c = 'Two years and Unlimited Km';
                
            }else{ 
                if(rdaNew.Add_Extended_Warranty__c != true && triggerOldMap.get(RDANew.Id).Add_Extended_Warranty__c == true ){
                    RDANew.Extended_Warranty__c = 'None';
                }
                
            }
            
            
            if(FieldsCompletedForSubmission(RDANew))  {
                
                if(RDANew.Submitted_Status__c != 'Cancelled'){
                    if(RDANew.Submitted_Status__c != 'Completed' ){
                        RDANew.Submitted_Status__c = 'Submitted';
                        RDANew.Submitted_Date__c = system.today();
                    } 
                    
                }
            } 
            if(RDANew.Common_Sale_Type__c != null &&   RDANew.Common_Type_of_Sale_Code__c == null && getCommonTypeOfSaleCodeMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){             
                RDANew.Common_Type_of_Sale_Code__c = getCommonTypeOfSaleCodeMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() ).Common_Sale_Type_Code__c;
            }
            
            if(   RDANew.Common_Type_of_Sale_Code__c != null && RDANew.Common_Sale_Type__c == null && getCommonTypeOfSaleTypeMetadata().containsKey( RDANew.Common_Type_of_Sale_Code__c.toUpperCase()) ){                
                
                RDANew.Common_Sale_Type__c  = getCommonTypeOfSaleTypeMetadata().get(RDANew.Common_Type_of_Sale_Code__c.toUpperCase());
            }
            
            
            if(RDANew.Common_Sale_Type__c != null &&  RDANew.Buyer_Type_Number__c == null && getBuyerTypeNumberFromMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){
                string xx = getBuyerTypeNumberFromMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() );              
                RDANew.Buyer_Type_Number__c = decimal.valueOf(xx);
            }
            if(RDANew.Common_Sale_Type__c != null  &&  RDANew.Buyer_Type__c == null && getBuyerTypeFromMetadata().containsKey(RDANew.Common_Sale_Type__c.toUpperCase() )){      
                RDANew.Buyer_Type__c = getBuyerTypeFromMetadata().get(RDANew.Common_Sale_Type__c.toUpperCase() );
            }
            
            
            /*if(RDANew.Opportunity__c != null && oppMap.containsKey(RDANew.Opportunity__c) && oppMap.get(RDANew.Opportunity__c) != null){
RDANew.Handover_Date__c = oppMap.get(RDANew.Opportunity__c).Handover_Date__c;
}*/
        }
    }    
    public static void PostUpdate(List<RDA__c> triggerNewList, Map<Id,RDA__c> triggerNewMap, List<RDA__c> triggerOldList,  Map<Id,RDA__c> triggerOldMap){
        System.debug('PostUpdate RDA');
        List<RDA__c> submittedRDAList = new List<RDA__c>();
        List<RDA__c> extendedWarrantyChangeRDAList = new List<RDA__c>();
        List<RDA__c> cancelledRDAList = new List<RDA__c>();
        List<RDA__c> servicePlanChangeRDAList = new List<RDA__c>();
        List<id> serviceplanRDAList = new List<id>();
        Set<Id> updateOpportunityIdList = new Set<Id>();
        Set<Id> updateAssetIdList = new Set<Id>();
        Set<Id> allAssetIdList = new Set<Id>();
        for(RDA__c RDANew : triggerNewList){
            allAssetIdList.add(RDANew.Asset__c);
            RDA__c RDAOLD = triggerOldMap.get(RDANew.Id);
            if(RDANew.Vital_RDA_Ref__c == null && ((RDANew.Corporate_Account__c != null && RDAOLD.Corporate_Account__c == null) || (RDANew.Assignment_Type__c != null && RDAOLD.Assignment_Type__c == null) ) && RDANew.Service_Plan_Policy__c == null && RDAOLD.Service_Plan_Policy__c == null){
                serviceplanRDAList.add(RDANew.id);
                
            }
            
            if(RDANew.Submitted_Status__c != triggerOldMap.get(RDANew.Id).Submitted_Status__c  && RDANew.Asset__c != null && (RDANew.RecordTypeId != dealerOwnedRecordTypeId || RDANew.RecordTypeId != OUVRecordTypeId)){
                updateAssetIdList.add(RDANew.Asset__c);
                if(RDANew.Submitted_Status__c == 'Submitted'){
                    submittedRDAList.add(RDANew);   
                } 
                else if(RDANew.Submitted_Status__c == 'Cancelled'){
                    cancelledRDAList.add(RDANew);   
                }
            }             
        }
        if(serviceplanRDAList !=  null && serviceplanRDAList.size() > 0 && !System.isFuture()){
            
            ServicePlanContractCreationLogic.createNewServicePlanContract(serviceplanRDAList);  
        }
        
        if(cancelledRDAList.size() > 0) cancelRelatedServiceContractPlans(cancelledRDAList);	//1.0
        
        if(submittedRDAList.size() > 0 || cancelledRDAList.size() > 0) UpdateRDAAssets(submittedRDAList, cancelledRDAList, updateAssetIdList, triggerNewMap, triggerOldMap);
        system.Debug('submittedRDAList.size()'+submittedRDAList.size());   
        system.Debug('cancelledRDAList.size()'+cancelledRDAList.size());   
        if(submittedRDAList.size() <= 0 && cancelledRDAList.size() <= 0) UpdateRDAAssetExtendedWarrantys( triggerNewList, allAssetIdList, triggerOldMap);
        
    }
    //1.0
    public static void cancelRelatedServiceContractPlans(List<RDA__c> cancelledRDAList){
        Set<Id> cancelledRDAIdSet = new Set<Id>();
        List<Service_Plan_Contract__c> spcToCancelList = new List<Service_Plan_Contract__c>();
        for(RDA__c eachCancelledRDA : cancelledRDAList){
            cancelledRDAIdSet.add(eachCancelledRDA.Id);
        }
        for(Service_Plan_Contract__c eachSPC : [Select Id, Cancellation_Date__c from Service_Plan_Contract__c
                                                Where RDA__c IN:cancelledRDAIdSet and Cancellation_Date__c = null])
        {
            eachSPC.Cancellation_Date__c = System.today();
            spcToCancelList.add(eachSPC);
        }
        if(spcToCancelList.size() > 0) update spcToCancelList;
    }
    
    public static Boolean validateEnteredHandoverDate(RDA__c RDANew, Map<Id, Asset> assMap, string isoCode){
        Boolean failedValidation = false;
        Date maxDayInFuture;
        Date minDayInPass;
        List<VistaHandoverValidation__mdt> handoverdates = [SELECT Label,CountryISOCode__c, Days_In_Future_Allowed__c, Days_In_Past_Allowed__c FROM VistaHandoverValidation__mdt];
        VistaHandoverValidation__mdt handoverdateRangeCountry;
        VistaHandoverValidation__mdt handoverdateRangeNoCountry;
        VistaHandoverValidation__mdt handoverdateRange;
        if(handoverdates.size()>0){
            if(isoCode != null && isoCode != '' ){
                for(VistaHandoverValidation__mdt mdt: handoverdates){
                    if(mdt.CountryISOCode__c == isoCode){
                        handoverdateRangeCountry = mdt;
                    }
                    if(mdt.CountryISOCode__c == null || mdt.CountryISOCode__c == ''){
                        handoverdateRangeNoCountry = mdt;
                    }
                }
            }
            if(handoverdateRangeCountry != null){
                
                handoverdateRange = handoverdateRangeCountry;
            }else{
                handoverdateRange = handoverdateRangeNoCountry;
            }
            
            
            if(handoverdateRange != null && handoverdateRange.Days_In_Future_Allowed__c !=  null  ){
                maxDayInFuture =  system.today();
                maxDayInFuture=   maxDayInFuture.addDays((Integer)handoverdateRange.Days_In_Future_Allowed__c);
            }
            if(handoverdateRange != null && handoverdateRange.Days_In_Past_Allowed__c !=  null  ){
                minDayInPass =  system.today();
                minDayInPass=   minDayInPass.addDays(-(Integer)handoverdateRange.Days_In_Past_Allowed__c);
            }
            
            if(maxDayInFuture != null && RDANew.Handover_Date__c !=null && RDANew.Handover_Date__c > maxDayInFuture  ){
                
                failedValidation = true;
            }
            if(minDayInPass != null && RDANew.Handover_Date__c !=null && RDANew.Handover_Date__c < minDayInPass ){
                
                failedValidation = true;
            }
        } 
        if(assMap != null && assMap.size() > 0 && RDANew.Asset__c != null && assMap.get(RDANew.Asset__c) != null){
            
            
            if( assMap.get(RDANew.Asset__c).Sold_Date_Vista__c != null ){
                Date soldDate = assMap.get(RDANew.Asset__c).Sold_Date_Vista__c;
                if(RDANew.Handover_Date__c < soldDate){
                    
                    failedValidation = true;
                }
            }
            
            if( assMap.get(RDANew.Asset__c).Into_Port_of_Entry_Date__c != null ){
                Date portDate = assMap.get(RDANew.Asset__c).Into_Port_of_Entry_Date__c;
                if(RDANew.Handover_Date__c < portDate){
                    
                    failedValidation = true;
                }
            }
            
        }
        
        return failedValidation;
    }
    
    public static void UpdateRDAAssets(List<RDA__c> submittedRDAList, List<RDA__c> cancelledRDAList, Set<Id> updateAssetIdList, Map<Id,RDA__c> triggerNewMap,  Map<Id,RDA__c> triggerOldMap){
        System.debug('entered UpdateRDAAssets');
        Warranty_Setting__mdt warrantySetting;
        Map<String, Warranty_Setting__mdt> warrantySettings  =getWarrantySetting();
        if(warrantySettings != null && loggedInUser !=  null && loggedInUser.Country_ISO_Code__c != null && warrantySettings.containskey(loggedInUser.Country_ISO_Code__c )){
            warrantySetting = warrantySettings.get(loggedInUser.Country_ISO_Code__c);
        }
        Map<Id,Asset> updatedAssetMap = new Map<Id,Asset>([SELECT Id,Extended_Warranty_End_Date__c,AccountId,Model__r.Name,Model__c,Account.Owner.Contact.AccountId, Original_Handover_Date__c, Handover_Date__c, Warranty_Start_Date__c, Warranty_End_Date__c, Derivative__c,
                                                           Previous_Owner__c, Vista_Status__c, Product2.Warranty_Length__c, Brand__c, Derivative__r.Model_Alternative__c, Common_Sale_Type__c,
                                                           (SELECT Id,Role__c FROM Roles__r WHERE Role__c = 'Current Owner' LIMIT 1 ) FROM Asset WHERE Id IN :updateAssetIdList]);
        
        //SELECT METADATA TABLE
        
        Map<Id,RDA__c> totalRDAMap = new Map<Id,RDA__c>();
        List<Asset> updateAssetList = new List<Asset>();        
        Set<ID> updateIdSet = new Set<Id>();           
        
        
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        List<Role__c> CancelledRolesList = new List<Role__c>();
        List<RDA__c> updatedRDAList = new List<RDA__c>();
        List<Role__c> newRetailerRolesList = new List<Role__c>();
        if(submittedRDAList.size() > 0) updatedRDAList.addAll(submittedRDAList);
        if(cancelledRDAList.size() > 0) updatedRDAList.addAll(cancelledRDAList);
        if(updatedRDAList.size() > 0  && loggedInUser.ContactId != null) TargetAndQuotaUpdater.calculateTargetAndQuota(updatedRDAList,updatedAssetMap);
        
        for(RDA__c submittedRDA : submittedRDAList){  
            totalRDAMap.put(submittedRDA.Asset__c,submittedRDA);          
            Asset updateAsset = updatedAssetMap.get(submittedRDA.Asset__c);
            updateAsset.Handover_Date__c = submittedRDA.Handover_Date__c; 
            updateAsset.Lessee__c = submittedRDA.Lessee__c;
            updateAsset.Driver__c =  submittedRDA.Driver__c;
            if(submittedRDA.RecordtypeId == tradeInRecordTypeId && submittedRDA.Common_Sale_Type__c != null &&  submittedRDA.Common_Sale_Type__c != updateAsset.Common_Sale_Type__c){
                updateAsset.Common_Sale_Type__c = submittedRDA.Common_Sale_Type__c;
                updateAsset.Sale_Type_Code__c =    getCommonTypeOfSaleCodeMetadata().get(submittedRDA.Common_Sale_Type__c.toUpperCase() ).Asset_Sale_Type_Code__c;
            }
            if(submittedRDA.Opportunity__c != null)
                updateOpportunityList.add(new Opportunity(Id = submittedRDA.Opportunity__c, Handed_Over_Date__c = submittedRDA.Handover_Date__c));               
            if(submittedRDA.RecordtypeId == newRetailRecordTypeId || submittedRDA.RecordtypeId == OUVRecordTypeId || submittedRDA.RecordtypeId == dealerOwnedRecordTypeId){
                VISTAAssetHandoverHandler.VISTARequestSenderFuture(submittedRDA.Id);
            }
            updateAsset.AccountId = submittedRDA.Account__c;
             updateAsset.Key_Contact__c = submittedRDA.Contact__c;
            system.debug('submittedRDA.Contact__c '+submittedRDA.Contact__c);
            if(submittedRDA.Registration_Number__c != null && submittedRDA.Registration_Number__c != ''){
                updateAsset.Registration_Number__c = submittedRDA.Registration_Number__c;
            }
            
            if( updateAsset.Original_Handover_Date__c == null){
                updateAsset.Original_Handover_Date__c = submittedRDA.Handover_Date__c;
            }                
            if( (submittedRDA.RecordtypeId == newRetailRecordTypeId  || submittedRDA.RecordtypeId == dealerOwnedRecordTypeId) && updateAsset.Product2.Warranty_Length__c != null &&    updateAsset.Warranty_End_Date__c  == null ){
                //|| submittedRDA.RecordtypeId == OUVRecordTypeId
                if(updateAsset.Warranty_Start_Date__c  == null ){
                    updateAsset.Warranty_Start_Date__c = submittedRDA.Handover_Date__c;
                    updateAsset.Warranty_End_Date__c = submittedRDA.Handover_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1); 
                }else{
                    
                    updateAsset.Warranty_End_Date__c =  updateAsset.Warranty_Start_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1);
                }
                
                
                
            }
            
            //here set the extended
            RDA__c oldrda = null;
            if(triggerOldMap != null && triggerOldMap.containsKey(submittedRDA.Id)){
                oldRDA = triggerOldMap.get(submittedRDA.Id);
            }
            if( (  oldRDA == null ||(oldRDA != null && (oldRDA.Add_Extended_Warranty__c == false || oldRDA.Add_Extended_Warranty__c == null) )) && submittedRDA.Add_Extended_Warranty__c == true && warrantySetting != null ){
                
                if(updateAsset.Warranty_Start_Date__c == null  ){
                    updateAsset.Extended_Warranty_End_Date__c = (submittedRDA.Handover_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1)).addMonths((Integer)warrantySetting.Extended_Warranty_Length_Months__c);  
                    updateAsset.Extended_Warranty_Type__c = warrantySetting.Extended_Warranty_Type__c;
                    if(warrantySetting.Warranty_Mileage__c != null){
                        updateAsset.Warranty_Mileage__c = warrantySetting.Warranty_Mileage__c;   
                    }
                    
                }else{
                    updateAsset.Extended_Warranty_End_Date__c = (updateAsset.Warranty_Start_Date__c.addDays(-1)).addMonths((Integer)warrantySetting.Extended_Warranty_Length_Months__c);  
                    updateAsset.Extended_Warranty_Type__c = warrantySetting.Extended_Warranty_Type__c;
                    if(warrantySetting.Warranty_Mileage__c != null){
                        updateAsset.Warranty_Mileage__c = warrantySetting.Warranty_Mileage__c;   
                    }
                    
                }             
                
            }else{
                if( (  oldRDA == null ||(oldRDA != null && (oldRDA.Add_Extended_Warranty__c == true || oldRDA.Add_Extended_Warranty__c == null) )) && submittedRDA.Add_Extended_Warranty__c == false && warrantySetting != null ){
                    
                    updateAsset.Extended_Warranty_End_Date__c = null;
                    updateAsset.Extended_Warranty_Type__c = null;
                }
            } 
            //here end set the extended //here set the extended
            updateAsset.Vista_Status__c ='Customer Handover'; 
            
            if(submittedRDA.RecordtypeId == OUVRecordTypeId || submittedRDA.RecordtypeId == dealerOwnedRecordTypeId){
                newRetailerRolesList.add(createRetailerAssetRole(submittedRDA.Account__c, submittedRDA.Asset__c,'Current Owner', submittedRDA.Driver__c, submittedRDA.Lessee__c));
            }
            if(!updateIdSet.contains(updateAsset.id)){
                updateAssetList.add(updateAsset);
                updateIdSet.add(updateAsset.id);
            }
        }
        for(RDA__c cancelledRDA : cancelledRDAList){
            totalRDAMap.put(cancelledRDA.Asset__c,cancelledRDA);
            Asset updateAsset = updatedAssetMap.get(cancelledRDA.Asset__c);
            
            if(cancelledRDA.Opportunity__c != null)
                updateOpportunityList.add(new Opportunity(Id = cancelledRDA.Opportunity__c,  Handed_Over_Date__c =null));          
            // if(cancelledRDA.RecordtypeId == newRetailRecordTypeId || cancelledRDA.RecordtypeId == OUVRecordTypeId || cancelledRDA.RecordtypeId == dealerOwnedRecordTypeId){           
            if(updateAsset.AccountId != null) { 
                if(updateAsset.AccountId != null) {
                //CXPD-2448
                if(updateAsset.Account.Owner.Contact.AccountId!=NULL){
                    updateAsset.AccountId = updateAsset.Account.Owner.Contact.AccountId;
                }else if(updateAsset.Account.Owner.Contact.AccountId==null && updateAsset.Previous_Owner__c!=NULL){
                    updateAsset.AccountId = updateAsset.Previous_Owner__c;
                }
                /*if(updateAsset.Previous_Owner__c != null){
                    updateAsset.AccountId = updateAsset.Previous_Owner__c;      
                }
                if(updateAsset.Previous_Owner__c == null && updateAsset.Account.Owner.Contact.AccountId != null){
                    updateAsset.AccountId = updateAsset.Account.Owner.Contact.AccountId;      
                }*/
                
                if(updateAsset.Roles__r.size() > 0) CancelledRolesList.add(updateAsset.Roles__r[0]);
            }
                
                
                if(updateAsset.Roles__r.size() > 0) CancelledRolesList.add(updateAsset.Roles__r[0]);
            }
            if(cancelledRDA.RecordtypeId == newRetailRecordTypeId || cancelledRDA.RecordtypeId == OUVRecordTypeId || cancelledRDA.RecordtypeId == dealerOwnedRecordTypeId){           
                updateAsset.Handover_Date__c = null;
                updateAsset.Vista_Status__c ='Arrived at Dealer';
                updateAsset.Original_Handover_Date__c = null;
                updateAsset.Warranty_Start_Date__c = null;
                updateAsset.Warranty_End_Date__c = null;
                updateAsset.Extended_Warranty_End_Date__c = null;
                updateAsset.Extended_Warranty_Type__c = null;
                updateAsset.Warranty_Mileage__c = null;
            }
            if(cancelledRDA.RecordtypeId == onSellRecordTypeId){
                updateAsset.Handover_Date__c =  updateAsset.Original_Handover_Date__c;
                if(cancelledRDA.Add_Extended_Warranty__c != null && cancelledRDA.Add_Extended_Warranty__c == true){
                    updateAsset.Extended_Warranty_End_Date__c = null;
                    updateAsset.Extended_Warranty_Type__c = null; 
                }
            }
            
            if(!updateIdSet.contains(updateAsset.id)){
                updateAssetList.add(updateAsset);
                updateIdSet.add(updateAsset.id);
            }
        }
        for(Role__c role : CancelledRolesList){
            role.Role__c = 'RDA ERROR';
        }
        if(updateAssetList.size() > 0){
            List<Database.SaveResult> saveResultList  = Database.update(updateAssetList, false);    
            for(Integer i=0;i<saveResultList.size();i++){
                if (!saveResultList[i].isSuccess()) {
                    for (Database.Error error : saveResultList[i].getErrors()) {                      
                        system.debug(error.getMessage());
                        totalRDAMap.get(updateAssetList[i].Id).addError('Related Asset update error : '+error.getMessage());
                    }
                }
            }
        }
        if(CancelledRolesList.size() > 0) update CancelledRolesList;
        if(updateOpportunityList.size() > 0) update updateOpportunityList;
        if(newRetailerRolesList.size() > 0) insert newRetailerRolesList;
    }
    
    private static boolean FieldsCompletedForSubmission(RDA__c rda) {
        //return (loggedInUser.Profile.Name == 'Sales Executive' || loggedInUser.Profile.Name == 'Dealer Principle' || loggedInUser.Profile.Name == 'Sales Manager/Receptionist') &&
        return (rda.Account__c != null && rda.Asset__c != null && rda.Handover_Date__c != null && rda.Registration_Number__c != '' && rda.Retail_Offer_Code__c != '' && ((rda.RecordTypeId == dealerOwnedRecordTypeId || rda.RecordTypeId == OUVRecordTypeId) ? true : rda.Opportunity__c != null));
    }
    
    private static Map<String, Warranty_Setting__mdt> getWarrantySetting() {
        
        Map<String, Warranty_Setting__mdt> warrantySettings = new Map<String, Warranty_Setting__mdt>();
        for(Warranty_Setting__mdt cts : [SELECT Id, MasterLabel, Language, NamespacePrefix, Label,  Extended_Warranty_End_Date__c, Extended_Warranty_Type__c, Warranty_Mileage__c, Extended_Warranty_Length_Months__c, Extended_Warranty_Start_Date__c FROM Warranty_Setting__mdt]){
            if(!warrantySettings.containsKey( cts.MasterLabel)){
                warrantySettings.put(cts.MasterLabel.toUpperCase(),cts);
            }
            
        }
        return warrantySettings; 
        
    }
    
    private static Map<String, String> getCommonTypeOfSaleMetadata() {
        if(commonSaleTypeCodes == null){
            commonSaleTypeCodes = new Map<String, String>();
            for(Common_Type_of_Sale_Code__mdt cts : [SELECT MasterLabel, Common_Sale_Type_Code__c, Buyer_Type_Code__r.Buyer_Type_Description__c FROM Common_Type_Of_Sale_Code__mdt WHERE Buyer_Type_Code__c != null]){
                if(!commonSaleTypeCodes.containsKey( cts.Common_Sale_Type_Code__C)){
                    commonSaleTypeCodes.put(cts.Common_Sale_Type_Code__c.toUpperCase(),cts.MasterLabel);
                }
                
            }
        } 
        return commonSaleTypeCodes;
    }
    
    private static Map<String, String> getBuyerTypeFromMetadata() {
        if(commonBuyerTypeCodes == null){
            commonBuyerTypeCodes = new Map<String, String>();
            for(Common_Type_of_Sale_Code__mdt cts : [SELECT MasterLabel, Buyer_Type_Code__r.Buyer_Type_Description__c FROM Common_Type_Of_Sale_Code__mdt WHERE Buyer_Type_Code__c != null]){
                commonBuyerTypeCodes.put(cts.MasterLabel.toUpperCase(), cts.Buyer_Type_Code__r.Buyer_Type_Description__c);
            }
        } 
        //   System.debug('META commonBuyerTypeCodes'+commonBuyerTypeCodes);
        return commonBuyerTypeCodes;
    }
    private static Map<String, String> getBuyerTypeNumberFromMetadata() {
        
        if(commonBuyerTypeNumbers == null){
            commonBuyerTypeNumbers = new Map<String, String>();
            for(Common_Type_of_Sale_Code__mdt cts : [SELECT MasterLabel, Buyer_Type_Code__r.MasterLabel FROM Common_Type_Of_Sale_Code__mdt WHERE Buyer_Type_Code__c != null]){
                commonBuyerTypeNumbers.put(cts.MasterLabel.toUpperCase(), cts.Buyer_Type_Code__r.MasterLabel);
            }
        } 
        //     System.debug('META commonBuyerTypeNumbers'+commonBuyerTypeNumbers);
        return commonBuyerTypeNumbers;
    }
    private static Map<String, Common_Type_of_Sale_Code__mdt> getCommonTypeOfSaleCodeMetadata() {
        if(commonSaleTypes == null){
            commonSaleTypes = new Map<String, Common_Type_of_Sale_Code__mdt>();
            for(Common_Type_of_Sale_Code__mdt cts : [SELECT MasterLabel,Common_Sale_Type_Code__c,Asset_Sale_Type_Code__c, Buyer_Type_Code__r.Buyer_Type_Description__c FROM Common_Type_Of_Sale_Code__mdt WHERE Buyer_Type_Code__c != null]){
                //commonSaleTypes.put(cts.MasterLabel.toUpperCase(), cts.Common_Sale_Type_Code__c);
                commonSaleTypes.put(cts.MasterLabel.toUpperCase(), cts);
                
            }
        } 
        //    System.debug('META commonSaleTypes'+commonSaleTypes);
        return commonSaleTypes;
    }
    private static Map<String, String> getCommonTypeOfSaleTypeMetadata() {
        if(commonSaleTypeCodes == null){
            commonSaleTypeCodes = new Map<String, String>();
            for(Common_Type_of_Sale_Code__mdt cts : [SELECT MasterLabel,Common_Sale_Type_Code__c, Buyer_Type_Code__r.Buyer_Type_Description__c FROM Common_Type_Of_Sale_Code__mdt WHERE Buyer_Type_Code__c != null]){
                commonSaleTypeCodes.put(cts.Common_Sale_Type_Code__c.toUpperCase(), cts.MasterLabel);
            }
        } 
        //        System.debug('META commonSaleTypeCodes'+commonSaleTypeCodes);
        return commonSaleTypeCodes;
    }
    
    public static Role__c createRetailerAssetRole(Id accountId, Id assetId, String role, Id lessee, Id driver ) {         
        return new Role__c(Account__c = accountId, Vehicle__c = assetId, Role__c=role, Effective_From__c = system.today(), Driver__c=driver, Lessee__c=lessee);         
    }
    public static void UpdateCompletedRDAAssets(List<RDA__c> completedRDAList, Set<Id> updateAssetIdList, Map<Id,RDA__c> triggerNewMap,  Map<Id,RDA__c> triggerOldMap){
        Warranty_Setting__mdt warrantySetting;
        Map<String, Warranty_Setting__mdt> warrantySettings  =getWarrantySetting();
        if(warrantySettings != null && loggedInUser !=  null && loggedInUser.Country_ISO_Code__c != null && warrantySettings.containskey(loggedInUser.Country_ISO_Code__c )){
            warrantySetting = warrantySettings.get(loggedInUser.Country_ISO_Code__c);
        }
        //   System.debug('entered UpdateCompletedRDAAssets');
        Map<Id,Asset> updatedAssetMap = new Map<Id,Asset>([SELECT Id,Extended_Warranty_End_Date__c,AccountId,Model__c,Model__r.Name, Original_Handover_Date__c, Handover_Date__c, Warranty_Start_Date__c, Warranty_End_Date__c, Derivative__c,
                                                           Previous_Owner__c, Vista_Status__c,Product2Id, Product2.Warranty_Length__c, Brand__c, Derivative__r.Model_Alternative__c, Common_Sale_Type__c,
                                                           (SELECT Id,Role__c FROM Roles__r WHERE Role__c = 'Current Owner' LIMIT 1 ) FROM Asset WHERE Id IN :updateAssetIdList]);
        Map<Id,RDA__c> totalRDAMap = new Map<Id,RDA__c>();
        List<Asset> updateAssetList = new List<Asset>();
        Set<Id> updateIdSet = new Set<Id>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        
        List<RDA__c> updatedRDAList = new List<RDA__c>();
        List<Role__c> newRetailerRolesList = new List<Role__c>();
        if(completedRDAList.size() > 0) updatedRDAList.addAll(completedRDAList);       
        if(completedRDAList.size() > 0  && loggedInUser.ContactId != null) TargetAndQuotaUpdater.calculateTargetAndQuota(updatedRDAList,updatedAssetMap);
        
        for(RDA__c submittedRDA : completedRDAList){  
            totalRDAMap.put(submittedRDA.Asset__c,submittedRDA);          
            Asset updateAsset = updatedAssetMap.get(submittedRDA.Asset__c);
            updateAsset.Handover_Date__c = submittedRDA.Handover_Date__c; 
            updateAsset.Lessee__c = submittedRDA.Lessee__c;
            updateAsset.Driver__c =  submittedRDA.Driver__c;
            if(submittedRDA.RecordtypeId == tradeInRecordTypeId && submittedRDA.Common_Sale_Type__c != null &&  submittedRDA.Common_Sale_Type__c != updateAsset.Common_Sale_Type__c){
                updateAsset.Common_Sale_Type__c = submittedRDA.Common_Sale_Type__c;
                
                //  updateAsset.Sale_Type_Code__c =   submittedRDA.Buyer_Type__c;
                //    submittedRDA.Buyer_Type_Number__c;
                updateAsset.Sale_Type_Code__c =   getCommonTypeOfSaleCodeMetadata().get(submittedRDA.Common_Sale_Type__c.toUpperCase() ).Asset_Sale_Type_Code__c;
            }
            if(submittedRDA.Opportunity__c != null)
                updateOpportunityList.add(new Opportunity(Id = submittedRDA.Opportunity__c, Handed_Over_Date__c = submittedRDA.Handover_Date__c));               
            
            updateAsset.AccountId = submittedRDA.Account__c;
            updateAsset.Key_Contact__c = submittedRDA.Contact__c;
            system.debug('submittedRDA.Contact__c '+submittedRDA.Contact__c);
            
            if(submittedRDA.Registration_Number__c != null && submittedRDA.Registration_Number__c != ''){
                updateAsset.Registration_Number__c = submittedRDA.Registration_Number__c;
            }
            
            if( updateAsset.Original_Handover_Date__c == null){
                updateAsset.Original_Handover_Date__c = submittedRDA.Handover_Date__c;
            }                
            
            if( (submittedRDA.RecordtypeId == newRetailRecordTypeId || submittedRDA.RecordtypeId == OUVRecordTypeId || submittedRDA.RecordtypeId == dealerOwnedRecordTypeId) && updateAsset.Product2.Warranty_Length__c != null &&    updateAsset.Warranty_End_Date__c  == null ){
                if(updateAsset.Warranty_Start_Date__c  == null ){
                    updateAsset.Warranty_Start_Date__c = submittedRDA.Handover_Date__c;
                    updateAsset.Warranty_End_Date__c = submittedRDA.Handover_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1); 
                }else{
                    
                    updateAsset.Warranty_End_Date__c =  updateAsset.Warranty_Start_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1);
                }
                
                
                
            }
            //here
            //
            //here set the extended
            RDA__c oldrda = null;
            if(triggerOldMap != null && triggerOldMap.containsKey(submittedRDA.Id)){
                oldRDA = triggerOldMap.get(submittedRDA.Id);
            }
            if( (  oldRDA == null ||(oldRDA != null && (oldRDA.Add_Extended_Warranty__c == false || oldRDA.Add_Extended_Warranty__c == null) )) && submittedRDA.Add_Extended_Warranty__c == true && warrantySetting != null ){
                
                if(updateAsset.Warranty_Start_Date__c == null  ){
                    if(updateAsset.Product2Id != null && updateAsset.Product2.Warranty_Length__c != null && warrantySetting.Extended_Warranty_Length_Months__c != null){
                        updateAsset.Extended_Warranty_End_Date__c = (submittedRDA.Handover_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1)).addMonths((Integer)warrantySetting.Extended_Warranty_Length_Months__c);  
                    }
                    
                    updateAsset.Extended_Warranty_Type__c = warrantySetting.Extended_Warranty_Type__c;
                    if(warrantySetting.Warranty_Mileage__c != null){
                        updateAsset.Warranty_Mileage__c = warrantySetting.Warranty_Mileage__c;   
                    }
                    
                }else{
                    updateAsset.Extended_Warranty_End_Date__c = (updateAsset.Warranty_Start_Date__c.addDays(-1)).addMonths((Integer)warrantySetting.Extended_Warranty_Length_Months__c);  
                    updateAsset.Extended_Warranty_Type__c = warrantySetting.Extended_Warranty_Type__c;
                    if(warrantySetting.Warranty_Mileage__c != null){
                        updateAsset.Warranty_Mileage__c = warrantySetting.Warranty_Mileage__c;   
                    }
                    
                }             
                
            }else{
                if( (  oldRDA == null ||(oldRDA != null && (oldRDA.Add_Extended_Warranty__c == true || oldRDA.Add_Extended_Warranty__c == null) )) && submittedRDA.Add_Extended_Warranty__c == false && warrantySetting != null ){
                    
                    updateAsset.Extended_Warranty_End_Date__c = null;
                    updateAsset.Extended_Warranty_Type__c = null;
                }
            } 
            //here end set the extended
            updateAsset.Vista_Status__c ='Customer Handover'; 
            
            if(submittedRDA.RecordtypeId == OUVRecordTypeId || submittedRDA.RecordtypeId == dealerOwnedRecordTypeId){
                newRetailerRolesList.add(createRetailerAssetRole(submittedRDA.Account__c, submittedRDA.Asset__c,'Current Owner', submittedRDA.Driver__c, submittedRDA.Lessee__c));
            }
            if(!updateIdSet.contains(updateAsset.id)){
                updateAssetList.add(updateAsset); 
            }
            
        }
        
        
        if(updateAssetList.size() > 0){
            List<Database.SaveResult> saveResultList  = Database.update(updateAssetList, false);    
            for(Integer i=0;i<saveResultList.size();i++){
                if (!saveResultList[i].isSuccess()) {
                    for (Database.Error error : saveResultList[i].getErrors()) {                      
                        system.debug(error.getMessage());
                        totalRDAMap.get(updateAssetList[i].Id).addError('Related Asset update error : '+error.getMessage());
                    }
                }
            }
        }
        
        if(updateOpportunityList.size() > 0) update updateOpportunityList;
        if(newRetailerRolesList.size() > 0) insert newRetailerRolesList;
    }
    
    public static void UpdateRDAAssetExtendedWarrantys(List<RDA__c> submittedRDAList, Set<Id> updateAssetIdList,  Map<Id,RDA__c> triggerOldMap){
        System.debug('entered UpdateRDAAssetExtendedWarrantys');
        Warranty_Setting__mdt warrantySetting;
        Map<String, Warranty_Setting__mdt> warrantySettings  =getWarrantySetting();
        if(warrantySettings != null && loggedInUser !=  null && loggedInUser.Country_ISO_Code__c != null && warrantySettings.containskey(loggedInUser.Country_ISO_Code__c )){
            warrantySetting = warrantySettings.get(loggedInUser.Country_ISO_Code__c);
        }
        Map<Id,Asset> updatedAssetMap = new Map<Id,Asset>([SELECT Id,Extended_Warranty_End_Date__c,AccountId,Model__r.Name,Model__c,Account.Owner.Contact.AccountId, Original_Handover_Date__c, Handover_Date__c, Warranty_Start_Date__c, Warranty_End_Date__c, Derivative__c,
                                                           Previous_Owner__c, Vista_Status__c, Product2.Warranty_Length__c, Brand__c, Derivative__r.Model_Alternative__c, Common_Sale_Type__c,
                                                           (SELECT Id,Role__c FROM Roles__r WHERE Role__c = 'Current Owner' LIMIT 1 ) FROM Asset WHERE Id IN :updateAssetIdList]);
        
        //SELECT METADATA TABLE
        
        Map<Id,RDA__c> totalRDAMap = new Map<Id,RDA__c>();
       Map<Id,Asset> updateAssetList = new Map<Id,Asset>();
        
        
        
        
        for(RDA__c submittedRDA : submittedRDAList){  
            totalRDAMap.put(submittedRDA.Asset__c,submittedRDA);          
            Asset updateAsset = updatedAssetMap.get(submittedRDA.Asset__c);           
            //here set the extended
            //here set the extended
            RDA__c oldrda = null;
            if(triggerOldMap != null && triggerOldMap.containsKey(submittedRDA.Id)){
                oldRDA = triggerOldMap.get(submittedRDA.Id);
            }
            if( (  oldRDA == null ||(oldRDA != null && (oldRDA.Add_Extended_Warranty__c == false || oldRDA.Add_Extended_Warranty__c == null) )) && submittedRDA.Add_Extended_Warranty__c == true && warrantySetting != null ){
                
                if(updateAsset.Warranty_Start_Date__c == null  ){
                    
                    if(updateAsset.Product2Id != null && updateAsset.Product2.Warranty_Length__c != null && warrantySetting.Extended_Warranty_Length_Months__c != null){
                        updateAsset.Extended_Warranty_End_Date__c = (submittedRDA.Handover_Date__c.addMonths((Integer) updateAsset.Product2.Warranty_Length__c).addDays(-1)).addMonths((Integer)warrantySetting.Extended_Warranty_Length_Months__c);  
                    }
                    updateAsset.Extended_Warranty_Type__c = warrantySetting.Extended_Warranty_Type__c;
                    if(warrantySetting.Warranty_Mileage__c != null){
                        updateAsset.Warranty_Mileage__c = warrantySetting.Warranty_Mileage__c;   
                    }
                    
                }else{
                    updateAsset.Extended_Warranty_End_Date__c = (updateAsset.Warranty_Start_Date__c.addDays(-1)).addMonths((Integer)warrantySetting.Extended_Warranty_Length_Months__c);  
                    updateAsset.Extended_Warranty_Type__c = warrantySetting.Extended_Warranty_Type__c;
                    if(warrantySetting.Warranty_Mileage__c != null){
                        updateAsset.Warranty_Mileage__c = warrantySetting.Warranty_Mileage__c;   
                    }
                    
                }             
                
            }else{
                if( (  oldRDA == null ||(oldRDA != null && (oldRDA.Add_Extended_Warranty__c == true || oldRDA.Add_Extended_Warranty__c == null) )) && submittedRDA.Add_Extended_Warranty__c == false && warrantySetting != null ){
                    
                    updateAsset.Extended_Warranty_End_Date__c = null;
                    updateAsset.Extended_Warranty_Type__c = null;
                    updateAsset.Warranty_Mileage__c = null;
                }
            }
            
            if((oldRDA == null && submittedRDA.Common_Sale_Type__c != null && submittedRDA.RecordTypeId == tradeInRecordTypeId) || (oldRDA != null && submittedRDA.Common_Sale_Type__c != null && oldRDA.common_Sale_Type__c != submittedRDA.Common_Sale_Type__c )){
                //CXPD 626
                updateAsset.Common_Sale_Type__c = submittedRDA.Common_Sale_Type__c;
                updateAsset.Sale_Type_Code__c =    getCommonTypeOfSaleCodeMetadata().get(submittedRDA.Common_Sale_Type__c.toUpperCase() ).Asset_Sale_Type_Code__c;
            }              
            
            
            if(!updateAssetList.containsKey(updateAsset.id)){
                updateAssetList.put(updateAsset.id,updateAsset); 
            }
            
        }
        if(updateAssetList!= null && updateAssetList.size() > 0){
           update updateAssetList.values(); 
        }
        
        
    }
    
    //Added by Suhan CXPD-768
    public static void updateNotCancelledRDACount(List<RDA__c> RDAList)
    {
        List<Asset> assetsForUpdateLst= New List<Asset>();
        set<Id> assetIdSet= New Set<Id>();
        set<Id> rdaIdSet= New Set<Id>();
        for(RDA__c singleRda:RDAList)
        {
            rdaIdSet.add(singleRda.id);
            if(singleRda.Asset__c !=null)assetIdSet.add(singleRda.Asset__c);
        } 
        
        if(!assetIdSet.isEmpty())
        {
            Map<Id,Asset> assetsMap= New Map<Id,Asset>([select id, Non_Cancelled_RDA_Count__c, (select id from RDAs__r where Submitted_Status__c !='Cancelled' AND ID NOT IN:rdaIdSet ) from Asset where ID In:assetIdSet]);
            
            for(Asset objAsset:assetsMap.Values())
            {
                objAsset.Non_Cancelled_RDA_Count__c=objAsset.RDAs__r !=null ? objAsset.RDAs__r.size():0;
                assetsForUpdateLst.add(objAsset);
            }
            
            if(!assetsForUpdateLst.isEmpty())
                update assetsForUpdateLst;
        }
        
    }
    
}
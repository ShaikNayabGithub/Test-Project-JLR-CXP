/*
* S.No.		Name		Date(DD/MM/YYYY)	Change
* 1.0		Ashwin		05/05/2021			CXPD-1218: Updated getExistingSP query to filter active Service Plan Contract 
* 
*/
public without sharing class NewRDA_LC_Controller {
    
    @AuraEnabled
    public static Map<String,String> getFieldLabel(String objectName) {
        return SchemaUtility.getObjectLabelMap(objectName);      
    }
    
    @AuraEnabled
    public static List<String> getDropdownCommonSaleType() {
        
        List<string> values = new List<string>();
        List<Common_Type_of_Sale_Code__mdt> csts = [SELECT Label FROM Common_Type_of_Sale_Code__mdt WHERE Available_for_Trade_In_Selection__c = true order by label asc];
        
        for(Common_Type_of_Sale_Code__mdt cst : csts){
            values.add(cst.label);
        }
        
        return values;
    }
    
     @AuraEnabled
    public static Affinity_Program_Status__mdt getAffinityProgramStatus() {
        return [select id,Affinity_Disabled__c,Disabled_Message__c from Affinity_Program_Status__mdt where label = 'Affinity Program'];
    }
    
    @AuraEnabled
    public static Asset getAsset(Id assetId) {
        return [SELECT Id, Product2Id, Product2.Name, Product2.Product_Description__c, Product2.Specification_Pack_Alternative__c, Product2.Model_Alternative__c, Product2.Model_Year__c, Brand__r.Name, Model__r.Name, Registration_Number__c, Exterior_Colour__c, Common_Sale_Type__c, Derivative__r.Service_Plan__c, Account.Owner.Contact.AccountId,  Warranty_Start_Date__c, Warranty_Mileage__c, Warranty_Length__c, Warranty_End_Date__c, Extended_Warranty_Type__c, Extended_Warranty_End_Date__c FROM Asset WHERE Id = :assetId];
    }
    
    @AuraEnabled
    public static List<Service_Plan_Contract__c>  getExistingSP(Id assetId) {
        
        //1.0 - CXPD-1218
        return [Select Id,   Name, Cancellation_Date__c, 
                Contract_Term_Months__c, Disposal_Date__c, End_Date__c, Mileage_Months__c, Mileage__c, Months__c, Policy_Number__c, Retailer_Id__c, Service_Plan_Product__c,Service_Plan_Product__r.Name, Service_Plan_Type__c, Start_Date__c,  
                Vehicle_Id__c, Assignment_Type__c, Corporate_Partner__c,Corporate_Partner__r.Name, Retail_Purchase_Price__c,
                Service_Plan_Incremental__c, Service_Plan_Reference__c, Month_Submitted__c, RDA__c, Is_Active__c from Service_Plan_Contract__c where Vehicle_Id__c = :assetId AND Is_Active__c = true];
        
    }
    
    @AuraEnabled
    public static OpportunityLineItem getComplimentaryOffer(Id assetId) {
        
        
        OpportunityLineItem opl;
        List<Offers__c> validOffs = new List<Offers__c>();
        List<Service_Plan_Contract__c> existingActiveServicePlans = [Select Id,   Name, Cancellation_Date__c, 
                                                                     Contract_Term_Months__c, Disposal_Date__c, End_Date__c, Mileage_Months__c, Mileage__c, Months__c, Policy_Number__c, Retailer_Id__c, Service_Plan_Product__c,Service_Plan_Product__r.Name, Service_Plan_Type__c, Start_Date__c,  
                                                                     Vehicle_Id__c, Assignment_Type__c, Corporate_Partner__c,Corporate_Partner__r.Name, Retail_Purchase_Price__c,
                                                                     Service_Plan_Incremental__c, Service_Plan_Reference__c, Month_Submitted__c, RDA__c, Is_Active__c from Service_Plan_Contract__c where Vehicle_Id__c = :assetId AND  Is_Active__c = true];
        if(existingActiveServicePlans == null || (existingActiveServicePlans != null && existingActiveServicePlans.size() == 0 ) ){
            Asset ass =  [SELECT Id, Product2Id, Derivative__c, Derivative__r.Service_Plan__c FROM Asset WHERE Id = :assetId];
            if(ass.Product2Id != null){
                List<Offers__c> offs = [Select Id, name, Service_Plan_Product2Id__c, Start_Date__c, End_Date__c FROM Offers__c WHERE Derivative_Product2Id__c = :ass.Product2Id AND IsActive__c = true AND Type__c = 'Complimentary'];           
                if( ass.Derivative__c != null && offs != null && offs.size() > 0){
                    for(Offers__c off : offs){
                        if(off.Start_Date__c < System.today() && (off.End_Date__c != null && off.End_Date__c > System.today() || off.End_Date__c == null) ){
                            validOffs.add(off);
                        }                  
                    }
                    if(validOffs != null && validOffs.size()>0){
                        
                        //                Product2 prod =  [SELECT Id, Product__c, Service_Plan_Code__c,(SELECT Id,CurrencyIsoCode, unitPrice, name, Pricebook2.name from PricebookEntries), Corporate_Programme_Code__c, Mileage_Months__c, Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c, RecordTypeId FROM Product2 WHERE Id = :validOffs[0].Service_Plan_Product2Id__c];      
                        Product2 prod =  [SELECT Id, Product__c, Service_Plan_Code__c,(SELECT Id,CurrencyIsoCode, unitPrice, name, Pricebook2.name from PricebookEntries), Corporate_Programme_Code__c, Mileage_Months__c, Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c, RecordTypeId FROM Product2 WHERE Id = :ass.Derivative__r.Service_Plan__c];      
                        opl =   new OpportunityLineItem();
                        opl.Product2= prod;        
                        opl.Quantity = 1; 
                    } 
                }
            }
        }
        return opl;
    }
    
    @AuraEnabled
    public static OpportunityLineItem getServicePlan(Id opportunityId) {
        Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
        OpportunityLineItem opl = new OpportunityLineItem();
        if(opportunityId != null ){
            List<OpportunityLineItem> OpportunityLineItemList = [SELECT Id, OpportunityId,Opportunity.Corporate_Partner_Account__c,Opportunity.Corporate_Partner_Account__r.Name, Assignment_Type__c, Product2Id, Product2.Product__c, Product2.Service_Plan_Code__c, Product2.Corporate_Programme_Code__c, Product2.Mileage_Months__c, Product2.Mileage_Measure__c, Product2.Miles_Kilometers__c, Product2.Service_Plan_Type__c, Product2.Indicator__c, Product2.Transferable__c, Product2.Months__c, Product2.RecordTypeId FROM OpportunityLineItem WHERE OpportunityId = :opportunityId AND Product2Id != null AND Product2.RecordTypeId =:ServiceplanrectypeId];
            if(OpportunityLineItemList != null && !OpportunityLineItemList.isEmpty()){
                opl = OpportunityLineItemList.get(0);
            }
        }
        return opl;
    }
    @AuraEnabled
    public static OpportunityLineItem refreshServicePlan(string productId, Id opportunityId) {
        Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
        system.debug('productId '+productId);
        system.debug('opportunityId '+opportunityId);
        Product2 prod;
        if(productId != null && productId != ''){
            prod =  [SELECT Id, Product__c, Service_Plan_Code__c,(SELECT Id,CurrencyIsoCode, unitPrice, name, Pricebook2.name from PricebookEntries), Corporate_Programme_Code__c, Mileage_Months__c, Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c, RecordTypeId FROM Product2 WHERE Id = :productId];
            
        }else{
            
            List<OpportunityLineItem> oppsLine = [SELECT id,Product2Id, Product2.Service_Plan__c FROM OpportunityLineItem WHERE  opportunityId = :opportunityId AND Asset__c != null];
            system.debug('oppsLine '+oppsLine);
            if(oppsLine != null && oppsLine.size() > 0 && oppsLine[0].Product2.Service_Plan__c != null ){
                
                
                prod =  [SELECT Id, Product__c, Service_Plan_Code__c,(SELECT Id,CurrencyIsoCode, unitPrice, name, Pricebook2.name from PricebookEntries), Corporate_Programme_Code__c, Mileage_Months__c, Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c, RecordTypeId FROM Product2 WHERE Id = :oppsLine[0].Product2.Service_Plan__c];
                system.debug('prod '+prod);
            }
            
        }
        //OpportunityLineItem opl =  [SELECT Id, OpportunityId, Product2Id, Product2.Product__c, Product2.Service_Plan_Code__c, Product2.Corporate_Programme_Code__c, Product2.Mileage_Months__c, Product2.Mileage_Measure__c, Product2.Miles_Kilometers__c, Product2.Service_Plan_Type__c, Product2.Indicator__c, Product2.Transferable__c, Product2.Months__c, Product2.RecordTypeId FROM OpportunityLineItem WHERE OpportunityId = :opportunityId AND Product2Id != null AND Product2.RecordTypeId =:ServiceplanrectypeId];
        // Product2 prod =  [SELECT Id, Product__c, Service_Plan_Code__c,(SELECT Id,CurrencyIsoCode, unitPrice, name, Pricebook2.name from PricebookEntries), Corporate_Programme_Code__c, Mileage_Months__c, Mileage_Measure__c, Miles_Kilometers__c, Service_Plan_Type__c, Indicator__c, Transferable__c, Months__c, RecordTypeId FROM Product2 WHERE Id = :productId];
        //Service_Plan__c
        OpportunityLineItem opl = new OpportunityLineItem();
        opl.Product2= prod;
        opl.OpportunityId = opportunityId;
        opl.Quantity = 1;
        system.debug('opl '+opl);
        return opl;
    }
    
    @AuraEnabled
    public static Asset getTradeIn(Id assetId) {
        return [SELECT Id, Brand__r.Name, Model__r.Name, Product2.Model_Year__c,Model__r.Model_Vehicle_spec__c,Model__r.Model_Vehicle_spec__r.Name, AccountId FROM Asset WHERE Id = :assetId];
    }
    
    @AuraEnabled
    public static Opportunity getOpportunity(Id opportunityId) {
        /*       Trade_in_Mileage__c , Revised_Trade_in_Brand__c ,  Revised_Trade_in_Model__c, Trade_in_Registration_Number__c, Model_Year__c, Revised_Trade_in_Value__c ,Service_History__c , JLR_Trade_In__c ,*/
        
        return [SELECT Id, Owner.Name,Trade_In_Brand_Lookup__c,Trade_In__c , Trade_In_Model_Lookup__c , Primary_Contact__c,Primary_Contact__r.Id,Primary_Contact__r.Email,Primary_Contact__r.MobilePhone,Primary_Contact__r.FirstName,Primary_Contact__r.LastName,Primary_Contact__r.MailingState,Primary_Contact__r.MailingPostalCode ,Primary_Contact__r.MailingCity , Primary_Contact__r.MailingStreet, Trade_in_Mileage__c , Revised_Trade_in_Brand__c ,  Revised_Trade_in_Model__c, Trade_in_Registration_Number__c, Model_Year__c, Revised_Trade_in_Value__c,Service_History__c , JLR_Trade_In__c    FROM Opportunity WHERE Id = :opportunityId];
    }
    @AuraEnabled
    public static Account getAccount(Id accountId) {
        return [SELECT Id,Name,LastName,BillingStreet, Loyalty_scheme__c, BillingState, BillingCity, BillingPostalCode, FirstName,Retailer_Email__c,PersonHomePhone , Phone,PersonEmail,PersonMobilePhone,PersonContactId, IsPersonAccount FROM Account WHERE Id = :accountId];
    }
    @AuraEnabled
    public static RDAWrapper getRDA(String rdaId) {
        RDAWrapper rdaWrap = new RDAWrapper();
        rdaWrap.fmoTrueList = new List<String>();
        for(Common_Type_of_Sale_Code__mdt custMdt:[SELECT MasterLabel from Common_Type_of_Sale_Code__mdt WHERE Default_FMO__c = true]) {
            rdaWrap.fmoTrueList.add(custMdt.MasterLabel);
        }
        rdaWrap.rdaInst = [SELECT Id, Asset__c, RecordTypeId, RecordType.DeveloperName, Opportunity__c, Account__c, Handover_Date__c, Common_Type_of_Sale_Code__c, Buyer_Type__c, Submitted_Status__c, Is_Locked__c, Is_Out_Of_Date__c FROM RDA__c WHERE Id = :rdaId];
        return rdaWrap;
    }
    
    @AuraEnabled
    public static List<AU_Locality__c> getLocations(Id accountId, Id oppId) {
        List<AU_Locality__c> auLocations = null;
        Account acc;
        Contact con;
        Opportunity opp;
        if(accountId != null){
            acc =  [SELECT BillingCity, BillingPostalCode FROM Account WHERE Id = :accountId];
        }
        if(oppId != null ){
            opp = [SELECT Primary_Contact__c, Primary_Contact__r.MailingCity, Primary_Contact__r.MailingPostalCode FROM Opportunity where Id =:oppId];
            if(opp != null && opp.Primary_Contact__c != null){
                con = new Contact();
                con.MailingCity = opp.Primary_Contact__r.MailingCity;
                con.MailingPostalCode = opp.Primary_Contact__r.MailingPostalCode;
            }
        }
        if(acc != null && acc.BillingPostalCode != null){
            List<AU_Locality__c> postcodeLocations = [SELECT Id, Name,State__c, PMA_Postcode__r.Name FROM AU_Locality__c WHERE PMA_Postcode__r.Name = :acc.BillingPostalCode];
            for(AU_Locality__c auloc : postcodeLocations){
                if(auloc.Name == acc.BillingCity){
                    auLocations = new List<AU_Locality__c>();
                    auLocations.add(auloc);
                }
            }
            if(auLocations == null){
                auLocations = postcodeLocations.clone();
            }
        }
        if(con != null && con.MailingPostalCode != null){
            List<AU_Locality__c> postcodeLocations = [SELECT Id, Name,State__c, PMA_Postcode__r.Name FROM AU_Locality__c WHERE PMA_Postcode__r.Name = :con.MailingPostalCode];
            for(AU_Locality__c auloc : postcodeLocations){
                if(auloc.Name == con.MailingCity){
                    auLocations = new List<AU_Locality__c>();
                    auLocations.add(auloc);
                }
            }
            if(auLocations == null){
                auLocations = postcodeLocations.clone();
            }
        }
        if(auLocations == null){
            auLocations = new List<AU_Locality__c>();
        }
        return auLocations;
    }
    @AuraEnabled
    public static List<AU_Locality__c> refreshLocations(String billingPostalCode, string billingCity) {
        List<AU_Locality__c> auLocations = null;
        system.debug('billingPostalCode '+ billingPostalCode);
        system.debug('billingPostalCode.length() '+ billingPostalCode.length());
        system.debug('billingCity '+ billingCity);
        
        if(billingPostalCode != null && billingPostalCode.length() > 2){
            system.debug('Searching '+ billingCity);
            
            string billingPostalCodeWild = billingPostalCode + '%';
            List<AU_Locality__c> postcodeLocations = [SELECT Id, Name,State__c, PMA_Postcode__r.Name FROM AU_Locality__c WHERE PMA_Postcode__r.Name Like:billingPostalCodeWild or PMA_Postcode__r.Name =:billingPostalCode  limit 105];
            system.debug('postcodeLocations '+ postcodeLocations);
            for(AU_Locality__c auloc : postcodeLocations){
                if(auloc.Name == billingCity){
                    auLocations = new List<AU_Locality__c>();
                    auLocations.add(auloc);
                }
            }
            if(auLocations == null){
                auLocations = postcodeLocations.clone();
            }
        }
        if(auLocations == null){
            auLocations = new List<AU_Locality__c>();
        }
        system.debug('auLocations '+ auLocations);
        return auLocations;
    }
    
    @AuraEnabled
    public static List<Offers__c> searchServicePlan(string accountName) {
        Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
        system.debug('accountName '+accountName);
        accountName = accountName +'%';
        
        //OpportunityLineItem opl =  [SELECT Id, OpportunityId, Product2Id, Product2.Product__c, Product2.Service_Plan_Code__c, Product2.Corporate_Programme_Code__c, Product2.Mileage_Months__c, Product2.Mileage_Measure__c, Product2.Miles_Kilometers__c, Product2.Service_Plan_Type__c, Product2.Indicator__c, Product2.Transferable__c, Product2.Months__c, Product2.RecordTypeId FROM OpportunityLineItem WHERE OpportunityId = :opportunityId AND Product2Id != null AND Product2.RecordTypeId =:ServiceplanrectypeId];
        List<Offers__c> offers =  [SELECT Id, Service_Plan_Product2Id__c, Service_Plan_Product2Id__r.Service_Plan_Code__c, Service_Plan_Product2Id__r.Corporate_Programme_Code__c,
                                   Service_Plan_Product2Id__r.Mileage_Months__c, Service_Plan_Product2Id__r.Mileage_Measure__c, Service_Plan_Product2Id__r.Miles_Kilometers__c, Service_Plan_Product2Id__r.Service_Plan_Type__c,
                                   Service_Plan_Product2Id__r.Indicator__c, Service_Plan_Product2Id__r.Transferable__c, Service_Plan_Product2Id__r.Months__c, Service_Plan_Product2Id__r.RecordTypeId FROM Offers__C 
                                   WHERE Corporate_Partner__r.Name Like :accountName];
        system.debug('offers'+ Json.serializePretty(offers));
        
        return offers;
    }
    
    
    @AuraEnabled
    public static Loyalty_Points_Transaction__c getLoyaltyTransaction(String accountId, String assetId, String recordId) {
        Loyalty_Points_Transaction__c LPT;
        try {
            if(recordId != null ){
                List<Loyalty_Points_Transaction__c> LPTList  = [SELECT Id,Transaction_Delivery_Status__c,Account_Name__c,Loyalty_Scheme_Reference__c, Bonus_Points__c, Base_Points__c, Loyalty_Points__c,Rejection_Reason__c FROM Loyalty_Points_Transaction__c WHERE RDA__c =:recordId order by createddate desc];
                if(LPTList != null && !LPTList.isEmpty() ){
                    LPT = LPTList[0];
                }
                SYstem.debug( 'LPT '+LPT );
                //return LPT;   
            }
            // Account currentAccount = [SELECT Id, Name,LastName, Loyalty_Scheme__c, Loyalty_Scheme_Reference__c, IsPersonAccount FROM Account WHERE Id=:accountId ];
            Account currentAccount;
            List<Account> currentAccounts = [SELECT Id, Name,LastName, Loyalty_Scheme__c, Loyalty_Scheme_Reference__c, IsPersonAccount FROM Account WHERE Id=:accountId];
            if(currentAccounts != null && currentAccounts.size() >0){
                currentAccount = currentAccounts[0];
            }
            Asset currentAsset;
            Loyalty_points__c loyaltyPoints;
            List<Asset> currentAssets = [SELECT Id, Product2id FROM Asset WHERE Id=:assetId AND Product2id != null];
            if(currentAssets != null && !currentAssets.isEmpty() ){
                currentAsset = currentAssets[0];
            }
            if(currentAccount != null && currentAsset != null && LPT == null){
                system.debug('LPT is not there asset not null and current account not null');
                /*  Loyalty_points__c loyaltyPoints =  [SELECT Id, Number_of_Points__c, Offer_End_Date__c, Is_Eligible__c, Corporate_multiplier__c, Bonus_Points__c,Offer_Start_Date__c, 
                Individual_multiplier__c, Product__c, Loyalty_Scheme__c FROM Loyalty_points__c WHERE Product__c =: currentAsset.Derivative__c AND
                Loyalty_Scheme__c=:currentAccount.Loyalty_Scheme__c AND  Offer_End_Date__c >= :system.Date.today() AND Offer_Start_Date__c <= :system.Date.today() LIMIT 1];*/
                if(currentAccount.IsPersonAccount){
                    loyaltyPoints =  [SELECT Id, Number_of_Points__c, Offer_End_Date__c, Is_Eligible__c, Corporate_multiplier__c, Bonus_Points__c,Offer_Start_Date__c, Loyalty_type__c,
                                      Individual_multiplier__c, Product__c, Loyalty_Scheme__c FROM Loyalty_points__c WHERE Product__c =: currentAsset.Product2id AND
                                      Offer_End_Date__c >= :system.Date.today() AND Offer_Start_Date__c <= :system.Date.today() AND Loyalty_type__c ='Individual' LIMIT 1];
                    
                }else{
                    loyaltyPoints =  [SELECT Id, Number_of_Points__c, Offer_End_Date__c, Is_Eligible__c, Corporate_multiplier__c, Bonus_Points__c,Offer_Start_Date__c, Loyalty_type__c,
                                      Individual_multiplier__c, Product__c, Loyalty_Scheme__c FROM Loyalty_points__c WHERE Product__c =: currentAsset.Product2id AND
                                      Offer_End_Date__c >= :system.Date.today() AND Offer_Start_Date__c <= :system.Date.today() AND Loyalty_type__c ='Corporate' LIMIT 1];
                }
                
                LPT = new Loyalty_Points_Transaction__c();           
                //LPT.Transaction_Date__c = singleRDA.Submitted_Date__c;
                LPT.Transaction_Delivery_Status__c ='Waiting to be Sent';
                LPT.Account_Name__c = currentAccount.IsPersonAccount ? currentAccount.LastName : currentAccount.Name;
                LPT.Loyalty_Scheme_Reference__c = currentAccount.Loyalty_Scheme_Reference__c; 
                LPT.Transaction_Date__c = Date.valueOf(system.today());
                if(loyaltyPoints != null) LPT=  RDALoyaltypointsCaliculation.pointsUpdate_New(LPT,loyaltyPoints, currentAccount.IsPersonAccount);
            }
        }catch(exception excep){
            system.debug(excep);
        }
        
        system.debug('LAST LPT '+LPT);
        return LPT;
    }
    
    
    @AuraEnabled
    public static Map<String,String> getContactLoyaltyStatus(String accountId) {
        Map<String,String> returnMap = new Map<String,String>{'successMessage' => null, 'errormessage' => null};
            try{
                Account currentAccount = [SELECT Id, Loyalty_Scheme_Reference__c, LastName, Name, IsPersonAccount FROM Account WHERE Id=: accountId];
                system.debug('Current Account '+currentAccount);
                if(currentAccount.Loyalty_Scheme_Reference__c != null && currentAccount.Loyalty_Scheme_Reference__c != ''){
                    GetContactLoyaltyStatusRequestDto request = new GetContactLoyaltyStatusRequestDto();
                    request.Contact.Attributes.QantasFrequentFlyerNumber = currentAccount.Loyalty_Scheme_Reference__c ; // '9023465';
                    request.Contact.Attributes.NameLast = currentAccount.IsPersonAccount ? currentAccount.LastName : currentAccount.Name ;// 'BobMarly';
                    GetContactLoyaltyStatusResponseDto response= ContactsController.getContactLoyaltyStatus(request);
                    system.debug('RESPONSE '+response);
                    if(response.errors != null){                        
                        returnMap.put('errormessage', response.errors[0].errorMessage );                        
                    }else{
                        returnMap.put('successMessage', response.Data.Attributes.Message); 
                    }
                }
            }catch(exception excep){
                returnMap.put('errormessage', excep.getMessage() );
            }
        return returnMap;
    }
    @AuraEnabled
    public static Map<String,String> getChangedContactLoyaltyStatus( string loyalty_Scheme_Reference, string name) {
        System.debug('Called getChangedContactLoyaltyStatus with  '+loyalty_Scheme_Reference );
        System.debug('Called getChangedContactLoyaltyStatus with  '+name );
        Map<String,String> returnMap = new Map<String,String>{'successMessage' => null, 'errormessage' => null};
            try{                     
                if(name != null && name != '' && loyalty_Scheme_Reference != null && loyalty_Scheme_Reference != ''){
                    GetContactLoyaltyStatusRequestDto request = new GetContactLoyaltyStatusRequestDto();
                    request.Contact.Attributes.QantasFrequentFlyerNumber = loyalty_Scheme_Reference; // '9023465';
                    request.Contact.Attributes.NameLast = name;// 'BobMarly';
                    GetContactLoyaltyStatusResponseDto response= ContactsController.getContactLoyaltyStatus(request);           
                    system.debug('RESPONSE '+response);
                    if(response.errors != null){                        
                        returnMap.put('errormessage', response.errors[0].errorMessage );                        
                    }else{
                        returnMap.put('successMessage', response.Data.Attributes.Message); 
                    }
                    
                }
            }catch(exception excep){
                returnMap.put('errormessage', excep.getMessage() );
            }
        return returnMap;
    }
    @AuraEnabled
    public static List<Asset> getTradeInAssets(string search){
        
        search = search+'%';
        List<Asset> asses = [SELECT Id, Name,  Brand__r.Name, Model__r.Name, Product2.Model_Year__c,Model__r.Model_Vehicle_spec__c,Model__r.Model_Vehicle_spec__r.Name,  AccountId, Registration_Number__c, VIN__c FROM Asset WHERE ( Account.Country_Iso_Code__c = 'AU' OR Account.Country_Iso_Code__pc = 'AU' )  AND ( Registration_Number__c LIKE :search OR VIN__c LIKE :search OR Name Like :search ) limit 3 ];
        //System.debug('asses'+asses);
        return asses;
        
        
    }
    
    public class servicePlanDetail {
        @AuraEnabled public OpportunityLineItem oppLineItem;
        @AuraEnabled public List<Service_Plan_Contract__c> spcs;
        
    }
    @AuraEnabled
    public static List<String> getTrueFMOList() {
        List<String> fmoTrueList = new List<String>();
        for(Common_Type_of_Sale_Code__mdt custMdt:[SELECT MasterLabel from Common_Type_of_Sale_Code__mdt WHERE Default_FMO__c = true]) {
            fmoTrueList.add(custMdt.MasterLabel);
        }
        return fmoTrueList;
    }
    public class RDAWrapper {
        @AuraEnabled
        public RDA__c rdaInst;
        @AuraEnabled
        public List<String> fmoTrueList;
    }
    
    
}
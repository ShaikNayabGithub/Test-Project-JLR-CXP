/****
ClassName      :  RDA Controller  
LastModified By:  Avinash Gaddipati // 14-10-2022
Description    :  It is Covering Creation of RDA's For both Australia And MENA.
****/

public with sharing class RDAController {    
    
    public static Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
    public static User loggedInUser = [SELECT Id, Contact.AccountId, profile.Name, Country_ISO_Code__c FROM User WHERE Id = :userinfo.getUserId()];
    public static Id onSellRDARecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    public static Id newRetailerRDARecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id tradeInRDARecordtype = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Trade_In').getRecordTypeId();
    public static List<RDADetail> assetList;
    
     public class InitWrapper {
        @AuraEnabled public boolean perset = false;
        @AuraEnabled public list<RDADetail> assets;
     }
    @AuraEnabled
    public static InitWrapper initAssets() { 
        InitWrapper inwrap = new InitWrapper();
        inwrap.assets = searchAssets(); 
        list<PermissionSetAssignment> userperset = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId =: loggedInUser.id AND PermissionSet.Name = 'Handover_Stock_Controller_RDA'];
        system.debug('users permissionset=:' + userperset);
        if(!userperset.isempty() || userperset.size() > 0){
            inwrap.perset = true;
        }
        system.debug('inwrap:'+inwrap.perset);
        return inwrap;
        
    }
    
    @AuraEnabled
    public static List<RDADetail> searchAssets() {
        List<Asset> allAssets;
        Map<String,boolean> validOppMap = new Map<String,boolean>();
        Set<String> rdaTypes = new Set<String>();
        Set<String> SaleCodeMetaValue = new Set<String>();
        Set<String> SaleTypeMetaValue = new Set<String>();
        Set<String> Vistastatusvalue = new Set<String>();
        Map<String, List<Defined_values_for_RDA_type__mdt>> rdaMetas = new Map<String, List<Defined_values_for_RDA_type__mdt>>(); //List of Custom Metadata records against RDA Type
        RDA_Locked__mdt rdaLock = [Select RDA_Locked__c from RDA_Locked__mdt limit 1];
        Boolean locked = false;
		
        if(rdaLock != null && rdaLock.RDA_Locked__c != null){
            locked = rdaLock.RDA_Locked__c;
        }        
        
        for(Defined_values_for_RDA_type__mdt rdameta : [SELECT Id, Sale_Type_Code__c, Common_Sale_Type__c, Common_Status_Point__c, Purchase_Type__c, Type_of_RDA__c, RDA_Exists__c
                                                        FROM Defined_values_for_RDA_type__mdt]){
                                                            rdaTypes.add(rdameta.Type_of_RDA__c);
                                                            SaleCodeMetaValue.add(rdameta.Sale_Type_Code__c);
                                                            SaleTypeMetaValue.add(rdameta.Common_Sale_Type__c);
                                                            Vistastatusvalue.add(rdameta.Common_Status_Point__c);
                                                            List<Defined_values_for_RDA_type__mdt> metaList = new List<Defined_values_for_RDA_type__mdt>();
                                                            if(rdaMetas.containsKey(rdameta.Type_of_RDA__c)){
                                                                metaList = rdaMetas.get(rdameta.Type_of_RDA__c);
                                                            }
                                                            metaList.add(rdameta);
                                                            rdaMetas.put(rdameta.Type_of_RDA__c, metaList);
                                                        }
        
		for(Common_Sale_Type_and_Account_Type_Mappin__mdt cst : [SELECT Label, Valid_for_Person_Account__c from Common_Sale_Type_and_Account_Type_Mappin__mdt ]){
            validOppMap.put(cst.Label, cst.Valid_for_Person_Account__c);
        }
        if(rdaMetas.size() > 0){
            if (Test.isRunningTest()) {
                allAssets = [SELECT Id, Name, Sale_Type_Code__c, Common_Sale_Type__c, Brand__r.Name, Model__r.Name, Vista_Status__c, Traded_In__c, AccountId, Account.Name, Product2.Product_Description__c, Account.Owner.Contact.AccountId,
                            (SELECT Id, Recordtypeid FROM RDAs__r WHERE Submitted_Status__c != 'Cancelled' ), 
                            (SELECT Id, OpportunityId, Opportunity.Name, Opportunity.Purchase_Type__c, Opportunity.AccountId, Opportunity.Account.IsPersonAccount, Opportunity.Account.Name, Opportunity.Owner.Name 
                            FROM Opportunity_Product__r WHERE Opportunity.IsWon = true AND Opportunity.Handed_Over_Date__c = NULL AND Opportunity.StageName ='Handover & RDA')
                            FROM Asset WHERE Sale_Type_Code__c IN :SaleCodeMetaValue AND Common_Sale_Type__c IN :SaleTypeMetaValue AND Vista_Status__c IN :Vistastatusvalue And Account.Country_ISO_Code__c  =: loggedInUser.Country_ISO_Code__c
                            ];
            }else if(loggedInUser.contact != null){
                allAssets = [SELECT Id, Name, Sale_Type_Code__c, Common_Sale_Type__c, Brand__r.Name, Model__r.Name, Vista_Status__c, Traded_In__c, AccountId, Account.Name, Product2.Product_Description__c, Account.Owner.Contact.AccountId,
                            (SELECT Id, Recordtypeid FROM RDAs__r WHERE Submitted_Status__c != 'Cancelled' ), 
                            (SELECT Id, OpportunityId, Opportunity.Name, Opportunity.Purchase_Type__c, Opportunity.AccountId, Opportunity.Account.IsPersonAccount, Opportunity.Account.Name, Opportunity.Owner.Name 
                            FROM Opportunity_Product__r WHERE Opportunity.IsWon = true AND Opportunity.Handed_Over_Date__c = NULL AND Opportunity.StageName ='Handover & RDA')
                            FROM Asset WHERE Sale_Type_Code__c IN :SaleCodeMetaValue AND Common_Sale_Type__c IN :SaleTypeMetaValue AND Vista_Status__c IN :Vistastatusvalue And AccountId  =: loggedInUser.Contact.AccountId
                            ];
            }else{
                allAssets = [SELECT Id, Name, Sale_Type_Code__c, Common_Sale_Type__c, Brand__r.Name, Model__r.Name, Vista_Status__c, Traded_In__c, AccountId, Account.Name, Product2.Product_Description__c, Account.Owner.Contact.AccountId,
                            (SELECT Id, Recordtypeid FROM RDAs__r WHERE Submitted_Status__c != 'Cancelled' ), 
                            (SELECT Id, OpportunityId, Opportunity.Name, Opportunity.Purchase_Type__c, Opportunity.AccountId, Opportunity.Account.IsPersonAccount, Opportunity.Account.Name, Opportunity.Owner.Name 
                            FROM Opportunity_Product__r WHERE Opportunity.IsWon = true AND Opportunity.Handed_Over_Date__c = NULL AND Opportunity.StageName ='Handover & RDA')
                            FROM Asset WHERE ( Sale_Type_Code__c = 'EXB' OR  Sale_Type_Code__c = 'OUV') And Account.Country_ISO_Code__c  =: loggedInUser.Country_ISO_Code__c AND Vista_Status__c = 'Arrived at Dealer' ];
            }
        }
        
        if(allAssets != null && allAssets.size() > 0){
            RDAControllerSystem outOfContextSearch = new RDAControllerSystem();
            set<ID> assetswithRDA = new Set<ID>();
            List<RDA__c> allRdas =outOfContextSearch.getRDAsRelatedToAssets(allAssets);
			
            if(allRdas != null && allRdas.size()> 0){
                for (Integer i = 0;i<allRdas.size();i++) {
                    RDA__c rdaIns = allRdas.get(i);
                    assetswithRDA.add(rdaIns.asset__c);
                }
            }
            assetList = new List<RDADetail>();
            for (Integer j=0; j<allAssets.size(); j++) {
                Asset ass = allAssets.get(j);
                for(String rdaType : rdaMetas.keySet()){
                    for(Defined_values_for_RDA_type__mdt rda : rdaMetas.get(rdaType)){
                        Opportunity linkedOpp = null;
                        boolean hasCorrectPurchaseTypeValue = false;
                        
                        if(rda.Type_of_RDA__c =='Trade_In' && (ass.Traded_In__c == null || (ass.Traded_In__c != null && ass.Traded_In__c == false)) ){
                            continue;
                        }
                        if(String.IsBlank(rda.Purchase_Type__c)){
                            hasCorrectPurchaseTypeValue = true;
                        }
                        else if(ass.Opportunity_Product__r != null && ass.Opportunity_Product__r.size() != 0){  
                            for(OpportunityLineItem oli : ass.Opportunity_Product__r){
                                if(oli.Opportunity.Purchase_Type__c == rda.Purchase_Type__c){
                                    hasCorrectPurchaseTypeValue = true;
                                    linkedOpp = oli.Opportunity;
                                    break;
                                }
                            }
                        }
                        if(!hasCorrectPurchaseTypeValue){
                            continue;
                        }
                        boolean hasCorrectSaleTypeCode = (rda.Sale_Type_Code__c == null|| (rda.Sale_Type_Code__c != null && rda.Sale_Type_Code__c == ass.Sale_Type_Code__c));
                        if(!hasCorrectSaleTypeCode){
                            continue;
                        }
                        boolean hasCorrectCommonSaleType = (rda.Common_Sale_Type__c == null ||(rda.Common_Sale_Type__c != null && rda.Common_Sale_Type__c == ass.Common_Sale_Type__c));
                        if(!hasCorrectCommonSaleType){
                            continue;
                        }						
                        boolean hasCorrectVistaStatus = (rda.Common_Status_Point__c == null ||(rda.Common_Status_Point__c != null && rda.Common_Status_Point__c == ass.Vista_Status__c));
                        if(!hasCorrectVistaStatus){
                            continue;
                        }
                        if(rda.RDA_Exists__c == null || ( rda.RDA_Exists__c == 'No' && ass.RDAs__r.size() == 0   && !assetswithRDA.contains(ass.id)  )){
                            RDADetail rdad = new RDADetail(ass, rda.Type_of_RDA__c);
							rdad.rdaAccountMismatched = false;									 
                            if(linkedOpp != null){
                                rdad.opp = linkedOpp;
								rdad.oppOwnerName = linkedOpp.Owner.Name;
                                rdad.accId = linkedOpp.AccountId;
								if(rda.Type_of_RDA__c != 'Trade_In' && validOppMap.containsKey(ass.Common_Sale_Type__c) && validOppMap.get(ass.Common_Sale_Type__c) != linkedOpp.Account.IsPersonAccount ){
									rdad.rdaAccountMismatched = true;
								}										 
                            }else{
                                if(rda.Type_of_RDA__c == 'Dealer_Owned' && (loggedInUser.contact != null || (ass.Account.Owner.Contact != null && ass.Account.Owner.Contact.AccountId != null) ) ){
                                    if(loggedInUser.contact != null){
                                        rdad.accId = loggedInUser.contact.Accountid;
                                    }else{
                                        rdad.accId = ass.Account.Owner.Contact.AccountId; 
                                    }
                                }else{
                                    rdad.accId = ass.AccountId;  
                                }
                            }
                            rdad.rdaAllowNew = !locked;
                            assetList.add(rdad);
                        }
                        else if(rda.RDA_Exists__c == 'Yes' && (ass.RDAs__r.size() != 0 || assetswithRDA.contains(ass.id))){
                            RDADetail rdad = new RDADetail(ass, rda.Type_of_RDA__c);
                            Boolean anExistingBannedTypeOfRDA = false;
                            if(rda.Type_of_RDA__c == 'On_Sell'){
                                for(RDA__C rdaunit : allRdas){
                                    if(!anExistingBannedTypeOfRDA && rdaunit.Asset__c == ass.Id && (rdaunit.RecordTypeId == onSellRDARecordtype ||   rdaunit.RecordTypeId == newRetailerRDARecordtype || rdaunit.RecordTypeId == tradeInRDARecordtype  )){
                                        anExistingBannedTypeOfRDA = true;
                                    }
                                }
                            }
                            if(!anExistingBannedTypeOfRDA){
                                if(ass.Opportunity_Product__r.size() > 0){
                                    Opportunity opp = ass.Opportunity_Product__r[0].Opportunity;
                                    rdad.opp = opp;                                    
                                    rdad.oppOwnerName = ass.Opportunity_Product__r[0].Opportunity.Owner.Name;
                                    rdad.accId =  ass.Opportunity_Product__r[0].Opportunity.AccountId;
									if(rda.Type_of_RDA__c != 'Trade_In' && validOppMap.containsKey(ass.Common_Sale_Type__c) && validOppMap.get(ass.Common_Sale_Type__c) != opp.Account.IsPersonAccount ){
										rdad.rdaAccountMismatched = true;
									}
                                }else{
                                    if(rda.Type_of_RDA__c == 'Dealer_Owned' && (loggedInUser.contact != null || (ass.Account.Owner.Contact != null && ass.Account.Owner.Contact.AccountId != null) ) ){
                                        if(loggedInUser.contact != null){
                                            rdad.accId = loggedInUser.contact.Accountid;
                                        }else{
                                            rdad.accId = ass.Account.Owner.Contact.AccountId; 
                                        }
                                    }else{
                                        rdad.accId = ass.AccountId;  
                                    }
                                }
                                rdad.rdaAllowNew = !locked;                          
                                assetList.add(rdad);
                            }
                        }
                    }
                }
            }
        }
        List<RDADetail> returnDem = new List<RDADetail>();
        Set<string> assetIdRDAType = new  Set<string>();
		if(assetList != null){
			for(RDADetail rdadet : assetList){
				String kee = rdadet.rdaAsset.Id + rdadet.rdaType;
				if(assetIdRDAType == null || !assetIdRDAType.contains(kee) ){
					assetIdRDAType.add(kee);
					returnDem.add(rdadet);
				}
			}
		}
        return returnDem;
    }
    
    @AuraEnabled
    public static RDA__c createRDA(String assetOppTypeKey) {
        Id assetId;
        Id oppId;
        Id accId;
        String rdaType;
        if(assetOppTypeKey != null){
            for(String stringId : assetOppTypeKey.split('-')){
                if(stringId.startsWith('006')) oppId = stringId;
                else if(stringId.startsWith('001')) accId = stringId;
                else if(stringId.startsWith('02i')) assetId = stringId;
                else rdaType = stringId;
            }
        }
        if(assetId != null){
            RDA__c rda = new RDA__c(Asset__c = assetId);
            Asset ass = [SELECT VIN__c, Product2.Model_Alternative__c, Common_Sale_Type__c FROM Asset WHERE Id = :assetId];
            rda.Common_Type_of_Sale_Code__c = getCommonTypeOfSale(ass.Common_Sale_Type__c);
            rda.Asset_VIN__c = ass.VIN__c;
            rda.Asset_Model__c = ass.Product2.Model_Alternative__c;
            rda.Buyer_Type__c = getBuyerType(ass.Common_Sale_Type__c);
            rda.Is_Fleet_Management_Organisation__c = getDefaultFMO(ass.Common_Sale_Type__c);
            system.debug('££££ FMO field updated ' + rda.Is_Fleet_Management_Organisation__c);
            if(rdaType != null && Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().containsKey(rdaType)){
                rda.RecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get(rdaType).getRecordTypeId();
                if( rda.RecordTypeId == onSellRDARecordtype){
                   rda.Is_APO__c = true; 
                }
            }            
            //default Handover Date (on rda) to today
            if(rda.Handover_Date__c == null){
                rda.Handover_Date__c = Date.today();
            }
            //need to enter Account and Opportunity for certain Record Types
            if(oppId != null){
                rda.Opportunity__c = oppId;
            }
            if(accId != null){
                rda.Account__c = accId;
            }
            return rda;
        }
        return null;
    }
    
    @AuraEnabled
    public static String tradeInAsset(String assetVin) {
        List<Asset> assetsToTradeIn = [SELECT Id, VIN__c, Traded_In__c FROM Asset WHERE VIN__c = :assetVin];
        if(assetsToTradeIn.size() != 1){
            return System.Label.RDA_Trade_In_Error;
        }
        if(assetsToTradeIn[0].Traded_In__c){
            return 'VIN is already marked as traded in';
        }
        assetsToTradeIn[0].Traded_In__c = true;
        try{
            update assetsToTradeIn;
        }
        catch(Exception e){
            return e.getMessage();
        }
        return 'Success';
    }
    
    public static String getCommonTypeOfSale(String commonSalePoint) {
        if(commonSalePoint != null){
            for(Common_Type_Of_Sale_Code__mdt cts : [SELECT Common_Sale_Type_Code__c FROM Common_Type_Of_Sale_Code__mdt WHERE MasterLabel = :commonSalePoint]){
                return cts.Common_Sale_Type_Code__c;
            }
        }
        return null;
    }
    
    public static String getBuyerType(String commonSalePoint) {
        if(commonSalePoint != null){
            for(Common_Type_Of_Sale_Code__mdt cts : [SELECT Buyer_Type_Code__r.Buyer_Type_Description__c FROM Common_Type_Of_Sale_Code__mdt WHERE MasterLabel = :commonSalePoint AND Buyer_Type_Code__c != null]){
                return cts.Buyer_Type_Code__r.Buyer_Type_Description__c;
            }
        }
        return null;
    }

	public static Boolean getDefaultFMO(String commonSalePoint) {
        if(commonSalePoint != null){
            for(Common_Type_Of_Sale_Code__mdt cts : [SELECT Default_FMO__c FROM Common_Type_Of_Sale_Code__mdt WHERE MasterLabel = :commonSalePoint AND Buyer_Type_Code__c != null]){
                return cts.Default_FMO__c;
            }
        }
        return null;
    }    
    
    @AuraEnabled
    public static Map<String,String> getAvailableQuota(String assetOppTypeKey) {
        Map<String,String> returnMap = new Map<String,String>();
        Integer maxLimit = 0;
        Integer reachedLimit = 0;        
        Integer demoQuotaLimit = 0;        
        Integer loanQuotaLimit = 0;
        Id assetId,oppId,accId;
        String rdaType,vehicleType,typeOfSale;
        if(assetOppTypeKey != null){
            for(String stringId : assetOppTypeKey.split('-')){
                if(stringId.startsWith('006'))  oppId =stringId;
                else if(stringId.startsWith('001'))  accId =stringId;
                else if(stringId.startsWith('02i'))  assetId =stringId;
                else  rdaType =stringId;
            }
        }
        try{
            SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());
            Asset rdaAsset= [SELECT Id,Common_Sale_Type__c,Brand__c, Derivative__r.Model_Alternative__c,New_or_Used__c FROM Asset WHERE Id = :assetId];
            vehicleType = rdaAsset.New_or_Used__c;
            typeOfSale = getVehicleTypeSetter(rdaAsset.Common_Sale_Type__c);
            for(Target_Quota__c quota : [SELECT Id, Maximum_Stock__c, Total_Actual__c, Total_In_Stock__c,Year__c, Model__r.Name, Quarter_2_Dealer_Loan_Remaining__c,Quarter_2_Demonstrator_Remaining__c,
                                        RecordtypeId,Quarter_1_Dealer_Loan_Remaining__c,Quarter_3_Dealer_Loan_Remaining__c,Quarter_4_Dealer_Loan_Remaining__c,
                                        Quarter_1_Demonstrator_Remaining__c, Quarter_3_Demonstrator_Remaining__c, Quarter_4_Demonstrator_Remaining__c
                                        FROM Target_Quota__c WHERE Retailer__c =:loggedInUser.Contact.AccountId 
										AND ((RecordtypeId = :maximumStockRecordTypeId) OR (RecordtypeId =: DemoOrLoanRecordTypeId AND Year__c = :''+financialDetails.financailYear ))
                                        AND (Make__c = :rdaAsset.Brand__c OR Model__r.Make__c = :rdaAsset.Brand__c) ]){    
				system.debug('qota '+json.serializePretty(quota));
				if(quota.RecordtypeId == maximumStockRecordTypeId && quota.Model__c == null){
					maxLimit = (Integer)quota.Maximum_Stock__c;
					reachedLimit = (Integer)quota.Total_Actual__c;                                             
				}else if(quota.RecordtypeId == DemoOrLoanRecordTypeId){
					if(quota.Year__c.equalsIgnoreCase(''+financialDetails.financailYear) && quota.Model__r.Name.equalsIgnoreCase(rdaAsset.Derivative__r.Model_Alternative__c) ){
						demoQuotaLimit = Integer.valueOf(quota.get('Quarter_'+financialDetails.Quarter+'_Demonstrator_Remaining__c'));
						loanQuotaLimit = Integer.valueOf(quota.get('Quarter_'+financialDetails.Quarter+'_Dealer_Loan_Remaining__c'));
					}
				}
			}
        }catch(exception exp){
            
        }
        returnMap.put('loanQuotaLimit',''+loanQuotaLimit);
        returnMap.put('demoQuotaLimit',''+demoQuotaLimit);
        returnMap.put('reachedLimit',''+reachedLimit);
        returnMap.put('maxLimit',''+maxLimit);
        returnMap.put('vehicleType',''+vehicleType);
        returnMap.put('rdaType',''+rdaType);
        returnMap.put('typeOfSale',''+typeOfSale);
        return returnMap;
    }
    
    public static String getVehicleTypeSetter(String commonSaletype) {
        String vehicleType = '';
        if(commonSaletype != null){
            for(Vehicle_Type_Setter__mdt vts : [SELECT MasterLabel,Common_Sale_Type_Code_List__c FROM Vehicle_Type_Setter__mdt]){
                if(vts.Common_Sale_Type_Code_List__c.split(';').contains(commonSaletype)){
                    vehicleType = vts.MasterLabel;
                } 
            }
        }
        return vehicleType;
    }
    
    public class RDADetail {
        @AuraEnabled public Asset rdaAsset;
        @AuraEnabled public String rdaType;
        @AuraEnabled public boolean rdaChecked;
		@AuraEnabled public boolean rdaAccountMismatched;												  
        @AuraEnabled public boolean rdaAllowNew;
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public string oppOwnerName;
        @AuraEnabled public Id accId;
        @AuraEnabled public String purchaseType;
        public RDADetail(Asset passedAsset, String passedType) {
            rdaAsset = passedAsset;
            rdaType = passedType;
            rdaChecked = false;
        }
    }
}
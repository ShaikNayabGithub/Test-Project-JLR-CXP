/*
Author : Deepti Tanguturi
Purpose : Getting schemes and VME data based on opportunity record
Created Date : 15-04-2019
Modified By : Sumit Kumar @Marlabs.com
Modified Reason : Sale LInk Generation now includes channel matrix 
Modified Date : 19th Aug 2019
*/
public class VME_Sales_Link {
        @AuraEnabled
        public static user fetchUser() {
                User loggedUser = VME_Utility_Class.fetchUser();
                loggedUser.DefaultCurrencyIsoCode = UserInfo.getDefaultCurrency();
                return loggedUser;
        }
        //Methods to get all related Scheme for attached Asset
        @AuraEnabled
        public static VME_Scheme_Wrpaper_CheckAll getSchemes(String opportunityId) {

                //Store list of Opportunity product for current opportunity]
                List < OpportunityLineItem > opportunityLineItemList = new List < OpportunityLineItem > ();
                //Master Wrapper to store data for model
                VME_Scheme_Wrpaper_CheckAll masterWrapper = new VME_Scheme_Wrpaper_CheckAll();
                //generate claims parameter
                List<Asset> newAssetList = new List<Asset>();
                Map<Id,Asset> newAssetMap = new Map<Id,Asset>();
                List<Asset> oldAssetList = new List<Asset>();
                Map<Id,Asset> oldAssetMap = new Map<Id,Asset>();
                //calling generate claims for scheme
                VME_Generate_Claims_Trigger_Service generateClaimServiceInstance = new VME_Generate_Claims_Trigger_Service();
                //Instatiating Trigger Handler Service class Wrapper
                VME_Generate_Claims_Trigger_Service.VME_GenerateClaim_Wrapper masterWrapperScheme = new VME_Generate_Claims_Trigger_Service.VME_GenerateClaim_Wrapper();
                //set of already selected id from sales link
                Set<Id> alreadySelectedScheme = new Set<Id>();
                //List of Available scheme for Asset 
                List < VME_Campaign_Scheme_Wrapper > schemeWrapList = new List < VME_Campaign_Scheme_Wrapper > ();
                try {
                        // Query opportunty details where user looking for saleslink
                        Opportunity recordOpportunity = [SELECT Id, Name, VME_Selected_Schemes__c, VME_Selected_Scheme_Id__c, AccountId, IsClosed, StageName FROM Opportunity WHERE Id=:opportunityId];
                        Boolean oppValueCheck = false;
                        System.debug(recordOpportunity);
                        if(recordOpportunity != null){
                                if(recordOpportunity.VME_Selected_Scheme_Id__c != null && recordOpportunity.VME_Selected_Scheme_Id__c != '' && recordOpportunity.VME_Selected_Schemes__c != null && recordOpportunity.VME_Selected_Schemes__c != ''){
                                        List<Id> tempIds = recordOpportunity.VME_Selected_Scheme_Id__c.split(',');
                                        alreadySelectedScheme = new Set<Id>(tempIds);
                                        oppValueCheck = true;
                                }
                                opportunityLineItemList = [SELECT Id, Product2Id, Product2.Model__c, ProductCode, OpportunityId, Brand__r.Name, Model__r.Name, Asset__c from OpportunityLineItem where OpportunityId = : opportunityId];
                                System.debug(opportunityLineItemList);
                                if(opportunityLineItemList != null && opportunityLineItemList.size() >0 && opportunityLineItemList.size() ==1 && opportunityLineItemList[0].Asset__c != null){
                                        System.debug(opportunityLineItemList[0].Asset__c);
                                        if(opportunityLineItemList[0].Asset__c != null){
                                                Asset linkedAsset = [SELECT Id, Name, Manufacture_Year__c, VME_Retail_Date__c, Sale_Type_Code__c, VME_TypeOfSale_Code_L2__c, Derivative__c, Model__c, Retailer_Name__c, AccountId, Derivative__r.VME_GST__c, VIN__c, VME_Market_Arrival_Date__c, (SELECT Id FROM VME_Claims__r) FROM Asset WHERE Id =:  opportunityLineItemList[0].Asset__c ];
                                                if (linkedAsset.Sale_Type_Code__c != null && linkedAsset.Sale_Type_Code__c != '' && linkedAsset.VME_TypeOfSale_Code_L2__c != null && linkedAsset.VME_TypeOfSale_Code_L2__c != ''){
                                                        //create new map , old map, new list and old list
                                                        Asset newAssetold = linkedAsset.clone(true,true,true,false);
                                                        newAssetold.VME_Retail_Date__c = null;
                                                        oldAssetList.add(newAssetold);
                                                        oldAssetMap.put(newAssetold.Id, newAssetold);
                                                        Asset newAsset = linkedAsset.clone(true,true,true,false);
                                                        if(linkedAsset.VME_Retail_Date__c != null){
                                                                newAsset.VME_Retail_Date__c = linkedAsset.VME_Retail_Date__c;
                                                        }else{
                                                                newAsset.VME_Retail_Date__c = System.today();
                                                        }                                                
                                                        newAssetList.add(newAsset);
                                                        newAssetMap.put(newAsset.Id, newAsset);
                                                        //Passing parameter and getting all claim list and others map[] to be inserted
                                                        try {
                                                                masterWrapperScheme = generateClaimServiceInstance.getMyClaimsGenerated(newAssetMap, oldAssetMap, newAssetList, oldAssetList, linkedAsset.VME_Retail_Date__c, false);
                                                        } catch (Exception e) {
                                                                System.debug('Sales Link Exception');
                                                                masterWrapper.statusOfTransaction = 'ERROR';
                                                                masterWrapper.iconOfTransaction = 'first_non_empty';
                                                                masterWrapper.showSaveButtons = false;
                                                                masterWrapper.MsgOfTransactionforUser = 'Looks like something not correct in server. Please contact your Administrator.';
                                                        }
                                                        /* if(masterWrapperScheme.statusOfTransaction == 'MATCH ERROR'){
                                                                masterWrapper.statusOfTransaction = 'WARNING';
                                                                masterWrapper.iconOfTransaction = 'first_non_empty';
                                                                masterWrapper.saveBtnStatus = true;
                                                                masterWrapper.disableBtnStatus = true;
                                                                masterWrapper.showSaveButtons = false;
                                                                masterWrapper.showDetailBaar = false;
                                                                masterWrapper.MsgOfTransactionforUser = masterWrapperScheme.errorMsgOfTransaction;
                                                        }else{ */
                                                                if(masterWrapperScheme.VIN_RelatedScheme_Final_Wrap != null && masterWrapperScheme.VIN_RelatedScheme_Final_Wrap.keySet().size()>0){
                                                                        for (VME_Schemes__c vmeSchemeObj : masterWrapperScheme.VIN_RelatedScheme_Final_Wrap.get(linkedAsset.Id)) {
                                                                                System.debug('vmeSchemeObj :::: '+ vmeSchemeObj);
                                                                                VME_Campaign_Scheme_Wrapper wrapperObj = new VME_Campaign_Scheme_Wrapper();
                                                                                wrapperObj.endDate = vmeSchemeObj.VME_End_Date__c;
                                                                                wrapperObj.perUnitVariant = vmeSchemeObj.VME_PU_Amount__c + vmeSchemeObj.VME_Retailer_Contribution__c; //PU amout + Reatiler contribution
                                                                                wrapperObj.perUnitVariantPostGST = vmeSchemeObj.VME_PU_Amount__c + vmeSchemeObj.VME_Retailer_Contribution__c; //PU amout + Reatiler contribution
                                                                                if(linkedAsset.Derivative__r.VME_GST__c != null && linkedAsset.Derivative__r.VME_GST__c > 0){
                                                                                        wrapperObj.perUnitVariantPostGST =    wrapperObj.perUnitVariant + (wrapperObj.perUnitVariant*(linkedAsset.Derivative__r.VME_GST__c/100));
                                                                                        //below logicfor rounds up to nearest 10s for P/U amount
                                                                                        Integer puAMount = Integer.valueOf(wrapperObj.perUnitVariantPostGST);
                                                                                        Integer reminder = (puAMount / 10) * 10; 
                                                                                        // Larger multiple 
                                                                                        Integer largerpuAmount = reminder + 10; 
                                                                                        // Return of closest of two 
                                                                                        Integer roundsUpPuAmount = (puAMount - reminder >= largerpuAmount - puAMount) ? largerpuAmount : reminder;
                                                                                        //putting PU amount after rounds up
                                                                                        wrapperObj.perUnitVariantPostGST = roundsUpPuAmount;
                                                                                }
                                                                                wrapperObj.category = vmeSchemeObj.VME_Campaign__r.VME_Category__c;
                                                                                wrapperObj.subCategory = vmeSchemeObj.VME_Campaign__r.VME_Sub_Category__c;
                                                                                wrapperObj.schemeId = vmeSchemeObj.Id;
                                                                                wrapperObj.schemeName = vmeSchemeObj.Name;
                                                                                wrapperObj.l3Description = vmeSchemeObj.VME_Level_3_Description__c;

                                                                                //Putting checkbox as true if any available scheme is already selected
                                                                                if (alreadySelectedScheme != null && alreadySelectedScheme.contains(vmeSchemeObj.Id)) {
                                                                                        wrapperObj.isChecked = true;
                                                                                }else {
                                                                                        wrapperObj.isChecked = false;
                                                                                }
                                                                                //adding scheme wrapper into list.
                                                                                schemeWrapList.add(wrapperObj);
                                                                                //Master check box checked if Selected scheme from Opp and Available schemenis same.
                                                                                if (alreadySelectedScheme.size() == masterWrapperScheme.VIN_RelatedScheme_Final_Wrap.get(linkedAsset.Id).size()) {
                                                                                        masterWrapper.checkAll = true;
                                                                                } else {
                                                                                        masterWrapper.checkAll = false;
                                                                                }
                                                                        }
                                                                }
                                                                if(linkedAsset.VME_Retail_Date__c != null && linkedAsset.VME_Retail_Date__c <= System.today() && linkedAsset.VME_Claims__r.isEmpty() && linkedAsset.VME_Claims__r.size()==0 && schemeWrapList != null && schemeWrapList.size() > 0){//retail date can't be greater than today
                                                                        masterWrapper.statusOfTransaction = 'DISABLE';
                                                                        masterWrapper.iconOfTransaction = 'related_list';
                                                                        masterWrapper.MsgOfTransactionforUser = 'Looks like attached VIN has a retail date populated. Please select another VIN or change channel type and refresh.';
                                                                        masterWrapper.saveBtnStatus = true;
                                                                        masterWrapper.disableBtnStatus = true;
                                                                        masterWrapper.showSaveButtons = false;
                                                                        masterWrapper.showDetailBaar = true;
                                                                        masterWrapper.listofWrapperSchemes = schemeWrapList;
                                                                }else{
                                                                        if(linkedAsset.VME_Claims__r != null && linkedAsset.VME_Claims__r.size()>0){
                                                                                masterWrapper.statusOfTransaction = 'DISABLE';
                                                                                masterWrapper.iconOfTransaction = 'date_time';
                                                                                masterWrapper.MsgOfTransactionforUser = 'Looks like the claims have been generated for attached VIN. Sales-Link has been disabled.';
                                                                                masterWrapper.saveBtnStatus = true;
                                                                                masterWrapper.disableBtnStatus = true;
                                                                                masterWrapper.showSaveButtons = false;
                                                                                masterWrapper.showDetailBaar = true;
                                                                                masterWrapper.listofWrapperSchemes = schemeWrapList;
                                                                        }else{
                                                                                if(schemeWrapList != null && schemeWrapList.size()>0){
                                                                                        masterWrapper.statusOfTransaction = 'SUCCESS';
                                                                                        masterWrapper.showSaveButtons = true;
                                                                                        masterWrapper.showDetailBaar = true;
                                                                                        masterWrapper.MsgOfTransactionforUser = 'Congratualtions!! L3 VME Campaigns are available for selection.';
                                                                                        masterWrapper.listofWrapperSchemes = schemeWrapList;        
                                                                                }else {
                                                                                        masterWrapper.statusOfTransaction = 'WARNING';
                                                                                        masterWrapper.iconOfTransaction = 'search';
                                                                                        masterWrapper.showSaveButtons = false;
                                                                                        masterWrapper.showDetailBaar = false;
                                                                                        masterWrapper.MsgOfTransactionforUser = 'Looks like attached VIN/Model/Derivative does not have any active running scheme TODAY. Please select another VIN and refresh.';
                                                                                }  
                                                                        }
                                                                }
                                                        //}
                                                }else{
                                                        masterWrapper.statusOfTransaction = 'WARNING';
                                                        masterWrapper.iconOfTransaction = 'product_required';
                                                        masterWrapper.showSaveButtons = false;
                                                        masterWrapper.showDetailBaar = false;
                                                        masterWrapper.MsgOfTransactionforUser = 'Looks like VIN does not have Sale Type Code / Type of Sale Code L2. Please select an different VIN and refresh.';
                                                }
                                        }else {
                                                if(oppValueCheck){
                                                        List < VME_Campaign_Scheme_Wrapper > schmWrapperList = updateSelectedChemesLogic(null, recordOpportunity.Id, true);
                                                }
                                                masterWrapper.statusOfTransaction = 'WARNING';
                                                masterWrapper.iconOfTransaction = 'work_order';
                                                masterWrapper.showSaveButtons = false;
                                                masterWrapper.showDetailBaar = false;
                                                masterWrapper.MsgOfTransactionforUser = 'Looks like you have not attached VIN to opportunity product. Please attach a VIN to products to proceed.';
                                        }
                                }else if(opportunityLineItemList != null && opportunityLineItemList.size() >0 && opportunityLineItemList.size() >1){
                                        if(oppValueCheck){
                                                List < VME_Campaign_Scheme_Wrapper > schmWrapperList = updateSelectedChemesLogic(null, recordOpportunity.Id, true);
                                        }
                                        masterWrapper.statusOfTransaction = 'WARNING';
                                        masterWrapper.iconOfTransaction = 'product_item_transaction';
                                        masterWrapper.showSaveButtons = false;
                                        masterWrapper.showDetailBaar = false;
                                        masterWrapper.MsgOfTransactionforUser = 'Looks like you have attached more than 1 product to opportunity. Please limit products to 1 and refresh.';
                                }else{
                                        if(oppValueCheck){
                                                List < VME_Campaign_Scheme_Wrapper > schmWrapperList = updateSelectedChemesLogic(null, recordOpportunity.Id, true);
                                        }
                                        masterWrapper.statusOfTransaction = 'WARNING';
                                        masterWrapper.iconOfTransaction = 'product_request';
                                        masterWrapper.showSaveButtons = false;
                                        masterWrapper.showDetailBaar = false;
                                        masterWrapper.MsgOfTransactionforUser = 'Looks like you have not attached product to opportunity. Please add product to proceed.';
                                }
                        }
                } catch (Exception e) {
                    	System.debug('EXCEPTION #' + e.getLineNumber() + ' &Message>> '+ e.getMessage() + ' @WHERE>> ' +e.getStackTraceString() + ' %WHY >>' +e.getTypeName());
                        masterWrapper.statusOfTransaction = 'WARNING';
                        masterWrapper.iconOfTransaction = 'product_request';
                        masterWrapper.showSaveButtons = false;
                        masterWrapper.showDetailBaar = false;
                        masterWrapper.MsgOfTransactionforUser = 'Oops !! We\'ve hit a snag. Please let your administrator knows about this and check after a while.';//+e.getMessage();
                }
                System.debug('masterWrapper :::'+ masterWrapper);
                return masterWrapper;
        }
        @AuraEnabled
        public static List < VME_Campaign_Scheme_Wrapper > updateSelectedChemes(string listOfSchemes, String recordId, Boolean flag) {
                List < VME_Campaign_Scheme_Wrapper > schmWrapperList = updateSelectedChemesLogic(listOfSchemes, recordId, flag);
                return schmWrapperList;
        }

        public static List < VME_Campaign_Scheme_Wrapper > updateSelectedChemesLogic(string listOfSchemes, String recordId, Boolean flag) {
                List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper > schemeList = new List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper >();
                System.debug('listOfSchemes ::'+ listOfSchemes);
                if(listOfSchemes != null){
                        schemeList = (List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper > ) System.JSON.deserialize(listOfSchemes, List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper > .class);
                }
                String selectedSchemesDetails = '';
                String selectedSchemesDetailsIds = '';
                List < VME_Campaign_Scheme_Wrapper > schmWrapperList = new List < VME_Campaign_Scheme_Wrapper > ();
                Opportunity updateOpportunities = [Select Name, Id, VME_Selected_Schemes__c from Opportunity where Id = : recordId];
                try {
                        if(schemeList != null && schemeList.size()>0){
                                for (VME_Campaign_Scheme_Wrapper wrapperObj: schemeList) {
                                                selectedSchemesDetails += wrapperObj.category + ',' + wrapperObj.subCategory + ',' + wrapperObj.perUnitVariantPostGST + '\n';
                                                selectedSchemesDetailsIds += wrapperObj.schemeId + ',';
                                                schmWrapperList.add(wrapperObj);
                                }
                                updateOpportunities.VME_Selected_Schemes__c = selectedSchemesDetails;
                                updateOpportunities.VME_Selected_Scheme_Id__c = selectedSchemesDetailsIds;
                        }else{
                                updateOpportunities.VME_Selected_Schemes__c = '';
                                updateOpportunities.VME_Selected_Scheme_Id__c = '';
                        }
                        if (flag){ 
                                Update updateOpportunities;
                        }
                } catch (Exception e) {
                        System.debug('Sales Link Handler : Wohhooo !! You got a Exception in Line number ' + e.getLineNumber() + ' and surprisingly your error is ' + e.getMessage() + e.getCause());
                }
                return schmWrapperList;
        }
        
        public class VME_Campaign_Scheme_Wrapper {
                @AuraEnabled public String category;
                @AuraEnabled public String subCategory;
                @AuraEnabled public Date endDate;
                @AuraEnabled public Decimal perUnitVariant;
                @AuraEnabled public Decimal perUnitVariantPostGST;
                @AuraEnabled public Boolean isChecked;
                @AuraEnabled public String schemeId;
                @AuraEnabled public String l3Description;
                @AuraEnabled public String schemeName;
        }
        public class VME_Scheme_Wrpaper_CheckAll {
                @AuraEnabled public String statusOfTransaction;
                @AuraEnabled public String iconOfTransaction;
                @AuraEnabled public String MsgOfTransactionforUser;
                @AuraEnabled public String errorMsgOfTransaction;
                @AuraEnabled public Boolean checkAll;
                @AuraEnabled public Boolean saveBtnStatus;
                @AuraEnabled public Boolean showSaveButtons;
                @AuraEnabled public Boolean showDetailBaar;
                @AuraEnabled public Boolean disableBtnStatus;
                @AuraEnabled public List < VME_Campaign_Scheme_Wrapper > listofWrapperSchemes;
        }
}
/*--
||      Name : VME_Generate_Claims_Trigger_Service.apxc
||      Created By: Sumit Kumar @Marlabs Private Limited
||      Purpose : This will have the Generic Logic Channel Martrix Calculation and Sales Link , on top Claim generation
||      Created Date : 19/08/2019
||      Modified By:Tamanna Shukla
||      Modified Date :11/08/2020
||      Reason :In existing process, while re-generating the claims for VINs, approved claims were getting deleted thus
                           resulting in problem in accounting. Objective is to restore approved claims along with re-generating
                            claims for modified / added schemes. 
--*/
public class VME_Generate_Claims_Trigger_Service {
        //Below is my custom exception class for CHannel Matrix error
        public class channelMatrixException extends Exception {}
        public static final Id PARENT_SCHEME_RECORD_TYPE = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Parent');
        public static final Id CHILD_SCHEME_RECORD_TYPE = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Child');
        /* 
        Below Logic in only for checking whether selected Sale Type Code and Branch Type Code is matching against channel matrix or not.
         */
        public void checkSaleTypeCodeMatch(Map < Id, Asset > newMap, Map < Id, Asset > oldMap, List < Asset > newList, List < Asset > oldList, Date retailDate, Boolean activeSchemes) {
                //Map of VME_Channel_Matrix_Dependency__c combination of Common sales Type and Sales Type with Channel Matric Type
                Map < String, Set < String >> VME_Channel_Matrix_Dependency_map = new Map < String, Set < String >> ();
                Map < Id, Id > relatedAssetOppMap = new Map < Id, Id > ();
                if (newMap != null && newMap.size() > 0)
                        for (VME_CXP_Channel_Matrix_Dependency__mdt vcmd: [Select id, Brand_Order_Type_Code__c, Details__c, Mapping__c, Type_of_Sale_Code_L2__c, Unique_ID__c from VME_CXP_Channel_Matrix_Dependency__mdt]) {
                                if (!VME_Channel_Matrix_Dependency_map.containsKey(vcmd.Unique_ID__c)) {
                                        VME_Channel_Matrix_Dependency_map.put(vcmd.Unique_ID__c, new Set < String > { //vcmd.Unique_ID__c
                                                vcmd.Mapping__c
                                        });
                                } else {
                                        Set < String > tempVcmd = VME_Channel_Matrix_Dependency_map.get(vcmd.Unique_ID__c); //vcmd.Unique_ID__c
                                        tempVcmd.add(vcmd.Mapping__c);
                                        VME_Channel_Matrix_Dependency_map.put(vcmd.Unique_ID__c, tempVcmd); //vcmd.Unique_ID__c
                                }
                        }
                //In this loop checking  if opportunity/opprtunity line item is present related to that Asset or not
                for (OpportunityLineItem lineItem: [SELECT Id, Asset__c, OpportunityId FROM OpportunityLineItem where Asset__c IN: newList]) {
                        relatedAssetOppMap.put(lineItem.Asset__c, lineItem.OpportunityId);
                }
                for (Asset assetObj: newList) {
                        if (assetObj.VME_Retail_Date__c == oldMap.get(assetObj.Id).VME_Retail_Date__c) {
                                if (assetObj.Sale_Type_Code__c != null && assetObj.Sale_Type_Code__c != '' && assetObj.VME_TypeOfSale_Code_L2__c != null && assetObj.VME_TypeOfSale_Code_L2__c != '') {
                                        String uniqueSalestype = assetObj.Sale_Type_Code__c + '_' + assetObj.VME_TypeOfSale_Code_L2__c;
                                        if (VME_Channel_Matrix_Dependency_map != null && !VME_Channel_Matrix_Dependency_map.containsKey(uniqueSalestype)) {
                                                assetObj.addError('The selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset\'s Sale Type Code (' + assetObj.Sale_Type_Code__c + ') , Please try again.');
                                        }
                                }
                        }
                        if (assetObj.VME_Retail_Date__c != null && oldMap.get(assetObj.Id).VME_Retail_Date__c == null) {
                                //This is added by Tamanna on 11/Aug/2020 for opportunity check
                                if (relatedAssetOppMap.isEmpty() || (relatedAssetOppMap != null && relatedAssetOppMap.size() > 0 && !relatedAssetOppMap.containsKey(assetObj.Id))) {
                                        assetObj.addError('This VIN is not attached with any opportunity.');
                                }
                        }
                }
        }
        public VME_GenerateClaim_Wrapper getMyClaimsGenerated(Map < Id, Asset > newMap, Map < Id, Asset > oldMap, List < Asset > newList, List < Asset > oldList, Date retailDate, Boolean activeSchemes) {
                /*VME_GenerateClaim_Wrapper masterWrapper = new VME_GenerateClaim_Wrapper();
                try {
                        masterWrapper = generationClaims(newMap, oldMap, newList, oldList, retailDate, activeSchemes);
                } catch (Exception e) {
                        System.debug('Calling GCMS error');
                        masterWrapper.statusOfTransaction = 'generationClaims ERROR';
                        masterWrapper.errorMsgOfTransaction = 'generationClaims Error on ' + e.getMessage();
                }*/
                return generationClaims(newMap, oldMap, newList, oldList, retailDate, activeSchemes);
        }
        @TestVisible
        private VME_GenerateClaim_Wrapper generationClaims(Map < Id, Asset > newAssetMap, Map < Id, Asset > oldAssetMap, List < Asset > newAssetList, List < Asset > oldAssetList, Date retailDate, Boolean activeSchemes) {
                //Master Wrapper Initialization
                VME_GenerateClaim_Wrapper masterWrapper = new VME_GenerateClaim_Wrapper();
                masterWrapper.statusOfTransaction = 'START';
                masterWrapper.errorMsgOfTransaction = 'No Error';
                /*Variable Declaration*/
                //Map of Asset Id and Product
                Map < Id, Set < Id >> Product_On_Asset_Map = new Map < Id, Set < Id >> ();
                //Map of all Scheme with Bundling 
                Map < Id, Id > Bundling_Scheme_Map = new Map < Id, Id > ();
                //map of Retail Scheme values to Scheme Id
                Map < String, Id > RetailBased_Scheme_Map = new Map < String, Id > ();
                //map of Retail Scheme values to Scheme Id
                Map < Id, Set < Id >> Scheme_HasRetailer_Map = new Map < Id, Set < Id >> ();
                //Set of all Scheme derived from Product/Model
                Set < Id > findSchemesFromProductSet = new Set < Id > ();
                //Map of Product  Id and Set of Scheme Id
                Map < Id, Set < Id >> product_RelatedScheme_Map = new Map < Id, Set < Id >> ();
                //Map of Product  Id and Set of Scheme Id
                Map < Id, Set < Id >> asset_RelatedScheme_Map = new Map < Id, Set < Id >> ();
                //Related Account Rtailer Set
                Set < Id > asset_Retailer_Set = new Set < Id > ();
                //Map of Asset Id against Opportunity Customer Details
                Map < Id, OpportunityLineItem > Asset_OpportunityCustomer_Map = new Map < Id, OpportunityLineItem > ();
                //Map of Asset Id against Opportunity Customer Details
                Map < Id, Account > Asset_Retailer_Map = new Map < Id, Account > ();
                //Getting Map of Products based on Asset product Set
                Map < Id, Product2 > Products_Map = new Map < Id, Product2 > ();
                //Map of Product type based on Asset and Scheme as Key (Model / Derivative)
                Map < String, String > Scheme_ProductType_Map = new Map < String, String > ();
                //Getting mapping of category and sub category mapping from Custom Setting
                Map < String, String > getCatSubCatCodeMapping = VME_Utility_Class.getCatSubCatCodeMapping();
                //Map of VME_Channel_Matrix_Dependency__c combination of Common sales Type and Sales Type with Channel Matric Type
                Map < String, Set < String >> VME_Channel_Matrix_Dependency_map = new Map < String, Set < String >> ();
                //Master Map of Asset Id and Set of Scheme Id which is going to create Claims for it.
                Map < Id, List < VME_Schemes__c >> VIN_RelatedScheme_Final_Map = new Map < Id, List < VME_Schemes__c >> ();
                //Map of List of Model/Derivative against Master L3
                Map < Id, Set < String >> mapOfL3vsModelsDerivatives = new Map < Id, Set < String >> ();
				//Boolena to restrict after update asset where retail date has not be manipulated.
				Boolean restrictAfterUpdate = false;
                //Getting UserDetails
                //   User userDetails = new User();
                try {
                        //   userDetails = [SELECT id, Name, Market__c, Country, Email, FirstName, LastName, IsActive, CurrencyIsoCode, DefaultCurrencyIsoCode, Country_ISO_Code__c, Profile.UserLicense.Name FROM User WHERE id = : UserInfo.getUserId()];
                        //   masterWrapper.userDetails_Wrap = userDetails;
                        //Iterating over trigger.new to get the asset id / product / model where Invoice Date has been manipulated
                        for (Asset assetObj: newAssetList) {
                                if (oldAssetMap.get(assetObj.Id).VME_Retail_Date__c == null && assetObj.VME_Retail_Date__c != null && assetObj.VME_Retail_Date__c != oldAssetMap.get(assetObj.Id).VME_Retail_Date__c) {
                                        if (assetObj.Sale_Type_Code__c != null && assetObj.Sale_Type_Code__c != '' && assetObj.VME_TypeOfSale_Code_L2__c != null && assetObj.VME_TypeOfSale_Code_L2__c != '') {
                                                System.debug('Working Asset Name :: ' + assetObj.Name);
                                                //Putting the Derivative into Set for Chekcing Derivative Based Scheme
                                                if (assetObj.Derivative__c != null) {
                                                        //Product_On_Asset_Map.put(assetObj.Id, new Set<Id>{assetObj.Derivative__c});
                                                        findSchemesFromProductSet.add(assetObj.Derivative__c);
                                                        if (!Product_On_Asset_Map.containsKey(assetObj.Id)) {
                                                                Product_On_Asset_Map.put(assetObj.Id, new Set < Id > {
                                                                        assetObj.Derivative__c
                                                                });
                                                        }
                                                }
                                                //Putting the Model into Set for Chekcing Model Based Scheme
                                                if (assetObj.Model__c != null) {
                                                        //Product_On_Asset_Map.put(assetObj.Id, new Set<Id>{assetObj.Model__c});
                                                        findSchemesFromProductSet.add(assetObj.Model__c);
                                                        if (!Product_On_Asset_Map.containsKey(assetObj.Id)) {
                                                                Product_On_Asset_Map.put(assetObj.Id, new Set < Id > {
                                                                        assetObj.Model__c
                                                                });
                                                        } else {
                                                                Set < Id > tempSchemeSet = Product_On_Asset_Map.get(assetObj.Id);
                                                                tempSchemeSet.add(assetObj.Model__c);
                                                                Product_On_Asset_Map.put(assetObj.Id, tempSchemeSet);
                                                        }
                                                }
                                                //Putting all Retailer Details from VIN into Set for getting Reatiler Info
                                                asset_Retailer_Set.add(assetObj.Retailer_Name__c);
                                                //checking if Sales type or Common Sale Type is null or not and updating Error Field
                                        }
                                } else {
                                        System.debug('Opps !!! this Asset (' + assetObj.Id + ') VME_Retail_Date__c has not changed or changed from existing date. Please Check!!');
										restrictAfterUpdate = true;
                                }
                        }
                        //Store map of asset against selected scheme id selected against Sales LINK
                        Map < Id, Set < Id >> asset_Selected_Scheme_Set_Map = new Map < Id, Set < Id >> ();
                        System.debug('findSchemesFromProductSet :: ' + findSchemesFromProductSet);
                        //Below for loop collect all the Opportunity / Customer information who are having this VIN in their opportunity line item.
                        for (OpportunityLineItem oppLineitm: [SELECT Id, Opportunity.Name, Opportunity.AccountId, Opportunity.Handover_Date__c, Opportunity.VME_Selected_Schemes__c, Opportunity.VME_Selected_Scheme_Id__c, Opportunity.Account.Name, Asset__c, Opportunity.VME_Trade_in_Type__c, Opportunity.VME_Segment__c, Opportunity.VME_Sub_Division__c FROM OpportunityLineItem WHERE Asset__c IN: newAssetMap.keySet() ORDER BY Asset__c DESC]) {
                                if (!Asset_OpportunityCustomer_Map.containsKey(oppLineitm.Asset__c)) {
                                        Asset_OpportunityCustomer_Map.put(oppLineitm.Asset__c, oppLineitm);
                                }
                                if (oppLineitm.Opportunity.VME_Selected_Scheme_Id__c != null && oppLineitm.Opportunity.VME_Selected_Scheme_Id__c != '' && oppLineitm.Opportunity.VME_Selected_Schemes__c != null && oppLineitm.Opportunity.VME_Selected_Schemes__c != '') {
                                        if (!asset_Selected_Scheme_Set_Map.containsKey(oppLineitm.Asset__c)) {
                                                List < Id > tempIds = oppLineitm.Opportunity.VME_Selected_Scheme_Id__c.split(',');
                                                Set < Id > setString = new Set < Id > (tempIds);
                                                asset_Selected_Scheme_Set_Map.put(oppLineitm.Asset__c, setString);
                                        } else {
                                                List < Id > tempIds = oppLineitm.Opportunity.VME_Selected_Scheme_Id__c.split(',');
                                                Set < Id > setString = new Set < Id > (tempIds);
                                                Set < Id > tempSchemeSet = asset_Selected_Scheme_Set_Map.get(oppLineitm.Asset__c);
                                                tempSchemeSet.addAll(setString);
                                                asset_Selected_Scheme_Set_Map.put(oppLineitm.Asset__c, tempSchemeSet);
                                        }
                                }
                        }
                        masterWrapper.asset_Selected_Scheme_Wrap = asset_Selected_Scheme_Set_Map;
                        masterWrapper.Asset_OpportunityCustomer_Wrap = Asset_OpportunityCustomer_Map;
                        System.debug('Asset_OpportunityCustomer_Map :: ' + Asset_OpportunityCustomer_Map);
                        //Below for loop Collects the information of Retailer who are having above VIN in their store.
                        for (Account acc: [SELECT Id, Name, NameLocal, Retailer_Email__c, Country_ISO_Code__c, Select_Country_ISO_Code__c, Region_or_Market__c, Primary_Dealer_Code__c FROM Account WHERE Id IN: asset_Retailer_Set]) {
                                if (!Asset_Retailer_Map.containsKey(acc.Id)) {
                                        Asset_Retailer_Map.put(acc.Id, acc);
                                }
                        }
                        masterWrapper.Asset_Retailer_Wrap = Asset_Retailer_Map;
                        System.debug('Asset_Retailer_Map :: ' + Asset_Retailer_Map);
                        //Getting all the Derivative and Model Details by product id from Asset
                        if (findSchemesFromProductSet != null && findSchemesFromProductSet.size() > 0) {
                                Products_Map = getMyProducts(findSchemesFromProductSet);
                        }
                        System.debug(Products_Map.size() + ' Products_Map :: ' + Products_Map);
                        //Getting all the Scheme Bundling based on Asset Product or Asset it self only
                        //Creating  a map of Product and all the Applicable Scheme
                        //and map of direct VIN based Applicable Scheme
                        if (Products_Map != null && !Products_Map.isEmpty() && Products_Map.size() > 0) {
                                for (VME_Bundling__c vmeBund: getSchemeBudling(Products_Map.keySet(), newAssetMap.keySet(), retailDate, activeSchemes)) {
                                        //System.debug('vmeBund :: ' + vmeBund);
                                        //Map of Bundling Id with values Related Scheme Id
                                        Bundling_Scheme_Map.put(vmeBund.Id, vmeBund.VME_Scheme__c);
                                        if (vmeBund.VME_Model_Derivative__c != null) {
                                                //Map of Scheme and Product Combination with Values to it of what kinf of Product Model / Derivative
                                                //This map helps in chekcing putting derivative based scheme if there is a Model Based Scheme is present.
                                                //Product Scheme Mapping based on L3, if any product eligible for more than 1 Scheme 
                                                if (!mapOfL3vsModelsDerivatives.containsKey(vmeBund.VME_Scheme__c)) {
                                                        if (vmeBund.VME_Model_Derivative__c != null && vmeBund.VME_Model_Derivative__r.RecordType.Name == 'Model') {
                                                                mapOfL3vsModelsDerivatives.put(vmeBund.VME_Scheme__c, new Set < String > {
                                                                        'M'
                                                                });
                                                        } else {
                                                                mapOfL3vsModelsDerivatives.put(vmeBund.VME_Scheme__c, new Set < String > {
                                                                        'D'
                                                                });
                                                        }
                                                } else {
                                                        Set < String > tempSchemeSet = mapOfL3vsModelsDerivatives.get(vmeBund.VME_Scheme__c);
                                                        if (vmeBund.VME_Model_Derivative__c != null && vmeBund.VME_Model_Derivative__r.RecordType.Name == 'Model') {
                                                                tempSchemeSet.add('M');
                                                        } else {
                                                                tempSchemeSet.add('D');
                                                        }
                                                        mapOfL3vsModelsDerivatives.put(vmeBund.VME_Scheme__c, tempSchemeSet);
                                                }
                                                //Product Scheme Mapping, if any product eligible for more than 1 Scheme 
                                                if (!product_RelatedScheme_Map.containsKey(vmeBund.VME_Model_Derivative__c)) {
                                                        product_RelatedScheme_Map.put(vmeBund.VME_Model_Derivative__c, new Set < Id > {
                                                                vmeBund.VME_Scheme__c
                                                        });
                                                } else {
                                                        Set < Id > tempSchemeSet = product_RelatedScheme_Map.get(vmeBund.VME_Model_Derivative__c);
                                                        tempSchemeSet.add(vmeBund.VME_Scheme__c);
                                                        product_RelatedScheme_Map.put(vmeBund.VME_Model_Derivative__c, tempSchemeSet);
                                                }
                                        }
                                        //Asset Scheme Mapping, if any Asset eligible for more than 1 Scheme 
                                        if (vmeBund.Asset__c != null) {
                                                //This map helps in chekcing putting derivative based scheme if there is a Model Based Scheme is present.
                                                Scheme_ProductType_Map.put(vmeBund.VME_Scheme__c + '_' + vmeBund.Asset__c, 'VIN');
                                                //Putting Asset Based Scheme
                                                if (!asset_RelatedScheme_Map.containsKey(vmeBund.Asset__c)) {
                                                        asset_RelatedScheme_Map.put(vmeBund.Asset__c, new Set < Id > {
                                                                vmeBund.VME_Scheme__c
                                                        });
                                                } else {
                                                        Set < Id > tempSchemeSet = asset_RelatedScheme_Map.get(vmeBund.Asset__c);
                                                        tempSchemeSet.add(vmeBund.VME_Scheme__c);
                                                        asset_RelatedScheme_Map.put(vmeBund.Asset__c, tempSchemeSet);
                                                }
                                        }
                                }
                        }
                        System.debug(mapOfL3vsModelsDerivatives.size() + ' mapOfL3vsModelsDerivatives :: ' + mapOfL3vsModelsDerivatives);
                        System.debug(Product_On_Asset_Map.size() + ' Product_On_Asset_Map :: ' + Product_On_Asset_Map);
                        System.debug(product_RelatedScheme_Map.size() + ' product_RelatedScheme_Map :: ' + product_RelatedScheme_Map);
                        System.debug(asset_RelatedScheme_Map.size() + ' asset_RelatedScheme_Map :: ' + asset_RelatedScheme_Map);
                        System.debug(Bundling_Scheme_Map.size() + ' Bundling_Scheme_Map :: ' + Bundling_Scheme_Map);
                        //putting all bundling based Scheme Id (parent rt type Scheme) into Set
                        Set < Id > tempSchemeSet = new Set < Id > ();
                        if (Bundling_Scheme_Map != null && !Bundling_Scheme_Map.isEmpty() && Bundling_Scheme_Map.size() > 0) 
							tempSchemeSet.addAll(Bundling_Scheme_Map.values());
                        List < VME_Schemes__c > retailSchemeList = new List < VME_Schemes__c > ();
                        if (tempSchemeSet != null && tempSchemeSet.size() > 0) {
                                retailSchemeList = [SELECT Id, Name, VME_External_ID__c, VME_Retailer__c, VME_Parent_Scheme__c FROM VME_Schemes__c WHERE VME_Available_for_Claims__c = false AND VME_Parent_Scheme__c IN: tempSchemeSet];
                        }
                        for (VME_Schemes__c retailScheme: retailSchemeList) {
                                //Asset Scheme Mapping, if any Asset eligible for more than 1 Scheme 
                                if (retailScheme.VME_Retailer__c != null) {
                                        if (mapOfL3vsModelsDerivatives.containsKey(retailScheme.VME_Parent_Scheme__c) && mapOfL3vsModelsDerivatives.get(retailScheme.VME_Parent_Scheme__c) != null && mapOfL3vsModelsDerivatives.get(retailScheme.VME_Parent_Scheme__c).contains('M')) {
                                                if (asset_Retailer_Set.contains(retailScheme.VME_Retailer__c)) Scheme_ProductType_Map.put(retailScheme.VME_Parent_Scheme__c + '_' + retailScheme.VME_Retailer__c + '_M', 'Retailer_Model');
                                        }
                                        if (mapOfL3vsModelsDerivatives.containsKey(retailScheme.VME_Parent_Scheme__c) && mapOfL3vsModelsDerivatives.get(retailScheme.VME_Parent_Scheme__c) != null && mapOfL3vsModelsDerivatives.get(retailScheme.VME_Parent_Scheme__c).contains('D')) {
                                                if (asset_Retailer_Set.contains(retailScheme.VME_Retailer__c)) Scheme_ProductType_Map.put(retailScheme.VME_Parent_Scheme__c + '_' + retailScheme.VME_Retailer__c + '_D', 'Retailer_Derivative');
                                        }
                                        //Putting Asset Based Scheme
                                        if (!RetailBased_Scheme_Map.containsKey(retailScheme.VME_Retailer__c + '_' + retailScheme.VME_Parent_Scheme__c)) {
                                                if (asset_Retailer_Set.contains(retailScheme.VME_Retailer__c)) {
                                                        RetailBased_Scheme_Map.put(retailScheme.VME_Retailer__c + '_' + retailScheme.VME_Parent_Scheme__c, retailScheme.Id);
                                                        if (!Scheme_HasRetailer_Map.containsKey(retailScheme.VME_Parent_Scheme__c)) {
                                                                Scheme_HasRetailer_Map.put(retailScheme.VME_Parent_Scheme__c, new Set < Id > {
                                                                        retailScheme.VME_Retailer__c
                                                                });
                                                        } else {
                                                                Set < Id > tempChildSchemeSet = Scheme_HasRetailer_Map.get(retailScheme.VME_Parent_Scheme__c);
                                                                tempChildSchemeSet.add(retailScheme.VME_Retailer__c);
                                                                Scheme_HasRetailer_Map.put(retailScheme.VME_Parent_Scheme__c, tempChildSchemeSet);
                                                        }
                                                }
                                        }
                                }
                        }
                        masterWrapper.RetailBased_Scheme_Wrap = RetailBased_Scheme_Map;
                        System.debug(RetailBased_Scheme_Map.size() + ' RetailBased_Scheme_Map :: ' + RetailBased_Scheme_Map);
                        //Map of all Scheme with Id value Scheme
                        Map < Id, VME_Schemes__c > VME_Schemes_Map = new Map < Id, VME_Schemes__c > ();
                        //Creating a Map of Scheme for Master List of Scheme based on Asset
                        if (tempSchemeSet != null && tempSchemeSet.size() > 0) {
                                for (VME_Schemes__c scheme: getMySchemes(tempSchemeSet, retailDate, activeSchemes)) {
                                        //System.debug(scheme.VME_Child_Schemes__r.size() +'>> Parent Scheme<-> Child Scheme:: ' + scheme.VME_Child_Schemes__r);
                                        //System.debug(scheme.VME_Bundlings__r.size() +'>> Parent Scheme<-> Bundling :: ' + scheme.VME_Bundlings__r);
                                        //System.debug(' scheme main :: ' + scheme);
                                        VME_Schemes_Map.put(scheme.Id, scheme);
                                }
                        }
                        //checking channel matrix first
                        if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.size() > 0)
                                for (VME_CXP_Channel_Matrix_Dependency__mdt vcmd: [Select id, Brand_Order_Type_Code__c, Details__c, Mapping__c, Type_of_Sale_Code_L2__c, Unique_ID__c from VME_CXP_Channel_Matrix_Dependency__mdt]) {
                                        if (!VME_Channel_Matrix_Dependency_map.containsKey(vcmd.Unique_ID__c)) {
                                                VME_Channel_Matrix_Dependency_map.put(vcmd.Unique_ID__c, new Set < String > { //vcmd.Unique_ID__c
                                                        vcmd.Mapping__c
                                                });
                                        } else {
                                                Set < String > tempVcmd = VME_Channel_Matrix_Dependency_map.get(vcmd.Unique_ID__c); //vcmd.Unique_ID__c
                                                tempVcmd.add(vcmd.Mapping__c);
                                                VME_Channel_Matrix_Dependency_map.put(vcmd.Unique_ID__c, tempVcmd); //vcmd.Unique_ID__c
                                        }
                                }
                        System.debug(VME_Channel_Matrix_Dependency_map.size() + ' VME_Channel_Matrix_Dependency_map :: ' + VME_Channel_Matrix_Dependency_map);
                        Map < String, Set < String >> VME_Channel_Matrix_map = getMyChannelMatrix();
                        System.debug(VME_Channel_Matrix_map.size() + ' VME_Channel_Matrix_map :: ' + VME_Channel_Matrix_map);
                        System.debug(VIN_RelatedScheme_Final_Map.size() + ' VIN_RelatedScheme_Final_Map :: ' + VIN_RelatedScheme_Final_Map);
                        //below for loop for final check of Channel Matrix and WBS based check
                        if (VME_Schemes_Map != null && !product_RelatedScheme_Map.isEmpty() && product_RelatedScheme_Map.size() > 0 && VME_Schemes_Map.size() > 0) {
                                for (Asset assetObj: newAssetList) {
                                        Set < Id > tempSchemeIdSet = new Set < Id > ();
                                        if (Product_On_Asset_Map.containsKey(assetObj.Id)) {
                                                for (Id tempId: Product_On_Asset_Map.get(assetObj.Id)) {
                                                        if (product_RelatedScheme_Map.containsKey(tempId)) 
															tempSchemeIdSet.addAll(product_RelatedScheme_Map.get(tempId));
                                                }
                                        }
                                        String uniqueSalestype = assetObj.Sale_Type_Code__c + '_' + assetObj.VME_TypeOfSale_Code_L2__c;
                                        System.debug(' tempSchemeIdSet :: ' + tempSchemeIdSet);
                                        if (tempSchemeIdSet != null && tempSchemeIdSet.size() > 0) {
                                                //List of Scheme Which fall under the Channel Matrix Check
                                                List < VME_Schemes__c > finalChannelMatrixScheme = new List < VME_Schemes__c > ();
                                                for (VME_Schemes__c scheme: getMySelectedScheme(tempSchemeIdSet, VME_Schemes_Map)) {
                                                        String cat_subCat_ExtId = getCatSubCatCodeMapping.get(scheme.VME_Campaign__r.VME_Category__c + '-C') + '_' + getCatSubCatCodeMapping.get(scheme.VME_Campaign__r.VME_Sub_Category__c + '-SC');
                                                        System.debug(scheme.Name + ' :: -----------uniqueSalestype :: ' + uniqueSalestype + ' // ' + cat_subCat_ExtId + ' ## ' + scheme.VME_Type__c + ' :: mapping>> ' + VME_Channel_Matrix_Dependency_map.get(uniqueSalestype));
                                                        if (VME_Channel_Matrix_Dependency_map != null && VME_Channel_Matrix_Dependency_map.containsKey(uniqueSalestype) && VME_Channel_Matrix_Dependency_map.get(uniqueSalestype) != null) {
                                                                //Third for loop is to get the Channel Matrxi Final Check
                                                                //there might be chances we get teo values as Private / Demo & Courtsy as Channel from Asset
                                                                //based on these two value need to get all Category / SubCategory applicable based on Scheme and check matrix
                                                                for (String mapping: VME_Channel_Matrix_Dependency_map.get(uniqueSalestype)) {
                                                                        //below check is for Base Level Check if the Channel Matrix allow for Regula, tactical and Discreationary Scheme ot NOT
                                                                        if (VME_Channel_Matrix_map.containsKey(mapping) && VME_Channel_Matrix_map.get(scheme.VME_Type__c).contains(cat_subCat_ExtId)) {
                                                                                Set < String > tempVcmd = VME_Channel_Matrix_map.get(mapping);
                                                                                //then below check is for checking other parameter based on Channel Matrix
                                                                                if (tempVcmd.contains(cat_subCat_ExtId)) {
                                                                                        System.debug(scheme.Name + ' :: uniqueSalestype :: ' + uniqueSalestype + ' // ' + cat_subCat_ExtId + ' ## ' + scheme.VME_Type__c + ' :: mapping>> ' + VME_Channel_Matrix_Dependency_map.get(uniqueSalestype));
                                                                                        System.debug(VME_Channel_Matrix_map.get(scheme.VME_Type__c).contains(cat_subCat_ExtId) + '  VME_Channel_Matrix_map by passing  :: ' + mapping + '>>> ' + tempVcmd.contains(cat_subCat_ExtId) + '\n');
                                                                                        finalChannelMatrixScheme.add(scheme);
                                                                                        break;
                                                                                } else {
                                                                                        System.debug('*** : ' + scheme.Name + '(' + scheme.VME_Type__c + ') type matches, but ' + cat_subCat_ExtId + ' not present in VME_Channel_Matrix_map of ' + mapping + ' Selection!!\n');
                                                                                }
                                                                        } else {
                                                                                System.debug('@@@ : Not Applied in Final Selection!! Scheme Type mismatch!! -: ' + mapping + ' -->(' + scheme.Name + ')\n');
                                                                        }
                                                                }
                                                        } else {
                                                                System.debug(uniqueSalestype + ' not matching to Channel Matrix.');
                                                                //Adding trigger error
                                                                //Adding trigger execution for result
                                                                if (System.Trigger.isExecuting) {
                                                                        if (!Test.isRunningTest()) {
                                                                                assetObj.addError('The selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset\'s Sale Type Code (' + assetObj.Sale_Type_Code__c + ') , Please try again.');
                                                                        } else {
                                                                                masterWrapper.statusOfTransaction = 'MATCH ERROR';
                                                                                masterWrapper.errorMsgOfTransaction = 'The selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset\'s Sale Type Code (' + assetObj.Sale_Type_Code__c + ') , Please try again.';
                                                                        }
                                                                } else {
                                                                        masterWrapper.statusOfTransaction = 'MATCH ERROR';
                                                                        masterWrapper.errorMsgOfTransaction = 'The selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset\'s Sale Type Code (' + assetObj.Sale_Type_Code__c + ') , Please try again.';
                                                                        throw new channelMatrixException('MATCH ERROR');
                                                                }
                                                                //}
                                                        }
                                                        System.debug(finalChannelMatrixScheme.size() + ' :: finalChannelMatrixScheme :: ' + finalChannelMatrixScheme);
                                                }
                                                //Addning those Schemes which fall under Channel Matrix agaist each Asset
                                                VIN_RelatedScheme_Final_Map.put(assetObj.Id, finalChannelMatrixScheme);
                                        }
                                }
                        }
                        System.debug(VME_Schemes_Map.size() + ' VME_Schemes_Map :: ' + VME_Schemes_Map);
                        //Master Map of Asset Id and Set of Scheme Id which is going to create Claims for it.
                        Map < Id, List < VME_Schemes__c >> VIN_RelatedScheme_FinalV1_Map = new Map < Id, List < VME_Schemes__c >> ();
                        //Iterating over Aseet inside loop Scheme for validation
                        if (VIN_RelatedScheme_Final_Map != null && VIN_RelatedScheme_Final_Map.size() > 0) {
                                for (Asset assetObj: newAssetList) {
                                        String uniqueSalestype = assetObj.Sale_Type_Code__c + '_' + assetObj.VME_TypeOfSale_Code_L2__c;
                                        //List of Scheme Which fall under the Channel Matrix Check
                                        List < VME_Schemes__c > finalChannelMatrixScheme = new List < VME_Schemes__c > ();
                                        List < VME_Schemes__c > tempChannelMatrixScheme = new List < VME_Schemes__c > ();
                                        tempChannelMatrixScheme.addAll(VIN_RelatedScheme_Final_Map.get(assetObj.Id));
                                        System.debug(assetObj.Name + ' vin has ' + tempChannelMatrixScheme.size() + ' number of scheme eligible after channel matrix');
                                        if (VIN_RelatedScheme_Final_Map != null && VIN_RelatedScheme_Final_Map.containsKey(assetObj.Id))
                                                for (VME_Schemes__c scheme: tempChannelMatrixScheme) {
                                                        /* 
                                                        Below code is for selecting those BASE scheme based on Model
                                                        BASE SCHEME
                                                         */
                                                        if (scheme.VME_Scheme_Type__c == 'Base' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Base Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c, 'Model');
                                                                }
                                                        }
                                                        /* 
                                                        Below code is for selecting those others parent /child type scheme which are only model wise
                                                        ONLY MODEL WISE SCHEME NO CONFIG
                                                         */
                                                        if (scheme.VME_Scheme_Type__c == 'Others' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE && RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && !RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id) && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null && scheme.VME_Market_Arrival_Start_Date__c == null && scheme.VME_Manufacturing_Start_Date__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Only Model Based Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && !RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c, 'Model');
                                                                        }
                                                                }
                                                        }
                                                        /* 
                                                        Below code is for selecting those others parent /child type scheme which are only derivative wise
                                                        ONLY DERIVATIVE WISE SCHEME NO CONFIG
                                                         */
                                                    System.debug('scheme'+scheme);
                                                   
                                                        if (scheme.VME_Scheme_Type__c == 'Others' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE &&  RetailBased_Scheme_Map != null &&  !RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id) && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null && scheme.VME_Market_Arrival_Start_Date__c == null && scheme.VME_Manufacturing_Start_Date__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Only Derivative Based Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Derivative__c) && product_RelatedScheme_Map.get(assetObj.Derivative__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null  && !RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c, 'Derivative');
                                                                        }
                                                                }
                                                        }
                                                        /* 
                                                        Below code is for selecting those others parent /child type scheme which are basically applied for
                                                        Specific retailer with specific product and model
                                                        ONLY RETAIL BASED SCHEME WITH MODEL AND DERIVATIVE
                                                         */
                                                        if (scheme.VME_Scheme_Type__c == 'Others' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null && RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                System.debug(scheme.VME_Type__c + ' <<Retailer Based Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Retailer_Name__c + '_M', 'Retailer_Model');
                                                                        }
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Derivative__c) && product_RelatedScheme_Map.get(assetObj.Derivative__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Retailer_Name__c + '_D', 'Retailer_Derivative');
                                                                        }
                                                                }
                                                        }
                                                        /* 
                                                        Below code is executing for parent and others type scheme, which has market arrival  date and matching with Asset
                                                        manufacturing date those scheme will  be selected.
                                                        ONLY MARKET ARRIVAL DATE BASED SCHEME WITH MODEL AND DERIVATIVE
                                                         */
                                                        if (scheme.VME_Scheme_Type__c == 'Others' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE && scheme.VME_Market_Arrival_Start_Date__c != null && scheme.VME_Market_Arrival_End_Date__c != null && assetObj.VME_Market_Arrival_Date__c != null && assetObj.VME_Market_Arrival_Date__c >= scheme.VME_Market_Arrival_Start_Date__c && assetObj.VME_Market_Arrival_Date__c <= scheme.VME_Market_Arrival_End_Date__c && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Market Arrival Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Derivative__c) && product_RelatedScheme_Map.get(assetObj.Derivative__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c + '_RDMAD', 'Retailer_Derivative_MAD');
                                                                        }
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c + '_DMAD', 'Derivative_MAD');
                                                                        }
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_RMMAD', 'Retailer_Model_MAD');
                                                                        }
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_MMAD', 'Model_MAD');
                                                                        }
                                                                }
                                                        }
                                                        /* 
                                                        Below code is executing for parent and others type scheme, which has manufacture date and matching with Asset
                                                        manufacturing date those scheme will  be selected.
                                                        ONLY MANUFACTURING DATE BASED SCHEME WITH MODEL AND DERIVATIVE
                                                         */
                                                        if (scheme.VME_Scheme_Type__c == 'Others' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE && scheme.VME_Manufacturing_Start_Date__c != null && scheme.VME_Manufacturing_End_Date__c != null && assetObj.Manufacture_Year__c != null && assetObj.Manufacture_Year__c >= scheme.VME_Manufacturing_Start_Date__c && assetObj.Manufacture_Year__c <= scheme.VME_Manufacturing_End_Date__c && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Manufacture Date Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Derivative__c) && product_RelatedScheme_Map.get(assetObj.Derivative__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c + '_RDMFG', 'Retailer_Derivative_MFG');
                                                                        }
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c + '_DMFG', 'Derivative_MFG');
                                                                        }
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_RMMFG', 'Retailer_Model_MFG');
                                                                        }
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_MMFG', 'Model_MFG');
                                                                        }
                                                                }
                                                        }
                                                        /* 
                                                        Below code is executing for parent and others type scheme, which has market arrival  date  and manufacturing date and matching with Asset
                                                        manufacturing date those scheme will  be selected. All configuration scheme
                                                        ONLY MANUFACTURING DATE AND MARKET ARRIVAL DATE BASED SCHEME WITH MODEL AND DERIVATIVE
                                                         */
                                                        if (scheme.VME_Scheme_Type__c == 'Others' && scheme.RecordTypeId == PARENT_SCHEME_RECORD_TYPE && scheme.VME_Market_Arrival_Start_Date__c != null && scheme.VME_Market_Arrival_End_Date__c != null && assetObj.VME_Market_Arrival_Date__c != null && assetObj.Manufacture_Year__c != null && assetObj.VME_Market_Arrival_Date__c >= scheme.VME_Market_Arrival_Start_Date__c && assetObj.VME_Market_Arrival_Date__c <= scheme.VME_Market_Arrival_End_Date__c && scheme.VME_Manufacturing_Start_Date__c != null && scheme.VME_Manufacturing_End_Date__c != null && assetObj.Manufacture_Year__c >= scheme.VME_Manufacturing_Start_Date__c && assetObj.Manufacture_Year__c <= scheme.VME_Manufacturing_End_Date__c && scheme.VME_Trade_In__c == null && scheme.VME_Segment__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Market Arrival and Manufacture Scheme :: ' + scheme);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Derivative__c) && product_RelatedScheme_Map.get(assetObj.Derivative__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c + '_RDMADMFG', 'Retailer_Derivative_MAD_MFG');
                                                                        }
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Derivative__c + '_DMADMFG', 'Derivative_MAD_MFG');
                                                                        }
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (RetailBased_Scheme_Map != null && RetailBased_Scheme_Map.size() > 0 && RetailBased_Scheme_Map.containsKey(assetObj.Retailer_Name__c + '_' + scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_RMMADMFG', 'Retailer_Model_MAD_MFG');
                                                                        }
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_MMADMFG', 'Model_MAD_MFG');
                                                                        }
                                                                }
                                                        }
                                                        String oppTradeIn;
                                                        String schemeL3Descp;
                                                        String segment_L3;
                                                        String segment_Opp;
                                                        String subDivision_L3;
                                                        String subDivision_Opp;
                                                        String fnb_ofb_L3;
                                                        String fnb_ofb_Opp;
                                                        //logic for removing space for checking trade in and L3 description
                                                        if (Asset_OpportunityCustomer_Map != null && Asset_OpportunityCustomer_Map.get(assetObj.Id) != null && Asset_OpportunityCustomer_Map.get(assetObj.Id).Opportunity != null) {
                                                                oppTradeIn = Asset_OpportunityCustomer_Map.get(assetObj.Id).Opportunity.VME_Trade_in_Type__c;
                                                                schemeL3Descp = scheme.VME_Trade_In__c;
                                                                //Opportunity segment populated
                                                                segment_Opp = Asset_OpportunityCustomer_Map.get(assetObj.Id).Opportunity.VME_Segment__c;
                                                                subDivision_Opp = Asset_OpportunityCustomer_Map.get(assetObj.Id).Opportunity.VME_Sub_Division__c;
                                                                if (segment_Opp != null && subDivision_Opp != null) {
                                                                        fnb_ofb_Opp = segment_Opp + '_' + subDivision_Opp;
                                                                } else if (segment_Opp != null && subDivision_Opp == null) {
                                                                        fnb_ofb_Opp = segment_Opp;
                                                                }
                                                                //L3 VME Scheme segment populated
                                                                segment_L3 = scheme.VME_Segment__c;
                                                                subDivision_L3 = scheme.VME_Sub_Division__c;
                                                                if (segment_L3 != null && subDivision_L3 != null) {
                                                                        fnb_ofb_L3 = segment_L3 + '_' + subDivision_L3;
                                                                } else if (segment_L3 != null && subDivision_L3 == null) {
                                                                        fnb_ofb_L3 = segment_L3;
                                                                }
                                                        }
                                                        //ONLY OPP SCHEME SEGMENT SUBDIVISION IN TYPE SCHEME FOR MODEL
                                                        //below if logic is for if the Segment / Subdivision is populated in related Asset opportunity
                                                        //check with same Segment / Subdivision in L3 description and apply that scheme from that RNF TRI L2
                                                        if (fnb_ofb_Opp != null && fnb_ofb_L3 != null && fnb_ofb_Opp == fnb_ofb_L3 && scheme.VME_Trade_In__c == null && scheme.VME_Market_Arrival_Start_Date__c == null && scheme.VME_Manufacturing_Start_Date__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Segment/SubDivision In Type Scheme :: ' + scheme);
                                                                System.debug('Oportunity Segment ' + fnb_ofb_Opp);
                                                                System.debug('Scheme L3 Segment ' + fnb_ofb_L3);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_MOFB', 'Model_OFB');
                                                                        }
                                                                }
                                                        }
                                                        //ONLY OPP SCHEME TRADE IN TYPE SCHEME FOR MODEL
                                                        //below if logic is for if the Trade in Support is populated in related Asset opportunity
                                                        //check with same trade in support in L3 description and apply that scheme from that RNF TRI L2
                                                        if (oppTradeIn != null && schemeL3Descp != null && oppTradeIn == schemeL3Descp && scheme.VME_Market_Arrival_Start_Date__c == null && scheme.VME_Manufacturing_Start_Date__c == null && scheme.VME_Segment__c == null) {
                                                                System.debug(scheme.VME_Type__c + ' <<Trade In Type Scheme :: ' + scheme);
                                                                System.debug('Oportunity Trade-In ' + oppTradeIn);
                                                                System.debug('Scheme L3 Description ' + schemeL3Descp);
                                                                if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, new List < VME_Schemes__c > {
                                                                                scheme
                                                                        });
                                                                } else {
                                                                        List < VME_Schemes__c > temSchemeList = VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id);
                                                                        temSchemeList.add(scheme);
                                                                        VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, temSchemeList);
                                                                }
                                                                if (product_RelatedScheme_Map != null && product_RelatedScheme_Map.containsKey(assetObj.Model__c) && product_RelatedScheme_Map.get(assetObj.Model__c).contains(scheme.Id)) {
                                                                        if (Scheme_HasRetailer_Map == null || !Scheme_HasRetailer_Map.containsKey(scheme.Id)) {
                                                                                Scheme_ProductType_Map.put(scheme.Id + '_' + assetObj.Model__c + '_MTRI', 'Model_TradeIn');
                                                                        }
                                                                }
                                                        }
                                                }
                                }
                        }
                        System.debug(VIN_RelatedScheme_FinalV1_Map + ' VIN_RelatedScheme_FinalV1_Map :: ' + VIN_RelatedScheme_FinalV1_Map);
                        //Below for Loop is specialluy for Adding VIN based (Discreationary) Scheme Directly into Asset List Scheme with out Channel Matrix Check
                        if (asset_RelatedScheme_Map != null &&  asset_RelatedScheme_Map.size()>0) {
                                for (Id assetObjId: asset_RelatedScheme_Map.keySet()) {
                                        if (!VIN_RelatedScheme_FinalV1_Map.containsKey(assetObjId)) {
                                                Set < Id > finalSchemeSet = new Set < Id > (asset_RelatedScheme_Map.get(assetObjId));
                                                VIN_RelatedScheme_FinalV1_Map.put(assetObjId, getMySelectedScheme(finalSchemeSet, VME_Schemes_Map));
                                        } else {
                                                List < VME_Schemes__c > tempfinalChannelMatrixScheme = VIN_RelatedScheme_FinalV1_Map.get(assetObjId);
                                                Set < Id > finalSchemeSet = new Set < Id > (asset_RelatedScheme_Map.get(assetObjId));
                                                tempfinalChannelMatrixScheme.addAll(getMySelectedScheme(finalSchemeSet, VME_Schemes_Map));
                                                VIN_RelatedScheme_FinalV1_Map.put(assetObjId, tempfinalChannelMatrixScheme);
                                        }
                                }
                        }
                        System.debug(VIN_RelatedScheme_FinalV1_Map.size() + ' VIN_RelatedScheme_FinalV1_Map Asset Added :: ' + VIN_RelatedScheme_FinalV1_Map);
                        System.debug(Scheme_ProductType_Map.size() + ' Scheme_Asset_ProductType_Map :: ' + Scheme_ProductType_Map);
                        for (String gg: VIN_RelatedScheme_FinalV1_Map.keySet()) {
                                for (VME_Schemes__c typo: VIN_RelatedScheme_FinalV1_Map.get(gg)) {
                                        System.debug(typo.Name + ' ==>> ::: ' + typo);
                                }
                        }
                        for (String typo: Scheme_ProductType_Map.keySet()) {
                                System.debug(typo + ' val ::: ' + Scheme_ProductType_Map.get(typo));
                        }
                        Map < String, Integer > schemeTypeMap = new Map < String, Integer > {
                                'VIN' => 1,
                                'Retailer_Derivative_MAD_MFG' => 2,
                                'Model_OFB' => 2,
                                'Model_TradeIn' => 2,
                                'Retailer_Derivative_MFG' => 3,
                                'Retailer_Derivative_MAD' => 4,
                                'Retailer_Derivative' => 5,
                                'Retailer_Model_MAD_MFG' => 6,
                                'Retailer_Model_MFG' => 7,
                                'Retailer_Model_MAD' => 8,
                                'Retailer_Model' => 9,
                                'Derivative_MAD_MFG' => 10,
                                'Derivative_MFG' => 11,
                                'Derivative_MAD' => 12,
                                'Derivative' => 13,
                                'Model_MAD_MFG' => 14,
                                'Model_MFG' => 15,
                                'Model_MAD' => 16,
                                'Model' => 17
                        };
                        System.debug('\n\n');
                        //Below for loop decide no two scheme from Same VME will applicable to Asset
                        //Differenciating to it. if Model and Derivative based Scheme both are present then Derivative will be applicable , Model Scheme will be discarded
                        if (VIN_RelatedScheme_FinalV1_Map != null && VIN_RelatedScheme_FinalV1_Map.size() > 0) {
                                for (Asset assetObj: newAssetList) {
                                        if (VIN_RelatedScheme_FinalV1_Map != null && VIN_RelatedScheme_FinalV1_Map.containsKey(assetObj.Id)) {
                                                //temporary map of Category and Sub category value to Scheme id
                                                //means per WBS only one Scheme applicable
                                                Map < String, Id > WBS_Scheme_Map = new Map < String, Id > ();
                                                Map < String, Integer > WBS_SchemeP_Map = new Map < String, Integer > ();
                                                for (VME_Schemes__c finalScheme: VIN_RelatedScheme_FinalV1_Map.get(assetObj.Id)) {
                                                        //getting the Category and Sub Category from Channel Matrix Custom Setting in utility Class
                                                        String sType = finalScheme.VME_Type__c.subString(0, 1);
                                                        String cat = getCatSubCatCodeMapping.get(finalScheme.VME_Campaign__r.VME_Category__c + '-C');
                                                        String subCat = getCatSubCatCodeMapping.get(finalScheme.VME_Campaign__r.VME_Sub_Category__c + '-SC');
                                                        String mapWpKey = sType + cat + '_' + subCat;
                                                        String extId = '';
                                                        //17 Only Model / Base
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c) != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c;
                                                                System.debug('-- 17');
                                                        }
                                                        //16 Model Manufacturing date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_MMAD') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_MMAD';
                                                                System.debug('-- 16');
                                                        }
                                                        //15 Model Manufacturing date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_MMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_MMFG';
                                                                System.debug('-- 15');
                                                        }
                                                        //14 Retailer Model Manufacture Date & Market Arrival Date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_MMADMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_MMADMFG';
                                                                System.debug('-- 14e');
                                                        }
                                                        //13 Only Derivative
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c) != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c;
                                                                System.debug('-- 13');
                                                        }
                                                        //12 Derivative Market Arrival date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c + '_DMAD') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c + '_DMAD';
                                                                System.debug('-- 12');
                                                        }
                                                        //11 Derivative Manufacturing date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c + '_DMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c + '_DMFG';
                                                                System.debug('-- 11');
                                                        }
                                                        //10 Derivative trade in
                                                        /* if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c+'_DTRI') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c+'_DTRI';
                                                                System.debug('-- 10');
                                                        } */
                                                        //10 Derivative Manufacture Date & Market Arrival Date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c + '_DMADMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c + '_DMADMFG';
                                                                System.debug('-- 10e');
                                                        }
                                                        //9 Retailer Model only
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Retailer_Name__c + '_M') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Retailer_Name__c + '_M';
                                                                System.debug('-- 9');
                                                        }
                                                        //8 Retailer Model Market Arrival Date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_RMMAD') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_RMMAD';
                                                                System.debug('-- 8');
                                                        }
                                                        //7 Retailer Derivative Manufacturing date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_RMMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_RMMFG';
                                                                System.debug('-- 7');
                                                        }
                                                        //6 Retailer Model Manufacture Date & Market Arrival Date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_RMMADMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_RMMADMFG';
                                                                System.debug('-- 6e');
                                                        }
                                                        //5 Retailer Derivative only
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Retailer_Name__c + '_D') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Retailer_Name__c + '_D';
                                                                System.debug('-- 5');
                                                        }
                                                        //4 Retailer Model Market Arrival date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c + '_RDMAD') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c + '_RDMAD';
                                                                System.debug('-- 4');
                                                        }
                                                        //3 Retailer Derivative Manufacturing date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c + '_RDMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c + '_RDMFG';
                                                                System.debug('-- 3');
                                                        }
                                                        //2 Retailer Derivative Manufacture Date & Market Arrival Date
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Derivative__c + '_RDMADMFG') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Derivative__c + '_RDMADMFG';
                                                                System.debug('-- 2');
                                                        }
                                                        //2 Retailer Model Segment in
                                                        else if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_MOFB') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_MOFB';
                                                                System.debug('-- 2Ie');
                                                        }
                                                        //2 Retailer Model trade in
                                                        else if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Model__c + '_MTRI') != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Model__c + '_MTRI';
                                                                System.debug('-- 2IIe');
                                                        }
                                                        //1 looking for VIN based
                                                        if (Scheme_ProductType_Map.get(finalScheme.Id + '_' + assetObj.Id) != null) {
                                                                extId = finalScheme.Id + '_' + assetObj.Id;
                                                                System.debug('-- 1');
                                                        }
                                                        String productType = Scheme_ProductType_Map.get(extId);
                                                        System.debug(finalScheme.Id + ' :: Scheme Type :: ' + finalScheme.VME_Type__c + ' :: Category / SubCategory :: ' + mapWpKey + ' is ' + productType + ' based.' + extId);
                                                        System.debug(schemeTypeMap.containsKey(productType) + ' // ' + productType + ' Present  :: with priority :- ' + schemeTypeMap.get(productType));
                                                        if (schemeTypeMap.containsKey(productType)) {
                                                                if (!WBS_SchemeP_Map.containsKey(sType + cat + '_' + subCat) || WBS_SchemeP_Map.get(sType + cat + '_' + subCat) > schemeTypeMap.get(productType)) {
                                                                        WBS_Scheme_Map.put(sType + cat + '_' + subCat, finalScheme.Id);
                                                                        WBS_SchemeP_Map.put(sType + cat + '_' + subCat, schemeTypeMap.get(productType));
                                                                        System.debug('WBS Map If');
                                                                } else {
                                                                        if (WBS_SchemeP_Map.get(sType + cat + '_' + subCat) >= schemeTypeMap.get(productType)) {
                                                                                System.debug('WBS Map If Else');
                                                                                String tempStr = WBS_Scheme_Map.get(sType + cat + '_' + subCat);
                                                                                System.debug(VME_Schemes_Map.get(tempStr).VME_Start_Date__c + ' == ' + VME_Schemes_Map.get(finalScheme.Id).VME_Start_Date__c);
                                                                                if (VME_Schemes_Map.get(tempStr).VME_Start_Date__c < VME_Schemes_Map.get(finalScheme.Id).VME_Start_Date__c) {
                                                                                        System.debug('WBS Map If else if startdate');
                                                                                        WBS_Scheme_Map.put(sType + cat + '_' + subCat, finalScheme.Id);
                                                                                        WBS_SchemeP_Map.put(sType + cat + '_' + subCat, schemeTypeMap.get(productType));
                                                                                }
                                                                        }
                                                                }
                                                        }
                                                        System.debug('WBS_SchemeP_Map :: ' + WBS_SchemeP_Map);
                                                        System.debug('WBS_Scheme_Map :: ' + WBS_Scheme_Map);
                                                        System.debug('\n\n');
                                                }
                                                Set < Id > finalSchemeSet = new Set < Id > (WBS_Scheme_Map.values());
                                                System.debug('finalSchemeSet :: ' + finalSchemeSet);
                                                VIN_RelatedScheme_FinalV1_Map.put(assetObj.Id, getMySelectedScheme(finalSchemeSet, VME_Schemes_Map));
                                        }
                                }
                        }
                        System.debug(VIN_RelatedScheme_FinalV1_Map.size() + ' VIN_RelatedScheme_FinalV1_Map :: ' + VIN_RelatedScheme_FinalV1_Map);
                        masterWrapper.VIN_RelatedScheme_Final_Wrap = VIN_RelatedScheme_FinalV1_Map;
                        System.debug(VIN_RelatedScheme_FinalV1_Map.size() + ' VIN_RelatedScheme_FinalV1_Map :: ' + VIN_RelatedScheme_FinalV1_Map);
						if(restrictAfterUpdate){
							masterWrapper.statusOfTransaction = 'INVALID VIN';
						}else{
							masterWrapper.statusOfTransaction = 'SUCCESS';
						}                        
                        masterWrapper.errorMsgOfTransaction = '';
                } catch (Exception e) {
                        System.debug('Exception thrown here :: ' + e.getMessage());
                        System.debug('Exception thrown here :: ' + e.getLineNumber());
                        if (e.getMessage().contains('MATCH ERROR')) {
                                masterWrapper.statusOfTransaction = 'MATCH ERROR';
                                //masterWrapper.errorMsgOfTransaction='The selected VME type of sale code is not supported for the Asset\'s Type of Sale Code L2, Please try again.';
                        } else {
                                masterWrapper.statusOfTransaction = 'ERROR';
                                masterWrapper.errorMsgOfTransaction = 'Error is ' + e.getMessage() + ' occurs in line ' + e.getLineNumber();
                        }
                }
                return masterWrapper;
        }
        //Master Wrapper sending to VME Planner
        public class VME_GenerateClaim_Wrapper {
                public Map < Id, List < VME_Schemes__c >> VIN_RelatedScheme_Final_Wrap;
                public Map < String, Id > RetailBased_Scheme_Wrap;
                public Map < Id, OpportunityLineItem > Asset_OpportunityCustomer_Wrap;
                public Map < Id, Account > Asset_Retailer_Wrap;
                public Map < Id, Set < Id >> asset_Selected_Scheme_Wrap;
                //  public User userDetails_Wrap;
                public String statusOfTransaction;
                public String errorMsgOfTransaction;
        }
        public static List < VME_Schemes__c > getMySchemes(Set < ID > relatedSchemeIds, Date retailDate, Boolean activeSchemes) {
                Date formulatedRetailDate;
                if (retailDate != null) {
                        formulatedRetailDate = retailDate;
                } else {
                        formulatedRetailDate = System.today();
                }
                System.debug(activeSchemes + ' // ' + formulatedRetailDate + ' //These are the Applicable Parent Scheme Id ::' + relatedSchemeIds);
                if (relatedSchemeIds != null && !relatedSchemeIds.isEmpty() && relatedSchemeIds.size() > 0) {
                        String SCHEME_QUERY = 'SELECT Id, Name, CurrencyIsoCode, RecordTypeId, RecordType.Name, VME_Parent_Scheme__c, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c,VME_Campaign__r.VME_External_ID__c,VME_Campaign__r.VME_Category__c, VME_Campaign__r.VME_Sub_Category__c, VME_Campaign__r.VME_Quarter__c, VME_Campaign__r.VME_Market_Code__c, VME_Campaign__r.VME_Country_ISO_Code__c, VME_Campaign__r.VME_End_Date__c,VME_JLR_Share__c, VME_PU_Amount__c, convertCurrency(VME_PU_Amount__c) VME_PU_Amount, VME_Retailer__c, VME_Trade_In__c, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, convertCurrency(VME_Total_Amount_Approved__c) VME_Total_Amount_Approved, VME_Total_Amount_Available__c, convertCurrency(VME_Total_Amount_Available__c) VME_Total_Amount_Available, VME_Available_for_Claims__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, VME_Total_VME__c, convertCurrency(VME_Total_VME__c) VME_Total_VME, VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, VME_Retailer_Contribution__c, convertCurrency(VME_Retailer_Contribution__c) VME_Retailer_Contribution, VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c, VME_Type__c, VME_Segment__c, VME_Sub_Division__c, (SELECT Id, Name, CurrencyIsoCode, VME_Model_Derivative__c, VME_Model_Derivative__r.Name, VME_Model_Derivative__r.Model__r.Name, VME_Model_Derivative__r.Make__r.Name, VME_Model_Derivative__r.Model__c, VME_Model_Derivative__r.Make__c, VME_Scheme__c, VME_Scheme__r.Name, Asset__c, Asset__r.Name, Asset__r.VIN__c FROM VME_Bundlings__r), (SELECT Id, Name, VME_Available_for_Claims__c, CurrencyIsoCode, VME_Retailer__c, VME_Campaign__c FROM  VME_Child_Schemes__r WHERE VME_Parent_Scheme__c != null AND RecordTypeId =: CHILD_SCHEME_RECORD_TYPE) FROM VME_Schemes__c WHERE VME_Parent_Scheme__c = null AND RecordTypeId =: PARENT_SCHEME_RECORD_TYPE AND Id IN: relatedSchemeIds AND VME_Start_Date__c <=: formulatedRetailDate AND VME_End_Date__c>=: formulatedRetailDate AND VME_Available_for_Claims__c =: activeSchemes ORDER BY Name ASC';
                        return Database.query(SCHEME_QUERY);
                }
                return null;
        }
        public static List < VME_Bundling__c > getSchemeBudling(Set < Id > findSchemesFromProductSet, Set < Id > findSchemesOnAsset, Date retailDate, Boolean activeSchemes) {
                System.debug('getSchemeBudling from Product Set ::' + findSchemesFromProductSet);
                System.debug('getSchemeBudling Asset Set ::' + findSchemesOnAsset);
                Date formulatedRetailDate;
                if (retailDate != null) {
                        formulatedRetailDate = retailDate;
                } else {
                        formulatedRetailDate = System.today();
                }
                System.debug('formulatedRetailDate Asset ::' + formulatedRetailDate);
                String BUNDLING_QUERY = 'SELECT Id, Name, CurrencyIsoCode, VME_Model_Derivative__c, VME_Model_Derivative__r.Name, VME_Model_Derivative__r.Model__r.Name, VME_Model_Derivative__r.Make__r.Name, VME_Model_Derivative__r.Model__c, VME_Model_Derivative__r.Make__c, VME_Scheme__r.VME_Scheme_Type__c, VME_Model_Derivative__r.RecordType.Name, VME_Scheme__c, VME_Scheme__r.Name, VME_Scheme__r.VME_Start_Date__c, VME_Scheme__r.VME_Retailer__c, VME_Scheme__r.RecordTypeId, VME_Scheme__r.RecordType.Name,VME_Scheme__r.VME_End_Date__c ,Asset__c, Asset__r.Name, Asset__r.VIN__c, VME_Scheme__r.VME_Trade_In__c FROM VME_Bundling__c WHERE VME_Scheme__r.VME_Start_Date__c <=: formulatedRetailDate AND VME_Scheme__r.VME_End_Date__c>=: formulatedRetailDate'; // AND VME_Scheme__r.VME_Available_for_Claims__c =: activeSchemes';
                if (findSchemesFromProductSet != null && findSchemesFromProductSet.size() > 0 && findSchemesOnAsset == null && findSchemesOnAsset.size() == 0) {
                        BUNDLING_QUERY += ' AND VME_Model_Derivative__c IN: findSchemesFromProductSet';
                }
                if (findSchemesOnAsset != null && findSchemesOnAsset.size() > 0 && findSchemesFromProductSet == null && findSchemesFromProductSet.size() == 0) {
                        BUNDLING_QUERY += ' AND Asset__c IN: findSchemesOnAsset';
                }
                if (findSchemesFromProductSet != null && findSchemesFromProductSet.size() > 0 && findSchemesOnAsset != null && findSchemesOnAsset.size() > 0) {
                        BUNDLING_QUERY += ' AND (VME_Model_Derivative__c IN: findSchemesFromProductSet OR Asset__c IN: findSchemesOnAsset)';
                }
                System.debug('*** BUNDLING_QUERY :: ' + BUNDLING_QUERY);
                BUNDLING_QUERY += ' ORDER BY Name ASC';
                return Database.query(BUNDLING_QUERY);
        }
        public static Map < Id, Product2 > getMyProducts(Set < Id > geyMyProductsIdSet) {
                System.debug('getMyProducts ::' + geyMyProductsIdSet);
                Map < Id, Product2 > getMyProductsMap = new Map < Id, Product2 > ([SELECT Id, CurrencyIsoCode, IsActive, Make__c, Make__r.Name, Market__c, Model__c, Model__r.Name, Model__r.ProductCode, Name, ProductCode, RecordTypeId, RecordType.Name, VME_GST__c FROM Product2 WHERE Id IN: geyMyProductsIdSet]);
                return getMyProductsMap;
        }
        public static List < VME_Schemes__c > getMySelectedScheme(Set < Id > mySchemeIdSet, Map < Id, VME_Schemes__c > myAllScheme) {
                System.debug('getMySelectedScheme S ::' + mySchemeIdSet);
                System.debug('getMySelectedScheme SMap ::' + myAllScheme);
                List < VME_Schemes__c > filteredSchemeList = new List < VME_Schemes__c > ();
                for (Id schemeId: myAllScheme.keySet()) {
                        if (mySchemeIdSet.size() > 0 && mySchemeIdSet.contains(schemeId)) {
                                filteredSchemeList.add(myAllScheme.get(schemeId));
                        }
                }
                return filteredSchemeList;
        }
        public static Map < String, Set < String >> getMyChannelMatrix() {
                Map < String, Set < String >> VME_Channel_Matrix = new Map < String, Set < String >> ();
                for (VME_CXP_Channel_Matrix__mdt vcm: [Select id, Approved__c, Category__c, C_Code__c, Demo_Courtesy__c, Discretionary__c, Export__c, Fleet_Business__c, MDR_Rental__c, OUV__c, Private__c, Regular__c, SC_Code__c, Self_Regs__c, Stock__c, Sub_Category__c, Tactical__c, Label from VME_CXP_Channel_Matrix__mdt]) {
                        if (vcm.Regular__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Regular')) {
                                        VME_Channel_Matrix.put('Regular', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Regular');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Regular', tempVcm);
                                }
                        }
                        if (vcm.Tactical__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Tactical')) {
                                        VME_Channel_Matrix.put('Tactical', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Tactical');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Tactical', tempVcm);
                                }
                        }
                        if (vcm.Discretionary__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Discretionary')) {
                                        VME_Channel_Matrix.put('Discretionary', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Discretionary');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Discretionary', tempVcm);
                                }
                        }
                        if (vcm.Private__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Private')) {
                                        VME_Channel_Matrix.put('Private', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Private');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Private', tempVcm);
                                }
                        }
                        if (vcm.Fleet_Business__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Fleet & Business')) {
                                        VME_Channel_Matrix.put('Fleet & Business', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Fleet & Business');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Fleet & Business', tempVcm);
                                }
                        }
                        if (vcm.MDR_Rental__c == true) {
                                if (!VME_Channel_Matrix.containsKey('MDR (Rental)')) {
                                        VME_Channel_Matrix.put('MDR (Rental)', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('MDR (Rental)');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('MDR (Rental)', tempVcm);
                                }
                        }
                        if (vcm.Demo_Courtesy__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Demo & Courtesy')) {
                                        VME_Channel_Matrix.put('Demo & Courtesy', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Demo & Courtesy');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Demo & Courtesy', tempVcm);
                                }
                        }
                        if (vcm.Export__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Export')) {
                                        VME_Channel_Matrix.put('Export', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Export');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Export', tempVcm);
                                }
                        }
                        if (vcm.Self_Regs__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Self Regs')) {
                                        VME_Channel_Matrix.put('Self Regs', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Self Regs');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Self Regs', tempVcm);
                                }
                        }
                        if (vcm.Stock__c == true) {
                                if (!VME_Channel_Matrix.containsKey('Stock')) {
                                        VME_Channel_Matrix.put('Stock', new Set < String > {
                                                vcm.Label
                                        });
                                } else {
                                        Set < String > tempVcm = VME_Channel_Matrix.get('Stock');
                                        tempVcm.add(vcm.Label);
                                        VME_Channel_Matrix.put('Stock', tempVcm);
                                }
                        }
                }
                return VME_Channel_Matrix;
        }
}
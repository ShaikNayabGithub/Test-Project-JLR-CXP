/*
* S.No.    Name    Date(DD/MM/YYYY)  Change 
* 1.0    Ashwin    09/06/2021      CXPD-1308: Prevent any process from updating VistaStatus from Customer Handover to older values.
* 
*/
public class AssetHandler {
    public static boolean CreateNewAssetRoleRun = false;
    public static boolean CreateNewServiceContractRun = true;
    public static boolean CreateNewServiceContractNewMarketRun = true;
    
    public static Boolean IgnoreMMIT = false;
    
    //CXPD-1882
    List<BEV_PHEV_Asset__mdt> evTypes = [SELECT MasterLabel, Value__c FROM BEV_PHEV_Asset__mdt];
    public static String vinId;
    public static String subchar;
    
    Id vehcileOptionRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle_Option').getRecordTypeId();
    private static List<Asset> vehicles = new List<Asset>();
    private static List<Asset> vehicleOptions = new List<Asset>();
    
    public void PreInsert(List<Asset> currentAssets)
    {

        populateChangedRecordTypes(currentAssets);
        if(vehicleOptions.size() > 0) {
            setVehicleOptionDefaults(currentAssets);
        }
        if(vehicles.size() == 0 ) {
            return;
        } 

        Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();
        Asset_ProductSetter productSetter =  new Asset_ProductSetter();
        
        colourGroupSetter.SetColourGroup(currentAssets);
        productSetter.SetProductOnCreate(currentAssets);
        
        Asset_ModelYearSetter.SetModelYear(currentAssets, null);
        this.assetFieldUpdates(currentAssets, null);
        
        //CXPD-1882
        Map<String, String> evTypesMap = new Map<String, String>();
        for(BEV_PHEV_Asset__mdt evType: evTypes){
            evTypesMap.put(evType.MasterLabel, evType.Value__c);
        }
        for(Asset asset: currentAssets){
            if(asset.VIN__c!=NULL){
                vinId = asset.VIN__c;
                if(vinId != null && vinId.length() > 7){
                    subchar = vinId.substring(7, 8);
                    if(evTypesMap.containsKey(subchar)){
                        asset.EV_Type__c = evTypesMap.get(subchar);
                    }
                }
            }
        }
    }
    
    public void PostInsert(List<Asset> currentAssets)
    {
        if(!IgnoreMMIT){
            populateChangedRecordTypes(currentAssets);
            if(vehicles.size() == 0 ) {
                return;
            }
            MMIT_OpportunityInfoSetter_Asset_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_Asset_F();
            MMIT_OpportunityInfoSetter_Asset mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();        
            mmitOpportunityInfoSetter.SetVehicleInfo(currentAssets);
        }
        // try{ //Added as part of JIRA 2123
        // for(Asset currAsset:currentAssets){
        //     if(currAsset.Original_Handover_Date__c!=null)
        //     currAsset.Fleet_Start_Date__c=currAsset.Original_Handover_Date__c;

        // }
        // }catch(DMLException e){
          
        // }
    }
    
    public void PreUpdate(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap)
    {

        populateChangedRecordTypes(currentAssets);
        if(vehicleOptions.size() > 0) {
            setVehicleOptionDefaults(currentAssets);
        }
        if(vehicles.size() == 0 ) {
            return;
        }

        //1.0
        Id d42ProfileId = [Select id from Profile where Name = 'D42 Integration']?.Id; 
        //new
        Map<Id,Id> changedAccountMap = new Map<Id,Id>();
        Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();
        
        /* if(!IgnoreMMIT){
system.debug('IgnoreMMIT --> '+IgnoreMMIT);
MMIT_OpportunityInfoSetter_Asset_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_Asset_F();
MMIT_OpportunityInfoSetter_Asset mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();
mmitOpportunityInfoSetter.SetVehicleInfo(currentAssets, oldAssetMap);
} */
        for(Asset newAsset : currentAssets){
            Asset oldAsset = oldAssetMap.get(newAsset.id);
            changedAccountMap.put(newAsset.Id, newAsset.AccountId); 
            if(newAsset.AccountId != oldAsset.AccountId){
                if(newAsset.Driver__c == oldAsset.Driver__c){
                    newAsset.Driver__c = null;
                }
                if(newAsset.Lessee__c == oldAsset.Lessee__c){
                    newAsset.Lessee__c = null;
                }
                
            }
            //1.0
            if(newAsset.Vista_Status__c != oldAsset.Vista_Status__c && 
               (oldAsset.Vista_Status__c == 'Customer Handover' || oldAsset.Vista_Status__c == 'Arrived at Dealer') && 
               d42ProfileId == UserInfo.getProfileId()
              ){
                  newAsset.Vista_Status__c = oldAsset.Vista_Status__c;
              }
            
            // system.debug('oldAss SUBMITTED '+Json.serializePretty(oldAss));
            //   system.debug('ass SUBMITTED '+Json.serializePretty(ass));
            // ass.addError('Stop');
            
            //CXPD-1882
            Map<String, String> evTypesMap = new Map<String, String>();
            for(BEV_PHEV_Asset__mdt evType: evTypes){
                evTypesMap.put(evType.MasterLabel, evType.Value__c);
            }
            for(Asset asset: currentAssets){
                if(asset.VIN__c != NULL && asset.VIN__c != oldAsset.VIN__c){
                    vinId = asset.VIN__c;
                    subchar = vinId.substring(7, 8);
                    if(evTypesMap.containsKey(subchar)){
                        asset.EV_Type__c = evTypesMap.get(subchar);
                    }
                }
            }
        }
        
        
        
        setKeyContact(changedAccountMap, currentAssets );
        Asset_ProductSetter productSetter = new Asset_ProductSetter();
        colourGroupSetter.SetColourGroup(currentAssets, oldAssetMap);        
        productSetter.SetProductOnUpdate(oldAssetMap, currentAssets);
        
        Asset_ModelYearSetter.SetModelYear(currentAssets, oldAssetMap);
        
        WrittenOffAssets writeOffAsset = new WrittenOffAssets();
        writeOffAsset.writtenOffAsset(currentAssets, oldAssetMap);
        this.assetFieldUpdates(currentAssets, oldAssetMap);

      /**  try{ //Added as part of JIRA 2123
             for(Asset currAsset:currentAssets){
                 if(currAsset.Original_Handover_Date__c!=null)
                 currAsset.Fleet_Start_Date__c=currAsset.Original_Handover_Date__c;
                 
                 if(currAsset.Vista_Status__c!=null&&currAsset.Vista_Status__c=='Customer Handover'&&(currAsset.Common_Sale_Type__c!=null&&(currAsset.Common_Sale_Type__c=='Courtesy, Loan Car'||currAsset.Common_Sale_Type__c=='Courtesy / Loan Car'||currAsset.Common_Sale_Type__c=='Demonstrator'))){
                    currAsset.Retailer_Fleet_Status__c='Active';
                 }else{
                    currAsset.Retailer_Fleet_Status__c='InActive';
                 }
                 if( currAsset.Retailer_Fleet_Status__c=='InActive')
                    currAsset.Actual_Defleet_Date__c=Date.today();
                 else   
                    currAsset.Actual_Defleet_Date__c=null;
            }
            }catch(DMLException e){
              
             } */ 
    }
    public void setKeyContact(Map<Id, Id> assetToAccount,List<Asset> currentAssets ){
        if(assetToAccount!= null && assetToAccount.size() > 0){
            Map<ID, Account> accountMap = new Map<ID, Account>([Select Id, Recordtype.Name,Country_iso_code__c, isPersonAccount, PersonContactId, (SELECT ID FROM Contacts) FROM Account where Id in :assetToAccount.Values()]);
            for(Asset newAss : currentAssets){
                if(assetToAccount.containsKey(newAss.id) && accountMap != null && accountMap.size()>0 && accountMap.containsKey(assetToAccount.get(newAss.id)) ){
                    Account acc = accountMap.get(assetToAccount.get(newAss.id));
                    if(acc.PersonContactId != null){
                        //either set to 
                        newAss.Key_Contact__c = acc.PersonContactId;
                    }
                    if( newAss.Key_Contact__c != null && (acc.Recordtype.Name == 'Retailer' || acc.country_iso_code__c != 'AU' ) ){
                        if(acc.Contacts != null && acc.Contacts.size() > 0 ){
                            Boolean wipeContact = true;
                            for(Contact con : acc.Contacts){
                                if(wipeContact && con.Id == newAss.Key_Contact__c){
                                    wipeContact = false; 
                                }
                            }
                            if(wipeContact){
                                newAss.Key_Contact__c = null; 
                            }
                            
                            
                            
                        }else{
                            newAss.Key_Contact__c = null;
                        }
                    }
                    
                    
                    
                }
            }
            
        }
        
    }
    
    public void CreateNewServiceContract(Map<Id,Asset> newAssetsMap, Map<Id, Asset> oldAssetMap)
    {
        system.debug('CreateNewServiceContractRun --> '+CreateNewServiceContractRun);
        User loggedUser = [SELECT Id,Name,Market__c,ContactId,Country_ISO_Code__c, profile.Name,Contact.Account.Country_ISO_Code__c,Contact.AccountId,Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        if(CreateNewServiceContractRun){
            system.debug('executing');
            If(string.isNotBlank(system.label.CXP_AUTO_SPC_ON_HANDOVER) && 
               string.isNotEmpty(system.label.CXP_AUTO_SPC_ON_HANDOVER))
            {
                Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
                List<string> CountryIsoCode= system.label.CXP_AUTO_SPC_ON_HANDOVER.split(';');
                system.debug(CountryIsoCode);
                Map<Id,set<string>> existingSpcAssetIdMap = New Map<Id,set<string>>();
                Set<Id> servicePlanIdSet= New Set<Id>();
                Set<string> assetCountryIsoSet= New Set<string>();
                Map<String,PricebookEntry> priceBookEntryMap = New Map<String,PricebookEntry>();
                List<Service_Plan_Contract__c> servicePlanConForInsertLst = New List<Service_Plan_Contract__c>();
                
                For(Service_Plan_Contract__c spcRec:[SELECT Id,
                                                     Vehicle_Id__c,
                                                     Country_ISO_Code__c
                                                     FROM 
                                                     Service_Plan_Contract__c 
                                                     WHERE Vehicle_Id__c  IN:newAssetsMap.keyset() AND 
                                                     Is_Active__c = true AND
                                                     Country_ISO_Code__c IN:CountryIsoCode])
                {
                    if(!existingSpcAssetIdMap.containsKey(spcRec.Vehicle_Id__c))
                    {
                        existingSpcAssetIdMap.put(spcRec.Vehicle_Id__c,new set<string>{spcRec.Country_ISO_Code__c}); 
                    }else{
                        existingSpcAssetIdMap.get(spcRec.Vehicle_Id__c).add(spcRec.Country_ISO_Code__c);
                    }
                }
                system.debug('existingSpcAssetIdSet'+existingSpcAssetIdMap);
                Map<Id,Asset> assetMap= New Map<Id,Asset>([ select id,
                                                           Vista_Status__c,
                                                           warranty_start_date__c,
                                                           Account.RecordtypeId,
                                                           Account.Name,
                                                           Account.Owner.AccountId,
                                                           Handover_Date__c,
                                                           Original_Handover_Date__c,
                                                           Account.owner.Country_ISO_Code__c,
                                                           Account.owner.Market__c,
                                                           Account.Country_ISO_Code__c,
                                                           Account.recordType.DeveloperName,
                                                           Account.Region_or_Market__c,
                                                           Derivative__c,
                                                           Derivative__r.Service_Plan__c,
                                                           Derivative__r.Service_Plan__r.Months__c,
                                                           Derivative__r.Service_Plan__r.Miles_Kilometers__c,
                                                           Derivative__r.Service_Plan__r.Service_Interval_Distance__c,
                                                           Derivative__r.Service_Plan__r.Service_Interval_Time__c,
                                                           Derivative__r.Service_Plan__r.Number_of_Services__c,
                                                           CurrencyIsoCode
                                                           from Asset 
                                                           where ID IN:newAssetsMap.keyset() AND
                                                           //ID NOT IN:existingSpcAssetIdSet AND
                                                           (Account.owner.Country_ISO_Code__c!=null OR
                                                            Account.Country_ISO_Code__c!=null) AND
                                                           (Account.owner.Country_ISO_Code__c IN:CountryIsoCode OR
                                                            Account.Country_ISO_Code__c IN:CountryIsoCode) AND
                                                           Derivative__c !=null AND
                                                           Original_Handover_Date__c != null AND
                                                           Derivative__r.Service_Plan__c !=null AND 
                                                           Derivative__r.Service_Plan__r.IsActive=true AND
                                                           Derivative__r.Service_Plan__r.Service_Plan_Type__c='Complimentary Service']);
                
                system.debug('assetMap'+assetMap);
                for(Asset newAsset:assetMap.values())
                {
                    if((oldAssetMap==null
                        || (oldAssetMap!=null && newAsset.Vista_Status__c !=oldAssetMap.get(newAsset.Id).Vista_Status__c))
                       && newAsset.Vista_Status__c !=null
                       && newAsset.Vista_Status__c.toUpperCase()=='CUSTOMER HANDOVER'
                       &&assetMap.get(newAsset.id).Account.Country_ISO_Code__c!='BR' //added 08/12/2022 to prevent auto create of spc for brazil
                       && (!existingSpcAssetIdMap.containsKey(newAsset.id) || 
                           (existingSpcAssetIdMap.containsKey(newAsset.id) && 
                            !existingSpcAssetIdMap.get(newAsset.id).contains(assetMap.get(newAsset.id).Account.recordType.DeveloperName =='Retailer' ? assetMap.get(newAsset.id).Account.Country_ISO_Code__c : assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c!=null ?assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c:assetMap.get(newAsset.id).Account.Country_ISO_Code__c)))
                      )
                    {
                        system.debug('inside');
                        servicePlanIdSet.add(assetMap.get(newAsset.id).Derivative__r.Service_Plan__c);
                        assetCountryIsoSet.add(assetMap.get(newAsset.id).Account.recordType.DeveloperName =='Retailer' ? assetMap.get(newAsset.id).Account.Country_ISO_Code__c : assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c!=null ?assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c:assetMap.get(newAsset.id).Account.Country_ISO_Code__c);
                    }else{
                        assetMap.remove(newAsset.id);
                    }
                }
                
                system.debug('servicePlanIdSet --> '+servicePlanIdSet);
                system.debug('assetCountryIsoSet --> '+assetCountryIsoSet); 
                if(!servicePlanIdSet.isEmpty())
                {
                    
                    for(PricebookEntry pbe :[SELECT Product2Id, 
                                             Pricebook2Id, 
                                             PriceBook2.Country_ISO_Code__c,
                                             CurrencyIsoCode,
                                             UnitPrice 
                                             from PricebookEntry 
                                             WHERE Product2Id IN : servicePlanIdSet AND 
                                             IsActive = TRUE AND 
                                             PriceBook2.Country_ISO_Code__c IN:assetCountryIsoSet])
                    {
                        priceBookEntryMap.put(pbe.Product2Id+pbe.PriceBook2.Country_ISO_Code__c, pbe); 
                    }
                    
                    string assetCountry;
                    if(!priceBookEntryMap.isEmpty())
                    {
                        for(asset currentAset:assetMap.values())
                        {
                            assetCountry= currentAset.Account.recordType.DeveloperName =='Retailer' ? currentAset.Account.Country_ISO_Code__c: currentAset.Account.owner.Country_ISO_Code__c!=null ? currentAset.Account.owner.Country_ISO_Code__c:currentAset.Account.Country_ISO_Code__c;
                            if(priceBookEntryMap.containsKey(currentAset.Derivative__r.Service_Plan__c+assetCountry))
                            {
                                Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
                                spc.Vehicle_Id__c=currentAset.Id;
                                if( currentAset.warranty_start_date__c != null){
                                    spc.Start_Date__c = currentAset.warranty_start_date__c;
                                }else{
                                    spc.Start_Date__c = currentAset.Original_Handover_Date__c;
                                }
                                
                                if( currentAset.Derivative__r.Service_Plan__r.Months__c != null &&  spc.Start_Date__c != null){
                                    spc.End_Date__c = spc.Start_Date__c.addMonths(currentAset.Derivative__r.Service_Plan__r.Months__c.intValue()).addDays(-1);
                                    spc.Contract_Term_Months__c = currentAset.Derivative__r.Service_Plan__r.Months__c.intValue();
                                } 
                                spc.Service_Plan_Product__c=currentAset.Derivative__r.Service_Plan__c;
                                spc.Assignment_Type__c = 'Complimentary';
                                spc.Country_ISO_Code__c=assetCountry;
                                spc.CurrencyIsoCode=priceBookEntryMap.get(currentAset.Derivative__r.Service_Plan__c+assetCountry).CurrencyIsoCode;
                                spc.Service_Interval_Distance__c=currentAset.Derivative__r.Service_Plan__r.Service_Interval_Distance__c;
                                spc.Service_Interval_Time__c=currentAset.Derivative__r.Service_Plan__r.Service_Interval_Time__c;
                                spc.Number_of_Services__c=currentAset.Derivative__r.Service_Plan__r.Number_of_Services__c;
                                spc.Market__c=currentAset.Account.Owner.Market__c !=null ?currentAset.Account.Owner.Market__c: currentAset.Account.Region_or_Market__c;
                                spc.Retailer_Id__c=currentAset.Account.RecordtypeId == retailerRecordTypeId ? currentAset.AccountId :currentAset.Account.Owner.AccountId;
                                
                                spc.Retailer_Name__c = currentAset.Account.Name;
                                spc.Purchased_Date__c = system.today();
                                spc.Sold_By__c = loggedUser.Name;
                                spc.Activated_By__c = loggedUser.Id;
                                spc.Assignment_Type__c = 'Complimentary';
                                //Added by sreeni
                                if(spc.Assignment_Type__c == 'Complimentary'){
                                    spc.Sold_By__c = null;
                                    spc.Retail_Purchase_Price__c = null;
                                }
                                spc.Country_ISO_Code__c=assetCountry;
                                spc.CurrencyIsoCode=currentAset.CurrencyIsoCode;
                                spc.Market__c=currentAset.Account.Owner.Market__c !=null ?currentAset.Account.Owner.Market__c: currentAset.Account.Region_or_Market__c;
                                spc.Retailer_Id__c=currentAset.Account.RecordtypeId == retailerRecordTypeId ? currentAset.AccountId :currentAset.Account.Owner.AccountId;                                
                                servicePlanConForInsertLst.add(spc);
                            }
                        } 
                    }
                    
                    if(!servicePlanConForInsertLst.isEmpty()){
                        system.debug('servicePlanConForInsertLst'+servicePlanConForInsertLst);
                        Database.SaveResult[] srList = database.insert(servicePlanConForInsertLst,false);
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted ID: ' + sr.getId());
                            }
                            else {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }
                }
            }
            CreateNewServiceContractRun = false;
        }
    }
    
    public void CreateNewOwnerAssetRoles(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap)
    {
        AssetRoleSetterNew assetRoleSetters = new AssetRoleSetterNew();
        
        if(!AssetHandler.CreateNewAssetRoleRun) {
            
            assetRoleSetters.SetOwnerAssetRoles(currentAssets, oldAssetMap);
            AssetHandler.CreateNewAssetRoleRun = true;
        }
    }
    
    public void assetFieldUpdates(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap)
    {   Asset oldRec;
     Map<Id,Account> asstAccMap = New Map<Id,Account>();
     set<Id> assetAccIdSet = New Set<Id>();
     Account asstAccount;
     Map<string, string> imsMap = new Map<string, string> ();
     for(MENA_IMS_Processing__mdt ims : [select id, label, Developername from MENA_IMS_Processing__mdt])
     {
         imsMap.put(ims.Developername, ims.label);
     }
     for(asset newRec:currentAssets)
     {
         newRec.IMS_Processing__c = imsMap.containskey(newRec.AccountCountryCode__c)? true : false;
         if(oldAssetMap!=null && oldAssetMap.containsKey(newRec.Id))
             oldRec=oldAssetMap.get(newRec.Id);
         if( (oldAssetMap==null) 
            || (oldAssetMap !=null && newRec.accountId != oldRec.accountId )
            && newRec.accountId !=null)
             assetAccIdSet.add(newRec.accountId);
         //CXPD-731 : Deepthi-NTT DATA
         if(((oldRec == null && newRec.APO_Stock_Status__c == 'Retail') || (newRec.APO_Stock_Status__c == 'Retail' && oldRec.APO_Stock_Status__c != 'Retail')) && newRec.IMS_Processing__c )
             newRec.Status = 'For Sale';
         
         
     }
     
     if(!assetAccIdSet.isEmpty())
         asstAccMap= New Map<Id,Account>([select Id,Is_Primary__c, Primary_Account__c,OwnerId From Account Where ID IN:assetAccIdSet AND (Primary_Account__c !=null OR Is_Primary__c=true )]);
     
     for(asset newRec:currentAssets)
     {
         if((oldAssetMap==null) || 
            (oldAssetMap !=null && newRec.accountId !=oldRec.accountId)
           )
         {
             newRec.Primary_Account__c=null;
             if( newRec.accountId !=null && asstAccMap.containsKey(newRec.accountId)){
                 newRec.Primary_Account__c= asstAccMap.get(newRec.accountId).Is_Primary__c ? newRec.accountId : asstAccMap.get(newRec.accountId).Primary_Account__c;
                 
             }
         }
     }
     
    }
    //Modified By:Tamanna @Marlabs Private Limited ||Added Date : 25/8/2020
    //Added the calling  of VME claim generation process in the AssetHandler as Suggested by the CXP Team
    public void vmeClaimGenerationBeforeUpdate(Map<Id, Asset> newAssetMap, Map<Id, Asset> oldAssetMap,List<Asset> currentAssets,List<Asset> oldAssets){
        VME_Generate_Claims_Trigger_Handler generateClaimsHelper = new VME_Generate_Claims_Trigger_Handler();
        Map<Id, Asset> newMap =new Map<Id, Asset>();
        Map<Id, Asset> oldMap =new Map<Id, Asset>();
        List<Asset> newList =new List<Asset>();
        for(Asset asst :currentAssets){
            if(asst.Retailer_Name__c!=null && asst.VME_Retailer_Country_Code__c !=null &&  asst.VME_Retailer_Country_Code__c=='IN'){
                newMap.put(asst.Id,asst);
                oldMap.put(asst.Id,oldAssetMap.get(asst.Id));
                newList.add(asst);
            }
        }
        if(newMap !=null && !newMap.isEmpty())
            generateClaimsHelper.onBeforeUpdate(newMap,oldMap, newList, oldAssets);
    }
    
    //Modified By:Tamanna @Marlabs Private Limited ||Added Date : 25/8/2020
    //Added the calling  of VME claim generation process in the AssetHandler as Suggested by the CXP Team
    public void vmeClaimGenerationAfterUpdate(Map<Id, Asset> newAssetMap, Map<Id, Asset> oldAssetMap,List<Asset> currentAssets,List<Asset> oldAssets){
        VME_Generate_Claims_Trigger_Handler generateClaimsHelper = new VME_Generate_Claims_Trigger_Handler();
        Map<Id, Asset> newMap =new Map<Id, Asset>();
        Map<Id, Asset> oldMap =new Map<Id, Asset>();
        List<Asset> newList =new List<Asset>();
        for(Asset asst :currentAssets){
            if(asst.Retailer_Name__c!=null && asst.VME_Retailer_Country_Code__c !=null &&  asst.VME_Retailer_Country_Code__c=='IN'){
                newMap.put(asst.Id,asst);
                oldMap.put(asst.Id,oldAssetMap.get(asst.Id));
                newList.add(asst);
            }
        }
        if(newMap !=null && !newMap.isEmpty())
            generateClaimsHelper.onAfterUpdate(newMap,oldMap, newList, oldAssets);
    }
    
    public void postUpdate(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap){     
        if(!IgnoreMMIT){
            system.debug('IgnoreMMIT --> '+IgnoreMMIT);
            MMIT_OpportunityInfoSetter_Asset_F mmitOpportunityInfoSetterFactory = new MMIT_OpportunityInfoSetter_Asset_F();
            MMIT_OpportunityInfoSetter_Asset mmitOpportunityInfoSetter = mmitOpportunityInfoSetterFactory.Create();
            mmitOpportunityInfoSetter.SetVehicleInfo(currentAssets, oldAssetMap);
        }
        AssetOppUpdateHandler.ProcessOpportunityHandoverUpdate(currentAssets,oldAssetMap);
       
    }
    
    public void CreateNewServiceContractNewMarket(Map<Id,Asset> newAssetsMap, Map<Id, Asset> oldAssetMap){
        system.debug('CreateNewServiceContractNewMarketRun --> '+CreateNewServiceContractNewMarketRun);
        if(CreateNewServiceContractNewMarketRun){
            If(string.isNotBlank(system.label.CXP_AUTO_SPC_ON_HANDOVER_New) && 
               string.isNotEmpty(system.label.CXP_AUTO_SPC_ON_HANDOVER_New)){
                   Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
                   List<string> CountryIsoCode= system.label.CXP_AUTO_SPC_ON_HANDOVER_New.split(';');
                   Map<Id,set<string>> existingSpcAssetIdMap = New Map<Id,set<string>>();
                   map<Id,serviceplanWrap> serviceplanWrapMap = new map<Id,serviceplanWrap>();
                   List<Service_Plan_Contract__c> servicePlanConForInsertLst = New List<Service_Plan_Contract__c>();
                   
                   For(Service_Plan_Contract__c spcRec:[SELECT Id,
                                                        Vehicle_Id__c,
                                                        Country_ISO_Code__c
                                                        FROM 
                                                        Service_Plan_Contract__c 
                                                        WHERE Vehicle_Id__c  IN:newAssetsMap.keyset() AND 
                                                        Country_ISO_Code__c IN:CountryIsoCode]){
                                                            if(!existingSpcAssetIdMap.containsKey(spcRec.Vehicle_Id__c)){
                                                                existingSpcAssetIdMap.put(spcRec.Vehicle_Id__c,new set<string>{spcRec.Country_ISO_Code__c}); 
                                                            }else{
                                                                existingSpcAssetIdMap.get(spcRec.Vehicle_Id__c).add(spcRec.Country_ISO_Code__c);
                                                            }
                                                        }
                   
                   system.debug('newAssetsMap.keyset() --> '+json.serializePretty(newAssetsMap.keyset()));
                   system.debug('CountryIsoCode --> '+json.serializePretty(CountryIsoCode));
                   
                   Map<Id,Asset> assetMap= New Map<Id,Asset>([ select id,
                                                              VIN__c,
                                                              Vista_Status__c,
                                                              warranty_start_date__c,
                                                              Account.RecordtypeId,
                                                              Account.Owner.AccountId,
                                                              Account.Name,
                                                              Handover_Date__c,
                                                              Original_Handover_Date__c,
                                                              Account.owner.Country_ISO_Code__c,
                                                              Account.owner.Market__c,
                                                              Account.Country_ISO_Code__c,
                                                              Account.recordType.DeveloperName,
                                                              Account.Region_or_Market__c,
                                                              Model__c,
                                                              Brand__c,
                                                              Has_been_a_Rental__c
                                                              from Asset 
                                                              where ID IN:newAssetsMap.keyset() AND
                                                              (Account.owner.Country_ISO_Code__c!=null OR
                                                               Account.Country_ISO_Code__c!=null) AND
                                                              (Account.owner.Country_ISO_Code__c IN:CountryIsoCode OR
                                                               Account.Country_ISO_Code__c IN:CountryIsoCode) AND
                                                              Brand__c != null AND
                                                              Model__c != null AND     
                                                              Original_Handover_Date__c != null AND
                                                              Country_ISO_Code__c != null]);
                   
                   system.debug('assetMap --> '+json.serializePretty(assetMap));
                   System.debug('assetMap -->'+assetMap);
                   for(Asset newAsset:assetMap.values()){
                       //   system.debug('1 -->'+assetMap.get(newAsset.id).Account.Country_ISO_Code__c);
                       //  system.debug('2 -->'+assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c);
                       //  system.debug('3 -->'+assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c);
                       //  system.debug('4 -->'+assetMap.get(newAsset.id).Account.Country_ISO_Code__c);
                         System.debug('newAsset -->'+newAsset);
                         System.debug('oldAssetMap -->'+oldAssetMap);
                       if((oldAssetMap==null
                           || (oldAssetMap!=null && newAsset.Vista_Status__c !=oldAssetMap.get(newAsset.Id).Vista_Status__c))
                          && newAsset.Vista_Status__c !=null
                          && newAsset.Vista_Status__c.toUpperCase()=='CUSTOMER HANDOVER'
                          && (!existingSpcAssetIdMap.containsKey(newAsset.id) || 
                              (existingSpcAssetIdMap.containsKey(newAsset.id) && 
                               !existingSpcAssetIdMap.get(newAsset.id).contains(
                                   assetMap.get(newAsset.id).Account.recordType.DeveloperName =='Retailer' ? assetMap.get(newAsset.id).Account.Country_ISO_Code__c 
                                   : assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c!=null ?assetMap.get(newAsset.id).Account.owner.Country_ISO_Code__c
                                   :assetMap.get(newAsset.id).Account.Country_ISO_Code__c)))
                         ) {
                             serviceplanWrap spcWrap = new serviceplanWrap();
                             spcWrap.brandId = newAsset.Brand__c;
                             spcWrap.modelId = newAsset.Model__c;
                             spcWrap.assetId = newAsset.Id;
                             spcWrap.BrandAndModel = newAsset.Brand__c+'-'+newAsset.Model__c+'-'+newAsset.Account.Country_ISO_Code__c;
                             spcWrap.market = newAsset.Account.Country_ISO_Code__c;
                             serviceplanWrapMap.put(spcWrap.brandId,spcWrap);
                         }
                   }
                   
                   // system.debug('serviceplanWrapMap --> '+json.serializePretty(serviceplanWrapMap));
                     System.debug('serviceplanWrapMap -->'+serviceplanWrapMap);
                   if(serviceplanWrapMap != null
                      && !serviceplanWrapMap.isEmpty()){
                          map<Id,Service_Plans_Model__c> assetServicePlanMap = new map<Id,Service_Plans_Model__c>();
                          for(Service_Plans_Model__c spm : [select 
                                                            id,Auto_Add_Extended_Plan__c,Brand__c,Complementary_Service_Plan__c,
                                                            Complementary_Service_Plan__r.Months__c,
                                                            Complementary_Service_Plan__r.CurrencyIsoCode,
                                                            Complementary_Service_Plan__r.Service_Interval_Distance__c,
                                                            Complementary_Service_Plan__r.Service_Interval_Time__c,
                                                            Complementary_Service_Plan__r.Number_of_Services__c,
                                                            Complementary_Service_Plan__r.Mileage_Months__c,                                                            
                                                            Complementary_Service_Plan__r.Mileage_Measure__c,
                                                            Complementary_Service_Plan__r.Service_Plan_Type__c,
                                                            Complementary_Service_Plan__r.Miles_Kilometers__c,
                                                            
                                                            Extended_Service_Plan__r.Months__c,
                                                            Extended_Service_Plan__r.CurrencyIsoCode,
                                                            Extended_Service_Plan__r.Service_Interval_Distance__c,
                                                            Extended_Service_Plan__r.Service_Interval_Time__c,
                                                            Extended_Service_Plan__r.Number_of_Services__c,
                                                            Extended_Service_Plan__r.Mileage_Months__c,                                                            
                                                            Extended_Service_Plan__r.Mileage_Measure__c,
                                                            Extended_Service_Plan__r.Service_Plan_Type__c, 
                                                            Extended_Service_Plan__r.Miles_Kilometers__c,
                                                            Extended_Service_Plan__c,
                                                            Model__c,
                                                            Region_or_Market__c
                                                            
                                                            FROM Service_Plans_Model__c
                                                            WHERE Brand__c IN: serviceplanWrapMap.keyset()
                                                            AND Brand__c != null
                                                            AND Complementary_Service_Plan__r.IsActive = true
                                                            AND (Complementary_Service_Plan__c != null OR Extended_Service_Plan__c != null)
                                                            AND Region_or_Market__c != null
                                                            AND Model__c != null]){
                                                                if(serviceplanWrapMap.containskey(spm.Brand__c)
                                                                   && serviceplanWrapMap.get(spm.Brand__c).BrandAndModel != null
                                                                   && serviceplanWrapMap.get(spm.Brand__c).assetId != null){
                                                                       String brandAndModel = serviceplanWrapMap.get(spm.Brand__c).BrandAndModel;
                                                                       if(brandAndModel ==  (spm.Brand__c+'-'+spm.Model__c+'-'+spm.Region_or_Market__c)){
                                                                           String assetId = serviceplanWrapMap.get(spm.Brand__c).assetId;
                                                                           assetServicePlanMap.put(assetId,spm);
                                                                       }
                                                                   }
                                                            }
                          
                          system.debug('assetServicePlanMap --> '+json.serializePretty(assetServicePlanMap));
                          if(assetServicePlanMap != null
                             && !assetServicePlanMap.isEmpty()){
                                 string assetCountry;
                                 map<String,PriceBookEntry> pbeMap = new map<String,PriceBookEntry>();
                                 for(PriceBookEntry pbe : [select id, Product2Id, UnitPrice,CurrencyIsoCode  
                                                           from PriceBookEntry 
                                                           where 
                                                           priceBook2.IsActive=true AND IsActive=true AND priceBook2.Country_Iso_Code__c IN: CountryIsoCode]){
                                                               pbeMap.put(pbe.Product2Id+'-'+priceBook2.Country_Iso_Code__c,pbe);     
                                                           }
                                 User loggedUser = [SELECT Id,Name,Market__c,ContactId,Country_ISO_Code__c, profile.Name,Contact.Account.Country_ISO_Code__c,Contact.AccountId,Contact.Account.Name FROM User WHERE Id =: UserInfo.getUserId() limit 1];
                                 for(id assetId : assetServicePlanMap.keyset()){
                                     if(assetMap.containskey(assetId)){
                                         system.debug('inside block');
                                         Asset currentAset = assetMap.get(assetId);
                                         Service_Plans_Model__c spm = assetServicePlanMap.get(assetId);
                                         Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
                                         Service_Plan_Contract__c extSpc = new Service_Plan_Contract__c();
                                         system.debug('spm'+spm);
                                         if(spm.Complementary_Service_Plan__c != null){
                                             assetCountry= currentAset.Account.recordType.DeveloperName =='Retailer' ? currentAset.Account.Country_ISO_Code__c: currentAset.Account.owner.Country_ISO_Code__c!=null ? currentAset.Account.owner.Country_ISO_Code__c:currentAset.Account.Country_ISO_Code__c;
                                             
                                             spc.Vehicle_Id__c=currentAset.Id;
                                             system.debug('currentAset.warranty_start_date__c'+currentAset.warranty_start_date__c);
                                             if( currentAset.warranty_start_date__c != null){
                                                 spc.Start_Date__c = currentAset.warranty_start_date__c;
                                             }else{
                                                system.debug('inside');
                                                 spc.Start_Date__c = currentAset.Original_Handover_Date__c;
                                             }
                                             system.debug('Start_Date__c'+spc.Start_Date__c);
                                             if(spc.Start_Date__c != null){
                                                 spc.End_Date__c = spc.Start_Date__c.addMonths(spm.Complementary_Service_Plan__r.Months__c.intValue()).addDays(-1);
                                                 spc.Contract_Term_Months__c = spm.Complementary_Service_Plan__r.Months__c.intValue();
                                             } 
                                             
                                             if(pbeMap.containsKey(spm.Complementary_Service_Plan__c+'-'+currentAset.Account.Country_ISO_Code__c)){
                                                 spc.Retail_Purchase_Price__c = pbeMap.get(spm.Complementary_Service_Plan__c+'-'+currentAset.Account.Country_ISO_Code__c).UnitPrice;
                                             }
                                             spc.Retailer_Name__c = currentAset.Account.Name;
                                             spc.Purchased_Date__c = system.today();
                                             spc.Sold_By__c = loggedUser.Name;
                                             spc.Activated_By__c = loggedUser.Id;
                                             spc.Service_Plan_Product__c = spm.Complementary_Service_Plan__c;
                                             spc.Assignment_Type__c = 'Complimentary';
                                             spc.Country_ISO_Code__c=assetCountry;
                                             spc.CurrencyIsoCode=spm.Complementary_Service_Plan__r.CurrencyIsoCode;
                                             spc.Service_Interval_Distance__c=spm.Complementary_Service_Plan__r.Service_Interval_Distance__c;
                                             spc.Service_Interval_Time__c=spm.Complementary_Service_Plan__r.Service_Interval_Time__c;
                                             spc.Number_of_Services__c=spm.Complementary_Service_Plan__r.Number_of_Services__c;
                                             spc.Market__c=currentAset.Account.Owner.Market__c !=null ?currentAset.Account.Owner.Market__c: currentAset.Account.Region_or_Market__c;
                                             spc.Retailer_Id__c=currentAset.Account.RecordtypeId == retailerRecordTypeId ? currentAset.AccountId :currentAset.Account.Owner.AccountId;
                                             spc.Auto_Added__c = true;
                                             if(spc.Assignment_Type__c == 'Complimentary'){
                                                 spc.Sold_By__c = null;
                                                 spc.Retail_Purchase_Price__c = null;
                                             }
                                             spc.Mileage_Months_SPC__c = spm.Complementary_Service_Plan__r.Mileage_Months__c;
                                             if(spm.Complementary_Service_Plan__r.Miles_Kilometers__c != null && spm.Complementary_Service_Plan__r.Mileage_Measure__c != null){
                                                 spc.Mileage_SPC__c = String.valueOf(spm.Complementary_Service_Plan__r.Miles_Kilometers__c)+' '+String.valueOf(spm.Complementary_Service_Plan__r.Mileage_Measure__c);
                                             }
                                             spc.Months_spc__c = spm.Complementary_Service_Plan__r.Months__c;
                                             spc.Service_Plan_Type_SPC__c = spm.Complementary_Service_Plan__r.Service_Plan_Type__c;
                                             if(spc.Vehicle_Id__c != null && currentAset.VIN__c != null){
                                                 spc.Service_Plan_Reference_spc__c = currentAset.VIN__c.mid(3,2)+'-CXP-'+currentAset.VIN__c.right(6);//+'-'+spc.Service_Plan_Incremental__c
                                             }
                                             if(spc.End_Date__c != null && spc.Start_Date__c != null){
                                                 spc.Service_Plan_Length_Check_SPC__c = (spc.Start_Date__c.daysBetween(spc.End_Date__c))/365;
                                             }
                                             servicePlanConForInsertLst.add(spc);
                                         }
                                         // system.debug('servicePlanConForInsertLst --> '+json.serializePretty(servicePlanConForInsertLst));
                                         if(spm.Extended_Service_Plan__c != null 
                                            && spm.Auto_Add_Extended_Plan__c){
                                                assetCountry= currentAset.Account.recordType.DeveloperName =='Retailer' ? currentAset.Account.Country_ISO_Code__c: currentAset.Account.owner.Country_ISO_Code__c!=null ? currentAset.Account.owner.Country_ISO_Code__c:currentAset.Account.Country_ISO_Code__c;
                                                
                                                extSpc.Vehicle_Id__c=currentAset.Id;
                                                if(spc.End_Date__c != null){
                                                    extSpc.Start_Date__c = spc.End_Date__c+1;
                                                }else{
                                                    extSpc.Start_Date__c = currentAset.Original_Handover_Date__c;
                                                }
                                                
                                                if(extSpc.Start_Date__c != null){
                                                    extSpc.End_Date__c = extSpc.Start_Date__c.addMonths(spm.Extended_Service_Plan__r.Months__c.intValue()).addDays(-1);
                                                    extSpc.Contract_Term_Months__c = spm.Extended_Service_Plan__r.Months__c.intValue();
                                                } 
                                                
                                                // if(pbeMap.containsKey(spm.Extended_Service_Plan__c+'-'+currentAset.Account.Country_ISO_Code__c)){
                                                //     extSpc.Retail_Purchase_Price__c = pbeMap.get(spm.Extended_Service_Plan__c+'-'+currentAset.Account.Country_ISO_Code__c).UnitPrice;
                                                // }
                                                extSpc.Retail_Purchase_Price__c = null;
                                                extSpc.Retailer_Name__c = currentAset.Account.Name;
                                                extSpc.Purchased_Date__c = system.today();
                                                extSpc.Sold_By__c = loggedUser.Name;
                                                extSpc.Activated_By__c = loggedUser.Id;
                                                extSpc.Service_Plan_Product__c = spm.Extended_Service_Plan__c;
                                                extSpc.Assignment_Type__c = 'Extended';
                                                extSpc.Country_ISO_Code__c=assetCountry;
                                                extSpc.CurrencyIsoCode=spm.Extended_Service_Plan__r.CurrencyIsoCode;
                                                extSpc.Service_Interval_Distance__c=spm.Extended_Service_Plan__r.Service_Interval_Distance__c;
                                                extSpc.Service_Interval_Time__c=spm.Extended_Service_Plan__r.Service_Interval_Time__c;
                                                extSpc.Number_of_Services__c=spm.Extended_Service_Plan__r.Number_of_Services__c;
                                                extSpc.Market__c=currentAset.Account.Owner.Market__c !=null ?currentAset.Account.Owner.Market__c: currentAset.Account.Region_or_Market__c;
                                                extSpc.Retailer_Id__c=currentAset.Account.RecordtypeId == retailerRecordTypeId ? currentAset.AccountId :currentAset.Account.Owner.AccountId;
                                                extSpc.Auto_Added__c = true;
                                                
                                                extSpc.Mileage_Months_SPC__c = spm.Extended_Service_Plan__r.Mileage_Months__c;
                                                if(spm.Extended_Service_Plan__r.Miles_Kilometers__c != null && spm.Extended_Service_Plan__r.Mileage_Measure__c != null){
                                                    extSpc.Mileage_SPC__c = String.valueOf(spm.Extended_Service_Plan__r.Miles_Kilometers__c)+' '+String.valueOf(spm.Extended_Service_Plan__r.Mileage_Measure__c);
                                                }
                                                extSpc.Months_spc__c = spm.Extended_Service_Plan__r.Months__c;
                                                extSpc.Service_Plan_Type_SPC__c = spm.Extended_Service_Plan__r.Service_Plan_Type__c;
                                                if(extSpc.Vehicle_Id__c != null && currentAset.VIN__c != null){
                                                    extSpc.Service_Plan_Reference_spc__c = currentAset.VIN__c.mid(3,2)+'-CXP-'+currentAset.VIN__c.right(6); //+'-'+extSpc.Service_Plan_Incremental__c
                                                }
                                                if(extSpc.End_Date__c != null && extSpc.Start_Date__c != null){
                                                    extSpc.Service_Plan_Length_Check_SPC__c = (extSpc.Start_Date__c.daysBetween(extSpc.End_Date__c))/365;
                                                }
                                                
                                                servicePlanConForInsertLst.add(extSpc);
                                            }
                                     }
                                 }
                                 
                                 //  system.debug('servicePlanConForInsertLst --> '+json.serializePretty(servicePlanConForInsertLst));
                                 if(servicePlanConForInsertLst != null 
                                    && !servicePlanConForInsertLst.isEmpty()){
                                        Database.SaveResult[] srList =   database.insert(servicePlanConForInsertLst,false);
                                        for (Database.SaveResult sr : srList) {
                                            if (sr.isSuccess()) {
                                                // Operation was successful, so get the ID of the record that was processed
                                                System.debug('Successfully inserted ID: ' + sr.getId());
                                            }
                                            else {
                                                // Operation failed, so get all errors                
                                                for(Database.Error err : sr.getErrors()) {
                                                    System.debug('The following error has occurred.');                    
                                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                    System.debug('fields that affected this error: ' + err.getFields());
                                                }
                                            }
                                        }
                                        
                                        List<Service_Plan_Contract__c> servicePlanConForUpdateLst = New List<Service_Plan_Contract__c>();
                                        set<id> servicePlanIDsSet = new set<id>();
                                        for(Service_Plan_Contract__c spc : servicePlanConForInsertLst){
                                            if(spc.Id != null){
                                                servicePlanIDsSet.add(spc.Id);
                                            }
                                        }
                                        if(servicePlanIDsSet != null && !servicePlanIDsSet.isEmpty()){
                                            for(Service_Plan_Contract__c spc : [select id,Service_Plan_Reference_spc__c,Service_Plan_Incremental__c,Service_Plan_Length_Check_SPC__c,Service_Plan_Length_Check__c 
                                                                                from Service_Plan_Contract__c where id in:servicePlanIDsSet]){
                                                                                    if(spc.Service_Plan_Reference_spc__c != null){
                                                                                        spc.Service_Plan_Reference_spc__c  = spc.Service_Plan_Reference_spc__c+'-'+spc.Service_Plan_Incremental__c;
                                                                                    }
                                                                                    if(spc.Service_Plan_Length_Check__c != null){
                                                                                        spc.Service_Plan_Length_Check_SPC__c = spc.Service_Plan_Length_Check__c;
                                                                                    }
                                                                                    servicePlanConForUpdateLst.add(spc);
                                                                                }
                                            if(servicePlanConForUpdateLst != null && !servicePlanConForUpdateLst.isEmpty()){
                                                database.update(servicePlanConForUpdateLst,false);
                                            } 
                                        }
                                    }
                             }
                      }
               }
            CreateNewServiceContractNewMarketRun = false;
        }
    }
    
    private void populateChangedRecordTypes(List<Asset> newAssets) {
        for(Asset a : newAssets) {
            if(a.RecordTypeId == vehcileOptionRecordTypeId) {
                vehicleOptions.add(a);
            } else {
                vehicles.add(a);
            }
        }
    }

    private void setVehicleOptionDefaults(List<Asset> newAssets) {
        
        Set<Id> parentAssetIds = new Set<Id>();
        Set<Id> parentProductIds = new Set<Id>();
        
        for(Asset a : newAssets) {
            if(a.RecordTypeId != vehcileOptionRecordTypeId) {
                continue;
            }
            if(a.ParentId != null) {
                parentAssetIds.add(a.ParentId);
            }
            if(a.Product2Id != null) {
                parentProductIds.add(a.Product2Id);
            }
        }
        if(parentAssetIds.size() == 0) {
            return;
        }

        Map<Id, Asset> parentAssets = new Map<Id, Asset>([SELECT Id, AccountId, OwnerId, Brand__c FROM Asset WHERE Id IN :parentAssetIds]);
        Map<Id, Product2> parentProducts = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE ID IN :parentProductIds ]);
        for(Asset a : newAssets) {
            if(parentAssetIds.contains(a.ParentId )) {
                Asset parentAsset  = parentAssets.get(a.ParentId);
                a.AccountId = parentAsset.AccountId;
                a.Brand__c = parentAsset.Brand__c;
                a.OwnerId = parentAsset.OwnerId;
            }
            if(parentProductIds.contains(a.Product2Id)) {
                Product2 parentProduct = parentProducts.get(a.Product2Id);
                a.Name = parentProduct.Name;
            }

        }

    }
    
    public class serviceplanWrap{
        public Id brandId;
        public Id modelId;
        public Id assetId;
        public String BrandAndModel;
        public String market;
    }
    
}
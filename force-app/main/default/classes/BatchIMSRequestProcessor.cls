global class BatchIMSRequestProcessor implements Database.batchable<sObject>, Database.Stateful 
{
    String Query;
    public class CustomException extends Exception {}

    Static final String UNPROCESSED_STATUSES = Label.IMS_BATCH_UNPROCESSED_STATUSES;
    Static final String NOTIFICATION_EMAILS = Label.IMS_BATCH_NOTIFICATION_EMAILS; 

    String EmailReportContentErrors='', EmailReportContentSuccesses='';
    Integer AssetsCreated=0,AssetsUpdated=0,ProductsCreated=0,ProductsUpdated=0,SOQLcount = 0;
    Map<String,String> mapCountries = new Map<String,String>();      
    Map<String,Vehicle_Specification__c> mapVehicleSpecsMake = new Map<String,Vehicle_Specification__c>(); 
    Map<String,Id> mapRecordTypes = new Map<String,Id>();
    Map<String,Colour_Group_Mapping__c > ColourGroup = Colour_Group_Mapping__c.getAll(); 
    //Map<String,Id> mapAllDerivatives = new Map <String,Id>();
    List<Account> MigratedVehicleAccounts = new List<Account>();
    List<Account> AllRetailers = new List<Account>();  
    public enum UPDATE_TYPES{AlwaysUpdate,OnlyIfDifferent,OnlyIfTargetNull}
    Static final UPDATE_TYPES UPDATE_TYPE = UPDATE_TYPES.AlwaysUpdate; 
    List<string> IsoCountryCodeLst= New List<string>();
    string countryCode='';
    
    global BatchIMSRequestProcessor(string countryCode) {  
        this.countryCode=countryCode;
        if(string.isNotEmpty(countryCode) && string.isNotBlank(countryCode))
            IsoCountryCodeLst=countryCode.split(';');
        
        try {
            mapCountries = getCountries();
            mapVehicleSpecsMake = getVehicleSpecs('Make');
            mapRecordTypes = getRecordTypes();
            //mapAllDerivatives = getAllDerivatives();
            MigratedVehicleAccounts = getMigratedVehiclesAccounts();
            AllRetailers = getRetailers();
        } catch (Exception e) {
            EmailReportContentErrors+='CRITICAL ERROR: Batch job has failed to pre-load datasets into memory needed for processing rows. STACK TRACE: ' + e.getMessage() + '---' + e.getStackTraceString() + '\n';
        }
        
        query='SELECT X5000_code__c,Asset__c,bodystyle_code__c,bodystyle_value_base__c,bodystyle_value_local__c,ci_code__c,colour_exterior_code__c,';
        query+='channel__c,country_code__c ,drivetrain_code__c,drivetrain_name_base__c,drivetrain_name_local__c,highlighted_base__c,highlighted_local__c,';
        query+='colour_exterior_value_base__c,colour_exterior_value_local__c,colour_interior_code__c,colour_interior_value_base__c,date_stock__c,price_new__c, ';
        query+='colour_interior_value_local__c,country_name__c,country_of_origin__c,currency__c,date_mot_expiry__c,date_registered__c,engine_name_base__c,';
        query+='date_visible_from__c,date_warranty_expiry__c,dealer_address__c,dealer_contact_no__c,dealer_email__c,dealer_gps_coordinates__c,';
        query+='dealer_id__c,dealer_name__c,doors_code__c,doors_value_base__c,doors_value_local__c,drive_code__c,drive_value_base__c,stock_status__c,';
        query+='drive_value_local__c,engine_size_code__c,engine_size_value_base__c,engine_size_value_local__c,features_base__c,features_local__c,';
        query+='fuel_code__c,fuel_value_base__c,fuel_value_local__c,manufacturer__c,model_code__c,model_description_base__c,model_description_local__c,';
        query+='model_value_base__c,model_value_local__c,model_year__c,odometer__c,pic_refs__c,engine_name_local__c, price_retail__c,price_siv__c,price_trade__c, ';
        query+='Processed_Error_Reason__c,Processed_Status__c,Processed_On__c,Product__c,reg_no__c,seats_code__c,seats_value_base__c,seats_value_local__c,';
        query+='stock_number__c,transmission_code__c,transmission_value_base__c,transmission_value_local__c,variant_code__c,variant_value_base__c,';
        query+='variant_value_local__c,vin__c,year_reg__c,additional_registration_fee__c,open_market_value__c,certificate_of_entitlement__c,';
        query+='transmission_meta_base__c,transmission_meta_local__c, wheelbase_code__c,wheelbase_name_base__c,wheelbase_name_local__c,int_material__c,Manufacture_Year__c,Number_IMS_Owners__c ';
        query+='FROM IMS_Request__c where Processed_Status__c IN ( '+UNPROCESSED_STATUSES+' ) and country_code__c IN:IsoCountryCodeLst order by createddate asc';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    { 
        return Database.getQueryLocator(query);
    }  
    
    global void execute(Database.BatchableContext BC, List<IMS_Request__c> IMSRequestData)
    {   
        Set<String> VINs = new Set<String>(); 
        Set<String> ModelCodes = new Set<String>();
        Map<String,String> MapProductCodeToModelCode = new Map<String,String>();
        String errMsg ='';

        for (IMS_Request__c row : IMSRequestData) {
            if (String.isNotEmpty(row.vin__c) && row.vin__c != '0') VINs.add(row.vin__c.toUpperCase());
            if (String.isNotEmpty(row.model_code__c) && row.model_code__c != '0') ModelCodes.add(row.model_code__c); 
            if (String.isNotEmpty(row.X5000_Code__c) && row.X5000_code__c != '0') MapProductCodeToModelCode.put(row.X5000_Code__c,row.model_code__c);
        }
        
        Map<String,Asset> AssetsToUpdate = getAssets(VINs);
        Map<String,Product2> DerivativeProductsToUpdate = getProducts(MapProductCodeToModelCode.KeySet(),'Derivative'); 
        Map<String,Product2> ModelProductsFound = getProducts(ModelCodes,'Model'); 
        
        Asset Vehicle;
        Product2 DerivativeProduct,ModelProduct;
        Id DerivativeProductId,DerivativeId; 
        String DerivativeProductCode;
        
        for (IMS_Request__c row : IMSRequestData) { 

            Vehicle=null;
            DerivativeProduct=null;
            ModelProduct=null;
            DerivativeProductId=null;
            DerivativeId=null;
            DerivativeProductCode=null;
            
            row.Processed_On__c = System.now();
            
            try {   
                
                //********************** MODELS *************************//
                if (String.isNotEmpty(row.model_code__c) && row.model_code__c != '0') {
                    
                    if (!ModelProductsFound.containsKey(row.model_code__c) ) {  
                    
                        //Create missing Model
                        ModelProduct = createModelFromRow(row);
                        insert ModelProduct;
                        ModelProductsFound.put(row.model_code__c,ModelProduct);
                        
                    }

                    ModelProduct = ModelProductsFound.get(row.model_code__c);
                    
                }
                
                //********************** DERIVATIVES *************************//
                if (String.isNotEmpty(row.X5000_code__c) && row.X5000_code__c != '0') { //5000 code is present in CSV file
                    
                    if (DerivativeProductsToUpdate.containsKey(row.X5000_code__c)) { //5000 code is present in CSV file and found in CXP
                        
                        //update product APO fields only   
                        DerivativeProduct = DerivativeProductsToUpdate.get(row.X5000_code__c);
                        row.Product__c = DerivativeProduct.Id; 
                        DerivativeProduct = updateProductFromRow(DerivativeProduct,row); 
                        update DerivativeProduct;
                        row.Processed_Error_Reason__c = null;
                        row.Processed_Status__c = 'Processed';
                        ProductsUpdated++;
                        EmailReportContentSuccesses+='UPDATED PRODUCT '+row.X5000_code__c+': ' + DerivativeProduct.id + ' at row : ' + row.id + '\n';
                        
                    } else { //5000 code is present in CSV file but not found in CXP
                        
                        if (String.isEmpty(row.model_code__c) || row.model_code__c=='0' || ModelProduct==null) { //Model code is either not present in CSV or not found in CXP

                            row.Processed_Status__c = 'Failed';
                            row.Processed_Error_Reason__c = 'Cannot create derivative product '+row.X5000_code__c+'; Model not found for model code: ' + row.model_code__c;
                            EmailReportContentErrors+='SKIPPED PRODUCT '+row.X5000_code__c+' CREATION at row : ' + row.id + '; ERROR: '+row.Processed_Error_Reason__c+'\n';

                        } else {

                            //Create missing derivative using model code provided as parent 
                            DerivativeProduct = createProductFromRow(row,ModelProduct);
                            insert DerivativeProduct;
                            row.Product__c = DerivativeProduct.id;
                            row.Processed_Error_Reason__c = null;
                            row.Processed_Status__c = 'Processed';
                            ProductsCreated++;
                            EmailReportContentSuccesses+='CREATED PRODUCT '+row.X5000_code__c+': ' + DerivativeProduct.id + ' at row : ' + row.id + '\n';

                        } 
                            
                    }    
                    
                } else { //5000 code is not present in CSV
                    if ( AssetsToUpdate.containsKey(row.vin__c.toUpperCase()) ) { //If Asset in CXP matches VIN in CSV

                        DerivativeProductId = AssetsToUpdate.get(row.vin__c.toUpperCase()).Product2id;
                        DerivativeId = AssetsToUpdate.get(row.vin__c.toUpperCase()).Derivative__c;
                        DerivativeProductCode = AssetsToUpdate.get(row.vin__c.toUpperCase()).Description_Group_Id__c;

                        if (DerivativeProductCode != null) { 
                            DerivativeProduct = getSpecificProduct(DerivativeProductCode,true);
                        } else if (DerivativeId != null) {  
                            DerivativeProduct = getSpecificProduct(String.ValueOf(DerivativeId),false); 
                        } else if (DerivativeProductId != null) {  
                            DerivativeProduct = getSpecificProduct(String.ValueOf(DerivativeProductId),false); 
                        } 

                        if (DerivativeProduct!=null) {
                            row.Product__c = DerivativeProduct.Id; 
                            DerivativeProduct = updateProductFromRow(DerivativeProduct,row); 
                            update DerivativeProduct;
                            row.Processed_Error_Reason__c = null;
                            row.Processed_Status__c = 'Processed';
                            ProductsUpdated++;
                            EmailReportContentSuccesses+='UPDATED PRODUCT '+row.X5000_code__c+': ' + DerivativeProduct.id + ' at row : ' + row.id + '\n';
                        }

                    } //else {
                      //  throw new CustomException('Asset '+row.Vin__c.toUpperCase()+' does not exist in CXP and 5000 product code not provided in CSV therefore nothing to update.');
                    //}
                }

                DerivativeProductId = null;
                
                //********************** ASSETS *************************//
                if (AssetsToUpdate.containsKey(row.vin__c.toUpperCase())) { //Asset found in CXP with VIN matching value provided in CSV

                    Vehicle = AssetsToUpdate.get(row.vin__c.toUpperCase());
                    row.Asset__c = Vehicle.Id; 

                    if (DerivativeProduct != null) {
                        DerivativeProductId = DerivativeProduct.Id;
                    }

                    /* CXPD-814 - Suhan Jain */Vehicle = updateAssetFromRow(Vehicle,DerivativeProductId,row,DerivativeProduct);  
                    update Vehicle; 
                    row.Processed_Error_Reason__c = null;
                    row.Processed_Status__c = 'Processed';
                    AssetsUpdated++;
                    EmailReportContentSuccesses+='UPDATED ASSET '+row.Vin__c.toUpperCase()+': ' + Vehicle.id + ' at row: ' + row.id + '\n';
                    
                } else { //Asset not found in CXP with VIN matching value provided in CSV
                        
                    Vehicle = createAssetFromRow(row, ModelProduct, DerivativeProduct);  
                    insert Vehicle;
                    row.Asset__c = Vehicle.Id;  
                    row.Processed_Error_Reason__c = null;
                    row.Processed_Status__c = 'Processed'; 
                    AssetsCreated++;
                    EmailReportContentSuccesses+='CREATED ASSET '+row.Vin__c.toUpperCase()+': ' + Vehicle.id + ' at row: ' + row.id + '\n';
                    //} else {
                        //row.Processed_Status__c = 'Failed';  
                        //if (DerivativeProduct==null) {
                        //   row.Processed_Error_Reason__c = 'Cannot create asset '+row.Vin__c.toUpperCase()+' without a product code';
                        //} else {
                        //row.Processed_Error_Reason__c = 'Cannot create asset '+row.Vin__c.toUpperCase()+' without a model code';
                       // }
                        //EmailReportContentErrors+='SKIPPED ASSET CREATION OF '+row.vin__c.toUpperCase()+' at row : ' + row.id + '; ERROR: '+row.Processed_Error_Reason__c+'\n';
                    //}
                    
                }  
                
            } catch (DMLException e) {
                errMsg = e.getMessage() + '; Field: ' + e.getDmlFieldNames(0) + '; Stack Trace: ' + e.getStackTraceString();
                row.Processed_Error_Reason__c = errMsg.left(255); 
                row.Processed_Status__c = 'Failed';  
                EmailReportContentErrors+='FAILED TO UPSERT PRODUCT '+row.X5000_code__c+' OR ASSET '+row.vin__c.toUpperCase()+' AT ROW: ' + row.id + '; ERROR: '+errMsg+'\n';
            } catch (Exception e) {
                errMsg = e.getMessage() + '; Stack Trace: ' + e.getStackTraceString();
                row.Processed_Error_Reason__c = errMsg.left(255); 
                row.Processed_Status__c = 'Failed';  
                EmailReportContentErrors+='FAILED TO UPSERT PRODUCT '+row.X5000_code__c+' OR ASSET '+row.vin__c.toUpperCase()+' AT ROW: ' + row.id + '; ERROR: '+errMsg+'\n';                
            } 
        }
        
        try { 
            update IMSRequestData; 
        } catch (DMLException e) {
            EmailReportContentErrors+='UNABLE TO UPDATE ROWS; ERROR: ' + e.getMessage() + '---' + e.getStackTraceString();
            system.debug('BatchIMSRequestProcessorSender --- Error Updating IMSRequestData ---' + e.getMessage() + '---' + e.getStackTraceString());
        }
        
        SOQLcount += Limits.getQueries();
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //if (AssetsUpdated>0 || AssetsCreated>0 || ProductsUpdated>0 || ProductsCreated>0) {
        if (String.isNotEmpty(EmailReportContentErrors)) {
            String EmailContent = '<h1>BatchIMSRequestProcessor Status</h1>';
            EmailContent+='<h3>Running User: ' + UserInfo.getUserName() + '</h3>';
            EmailContent+='<hr/>';
            EmailContent+='<br/>There were '+AssetsUpdated+' assets updated and '+AssetsCreated+' assets created in this batch run.';
            EmailContent+='<br/>There were '+ProductsUpdated+' products updated and '+ProductsCreated+' products created in this batch run.'; 
            EmailContent+='<br/>Batch job total SOQL requests: ' + SOQLcount;
            EmailContent+='<h2>Errors</h2><PRE>';
            EmailContent+=EmailReportContentErrors+'</PRE>';
            EmailContent+='<hr/><h2>Successes</h2><PRE>';
            EmailContent+=EmailReportContentSuccesses+'</PRE><hr/>';
            EmailUtility.SendEmail(NOTIFICATION_EMAILS, 'BatchIMSRequestProcessorSender', 'BatchIMSRequestProcessor Status Report - ' + system.now(),EmailContent); 
        }
    }  
    
    private Boolean updateRequired(String Source, String Target, UPDATE_TYPES updateTYPE) { 
        if (String.isEmpty(Source) || Source=='\N' || Source=='\\N' || Source=='0000-00-00' || Source=='0') {
            return false;
        } else if (String.isNotEmpty(Target)) { 
            if (updateTYPE==UPDATE_TYPES.AlwaysUpdate) {
                return true;
            } else if ( (Source != Target) && updateTYPE==UPDATE_TYPES.OnlyIfDifferent) {
                return true;
            } else {
                return false;
            }
        } else if (String.isEmpty(Target)) { 
            if (updateTYPE==UPDATE_TYPES.OnlyIfTargetNull) return true;
        } 
        return true;
    }
    
    private String formatProductName(IMS_Request__c row) {
        return row.model_value_base__c + ' ' + row.engine_size_value_base__c + ' ' + row.variant_value_base__c + ' ' + row.transmission_meta_base__c + ' ' + row.country_name__c;
    }  
    
    private Date getDateFromString(String sDate) { //'YYYY-MM-DD HH:mm:SS' or 'YYYY-MM-DD'
        if (String.isEmpty(sDate) || sDate == '0000-00-00') return null;
        List<String> sDateParts = sDate.split('-');
        Integer intYear = Integer.ValueOf(sDateParts[0]), //YYYY
                intMonth = Integer.ValueOf(sDateParts[1]), //MM
                intDay = Integer.ValueOf(sDateParts[2].left(2)); //DD
        return Date.newInstance(intYear,intMonth,intDay);
    } 
    
    private Account getRetailerForCountryBrandAndCIcode(String CountryCode, String Brand, String CIcode) {
        if (AllRetailers.isEmpty()) return null;
        if (String.isEmpty(CountryCode) || String.isEmpty(Brand) || String.isEmpty(CIcode) ) return null;
        for (Account a : AllRetailers) {
            if (CountryCode == a.Country_ISO_Code__c) { 
                if (Brand == 'Jaguar' && a.Dealer_CI_Code__c == CIcode) {
                    return a;
                } else if (Brand == 'Land Rover' && a.Dealer_CI_Code_2__c == CIcode) {
                    return a;
                }
            }
        }
        return null;
    }
    
    private List<Account> getRetailers() { 
        string Qstring='select id,name,country_iso_code__c,dealer_ci_code__c,dealer_ci_code_2__c,queue_id__c'+ 
                                      ' from Account where RecordType.DeveloperName = \'Retailer\' AND';
        if(countryCode==label.IMS_BATCH_MENA_MARKET)
        {
           Qstring+=' (dealer_ci_code__c!=null Or dealer_ci_code_2__c!=null) AND Parent_Retailer__c=true order by country_iso_code__c'; 
        }else{
           Qstring+=' (dealer_ci_code__c!=null AND dealer_ci_code_2__c!=null) order by country_iso_code__c'; 
        }
        List<Account> AllRetailerAccounts = database.query(Qstring);
            /*[select id,name,country_iso_code__c,dealer_ci_code__c,dealer_ci_code_2__c,queue_id__c 
                                      from Account where RecordType.DeveloperName = 'Retailer' 
                                      and (dealer_ci_code__c!=null AND dealer_ci_code_2__c!=null) 
                                      order by country_iso_code__c];*/
        if (!AllRetailerAccounts.isEmpty()) return AllRetailerAccounts; else return new List<Account>();
    }
    
    private List<Account> getMigratedVehiclesAccounts() {
        List<Account> MigratedVehiclesAccounts = [select id,name,country_iso_code__c from Account where RecordType.DeveloperName = 'Retailer' and name like '%Migrated Vehicles'];
        if (!MigratedVehiclesAccounts.isEmpty()) return MigratedVehiclesAccounts; else return null;
    }
    
    private Map<String,Id> getRecordTypes() {
        Map<String,Id> RecordTypes = new Map<String,Id>();
        for (RecordType r : [select id,developername,SObjectType from RecordType where SObjectType in ('Vehicle_Specification__c','Product2','Asset')]) {
            RecordTypes.put(r.SObjectType+'.'+r.developername,r.id);
        }
        return RecordTypes;
    }

    private Map<String,Id> getAllDerivatives() {
        Map<String,Id> returnAllProducts = new Map<String,Id>();
        for (Product2 p : [select Id, ProductCode, Name, BODY_STYLE__C, ENGINE__C, TRANSMISSION__C, CurrencyIsoCode, isActive,Family,
                             WHEEL_BASE__C, Make__r.Name, Model__r.Name, Model__r.ProductCode , Model__c, Make__c, Model_Year_Alternative__c,
                               BodyStyle_Alternative__c,Transmission_Alternative__c,Wheel_Driven_Alternative__c,RecordTypeId,
                               Engine_Capacity_Alternative__c,Engine_Name_Alternative__c ,Registration_Year_Alternative__c,
                               Fuel_Type_Alternative__c, APO_Body_Style_Alternative__c, Doors__c, Drive__c, Seats__c,
                               Specification_Pack_Alternative__c,New_Vehicle__c, Model_Alternative__c  
                            from Product2 where recordtype.developername = 'Derivative' and productcode != null]) {
            returnAllProducts.put(p.ProductCode, p.id);
        }
        return returnAllProducts;
    }
    
    private Map<String,Product2> getProducts(Set<String> ProductCodes, String RecordType) {
        Map<String,Product2> productsByCode = new Map<String,Product2>(); 
        for (Product2 p : [select Id, ProductCode, Name, BODY_STYLE__C, ENGINE__C, TRANSMISSION__C, CurrencyIsoCode, isActive,Family,
                           WHEEL_BASE__C, Make__r.Name, Model__r.Name, Model__r.ProductCode , Model__c, Make__c, Model_Year_Alternative__c,
                           BodyStyle_Alternative__c,Transmission_Alternative__c,Wheel_Driven_Alternative__c,RecordTypeId,
                           Engine_Capacity_Alternative__c,Engine_Name_Alternative__c ,Registration_Year_Alternative__c,
                           Fuel_Type_Alternative__c, APO_Body_Style_Alternative__c, Doors__c, Drive__c, Seats__c,
                           Specification_Pack_Alternative__c, New_Vehicle__c, Model_Alternative__c, Transmission_Description_Alternative__c 
                           from Product2 where RecordType.DeveloperName = : RecordType 
                           and ProductCode in : ProductCodes ]) {
                               if (String.isNotEmpty(p.ProductCode)) productsByCode.put(p.ProductCode, p); 
                           }
        return productsByCode;
    } 
    
    private Map<String,Asset> getAssets(Set<String> Vins) {
        Map<String,Asset> mapAssets = new Map<String,Asset>(); 
        for (Asset a : [select id,name,account.recordtype.developername,Registration_Number__c,Description_Group_ID__c,Stock_Number__c,Vehicle_Initial_Registration_Date__c,
                                MOT_Expiry__c,Visible_From__c,Exterior_colour_code__c,Interior_colour_code__c, mileage__c,RecordTypeId,
                                Price_Trade__c, Price_Retail__c, Price_Siv__c, Local_Price__c, CurrencyIsoCode, features_base__c,
                                features_local__c,Pictures__c,Date_into_stock__c,APO_Stock_Status__c, APO__c,Mileage_Checked_Date__c,
                                Additional_registration_fee__c, Open_market_value__c, Certificate_of_entitlement__c,New_or_Used__c,
                                Interior_Material__c, Product2Id, Derivative__c,Number_IMS_Owners__c,Manufacture_Year__c
                                from asset where (name in : Vins) or (vin__c in : Vins) FOR UPDATE]) {
            if (String.isNotEmpty(a.name)) mapAssets.put(a.name.toUpperCase(), a);
        }
        return mapAssets;
    }
    
    private Map<String,String> getCountries() {
        Schema.DescribeFieldResult fieldResult = Account.Select_Country_ISO_Code__c.getDescribe();
        List<Schema.PicklistEntry> countries = fieldResult.getPicklistValues();
        Map<String,String> mapCountries = new Map<String,String>();
        for( Schema.PicklistEntry f : countries) 
           mapCountries.put( f.getValue(), f.getLabel() ); 
        return mapCountries;
    }
    
    private Map<String,Vehicle_Specification__c> getVehicleSpecs (String RecordType) {
        Boolean MakeModelSwitch = (RecordType=='Make');
        Map<String,Vehicle_Specification__c> result = new Map<String,Vehicle_Specification__c>();
        for (Vehicle_Specification__c v : [select id,name from Vehicle_Specification__c where RecordType.Developername = : RecordType 
                                           and aop_JLR_Owned__c = : MakeModelSwitch and Is_Currently_Sold__c != : MakeModelSwitch]) {
            result.put(v.name,v);
        } 
        return result;
    }
    
    private Product2 createModelFromRow(IMS_Request__c row) {
        
        String ModelName = row.model_value_base__c;
        
        if (ModelName.contains(' (')) ModelName = ModelName.substring(0,ModelName.indexOf('('));
        
        return  new Product2(
            IsActive = true,
            Family = 'Vehicle',
            Make__c = mapVehicleSpecsMake.get(row.manufacturer__c).id,
            Name = ModelName,
            Model_Alternative__c = ModelName,
            Alternative_Name__c = row.model_description_base__c,
            Model_Year_Alternative__c = row.model_year__c,
            ProductCode = row.model_code__c,
            RecordTypeId = mapRecordTypes.get('Product2.Model'),
            CurrencyIsoCode = row.currency__c
        );
        
    }
    
    private Product2 updateProductFromRow(Product2 UpdateProduct, IMS_Request__c row) { 
        
        Product2 Product = UpdateProduct; 
        Boolean isNewVehicleProduct = Product.New_Vehicle__c;
        
        String Transmission = row.transmission_meta_base__c;
        if (String.isNotEmpty(row.transmission_meta_base__c) && row.transmission_meta_base__c.contains(' ')) 
            Transmission = row.transmission_meta_base__c.substring(0,row.transmission_meta_base__c.indexOf(' '));
            
        String EngineSize = row.engine_size_value_base__c;
        if (String.isNotEmpty(row.engine_size_value_base__c) && row.engine_size_value_base__c.length()>=3) {
            EngineSize = row.engine_size_value_base__c.left(1) + '.' + row.engine_size_value_base__c.substring(1,2) + ' L';
        }

        //Common fields
        if (isNewVehicleProduct==null || !isNewVehicleProduct) {
            if (updateRequired(row.variant_value_base__c,Product.Specification_Pack_Alternative__c ,UPDATE_TYPES.OnlyIfDifferent))
                Product.Specification_Pack_Alternative__c = row.variant_value_base__c;  
            if (updateRequired(Transmission,Product.Transmission_Alternative__c,UPDATE_TYPES.OnlyIfDifferent))
                Product.Transmission_Alternative__c = Transmission; 
            if (updateRequired(row.drivetrain_name_base__c,Product.Wheel_Driven_Alternative__c,UPDATE_TYPES.OnlyIfDifferent))
                Product.Wheel_Driven_Alternative__c = row.drivetrain_name_base__c;
            if (updateRequired(EngineSize,Product.Engine_Capacity_Alternative__c,UPDATE_TYPES.OnlyIfDifferent))
                Product.Engine_Capacity_Alternative__c = EngineSize;
            if (updateRequired(row.year_reg__c,Product.Registration_Year_Alternative__c,UPDATE_TYPES.OnlyIfDifferent))
                Product.Registration_Year_Alternative__c = row.year_reg__c;
            if (updateRequired(row.fuel_value_base__c,Product.Fuel_Type_Alternative__c,UPDATE_TYPES.OnlyIfDifferent))
                Product.Fuel_Type_Alternative__c = row.fuel_value_base__c;
            if (updateRequired(row.model_description_base__c, Product.Model_Alternative__c,UPDATE_TYPES.OnlyIfTargetNull ))
                Product.Model_Alternative__c = row.model_description_base__c;
        } else {
            if (Product.Specification_Pack_Alternative__c == null && String.isNotEmpty(row.variant_value_base__c) )
                Product.Specification_Pack_Alternative__c = row.variant_value_base__c;  
            if (Product.Transmission_Alternative__c == null && String.isNotEmpty(Transmission) )
                Product.Transmission_Alternative__c = Transmission; 
            if (Product.Wheel_Driven_Alternative__c == null && String.isNotEmpty(row.drivetrain_name_base__c) )
                Product.Wheel_Driven_Alternative__c = row.drivetrain_name_base__c;
            if (Product.Engine_Capacity_Alternative__c == null && String.isNotEmpty(EngineSize) )
                Product.Engine_Capacity_Alternative__c = EngineSize;
            if (Product.Registration_Year_Alternative__c == null && String.isNotEmpty(row.year_reg__c) )
                Product.Registration_Year_Alternative__c = row.year_reg__c;
            if (Product.Fuel_Type_Alternative__c == null && String.isNotEmpty(row.fuel_value_base__c) )
                Product.Fuel_Type_Alternative__c = row.fuel_value_base__c;
            if (Product.Model_Alternative__c == null && String.isNotEmpty(row.model_description_base__c) )
                Product.Model_Alternative__c = row.model_description_base__c;
        }

        //APO only fields
        if (updateRequired(row.model_year__c,Product.Model_Year_Alternative__c ,UPDATE_TYPE))
            Product.Model_Year_Alternative__c = row.model_year__c; 
        if (updateRequired(row.engine_name_base__c,Product.Engine_Name_Alternative__c ,UPDATE_TYPE))
            Product.Engine_Name_Alternative__c = row.engine_name_base__c;  
        if (updateRequired(row.bodystyle_value_base__c,Product.APO_Body_Style_Alternative__c ,UPDATE_TYPE))
            Product.APO_Body_Style_Alternative__c = row.bodystyle_value_base__c.replace('Ã©','é');   
        if (updateRequired(row.doors_value_base__c,Product.Doors__c,UPDATE_TYPE))
            Product.Doors__c = row.doors_value_base__c;
        if (updateRequired(row.drive_value_base__c,Product.Drive__c,UPDATE_TYPE))
            Product.Drive__c = row.drive_value_base__c;
        if (updateRequired(row.seats_value_base__c,Product.Seats__c,UPDATE_TYPE))
            Product.Seats__c = row.seats_value_base__c;
        if (updateRequired(row.transmission_value_base__c,Product.Transmission_Description_Alternative__c,UPDATE_TYPE))
            Product.Transmission_Description_Alternative__c = row.transmission_value_base__c;
        
        return Product;
        
    }

    private Product2 getSpecificProduct(String uniqueID, Boolean isCode) {
        
        List<Product2> productsToReturn;
        
        if (String.isNotEmpty(uniqueID)) {
            if (isCode) {
                productsToReturn =  [select Id, ProductCode, Name, BODY_STYLE__C, ENGINE__C, TRANSMISSION__C, CurrencyIsoCode, isActive,Family,
                                     WHEEL_BASE__C, Make__r.Name, Model__r.Name, Model__r.ProductCode , Model__c, Make__c, Model_Year_Alternative__c,
                                     BodyStyle_Alternative__c,Transmission_Alternative__c,Wheel_Driven_Alternative__c,RecordTypeId,
                                     Engine_Capacity_Alternative__c,Engine_Name_Alternative__c ,Registration_Year_Alternative__c,
                                     Fuel_Type_Alternative__c, APO_Body_Style_Alternative__c, Doors__c, Drive__c, Seats__c,
                                     Specification_Pack_Alternative__c,New_Vehicle__c,Model_Alternative__c
                                     from Product2 where ProductCode = : uniqueID and RecordType.DeveloperName = 'Derivative'];
            } else {
                productsToReturn =  [select Id, ProductCode, Name, BODY_STYLE__C, ENGINE__C, TRANSMISSION__C, CurrencyIsoCode, isActive,Family,
                                     WHEEL_BASE__C, Make__r.Name, Model__r.Name, Model__r.ProductCode , Model__c, Make__c, Model_Year_Alternative__c,
                                     BodyStyle_Alternative__c,Transmission_Alternative__c,Wheel_Driven_Alternative__c,RecordTypeId,
                                     Engine_Capacity_Alternative__c,Engine_Name_Alternative__c ,Registration_Year_Alternative__c,
                                     Fuel_Type_Alternative__c, APO_Body_Style_Alternative__c, Doors__c, Drive__c, Seats__c,
                                     Specification_Pack_Alternative__c,New_Vehicle__c,Model_Alternative__c
                                     from Product2 where Id = : uniqueID  and RecordType.DeveloperName = 'Derivative'];
            }
        } 
        
        if (!productsToReturn.isEmpty()) return productsToReturn[0];
        
        return null;
        
    }
    
    private Product2 createProductFromRow(IMS_Request__c row, Product2 Model) { 
        
        String Transmission = row.transmission_meta_base__c;
        if (String.isNotEmpty(row.transmission_meta_base__c) && row.transmission_meta_base__c.contains(' ')) 
            Transmission = row.transmission_meta_base__c.substring(0,row.transmission_meta_base__c.indexOf(' '));
        
        String EngineSize = row.engine_size_value_base__c;
        if (String.isNotEmpty(row.engine_size_value_base__c) && row.engine_size_value_base__c.length()>=3) {
            EngineSize = row.engine_size_value_base__c.left(1) + '.' + row.engine_size_value_base__c.substring(1,2) + ' L';
        }
        
        return new Product2(
            IsActive = true,
            Family = 'Vehicle',
            Model__c = (Model==null?null:Model.Id),
            Make__c = mapVehicleSpecsMake.get(row.manufacturer__c).id,
            ProductCode = row.X5000_code__c,
            RecordTypeId = mapRecordTypes.get('Product2.Derivative'),
            Name = formatProductName(row),
            Alternative_Name__c = formatProductName(row), 
            CurrencyIsoCode = row.currency__c, 
            //Body_Style__c = row.bodystyle_code__c, // BRS CODE --> Future enhancement moves these to a BRS Request record given the insert will fail if the picklist values does not exist in the global value set
            //Transmission__c = row.transmission_code__c, // BRS CODE 
            //Wheel_Base__c = row.wheelbase_code__c, // BRS CODE 
            //Wheel_Driven__c = row.drivetrain_code__c, // BRS CODE 
            //Specification_Pack__c = row.variant_code__c, // BRS CODE 
            //Engine__c = row.engine_size_code__c, // BRS CODE 
            APO_Body_Style_Alternative__c  = row.bodystyle_value_base__c.replace('Ã©','é'), 
            Transmission_Alternative__c = Transmission, 
            Transmission_Description_Alternative__c = row.transmission_value_base__c, 
            Wheel_Driven_Alternative__c = row.drivetrain_name_base__c, 
            Specification_Pack_Alternative__c = row.variant_value_base__c, 
            Engine_Capacity_Alternative__c = EngineSize,
            Engine_Name_Alternative__c = row.engine_name_base__c, 
            Registration_Year_Alternative__c = row.year_reg__c, 
            Model_Year_Alternative__c = row.model_year__c, 
            Model_Alternative__c = row.model_description_base__c,
            Fuel_Type_Alternative__c = row.fuel_value_base__c, 
            Doors__c = row.doors_value_base__c, 
            Drive__c = row.drive_value_base__c, 
            Seats__c = row.seats_value_base__c 
            
        );
    }

    private Asset createAssetFromRow(IMS_Request__c row, Product2 Model, Product2 Derivative) {
        
        List<Double> fees = new List<Double>();
        List<Double> prices = new List<Double>();
        
        if (String.isNotEmpty(row.additional_registration_fee__c)) {
            fees.add(Double.ValueOf(row.additional_registration_fee__c.replaceAll(',','')));
        } else fees.add(null);
        if (String.isNotEmpty(row.Open_market_value__c)) {
            fees.add(Double.ValueOf(row.Open_market_value__c.replaceAll(',','')));
        } else fees.add(null);
        if (String.isNotEmpty(row.Certificate_of_entitlement__c)) {
            fees.add(Double.ValueOf(row.Certificate_of_entitlement__c.replaceAll(',','')));
        } else fees.add(null);
        
        if (String.isNotEmpty(row.price_trade__c)) {
            prices.add(Double.ValueOf(row.price_trade__c.replaceAll(',','')));
        } else prices.add(null);
        if (String.isNotEmpty(row.price_siv__c)) {
            prices.add(Double.ValueOf(row.price_siv__c.replaceAll(',','')));
        } else prices.add(null);
        if (String.isNotEmpty(row.price_retail__c)) {
            prices.add(Double.ValueOf(row.price_retail__c.replaceAll(',','')));
        } else prices.add(null);
        
        if (row.country_code__c=='SGP') row.country_code__c='SG';
        
        Account OwnerAccount = getRetailerForCountryBrandAndCIcode(row.country_code__c, row.manufacturer__c, row.ci_code__c);
        
        if (OwnerAccount==null) {
            for (Account a : MigratedVehicleAccounts) {
                if (a.country_iso_code__c == row.country_code__c) {
                    OwnerAccount = a;
                }
            }
        }  
        
        if (row.date_stock__c==null) row.date_stock__c = '';
        
        date manufacturerDate;
        if(row.Manufacture_Year__c!=null)
            manufacturerDate = date.parse('01/01/'+row.Manufacture_Year__c);

        return new Asset( 
            APO__c = true,
            New_or_Used__c='Used',
            AccountId = OwnerAccount.id,
            Name = row.vin__c.toUpperCase(),
            Vin__c = row.vin__c.toUpperCase(),
            Brand__c = mapVehicleSpecsMake.containsKey(row.manufacturer__c) ? mapVehicleSpecsMake.get(row.manufacturer__c).id : null,
            /* CXPD-813 - Suhan Jain */ Model__c = (Derivative == null ? null : Derivative.Model__c),
            Derivative__c = (Derivative==null?null:Derivative.id),
            Product2id = (Derivative==null?null:Derivative.id),
            
            Vehicle_Initial_Registration_Date__c = getDateFromString(row.date_registered__c),
            MOT_Expiry__c = getDateFromString(row.date_mot_expiry__c),
            Visible_From__c = getDateFromString(row.date_visible_from__c),
            
            Exterior_colour_code__c = row.colour_exterior_code__c,
            Exterior_colour__c = row.colour_exterior_value_base__c, 
            Interior_colour_code__c = row.colour_interior_code__c,
            Interior_color__c = row.colour_interior_value_base__c,
            Exterior_Colour_Group__c  = (ColourGroup.containsKey(row.colour_exterior_value_base__c) ? ColourGroup.get(row.colour_exterior_value_base__c).Colour_Group__c : null),
         
            Mileage__c = Integer.ValueOf(row.odometer__c),
            Mileage_checked_date__c=system.now(),  
            
            Price_trade__c = prices[0],
            Price_retail__c = prices[2], //price_new is not being used
            Price_siv__c = prices[1],
            Local_price__c = prices[2],  
            
            CurrencyIsoCode = row.currency__c,
            
            Features_base__c = '{'+row.features_base__c+'}',
            Features_local__c = '{'+row.features_local__c+'}',
            Highlighted_base__c = '{'+row.highlighted_base__c+'}',
            Highlighted_local__c = '{'+row.highlighted_local__c+'}',
            
            Pictures__c  = row.pic_refs__c, 
            
            Registration_Number__c = row.reg_no__c,
            Description_Group_ID__c = row.X5000_code__c,
            Stock_Number__c = row.stock_number__c,   
            
            Date_Into_Stock__c  = getDateFromString(row.date_stock__c),
            APO_stock_status__c = 'Retail',
            Additional_registration_fee__c = fees[0],
            Open_market_value__c = fees[1],
            Certificate_of_entitlement__c = fees[2],
            Number_IMS_Owners__c=row.Number_IMS_Owners__c,
            Manufacture_Year__c=manufacturerDate,
            Interior_Material__c = row.int_material__c
            
        );       
    }
    
    private Asset updateAssetFromRow(Asset VehicleToUpdate, Id DerivativeProductId, IMS_Request__c row, Product2 DerivativeProduct) {
        
        Asset Vehicle = VehicleToUpdate; 

        if (DerivativeProductId != null) {
            Vehicle.Derivative__c = DerivativeProductId; 
            Vehicle.Product2id = DerivativeProductId;
             /* CXPD-814 - Suhan Jain */
            Vehicle.Model__c=DerivativeProduct !=null ?DerivativeProduct.Model__c:null;
        }

        if (row.country_code__c=='SGP') row.country_code__c='SG';
        Account OwnerAccount = getRetailerForCountryBrandAndCIcode(row.country_code__c, row.manufacturer__c, row.ci_code__c);
        system.debug('OwnerAccount'+OwnerAccount);     
        
        if (OwnerAccount==null) {
            for (Account a : MigratedVehicleAccounts) {
                if (a.country_iso_code__c == row.country_code__c) {
                    OwnerAccount = a;
                } 
            }
        }  
        
        if (row.date_stock__c == null) row.date_stock__c = '';
        
        date manufacturerDate;
        if(row.Manufacture_Year__c!=null)
            manufacturerDate = date.parse('01/01/'+row.Manufacture_Year__c);
        
        Vehicle.APO__c = true;
        Vehicle.New_or_Used__c = 'Used';
        
        if (Vehicle.APO_Stock_Status__c != 'Reserved') Vehicle.APO_Stock_Status__c = 'Retail';
//CXPD-702        if(Vehicle.Account.RecordType.DeveloperName == 'Retailer'){
        if (OwnerAccount!=null && updateRequired(String.ValueOf(OwnerAccount.id),String.ValueOf(Vehicle.AccountId),UPDATE_TYPE) )
            Vehicle.AccountId = OwnerAccount.id; 
       // }
      
        if (Vehicle.Vehicle_Initial_Registration_Date__c==null)
            Vehicle.Vehicle_Initial_Registration_Date__c  = getDateFromString(row.date_registered__c);
        
        if (updateRequired(row.date_mot_expiry__c,string.valueof(Vehicle.MOT_Expiry__c),UPDATE_TYPE)) 
            Vehicle.MOT_Expiry__c  = getDateFromString(row.date_mot_expiry__c);
        
        if (updateRequired(row.date_visible_from__c,string.valueof(Vehicle.Visible_From__c),UPDATE_TYPE)) 
            Vehicle.Visible_From__c  = getDateFromString(row.date_visible_from__c);
        
        if (updateRequired(row.colour_exterior_code__c,Vehicle.Exterior_colour_code__c,UPDATE_TYPE)) 
            Vehicle.Exterior_colour_code__c = row.colour_exterior_code__c;
        
        if (updateRequired(row.colour_interior_code__c,Vehicle.Interior_colour_code__c,UPDATE_TYPE)) 
            Vehicle.Interior_colour_code__c = row.colour_interior_code__c;
        
        if (updateRequired(row.colour_exterior_value_base__c,Vehicle.Exterior_colour__c,UPDATE_TYPE)) {
            Vehicle.Exterior_colour__c = row.colour_exterior_value_base__c;
            if (ColourGroup.containsKey(row.colour_exterior_value_base__c)) 
                Vehicle.Exterior_Colour_Group__c  = ColourGroup.get(row.colour_exterior_value_base__c).Colour_Group__c;
        }
        
        if (updateRequired(row.colour_interior_value_base__c,Vehicle.Interior_color__c,UPDATE_TYPE)) 
            Vehicle.Interior_color__c = row.colour_interior_value_base__c; 
        
        if ( updateRequired(row.odometer__c,string.valueof(Vehicle.mileage__c),UPDATE_TYPE) && 
            (Vehicle.mileage__c==null || (Vehicle.mileage__c<Integer.ValueOf(row.odometer__c)) ) ) {
                Vehicle.Mileage__c = Integer.ValueOf(row.odometer__c);
                Vehicle.Mileage_Checked_Date__c = system.now();
        }
        
        if (updateRequired(row.price_retail__c,string.valueof(Vehicle.local_price__c ),UPDATE_TYPE) ) 
            Vehicle.local_price__c = Double.ValueOf(row.price_retail__c.replace(',',''));
        
        if (updateRequired(row.price_trade__c,string.valueof(Vehicle.price_trade__c ),UPDATE_TYPE)) 
            Vehicle.price_trade__c = Double.ValueOf(row.price_trade__c.replace(',',''));
        
        if (updateRequired(row.price_retail__c,string.valueof(Vehicle.price_retail__c ),UPDATE_TYPE)) 
            Vehicle.price_retail__c = Double.ValueOf(row.price_retail__c.replace(',',''));
        
        if (updateRequired(row.price_siv__c,string.valueof(Vehicle.price_siv__c ),UPDATE_TYPE)) 
            Vehicle.price_siv__c = Double.ValueOf(row.price_siv__c.replace(',','')); 
        
        if (updateRequired(row.currency__c, Vehicle.CurrencyIsoCode, UPDATE_TYPE)) 
            Vehicle.CurrencyIsoCode = row.currency__c ;
        
        if (updateRequired('{'+row.features_base__c+'}', Vehicle.features_base__c, UPDATE_TYPE)) 
            Vehicle.features_base__c = '{'+row.features_base__c+'}' ;
        
        if (updateRequired('{'+row.features_local__c+'}', Vehicle.features_local__c, UPDATE_TYPE )) 
            Vehicle.features_local__c = '{'+row.features_local__c+'}' ;
        
        if (updateRequired('{'+row.highlighted_base__c+'}' , Vehicle.highlighted_base__c, UPDATE_TYPE )) 
            Vehicle.highlighted_base__c = '{'+row.highlighted_base__c+'}' ;
        
        if (updateRequired('{'+row.highlighted_local__c+'}', Vehicle.highlighted_local__c, UPDATE_TYPE )) 
            Vehicle.highlighted_local__c = '{'+row.highlighted_local__c+'}' ;
        
        if (updateRequired(row.pic_refs__c, Vehicle.Pictures__c , UPDATE_TYPE)) 
            Vehicle.Pictures__c  = row.pic_refs__c ; 
        
        if (updateRequired(row.reg_no__c,Vehicle.Registration_Number__c,UPDATE_TYPE) )
            Vehicle.Registration_Number__c = row.reg_no__c;
        
        if (updateRequired(row.X5000_code__c,Vehicle.Description_Group_ID__c,null)) 
            Vehicle.Description_Group_ID__c = row.X5000_code__c;
        
        if (updateRequired(row.stock_number__c,Vehicle.Stock_Number__c ,UPDATE_TYPE)) 
            Vehicle.Stock_Number__c  = row.stock_number__c ; 
        
        if (updateRequired(row.date_stock__c, string.valueof(Vehicle.Date_Into_Stock__c) ,UPDATE_TYPE )) 
            Vehicle.Date_Into_Stock__c  = getDateFromString(row.date_stock__c); 
        
        if (updateRequired(row.additional_registration_fee__c, String.ValueOf(Vehicle.additional_registration_fee__c), UPDATE_TYPE)) 
            Vehicle.additional_registration_fee__c = Double.ValueOf(row.additional_registration_fee__c.replaceAll(',','')) ;
        
        if (updateRequired(row.open_market_value__c, String.ValueOf(Vehicle.open_market_value__c), UPDATE_TYPE )) 
            Vehicle.open_market_value__c = Double.ValueOf(row.open_market_value__c.replaceAll(',','')) ;
        
        if (updateRequired(row.certificate_of_entitlement__c, String.ValueOf(Vehicle.certificate_of_entitlement__c), UPDATE_TYPE)) 
            Vehicle.certificate_of_entitlement__c = Double.ValueOf(row.certificate_of_entitlement__c.replaceAll(',','')) ;  
        
        if (updateRequired(row.int_material__c, Vehicle.Interior_Material__c  ,UPDATE_TYPE )) 
            Vehicle.Interior_Material__c  = row.int_material__c;  
        
        if (updateRequired(row.Number_IMS_Owners__c, Vehicle.Number_IMS_Owners__c,UPDATE_TYPE )) 
            Vehicle.Number_IMS_Owners__c= row.Number_IMS_Owners__c;
        
        if (Vehicle.Manufacture_Year__c!=manufacturerDate && manufacturerDate!=null) 
            Vehicle.Manufacture_Year__c= manufacturerDate;      
        
        return Vehicle;
    }  

}

/* (c) 2018-2021 X-Cloud (UK) Limited. */
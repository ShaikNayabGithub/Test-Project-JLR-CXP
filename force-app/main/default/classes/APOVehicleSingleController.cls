/*** 
Requirement : APOVehicleSingle Page 
Description: 
Author : TCS TEAM OFFSHORE
Test class: 
Create Date: 13/02/2018 
Description: Controller class with methods to call all the three Sections: Single Vehicle, Similar Vehicle and Retailer Info

***/

public without sharing class APOVehicleSingleController {
    public VehicleWrapper wrapper { get;set; }
    public SaveVehicleEnquiry vehicleEnquiry {get; set;}
    public String availability {get;set;}
    public Id similerVehicleId {get;set;} 
    public List<VehicleWrapper> nearMatchList {get;Set;}
    public String language {get;set;}
    public String market { get; set; }
    public CreateSavedVehicleDto dto {get; set;}
    public String CurrencySym{ get; set; }
    public String brand { get; set; }
    public String AccountId { get; set; }
    public String ApoDxLink { get; set; }
    public transient Set<String> featureSet{get;set;} 
    public String DealerLocatorJGLink{get;set;}
    public String DealerLocatorLRLink{get;set;}
    public String RetailerAddressInMap{get;set;}
    public String RetailerAccountWebsite{get;set;}
    public string APOImagePath{get;set;}
    public Case objcase{get;set;}
    public boolean IsSuccessLandrover{get;set;}
    public boolean IsSuccessJaguar{get;set;}
     public String pdpaLink{ get; set; }
   public String SelectedRetailer;
   public string marketPhone {get;set;}
    public string marketEmail {get;set;}
   
    public string modelDescription {get;set;}
     
    public APOVehicleSingleController(){
        this.vehicleEnquiry = new SaveVehicleEnquiry();
        IsSuccessLandrover=false;
        IsSuccessJaguar=false;
        featureSet = new Set<String>(); 
        brand = ApexPages.currentPage().getParameters().get('brand');
        this.language = ApexPages.currentPage().getParameters().get('lang');
        this.market = JUDAANUtil.getSimpleMarket();
        
        if(UserDao.getUserById(UserInfo.getUserId()).size() > 0)
        {
            this.AccountId = UserDao.getUserById(UserInfo.getUserId())[0].AccountId;
            
        }
        this.VehicleId =  ApexPages.currentPage().getParameters().get('id');
        this.dto = new CreateSavedVehicleDto();
        this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSingle();
        this.dto.url = '/APOVehicleSingle';
        this.dto.urlParameterMap = new Map<String, String>();
        this.dto.urlParameterMap.put('id', ApexPages.currentPage().getParameters().get('id'));
        this.dto.urlParameterMap.put('brand', ApexPages.currentPage().getParameters().get('brand'));
        
        // TCRM -3766
        objcase = new Case();
        
        CurrencySym= JUDAANUtil.getCurrencySymbol();
        DealerLocatorJGLink=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_JG_Link__c   ;
        DealerLocatorLRLink=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_LR_Link__c   ;
        ApoDxLink = JUDAANUtil.getApoDxLink();

        if(String.isEmpty(this.language)) {
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        if(this.language != 'ja' && this.language != 'en' && this.language != 'pt_BR'){
                this.language = System.label.DEFAULT_LANGUAGE;
        }
        RetailerAddressInMap='';
        this.dto.urlParameterMap.put('lang', this.language);
        this.dto.urlParameterMap.put('market', this.market);
        //added bu sfurti
        this.dto.urlParameterMap.put('svid', ApexPages.currentPage().getParameters().get('svid'));//Ankita
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            Asset AssetData=[select id, accountid, Account.Address_local__c from Asset where id =: ApexPages.currentPage().getParameters().get('id')];
            RetailerAddressInMap= AssetData.Account.Address_local__c;
            SelectedRetailer = AssetData.accountid;
        }
       
          pdpaLink  = this.market == 'sg'  ? Label.SG_PDPA : this.market == 'hk' ?  Label.HK_PDPA :  this.market == 'th' ?  Label.TH_PDPA  :  '';
         pdpaLink  = ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? pdpaLink : pdpaLink.replace('jaguar', 'landrover'); 
        IsSaved = false;
        checkSaved();
    }
    
    public String VehicleId { get; set; }
    
    public void VehicleHitCount(id assetId) {
        String queueName;
        List<Vehicle_Hit_Count__c > vehicleRecordList = new List<Vehicle_Hit_Count__c >(); 
        Vehicle_Hit_Count__c vehicleRecord = new Vehicle_Hit_Count__c();
        System.debug('Hit for the asset :: '+assetId);
        if(assetId != null)
            vehicleRecordList  = [select id,Vehicle_Count__c from Vehicle_Hit_Count__c where Asset__c =: assetId limit 1];
        if(vehicleRecordList  != null && vehicleRecordList.size() > 0 ) {
            vehicleRecordList.get(0).Vehicle_Count__c =vehicleRecordList.get(0).Vehicle_Count__c + 1;
            update vehicleRecordList;
            System.debug('updated hit :: '+vehicleRecordList);
        } else {
            System.debug('Hit for the asset :: '+assetId);
            vehicleRecord.Asset__c  = assetId;
            vehicleRecord.Vehicle_Count__c = 1;
            vehicleRecord.Name =  'APOVehicleSingle';  
            if(this.market == 'jp')
                queueName = 'Japan CRC Queue';
            else if (this.market == 'sg' || this.market == 'hk')
                queueName = 'Singapore CRC Queue';
            if(queueName != null) {
                List<Group> queueIdList = [select Id from Group where Type = 'Queue' AND NAME =: queueName  limit 1];
                vehicleRecord.OwnerId = queueIdList.get(0).id; 
            }
            if(!test.isRunningTest() && vehicleRecord != null) 
                insert vehicleRecord; 
        }
        System.debug('inserted hit count');
    }  
    
    public PageReference getRecords(){
        APOImagePath='';
        String assetId = ApexPages.currentPage().getParameters().get('id');
        VehicleHitCount(ApexPages.currentPage().getParameters().get('id'));
        String Currentlanguage=ApexPages.currentPage().getParameters().get('lang');
        VehicleId = assetId;
        List<Asset> assetList = AssetDao.getAssetById(assetId);
        if(assetList.size() != 0){
            System.debug('## market - ' + this.market);
            // Logic is added for THAI market to display THAI text
            modelDescription  = assetList.get(0).product2.Model_Alternative__c.replaceAll( ' ' , '_' ).toUpperCase().replaceAll('-', '_');
            if(this.market == 'th') { // Fix added for THAI text description
                modelDescription = modelDescription + '_' + this.market.toUpperCase();
            } 
            System.debug('modelDescription---:: '+modelDescription);
            System.debug('modelDescription111---:: '+CustomLabels.getInstance().getValue( modelDescription ));
            modelDescription = modelDescription != null && CustomLabels.getInstance().getValue( modelDescription ) != null ? CustomLabels.getInstance().getValue( modelDescription ) : '';
            JUDAAN_Campaign__c campaign = this.getCampaign(assetList.get(0).Model__c,market);
            this.wrapper = new VehicleWrapper(assetList.get(0), campaign);
            JUDAANMarketSettings__c objmarketSett = JUDAANMarketSettings__c.getValues(ApexPages.currentPage().getParameters().get('market'));
            marketPhone = ApexPages.currentPage().getParameters().get('brand') =='jaguar' ? objmarketSett.JG_Phone__c : objmarketSett.Land_Phone__c;
            marketEmail =  ApexPages.currentPage().getParameters().get('brand') =='jaguar' ? objmarketSett.JG_Email__c : objmarketSett.Land_Email__c;
            this.getNearMatchRecord(campaign);
            if(StringUtil.splitImageLink(assetList[0].pictures__c).size() > 0) {
                APOImagePath = StringUtil.splitImageLink(assetList[0].pictures__c)[0];
            }
            if(Currentlanguage=='en'){
                if(!String.isBlank(assetList[0].Features_Base__c)){
                    featureSet = getFeatures(assetList[0].Features_Base__c);
                    system.debug('debug--------'+featureSet );// for fetching features
                }
            } else {
                if(!String.isBlank(assetList[0].Features_Local__c)){
                    featureSet = getFeatures(assetList[0].Features_Local__c); // for fetching features
                }
            }
            
        }
        
        return JUDAANUtil.brandCheck();
    }
    
    @TestVisible
    private JUDAAN_Campaign__c getCampaign(Id productId, string marketName){
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c();
        for(JUDAAN_Campaign__c c : JUDAAN_CampaignDao.getActiveCampaignByProductId(productId,marketName)){
                campaign = c;
        }
        return campaign;
    }
    @TestVisible
    private void getNearMatchRecord(JUDAAN_Campaign__c campaign){
        nearMatchList = new List<VehicleWrapper>();
        List<Asset> nearMatchrAssetRecords = AssetDao.getNearMatchAssets(wrapper.asset.Product2.Model_Alternative__c, wrapper.price, market, true);
        for(Asset asset : nearMatchrAssetRecords){
            if(ApexPages.currentPage().getParameters().get('id') != asset.Id && nearMatchList.size()<Integer.valueOf(Label.Near_Match_Count))
            nearMatchList.add(new VehicleWrapper(asset, campaign));
        }
    }
    
    public PageReference goBack(){
        String savedVehicleId = ApexPages.currentPage().getParameters().get('svid');
        PageReference p;
        if(String.isEmpty(savedVehicleId)){
                p = Page.APOVehicleSearch;
        }else{
                p = Page.APOVehicleSearch;
                p.getParameters().put('id', savedVehicleId);
        }
        if('Jaguar' == this.wrapper.brand){
                        p.getParameters().put('brand', 'jaguar');
                }else{
                        p.getParameters().put('brand', 'landrover');
                }
        p.getParameters().put('lang', this.language);
        //if(JUDAANUtil.RunningInAsandbox())
        //{
            p.getParameters().put('market', market);
        //}
        return p;
    }
    
    public PageReference showCheckoutPage(){
        String savedVehicleId = ApexPages.currentPage().getParameters().get('svid');
                PageReference p;
                if(this.market == 'jp')
                {
                    p = Page.Checkout;
                }
                else if(this.market == 'sg' )//enabling hk market
                {
                    p = Page.SGCheckout;
                }
                else if(this.market == 'hk'){
                 p = Page.hkcheckout;
                }
                else if(this.market == 'br'){
                 p = Page.BRCheckout;
                 
                }
                else if(this.market == 'th'){
                 p = Page.Thcheckout;
                 
                }
                //if(JUDAANUtil.runningInASandbox())
                //{
                    p.getParameters().put('market', market);
                //}
                p.getParameters().put('vid', this.wrapper.vid);
                p.getParameters().put('lang', this.language);
                if(this.wrapper.brand.equalsIgnoreCase('Jaguar')){
                        p.getParameters().put('brand', 'jaguar');
                }else{
                        p.getParameters().put('brand', 'landrover');
                }
                if(!String.isEmpty(savedVehicleId)){
                p.getParameters().put('svid', savedVehicleId);
        }
                return p;
    }
    
     public PageReference showMoreVehicle(){
        String assetId = ApexPages.currentPage().getParameters().get('assetid');
        String savedVehicleId = ApexPages.currentPage().getParameters().get('svid');
        String brandParam = Apexpages.currentPage().getParameters().get('brand');
        
        PageReference p = Page.APOVehicleSingle;
        p.getParameters().put('id', assetId);
        p.getParameters().put('lang', this.language);
        //if(JUDAANUtil.runningInaSandbox())
        //{
            p.getParameters().put('market', market);
        //}
        
        if(brandParam == 'jaguar'){
                p.getparameters().put('brand', 'jaguar');
        }else{
                p.getParameters().put('brand', 'landrover');
        }
        
        if(!String.isEmpty(savedVehicleId)){
                p.getParameters().put('svid', savedVehicleId);
        }
        
        p.setRedirect(true);
        return p;
    }
    
    public Boolean IsSaved { get; set; }
    List<Saved_Vehicle_for_Lead__c> SavedVehicleLead { get; set; } 
    List<Saved_Vehicle_for_Account__c> SavedVehicleAccount { get; set; }
    public void checkSaved()
    {
        string leadId;
       if(!test.isrunningTest()){
            leadId = [select Id from Lead where Account__c = :AccountId limit 1].id;
        }
       else{
           leadId = [select Id from Lead limit 1].id;
        }

        SavedVehicleLead = new List<Saved_Vehicle_for_Lead__c>();
        SavedVehicleAccount = new List<Saved_Vehicle_for_Account__c>();
        
        SavedVehicleLead = [Select Id from Saved_Vehicle_for_Lead__c where Lead__c = :leadId and Saved_Vehicle__c = :VehicleId];
        SavedVehicleAccount = [Select Id from Saved_Vehicle_for_Account__c where Account__c = :AccountId and Saved_Vehicle__c = :VehicleId];
        
        if(SavedVehicleLead.size() > 0 || SavedVehicleAccount.size() > 0)
        {
            IsSaved = true;
        }
        else
        {
            IsSaved = false;
        }
    }
    
    public void setAssetIdToDtoClass(){   
       
        this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
        //this.dto.svid = ApexPages.currentPage().getParameters().get('svid'); // Added by Ankita
        
    }
    
    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        PageReference p;
        try{
                this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
                this.dto.createSavedVehicle.create(this.dto);
                p = Page.APOVehicleSingle;
                p.getParameters().put('id', ApexPages.currentPage().getParameters().get('assetId'));
                p.getParameters().put('lang', this.language);
                p.getParameters().put('market', market);
                if(brand == 'jaguar'){
                        p.getparameters().put('brand', 'jaguar');
                }else{
                        p.getParameters().put('brand', 'landrover');
                }
                if(!String.isEmpty(ApexPages.currentPage().getParameters().get('svid'))){
                        p.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
                }
                p.setRedirect(true);

                
        }catch(Exception e){
                Database.rollback(sp);
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
        }
        return p;
    }
    
    public PageReference removeAsset()
    {
        Savepoint sp = Database.setSavepoint();
        PageReference p;
        try
        {
            checkSaved();
            delete SavedVehicleLead;
            delete SavedVehicleAccount;
            p = Page.APOVehicleSingle;
            p.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
            p.getParameters().put('lang', this.language);
            p.getParameters().put('market', market);
            if(brand == 'jaguar'){
                p.getparameters().put('brand', 'jaguar');
            }else{
                  p.getParameters().put('brand', 'landrover');
               }
            if(!String.isEmpty(ApexPages.currentPage().getParameters().get('svid'))){
                        p.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
                }
            p.setRedirect(true);
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            system.debug('---ex:' + ex.getMessage());
        }
        
        IsSaved = false;
         return p;
    }
     public void setAssetVehicleToDtoClass(){   
        
        //this.dto.urlParameterMap.put('id', ApexPages.currentPage().getParameters().get('assetId'));
        this.dto.assetIdQuery = ApexPages.currentPage().getParameters().get('assetId');
    }
    
    /* **************************************************
    Method Name: getFeatures
    Input Parameters: String
    Return Type: Set<String> (features)
    Method Description: Method to deserialze JSON key value pairs and return values as set of string
    ****************************************************** */  
    public Set<String> getFeatures(String features){ 
        Set<String> featuresSet = new Set<String>();
        try {
            Map<String,Object> mFeatures = (Map<String, Object>) JSON.DeserializeUntyped(features); 
            for (String s : mFeatures.keySet()) featuresSet.add(String.ValueOf(mFeatures.get(s)));
        } catch(Exception ex) {
            System.debug('### JSON Parsing ERROR ###  ' + ex.getMessage());
        }
        return featuresSet;
    }
  
     /* Wrapper class for Vehicle Single Page */
    public class VehicleWrapper{
        // Asset
        public Asset asset;
        public Id vid {get;set;}
        public String model { get; set; }
        public String image {get;set;}
        public String bodystyle { get; set; }
        public String specification { get; set; }
        public String registration { get; set; }
        public String fuelType { get; set; }
        public String transmission { get; set; }
        public String engine { get; set; }
        public String PowerOutput { get; set; }
        public String drive { get; set; }
       
        public String option { get; set; }
        public List<String> optionList {get;set;}
        public String extColor { get; set; }
        public String intColor { get; set; }
        public String intImage { get; set; }
        public Decimal price { get; set; }
        public String brand {get; set;}
        public String linkForDetail { get; set; }
        public String linkForUserd {get; set; } 
        public String linkForFinance {get; set;}
        public String availability { get; set; }
        
        public List<String> Options {get;set;}
       
        public String modelYear{get;set;}
        public Decimal mileage{get;set;}
        public String location{get;set;}
        public Date vehicleRegisteration;
        public string vehicleRegDate{get;set;}
        public String nameLocal{get;set;}
        public String retailerAddress{get;set;}
        public String retailerCity { get; set; }
        public String retailerPhone{get;set;}
        public String retailerEmail{get;set;}
        public String KowloonRetailerPhoneForTel{get;set;}
        public Decimal ARF{get;set;}
        public Decimal OMV{get;set;}
        public Decimal COE{get;set;}
        public String VIN{get;set;}
        //added on 26th june
        public Date Vehicle_legal_check_term{get;set;}
        public string vehiclelegalDate{get;set;}
        public string retailerurl{get;set;}
        // Campaign
        public JUDAAN_Campaign__c campaign{get; set;}
        public String campaignEnglish {get; set;}
        public String campaignJapanese {get; set;}
       
        // Multiple Images
        public List<String> images { get; set; }
        //Manufacture year
        public String manufactureYear{get;set;}
        //number of IMS Owner
        public String NoIMSOwners {get;set;}
        public boolean isVehicleSaved{get;set;}
        public User loginUser{get; set;}
        String mk = apexpages.currentpage().getparameters().get('market');
        public String retailerPhoneForTel{get;set;}
        public Date warrantyStartDate { get; set; } // COSA-572
        public String formattedWarrantyStartDate { get; set; } // COSA-572
        
        public String keyFeaturesLink { get; set; }
        public String marketValue = JUDAANUtil.getSimpleMarket();
        
        public VehicleWrapper(Asset asset, JUDAAN_Campaign__c campaign) {
            this.asset = asset;
            this.vid = asset.Id;
            this.model = asset.Product2.Model_Alternative__c;
            this.bodystyle = asset.Product2.APO_Body_Style_Alternative__c;
            this.specification = asset.Product2.Specification_Pack_Alternative__c;
            if(asset.Product2.Model_Year_Alternative__c != null)
                this.registration = Label.ManufactureYear + asset.Product2.Model_Year_Alternative__c.right(2);
            //this.registration= Label.ManufactureYear + asset.Product2.Registration_Year_Alternative__c.right(2);
            this.modelYear = asset.Product2.Model_Year_Alternative__c;
            this.fuelType = asset.Product2.Fuel_Type_Alternative__c;
            this.transmission = asset.Product2.Transmission_Alternative__c;
            this.engine= asset.Product2.Engine_Name_Alternative__c ;
            this.PowerOutput= asset.Product2.Power_Output_Alternative__c;
            this.drive = asset.Product2.Wheel_Driven_Alternative__c;
            this.ARF = asset.additional_registration_fee__c;
            this.OMV = asset.open_market_value__c;
            this.COE = asset.certificate_of_entitlement__c;
            
            if(asset.VIN__c != '' && asset.VIN__c!= null){
                this.VIN =(asset.VIN__c).substring((asset.VIN__c).length()-3,(asset.VIN__c).length());//added by sneha    start
                this.VIN = '**************'+this.VIN;
            }
            else{
                this.VIN='';
            }
            if(asset.Number_IMS_Owners__c != null)
                this.NoIMSOwners = asset.Number_IMS_Owners__c;
            this.Vehicle_legal_check_term = asset.MOT_Expiry__c;
            if(Vehicle_legal_check_term != null)
            {
                datetime Vehiclelegalcheckterm  = datetime.newInstance(Vehicle_legal_check_term.year(), Vehicle_legal_check_term.month(),Vehicle_legal_check_term .day());
                vehiclelegalDate = Vehiclelegalcheckterm.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            } //end
            
            
            if(asset.Manufacture_Year__c != null)
                this.manufactureYear = String.valueOf(asset.Manufacture_Year__c.year());
            this.mileage = asset.Mileage__c ;
            String city = asset.Account.BillingCity == null?' ':asset.Account.BillingCity ;
            String state = asset.Account.BillingState == null?' ':asset.Account.BillingState ;
            // this.location = city +' '+state;
            this.location=asset.Account.NameLocal;
            this.vehicleRegisteration = asset.Vehicle_Initial_Registration_Date__c;
            if(vehicleRegisteration != null) {
                datetime regDateFormat  = datetime.newInstance(vehicleRegisteration.year(), vehicleRegisteration.month(), vehicleRegisteration .day());
                vehicleRegDate = regDateFormat.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            }
            this.warrantyStartDate = asset.Warranty_Start_Date__c; // COSA-572
            if(warrantyStartDate != null) {
                datetime regDateFormat  = datetime.newInstance(warrantyStartDate.year(), warrantyStartDate.month(), warrantyStartDate.day());
                formattedWarrantyStartDate = regDateFormat.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            }
            //Retailer Info ---
            this.namelocal = asset.Account.Namelocal;
            this.retailerAddress = asset.Account.Address_local__c;
            this.retailerCity = city;
            this.KowloonRetailerPhoneForTel = ((Label.Kowloon_Retailer_PhoneNo).SubStringBefore('/')).replaceAll('[^0-9]', ''); 
            //  this.retailerPhone = asset.Account.Phone;
            this.retailerEmail = asset.Account.Email_used_for_Udaan__c;
            // this.retailerurl=asset.Account.Website;//Added on 26th june----Sneha
            //tm
            String assId = ApexPages.currentPage().getParameters().get('assetid');
            String brandpage = Apexpages.currentPage().getParameters().get('brand');
            Id accid = asset.AccountId;
            
            System.debug('accid :: '+accid);
            System.debug('brandpage :: '+brandpage);
            if(brandpage == 'landrover')
                brandpage = 'Land Rover';
            for(Account acc: [select Id,Website,Phone,Brand__c from Account where ParentId =:accid and Brand__c =:brandpage limit 1])
            {
                this.retailerurl = acc.Website; 
                this.retailerPhone = acc.Phone; 
                if(this.retailerPhone != null)
                    this.retailerPhoneForTel = (retailerPhone.SubStringBefore('/')).replaceAll('[^0-9]', ''); 
            }
            if(this.retailerurl != null)
            {
                if(!(this.retailerurl.contains('www')))
                {
                    this.retailerurl = 'www.' + this.retailerurl;
                }
                if(!(this.retailerurl.contains('http://')) && !(this.retailerurl.contains('https://')))
                {
                    this.retailerurl = 'http://' + this.retailerurl;
                } 
            }
            System.debug('retailerPhone :: '+retailerPhone);
            this.option = asset.Options__c; 
            this.images = new List<String>();
            if(asset.pictures__c != null)
            {
                this.images = asset.pictures__c.split(',');
                if(!images.isEmpty()){
                    this.image = images[0];
                }
            }
            String brandvalue;
            if(ApexPages.currentPage().getParameters().get('brand') == 'landrover')
                brandvalue = 'Land Rover';
            else
                brandvalue = ApexPages.currentPage().getParameters().get('brand');
            List<User> uList = UserDao.getUdaanActiveUserById(UserInfo.getUserId());
            for(User u : uList){
                this.loginUser = u;
            }
            List<Saved_Vehicle_for_Lead__c> svLeadList = SavedVehicleDao.getSavedVehicleForLeadByAccountId(this.loginUser.AccountId, brandvalue);
            if(svLeadList != null && !svLeadList.isEmpty()){
                this.isVehicleSaved = false;
                for(Saved_Vehicle_for_Lead__c saveVehicleobj :svLeadList)
                {
                    System.debug('saveVehicleobj.Saved_Vehicle__c :: '+saveVehicleobj.Saved_Vehicle__c);
                    System.debug('asset :: '+asset);
                    if(saveVehicleobj.Saved_Vehicle__c == asset.Id)
                        this.isVehicleSaved = true;
                }
            }
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( asset.Options__c ) );
            
            if(Option != null){
                this.optionList = Option.split(';');
            }else{
                this.optionList = new List<String>();
            }
            this.extColor = asset.Exterior_Colour__c;
            this.intColor = asset.Interior_Color__c;
            this.intImage = asset.Vehicle_interior_image_L__c;
            this.price = asset.Local_price__c;
            this.brand = asset.product2.Make__r.name;
            this.linkForDetail = asset.Link_for_detail_page_on_DX__c;
            this.linkForUserd = asset.Link_for_used_car_page_on_DX__c;
            this.linkForFinance = asset.Link_for_finance_page_on_DX__c;
            
            if(asset.Is_Available_on_Website__c){
                this.availability = Label.Available_Now ;
            }else{
                this.availability = Label.Not_Available_Now;
            }
            
            this.campaign = campaign;
            this.campaignEnglish = campaign.EnglishDescription__c;
            this.campaignJapanese = campaign.JapaneseDescription__c;
            
            if(marketValue == 'sg') {
                this.keyFeaturesLink = OSAUtil.getKeyFeaturesUrl(this.brand, this.model);
            }
        }
    }
    
    
   


    //Save Enquiry form
    public Boolean IsEmail { get; set; }
    public Boolean IsPhone { get; set; }
    public Boolean IsSMS { get; set; }
    
    
    
    public void saveEnquiryform(){
    
       Savepoint sp = Database.setSavepoint();
        try{
                list<string> lststring = new  list<string>();
                system.debug('---IsEmail1111 '+IsEmail );
                
                system.debug('---objcase'+objcase);
                if(IsEmail == true){
                system.debug('---IsEmail '+IsEmail );
                lststring.add(Label.Enquiry_Email);
                }
                if(IsPhone == true){
              
                lststring.add(Label.Enquiry_Phone_Number);
                }
                if(IsSMS == true){
               
                lststring.add(Label.Enquiry_Sms);
                }
                
/*
                if(!lststring.isEmpty()){
        
                 objcase.Contact_By__c  = string.join(lststring,',');
                }
                
                String nscEmail = '';
                if(market == 'jp'|| market == 'br')
                {
                    nscEmail  = Label.JUDAAN_NSC_Email;
                }
                else if(market =='sg' || market =='hk'|| market =='th'){ //enabling hk market
                    nscEmail  = Label.SUDAAN_NSC_Email;
                }
                
                if(ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().containskey('brand'))
                objcase.Brand2__c = brand = ApexPages.currentPage().getParameters().get('brand');
                */
                wrapper.brand = ApexPages.currentPage().getParameters().get('brand');
                
                EnquiryformAPOSingle objEnquiryformAPOSingle  =  new EnquiryformAPOSingle();
               
                objEnquiryformAPOSingle.createLead(objcase,SelectedRetailer , lststring  );
                //EnquiryformAPOSingle objEnquiryformAPOSingle  =  new EnquiryformAPOSingle();
                //objEnquiryformAPOSingle.createCaseforAPOVehicle(objcase,nscEmail  );
                objcase = new Case();
                IsEmail = false;
                IsPhone = false;
                IsSMS = false;
                if(brand=='landrover'){
                    IsSuccessLandrover=true;
                }
                else if(brand=='jaguar'){
                    IsSuccessJaguar=true;
                }
            
            }catch(Exception e){
                Database.rollback(sp);
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
    
    }//End Method
    // Lead Generation for Brazil
     public String errorMsg {get; set;}
     public void saveVehicleEnquiryform()
     {
         SaveVehicleEnquiry vehicleEnquiryObj = new SaveVehicleEnquiry();
         vehicleEnquiry.strleadtype = objCase.type;
         vehicleEnquiry.strDescription = objCase.description;
         System.debug('Inside saveVehicleEnquiryform :: '+vehicleEnquiry.firstName);   
         errorMsg = vehicleEnquiryObj.createLead(vehicleEnquiry,wrapper.vid);
     }

}
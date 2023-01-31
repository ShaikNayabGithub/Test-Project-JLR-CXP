/*** 
Requirement : VehicleSingle Page 
Description: 
Apply To: JPN
Author : TCS TEAM
Test class: 
Create Date: 28/7/2017 
Description: Controller class with methods to call all the three Sections: Single Vehicle, Similar Vehicle and Jaguar Vehicle

***/
public class VehicleSingleController {
    public VehicleWrapper wrapper { get;set; }
    public SaveVehicleEnquiry vehicleEnquiry {get; set;}
    public String availability {get;set;}
    public Id similerVehicleId {get;set;} 
    public transient  List<VehicleWrapper> nearMatchList {get;Set;}
    public String language {get;set;}
    public String market { get; set; }
    public CreateSavedVehicleDto dto {get; set;}
    public String CurrencySym{ get; set; }
    public String RetailerLink { get; set; }
    public User loginUser{get; set;}
    public Boolean isRecommend {get; set;}
    public Boolean isSpecial {get; set;}
    public Boolean isFeature{get; set;}
    public Case objcase{get;set;}
    public boolean IsSuccessLandrover{get;set;}
    public boolean IsSuccessJaguar{get;set;}
    public string strState;  
    public String pdpaLink{ get; set; }
    public string modelDescription {get;set;}
    public string marketPhone {get;set;}
    public string marketEmail {get;set;}
    private Set<String> duplicateAsset;
    
    public boolean isVehicleSaved;
    
    public VehicleSingleController(){
        IsSuccessLandrover=false;
        
        IsSuccessJaguar=false;
        objcase = new Case();
        isRecommend  = false;
        isFeature = false;
        isSpecial  = false;
        this.language = ApexPages.currentPage().getParameters().get('lang');
        this.market = JUDAANUtil.getSimpleMarket();
        this.vehicleEnquiry = new SaveVehicleEnquiry();
        this.dto = new CreateSavedVehicleDto();
        this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSingle();
        this.dto.url = '/VehicleSingle';
        this.dto.urlParameterMap = new Map<String, String>();
        this.dto.urlParameterMap.put('id', ApexPages.currentPage().getParameters().get('id'));
        string orderNo = ApexPages.currentPage().getParameters().get('order'); 
        if(orderNo != null)
            this.dto.urlParameterMap.put('order',orderNo);
        this.dto.urlParameterMap.put('brand', ApexPages.currentPage().getParameters().get('brand'));
        this.RetailerLink = JUDAANUtil.getRetailerDxLink();
        
        JUDAANMarketSettings__c objmarketSett = JUDAANMarketSettings__c.getValues(ApexPages.currentPage().getParameters().get('market'));
        
        marketPhone  = ApexPages.currentPage().getParameters().get('brand') =='jaguar' ? objmarketSett.JG_Phone__c : objmarketSett.Land_Phone__c;
        marketEmail =  ApexPages.currentPage().getParameters().get('brand') =='jaguar' ? objmarketSett.JG_Email__c : objmarketSett.Land_Email__c;
        system.debug('--marketPhone  '+marketPhone  );
        
        CurrencySym= JUDAANUtil.getCurrencySymbol();
        if(String.isEmpty(this.language)) {
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        if(this.language != 'ja' && this.language != 'en' && this.language != 'pt_BR'){
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        
        this.dto.urlParameterMap.put('lang', this.language);
        this.dto.urlParameterMap.put('market', this.market);
        strState= ApexPages.currentPage().getParameters().get('state');
        system.debug('888888888'+strState);
        //this.getRecords();
        //this.setBrandValue();
        if(this.market == 'jp')    
            getPrefecureWards();
        
        pdpaLink  = this.market == 'sg'  ? Label.SG_PDPA : this.market == 'hk' ?  Label.HK_PDPA :  this.market == 'th' ?  Label.TH_PDPA  :  '';
        pdpaLink  = ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? pdpaLink : pdpaLink.replace('jaguar', 'landrover'); 
    }
    
    public void getLoginUser(){
        List<User> uList = UserDao.getUdaanActiveUserById(UserInfo.getUserId());
        for(User u : uList){
            this.loginUser = u;
        }
    }
    
    public void VehicleHitCount(id assetId)
    {
      String queueName;
    /*  List<Vehicle_Hit_Count__c > vehicleRecordList = new List<Vehicle_Hit_Count__c >(); 
      Vehicle_Hit_Count__c vehicleRecord = new Vehicle_Hit_Count__c();
      System.debug('Hit for the asset :: '+assetId);
      if(assetId != null)
      vehicleRecordList  = [select id,Vehicle_Count__c from Vehicle_Hit_Count__c where Asset__c =: assetId limit 1];
      if(vehicleRecordList  != null && vehicleRecordList.size() > 0 )
      {
        vehicleRecordList.get(0).Vehicle_Count__c =vehicleRecordList.get(0).Vehicle_Count__c + 1;
        update vehicleRecordList;
      }
      else
      {
       
       System.debug('Hit for the asset :: '+assetId);
          
       vehicleRecord.Asset__c  = assetId;
       vehicleRecord.Vehicle_Count__c = 1;
       vehicleRecord.Name =  'VehicleSingle';
       if(this.market == 'jp')
       queueName = 'Japan CRC Queue';
       else if (this.market == 'sg' || this.market == 'hk'|| this.market == 'th')
       queueName = 'Singapore CRC Queue';
       if(queueName != null)  
       {
       List<Group> queueIdList = [select Id from Group where Type = 'Queue' AND NAME =: queueName  limit 1];
       vehicleRecord.OwnerId = queueIdList.get(0).id;
       }
       if(!test.isRunningTest() && vehicleRecord != null) 
       insert vehicleRecord; 
      }*/
      
      System.debug('inserted hit count');
    }  
    
    public PageReference getRecords(){
        getLoginUser();
        String assetId = ApexPages.currentPage().getParameters().get('id');
        //VehicleHitCount(ApexPages.currentPage().getParameters().get('id'));
        if(ApexPages.currentPage().getParameters().containskey('isRecomm') && ApexPages.currentPage().getParameters().get('isRecomm') != '' )
            isRecommend = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isRecomm'));
        
        if(ApexPages.currentPage().getParameters().containskey('isFeature') && ApexPages.currentPage().getParameters().get('isFeature') != ''){
            if(isRecommend || isSpecial)
                isFeature= false;
            else
                isFeature= Boolean.valueOf(ApexPages.currentPage().getParameters().get('isFeature'));
        }
        List<String> lstProductId = new  List<String>();
        Map<Id, List<JUDAAN_Campaign__c>> campaignMap = new  Map<Id, List<JUDAAN_Campaign__c>>();
        
        String assetIdFromSave = ApexPages.currentPage().getParameters().get('assetId');
        List<Asset> assetList = AssetDao.getAssetById(assetId);
        if(assetList.size() != 0){
            system.debug('marketvalue==>'+market);
            JUDAAN_Campaign__c campaign = this.getCampaign(assetList.get(0).Model__c,market);
            lstProductId.add(assetList.get(0).Model__c);
            isVehicleSaved = true;
            String brandValue;
            if(ApexPages.currentPage().getParameters().get('brand') == 'landrover')
                brandValue = 'Land Rover';
            else
                brandValue = ApexPages.currentPage().getParameters().get('brand');
            
            List<Saved_Vehicle_for_Lead__c> svLeadList = SavedVehicleDao.getSavedVehicleForLeadByAccountId(this.loginUser.AccountId, brandValue);
            System.debug('svLeadList :: '+svLeadList);    
            for(Saved_Vehicle_for_Lead__c saveVehicleobj :svLeadList) {
                System.debug('saveVehicleobj :: '+saveVehicleobj);
                if(saveVehicleobj.Saved_Vehicle__c == ID.valueOf(assetId))
                    isVehicleSaved = false;
            }
            System.debug('isVehicleSaved :: '+isVehicleSaved);
            campaign = checkCampaign(assetList.get(0), new List<JUDAAN_Campaign__c> {campaign});
            System.debug('campaign :: '+campaign );
            System.debug('isSpecial:: '+isSpecial);
            if(ApexPages.currentPage().getParameters().containskey('isSpecial')  && ApexPages.currentPage().getParameters().get('isSpecial') != ''){
                if(isRecommend)
                    isSpecial = false;
                
                else
                    isSpecial= Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSpecial'));
                System.debug('isSpecial:: '+isSpecial);
            }
            
            //if(campaign != null && campaign.Id != null && isRecommend == false) {
           //      isSpecial = true;
           // }
            
            System.debug('111isSpecial:: '+isSpecial);
            // Logic is added for THAI market to display THAI text
            modelDescription  = assetList.get(0).product2.Model_Alternative__c.replaceAll( ' ' , '_' ).toUpperCase().replaceAll('-', '_');
            if(this.market == 'th') { // Fix added for THAI text description
                modelDescription = modelDescription + '_' + this.market.toUpperCase();
            } 
            System.debug('modelDescription---:: '+modelDescription);
            System.debug('modelDescription111---:: '+CustomLabels.getInstance().getValue( modelDescription ));
            modelDescription = modelDescription != null && CustomLabels.getInstance().getValue( modelDescription ) != null ? CustomLabels.getInstance().getValue( modelDescription ) : '';
            
            this.wrapper = new VehicleWrapper(assetList.get(0), campaign);
            this.wrapper.isSavedVehicle =isVehicleSaved;
            Map<String,Asset> mapProductIdToAsset = new  Map<String,Asset>();
            Map<String,JUDAAN_Campaign__c> mapProductIdToCampaign = new  Map<String,JUDAAN_Campaign__c>();
            duplicateAsset = new Set<String>();
            /* 
            if(isRecommend){
                system.debug('---Make__r'+assetList.get(0).product2.Make__r.name);
                List<Asset> lstAsset = new VehicleSearch_AssetDao(assetList.get(0).product2.Make__r.name).getRecommendedAsset(lstProductId,market,campaignMap); 
                
                if(lstAsset != null && !lstAsset .isEmpty() ){
                    system.debug('---lstAsset '+lstAsset );
                    for( Asset tmp : lstAsset ) {
                       
                        mapProductIdToAsset.put(tmp.model__c,tmp);
                        List<JUDAAN_Campaign__c> lstcampaignRecommend = campaignMap.get(tmp.model__c); 
                        if(lstcampaignRecommend != null && !lstcampaignRecommend .isEmpty()) { 
        
                            system.debug('---lstcampaignRecommend '+lstcampaignRecommend );
                            //campaign1 = new VehicleSingleController().checkCampaign(tmp , new List<JUDAAN_Campaign__c> {lstcampaign[0]});
                                             
                            for(JUDAAN_Campaign__c objCamapaign : lstcampaignRecommend ){ 
                                if(tmp.model__c == objCamapaign.product__c){
                                  mapProductIdToCampaign.put(tmp.id,objCamapaign);
                                 //this.nearMatchList.add(new VehicleWrapper(tmp, objCamapaign ));
                                  system.debug('---nearMatchList'+nearMatchList);
                                }
                            }
                        } 
                     }   
                     
                     if(mapProductIdToAsset != null && mapProductIdToCampaign !=null ){
                         this.nearMatchList = new List<VehicleWrapper>();
                     
                         for( Asset objAsset :mapProductIdToAsset.values){
                                 
                          this.nearMatchList.add(new VehicleWrapper(objAsset , mapProductIdToCampaign.get(objAsset.id)));
                         }
                     
                     
                     }
                         
                 }                
                  
             }//if isRecommend
            
            else  
            */
            this.getNearMatchRecord( campaign );
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
        this.nearMatchList = new List<VehicleWrapper>();
        List<Asset> nearMatchrAssetRecords = AssetDao.getNearMatchAssets(this.wrapper.asset.Product2.Model_Alternative__c, this.wrapper.price, this.market, false);
        duplicateAsset.add(this.wrapper.asset.local_price__c+ this.wrapper.asset.Exterior_Colour__c + this.wrapper.asset.Interior_Color__c +this.wrapper.asset.Product2.BodyStyle_Alternative__c+this.wrapper.asset.Product2.Model_Alternative__c+this.wrapper.asset.Product2.Engine_Capacity_Alternative__c+this.wrapper.asset.Product2.Registration_Year_Alternative__c+this.wrapper.asset.product2.Specification_Pack_Alternative__c);
        for(Asset asset : nearMatchrAssetRecords){
            if(!duplicateAsset.contains(asset.local_price__c+ asset.Exterior_Colour__c + asset.Interior_Color__c +asset.Product2.BodyStyle_Alternative__c+asset.Product2.Model_Alternative__c+asset.Product2.Engine_Capacity_Alternative__c+asset.Product2.Registration_Year_Alternative__c+asset.product2.Specification_Pack_Alternative__c)){
                duplicateAsset.add(asset.local_price__c+ asset.Exterior_Colour__c + asset.Interior_Color__c +asset.Product2.BodyStyle_Alternative__c+asset.Product2.Model_Alternative__c+asset.Product2.Engine_Capacity_Alternative__c+asset.Product2.Registration_Year_Alternative__c+asset.product2.Specification_Pack_Alternative__c);
                system.debug('--assetkey'+asset.local_price__c+ asset.Exterior_Colour__c + asset.Interior_Color__c +asset.Product2.BodyStyle_Alternative__c+asset.Product2.Model_Alternative__c+asset.Product2.Engine_Capacity_Alternative__c+asset.Product2.Registration_Year_Alternative__c+asset.product2.Specification_Pack_Alternative__c);
                if(ApexPages.currentPage().getParameters().get('id') != asset.Id && nearMatchList.size()<Integer.valueOf(Label.Near_Match_Count))
                    
                    this.nearMatchList.add(new VehicleWrapper(asset, campaign));
            }
        }
    }
    
    public PageReference goBack(){
        String savedVehicleId = ApexPages.currentPage().getParameters().get('svid');
        PageReference p;
        if(String.isEmpty(savedVehicleId)){
            //p = Page.CustomerAccountPage;
            p = Page.VehicleSearch;
        }else{
            p = Page.VehicleSearch;
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
        system.debug('------showCheckoutPage-----');
        String savedVehicleId = ApexPages.currentPage().getParameters().get('svid');
        PageReference p;
        
        if(market == 'jp')
        {
            p = Page.CheckOut;
        }
        else if(market == 'sg')
        {
            p = Page.SGCheckout;
        }
        else if(this.market == 'hk'){
            p = Page.hkcheckout;
        }
        else if(this.market == 'br'){
            p = Page.BRCheckout;
            p.getParameters().put('state', strState);
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
        if('Jaguar' == this.wrapper.brand){
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
        
        String isRecommend = ApexPages.currentPage().getParameters().get('isRecommended1');
        String isSpecial = ApexPages.currentPage().getParameters().get('isSpecial1');
        //String isFeature= ApexPages.currentPage().getParameters().get('isFeature1');
        String order = ApexPages.currentPage().getParameters().get('orderNo');
        
        system.debug('----test'+isFeature);
        system.debug('----isSpecial '+isSpecial );
        
        PageReference p = Page.VehicleSingle;
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
        
        //if(isRecommend  != null && isRecommend != '')
        //p.getParameters().put('isRecomm' ,isRecommend );
        
        if(order != null)
        p.getParameters().put('order',order );
        
        if(isSpecial != null && isSpecial != '' && isRecommend == 'false' )
        p.getParameters().put('isSpecial' ,'true');
        
        
        //if(isFeature != null && isFeature != '' && ( isRecommend == 'false' || isSpecial == 'false') )
        //p.getParameters().put('isFeature' ,'true');
        
        p.setRedirect(true);
        return p;
    }
    
    public void setAssetIdToDtoClass(){   
        this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
    }
    
    public PageReference save() {
        PageReference p;
        String order;
        Savepoint sp = Database.setSavepoint();
        try{
            this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
            this.dto.createSavedVehicle.create(this.dto);
            String savedVehicleId = ApexPages.currentPage().getParameters().get('svid');
            String brandParam = Apexpages.currentPage().getParameters().get('brand');
            order = Apexpages.currentPage().getParameters().get('order');
            if(market == 'br')
                p = Page.CustomerAccountPage_New;
            else
            {
                p = Page.VehicleSingle;
                if(!String.isEmpty(savedVehicleId)){
                    p.getParameters().put('svid', savedVehicleId);
                }
            }
            
            
            if(order != null)
                p.getParameters().put('order', order);
            p.getParameters().put('id', ApexPages.currentPage().getParameters().get('assetid'));
            p.getParameters().put('lang', this.language);
            p.getParameters().put('market', market);
            if(brandParam == 'jaguar'){
                p.getparameters().put('brand', 'jaguar');
            }else{
                p.getParameters().put('brand', 'landrover');
            }
            
            
            p.setRedirect(true);
        }catch(Exception e){
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return p;
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
        public Decimal monthlyPrice { get; set; }
        public Decimal previousmonthlyPrice { get; set; }
        public Decimal previousprice { get; set; }
        public String brand {get; set;}
        public String linkForDetail { get; set; }
        public String linkForUserd {get; set; } 
        public String linkForFinance {get; set;}
        public String availability { get; set; }
        public boolean isSavedVehicle { get; set; }
        public boolean isSavedNearVehicle { get; set; }
        User loginUser1{ get; set; }
        public List<String> Options {get;set;}
        public Boolean isFeatureProduct{ get; set; }
        public Boolean isSpecialOffer{ get; set; }
        public string priceString { get; set; }
        public string monthlyPriceString { get; set; }
        public string previousmonthlyPriceString { get; set; }
        public string previouspriceString { get; set; } 
        public Boolean isRecommended{ get; set; }
        
        // Campaign
        public transient JUDAAN_Campaign__c campaign{get; set;}
        public String campaignEnglish {get; set;}
        public String campaignJapanese {get; set;}
        public String campaignUrlText { get; set; }
        
        // Multiple Images
        public transient List<String> images { get; set; }
        //Order number
        public string orderNumber { get; set; } 
        //contact to retailer
        public string city { get; set; }
        public String retailerAddress{get;set;}
        public String retailerPhone{get;set;}
        public String retailerPhoneForTel{get;set;}
        public String KowloonRetailerPhoneForTel{get;set;}
        public String retailerLocalName{get;set;}
        
        public String retaileremail{get;set;}
        public String keyFeaturesLink { get; set; }
        public String marketValue = JUDAANUtil.getSimpleMarket();
        
        // Check image exists in Vista server or not
        public Boolean checkImageExist(String endPoint) {
            // Get the XML document from the external server
            Boolean imageExist = false;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            Http http = new Http();
            if(Test.isRunningTest()) {
                imageExist = true;
            } else {
                HttpResponse res = http.send(req);
                if(res.getStatusCode() == 200) {
                    imageExist = true;
                }
            }
            return imageExist;
        }
        
        public VehicleWrapper(Asset asset, JUDAAN_Campaign__c campaign){
            isFeatureProduct = false;
            isSpecialOffer = false;
            this.asset = asset;
            this.vid = asset.Id;
            this.brand = asset.product2.Make__r.name;
            this.model = asset.Product2.Model_Alternative__c;
            this.image = asset.Vehicle_Image_L__c;
            this.retaileremail = asset.account.Email_used_for_Udaan__c;
            //if(asset.Product2.Monthly_Price_From__c != null)
            if(asset.Monthly_Price__c != 0)
            this.monthlyPrice = asset.Monthly_Price__c;
            if(asset.Product2.Previous_Monthly_Price_From__c != null)
            this.previousmonthlyPrice = asset.Product2.Previous_Monthly_Price_From__c;
            this.bodystyle = asset.Product2.BodyStyle_Alternative__c;
            this.specification = asset.Product2.Specification_Pack_Alternative__c;
            if(asset.Product2.Registration_Year_Alternative__c != null)
            this.registration= Label.ManufactureYear + asset.Product2.Registration_Year_Alternative__c.right(2);
            this.fuelType = asset.Product2.Fuel_Type_Alternative__c;
            this.transmission = asset.Product2.Transmission_Alternative__c;
            this.engine= asset.Product2.Engine_Capacity_Alternative__c;
            this.PowerOutput= asset.Product2.Power_Output_Alternative__c;
            this.drive = asset.Product2.Wheel_Driven_Alternative__c;
            this.option = asset.Options__c; 
            this.images = new List<String>();
            this.images = asset.Images__c.split(',');
            
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( asset.Options__c ) );
            if(marketValue == 'sg') {
                this.keyFeaturesLink = OSAUtil.getKeyFeaturesUrl(this.brand, this.model);
            }
            
            // logic to display image corousel
            final integer MAX_IMG = Integer.valueOf(Label.Multiangle_MAX_IMG);
            final integer MAX_EXTERIOR_IMG = Integer.valueOf(Label.Multiangle_MAX_EXTERIOR_IMG);
            final integer MAX_INTERIOR_IMG = Integer.valueOf(Label.Multiangle_MAX_INTERIOR_IMG);
            Integer ExteriorCount = 0;
            Integer InteriorCount = 0;
              
            /* if ( this.images.size() > 0 ) { 
                List<String> newList = new List<String>();
                for (Integer i=0; i<=this.images.size()-1 ;i++) {
                    for (Integer j=1; j<=MAX_IMG; j++) {
                        if (this.images[i].contains('.webp')) {
                            if(this.images[i].contains('EXTERIOR') && ExteriorCount < MAX_EXTERIOR_IMG) {
                                newList.add(String.ValueOf(this.images[i].replace('.webp','-0' + String.ValueOf(j) + '.webp')));
                                ExteriorCount++;
                            }
                            if(this.images[i].contains('INTERIOR') && InteriorCount < MAX_INTERIOR_IMG) {
                                newList.add(String.ValueOf(this.images[i].replace('.webp','-0' + String.ValueOf(j) + '.webp')));
                                InteriorCount++;
                            }
                        }
                    }
                }
                for (Integer i=0; i<=newList.size()-1; i++) {
                    this.images.add(newList[i]);
                }
            }*/
            
            // CXPD-1486 - New Logic to display Images from VISTA system
            if ( this.images.size() > 0 ) { 
                List<String> newList = new List<String>();
                for (Integer i=0; i<=this.images.size()-1 ;i++) {
                    // Add start image
                    newList.add(this.images[i]);
                    // Start index is 2 to get next image
                    for (Integer j=2; j<=MAX_IMG; j++) {
                        if(this.images[i].containsIgnoreCase('/Ext/') && ExteriorCount < MAX_EXTERIOR_IMG) {
                            String endPoint = this.images[i].substringBeforeLast('/') + '/' +  String.ValueOf(j) + '.jpg';
                            if(checkImageExist(endPoint)) {
                                newList.add(this.images[i].substringBeforeLast('/') + '/' +  String.ValueOf(j) + '.jpg');
                            }
                            ExteriorCount++;
                        }
                        if(this.images[i].containsIgnoreCase('/Int/') && InteriorCount < MAX_INTERIOR_IMG) {
                            String endPoint = this.images[i].substringBeforeLast('/') + '/' +  String.ValueOf(j) + '.jpg';
                            if(checkImageExist(endPoint)) {
                                newList.add(this.images[i].substringBeforeLast('/') + '/' +  String.ValueOf(j) + '.jpg');
                            }
                            InteriorCount++;
                        }
                    }
                }
                /* for (Integer i=0; i<=newList.size()-1; i++) {
                    this.images.add(newList[i]);
                } */
                this.images = newList;
            }
            
            if(Option != null){
                this.optionList = Option.split(';');
            }else{
                this.optionList = new List<String>();
            }
            this.extColor = asset.Exterior_Colour__c;
            this.intColor = asset.Interior_Color__c;
            this.intImage = asset.Vehicle_interior_image_L__c;
            this.price = asset.Local_price__c;
            this.previousprice  = asset.Previous_price__c;
            
            
            
            this.priceString  =  String.valueof(this.price.format());
            this.monthlyPriceString = this.monthlyPrice != null ? String.valueof(this.monthlyPrice.format()) : '';
            this.previousmonthlyPriceString  = this.previousmonthlyPrice != null ? String.valueof(this.previousmonthlyPrice.format()) : '';
            this.previouspriceString = this.previousprice != null ? String.valueof(this.previousprice.format()) : '';
            
            this.linkForDetail = asset.Link_for_detail_page_on_DX__c;
            this.linkForUserd = asset.Link_for_used_car_page_on_DX__c;
            this.linkForFinance = asset.Link_for_finance_page_on_DX__c;
            system.debug('---UserInfo.getUserId()'+UserInfo.getUserId()); 
            List<User> uList = UserDao.getUdaanActiveUserById(UserInfo.getUserId());
            
            system.debug('---uList '+uList );
            for(User u : uList){
                this.loginUser1 = u;
            }
            String brandValue;
            if(ApexPages.currentPage().getParameters().get('brand') == 'landrover')
                brandValue = 'Land Rover';
            else
                brandValue = ApexPages.currentPage().getParameters().get('brand');
             /*        
             List<Saved_Vehicle_for_Lead__c> svLeadList = SavedVehicleDao.getSavedVehicleForLeadByAccountId(this.loginUser1.AccountId, brandValue);
             
            System.debug('svLeadList wrapper:: '+svLeadList); 
            system.debug('---isFeatureProduct '+isFeatureProduct + 'asset'+asset.Id );   
            for(Saved_Vehicle_for_Lead__c saveVehicleobj :svLeadList)
                {
                    System.debug('saveVehicleobj.Saved_Vehicle__c :: '+saveVehicleobj.Saved_Vehicle__c);
                    System.debug('asset.id :: '+asset.id);
                    if(saveVehicleobj.Saved_Vehicle__c == asset.id)
                        this.isSavedNearVehicle = true;
                }
            */    
            if(asset.Is_Available_on_Website__c){
                this.availability = Label.Available_Now ;
            }else{
                this.availability = Label.Not_Available_Now;
            }
            this.orderNumber = asset.Order_Number__c;
            this.campaign = campaign;
            system.debug('---campaign--22'+campaign);
            system.debug('---asset--22'+asset);
            Map<string,string> mapAssetIdtoCampaignText = new Map<string,string>();
            
            List<String> lstcampaignText = new List<string>();
            
            
            if(this.campaign.VIN_Asset_Level_ID__c != null ){
                
                List<String> lstAssetID =   this.campaign.VIN_Asset_Level_ID__c.contains(',') ? this.campaign.VIN_Asset_Level_ID__c.split(',') : new List<string> {this.campaign.VIN_Asset_Level_ID__c} ;
                    
                    if(lstAssetID != null ){
                        lstcampaignText = this.campaign.VIN_Level_Campaign_Text__c.contains(',') ? this.campaign.VIN_Level_Campaign_Text__c.split(',') : new List<string>{this.campaign.VIN_Level_Campaign_Text__c};
                            
                            if(lstcampaignText != null)
                            for(Integer j= lstAssetID.size()-1; j>= 0 ; j--){
                                String strassetid =  lstAssetID[j];
                                String strCampaignText =  lstcampaignText.size() == 1 ? lstcampaignText[0] :lstcampaignText[j];
                                mapAssetIdtoCampaignText.put(strassetid,strCampaignText );
                                
                            }
                        
                        
                    }
                
                
            }
            system.debug('---mapAssetIdtoCampaignText--22'+mapAssetIdtoCampaignText);
            this.campaignEnglish = ( (!mapAssetIdtoCampaignText.isEmpty() && !mapAssetIdtoCampaignText.containsKey(asset.VIN__C)) || mapAssetIdtoCampaignText.isEmpty() || mapAssetIdtoCampaignText == null) ? this.campaign.EnglishDescription__c : mapAssetIdtoCampaignText.get(asset.VIN__C);    
            
            this.campaignJapanese = campaign.JapaneseDescription__c;
            this.campaignUrlText = campaign.Campaign_Url_Text__c;
            
            if(this.previousprice != null && this.campaign !=null){
                isFeatureProduct = false;
            }
            else if(this.previousprice != null){
                
                isFeatureProduct = true;
            }
            system.debug('---isFeatureProduct '+isFeatureProduct + 'asset'+asset.Id );
            if(this.campaign != null && (this.campaignEnglish != null ||this.campaignJapanese != null) && isFeatureProduct == false ){
                
                isSpecialOffer = true;
            }
            
            Id accid = asset.AccountId;
            this.retailerAddress =asset.Account.Address_local__c;
                
                /*if(ApexPages.currentPage().getParameters().get('market') == 'th'){
                    if((asset.Account.billingcity).equalsIgnoreCase(asset.Account.billingstate)  ){
                        this.city = asset.Account.billingcity;
                    }else {
                        this.city = asset.Account.fngstate+'-'+asset.Account.billingcity;   
                    }
                }else {
                        this.city = asset.Account.billingcity;  
                }
                */
                //if(ApexPages.currentPage().getParameters().get('market') == 'jp')
            this.city = ApexPages.currentPage().getParameters().get('market') == 'jp'  && asset.Account.City_Name_Local__c != null ? asset.Account.City_Name_Local__c : asset.Account.billingcity; 
            
            this.city = ApexPages.currentPage().getParameters().get('market') == 'br' ? asset.Account.Name.replaceAll('[0-9]', '').replaceAll('-', '') +' - ' +this.city : this.city;
            
            this.retailerLocalName = asset.Account.NameLocal;
            this.KowloonRetailerPhoneForTel = ((Label.Kowloon_Retailer_PhoneNo).SubStringBefore('/')).replaceAll('[^0-9]', '');
            for(Account acc: [select Id,Website,Phone,Brand__c from Account where ParentId =:accid and Brand__c =:brandValue limit 1]) {
                this.retailerPhone = acc.Phone; 
                if(this.retailerPhone != null)  
                    this.retailerPhoneForTel = (retailerPhone.SubStringBefore('/')).replaceAll('[^0-9]', '');
                
            }
        }
    }
    
    
    public JUDAAN_Campaign__c checkCampaign(Asset tmp,List<JUDAAN_Campaign__c> lstcampaign){
        
        System.debug('lstcampaign----'+lstcampaign);
        System.debug('tmp----'+tmp);
        JUDAAN_Campaign__c newOSAcampaign =  new JUDAAN_Campaign__c ();  
        if(lstcampaign != null && !lstcampaign.isEmpty()){
            for(JUDAAN_Campaign__c campaign : lstcampaign){
                
                //compare 3 criteria not null                    
                if(campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.product2.BodyStyle_Alternative__c 
                   && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.product2.Registration_Year_Alternative__c
                   && campaign.Specification_Pack_Alternative__c   != null  &&  campaign.Specification_Pack_Alternative__c   == tmp.product2.Specification_Pack_Alternative__c
                  ){
                      System.debug('campaign2----'+campaign);
                      newOSAcampaign = campaign;
                      
                  }
                //compare 2 criteria not null   - Body_Style__c and model year                 
                else if (campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.product2.BodyStyle_Alternative__c 
                         && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.product2.Registration_Year_Alternative__c
                         && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                        ){
                            System.debug('campaign3----'+campaign);
                            newOSAcampaign = campaign;
                            
                        }
                
                //compare 2 criteria not null   - Body_Style__c and Specification_Pack_Alternative__c                    
                else if (campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.product2.BodyStyle_Alternative__c 
                         &&  (campaign.Model_Year__c == null || campaign.Model_Year__c == '')
                         && (campaign.Specification_Pack_Alternative__c   != null  &&  campaign.Specification_Pack_Alternative__c   == tmp.product2.Specification_Pack_Alternative__c)
                        ){
                            System.debug('campaign4----'+campaign);
                            newOSAcampaign = campaign;
                            
                        }
                
                //compare 2 criteria not null   - Specification_Pack_Alternative__c  and model year                 
                else if ((campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                         && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.product2.Registration_Year_Alternative__c
                         && (campaign.Specification_Pack_Alternative__c   != null  &&  campaign.Specification_Pack_Alternative__c   == tmp.product2.Specification_Pack_Alternative__c)
                        ){ 
                            System.debug('campaign5----'+campaign);
                            newOSAcampaign = campaign;
                            
                        }
                
                
                //compare 2 criteria not null   - Specification_Pack_Alternative__c  and model year                 
                else if ((campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                         && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.product2.Registration_Year_Alternative__c
                         && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                        ){ 
                            System.debug('campaign5----'+campaign);
                            newOSAcampaign = campaign;
                            
                        }
                
                //compare 1 criteria not null   - Model_Year__c 
                else if(
                    (campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                    && (campaign.Model_Year__c != null &&  campaign.Model_Year__c == tmp.product2.Registration_Year_Alternative__c)
                    && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                ){
                    
                    System.debug('campaign1----'+campaign);
                    newOSAcampaign = campaign;
                    
                }
                
                //compare 1 criteria not null   - Body_Style__c                    
                else if (campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.product2.BodyStyle_Alternative__c 
                         &&  (campaign.Model_Year__c == null || campaign.Model_Year__c == '')
                         && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                        ){
                            System.debug('campaign4----'+campaign);
                            newOSAcampaign = campaign;
                            
                        }
                //compare 1 criteria not null   - Specification_Pack_Alternative__c   
                
                else if(
                    (campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                    && (campaign.Model_Year__c == null || campaign.Model_Year__c == '')
                    && (campaign.Specification_Pack_Alternative__c   != null  && campaign.Specification_Pack_Alternative__c   == tmp.product2.Specification_Pack_Alternative__c)
                ){
                    System.debug('campaign7----'+campaign);
                    newOSAcampaign = campaign;
                    
                }
                //compare 3 criteria  null   - Specification_Pack_Alternative__c   ,Model_Year__c .Body_Style__c  
                
                else if(
                    (campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                    && (campaign.Model_Year__c == null || campaign.Model_Year__c == '')
                    && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                ){
                    System.debug('campaign7----'+campaign);
                    newOSAcampaign = campaign;
                    
                }
            }
            
        } 
        return newOSAcampaign ;
    }

 //Save Enquiry form
    public Boolean IsEmail { get; set; }
    public Boolean IsPhone { get; set; }
    public Boolean IsSMS { get; set; }
    
    
    
    public List<SelectOption> Prefectures2 { get; set; }
    public String Prefecture2 { get; set; }
    public List<SelectOption> Wards2 { get; set; }
    public String Ward2 { get; set; }
    public Map<String, List<String>> PrefectureWardMapping { get; set; }
    public Map<Id, Account> RetailerMap { get; set; }
    
    public void getPrefecureWards() {
        ShowWard = false;
     
        String currentBrand = ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? 'Jaguar' : 'Land Rover';
        String recTypeId = [select Id, Name from RecordType where sObjecttype = 'Account' and Name = 'Retailer' limit 1].Id;
        RetailerMap = new Map<Id, Account> ([select Id, Brand__c,  NameLocal, Address_Local__c, Record_Sub_Type__c, Name, merchant_id__c, service_id__c, c_udaan_marketarea1__c, c_udaan_marketarea2__c, Email_used_for_Udaan__c from Account where RecordTypeId = :recTypeId and Record_Sub_Type__c = 'Branded' and Brand__c = :currentBrand and Region_or_Market__c in ('JAPAN', 'JP')]);
        Map<String, String> PrefectureMap = new Map<String, String>();
        PrefectureMap = JUDAANUtil.getPicklistValues('Account', 'c_udaan_marketarea1__c');
        system.debug('---PrefectureMap ---map11'+PrefectureMap );
        Prefectures2 = new List<SelectOption>();
        Prefectures2.add(new SelectOption('', system.label.SELECT_A_PREFECTURE));
        for(String key : PrefectureMap.keySet())
        {
            Prefectures2.add(new SelectOption(key, PrefectureMap.get(key)));
        }
         system.debug('---Prefecture2---11'+Prefecture2);
        Map<String, String> WardMap = new Map<String, String>();
        WardMap = JUDAANUtil.getPicklistValues('Account', 'c_udaan_marketarea2__c');
        Wards2 = new List<SelectOption>();
        Wards = new List<SelectOption>();
        Wards2.add(new SelectOption('', system.label.SELECT_A_WARD));
        for(String key : WardMap.keySet())
        {
            Wards2.add(new SelectOption(key, WardMap.get(key)));
            Wards.add(new SelectOption(key, WardMap.get(key)));
        }
        
        PrefectureWardMapping = new Map<String, List<String>>();
        for(JUDAAN_Prefecture_Ward__c pw : [select Id, Prefecture__c, Ward__c, Name from JUDAAN_Prefecture_Ward__c ORDER BY Name ASC])
        {
            if(!PrefectureWardMapping.containsKey(pw.Prefecture__c))
            {
                PrefectureWardMapping.put(pw.Prefecture__c, new List<String> { pw.Ward__c });
            }
            else
            {
                PrefectureWardMapping.get(pw.Prefecture__c).add(pw.Ward__c);
            }           
        }
         system.debug('---PrefectureWardMapping---11'+PrefectureWardMapping);
        //Prefecture2 = '';
        Ward2 = '';
        //Message2Retailer = '';
        WardsLabelMap = new Map<String, String>();
        for(SelectOption so : Wards)
        {
            wardsLabelMap.put(so.getValue(), so.getLabel());
        }
          system.debug('---PrefectureWardMapping---1111'+PrefectureWardMapping);
          system.debug('---Prefecture2---22'+Prefecture2);
    }
    public List<SelectOption> Wards { get; set; }
    public Map<String, String> WardsLabelMap { get; set; }
    public Boolean ShowWard { get; set; }
    
    public void filterWards() {
        system.debug('---Prefecture2---33'+Prefecture2);
        Wards2 = new List<SelectOption>();
        Wards2.add(new SelectOption('', system.label.select_a_ward));
        if(PrefectureWardMapping.containsKey(Prefecture2)) {
            for(String ward : PrefectureWardMapping.get(Prefecture2)) {   
                if(wardsLabelMap.containsKey(ward)) {
                    Wards2.add( new SelectOption(ward, WardsLabelMap.get(ward)));
                }
            }
        }
        else {
            searchRetailers();
        }
        
        if(Wards2.size() > 1) {
            ShowWard = true;
        }
        else {
            ShowWard = false;
        }
    }

    public List<SelectOption> Prefectures { get; set; }
    public String Prefecture { get; set; }
    public List<Account> Retailers { get; set; }
    public String SelectedRetailer { get; set; }
    public String NewVehicleRetailerEmail;
    
    public void searchRetailers() {
        Retailers = new List<Account>();
        String currentBrand = this.wrapper.brand == 'jaguar' ? 'Jaguar' : 'Land Rover';
        String recTypeId = [select Id, Name from RecordType where sObjecttype = 'Account' and Name = 'Retailer' limit 1].Id;
        Set<String> selectedPref = new Set<String> { Prefecture2 };
            Set<String> selectedWard = new Set<String> { Ward2 };
                if(!String.isBlank(Prefecture2) ) {
                    if(!PrefectureWardMapping.containsKey(Prefecture2)) {
                        Retailers = [select Id, Email_used_for_Udaan__c, parentid, Merchant_Id__c, Service_Id__c, NameLocal, Address_Local__c from Account where RecordTypeId = :recTypeId and Record_Sub_Type__c = 'Branded' and Brand__c = :currentBrand and Region_or_Market__c in ('JAPAN', 'JP') and c_udaan_marketarea1__c includes (:Prefecture2)];
                    }
                    else {
                        if(!String.isBlank(Ward2)) {
                            Retailers = [select Id, Email_used_for_Udaan__c, parentid, Merchant_Id__c, Service_Id__c, NameLocal, Address_Local__c from Account where RecordTypeId = :recTypeId and Record_Sub_Type__c = 'Branded' and Brand__c = :currentBrand and Region_or_Market__c in ('JAPAN', 'JP') and c_udaan_marketarea1__c includes (:Prefecture2) and c_udaan_marketarea2__c includes (:Ward2)];
                        }
                    }
                    if(Retailers.size() > 0){
                        if(Retailers[0].Parentid!=null && String.valueof(Retailers[0].Parentid)!=''){
                            NewVehicleRetailerEmail =[select id,Email_used_for_Udaan__c from Account WHERE id=:Retailers[0].Parentid limit 1].Email_used_for_Udaan__c;
                        }
                    }
                }
        
        if(Retailers.size() > 0) {
            SelectedRetailer = Retailers[0].Id;
        } else {
            SelectedRetailer = '';
        }
    }
    
    
    public void saveEnquiryform(){
    
       Savepoint sp = Database.setSavepoint();
        try{
                list<string> lststring = new  list<string>();
                system.debug('---IsEmail1111 '+IsEmail );
                
                system.debug('---objcase'+objcase);
                if(IsEmail == true){
                
                lststring.add(Label.Enquiry_Email);
                }
                if(IsPhone == true){
              
                lststring.add(Label.Enquiry_Phone_Number);
                }
                if(IsSMS == true){
               
                lststring.add(Label.Enquiry_Sms);
                }
                

               /*
                
                String nscEmail = '';
                if(market == 'jp'|| market == 'br')
                {
                    nscEmail  = Label.JUDAAN_NSC_Email;
                }
                else if(market =='sg' || market =='hk'){ //enabling hk market
                    nscEmail  = Label.SUDAAN_NSC_Email;
                }
                 else if(market == 'th')
                {
                    nscEmail = Label.TUDAAN_NSC_Email;
                }
                
                if(ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().containskey('brand'))
                objcase.Brand2__c = wrapper.brand = ApexPages.currentPage().getParameters().get('brand');
                */
                wrapper.brand = ApexPages.currentPage().getParameters().get('brand');
                
                EnquiryformAPOSingle objEnquiryformAPOSingle  =  new EnquiryformAPOSingle();
                //objEnquiryformAPOSingle.createCaseforAPOVehicle(objcase,nscEmail  );
                objEnquiryformAPOSingle.createLead(objcase,SelectedRetailer , lststring  );
                objcase = new Case();
                IsEmail = false;
                IsPhone = false;
                IsSMS = false;
                if(wrapper.brand=='landrover'){
                    IsSuccessLandrover=true;
                }
                else if(wrapper.brand=='jaguar'){
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
     public void saveVehicleEnquiryform() {
         SaveVehicleEnquiry vehicleEnquiryObj = new SaveVehicleEnquiry();
         vehicleEnquiry.strleadtype = objCase.type;
         vehicleEnquiry.strDescription = objCase.description;
         System.debug('Inside saveVehicleEnquiryform :: '+vehicleEnquiry.firstName);   
         errorMsg = vehicleEnquiryObj.createLead(vehicleEnquiry,wrapper.vid);
     }
}
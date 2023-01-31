public with sharing Class VehicleSearchController {    

    public VehicleSearchBean bean { get; set; }
    public CreateSavedVehicleDto dto { get; set; }
   public Integer modelCount { get; set; }
   public Integer recommModelCount{ get; set; }
    public SaveVehicleEnquiry vehicleEnquiry {get; set;}
     public String pdpaLink{ get; set; }
    public final String RECOMMEND_RECORDTYPE =Label.Recommended_Choice;
    public final String PROMOTIONAL_BANNER_RECORDTYPE =Label.Promotional_Banner;
    
    public String selectedMarket { get; set; }
    public String ModelStr { get; set; }
    public String EngineStr { get; set; }
    public String ExteriorGroupStr { get; set; }
    public String ExteriorColourStr {get; set; }
    public String interiorColourStr {get; set; }    
    public String specificationStr {get; set;}
    public String optionsStr {get; set;}
    public String DealerLocatorJGLink{get;set;}
    public String DealerLocatorLRLink{get;set;}
    public Boolean isFromScrollVehicle{get;set;}
    public Boolean isDeepColor {get;set;}
    public User loginUser{get; set;}
    public  List<SelectOption> lstState {get;set;}
    public String selectedValue{ get; set; }
    
    public List<SelectOption> getStateValues(){
        System.debug('getStateValues starts');
        List<SelectOption> lstState1  = new List<SelectOption> ();  
        lstState  = new List<SelectOption> ();  
        Set<String> lstAaccount = new VehicleSearch_AssetDao(ApexPages.currentPage().getParameters().get('brand'), ApexPages.currentPage().getParameters().get('market')).getStateValues();
        //List<Account> lstAaccount = [Select RecordType.name,Regional_State_Code__c  from Account  where RecordType.name = 'Retailer' and country_ISO_Code__c =: this.market and Regional_State_Code__c != '' ];
        system.debug('lstAaccount--- '+lstAaccount );
        for(String objAacc : lstAaccount ){ 
            
                   
           SelectOption sa1= new SelectOption(objAacc  , objAacc );
           
           lstState1.add(sa1);
        }
        
       SelectOption sa2= new SelectOption(Label.None_State, Label.None_State );
        lstState.add(sa2);
        lstState1.sort();
        lstState.addAll(lstState1);
         
       System.debug('getStateValues ends');
        return lstState ;
    }
    
    /*
     *  Constructor
     */   
    
    public VehicleSearchController() {
        System.debug('VehicleSearchController Constructor Starts');
        selectedMarket = ApexPages.currentPage().getParameters().get('market');
        getStateValues();
        pdpaLink  = selectedMarket  == 'sg'  ? Label.SG_PDPA : selectedMarket  == 'hk' ?  Label.HK_PDPA :  selectedMarket  == 'th' ?  Label.TH_PDPA  :  '';
        pdpaLink  = ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? pdpaLink : pdpaLink.replace('jaguar', 'landrover'); 
        this.vehicleEnquiry = new SaveVehicleEnquiry();         
        
        isFromScrollVehicle = false;
        isDeepColor = false;
        IsAPO = false;
        DealerLocatorJGLink=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_JG_Link__c   ;
        DealerLocatorLRLink=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_LR_Link__c   ;
        ValidModelFromDx = false;
        
        this.bean = new VehicleSearchBean();
        
        
        this.dto = new CreateSavedVehicleDto();
        
        //this.dto.url = '/VehicleSearch';
        this.dto.url = '/CustomerAccountPage_New';
        this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSearch();
        this.dto.vehicleSearchBean = this.bean;
        
        if('jaguar'.equals(ApexPages.currentPage().getParameters().get('brand')) ){
                    this.bean.selectedBrand = VehicleSearchBean.BRAND_JAGUAR;
        }else{
                this.bean.selectedBrand = VehicleSearchBean.BRAND_LANDROVER;
        }
        
        
       // LoadModels();
    }

    public PageReference switchBrand() {
                this.LoadModels();        
        return( null );
    }
    
    
    // Pre-Dev
    public Boolean IsAPO { get; set; }
    public String Market { get; set; }
    public String CurrencySym{ get; set; }
    public String CustomPath { get; set; }
    public String PathPrefix { get; set; } 
    public PageReference dispatch()
    {   
        System.debug('dispatch starts');
        this.vehicleEnquiry = new SaveVehicleEnquiry();
        modelCount  = 0;
        recommModelCount  = 0;
        Market = JUDAANUtil.getSimpleMarket();
        CurrencySym= JUDAANUtil.getCurrencySymbol();
        if(!ApexPages.currentPage().getParameters().containsKey('brand'))
        {
            String brand;
            String url = Site.getBaseRequestUrl();
            if(url.containsIgnoreCase('jaguar')){
                brand = 'jaguar'; 
            }else {
                brand = 'landrover';
            }
            PageReference p = new PageReference(url);
            p.getParameters().put('brand', brand);
            p.getParameters().put('market', Market);
            p.setRedirect(true);
            System.debug('dispatch ends1');
            return p;
        }
        else
        {
            System.debug('dispatch ends2');
            return LoadModels();
        }

           
        //if(JUDAANUtil.checkAPO())
        //{
        //    return Page.APOVehicleSearch;
        //}
        //else
        //{
        //     return LoadModels();
        //}
    }
    
    public void setStateValues(){
      System.debug( '------------- selectedValue1111'+selectedValue );
      
      string aa = ApexPages.currentPage().getParameters().get('statename');
      
   
       
       
            this.bean.models =null;
            this.bean.recommendedModels = null;
            this.bean.bodyStyles = null;
            this.bean.engines = null;
            this.bean.exteriorGroupColours = null;
            this.bean.exteriorColours = null;
            this.bean.interiorColours = null;
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedModelStr = System.label.Model_FB;
            this.bean.selectedEngineStr = System.label.Engine_FB;
            this.bean.selectedColourStr = System.label.Colour_FB;

            this.bean.selectedOptionStr = System.label.Features_FB;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
       dispatch();
    }
    
    /*
     *  load modesl when initialize
     */
    public Boolean ValidModelFromDx { get; set; }
    public PageReference LoadModels() {
        System.debug('LoadModels starts');
        String svId = ApexPages.currentPage().getParameters().get('id');
        System.debug( '------------- selectedValue222'+selectedValue );
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
       
        this.bean.engineSelector = new VehicleSearchBean.EngineSelector();
        
        /*List<Attachment> attList = AttachmentDao.getAttachmentByParentId(svId);
        
        if(attList.size() != 0){
            VehicleSearchBeanSelectedOnly selectedOnlyBean = (VehicleSearchBeanSelectedOnly)JSON.deserialize(attList.get(0).Body.toString(), VehicleSearchBeanSelectedOnly.class);
                this.bean.setDeserializedBean( selectedOnlyBean );
            System.debug('selectedOnlyBean :::'+selectedOnlyBean);
                //return;
        } else {
                this.bean.init();
        }
        
        */       
        this.bean.init(); 
        String deepModel = ApexPages.currentPage().getParameters().get('model');
        String deepColor = ApexPages.currentPage().getParameters().get('colour');
        
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters(deepModel);
        
       //parameters.inputDeposit = selectedValue;
        //VehicleSearch_Model logic = new VehicleSearch_Model( this.bean.selectedBrand, parameters );


       
        VehicleSearch_Model logic = new VehicleSearch_Model( this.bean.selectedBrand , Market, parameters );
        
        VehicleSearchBean bean = logic.getSelectOptions();

        this.bean.models = this.bean.setCheckedModels( bean.models );
        this.bean.vehicleCount = bean.vehicleCount;
        
        Set<String> validModels = new Set<String>();
         Set<String> ids = new Set<String>();
        for(VehicleSearchBean.Model model : this.bean.models)
        { 
            ids.add( model.productId);
            validModels.add(model.modelName);
            if((model.modelName).equalsIgnoreCase(deepModel))
            {
                ValidModelFromDx = true;
                break;
            }
        }
        List<String> productIds = new List<String>( ids );

        Map<Id, List<JUDAAN_Campaign__c>> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign( productIds,Market,PROMOTIONAL_BANNER_RECORDTYPE );

        for(VehicleSearchBean.Model model : this.bean.models)
        {
            List<JUDAAN_Campaign__c> lstcampaign = campaignMap.get(model.productId);
            if(lstcampaign != null && !lstcampaign.isempty())
            {
                 model.campaignName = Market == 'jp' ? lstcampaign[0].EnglishDescription__c : Label.Special_Offer ;
                 
                
                
              
                model.modelCampaignName = model.modelName;


            }
          }


        if(ValidModelFromDx && deepColor != null && deepColor != '' ) {
             isDeepColor = true;
             LoadBodyStyles();
             scrollColor();
             LoadExteriorDetailColor();
            
        }
        else if(deepColor != null && deepColor != ''){
        //selectAllForModel();
        //selectAllForBodyStyle();
       // selectAllForEngine();
        //selectAllForExteriorGroupColour();



        
        }
        
        //ValidModelFromDx = validModels.contains(deepModel) ? true : false;

        if( (ValidModelFromDx && (deepColor == null || deepColor== '')) ) {
            LoadBodyStyles();
        }
        
        System.debug('LoadModels ends');
        return JUDAANUtil.brandCheck();
        
    }

    /*
     *  load BodyStyles's select options
     */
    public void LoadBodyStyles() {
        System.debug( '------------- loadBodyStyles ' );
         System.debug( '------------- selectedValueLoadBodyStyles'+selectedValue );
         
        if( this.bean.getCheckedModels().isEmpty() ) {
            this.bean.recommendedModels = null;
            this.bean.bodyStyles = null;
            this.bean.engines = null;
            this.bean.exteriorGroupColours = null;
            this.bean.exteriorColours = null;
            this.bean.interiorColours = null;
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedModelStr = System.label.Model_FB;
            this.bean.selectedEngineStr = System.label.Engine_FB;
            this.bean.selectedColourStr = System.label.Colour_FB;
//            this.bean.selectedPriceStr = System.label.Price_FB;
            this.bean.selectedOptionStr = System.label.Features_FB;
             this.bean.selectedSpecificationStr = System.label.Specification_FB;
            
            this.LoadModels();
            
            return;
        }
         
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
       
        
        
        
        modelCount  =  parameters.models.size();
        if(!isFromScrollVehicle ){
        VehicleSearch_RecommendModel Recommendlogic = new VehicleSearch_RecommendModel( this.bean.selectedBrand , Market, parameters );
     
        VehicleSearchBean beanRecommend = Recommendlogic.getSelectOptions();
      
        recommModelCount  =   beanRecommend.vehicleCount;
        System.debug( '-------------recommModelCount  = ' + recommModelCount  );
        this.bean.recommendedmodels = this.bean.setCheckedRecommended( beanRecommend.recommendedmodels );
        System.debug('beanrecommendedmodels---:' + this.bean.recommendedmodels);
        
        }
        //VehicleSearch_BodyStyle logic = new VehicleSearch_BodyStyle( this.bean.selectedBrand , parameters );
        System.debug('bean:' + this.bean);
        VehicleSearch_BodyStyle logic = new VehicleSearch_BodyStyle( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getSelectOptions();
        this.bean.bodyStyles = this.bean.setCheckedBodyStyles( bean.bodyStyles );
        
        //this.bean.vehicles = bean.vehicles;
        

        
        

        this.bean.vehicleCount = bean.vehicleCount;
        

        //  set floating bar label
        this.bean.selectedModelStr = this.setFloatingBarValue( System.label.Model_FB , parameters.models );
        
        if( this.bean.engines != null ) {
            this.LoadEngines();
        }
    }

    /*
     *  load engine's select otpions
     */
    public void LoadEngines() {
        System.debug( '------------- loadEngines ' );

        if( this.bean.getCheckedBodyStyles().isEmpty() ) {
            this.bean.engines = null;
            this.bean.exteriorGroupColours = null;
            this.bean.exteriorColours = null;
            this.bean.interiorColours = null;
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedEngineStr = System.label.Engine_FB;
            this.bean.selectedColourStr = System.label.Colour_FB;
//            this.bean.selectedPriceStr = System.label.Price_FB;
            this.bean.selectedOptionStr = System.label.Features_FB;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
            
            this.LoadBodyStyles();
            
            return;
        }
          System.debug( '------------- checked selectedValue=333 ' + selectedValue );
          ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        this.loadEngines( parameters , false );
    }

    /*
     *  load engine for engine selector
     */
    public void advancedSearch() {
        System.debug( '------------- advancedSearch ' );
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        parameters.selectedFuel = this.bean.engineSelector.selectedFuel;
        parameters.selectedDrive = this.bean.engineSelector.selectedDrive;
        parameters.selectedEngineSize = this.bean.engineSelector.selectedEngineSize;
        parameters.selectedTransmission = this.bean.engineSelector.selectedTransmission;
        
        this.loadEngines( parameters , true );
    }

    /*
     *  load engine logic
     */
    private void loadEngines( VehicleSearchInputParameters parameters , Boolean isReload ) {
                System.debug( '--------------- private loadEngines' );
        
        //VehicleSearch_Engine logic = new VehicleSearch_Engine( this.bean.selectedBrand , parameters );
        VehicleSearch_Engine logic = new VehicleSearch_Engine( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getSelectOptions();
        this.bean.engines = this.bean.setCheckedEngines( bean.engines );
        
         this.bean.vehicleCount = bean.vehicleCount;

        
        
        if( ! isReload ) {
            this.bean.engineSelector = new VehicleSearchBean.EngineSelector();
            this.bean.engineSelector.fuels = logic.getFuelOptions();
            this.bean.engineSelector.drives = logic.getDriveOptions();
            this.bean.engineSelector.engineSizes = logic.getEngineSizeOptions();
            this.bean.engineSelector.transmissions = logic.getTransmissionOptions();
        }
        
        //  set floating bar label
        //this.bean.selectedEngineStr = this.setFloatingBarValue( System.label.Engine_FB , parameters.engines ).replaceAll( '_' , ' ' );

        if( this.bean.exteriorGroupColours != null ) {
            this.LoadExteriorColor();
        }
    }


    /*
     *  load exterior group colours by engine
     */    
    public void LoadExteriorColor() {




        
        if( this.bean.getCheckedEngines().isEmpty() ) {
            this.bean.exteriorGroupColours = null;
            this.bean.exteriorColours = null;
            this.bean.interiorColours = null;
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedEngineStr = System.label.Engine_FB;
            this.bean.selectedColourStr = System.label.Colour_FB;
//            this.bean.selectedPriceStr = System.label.Price_FB;
            this.bean.selectedOptionStr = System.label.Features_FB;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
            
            this.advancedSearch();
            
            return;
        }
        
          System.debug( '------------- checked selectedValue=5555' + selectedValue );
          ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
         if(ApexPages.currentPage().getParameters().get('colour') != null)
         parameters.deepColor = ( ApexPages.CurrentPage().getParameters().get('colour') );
         
        //VehicleSearch_ExteriorColors logic = new VehicleSearch_ExteriorColors( this.bean.selectedBrand , parameters );
        VehicleSearch_ExteriorColors logic = new VehicleSearch_ExteriorColors( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getExteriorGroupColourOptions();
        this.bean.exteriorGroupColours = this.bean.setCheckedExteriorGroupColours( bean.exteriorGroupColours );
        
        
          this.bean.vehicleCount = bean.vehicleCount;

        //  set floating bar label
        //this.bean.selectedEngineStr = this.setFloatingBarValue( System.label.Engine_FB , parameters.engines ).replaceAll( '_' , ' ' );
        this.bean.selectedEngineStr = this.setFloatingBarValue( System.label.Engine_FB , this.bean.setCheckedEngines( this.bean.engines ) );
        
        System.debug( '--------------- LoadExteriorColour vehicleCount = ' + this.bean.vehicleCount );
       
        if( this.bean.exteriorColours != null ) {
            this.loadExteriorDetailColor();
        }
    }


    /*
     *  load exterior detail colours by group colours 
     */
    public void LoadExteriorDetailColor() {
        System.debug( '------------- loadExteriorDetailColor ' );
        if( this.bean.getCheckedExteriorGroupColours().isEmpty() ) {
            System.debug( '------------- loadExteriorDetailColor group colour deselected' );
            this.bean.exteriorColours = null;
            this.bean.interiorColours = null;
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedColourStr = System.label.Colour_FB;
//            this.bean.selectedPriceStr = System.label.Price_FB;
            this.bean.selectedOptionStr = System.label.Features_FB;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
            
            this.LoadExteriorColor();

            return;
        }
       
          System.debug( '------------- checked selectedValue6666 ' + selectedValue );
          ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        
        //VehicleSearch_ExteriorColors logic = new VehicleSearch_ExteriorColors( this.bean.selectedBrand , parameters );
        VehicleSearch_ExteriorColors logic = new VehicleSearch_ExteriorColors( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getExteriorDetailColourOptions();
        if( bean.exteriorColours == null || bean.exteriorColours.isEmpty() ) {
            return;
        }
        this.bean.exteriorColours = this.bean.setCheckedExteriorColours( bean.exteriorColours );
        
          this.bean.vehicleCount = bean.vehicleCount;
        
          System.debug( '--------------- LoadExteriorDetailColor = ' + this.bean.vehicleCount );
        if( this.bean.interiorColours != null ) {
            this.LoadInteriorColor();
        }
    }

    /*
     *  load interior detail colours by exterior detail colours 
     */
    public void LoadInteriorColor() {
        System.debug( '------------------ loadInteriorColour' );
        if( this.bean.getCheckedExteriorColours().isEmpty() ) {
            this.bean.interiorColours = null;
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;   
            this.bean.selectedColourStr = System.label.Colour_FB;
//            this.bean.selectedPriceStr = System.label.Price_FB;
            this.bean.selectedOptionStr = System.label.Features_FB;
             this.bean.selectedSpecificationStr = System.label.Specification_FB;
            
            this.LoadExteriorDetailColor();
            
            return;
        }
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        
        //VehicleSearch_InteriorColors logic = new VehicleSearch_InteriorColors( this.bean.selectedBrand , parameters );
        VehicleSearch_InteriorColors logic = new VehicleSearch_InteriorColors( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getInteriorColourOptions();
        this.bean.interiorColours = this.bean.setCheckedInteriorColours( bean.interiorColours );
        
          System.debug( '--------------- LoadInteriorColor= ' + this.bean.vehicleCount );
           this.bean.vehicleCount = bean.vehicleCount;
        
        //  set floating bar label
        List<String> exteriorColours = new List<String>();
        for( VehicleSearchBean.ExteriorColour colour : this.bean.exteriorColours ) {
            if( colour.checked ) {
                exteriorColours.add( colour.colourName );
            }
        }

        System.debug( '------------ exteriorColours = ' + exteriorColours );

        //  show floating bar
        //this.bean.selectedColourStr = this.setFloatingBarValue( System.label.Colour_FB , exteriorColours );
        this.bean.selectedColourStr = this.setFloatingBarValue( System.label.Colour_FB , this.bean.setCheckedExteriorColours( this.bean.exteriorColours ) );
       
        System.debug( '--------------- LoadInteriorColor interiorColours.size() = ' + this.bean.interiorColours.size() );

        if( this.bean.specifications != null ) {
            this.LoadSpecs(); 
        } 
    }

    public void LoadBudget() {
        // calculate the total price and narrow down the asset list to budgetLisy
        System.debug( '------------- LoadBudget ' );
        this.scrollPrice();
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        parameters.selectedPaymentType = this.bean.paymentSelector.selectedType;
        parameters.inputMonthlyBudget = this.bean.paymentSelector.selectedBudget;
        parameters.inputDeposit = this.bean.paymentSelector.selectedDeposit; 
        parameters.inputTradeinvalue = this.bean.paymentSelector.selectedTradeinvalue;
        VehicleSearchBean searchBean = new VehicleSearchBean();
        if(Market== 'jp'){
            VehicleSearch_Budget logic = new VehicleSearch_Budget( this.bean.selectedBrand , parameters );
            searchBean = logic.getBudget();
        }
        // enabling hk market 
        if(Market== 'sg'|| Market== 'hk' || Market == 'br'|| Market == 'th'){ 
            Integer tradeInPrice = 0 ;
            Integer depositAmt = 0;
            Integer monthlyInst = 0;
            Integer noOfpayment =0;
            Integer minHKBudget = 0;
            if(!String.isBlank(bean.paymentSelector.selectedTradeinvalue)){
                tradeInprice = Integer.valueOf((bean.paymentSelector.selectedTradeinvalue).remove(','));
            }
            if(!String.isBlank(bean.paymentSelector.selectedDeposit)){
                depositAmt = Integer.valueOf((bean.paymentSelector.selectedDeposit).remove(','));
            }
            Integer downpayment = tradeInprice + depositAmt ;
            
             if(!String.isBlank(bean.paymentSelector.selectedBudget)){
                monthlyInst = Integer.valueOf((bean.paymentSelector.selectedBudget).remove(','));
            }
             if(!String.isBlank(bean.paymentSelector.selectedType)){
                noOfpayment = Integer.valueOf((bean.paymentSelector.selectedType).remove(','));
            }
            
            // Call method for calculating vehicle price under budget section for Singapore
            Decimal localPrice = SGFinanceCalculator.calculateLocalPriceforBudget(monthlyInst,downpayment,noOfpayment);
            searchBean.budget = Integer.valueOf(localPrice);
           if(!String.isBlank(bean.paymentSelector.selectedMinbudget))
            {
             minHKBudget = Integer.valueOf((bean.paymentSelector.selectedMinbudget).remove(',')); 
             this.bean.minBudget = minHKBudget;  
             System.debug('minBudget :: '+minHKBudget);
            }
            else
                this.bean.minBudget = minHKBudget;
        }
        
        this.bean.paymentSelector.selectedBudget = StringUtil.formatCurrency( this.bean.paymentSelector.selectedBudget );
        this.bean.paymentSelector.selectedDeposit = StringUtil.formatCurrency( this.bean.paymentSelector.selectedDeposit ); 
        this.bean.paymentSelector.selectedTradeinvalue = StringUtil.formatCurrency( this.bean.paymentSelector.selectedTradeinvalue );
        this.bean.budget = searchBean.budget;
              
        //  set floating bar label
        this.bean.selectedPriceStr = CurrencySym + ' ' + bean.budget.format();
        this.bean.decidedBudget = true;
        
        if( this.bean.budget != null ) {
            //this.LoadSpecs();
            this.LoadAvailableVehicle();
        }
    }

    public void clearBudget() {
        System.debug( '------------- clearBudget ' );
        this.scrollPrice();
        {
                        this.bean.budget = null;
                this.bean.paymentSelector.selectedType = null;
            this.bean.paymentSelector.selectedBudget = null;
            this.bean.paymentSelector.selectedDeposit = null;
            this.bean.paymentSelector.selectedBonus = null;
            this.bean.paymentSelector.selectedTradeinvalue = null;
            //  set floating bar label
            this.bean.selectedPriceStr = System.label.Price_FB;
        }
                this.bean.decidedBudget = true;

        //  set floating bar label
        this.bean.selectedPriceStr = System.Label.Unset;
        
                //Commented for special vehicle
                //this.LoadAvailableVehicle();
    }
    
    public void deloadSpecs() {
        System.debug( '------------------ deloadSpecs' );
        if( this.bean.getCheckedInteriorColours().isEmpty() ) {
            System.debug( '------------------ loadSpecs interior colours is empty' );
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedOptionStr = System.label.Features_FB;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
            return;
        } else if( this.bean.specifications != null ) {
            this.LoadSpecs();
        }        
    }
    
    /*
     *  load specification colours by exterior detail colours 
     */
    public void LoadSpecs() {
        System.debug( '------------------ loadSpecs' );
        /*if( ! this.bean.decidedBudget ) {
            return;
        }*/
        
        if( this.bean.getCheckedInteriorColours().isEmpty() ) {
            System.debug( '------------------ loadSpecs interior colours is empty' );
            this.bean.specifications = null;
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedOptionStr = System.label.Features_FB;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
            
            this.LoadInteriorColor();
            
            return;
        }
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        
        //VehicleSearch_Specification logic = new VehicleSearch_Specification( this.bean.selectedBrand , parameters );
        VehicleSearch_Specification logic = new VehicleSearch_Specification( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getSpecificationOptions();
        this.bean.specifications = this.bean.setCheckedSpecifications( bean.specifications );
        
          this.bean.vehicleCount = bean.vehicleCount;
        

        if( this.bean.options != null ) {
            this.LoadOptions(); 
        }        
    }

    /*
     *  load options colours by exterior detail colours 
     */
    public void LoadOptions() {
        System.debug( '------------------ loadOptions' );
        if( this.bean.getCheckedSpecifications().isEmpty() ) {
            //System.debug( '------------------ checked specification is empty.' );
            this.bean.options = null;
            this.bean.vehicles = null;
            this.bean.selectedSpecificationStr = System.label.Specification_FB;
            this.bean.selectedOptionStr = System.label.Features_FB;
            
            this.LoadSpecs();
            
            return;
        }
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        
        //VehicleSearch_Option logic = new VehicleSearch_Option( this.bean.selectedBrand , parameters );
        VehicleSearch_Option logic = new VehicleSearch_Option( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getOptionOptions();
        this.bean.options = this.bean.setCheckedOptions( bean.options );
        
        
           this.bean.vehicleCount = bean.vehicleCount;
        
        this.bean.selectedSpecificationStr = this.setFloatingBarValue( System.label.Specification_FB , this.bean.setCheckedSpecifications( this.bean.specifications ) );
        //this.bean.selectedSpecificationStr = this.setFloatingBarValue(System.label.Specification_FB, parameters.specifications);

        if( this.bean.vehicles != null ) {
            this.LoadAvailableVehicle();
        }
    }

    public void selectOption() {
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
        //VehicleSearch_AvailableVehicle logic = new VehicleSearch_AvailableVehicle( this.bean.selectedBrand , parameters );
        VehicleSearch_AvailableVehicle logic = new VehicleSearch_AvailableVehicle( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getAvailableVehicles();
        this.bean.vehicleCount = bean.vehicles.size();
       
        
        if( this.bean.decidedBudget ) {
            this.LoadAvailableVehicle();
        }
    }
     /* to get logged in user account id*/
      public void getLoginUser(){
        List<User> uList = UserDao.getUdaanActiveUserById(UserInfo.getUserId());
        for(User u : uList){
            this.loginUser = u;
        }
      }
    /*
     *  load available vehicle 
     */
     
    public  void LoadAvailableVehicle() {
        System.debug( '------------------ loadAvailableVehicle' );
        system.debug('$$$$$ this bean:' + this.bean);

        getLoginUser();
        
          string specialVehicle =  ApexPages.currentPage().getParameters().get('specialmodel');
        if( this.bean.getCheckedSpecifications().isEmpty() && (specialVehicle == null || specialVehicle == '') ) {
           // this.bean.vehicles = null;
           // this.LoadOptions();
           // return;
        }
        ApexPages.currentPage().getParameters().put('statename',selectedValue);
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters( this.bean );
          system.debug('---parameters' + parameters);
        //VehicleSearch_AvailableVehicle logic = new VehicleSearch_AvailableVehicle( this.bean.selectedBrand , parameters );
        VehicleSearch_AvailableVehicle logic = new VehicleSearch_AvailableVehicle( this.bean.selectedBrand , Market, parameters );
        VehicleSearchBean bean = logic.getAvailableVehicles();
        this.bean.vehicles = bean.vehicles;
        system.debug('$$$$ bean vehicles:' + bean.vehicles);
        
         this.bean.vehicleCount = this.bean.vehicles.size();
        


        //      join Campaign
        {
            Set<String> ids = new Set<String>();
            // saved vehicle multiple times
            String brandvalue;
            if(ApexPages.currentPage().getParameters().get('brand') == 'landrover')
                 brandvalue = 'Land Rover';
            else
                brandvalue = ApexPages.currentPage().getParameters().get('brand');
                
            List<Saved_Vehicle_for_Lead__c> svLeadList = SavedVehicleDao.getSavedVehicleForLeadByAccountId(this.loginUser.AccountId, brandvalue);
            
            
                for( VehicleSearchBean.Vehicle tmp : this.bean.vehicles ) {
                    ids.add( tmp.productId );
                    if(svLeadList != null && !svLeadList.isEmpty()){
                    tmp.isVehicleSaved = false;
                    for(Saved_Vehicle_for_Lead__c saveVehicleobj :svLeadList)
                    {   
                        if(saveVehicleobj.Saved_Vehicle__c == tmp.vehicleId)
                            tmp.isVehicleSaved = true;
                    }
                    }
                }
            
               
               List<String> productIds = new List<String>( ids );
              // if(!productIds.isEmpty()){
                   Map<Id, List<JUDAAN_Campaign__c>> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign( productIds,Market,PROMOTIONAL_BANNER_RECORDTYPE );
             system.debug('-campaignMap --'+campaignMap );
                      /*  for( VehicleSearchBean.Vehicle tmp: this.bean.vehicles ) {
                            JUDAAN_Campaign__c campaign = campaignMap.get( tmp.productId );
                            if( campaign != null ) {
                                if( 'ja'.equals( this.bean.selectedLanguage ) ) {
                                    tmp.campaign = campaign.JapaneseDescription__c;    
                                } else {
                                    tmp.campaign = campaign.EnglishDescription__c;    
                                }
                                tmp.campaignUrlText =campaign.Campaign_Url_Text__c;
                                
                            }
                        }*/
                        
            
            
                              system.debug('-specialVehicle --'+specialVehicle );
                         for(Integer i= this.bean.vehicles.size() - 1; i>= 0 ; i-- ) {
                             // for( VehicleSearchBean.Vehicle tmp: this.bean.vehicles ) {
                            
                                VehicleSearchBean.Vehicle tmp = this.bean.vehicles[i]; 
                                 
                                system.debug('--111-v'+tmp);
                                List<JUDAAN_Campaign__c> lstcampaign = campaignMap.get(tmp.productId);
                                System.debug('lstcampaign ----'+lstcampaign );
                                 Map<string,string> mapAssetIdtoCampaignText = new Map<string,string>();
                                
                                List<String> lstcampaignText = new List<string>();
                                
                                JUDAAN_Campaign__c newOSAcampaign  = checkCampaign(tmp,lstcampaign );
                                if(newOSAcampaign.VIN_Asset_Level_ID__c != null ){
                                 
                                    List<String> lstAssetID =   newOSAcampaign.VIN_Asset_Level_ID__c.contains(',') ? newOSAcampaign.VIN_Asset_Level_ID__c.split(',') : new List<string> {newOSAcampaign.VIN_Asset_Level_ID__c} ;
                                    system.debug('---newOSAcampaign.VIN_Asset_Level_ID__c'+newOSAcampaign.VIN_Asset_Level_ID__c);
                                        if(lstAssetID != null ){
                                        lstcampaignText = newOSAcampaign.VIN_Level_Campaign_Text__c.contains(',') ? newOSAcampaign.VIN_Level_Campaign_Text__c.split(',') : new List<string>{newOSAcampaign.VIN_Level_Campaign_Text__c};
                                        
                                            if(lstcampaignText != null)
                                            for(Integer j= lstAssetID.size()-1; j>= 0 ; j--){
                                               String strassetid =  lstAssetID[j];
                                                String strCampaignText =  lstcampaignText.size()== 1 ? lstcampaignText[0] : lstcampaignText[j];
                                                mapAssetIdtoCampaignText.put(strassetid,strCampaignText );
                                                
                                            }
                                        
                                        
                                        }
                                    
                                    
                                }
                                system.debug('--mapAssetIdtoCampaignText'+mapAssetIdtoCampaignText);
                                if(specialVehicle != null && specialVehicle != ''&& newOSAcampaign != null ){
                                      if((newOSAcampaign.Model_Year__c ==tmp.modelYearFormat 
                                      
                                      || newOSAcampaign.Body_Style__c == tmp.bodyStyle
                                 
                                      || newOSAcampaign.Specification_Pack_Alternative__c ==tmp.specification
                                      || newOSAcampaign.Model_Year__c != null 
                                       || newOSAcampaign.Body_Style__c != null
                                       || newOSAcampaign.Specification_Pack_Alternative__c != null)
                                      
                                       
                                       || newOSAcampaign.product__c != null 
                                      
                                      
                                      ){
                                       
                                        
                                       if( 'ja'.equals( this.bean.selectedLanguage ) ) {
                                            tmp.campaign = newOSAcampaign.JapaneseDescription__c;    
                                        } else {
                                            tmp.campaign = !mapAssetIdtoCampaignText.containsKey(tmp.assetVIN) ? newOSAcampaign.EnglishDescription__c : mapAssetIdtoCampaignText.get(tmp.assetVIN);    
                                        }
                                        tmp.campaignUrlText =newOSAcampaign.Campaign_Url_Text__c;
                                        system.debug('-specialVehicle --'+specialVehicle );
                                        }
                                        else{
                                        system.debug('-specialVehicle11111 --'+tmp.vehicleid);
                                        this.bean.vehicles.remove(i);
                                        
                                        }      
                                       
                                
                                }
                                else if( newOSAcampaign != null  ) {
                                        if( 'ja'.equals( this.bean.selectedLanguage ) ) {
                                            tmp.campaign = newOSAcampaign.JapaneseDescription__c;    
                                        } else {
                                            tmp.campaign = !mapAssetIdtoCampaignText.containsKey(tmp.assetVIN) ? newOSAcampaign.EnglishDescription__c : mapAssetIdtoCampaignText.get(tmp.assetVIN);        
                                        }
                                        tmp.campaignUrlText =newOSAcampaign.Campaign_Url_Text__c;
                                        
                                 }
                        }//for    
                }
        //}productid
        
        this.bean.vehicleCount = this.bean.vehicles.size();
        
        
        
        List<String> optionNames = new List<String>();
        if(this.bean.options != null){
        for( VehicleSearchBean.Option option : this.bean.options ) {
            if( option.checked ) {
                    optionNames.add( option.translatedName );
            }
        }
        
        //  set floating bar label
        this.bean.selectedOptionStr = this.setFloatingBarValue( System.label.Features_FB , optionNames );
       }
        System.debug( '------------ vehicles = ' + this.bean.vehicles );
        
    }

   /*
     *  set campaign Value
     */
        public JUDAAN_Campaign__c  checkCampaign(VehicleSearchBean.Vehicle tmp,List<JUDAAN_Campaign__c> lstcampaign){
                system.debug('---lstcampaign'+lstcampaign);
                 system.debug('---v'+tmp);
      
                JUDAAN_Campaign__c newOSAcampaign =  new JUDAAN_Campaign__c ();  
                if(lstcampaign != null && !lstcampaign.isEmpty()){
                for(JUDAAN_Campaign__c campaign : lstcampaign){
                     
                    //compare 3 criteria not null                    
                    if(campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.bodystyle
                        && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.modelYearFormat
                        && campaign.Specification_Pack_Alternative__c   != null  &&  campaign.Specification_Pack_Alternative__c   == tmp.specification
                        ){
                         System.debug('campaign2----'+campaign);
                         newOSAcampaign = campaign;
                     
                    }
                     //compare 2 criteria not null   - bodystyle and model year                 
                    else if (campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.bodystyle
                        && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.modelYearFormat
                        && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                        ){
                         System.debug('campaign3----'+campaign);
                          newOSAcampaign = campaign;
                     
                    }
                    
                     //compare 2 criteria not null   - bodystyle and Specification_Pack_Alternative__c                    
                    else if (campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.bodystyle
                        &&  (campaign.Model_Year__c == null || campaign.Model_Year__c == '')
                        && (campaign.Specification_Pack_Alternative__c   != null  &&  campaign.Specification_Pack_Alternative__c   == tmp.specification)
                        ){
                         System.debug('campaign4----'+campaign);
                          newOSAcampaign = campaign;
                     
                    }
                    
                     //compare 2 criteria not null   - Specification_Pack_Alternative__c  and model year                 
                    else if ((campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                        && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.modelYearFormat
                        && (campaign.Specification_Pack_Alternative__c   != null  &&  campaign.Specification_Pack_Alternative__c   == tmp.specification)
                        ){ 
                          System.debug('campaign5----'+campaign);
                          newOSAcampaign = campaign;
                     
                    }
                      
                    
                      //compare 2 criteria not null   - Specification_Pack_Alternative__c  and model year                 
                    else if ((campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                        && campaign.Model_Year__c   != null  && campaign.Model_Year__c   == tmp.modelYearFormat
                        && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                        ){ 
                          System.debug('campaign5----'+campaign);
                          newOSAcampaign = campaign;
                     
                    }
                    
                     //compare 1 criteria not null   - Model_Year__c 
                    else if(
                        (campaign.Body_Style__c  == null  || campaign.Body_Style__c  == '')
                        && (campaign.Model_Year__c != null &&  campaign.Model_Year__c == tmp.modelYearFormat)
                        && (campaign.Specification_Pack_Alternative__c   == null  || campaign.Specification_Pack_Alternative__c   == '')
                        ){
                        
                          System.debug('campaign1----'+campaign);
                          newOSAcampaign = campaign;
                     
                    }
                    
                       //compare 1 criteria not null   - bodystyle                    
                    else if (campaign.Body_Style__c  != null  && campaign.Body_Style__c  == tmp.bodystyle
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
                        && (campaign.Specification_Pack_Alternative__c   != null  && campaign.Specification_Pack_Alternative__c   == tmp.specification)
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


/*
 *     public void ShowMoreDetails() {
    }
*/
    /*
     *  set FloatingBar Value
     */
    private String setFloatingBarValue( String label , List<String> selected ) {
        String returnValue;
        if( selected.size() < 1 ) {
            returnValue = label;
        } else if( selected.size() == 1 ) {
            returnValue = selected.get( 0 );
        } else {
            returnValue = String.valueOf( selected.size() );
        }
       
        return( returnValue ); 
    }

    private String setFloatingBarValue( String label , List<VehicleSearchBean.SearchSection> options ) {
        String selected;
        Integer checkedCount = 0;
        for( VehicleSearchBean.SearchSection tmp : options ) {
            if( tmp.checked ) {
                selected = tmp.getValue();
                checkedCount++;
            }
        }
        
        String returnValue;
        if( checkedCount < 1 ) {
            returnValue = label;
        } else if( checkedCount == 1 ) {
            returnValue = selected;
        } else {
            returnValue = String.valueOf( checkedCount );
        }
       
        return( returnValue ); 
    }
    
    /*public void save() {
        Savepoint sp = Database.setSavepoint();
        try{
        
      
                this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
                this.dto.urlParameterMap = new Map<String, String>();
                if(bean.selectedBrand == 'Jaguar'){
                        this.dto.urlParameterMap.put('brand', 'jaguar');
                }else{
                        this.dto.urlParameterMap.put('brand' , 'landrover');
                }
                this.dto.urlParameterMap.put('lang', this.bean.selectedLanguage);
                //if(JUDAANUtil.RunningInAsandbox())
                //{
                    this.dto.urlParameterMap.put('market', Market);
                //}
                this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSearch();
                this.dto.createSavedVehicle.create(this.dto);
        }catch(Exception e){
                Database.rollback(sp);
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
        }
    }*/
    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        PageReference myaccount = Page.CustomerAccountPage_New;
        try{
                this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
                this.dto.urlParameterMap = new Map<String, String>();
                if(bean.selectedBrand == 'Jaguar'){
                        this.dto.urlParameterMap.put('brand', 'jaguar');
                        myaccount.getParameters().put('brand', 'jaguar');
                }else{
                        this.dto.urlParameterMap.put('brand' , 'landrover');
                        myaccount.getParameters().put('brand', 'landrover');
                }
                this.dto.urlParameterMap.put('lang', this.bean.selectedLanguage);
                myaccount.getParameters().put('lang', this.bean.selectedLanguage);
                //if(JUDAANUtil.RunningInAsandbox())
                //{
                    this.dto.urlParameterMap.put('market', Market);
                    myaccount.getParameters().put('market', Market);
                //}
                this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSearch();
                this.dto.createSavedVehicle.create(this.dto);
                myaccount.setRedirect(true);
                return myaccount;
                
        }catch(Exception e){
                Database.rollback(sp);
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                return null;
        }
    }
    
    public PageReference showDetail() {
        String assetId = ApexPages.currentPage().getParameters().get('assetId');
        String isRecommend = ApexPages.currentPage().getParameters().get('isRecommended');
        String isSpecial = ApexPages.currentPage().getParameters().get('isSpecial');
        String isFeature= ApexPages.currentPage().getParameters().get('isFeature');
        String order = ApexPages.currentPage().getParameters().get('orderNo');
        system.debug('isFeature'+isFeature);
        
        //Saved_Vehicle_for_Lead__c savedVehicle = new Saved_Vehicle_for_Lead__c();
        //insert savedVehicle;
        
        //Blob b = Blob.valueOf(JSON.serialize(new VehicleSearchBeanSelectedOnly(this.dto.vehicleSearchBean)));
        //Attachment att = new Attachment();
        //att.Name = 'Bean Class.json';
        //att.ParentId = savedVehicle.Id;
        //att.Body = b;
        //insert att;
        
        PageReference p = Page.VehicleSingle;
        p.getParameters().put('id' , assetId);
        //p.getParameters().put('svid' , savedVehicle.Id);
        //if(isRecommend  != null && isRecommend != '')
        //p.getParameters().put('isRecomm' ,isRecommend );
        
        //if(isFeature != null && isFeature != '')
        //p.getParameters().put('isFeature' ,'true');
        
        
        if(isSpecial != null && isSpecial != '')
        p.getParameters().put('isSpecial' , 'true' );
        if(order != null)
        p.getParameters().put('order' ,order);
        if(bean.selectedBrand == 'Jaguar'){
                p.getParameters().put('brand' , 'jaguar');
        }else{
                p.getParameters().put('brand' , 'landrover');
        }
        p.getParameters().put('lang', this.bean.selectedLanguage);
        
        String strState= ApexPages.currentPage().getParameters().get('statename');
        if(strState == Label.None_State)
        selectedValue = 'None';
        
        p.getParameters().put('state' , selectedValue);
        
        //if(JUDAANUtil.RunningInAsandbox())
        //{
            p.getParameters().put('market', Market);
        //}
        return p;
    }
    
    public void setAssetIdToDtoClass(){   
        this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
        this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSearch();
        this.dto.urlParameterMap = new Map<String, String>();
        if(bean.selectedBrand == 'Jaguar'){
                this.dto.urlParameterMap.put('brand', 'jaguar');
        }else{
                this.dto.urlParameterMap.put('brand' , 'landrover');
        }
        this.dto.urlParameterMap.put('lang', this.bean.selectedLanguage);
        //if(JUDAANUtil.RunningInAsandbox())
        //{
            this.dto.urlParameterMap.put('market', Market);
        //}
        //this.dto.url = '/VehicleSearch';
    }
    
    private void selectAllForModel(){
        if(this.bean.getCheckedModels().size() == 0 && this.bean.models != null ){
                for(VehicleSearchBean.Model model : this.bean.models){
                        if(model.available){
                                model.checked = true;
                        }
                       
                }
                isFromScrollVehicle = true;
                this.loadBodyStyles();
        }
    }
    
    private void selectAllForBodyStyle(){
        if(this.bean.getCheckedBodyStyles().size() == 0 && this.bean.bodyStyles != null ){
                for(VehicleSearchBean.BodyStyle style : this.bean.bodyStyles){
                        style.checked = true;
                }
                this.loadEngines();
        }
    }
    
    private void selectAllForEngine(){
        if(this.bean.getCheckedEngines().size() == 0 && this.bean.engines != null ){
                for(VehicleSearchBean.Engine engine : this.bean.engines){
                        engine.checked = true;
                }
                this.loadExteriorColor();
        }
    }
    
    private void selectAllForExteriorGroupColour(){
        if(this.bean.getCheckedExteriorGroupColours().size() == 0 && this.bean.exteriorGroupColours != null ){
                for(VehicleSearchBean.ExteriorGroupColour eGroupColor : this.bean.exteriorGroupColours){
                        eGroupColor.checked = true;
                }
                this.LoadExteriorDetailColor();
        }
    }
    
    private void selectAllForExteriorColour(){
        if(this.bean.getCheckedExteriorColours().size() == 0 && this.bean.exteriorColours != null ){
                for(VehicleSearchBean.ExteriorColour eColor : this.bean.exteriorColours){
                        eColor.checked = true;
                }
                this.LoadInteriorColor();
        }
    }
    
    private void selectAllForInteriorColour(){
        if(this.bean.getCheckedInteriorColours().size() == 0 && this.bean.interiorColours != null ){
                for(VehicleSearchBean.InteriorColour iColor : this.bean.interiorColours){
                        iColor.checked = true;
                }
                this.LoadSpecs();
        }
    }
    
    private void selectAllForSpecification(){
        if(this.bean.getCheckedSpecifications().size() == 0 && this.bean.specifications != null ){
                for(VehicleSearchBean.Specification sf : this.bean.specifications){
                        sf.checked = true;
                }
                this.LoadOptions();
        }
    }
    
    public void scrollEngine(){
        this.selectAllForModel();
      
        this.selectAllForBodyStyle();
    }
    
    public void scrollColor(){
        this.scrollEngine();
        this.selectAllForEngine();
    }
    
    public void scrollExtOptionColor(){
         //LoadBodyStyles();
             
        this.scrollColor();
        //this.selectAllForExteriorGroupColour();
        LoadExteriorDetailColor();
        //selectAllForExteriorColour();
        
    }
     public void scrollSpecification(){
        /*if(System.label.Price_FB.equals(this.bean.selectedPriceStr)){
                //this.LoadBudget();
                this.clearBudget();
        }*/
        this.scrollColor();
        this.selectAllForExteriorGroupColour();
        this.selectAllForExteriorColour();
        this.selectAllForInteriorColour();
    }
    
    public Boolean FromHeader { get; set; }
    public void scrollPrice(){
        FromHeader = ApexPages.currentPage().getParameters().get('fromHeader') == '0' ? true : false;
        this.scrollSpecification();
        this.selectAllForSpecification();
                        
    }
    
     public void specialVehicleLst(){
        this.LoadBodyStyles();  
        //Commented for special vehicle
       // this.scrollPrice();
      /*  if(System.label.Price_FB.equals(this.bean.selectedPriceStr)){
                //this.LoadBudget();
                this.clearBudget();
        }*/
        this.LoadAvailableVehicle();
        
    }
    public void scrollVehicleList(){
       System.debug('scrollVehicleList starts');
       //if(ApexPages.CurrentPage().getParameters().containskey( 'modelname') &&  ApexPages.CurrentPage().getParameters().get( 'modelname') != null )
       //specialVehicleLst();
       //else
       {
        // this.scrollPrice();
        //Commented for special vehicle
        if(System.label.Price_FB.equals(this.bean.selectedPriceStr)){
                //this.LoadBudget();
                this.clearBudget();
        }
        this.bean.selectedPriceStr = System.label.Price_FB;
        this.LoadAvailableVehicle();
        }
        System.debug('scrollVehicleList ends');
    }
    
    public PageReference restartSearch(){
        PageReference p = Page.VehicleSearch;
        if(bean.selectedBrand == 'Jaguar'){
                p.getParameters().put('brand' , 'jaguar');
        }else{
                p.getParameters().put('brand' , 'landrover');
        }
        p.getParameters().put('lang', bean.selectedLanguage);
        //if(JUDAANUtil.RunningInAsandbox())
        //{
            p.getParameters().put('market' , Market);
        //}
        p.setRedirect(true);

        return p;
    }
    
    
      // Lead Generation for Brazil
     public String errorMsg {get; set;}
     public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String phone { get; set; }
     public boolean isphone { get; set; }
      public boolean isemail{ get; set; }
       public boolean issms{ get; set; }
        
     
     
     public void saveVehicleEnquiryform()
     {   
         this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
         firstName = ApexPages.currentPage().getParameters().get('firstName');
         lastName = ApexPages.currentPage().getParameters().get('lastName');
         email  = ApexPages.currentPage().getParameters().get('email');
         phone  = ApexPages.currentPage().getParameters().get('phone');
         isphone = boolean.valueof(ApexPages.currentPage().getParameters().get('isphone'));
         isemail= boolean.valueof(ApexPages.currentPage().getParameters().get('isemail'));
         issms= boolean.valueof(ApexPages.currentPage().getParameters().get('issms'));
         System.debug('----this.dto.assetId :: '+this.dto.assetId); 
         System.debug('----firstName :: '+firstName ); 
         SaveVehicleEnquiry vehicleEnquiryObj = new SaveVehicleEnquiry();
         System.debug('Inside saveVehicleEnquiryform :: '+this.firstName );  
         vehicleEnquiry.firstname = this.firstname;
          vehicleEnquiry.lastname = this.lastname;
           vehicleEnquiry.email = this.email;
            vehicleEnquiry.phone= this.phone ;
            
             vehicleEnquiry.isphone=  this.isphone;
              vehicleEnquiry.isemail = (this.isemail);
               vehicleEnquiry.issms = (this.issms) ;
          
         errorMsg = vehicleEnquiryObj.createLead(vehicleEnquiry,this.dto.assetId);
         System.debug('=====errorMsg '+errorMsg ); 
         if(errorMsg  == 'success'){
         vehicleEnquiryObj     = new SaveVehicleEnquiry();
         
         
         }
     }
    
     // Lead Generation for Brazil
    
     public void saveVehicleEnquiryforms()
     {
         SaveVehicleEnquiry vehicleEnquiryObj = new SaveVehicleEnquiry();
         System.debug('Inside saveVehicleEnquiryform :: '+vehicleEnquiry.firstName);   
         errorMsg = vehicleEnquiryObj.createLead(vehicleEnquiry,null);
     }
}
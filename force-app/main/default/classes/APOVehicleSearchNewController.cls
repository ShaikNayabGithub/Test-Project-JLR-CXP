public class APOVehicleSearchNewController {

    

    public List < wrapperClass > wrapClassList {
        get;
        set;
    }

    private boolean isOnload = false;
    
    public List < string > localpriceMin {
        get;
        set;
    }
    public List < string > localpriceMax {
        get;
        set;
    }
    
    
     public List < string > mileageMin {
        get;
        set;
    }
    public List < string > mileageMax {
        get;
        set;
    }
    
    public String minmileageprice {
        get;
        set;
    }
    public String maxmileageprice {
        get;
        set;
    }
     public List < SelectOption > mileageMinLst {
        get;
        set;
    }
    public List < SelectOption > milegeMaxLst {
        get;
        set;
    }
    public List < SelectOption > regYearLst{
        get;
        set;
    }
    
    private set < String > regYearSet;
    
    private set < String > mileagepriceMinSet;
    
    private set < String > localpriceMinSet;
    
    public boolean ISAPO{
        get;
        set;
    }
    public String minprice {
        get;
        set;
    }
    public String maxprice {
        get;
        set;
    }
       public String minmonthlyprice {
        get;
        set;
    }
    public String maxmonthlyprice {
        get;
        set;
    }
    public String selectedSort {
        get;
        set;
    }
    public String selectedSortmobile {
        get;
        set;
    }
    public String strState {
        get;
        set;
    }

    public integer index {
        get;
        set;
    } //keeps track of the offset
    public integer start {
        get;
        set;
    } //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list

    public Boolean nextBool {
        get;
        set;
    }
    public Boolean prevBool {
        get;
        set;
    }

    public List < VehicleSearchBean.Vehicle > assetlst {
        get;
        set;
    }
    private transient List < VehicleSearchBean.Vehicle > temp;
    private List < VehicleSearchBean.Vehicle > assetlstdummy;
    public boolean isCampaign {
        get;
        set;
    }


    public VehicleSearchBean bean {
        get;
        set;
    }
    public CreateSavedVehicleDto dto {
        get;
        set;
    }
   
    public String pdpaLink;

    public final String PROMOTIONAL_BANNER_RECORDTYPE = Label.Promotional_Banner;

    public String selectedMarket {
        get;
        set;
    }
    public String strRegYear{
        get;
        set;
    }

    public String DealerLocatorJGLink {
        get;
        set;
    }
    public String DealerLocatorLRLink {
        get;
        set;
    }
    public Boolean isFromScrollVehicle {
        get;
        set;
    }
    public Boolean isDeepColor {
        get;
        set;
    }
    public User loginUser {
        get;
        set;
    }
    public List < SelectOption > lstState {
        get;
        set;
    }
    public String selectedValue {
        get;
        set;
    }

    private Boolean ValidModelFromDx;
    
    public String Market {
        get;
        set;
    }
    public String CurrencySym {
        get;
        set;
    }
    //public String CustomPath { get; set; }
    //public String PathPrefix { get; set; } 
    public List < SelectOption > localpriceMinLst {
        get;
        set;
    }
    public List < SelectOption > localpriceMaxLst {
        get;
        set;
    }
    
    public List < SelectOption > mileagepriceMinLst {
        get;
        set;
    }
    public List < SelectOption > mileagepriceMaxLst {
        get;
        set;
    }
   
    private Set < String > models;
    public string modelName {
        get;
        set;
    }
    
    public boolean isAPOFilter{get;set;}
    
     public List<SelectOption> monthlypriceMinLst {get;set;}
    public List<SelectOption> monthlypriceMaxLst {get;set;}
    private set<String> monthlypriceMinSet;
    
    //private 

    public pageReference dispatchlanding() {
        System.debug('dispatch starts');

        isCampaign = ApexPages.currentPage().getParameters().get('isCampaign') != null ? true : false;
        //modelCount  = 0;
        //recommModelCount  = 0;
        Market = JUDAANUtil.getSimpleMarket();
        CurrencySym = JUDAANUtil.getCurrencySymbol();



        if (!ApexPages.currentPage().getParameters().containsKey('brand')) {
            String brand;
            String url = Site.getBaseRequestUrl();
            if (url.containsIgnoreCase('jaguar')) {
                brand = 'jaguar';
            } else {
                brand = 'landrover';
            }
            PageReference p = new PageReference(url);
            p.getParameters().put('brand', brand);
            p.getParameters().put('market', Market);
            System.debug('---dispatch ends1' + url + '---page' + p);
            p.setRedirect(true);

            return p;
        } else {

            return loadmodels();



        }
    }


    public void dispatch() {
        System.debug('dispatch starts');
        isCampaign = ApexPages.currentPage().getParameters().get('isCampaign') != null ? true : false;

        Market = JUDAANUtil.getSimpleMarket();
        CurrencySym = JUDAANUtil.getCurrencySymbol();
        modelName = ApexPages.currentPage().getParameters().get('model');

        system.debug('--modelName--' + modelName);

        system.debug('--modelName--' + modelName);
        Boolean isNew = false; 
        Boolean isAPO  = false;
        isAPOFilter = false;
        
        //isNew = ApexPages.currentPage().getParameters().containskey('isNew')  ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isNew')) : isAPOFilter ;
        isAPO = ApexPages.currentPage().getParameters().containskey('isAPO') ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isAPO')) : false; 
        if(isAPO == true)
        isAPO  = true;
        else
        isNew  = true;
        
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters();

        system.debug('---modelName ' + modelName );
        if(ApexPages.currentPage().getParameters().get('market') == 'jp'){
        if (modelName != null || isCampaign == true) {

            parameters.models.add(modelName );
            assetlst = selectDataNew(parameters);
            this.bean.vehicleCount = assetlst.size();
            


        }
        }
        else{
        assetlst = selectDataNew(parameters);
        this.bean.vehicleCount = assetlst.size();
        }
        
       
    }

    public APOVehicleSearchNewController() {


        isCampaign = ApexPages.currentPage().getParameters().get('isCampaign') != null ? true : false;
        
         System.debug('dispatch starts');
       isAPOFilter  = false;

      
        //modelName = ApexPages.currentPage().getParameters().get('model');

        
        
        index = 10;
        start = 0;
        isOnload = true;
        prevBool = false;
        nextBool = false;

        localpriceMinSet = new Set < String > ();
        localpriceMaxLst = new List < selectOption > ();
        localpriceMinLst = new List < selectOption > ();
        
        regYearSet = new Set<String>();
        regYearLst = new List<selectOption>();
        
        mileagepriceMinSet = new Set<String>();
        mileagepriceMaxLst = new List < selectOption > ();
        mileagepriceMinLst = new List < selectOption > ();
        
        monthlypriceMinSet = new Set<String>();
        
        monthlypriceMaxLst = new List<selectOption>();
        monthlypriceMinLst = new List<selectOption>();

        temp = new List < VehicleSearchBean.Vehicle > ();
        System.debug('APOVehicleSearchNewController Constructor Starts');
        selectedMarket = ApexPages.currentPage().getParameters().get('market');
        //getStateValues();
        pdpaLink = selectedMarket == 'sg' ? Label.SG_PDPA : selectedMarket == 'hk' ? Label.HK_PDPA : selectedMarket == 'th' ? Label.TH_PDPA : '';
        pdpaLink = ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? pdpaLink : pdpaLink.replace('jaguar', 'landrover');
        
        strRegYear = '';
        isFromScrollVehicle = false;
        isDeepColor = false;
        DealerLocatorJGLink=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_JG_Link__c != null ? JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_JG_Link__c : ''  ;
        DealerLocatorLRLink=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_LR_Link__c  != null ? JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Dealer_Locator_LR_Link__c : ''  ;
        ValidModelFromDx = false;

        this.bean = new VehicleSearchBean();


        this.dto = new CreateSavedVehicleDto();

        //this.dto.url = '/VehicleSearch';
        this.dto.url = '/CustomerAccountPage_New';
        //this.dto.createSavedVehicle = new CreateSavedVehicleImplByVehicleSearch();
        //this.dto.vehicleSearchBean = this.bean;

        if ('jaguar'.equals(ApexPages.currentPage().getParameters().get('brand'))) {
            this.bean.selectedBrand = VehicleSearchBean.BRAND_JAGUAR;
        } else {
            this.bean.selectedBrand = VehicleSearchBean.BRAND_LANDROVER;
        }

        
        
        
        
        

        //New code
        
        String selectedModel = ApexPages.currentPage().getParameters().get('model');
        brandName = this.bean.selectedBrand;
        market = selectedMarket;



      //loadAllVehicleData();
    
        
        if(selectedModel != null && selectedModel  != '' ){
        assetlst = new List < VehicleSearchBean.Vehicle > ();
        assetlstdummy = new List < VehicleSearchBean.Vehicle > ();





       
        assetlstdummy = assetlst;
        this.bean.vehicleCount = assetlst.size();
        total_size = assetlst.size();
        temp = new List < VehicleSearchBean.Vehicle > ();
        system.debug('-total_size --' + total_size);
        index = 10;
        start = 0;
        index = index > total_size ? total_size : index;
        for (Integer i = start; i < index; i++) {
            system.debug('-assetlstdummy--' + i);

            temp.add(assetlstdummy.get(i));
        }
        assetlst = temp;
        prevBool = true;
        nextBool = false;
       }


    }


    public void setStateValues() {
        System.debug('------------- selectedValue1111' + selectedValue);
        //restartSearch();
        loadAllVehicleData();
        processSelected();

    }

    public void setStateValuesBR() {

        LoadModels();
    }



    public List < SelectOption > getStateValues() {
        System.debug('getStateValues starts');
        List < SelectOption > lstState1 = new List < SelectOption > ();
        lstState = new List < SelectOption > ();
        Set < String > lstAaccount = new VehicleSearch_AssetDao(ApexPages.currentPage().getParameters().get('brand'), ApexPages.currentPage().getParameters().get('market')).getStateValues();
        //List<Account> lstAaccount = [Select RecordType.name,Regional_State_Code__c  from Account  where RecordType.name = 'Retailer' and country_ISO_Code__c =: this.market and Regional_State_Code__c != '' ];
        system.debug('lstAaccount--- ' + lstAaccount);
        for (String objAacc: lstAaccount) {


            SelectOption sa1 = new SelectOption(objAacc, objAacc);

            lstState1.add(sa1);
        }

        SelectOption sa2 = new SelectOption(Label.None_State, Label.None_State);
        lstState.add(sa2);
        lstState1.sort();
        lstState.addAll(lstState1);

        System.debug('getStateValues ends');
        return lstState;
    }


   
    // Generates country dropdown from country settings
    public List<SelectOption> getmileagePriceList() {   
        String brand =  bean.selectedBrand;
        //String brand = ApexPages.currentPage().getParameters().get('isCampaign');
        String market=  ApexPages.currentPage().getParameters().get('market');
        
        List<SelectOption> options = new List<SelectOption>();
        mileagepriceMinLst.add(new SelectOption('','Select Mileage'));
        List<string> localPriceTempLst = new List<string>();
        List<string> regYearTempLst = new List<string>();
        String soql = 'Select Id, Mileage__c, product2.Registration_Year_Alternative__c' +
            ' from Asset' + 
            ' Where Product2.Make__r.Name =:brand' +
            ' And Account.Country_ISO_Code__c =:market' +
            ' And Model__r.OSA_Country_ISO_Code__c includes (:market )' +
            ' And Approved_On_Udaan__c = true' +
            ' And New_Display__c = false' +
            ' And APO__c = true' + 
            ' AND Product2.Model_Alternative__c != null';
        
        Map < Id, Asset > mapIdToAsset = new Map < id, Asset > ((List < Asset > ) Database.query(soql));
        for( Asset  objAsset : mapIdToAsset.values()){
            if(!localPriceTempLst.contains(string.valueof(objAsset.Mileage__c)))
                localPriceTempLst.add(string.valueof(objAsset.Mileage__c ));
            
            System.debug('pickListVal.getLabel() '+localPriceTempLst);
            
            if(objAsset.product2.Registration_Year_Alternative__c != null && !regYearSet.contains(objAsset.product2.Registration_Year_Alternative__c))
                regYearSet.add(objAsset.product2.Registration_Year_Alternative__c );
        } 
        
        // Sort them by name
        
        //List<String> localPriceTempLst = new List<String>( mileagepriceMinSet);
        String strPattern = '^0+(?!$)';
        //localPriceTempLst.addAll(localpriceMinSet);
        localPriceTempLst.sort();
        system.debug('---localPriceTempLst'+localPriceTempLst);
        // Create the Select Options.
        for (String localPriceName : localPriceTempLst ){
            system.debug('---localPriceName '+localPriceName );
            mileagepriceMinLst.add(new SelectOption(localPriceName.replaceAll(strPattern, ''), localPriceName.replaceAll(strPattern, '') ));
        }
        return mileagepriceMinLst;
    }
    
    // Generates registration year list
    public List<SelectOption> getRegYearList() {
        List<SelectOption> options = new List<SelectOption>();
        regYearLst.add(new SelectOption('','Select Year'));
        
        // Sort them by name
        List<String> localPriceTempLst = new List<String>( regYearSet);
        String strPattern = '^0+(?!$)';
        //localPriceTempLst.addAll(localpriceMinSet);
        localPriceTempLst.sort();
        system.debug('---localPriceTempLst'+localPriceTempLst);
        // Create the Select Options.
        for (string localPriceName : localPriceTempLst ) {
            system.debug('---localPriceName '+localPriceName );
            regYearLst.add(new SelectOption(localPriceName, localPriceName ));
        }
        return regYearLst;
    }

    // Generates country dropdown from country settings
    public List<SelectOption> getMonthlyPriceList() {
        List<SelectOption> options = new List<SelectOption>();
        monthlypriceMinLst.add(new SelectOption('','Select Price'));
        
        // Sort them by name
        List<String> localPriceTempLst = new List<String>( monthlypriceMinSet);
        String strPattern = '^0+(?!$)';
        //localPriceTempLst.addAll(localpriceMinSet);
        localPriceTempLst.sort();
        system.debug('---localPriceTempLst'+localPriceTempLst);
        // Create the Select Options.
        for (string localPriceName : localPriceTempLst ) {
            system.debug('---localPriceName '+localPriceName );
            monthlypriceMinLst.add(new SelectOption(localPriceName.replaceAll(strPattern, ''), localPriceName.replaceAll(strPattern, '') ));
        }
        return monthlypriceMinLst;
    }
    
    // Generates country dropdown from country settings
    public List < SelectOption > getLocalPriceList() {
        List < SelectOption > options = new List < SelectOption > ();
        localpriceMinLst.add(new SelectOption('', 'Select Price'));

        // Sort them by name
        List < String > localPriceTempLst = new List < String > (localpriceMinSet);
        String strPattern = '^0+(?!$)';
        //localPriceTempLst.addAll(localpriceMinSet);
        localPriceTempLst.sort();
        system.debug('---localPriceTempLst' + localPriceTempLst);
        // Create the Select Options.
        for (string localPriceName : localPriceTempLst) {
            system.debug('---localPriceName ' + localPriceName);
            localpriceMinLst.add(new SelectOption(localPriceName.replaceAll(strPattern, ''), localPriceName.replaceAll(strPattern, '')));
        }
        return localpriceMinLst;
    }
    
    public PageReference switchBrand() {
        //this.LoadModels();        
        return (null);
    }

    public PageReference restartSearch() {
        PageReference p = Page.VehicleSearch;
        if (bean.selectedBrand == 'Jaguar') {
            p.getParameters().put('brand', 'jaguar');
           // p.getParameters().put('model', 'XE');
        } else {
            p.getParameters().put('brand', 'landrover');
           // p.getParameters().put('model', 'DISCOVERY');
        }
        p.getParameters().put('lang', bean.selectedLanguage);
        system.debug('--selectedValue ' + selectedValue);
        //if(selectedValue != null && selectedValue != '' && selectedValue != Label.None_State)
        //p.getParameters().put('state', selectedValue );

        //if(JUDAANUtil.RunningInAsandbox())
        //{
        p.getParameters().put('market', Market);
        //}
        p.setRedirect(true);

        return p;
    }
    
    public string brandName;
    
    public void loadAllVehicleData() {
        System.debug('------------- selectedMarket = ' + selectedMarket);
        
        brandName = bean.selectedBrand;
        // ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? 'Jaguar' : 'Land Rover';
        // bean.selectedBrand ;
        market = selectedMarket;
        
        strState = selectedValue != null && selectedValue != Label.None_State ? selectedValue : ApexPages.currentPage().getParameters().containsKey('state') ? ApexPages.currentPage().getParameters().get('state') : null;
        System.debug('------------- strState = ' + strState);
        String soql = 'Select Id , Name , ToLabel( Exterior_Colour_Group__c ) , ToLabel( Exterior_Colour__c ) , Interior_Color_Image__c , Search_Key__c , Search_Key_Text__c , Master_Colour__c , Model__c , Body_Style_Image_M__c , ToLabel( Interior_Color__c ) ' +
            ' , Vehicle_Image_L__c , Vehicle_Image_M__c , Asset_Specification_Pack__c , Monthly_Price__c , Exterior_Detail_Color_Image__c , pictures__c , Option_Image_Root__c , ToLabel( Options__c ) , Interior_colour_code__c , Colour__c , Exterior_Colour_Code__c ' +
            ' , Model_Year__c , Fuel_TypeValue__c , TransmissionValue__c , OptionsValue__c , Exterior_Colour_GroupValue__c , ToLabel( Product2.BodyStyle_Alternative__c ) ,  Product2.Model__r.Model_Alternative__c , Product2.Engine_Capacity_Alternative__c ' +
            ' , product2.Monthly_Price_From__c , product2.Previous_Monthly_Price_From__c , ToLabel( Product2.Fuel_Type_Alternative__c ) , ToLabel(Product2.Model_Alternative__c) , Product2.Registration_Year_Alternative__c , Product2.Specification_Pack_Alternative__c ' +
            ' , ToLabel( Product2.Transmission_Alternative__c ) , ToLabel( Product2.Wheel_Driven_Alternative__c ) , Product2.Engine__c , Body_Style_Value__c , ToLabel( Product2.Power_Output_Alternative__c ) ' +
            ' , Product2.Name_plate_display_order__c , Product2.Name_Plate_Display_Order_SG__c , New_Display__c , APO_Display__c , Local_price__c , vin__c , Order_Number__c , Power_Output_Value__c ' +
            ' , Previous_Price__c , Product2.Vehicle_Image_L__c , Product2.KMILink__c , Mileage__c , Model__r.Model_Alternative__c , Account.Name , Account.City_Name_Local__c , Account.BillingCity , Account.BillingState ' +
            ' From Asset ' +
            ' Where Product2.Make__r.Name =:brandName  ' +
            ' And Account.Country_ISO_Code__c =:market' +
            ' And Model__r.OSA_Country_ISO_Code__c includes (:market )' +
            ' And Approved_On_Udaan__c = true' +
            ' And New_Display__c = false' +
            ' And APO__c = true' +
            ' And Product2.New_Vehicle__c = true' +
            ' AND Product2.Model_Alternative__c != null ';
        
        if (strState != null)
            soql += ' And Account.Regional_State_Code__c =: strState';
        
        // To display market wise Vista Status
        JUDAAN_Market_Settings__mdt marketSettings = JUDAAN_Market_Settings__mdt.getInstance(market);
        if(marketSettings != null) {
            String vistaStatus = '';
            if(brandName == 'jaguar') {
                vistaStatus = marketSettings.JG_Vista_Status__c;    
            } else if(brandName == 'landrover') {
                vistaStatus = marketSettings.LR_Vista_Status__c;
            }
            // Check if Vista Status exist
            if(String.isNotBlank(vistaStatus)) {
                soql += ' And Vista_Status__c IN (' + StringUtil.getInOperatorValue(vistaStatus) + ')';
            }
        }
        
        Map < Id, Asset > mapIdToAsset = new Map < id, Asset > ((List < Asset > ) Database.query(soql));
        transient Set < String > models = new Set < String > ();
        transient Set < String > bodyStyles = new Set < String > ();
        
        transient Set < String > enginecapacity = new Set < String > ();
        transient Set < String > fuel = new Set < String > ();
        transient Set < String > powertrain = new Set < String > ();
        
        transient Set < String > options = new Set < String > ();
        transient Set < String > exteriorGroupColours = new Set < String > ();
        transient Set < String > interiorColours = new Set < String > ();
        transient Set < String > specifications = new Set < String > ();
        transient Set < String > transmissionSet = new Set < String > ();
        
        wrapClassList = new List < wrapperClass > ();
        wrapperClass objWC = new wrapperClass();
        
        
        // APOVehicleSearchNewController.wrapperClass objWC= new APOVehicleSearchNewController.wrapperClass();
        
        for (Asset objAsset: mapIdToAsset.values()) {
            if (!models.contains(objAsset.Product2.Model_Alternative__c)) {
                
                Decimal sortNo = 0;
                if(market == 'sg') {
                    sortNo = objAsset.Product2.Name_Plate_Display_Order_SG__c;
                } else {
                    sortNo = objAsset.Product2.Name_plate_display_order__c;
                }
                
                models.add(objAsset.Product2.Model_Alternative__c);
                APOVehicleSearchNewController.modelClass wc = new APOVehicleSearchNewController.modelClass(false, objAsset.Product2.Model_Alternative__c, objAsset.Product2.Vehicle_IMage_L__c, sortNo);
                objWC.modelLst.add(wc);
                
                if ((modelName == null || modelName == '') && (market != 'br' && strState == NULL)) {
                    objWC.flag = true;
                    processSelected();
                    objWC.flag = false;
                }
            }
            
            if (!localpriceMinSet.contains(string.valueof(objAsset.Local_price__c))) {
                //StringUtil.zeroPadding( this.price , 10 )
                system.debug('--objAsset.Local_price__c'+objAsset.Local_price__c);
                localpriceMinSet.add(string.valueof(StringUtil.zeroPadding(objAsset.Local_price__c, 10)));
                // localpriceMaxSet.add(objAsset.Local_price__c);  
                // APOVehicleSearchNewController.modelClass  wc = new APOVehicleSearchNewController.modelClass(false,objAsset.Product2.Model_Alternative__c, objAsset.Product2.Vehicle_IMage_L__c);
                // objWC.localpriceSet.add(wc);
                
            }
            system.debug('---objAsset.Mileage__c'+objAsset.Mileage__c);
            if (!mileagepriceMinSet.contains(string.valueof(objAsset.Mileage__c ))) {
                //StringUtil.zeroPadding( this.price , 10 )
                system.debug('--objAsset.Local_price__c'+objAsset.Mileage__c );
                mileagepriceMinSet.add(string.valueof(StringUtil.zeroPadding(objAsset.Mileage__c , 10)));
            }
            
            if (!bodyStyles.contains(StringUtil.getValue(objAsset.Product2.BodyStyle_Alternative__c))) {
                bodyStyles.add(StringUtil.getValue(objAsset.Product2.BodyStyle_Alternative__c));
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.bodyStyleClass wcBodystyle = new APOVehicleSearchNewController.bodyStyleClass(false, StringUtil.getValue(objAsset.Product2.BodyStyle_Alternative__c));
                objWC.bodystyleLst.add(wcBodystyle);
            }
            
            if (!fuel.contains(objAsset.Product2.Fuel_Type_Alternative__c)) {
                fuel.add(objAsset.Product2.Fuel_Type_Alternative__c);
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.fuelClass wcfuel = new APOVehicleSearchNewController.fuelClass(false, objAsset.Product2.Fuel_Type_Alternative__c);
                objWC.fuelclassLst.add(wcfuel);
            }

            if (!enginecapacity.contains(objAsset.Product2.Engine_Capacity_Alternative__c)) {
                enginecapacity.add(objAsset.Product2.Engine_Capacity_Alternative__c);
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.enginecapacityClass wcenginecapacity = new APOVehicleSearchNewController.enginecapacityClass(false, objAsset.Product2.Engine_Capacity_Alternative__c);
                objWC.enginecapacityclassLst.add(wcenginecapacity);
            }
            
            if (!powertrain.contains(objAsset.Product2.Power_Output_Alternative__c)) {
                powertrain.add(objAsset.Product2.Power_Output_Alternative__c);
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.powertrainClass wcpowertrain = new APOVehicleSearchNewController.powertrainClass(false, objAsset.Product2.Power_Output_Alternative__c);
                objWC.powertrainclassLst.add(wcpowertrain);
            }
            
            if (!exteriorGroupColours.contains(objAsset.Exterior_Colour_Group__c)) {
                exteriorGroupColours.add(objAsset.Exterior_Colour_Group__c);
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.exteriorColorGroupClass wcexteriorColorGroup = new APOVehicleSearchNewController.exteriorColorGroupClass(false, objAsset.Exterior_Colour_Group__c, objAsset.Exterior_Detail_Color_Image__c);
                objWC.exteriorColorGroupClassLst.add(wcexteriorColorGroup);
            }
            
            if (!interiorColours.contains(StringUtil.getValue(objAsset.Interior_Color__c))) {
                interiorColours.add(StringUtil.getValue(objAsset.Interior_Color__c));
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.interiorcolorClass wcinteriorcolor = new APOVehicleSearchNewController.interiorcolorClass(false, StringUtil.getValue(objAsset.Interior_Color__c), objAsset.Interior_Color_Image__c);
                objWC.interiorcolorClassLst.add(wcinteriorcolor);
            }
            
            if (!specifications.contains(objAsset.Product2.Specification_Pack_Alternative__c)) {
                specifications.add(objAsset.Product2.Specification_Pack_Alternative__c);
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.specificationClass wcspecification = new APOVehicleSearchNewController.specificationClass(false, objAsset.Product2.Specification_Pack_Alternative__c);
                objWC.specificationClassLst.add(wcspecification);
            }
            /* 
            if(!transmissionSet.contains( StringUtil.getValue( (objAsset.Product2.Transmission_Alternative__c )))){
                system.debug('---objAsset.Product2.Transmission_Alternative__c'+objAsset.Product2.Transmission_Alternative__c);
                system.debug('---objAsset.Product2.Transmission_Alternative__c'+StringUtil.getValue(objAsset.Product2.Transmission_Alternative__c));
                transmissionSet.add( StringUtil.getValue( objAsset.Product2.Transmission_Alternative__c) );
                //fuelType.add(objAsset.Product2.Fuel_Type_Alternative__c );
                
                APOVehicleSearchNewController.TransmissionClass wcTransmission = new APOVehicleSearchNewController.TransmissionClass(false, StringUtil.getValue( objAsset.Product2.Transmission_Alternative__c ));
                
                
                objWC.transmissionClassLst.add(wcTransmission );
                system.debug('---objAsset--'+wcTransmission );
            } 
            */
            
            if (!String.isEmpty(objAsset.Options__c)) {
                List < String > optionValues = StringUtil.splitMultiplePickList(objAsset.Options__c);
                for (String optionName: optionValues) {
                    if (!options.contains(optionName)) {
                        APOVehicleSearchNewController.optionClass wcOption = new APOVehicleSearchNewController.optionClass(false, optionName);
                        options.add(StringUtil.getValue(optionName));
                        objWC.optionClassLst.add(wcOption);
                    }
                }
            }
        }
        
        // Sort Models
        objWC.modelLst.sort();
        
        wrapClassList.add(objWC);
        models.clear();
        specifications.clear();
        bodyStyles.clear();
        fuel.clear();
        enginecapacity.clear();
        exteriorGroupColours.clear();
        interiorColours.clear();
        mapIdToAsset.clear();
        // return(wrapClassList);           
    }


   

    public class wrapperClass {
        public boolean flag {
            get;
            set;
        }
        public boolean isAPO{
            get;
            set;
        }

        public list < APOVehicleSearchNewController.modelClass > modelLst {
            get;
            set;
        }
        public list < APOVehicleSearchNewController.bodystyleClass > bodystyleLst {
            get;
            set;
        }
        public list < APOVehicleSearchNewController.powertrainClass > powertrainClassLst {
            get;
            set;
        }

        public list < APOVehicleSearchNewController.fuelClass > fuelClassLst {
            get;
            set;
        }

        public list < APOVehicleSearchNewController.engineCapacityClass > engineCapacityClassLst {
            get;
            set;
        }

        public list < APOVehicleSearchNewController.exteriorColorGroupClass > exteriorColorGroupClassLst {
            get;
            set;
        }
        public list < APOVehicleSearchNewController.interiorcolorClass > interiorcolorClassLst {
            get;
            set;
        }
        public list < APOVehicleSearchNewController.specificationClass > specificationClassLst {
            get;
            set;
        }
        public list < APOVehicleSearchNewController.TransmissionClass > transmissionClassLst {
            get;
            set;
        }
        public list < APOVehicleSearchNewController.optionClass > optionClassLst {
            get;
            set;
        }








        public wrapperClass() {
            isAPO = false;
            modelLst = new List < APOVehicleSearchNewController.modelClass > ();
            bodystyleLst = new List < APOVehicleSearchNewController.bodystyleClass > ();


            engineCapacityClassLst = new List < APOVehicleSearchNewController.engineCapacityClass > ();
            fuelClassLst = new List < APOVehicleSearchNewController.fuelClass > ();
            powertrainClassLst = new List < APOVehicleSearchNewController.powertrainClass > ();

            exteriorColorGroupClassLst = new List < APOVehicleSearchNewController.exteriorColorGroupClass > ();
            interiorcolorClassLst = new List < APOVehicleSearchNewController.interiorcolorClass > ();

            //modelLst = new List<APOVehicleSearchNewController.modelClass>();
            specificationClassLst = new List < APOVehicleSearchNewController.specificationClass > ();
            transmissionClassLst = new List < APOVehicleSearchNewController.TransmissionClass > ();

            optionClassLst = new List < APOVehicleSearchNewController.optionClass > ();

        }

    }

    public class modelClass implements Comparable {

        public boolean flag {
            get;
            set;
        }
        public String modelName {
            get;
            set;
        }
        public transient String modelImage {
            get;
            set;
        }
        public Decimal sortNo {
            get;
            set;
        }

        public modelClass(Boolean isChecked, String modelName, String modelImage, Decimal sortNo) {
            this.flag = isChecked;
            this.modelName = modelName;
            this.modelImage = modelImage;
            this.sortNo = sortNo;
        }
        
        public Integer compareTo(Object objToCompare) {
            modelClass compareObj = (modelClass)objToCompare;
            if (this.sortNo > compareObj.sortNo) {
                return 1;
            }
            if (this.sortNo == compareObj.sortNo) {
                return 0;
            }
            return -1;
        }

    }

    public class bodystyleClass implements Comparable{
        public boolean flag {
            get;
            set;
        }
        public string bodyStyleName {
            get;
            set;
        }

        public bodystyleClass(Boolean isChecked, String bodyStyleName) {
            this.flag = isChecked;
            this.bodyStyleName = bodyStyleName;
        }
        
        public Integer compareTo(Object objToCompare) {
            bodystyleClass compareObj = (bodystyleClass)objToCompare;
            if(bodyStyleName.equalsIgnoreCase('Other')) return 1;
            if(compareObj.bodyStyleName.equalsIgnoreCase('Other')) return -1;
            return bodyStyleName.compareTo(compareObj.bodyStyleName);
        }
    }

    public class fuelClass {
        public boolean flag {
            get;
            set;
        }
        public string fuelName {
            get;
            set;
        }

        public fuelClass(Boolean isChecked, String fuelName) {
            this.flag = isChecked;
            this.fuelName = fuelName;
        }

    }

    public class engineCapacityClass implements Comparable {
        public boolean flag {
            get;
            set;
        }
        public string engineName {
            get;
            set;
        }

        public engineCapacityClass(Boolean isChecked, String engineName) {
            this.flag = isChecked;
            this.engineName = engineName;
        }
        
        public Integer compareTo(Object objToCompare) {
            engineCapacityClass compareObj = (engineCapacityClass)objToCompare;
            if(engineName.equalsIgnoreCase('Other')) return 1;
            if(compareObj.engineName.equalsIgnoreCase('Other')) return -1;        
            return engineName.compareTo(compareObj.engineName);
        }
    }

    public class powertrainClass implements Comparable {
        public boolean flag {
            get;
            set;
        }
        public string powertrainName {
            get;
            set;
        }

        public powertrainClass(Boolean isChecked, String powertrainName) {
            this.flag = isChecked;
            this.powertrainName = powertrainName;
        }
        
        public Integer compareTo(Object objToCompare) {
            powertrainClass compareObj = (powertrainClass)objToCompare;
            if(powertrainName.equalsIgnoreCase('Other')) return 1;
            if(compareObj.powertrainName.equalsIgnoreCase('Other')) return -1;
            return powertrainName.compareTo(compareObj.powertrainName);
        }
    }
    
    public class exteriorColorGroupClass implements Comparable{
        public boolean flag {
            get;
            set;
        }
        public string exteriorcolorgroupName {
            get;
            set;
        }
        public string exteriorcolorurl {
            get;
            set;
        }

        public exteriorColorGroupClass(Boolean isChecked, String exteriorcolorgroupName, string exteriorcolorurl) {
            this.flag = isChecked;
            this.exteriorcolorgroupName = exteriorcolorgroupName;
            this.exteriorcolorurl = exteriorcolorurl;
        }
        
        public Integer compareTo(Object objToCompare) {
            exteriorColorGroupClass compareObj = (exteriorColorGroupClass)objToCompare;
            if(exteriorcolorgroupName.equalsIgnoreCase('Other')) return 1;
            if(compareObj.exteriorcolorgroupName.equalsIgnoreCase('Other')) return -1;
            return exteriorcolorgroupName.compareTo(compareObj.exteriorcolorgroupName);
        }
    }

    public class interiorcolorClass implements Comparable {
        public boolean flag {
            get;
            set;
        }
        public string interiorcolorName {
            get;
            set;
        }
        public string interiorcolorurl {
            get;
            set;
        }

        public interiorcolorClass(Boolean isChecked, String interiorcolorName, string interiorcolorurl) {
            this.flag = isChecked;
            this.interiorcolorName = interiorcolorName;
            this.interiorcolorurl = interiorcolorurl;
        }
        
        public Integer compareTo(Object objToCompare) {
            interiorcolorClass compareObj = (interiorcolorClass)objToCompare;
            if(interiorcolorName.equalsIgnoreCase('Other')) return 1;
            if(compareObj.interiorcolorName.equalsIgnoreCase('Other')) return -1;
            return interiorcolorName.compareTo(compareObj.interiorcolorName);

        }
    }

    public class TransmissionClass {
        public boolean flag {
            get;
            set;
        }
        public string transmissioName {
            get;
            set;
        }


        public TransmissionClass(Boolean isChecked, String transmissioName) {
            this.flag = isChecked;
            this.transmissioName = transmissioName;

        }
    }

    public class specificationClass {
        public boolean flag {
            get;
            set;
        }
        public string specificationName {
            get;
            set;
        }

        public specificationClass(Boolean isChecked, String specificationName) {
            this.flag = isChecked;
            this.specificationName = specificationName;
        }

    }

    public class optionClass {

        public boolean flag {
            get;
            set;
        }
        public string optionName {
            get;
            set;
        }

        public String optionCode {
            get;
            set;
        }
        public String translatedName {
            get;
            set;
        }
        public String imagePath {
            get;
            set;
        }
        public String description {
            get;
            set;
        }

        public optionClass(Boolean isChecked, String optionName) {
            this.flag = isChecked;
            this.optionName = StringUtil.getValue(optionName);
            //this.optionName =   optionName ; 

            //this.translatedName = StringUtil.getValue( optionName );
            //this.imagePath = imageRootPath + this.optionName + '.jpg';

            //String key = ( this.optionName ).replaceAll( ' & ' , '_' ).replaceAll( ' ' , '_' ).toUpperCase();

            //key = key.replaceAll( '-' , '_' );

            //this.description = CustomLabels.getInstance().getValue(key);
        }
    }

    /*
       
     public Option( String optionName , String optionCode , String imageRootPath , Asset tmp ) {
         this.init( tmp );
         this.optionName = StringUtil.getValue( optionCode );
         this.translatedName = StringUtil.getValue( optionName );
         this.imagePath = imageRootPath + this.optionName + '.jpg';
         
         String key = ( this.optionName ).replaceAll( ' & ' , '_' ).replaceAll( ' ' , '_' ).toUpperCase();
       
         key = key.replaceAll( '-' , '_' );

         this.description = CustomLabels.getInstance().getValue(key);


     }
    */

    public void next() {
        index = index + 10;
        start = start + 10;

        assetlst.clear();

        if (index > this.bean.vehicleCount) {
            index = Math.Mod(this.bean.vehicleCount, 10) + start;
            system.debug('Index is ' + index);
            nextBool = true;
            prevBool = index <= 10 ? true : false;
            List < VehicleSearchBean.Vehicle > temp1 = new List < VehicleSearchBean.Vehicle > ();
            for (Integer i = start; i < index; i++) {
                temp1.add(assetlstdummy.get(i));
            }
            assetlst = temp1;
            index = start + 10;
        } else {
            List < VehicleSearchBean.Vehicle > temp1 = new List < VehicleSearchBean.Vehicle > ();
            for (Integer i = start; i < index; i++) {
                temp1.add(assetlstdummy.get(i));
            }
            assetlst = temp1;
            prevBool = index <= 10 ? true : false;
        }
    }

    public void previous() {
        if (start > 10) {
            index = index - 10;
            start = start - 10;
            List < VehicleSearchBean.Vehicle > temp1 = new List < VehicleSearchBean.Vehicle > ();

            for (Integer i = start; i < index; i++) {
                temp1.add(assetlstdummy.get(i));
            }
            assetlst = temp1;

            prevBool = index <= 10 ? true : false;
            nextBool = false;
        } else {
            index = index - 10;
            start = start - 10;
            List < VehicleSearchBean.Vehicle > temp1 = new List < VehicleSearchBean.Vehicle > ();
            for (Integer i = start; i < index; i++) {
                temp1.add(assetlstdummy.get(i));
            }
            assetlst = temp1;
            prevBool = true;
            nextBool = false;
        }
    }

    public List < VehicleSearchBean.Vehicle > selectData(VehicleSearchInputParameters parameters, boolean isNew, boolean isAPO) {
        //System.debug( '------------- section = ' + section );


        List < String > productIds = new List < String > ();
        strState = selectedValue != null && selectedValue != Label.None_State ? selectedValue : ApexPages.currentPage().getParameters().containsKey('state') ? ApexPages.currentPage().getParameters().get('state') : null;

        system.debug('--strState ' + strState);
        system.debug('--minprice' + minprice);
        system.debug('--maxprice' + maxprice);
         system.debug('--brandName ' + brandName );
          system.debug('--market' + market);
          
          system.debug('--isNew' + isNew);
          system.debug('--isAPO' + isAPO);

        String soql = 'Select Id , Name , ToLabel( Exterior_Colour_Group__c ) , ToLabel( Exterior_Colour__c ) , Interior_Color_Image__c , Search_Key__c , Search_Key_Text__c , Master_Colour__c , Model__c , Body_Style_Image_M__c , ToLabel( Interior_Color__c ) ' +
            ' , Vehicle_Image_L__c , Vehicle_Image_M__c , Asset_Specification_Pack__c , Monthly_Price__c , Exterior_Detail_Color_Image__c , pictures__c , Option_Image_Root__c , ToLabel( Options__c ) , Interior_colour_code__c , Colour__c , Exterior_Colour_Code__c ' +
            ' , Model_Year__c , Fuel_TypeValue__c , TransmissionValue__c , OptionsValue__c , Exterior_Colour_GroupValue__c , ToLabel( Product2.BodyStyle_Alternative__c ) ,  Product2.Model__r.Model_Alternative__c , Product2.Engine_Capacity_Alternative__c ' +
            ' , product2.Monthly_Price_From__c , product2.Previous_Monthly_Price_From__c , ToLabel( Product2.Fuel_Type_Alternative__c ) , ToLabel(Product2.Model_Alternative__c) , Product2.Registration_Year_Alternative__c , Product2.Specification_Pack_Alternative__c ' +
            ' , ToLabel( Product2.Transmission_Alternative__c ) , ToLabel( Product2.Wheel_Driven_Alternative__c ) , Product2.Engine__c , Body_Style_Value__c , ToLabel( Product2.Power_Output_Alternative__c ) ' +
            ' , Product2.Name_plate_display_order__c , Product2.Name_Plate_Display_Order_SG__c , New_Display__c , APO_Display__c , Local_price__c , vin__c , Order_Number__c , Power_Output_Value__c ' +
            ' , Previous_Price__c , Product2.Vehicle_Image_L__c , Product2.KMILink__c , Mileage__c , Model__r.Model_Alternative__c , Account.Name , Account.City_Name_Local__c , Account.BillingCity , Account.BillingState ' +
            ' From Asset ' +
            ' Where Product2.Make__r.Name =:brandName ' +
            ' And Account.Country_ISO_Code__c =:market ' +
            ' And Model__r.OSA_Country_ISO_Code__c includes (:market)' +
            ' And Approved_On_Udaan__c =true' +
            ' And  New_Display__c = false' +
            ' AND APO__c = true' +
            ' And Product2.New_Vehicle__c = true' +
            ' AND Product2.Model_Alternative__c != null ';

        if (strState != null && strState != '' && strState != Label.None_State)
            soql += ' And Account.Regional_State_Code__c =: strState';
        
        // To display market wise Vista Status
        JUDAAN_Market_Settings__mdt marketSettings = JUDAAN_Market_Settings__mdt.getInstance(market);
        if(marketSettings != null) {
            String vistaStatus = '';
            if(brandName == 'jaguar') {
                vistaStatus = marketSettings.JG_Vista_Status__c;    
            } else if(brandName == 'landrover') {
                vistaStatus = marketSettings.LR_Vista_Status__c;
            }
            // Check if Vista Status exist
            if(String.isNotBlank(vistaStatus)) {
                soql += ' And Vista_Status__c IN (' + StringUtil.getInOperatorValue(vistaStatus) + ')';
            }
        }

        List < String > models = parameters.models;
        System.debug('----------- where models = ' + models);
        if (models != null && !models.isEmpty())
            soql += ' And Product2.Model_Alternative__c in :models ';

        //soql += ' And Product2.Model__r.Model_Alternative__c in :models ';

        List < String > bodyStyles = parameters.styles;
        System.debug('----------- where bodyStyles = ' + bodyStyles);
        if (bodyStyles != null && !bodyStyles.isEmpty())
            soql += ' And toLabel(Product2.BodyStyle_Alternative__c) in :bodyStyles ';


        List < String > fuelTypes = parameters.fuelTypes;
        System.debug('----------- where fuelTypes = ' + fuelTypes);
        if (fuelTypes != null && !fuelTypes.isEmpty())

            soql += ' And toLabel(Product2.Fuel_Type_Alternative__c) in:fuelTypes';

        List < String > engines = parameters.engines;
        System.debug('----------- where engines = ' + engines);
        if (engines != null && !engines.isEmpty())

            soql += ' And toLabel(Product2.Engine_Capacity_Alternative__c) in:engines';


        List < String > powertrains = parameters.powertrains;
        System.debug('----------- where powertrains = ' + powertrains);
        if (powertrains != null && !powertrains.isEmpty())

            soql += ' And toLabel(Product2.Power_Output_Alternative__c ) in:powertrains';


        List < String > specifications = parameters.specifications;
        System.debug('----------- where specifications= ' + specifications);
        if (specifications != null && !specifications.isEmpty())

            soql += ' And toLabel(Product2.Specification_Pack_Alternative__c ) in:specifications';


        List < String > exteriorGroupColours = parameters.exteriorGroupColours;
        System.debug('----------- where exteriorGroupColours = ' + exteriorGroupColours);
        if (exteriorGroupColours != null && !exteriorGroupColours.isEmpty())
            soql += ' And toLabel(Exterior_Colour_Group__c)  in :exteriorGroupColours ';


        List < String > interiorColours = parameters.interiorColours;
        System.debug('------------ where interiorColours = ' + interiorColours);
        if (interiorColours != null && !interiorColours.isEmpty())
            soql += ' And toLabel(Interior_color__c) in :interiorColours ';


        System.debug('------------ where localprice= ' + minprice);
        if (minprice != null && minprice != '' && maxprice != null && maxprice != '')
            soql += ' And Local_price__c >=' + minprice.replaceAll(',' ,'') + ' And Local_price__c <=' + maxprice.replaceAll(',' ,'');
        
         System.debug('------------ where localprice= ' + minprice);
        if (isNew  && minmonthlyprice != null && minmonthlyprice != '' && maxmonthlyprice != null && maxmonthlyprice != '')
            soql += ' And Monthly_Price__c>=' + minmonthlyprice .replaceAll(',' ,'') + ' And Monthly_Price__c <=' + maxmonthlyprice .replaceAll(',' ,'');
        
        System.debug('-------------- minmileageprice  = ' + minmileageprice );
        System.debug('-------------- maxmileageprice  = ' + maxmileageprice );
        System.debug('-------------- isAPO  = ' + isAPO );
        
         if (isAPO != null && isAPO && strRegYear != null && strRegYear!= '' )
            soql += ' And product2.Registration_Year_Alternative__c =:strRegYear' ;
        System.debug('-------------- parameters.options = ' + parameters.options);
        
         if (isAPO != null && isAPO && minmileageprice != null && minmileageprice != '' && maxmileageprice != null && maxmileageprice != '')
            soql += ' And Mileage__c >=' + minmileageprice .replaceAll(',' ,'') + ' And Mileage__c <=' + maxmileageprice.replaceAll(',' ,'');
        System.debug('-------------- parameters.options = ' + parameters.options);

        if (!parameters.options.isEmpty()) {
            String optionWord = '';

            for (String tmp: parameters.options) {
                
                optionWord += '\''+tmp.replaceAll('\'', '\\\'')+'\'' + ',';
                
                System.debug('--------------111 where options = ' + optionWord);
            }
            optionWord = optionWord.substring(0, optionWord.length() - 1);
           
             System.debug('-------------- where options = ' + optionWord);
            soql += ' AND toLabel(Options__c) includes ('+ optionWord + ')' ;
           
            //'REVERSE TRAFFIC DETECTION & BSM & CVS;SLIDING PANORAMIC ROOF;BLACK PACK;'
            //soql += ' AND toLabel(Options__c) in :parameters.options';

        }
       /*
        for( String tmp : parameters.options ) {
                optionWord += tmp.replaceAll( '\'' , '\\\'' ) + ';';
            }
            
            System.debug( '-------------- where options = ' + optionWord );
            soql += ' AND toLabel(Options__c) includes ( \'' + optionWord + '\' ) ' ;
        */
        
        if (selectedSort == null)
            soql += ' Order by Name_Plate__c , Body_Style__c ';
        //soql += 'limit :list_size offset :counter';

        if (selectedSort != null || selectedSortmobile != null)
            soql += ' Order by  Local_price__c asc';

        System.debug('----------- selectedSort = ' + selectedSort);
        System.debug('----------- selectedSortmobile = ' + selectedSortmobile);
        System.debug('----------- soql = ' + soql);

        List < Asset > assets = Database.query(soql);
        //Map<Id,Asset> mapIdToAsset = new Map<id,Asset>((List<Asset>)Database.query(soql));
        Map < String, VehicleSearchBean.Vehicle > distinct = new Map < String, VehicleSearchBean.Vehicle > ();
        // controller1= new ApexPages.standardSetController(mapIdToAsset.values());



        //controller1.setPageSize(10);
        // setcon= new ApexPages.standardSetController(mapIdToAsset.values());
        //(List<Asset>) controller1.getRecords()

        for (Asset tmp: assets) {
            productIds.add(tmp.model__c);
            VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle(tmp);
            system.debug('-----vehicle' + vehicle);

            if (ApexPages.CurrentPage().getParameters().get('market') != 'br' && isAPO == true) {
                if (distinct.containsKey(vehicle.getDistinctKey() +tmp.vin__c)) {
                    VehicleSearchBean.Vehicle exist = distinct.get(vehicle.getDistinctKey()+tmp.vin__c);
                    if (vehicle.Price < exist.Price) {
                        distinct.put(vehicle.getDistinctKey()+tmp.vin__c, vehicle);
                    }
                } else {
                    distinct.put(vehicle.getDistinctKey()+tmp.vin__c, vehicle);
                }
            }

        }

        //  sort
        List < VehicleSearchBean.Vehicle > sorted = new List < VehicleSearchBean.Vehicle > ();

        if(!isOnload) {
            for (VehicleSearchBean.SearchSection tmp: this.sort(distinct)) {
                sorted.add((VehicleSearchBean.Vehicle) tmp);
            }
        } else {
            sorted.addALL( (List<VehicleSearchBean.Vehicle> )distinct.values());
        }
        
        system.debug('-Market--' + Market);
        system.debug('-productIds--' + productIds);
        Map < Id, List < JUDAAN_Campaign__c >> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign(productIds, Market, PROMOTIONAL_BANNER_RECORDTYPE);

        system.debug('-this.bean.selectedLanguage--' + this.bean.selectedLanguage);
        for (Integer i = sorted.size() - 1; i >= 0; i--) {
            // for( VehicleSearchBean.Vehicle tmp: this.bean.vehicles ) {

            VehicleSearchBean.Vehicle tmp = sorted[i];

            system.debug('--111-v' + tmp);
            List < JUDAAN_Campaign__c > lstcampaign = campaignMap.get(tmp.productId);
            System.debug('lstcampaign ----' + lstcampaign);
            Map < string, string > mapAssetIdtoCampaignText = new Map < string, string > ();

            List < String > lstcampaignText = new List < string > ();

            JUDAAN_Campaign__c newOSAcampaign = checkCampaign(tmp, lstcampaign);
            if (newOSAcampaign.VIN_Asset_Level_ID__c != null) {

                List < String > lstAssetID = newOSAcampaign.VIN_Asset_Level_ID__c.contains(',') ? newOSAcampaign.VIN_Asset_Level_ID__c.split(',') : new List < string > {
                    newOSAcampaign.VIN_Asset_Level_ID__c
                };
                system.debug('---newOSAcampaign.VIN_Asset_Level_ID__c' + newOSAcampaign.VIN_Asset_Level_ID__c);
                if (lstAssetID != null) {
                    lstcampaignText = newOSAcampaign.VIN_Level_Campaign_Text__c.contains(',') ? newOSAcampaign.VIN_Level_Campaign_Text__c.split(',') : new List < string > {
                        newOSAcampaign.VIN_Level_Campaign_Text__c
                    };

                    if (lstcampaignText != null)
                        for (Integer j = lstAssetID.size() - 1; j >= 0; j--) {
                            String strassetid = lstAssetID[j];
                            String strCampaignText = lstcampaignText.size() == 1 ? lstcampaignText[0] : lstcampaignText[j];
                            mapAssetIdtoCampaignText.put(strassetid, strCampaignText);

                        }


                }


            }
            system.debug('--mapAssetIdtoCampaignText' + mapAssetIdtoCampaignText);
            if (newOSAcampaign != null && newOSAcampaign.product__c != null) {
                {


                    if ('ja'.equals(this.bean.selectedLanguage)) {
                        tmp.campaign = newOSAcampaign.JapaneseDescription__c;
                    } else {
                        tmp.campaign = !mapAssetIdtoCampaignText.containsKey(tmp.assetVIN) ? newOSAcampaign.EnglishDescription__c : mapAssetIdtoCampaignText.get(tmp.assetVIN);
                    }
                    tmp.campaignUrlText = newOSAcampaign.Campaign_Url_Text__c;
                    //system.debug('-specialVehicle --'+specialVehicle );
                }


                system.debug('-tmp.campaign --' + tmp.campaign);

            } else {
                if (isCampaign)
                    sorted.remove(i);

            }
        } //for    
        return (sorted);
        // return( mapIdToAsset.values() );
    }

    public JUDAAN_Campaign__c checkCampaign(VehicleSearchBean.Vehicle tmp, List < JUDAAN_Campaign__c > lstcampaign) {
        system.debug('---lstcampaign' + lstcampaign);
        system.debug('---v' + tmp);

        JUDAAN_Campaign__c newOSAcampaign = new JUDAAN_Campaign__c();
        if (lstcampaign != null && !lstcampaign.isEmpty()) {
            for (JUDAAN_Campaign__c campaign: lstcampaign) {

                //compare 3 criteria not null                    
                if (campaign.Body_Style__c != null && campaign.Body_Style__c == tmp.bodystyle &&
                    campaign.Model_Year__c != null && campaign.Model_Year__c == tmp.modelYearFormat &&
                    campaign.Specification_Pack_Alternative__c != null && campaign.Specification_Pack_Alternative__c == tmp.specification
                ) {
                    System.debug('campaign2----' + campaign);
                    newOSAcampaign = campaign;

                }
                //compare 2 criteria not null   - bodystyle and model year                 
                else if (campaign.Body_Style__c != null && campaign.Body_Style__c == tmp.bodystyle &&
                    campaign.Model_Year__c != null && campaign.Model_Year__c == tmp.modelYearFormat &&
                    (campaign.Specification_Pack_Alternative__c == null || campaign.Specification_Pack_Alternative__c == '')
                ) {
                    System.debug('campaign3----' + campaign);
                    newOSAcampaign = campaign;

                }





                //compare 2 criteria not null   - Specification_Pack_Alternative__c  and model year                 
                else if ((campaign.Body_Style__c == null || campaign.Body_Style__c == '') &&
                    campaign.Model_Year__c != null && campaign.Model_Year__c == tmp.modelYearFormat &&
                    (campaign.Specification_Pack_Alternative__c == null || campaign.Specification_Pack_Alternative__c == '')
                ) {
                    System.debug('campaign5----' + campaign);
                    newOSAcampaign = campaign;

                }

                //compare 1 criteria not null   - Model_Year__c 
                else if (
                    (campaign.Body_Style__c == null || campaign.Body_Style__c == '') &&
                    (campaign.Model_Year__c != null && campaign.Model_Year__c == tmp.modelYearFormat) &&
                    (campaign.Specification_Pack_Alternative__c == null || campaign.Specification_Pack_Alternative__c == '')
                ) {

                    System.debug('campaign1----' + campaign);
                    newOSAcampaign = campaign;

                }

                //compare 1 criteria not null   - bodystyle                    
                else if (campaign.Body_Style__c != null && campaign.Body_Style__c == tmp.bodystyle &&
                    (campaign.Model_Year__c == null || campaign.Model_Year__c == '') &&
                    (campaign.Specification_Pack_Alternative__c == null || campaign.Specification_Pack_Alternative__c == '')
                ) {
                    System.debug('campaign4----' + campaign);
                    newOSAcampaign = campaign;

                }
                //compare 1 criteria not null   - Specification_Pack_Alternative__c   
                else if (
                    (campaign.Body_Style__c == null || campaign.Body_Style__c == '') &&
                    (campaign.Model_Year__c == null || campaign.Model_Year__c == '') &&
                    (campaign.Specification_Pack_Alternative__c != null && campaign.Specification_Pack_Alternative__c == tmp.specification)
                ) {
                    System.debug('campaign7----' + campaign);
                    newOSAcampaign = campaign;

                }
                //compare 3 criteria  null   - Specification_Pack_Alternative__c   ,Model_Year__c .Body_Style__c  
                else if (
                    (campaign.Body_Style__c == null || campaign.Body_Style__c == '') &&
                    (campaign.Model_Year__c == null || campaign.Model_Year__c == '') &&
                    (campaign.Specification_Pack_Alternative__c == null || campaign.Specification_Pack_Alternative__c == '')
                ) {
                    System.debug('campaign7----' + campaign);
                    newOSAcampaign = campaign;

                }
            }

        }
        return newOSAcampaign;
    }


    /*
     *  sort 
     */
    private List < VehicleSearchBean.SearchSection > sort(Map < String, VehicleSearchBean.SearchSection > records) {
        Set < String > keys = new Set < String > ();
        Map < String, VehicleSearchBean.SearchSection > mapKeyToRecordValues = new Map < String, VehicleSearchBean.SearchSection > ();
        for (VehicleSearchBean.SearchSection tmp: records.values()) {
            selectedSort = selectedSortmobile != null && selectedSortmobile != '' && selectedSortmobile != '-SORT BY-' ? selectedSortmobile : selectedSort;
            System.debug('-----------222 selectedSortmobile = ' + selectedSortmobile);
            if (selectedSort == '' || selectedSort == null || selectedSort == Label.SORT_BY)
                keys.add((String) tmp.getSortKey());
            else
                keys.add(String.valueof(tmp.price));
            //mapKeyToRecordValues.put((String)tmp.getSortKey(), tmp);
        }

        List < String > sortList = new List < String > (keys);
        system.debug('---sortList ' + sortList);
        List < String > sortListNew = new List < String > ();

        system.debug('---selectedSort ' + selectedSort);
        if (selectedSort != null && selectedSort != '' && selectedSort == System.Label.PRICE_HIGH_TO_LOW) {
            //sortList.clear();
            system.debug('---sortListNew' + sortListNew);
            for (Integer i = sortList.size() - 1; i >= 0; i--) {
                sortListNew.add(sortList.get(i));
            }
        } else {
            if (sortList.contains('_'))
                sortList.sort();
        }
        system.debug('---2222sortList ' + sortList);
        List < String > sortListSorted = selectedSort != null && selectedSort != '' && selectedSort == System.Label.PRICE_HIGH_TO_LOW ? sortListNew : sortList;

        List < VehicleSearchBean.SearchSection > sorted = new List < VehicleSearchBean.SearchSection > ();

        for (String tmp: sortListSorted) {
            system.debug('----tmp ' + tmp);

            for (VehicleSearchBean.SearchSection section: records.values()) {
                system.debug('----section.getSortKey()' + section.getSortKey());
                string tocheck;
                //if( tmp.contains( section.getSortKey() ) )
                if (tmp == (tocheck = selectedSort != null ? string.valueof(section.price) : section.getSortKey()))

                {
                    system.debug('111111' + section.getSortKey());
                    sorted.add(section);

                }

            }


        }
        return (sorted);
    }


    /*public void tabSelected() {

        system.debug('-selectedmin-' + minprice);
        isOnload = false;
        
        
        Boolean isNew = false; 
        Boolean isAPO  = false;
        isAPOFilter = false;
        
        isNew = ApexPages.currentPage().getParameters().containskey('isNew')  ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isNew')) : isAPOFilter ;
        isAPO = ApexPages.currentPage().getParameters().containskey('isAPO') ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isAPO')) : isAPOFilter ; 
        system.debug('---1111isNew '+isNew );
        system.debug('---111isAPO '+isAPO );
        
        system.debug('---isAPOFilter'+isAPOFilter );
        
        isAPOFilter = (isAPO == true ) ? true : false;
        isNew = (isNew == false) && (isAPO == false) ? true : (isAPO == true ) ? false : true;
      
        system.debug('---2222isNew '+isNew );
        system.debug('--222-isAPO '+isAPO );
        system.debug('---22isAPOFilter'+isAPOFilter );
  
        //ApexPages.currentPage().getParameters().put('isapofilter',String.valueof(isAPOFilter));
        processSelected();
     } */
     
     public PageReference tabSelected() {

        system.debug('-selectedmin-' + minprice);
        //isOnload = false;
        
        
        Boolean isNew = false; 
        Boolean isAPO  = false;
        isAPOFilter = false;
        
        isNew = ApexPages.currentPage().getParameters().containskey('isNew')  ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isNew')) : isAPOFilter ;
        isAPO = ApexPages.currentPage().getParameters().containskey('isAPO') ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isAPO')) : isAPOFilter ; 
        system.debug('---1111isNew '+isNew );
        system.debug('---111isAPO '+isAPO );
        
        system.debug('---isAPOFilter'+isAPOFilter );
        
        //isAPOFilter = (isAPO == true ) ? true : false;
        
        //isNew = (isNew == false) && (isAPO == false) ? true : (isAPO == true ) ? false : true;
        
        
        //Boolean isAPOPage= false;
        //isAPOPage= Boolean.valueof(ApexPages.currentPage().getParameters().get('isAPO'));
       /* Map<String, Object> obj = new Map<String, Object>();
        obj.put('Model', 'XE');

        System.debug(JSON.Serialize(obj));

        String toPassData = JSON.Serialize(obj);*/
        PageReference p;
        if(isNew){
        
        
        p= Page.vehiclesearchnew;
        /*Cookie cook = new Cookie('new', toPassData, null, -1, false);
        p.setCookies(new Cookie[] {cook});*/
        //p.getParameters().put('isAPO', String.valueof(isAPO));
        
        
        String modelName= ApexPages.currentPage().getParameters().get('model');
        
        if (ApexPages.currentPage().getParameters().get('brand') == 'jaguar') {
            p.getParameters().put('brand', 'jaguar');
        } else {
            p.getParameters().put('brand', 'landrover');
        }
        if (selectedValue != '' && selectedValue != Label.None_State)
            p.getParameters().put('state', selectedValue);
        
        
        p.getParameters().put('model', modelName);
        p.getParameters().put('market', Market);
        String lang= ApexPages.currentPage().getParameters().get('lang') != null ? ApexPages.currentPage().getParameters().get('lang') : this.bean.selectedLanguage;
        p.getParameters().put('lang', lang);
        p.setRedirect(true);
        return p;
        
        }
        
       return null;
        //system.debug('---2222isNew '+isNew );
        //system.debug('--222-isAPO '+isAPO );
        //system.debug('---22isAPOFilter'+isAPOFilter );
  
        //ApexPages.currentPage().getParameters().put('isapofilter',String.valueof(isAPOFilter));
        //processSelected();
     }   

    public void processSelected() {

        
        isOnload = false;
        
        
        Boolean isNew = false; 
        Boolean isAPO  = true;
        
        //isNew = ApexPages.currentPage().getParameters().containskey('isNew')  ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isNew')) : isAPOFilter ;
        //isAPO = ApexPages.currentPage().getParameters().containskey('isAPO') ? Boolean.valueof(ApexPages.currentPage().getParameters().get('isAPO')) : isAPOFilter ; 
        system.debug('---333isNew '+isNew );
        system.debug('---3333isAPO '+isAPO );
        
        
        //system.debug('---isAPOFilter'+isAPOFilter );
        //isAPOFilter = (isAPO == true ) ? true : false;
        //isNew = (isNew == false) && (isAPO == false) ? true : (isAPO == true ) ? false : true;
        
        
        system.debug('---7777isAPOFilter'+isAPOFilter );
        
        system.debug('-- 8888isAPOFilter'+isAPOFilter );
        
        system.debug('--444-isNew '+isNew );
        system.debug('--555-isAPO '+isAPO );
      
        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters();
        //selectedModels.add('XE');
        //system.debug('---selectedModel '+selectedModel );
        system.debug('---processSelected');

        for (wrapperClass objWP: wrapClassList) {
            system.debug('---objWP' + objWP);

            for (APOVehicleSearchNewController.modelClass modelType: objWP.modelLst) {

                system.debug('---modelType.flag' + modelType.flag);

                if (modelType.flag == true || objWP.flag == true) {

                    //selectedModels.add(modelType.modelName);

                    parameters.models.add(modelType.modelName);
                }

            }
            //system.debug('---selectedModels'+selectedModels);
            for (APOVehicleSearchNewController.bodystyleClass bodyStyleType: objWP.bodystyleLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedBodystyles.add(bodyStyleType.bodyStyleName);
                    parameters.styles.add(bodyStyleType.bodyStyleName);
                }
            }
            //system.debug('---selectedBodystyles'+selectedBodystyles);

            for (APOVehicleSearchNewController.fuelClass bodyStyleType: objWP.fuelclassLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedBodystyles.add(bodyStyleType.bodyStyleName);
                    parameters.fuelTypes.add(bodyStyleType.fuelName);
                }
            }



            for (APOVehicleSearchNewController.enginecapacityClass bodyStyleType: objWP.enginecapacityClassLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedBodystyles.add(bodyStyleType.bodyStyleName);
                    parameters.engines.add(bodyStyleType.engineName);
                }
            }

            for (APOVehicleSearchNewController.powertrainClass bodyStyleType: objWP.powertrainClassLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedBodystyles.add(bodyStyleType.bodyStyleName);
                    parameters.powertrains.add(bodyStyleType.powertrainName);
                }
            }


            for (APOVehicleSearchNewController.exteriorColorGroupClass bodyStyleType: objWP.exteriorColorGroupClassLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedexteriorcolorName.add(bodyStyleType.exteriorcolorgroupName );
                    parameters.exteriorGroupColours.add(bodyStyleType.exteriorcolorgroupName);
                }
            }


            for (APOVehicleSearchNewController.interiorcolorClass bodyStyleType: objWP.interiorcolorClassLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedinteriorcolorName.add(bodyStyleType.interiorcolorName );
                    parameters.interiorColours.add(bodyStyleType.interiorcolorName);
                }
            }

            for (APOVehicleSearchNewController.specificationClass bodyStyleType: objWP.specificationClassLst) {
                if (bodyStyleType.flag == true || objWP.flag == true) {
                    //selectedinteriorcolorName.add(bodyStyleType.interiorcolorName );
                    parameters.specifications.add(bodyStyleType.specificationName);
                }
            }

            system.debug('--objWP.optionClassLst' + objWP.optionClassLst);
            for (APOVehicleSearchNewController.optionClass optionType: objWP.optionClassLst) {
                if (optionType.flag == true || objWP.flag == true) {
                    //selectedoptionName.add(optionType.optionname );
                    parameters.options.add(optionType.optionname);
                }
            }

        } //end main for
        //setCon.setpagesize(10);
        assetlstdummy = new List < VehicleSearchBean.Vehicle > ();
        assetlst = selectData(parameters,isNew , isAPO);

        assetlstdummy = assetlst;
        this.bean.vehicleCount = assetlst.size();
        total_size = assetlst.size();
        temp = new List < VehicleSearchBean.Vehicle > ();
        system.debug('-total_size --' + total_size);
        index = 10;
        start = 0;
        index = index > total_size ? total_size : index;
        for (Integer i = start; i < index; i++) {
            system.debug('-assetlstdummy--' + i);

            temp.add(assetlstdummy.get(i));
        }
        assetlst = temp;

        prevBool = index == 0 || index >= 11 ? true : false;
        nextBool = index == 0 || index >= total_size ? true : false;
        //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(assetlst);
        system.debug('---assetlst ' + assetlst);
        system.debug('--temp' + temp.size());
    }


   

    public pageReference switch () {
        Boolean isAPO= false;
        isAPO = Boolean.valueof(ApexPages.currentPage().getParameters().get('isAPO'));
        
        PageReference p;
        if(isAPO)
            p= Page.APOVehicleSingle;
        else
            p = Page.vehiclesingle;
        String assetId = ApexPages.currentPage().getParameters().get('assetid');
        
        if (ApexPages.currentPage().getParameters().get('brand') == 'jaguar') {
            p.getParameters().put('brand', 'jaguar');
        } else {
            p.getParameters().put('brand', 'landrover');
        }
        if (selectedValue != '' && selectedValue != Label.None_State)
            p.getParameters().put('state', selectedValue);
        
        p.getParameters().put('id', assetId);
        p.getParameters().put('market', Market);
        String lang= ApexPages.currentPage().getParameters().get('lang') != null ? ApexPages.currentPage().getParameters().get('lang') : this.bean.selectedLanguage;
        p.getParameters().put('lang', lang);
        p.setRedirect(true);
        
        return p;
    }


    public string selectedmodel {
        get;
        set;
    }

    public pageReference loadvehicleSearch() {

        PageReference p = Page.vehiclesearchnew;
        if (ApexPages.currentPage().getParameters().get('brand') == 'jaguar') {
            p.getParameters().put('brand', 'jaguar');
            //p.getParameters().put('model', 'XE');

        } else {
            p.getParameters().put('brand', 'landrover');
           // p.getParameters().put('model', 'DISCOVERY');

        } 
        system.debug('-lang---'+this.bean.selectedLanguage);
        
        p.getParameters().put('lang', this.bean.selectedLanguage);


        if (selectedValue == Label.None_State)
            selectedValue = 'None';

        system.debug('----selectedValue' + selectedValue);
        p.getParameters().put('state', selectedValue);


        p.getParameters().put('market', Market);
        p.getParameters().put('model', selectedmodel);
      
        p.setRedirect(true);

        return p;

    }
    
    public PageReference LoadModels() {
        System.debug('LoadModels starts');
        System.debug('------------- selectedValue222' + selectedValue);
        ApexPages.currentPage().getParameters().put('statename', selectedValue);


        //this.bean.init();
        String deepModel = ApexPages.currentPage().getParameters().get('model');
        //String deepColor = ApexPages.currentPage().getParameters().get('colour');

        VehicleSearchInputParameters parameters = new VehicleSearchInputParameters(deepModel);

        //parameters.inputDeposit = selectedValue;
        //VehicleSearch_Model logic = new VehicleSearch_Model( this.bean.selectedBrand, parameters );



        VehicleSearch_Model logic = new VehicleSearch_Model(this.bean.selectedBrand, Market, parameters);

        VehicleSearchBean bean = logic.getSelectOptions();

        this.bean.models = this.bean.setCheckedModels(bean.models);
        system.debug('--this.bean.models ' + this.bean.models);
        this.bean.vehicleCount = bean.vehicleCount;

        Set < String > validModels = new Set < String > ();
        Set < String > ids = new Set < String > ();
        for (VehicleSearchBean.Model model: this.bean.models) {
            ids.add(model.productId);
            validModels.add(model.modelName);
            if ((model.modelName).equalsIgnoreCase(deepModel)) {
                ValidModelFromDx = true;
                break;
            }
        }
        List < String > productIds = new List < String > (ids);

        Map < Id, List < JUDAAN_Campaign__c >> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign(productIds, Market, PROMOTIONAL_BANNER_RECORDTYPE);

        for (VehicleSearchBean.Model model: this.bean.models) {
            List < JUDAAN_Campaign__c > lstcampaign = campaignMap.get(model.productId);
            if (lstcampaign != null && !lstcampaign.isempty()) {
                model.campaignName = Market == 'jp' ? lstcampaign[0].EnglishDescription__c : Label.Special_Offer;
                model.modelCampaignName = model.modelName;
            }
        }
        System.debug('LoadModels ends');
        return JUDAANUtil.brandCheck();
    }

     public List < VehicleSearchBean.Vehicle > selectDataNew(VehicleSearchInputParameters parameters) {
        //System.debug( '------------- section = ' + section );
        List < String > productIds = new List < String > ();
        strState = selectedValue != null && selectedValue != Label.None_State ? selectedValue : ApexPages.currentPage().getParameters().containsKey('state') ? ApexPages.currentPage().getParameters().get('state') : null;

        system.debug('--strState ' + strState);
        system.debug('--minprice' + minprice);
        system.debug('--maxprice' + maxprice);

        String soql = 'Select id, ToLabel( Exterior_Colour_Group__c ) , ToLabel( Exterior_Colour__c ) , Interior_Color_Image__c, Search_Key__c , Search_Key_Text__c, Name ' +
            ' ,Master_Colour__c,Model__c,Body_Style_Image_M__c , ToLabel( Interior_Color__c ) ' +
            ' , Vehicle_Image_L__c, Vehicle_Image_M__c,Asset_Specification_Pack__c,Monthly_Price__c' +
            ' , Exterior_Detail_Color_Image__c,pictures__c ' +
            ' , Option_Image_Root__c , ToLabel( Options__c ) , Interior_colour_code__c , Colour__c, Exterior_Colour_Code__c ' +
            ' , Model_Year__c , Fuel_TypeValue__c , TransmissionValue__c , OptionsValue__c , Exterior_Colour_GroupValue__c ' +
            ' , ToLabel( Product2.BodyStyle_Alternative__c ) ,  Product2.Model__r.Model_Alternative__c, Product2.Engine_Capacity_Alternative__c , product2.Monthly_Price_From__c,product2.Previous_Monthly_Price_From__c,ToLabel( Product2.Fuel_Type_Alternative__c ) , ToLabel(Product2.Model_Alternative__c) ' +
            ' , Product2.Registration_Year_Alternative__c , Product2.Specification_Pack_Alternative__c , ToLabel( Product2.Transmission_Alternative__c ) , ToLabel( Product2.Wheel_Driven_Alternative__c ) ' +
            ' , Product2.Engine__c , Body_Style_Value__c , ToLabel( Product2.Power_Output_Alternative__c ) , Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c ' +
            ' , New_Display__c, APO_Display__c,Local_price__c , vin__c,Order_Number__c, Model__r.Model_Alternative__c, account.name, account.City_Name_Local__c,account.billingcity,account.billingstate,Power_Output_Value__c , Previous_Price__c,Product2.Vehicle_Image_L__c,Product2.KMILink__c ' +
            ' , Mileage__c,APO__c'+
            ' From Asset ' +
            ' Where Product2.Make__r.Name =:brandName ' +
            ' And Account.Country_ISO_Code__c =:market ' +
            ' And Model__r.OSA_Country_ISO_Code__c includes (:market)' +
            ' And Approved_On_Udaan__c = true ' +
            ' And New_Display__c = false' +
            ' AND APO__c = true' +
            ' And Product2.New_Vehicle__c = true ' +
            ' AND Product2.Model_Alternative__c != null ';

        if (strState != null && strState != '' && strState != Label.None_State)
            soql += ' And Account.Regional_State_Code__c =: strState';

         // To display market wise Vista Status
         JUDAAN_Market_Settings__mdt marketSettings = JUDAAN_Market_Settings__mdt.getInstance(market);
         if(marketSettings != null) {
             String vistaStatus = '';
             if(brandName == 'jaguar') {
                vistaStatus = marketSettings.JG_Vista_Status__c;    
             } else if(brandName == 'landrover') {
                 vistaStatus = marketSettings.LR_Vista_Status__c;
             }
             // Check if Vista Status exist
             if(String.isNotBlank(vistaStatus)) {
                 soql += ' And Vista_Status__c IN (' + StringUtil.getInOperatorValue(vistaStatus) + ')';
             }
         }
         
        List < String > modelsId = parameters.models;
        System.debug('----------- where models = ' + modelsId);
        
        //if (modelsId != null && !modelsId.isEmpty())
           // soql += ' And Product2.Model_Alternative__c in :modelsId ';

        System.debug('----------- soql = ' + soql);

        //List < Asset > assets = Database.query(soql);
        Map<Id,Asset> mapIdToAsset = new Map<id,Asset>((List<Asset>)Database.query(soql));
        Map < String, VehicleSearchBean.Vehicle > distinct = new Map < String, VehicleSearchBean.Vehicle > ();
       
        transient  Set < String > models = new Set < String > ();
        transient Set < String > bodyStyles = new Set < String > ();

        transient Set < String > enginecapacity = new Set < String > ();
        transient Set < String > fuel = new Set < String > ();
        transient Set < String > powertrain = new Set < String > ();

        transient Set < String > options = new Set < String > ();
        transient Set < String > exteriorGroupColours = new Set < String > ();
        transient Set < String > interiorColours = new Set < String > ();
        transient Set < String > specifications = new Set < String > ();
        transient Set < String > transmissionSet = new Set < String > ();

        wrapClassList = new List < wrapperClass > ();
        
        wrapperClass objWC = new wrapperClass();
       
        for (Asset tmp: mapIdToAsset.values()) {
            system.debug('---tmp'+tmp);
            objWC.isAPO = tmp.APO__c;
            
            VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle(tmp);
            system.debug('-----vehicle' + vehicle);
           
            if (!models.contains(tmp.Product2.Model_Alternative__c)) {
                
                Decimal sortNo = 0;
                if(market == 'sg') {
                    sortNo = tmp.Product2.Name_Plate_Display_Order_SG__c;
                } else {
                    sortNo = tmp.Product2.Name_plate_display_order__c;
                }
                
                models.add(tmp.Product2.Model_Alternative__c);
                APOVehicleSearchNewController.modelClass wc = new APOVehicleSearchNewController.modelClass(false, tmp.Product2.Model_Alternative__c, tmp.Product2.Vehicle_IMage_L__c, sortNo);
                
                objWC.modelLst.add(wc);
                
                if ((modelName == null || modelName == '') && (market != 'br' && strState == NULL)) {
                    objWC.flag = true;
                    processSelected();
                    objWC.flag = false;
                }
                
            }
           

            if (!localpriceMinSet.contains(string.valueof(tmp.Local_price__c))) {
                string pricestring = tmp.Local_price__c.format();
                //pricestring = String.format(pricestring , '0,number,#,###');
                system.debug('--objAsset.Local_price__c'+pricestring );
                String pricedec = StringUtil.zeroPadding(tmp.Local_price__c, 10);
                localpriceMinSet.add(Decimal.valueof(pricedec).format());
                //localpriceMaxSet.add(tmp.Local_price__c);  
                // APOVehicleSearchNewController.modelClass  wc = new APOVehicleSearchNewController.modelClass(false,tmp.Product2.Model_Alternative__c, tmp.Product2.Vehicle_IMage_L__c);


                //objWC.localpriceSet.add(wc);


            }
            system.debug('---tmp.Mileage__c'+tmp.Mileage__c);
            if (!mileagepriceMinSet.contains(string.valueof(tmp.Mileage__c ))) {
                //StringUtil.zeroPadding( this.price , 10 )
                system.debug('--objAsset.Local_price__c'+tmp.Mileage__c );
                
                
                mileagepriceMinSet.add(string.valueof(StringUtil.zeroPadding(tmp.Mileage__c , 10)));
                

            }
              if(!monthlypriceMinSet.contains(string.valueof(tmp.Monthly_Price__c) )){
                    string pricestring = tmp.Monthly_Price__c.format();
                    String pricedec = StringUtil.zeroPadding(tmp.Monthly_Price__c, 8);
                    monthlypriceMinSet.add(Decimal.valueof(pricedec).format()); 
                   
                
                }
            if (!bodyStyles.contains(StringUtil.getValue(tmp.Product2.BodyStyle_Alternative__c))) {
                bodyStyles.add(StringUtil.getValue(tmp.Product2.BodyStyle_Alternative__c));
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.bodyStyleClass wcBodystyle = new APOVehicleSearchNewController.bodyStyleClass(false, StringUtil.getValue(tmp.Product2.BodyStyle_Alternative__c));


                objWC.bodystyleLst.add(wcBodystyle);
            }

            if (!fuel.contains(tmp.Product2.Fuel_Type_Alternative__c)) {
                fuel.add(tmp.Product2.Fuel_Type_Alternative__c);
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.fuelClass wcfuel = new APOVehicleSearchNewController.fuelClass(false, tmp.Product2.Fuel_Type_Alternative__c);


                objWC.fuelclassLst.add(wcfuel);
            }



            if (!enginecapacity.contains(tmp.Product2.Engine_Capacity_Alternative__c) && tmp.Product2.Engine_Capacity_Alternative__c != null) {
                enginecapacity.add(tmp.Product2.Engine_Capacity_Alternative__c);
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.enginecapacityClass wcenginecapacity = new APOVehicleSearchNewController.enginecapacityClass(false, tmp.Product2.Engine_Capacity_Alternative__c);


                objWC.enginecapacityclassLst.add(wcenginecapacity);
            }



            if (!powertrain.contains(tmp.Product2.Power_Output_Alternative__c) && tmp.Product2.Power_Output_Alternative__c !=null) {
                powertrain.add(tmp.Product2.Power_Output_Alternative__c);
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.powertrainClass wcpowertrain = new APOVehicleSearchNewController.powertrainClass(false, tmp.Product2.Power_Output_Alternative__c);


                objWC.powertrainclassLst.add(wcpowertrain);
            }



            if (!exteriorGroupColours.contains(tmp.Exterior_Colour_Group__c)) {
                exteriorGroupColours.add(tmp.Exterior_Colour_Group__c);
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.exteriorColorGroupClass wcexteriorColorGroup = new APOVehicleSearchNewController.exteriorColorGroupClass(false, tmp.Exterior_Colour_Group__c, tmp.Exterior_Detail_Color_Image__c);


                objWC.exteriorColorGroupClassLst.add(wcexteriorColorGroup);
            }




            if (!interiorColours.contains(StringUtil.getValue(tmp.Interior_Color__c))) {
                interiorColours.add(StringUtil.getValue(tmp.Interior_Color__c));
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.interiorcolorClass wcinteriorcolor = new APOVehicleSearchNewController.interiorcolorClass(false, StringUtil.getValue(tmp.Interior_Color__c), tmp.Interior_Color_Image__c);


                objWC.interiorcolorClassLst.add(wcinteriorcolor);
            }





            if (!specifications.contains(tmp.Product2.Specification_Pack_Alternative__c) && tmp.Product2.Specification_Pack_Alternative__c != null) {
                specifications.add(tmp.Product2.Specification_Pack_Alternative__c);
                //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                APOVehicleSearchNewController.specificationClass wcspecification = new APOVehicleSearchNewController.specificationClass(false, tmp.Product2.Specification_Pack_Alternative__c);


                objWC.specificationClassLst.add(wcspecification);
            }
            /* 
               if(!transmissionSet.contains( StringUtil.getValue( (tmp.Product2.Transmission_Alternative__c )))){
                  system.debug('---tmp.Product2.Transmission_Alternative__c'+tmp.Product2.Transmission_Alternative__c);
                  system.debug('---tmp.Product2.Transmission_Alternative__c'+StringUtil.getValue(tmp.Product2.Transmission_Alternative__c));
                  transmissionSet.add( StringUtil.getValue( tmp.Product2.Transmission_Alternative__c) );
                  //fuelType.add(tmp.Product2.Fuel_Type_Alternative__c );
                  
                  APOVehicleSearchNewController.TransmissionClass wcTransmission = new APOVehicleSearchNewController.TransmissionClass(false, StringUtil.getValue( tmp.Product2.Transmission_Alternative__c ));
                                   
             
                  objWC.transmissionClassLst.add(wcTransmission );
                  system.debug('---tmp--'+wcTransmission );
                } 
                */

            if (!String.isEmpty(tmp.Options__c)) {
                List < String > optionValues = StringUtil.splitMultiplePickList(tmp.Options__c);

                for (String optionName: optionValues) {
                    if (!options.contains(optionName)) {
                        APOVehicleSearchNewController.optionClass wcOption = new APOVehicleSearchNewController.optionClass(false, optionName);

                        options.add(StringUtil.getValue(optionName));
                        objWC.optionClassLst.add(wcOption);
                    }
                }
            }

            system.debug('-tmp.Product2.Model_Alternative__c'+tmp.Product2.Model_Alternative__c);
              system.debug('-modelsId'+modelsId);
           
            if (ApexPages.CurrentPage().getParameters().get('market') == 'jp' && tmp.APO__c == true) {
                productIds.add(tmp.model__c);
                if(tmp.Product2.Model_Alternative__c.equalsIgnoreCase(modelsId[0])){
                    system.debug('---contains'+modelsId.contains(tmp.Product2.Model_Alternative__c));
                    if (distinct.containsKey(vehicle.getDistinctKey())) {
                        VehicleSearchBean.Vehicle exist = distinct.get(vehicle.getDistinctKey());
                        if (vehicle.Price < exist.Price) {
                            distinct.put(vehicle.getDistinctKey(), vehicle);
                        }
                    } else {
                        distinct.put(vehicle.getDistinctKey(), vehicle);
                    }
                }
            }
            
            if (ApexPages.CurrentPage().getParameters().get('market') != 'jp' && tmp.APO__c == true) {
                productIds.add(tmp.model__c);
                //if(tmp.Product2.Model_Alternative__c.equalsIgnoreCase(modelsId[0])){
                system.debug('---contains'+modelsId.contains(tmp.Product2.Model_Alternative__c));
                if (distinct.containsKey(vehicle.getDistinctKey())) {
                    VehicleSearchBean.Vehicle exist = distinct.get(vehicle.getDistinctKey());
                    if (vehicle.Price < exist.Price) {
                        distinct.put(vehicle.getDistinctKey(), vehicle);
                    }
                } else {
                    distinct.put(vehicle.getDistinctKey(), vehicle);
                }
                //}
            }

        }
         
         // Sort Models
         objWC.modelLst.sort();
         objWC.exteriorColorGroupClassLst.sort();
         objWC.interiorcolorClassLst.sort();
         objWC.powertrainclassLst.sort();
         objWC.bodystyleLst.sort();
         objWC.enginecapacityclassLst.sort();
         
         
         //  sort
         List < VehicleSearchBean.Vehicle > sorted = new List < VehicleSearchBean.Vehicle > ();
         
         
         
         sorted.addALL( (List<VehicleSearchBean.Vehicle> )distinct.values());
         
         wrapClassList.add(objWC);
         models.clear();
         specifications.clear();
         bodyStyles.clear();
         fuel.clear();
         enginecapacity.clear();
         exteriorGroupColours.clear();
         interiorColours.clear();
         //mapIdToAsset.clear();
         
         system.debug('-Market--' + Market);
         system.debug('-productIds--' + productIds);
         Map < Id, List < JUDAAN_Campaign__c >> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign(productIds, Market, PROMOTIONAL_BANNER_RECORDTYPE);
         
         system.debug('-this.bean.selectedLanguage--' + this.bean.selectedLanguage);
         for (Integer i = sorted.size() - 1; i >= 0; i--) {
             // for( VehicleSearchBean.Vehicle tmp: this.bean.vehicles ) {
             
             VehicleSearchBean.Vehicle tmp = sorted[i];
             
             system.debug('--111-v' + tmp);
             List < JUDAAN_Campaign__c > lstcampaign = campaignMap.get(tmp.productId);
             System.debug('lstcampaign ----' + lstcampaign);
             Map < string, string > mapAssetIdtoCampaignText = new Map < string, string > ();
             
             List < String > lstcampaignText = new List < string > ();
             
             JUDAAN_Campaign__c newOSAcampaign = checkCampaign(tmp, lstcampaign);
             
             system.debug('--mapAssetIdtoCampaignText' + mapAssetIdtoCampaignText);
             if (newOSAcampaign != null && newOSAcampaign.product__c != null) {
                 if ('ja'.equals(this.bean.selectedLanguage)) {
                     tmp.campaign = newOSAcampaign.JapaneseDescription__c;
                 } else {
                     tmp.campaign = !mapAssetIdtoCampaignText.containsKey(tmp.assetVIN) ? newOSAcampaign.EnglishDescription__c : mapAssetIdtoCampaignText.get(tmp.assetVIN);
                 }
                 tmp.campaignUrlText = newOSAcampaign.Campaign_Url_Text__c;
                 //system.debug('-specialVehicle --'+specialVehicle );
                 
                 system.debug('-tmp.campaign --' + tmp.campaign);
                 
             } else {
                 if (isCampaign)
                     sorted.remove(i);
             }
         } //for    
         return (sorted);
     }
}
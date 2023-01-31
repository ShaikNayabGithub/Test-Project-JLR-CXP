public class VehicleSearchBean {

    public final static String BRAND_JAGUAR = 'Jaguar';
    public final static String BRAND_LANDROVER = 'Land Rover';
    
    public final static String PARAM_LANGUAGE = 'lang';
  
    public List<VehicleSearchBean.Model> models { get; set; }
    public List<VehicleSearchBean.Model> recommendedmodels { get; set; }
    public List<VehicleSearchBean.BodyStyle> bodyStyles { get; set; }
    public List<VehicleSearchBean.Engine> engines { get; set; }
    public List<VehicleSearchBean.ExteriorGroupColour> exteriorGroupColours { get; set; }
    public List<VehicleSearchBean.ExteriorColour> exteriorColours { get; set; }
    public List<VehicleSearchBean.InteriorColour> interiorColours {get; set; }
    public List<VehicleSearchBean.Specification> specifications {get; set; }
    public List<VehicleSearchBean.Option> options { get; set; }
    public List<VehicleSearchBean.Vehicle> vehicles { get; set; }
    public Integer vehicleCount { get; set; }
    public Decimal budget { get; set; }
    public Decimal minBudget { get; set; } 
    public Boolean decidedBudget { get; set; }

    public EngineSelector engineSelector { get; set; }
    public PaymentSelector paymentSelector { get; set; }

    public String selectedLanguage { get; set; }
    public String selectedModelStr { get; set; }
    public String selectedBodyStyleStr { get; set; }
    public String selectedEngineStr { get; set; }
    public String selectedColourStr { get; set; }
    public String selectedPriceStr { get; set; }
    public String selectedOptionStr { get; set; }
    public String selectedSpecificationStr {get; set;}

    public String selectedBrand { get; set; }
    public List<String> selectedModels;
    public List<String> selectedBodyStyles;    
    public List<String> selectedEngines;
    public List<String> selectedExteriorGroupColours;
    public List<String> selectedExteriorDetailColours;
    public List<String> selectedInteriorColours;
    public List<String> selectedSpecifications;
    public List<String> selectedOptions;

    public List<SelectOption> brands;
    
    public String getSearchResultFloatingBarMessage(){
        if(getCheckedModels().size() == 0){
            return System.label.Initial_Search;
        }else{
            if(this.vehicleCount == 1)
            return this.vehicleCount + ' ' + System.Label.Available;
            else
            return this.vehicleCount + ' ' + System.Label.AvailableBR;   
        }
    }
  
    public String getAvailableMessage() {
        String tmp = System.label.WE_HAVE_FOUND_CARS_FOR_YOU;

        if(getCheckedModels().size() == 0){
            tmp = tmp.replaceAll( '\\*' , '0' );
        }else{
            tmp = tmp.replaceAll( '\\*' , String.valueOf( this.vehicleCount ) );
            if(this.vehicleCount == 1){
                tmp = tmp.replaceAll( 'VEHICLES' , 'VEHICLE' );
            }
        }
        return( tmp );
    }
    
    
    
    public VehicleSearchBean() {
        this.brands = new List<SelectOption>();
        
        String language = ApexPages.CurrentPage().getParameters().get( PARAM_LANGUAGE );
        if( ! String.isEmpty( language ) ) {
            this.selectedLanguage = language;
        } else {
            //this.selectedLanguage = System.label.DEFAULT_LANGUAGE;
            this.selectedLanguage = JUDAANUtil.getDefaultLanguage();
        }
        
        if(this.selectedLanguage != 'ja' && this.selectedLanguage != 'en' && this.selectedLanguage != 'pt_BR'){
            this.selectedLanguage = System.label.DEFAULT_LANGUAGE;
        }
    }
    
    public void setDeserializedBean(VehicleSearchBeanSelectedOnly bean) {
        this.models = bean.models;
        this.bodyStyles = bean.bodyStyles;
        this.engines = bean.engines;
        this.exteriorGroupColours = bean.exteriorGroupColours;
        this.exteriorColours = bean.exteriorColours;
        this.interiorColours = bean.interiorColours;
        this.specifications = bean.specifications;
        this.options = bean.options;
        this.vehicles = bean.vehicles;
        this.vehicleCount = bean.vehicleCount;
        this.budget = bean.budget;
        
        //this.selectedLanguage = bean.selectedLanguage;
        this.selectedModelStr = bean.selectedModelStr;
        this.selectedBodyStyleStr = bean.selectedBodyStyleStr;
        this.selectedEngineStr = bean.selectedEngineStr;
        this.selectedColourStr = bean.selectedColourStr;
        if( this.budget == null ) {
            this.selectedPriceStr = System.Label.Unset;
        } else {
            this.selectedPriceStr = bean.selectedPriceStr;  
        }
        this.selectedOptionStr = bean.selectedOptionStr;
        this.selectedSpecificationStr = bean.selectedSpecificationStr;
        
        this.selectedBrand = bean.selectedBrand;
        this.selectedModels = bean.selectedModels;
        this.selectedBodyStyles = bean.selectedBodyStyles;
        this.selectedEngines = bean.selectedEngines;
        this.selectedExteriorGroupColours = bean.selectedExteriorGroupColours;
        this.selectedExteriorDetailColours = bean.selectedExteriorDetailColours;
        this.selectedInteriorColours = bean.selectedInteriorColours;
        this.selectedSpecifications = bean.selectedSpecifications;
        this.selectedOptions = bean.selectedOptions;
        
        this.paymentSelector = new VehicleSearchBean.PaymentSelector();  
    }
    
    public void init() {
        this.selectedModelStr = System.label.Model_FB;
        this.selectedEngineStr = System.label.Engine_FB;
        this.selectedColourStr = System.label.Colour_FB;
        this.selectedPriceStr = System.label.Price_FB;
        this.selectedOptionStr = System.label.Features_FB;
        this.selectedSpecificationStr = System.label.Specification_FB;

        this.brands.add( new SelectOption( BRAND_JAGUAR , System.label.JAGUAR ) );
        this.brands.add( new SelectOption( BRAND_LANDROVER , System.label.LAND_ROVER ) );
        
        this.paymentSelector = new VehicleSearchBean.PaymentSelector();     
        this.decidedBudget = false;
    }

    public List<VehicleSearchBean.Model> setCheckedModels( List<VehicleSearchBean.Model> newOptions ) {
        if( this.models == null || newOptions == null ) {
            return( newOptions );
        }
        for( VehicleSearchBean.Model option : newOptions ) {
            for( VehicleSearchBean.Model exist : this.models ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.Model> setCheckedRecommended( List<VehicleSearchBean.Model> newOptions ) {
        if( this.recommendedModels == null || newOptions == null  ) {
            return( newOptions );
        }
        for( VehicleSearchBean.Model  option : newOptions ) {
            for( VehicleSearchBean.Model exist : this.recommendedModels) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.BodyStyle> setCheckedBodyStyles( List<VehicleSearchBean.BodyStyle> newOptions ) {
        if( this.bodyStyles == null || newOptions == null  ) {
            return( newOptions );
        }
        for( VehicleSearchBean.BodyStyle option : newOptions ) {
            for( VehicleSearchBean.BodyStyle exist : this.bodyStyles ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.Engine> setCheckedEngines( List<VehicleSearchBean.Engine> newOptions ) {
        if( this.engines == null || newOptions == null  ) {
            return( newOptions );
        }
        for( VehicleSearchBean.Engine option : newOptions ) {
            for( VehicleSearchBean.Engine exist : this.engines ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.ExteriorGroupColour> setCheckedExteriorGroupColours( List<VehicleSearchBean.ExteriorGroupColour> newOptions ) {
        if( this.exteriorGroupColours == null || newOptions == null ) {
            return( newOptions );
        }
        for( VehicleSearchBean.ExteriorGroupColour option : newOptions ) {
            for( VehicleSearchBean.ExteriorGroupColour exist : this.exteriorGroupColours ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.ExteriorColour> setCheckedExteriorColours( List<VehicleSearchBean.ExteriorColour> newOptions ) {
        if( this.exteriorColours == null || newOptions == null ) {
            return( newOptions );
        }
        for( VehicleSearchBean.ExteriorColour option : newOptions ) {
            for( VehicleSearchBean.ExteriorColour exist : this.exteriorColours ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.InteriorColour> setCheckedInteriorColours( List<VehicleSearchBean.InteriorColour> newOptions ) {
        if( this.interiorColours == null || newOptions == null  ) {
            return( newOptions );
        }
        for( VehicleSearchBean.InteriorColour option : newOptions ) {
            for( VehicleSearchBean.InteriorColour exist : this.interiorColours ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.Specification> setCheckedSpecifications( List<VehicleSearchBean.Specification> newOptions ) {
        if( this.specifications == null || newOptions == null  ) {
            return( newOptions );
        }
        for( VehicleSearchBean.Specification option : newOptions ) {
            for( VehicleSearchBean.Specification exist : this.specifications ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<VehicleSearchBean.Option> setCheckedOptions( List<VehicleSearchBean.Option> newOptions ) {
        if( this.options == null || newOptions == null  ) {
            return( newOptions );
        }
        for( VehicleSearchBean.Option option : newOptions ) {
            for( VehicleSearchBean.Option exist : this.options ) {
                if( exist.getDistinctKey().equals( option.getDistinctKey() ) ) {
                    option.checked = exist.checked;
                }
            }
        }
        
        return( newOptions );
    }
    
    public List<String> getCheckedModels() {
        List<String> checked = new List<String>();
       
          
        system.debug('--this.models'+this.models);  
        
        for( VehicleSearchBean.Model option : this.models ) {
            String specialmodelname;
            if(ApexPages.CurrentPage().getParameters().containskey( 'modelname') &&  ApexPages.CurrentPage().getParameters().get( 'modelname') != null )
             specialmodelname = ApexPages.CurrentPage().getParameters().get('modelname');  
              system.debug('--option.checked'+option.checked);  
            if( option.checked || (specialmodelname == option.modelname)) {
                 
                checked.add( option.getDistinctKey() );
               
            }
           
        }
        return( checked );
    }
    
    public List<String> getCheckedRecommendModels() {
        List<String> checked = new List<String>();
        if(this.recommendedModels != null){
        for( VehicleSearchBean.Model option : this.recommendedModels) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        }
        return( checked );
    }
    
    public List<String> getCheckedBodyStyles() {
        List<String> checked = new List<String>();
        if( this.bodyStyles == null ) {
            return( checked );
        }
        for( VehicleSearchBean.BodyStyle option : this.bodyStyles ) {
           /* String modelsname;
            if(ApexPages.CurrentPage().getParameters().containskey('models')){
            modelsname = ApexPages.CurrentPage().getParameters().get( 'models');
            system.debug('---modelsname '+modelsname +'checked'+option.checked);
            option.checked = false;
            checked.add( option.getDistinctKey() );
            }*/
            if( option.checked) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }
    
    public List<String> getCheckedExteriorGroupColours() {
        List<String> checked = new List<String>();
        if( this.exteriorGroupColours == null ) {
            return( checked );
        }
        for( VehicleSearchBean.ExteriorGroupColour option : this.exteriorGroupColours ) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }

    public List<String> getCheckedExteriorColours() {
        List<String> checked = new List<String>();
        if( this.exteriorColours == null ) {
            return( checked );
        }
        for( VehicleSearchBean.ExteriorColour option : this.exteriorColours ) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }
    
    public List<String> getCheckedInteriorColours() {
        List<String> checked = new List<String>();
        if( this.interiorColours == null ) {
            return( checked );
        }
        for( VehicleSearchBean.InteriorColour option : this.interiorColours ) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }
    
    public List<String> getCheckedEngines() {
        List<String> checked = new List<String>();
        if( this.engines == null ) {
            return( checked );
        }
        for( VehicleSearchBean.Engine option : this.engines ) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }
    
    public List<String> getCheckedSpecifications() {
        List<String> checked = new List<String>();
        if( this.specifications == null ) {
            return( checked );
        }
        for( VehicleSearchBean.Specification option : this.specifications ) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }
    
    public List<String> getCheckedOptions() {
        List<String> checked = new List<String>();
        if( this.options == null ) {
            return( checked );
        }
        for( VehicleSearchBean.Option option : this.options ) {
            if( option.checked ) {
                checked.add( option.getDistinctKey() );
            }
        }
        return( checked );
    }
    
    private List<String> getCheckedValue( List<VehicleSearchBean.SearchSection> options ) {
        List<String> checked = new List<String>();
        if( this.options == null ) {
            return( checked );
        }
        for( VehicleSearchBean.SearchSection option : this.options ) {
            if( option.getChecked() ) {
                checked.add( option.getDistinctKey() );
            }
        }
        
        return( checked );
    }

    public virtual class SearchSection {
        public String modelName { get; set; }
        public string orderNumber { get; set; } 
        public String bodyStyle { get; set; }
        public String engine { get; set; }
        public String exteriorColour { get; set; }
        public String interiorColour { get; set; }
        public String specification { get; set; }
        public List<String> options { get; set; }
        public Decimal price { get; set; }
        public Decimal monthlyPrice { get; set; }
        public Decimal previousmonthlyPrice { get; set; }
        public Decimal previousprice { get; set; }
        public String modelYear { get; set; }
        public String modelYearFormat { get; set; }
        public Boolean checked { get; set; }
        public Decimal sortNo;
        
        //new 
        public string priceString { get; set; }
        public string monthlyPriceString { get; set; }
        public string previousmonthlyPriceString { get; set; }
        public string previouspriceString { get; set; }
        
        public string fuleTypeNew{ get; set; }
        public string powertrainNew{ get; set; }
        public string enginecapacitynew{ get; set; }
        public string transmissionnew{ get; set; }
        public string powernew{ get; set; }
       
        public void init( Asset tmp ) {
            this.modelName = StringUtil.getValue( tmp.Product2.Model_Alternative__c );
            //this.modelName = StringUtil.getValue( tmp.Model__r.Model_Alternative__c);
            this.bodyStyle = StringUtil.getValue( tmp.Product2.BodyStyle_Alternative__c );
            this.orderNumber = tmp.Order_Number__c;
            this.engine = StringUtil.getValue( tmp.Product2.Fuel_Type_Alternative__c  ) + ' (' + StringUtil.getValue( tmp.Product2.Transmission_Alternative__c ) + ') ' + StringUtil.getValue( tmp.Product2.Engine_Capacity_Alternative__c ) + ' (' + StringUtil.getValue( tmp.Product2.Wheel_Driven_Alternative__c ) + ') ' + StringUtil.getValue( tmp.Product2.Power_Output_Alternative__c );
           
            this.fuleTypeNew = StringUtil.getValue( tmp.Product2.Fuel_Type_Alternative__c  );
            this.transmissionnew= StringUtil.getValue( tmp.Product2.Transmission_Alternative__c );
            this.enginecapacitynew= StringUtil.getValue( tmp.Product2.Engine_Capacity_Alternative__c );
            this.powertrainNew= StringUtil.getValue( tmp.Product2.Power_Output_Alternative__c );
            this.powernew= StringUtil.getValue( tmp.Product2.Wheel_Driven_Alternative__c );
            
            this.exteriorColour = StringUtil.getValue( tmp.Exterior_Colour__c );
            this.interiorColour = StringUtil.getValue( tmp.Interior_Color__c );
            this.specification = StringUtil.getValue( tmp.Product2.Specification_Pack_Alternative__c );
            //this.price = tmp.Price;
            this.price = tmp.Local_price__c;
           
            if(tmp.Monthly_Price__c!= null)
            this.monthlyPrice =tmp.Monthly_Price__c;
            if(tmp.Product2.Previous_Monthly_Price_From__c != null)
            this.previousmonthlyPrice = tmp.Product2.Previous_Monthly_Price_From__c;
            this.previousprice  = tmp.Previous_Price__c;
            this.options = StringUtil.splitMultiplePickList( StringUtil.getValue( tmp.Options__c ) );
            this.modelYear = Label.ManufactureYear + StringUtil.getValue( tmp.Product2.Registration_Year_Alternative__c ).right(2);
            this.modelYearFormat =StringUtil.getValue( tmp.Product2.Registration_Year_Alternative__c );
            this.sortNo = tmp.Product2.Name_plate_display_order__c;
            this.checked = false;
            


this.priceString  =  String.valueof(tmp.Local_price__c.format());
this.monthlyPriceString = tmp.Product2.Previous_Monthly_Price_From__c != null ? String.valueof(tmp.Product2.Monthly_Price_From__c.format()) : '';
this.previousmonthlyPriceString  = tmp.Product2.Previous_Monthly_Price_From__c != null ? String.valueof(tmp.Product2.Previous_Monthly_Price_From__c.format()) : '';
this.previouspriceString = tmp.Previous_Price__c != null ? String.valueof(tmp.Previous_Price__c.format()) : '';
    
           
        }

        public virtual String getSortKey() {
            return( StringUtil.zeroPadding( this.sortNo , 3 ) );
        }

        public virtual String getSortKeyPrice() {
            return( StringUtil.zeroPadding( this.price , 10 ) );
//  
        }
        public virtual String getDistinctKey() {
            return( this.modelName );
        }

        public virtual Boolean getChecked() {
            return( checked );
        }

        public virtual String getCountDistinctKey() {
        system.debug('this.exteriorColour =>'+this.exteriorColour+'--- =>'+this.interiorColour);
         system.debug('this.specification--- =>'+this.specification);
            return( this.modelName + '_' + this.bodyStyle + '_' + this.engine + '_' + this.exteriorColour + '_' + this.interiorColour + '_' + this.specification + '_' + this.options );
        }        
        
        public virtual String getValue() {
            return( null );
        }
    }

    public class Model extends SearchSection {
        public transient String imagePath { get; set; }
        public list<string> APOImageLink{get;set;}
        public Decimal price { get; set; }
        public Decimal monthlyPrice { get; set; }
        public Decimal previousmonthlyPrice { get; set; }
        public Boolean available { get; set; }
        public Decimal previousprice  { get; set; }
        public String KMILink { get; set; }
        public string APOImagePath{get;set;}
        public Integer assetsCount { get; set; }
        public List<Asset> assets;
        public id productId;// cosa-53
        public String campaignName { get; set; }
        public String modelCampaignName { get; set; }
        public String enginename{ get; set; }
        public String assetId{ get; set; }
        public Boolean isSpecial{ get; set; }
        
        //new 
        public string priceString { get; set; }
        public string monthlyPriceString { get; set; }
        public string previousmonthlyPriceString { get; set; }
        public string previouspriceString { get; set; }
       
         
        public Model( Product2 tmp ) {
            this.modelName = StringUtil.getValue( tmp.Model_Alternative__c );
            //this.modelName = StringUtil.getValue( tmp.Model__r.Model_Alternative__c );
            this.imagePath = tmp.Vehicle_IMage_L__c;
            this.checked = false;
            this.isSpecial = false;
            this.assetsCount = tmp.assets.size();
            this.sortNo = tmp.Name_plate_display_order__c;
            if(tmp.Monthly_Price_From__c != null)
            this.monthlyPrice = tmp.Monthly_Price_From__c;
            if(tmp.Previous_Monthly_Price_From__c != null)
            this.previousmonthlyPrice = tmp.Previous_Monthly_Price_From__c;
            this.bodyStyle = StringUtil.getValue( tmp.BodyStyle_Alternative__c );
            this.engine = StringUtil.getValue( tmp.Engine_Capacity_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Fuel_Type_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Wheel_Driven_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Transmission_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Power_Output_Alternative__c );
            this.specification = StringUtil.getValue( tmp.Specification_Pack_Alternative__c ); 
            this.assets = tmp.assets;
            

            
              Decimal lowest;
            Decimal  lowestpreviousprice;  
            for( Asset vehicle : tmp.assets ) {
            this.orderNumber = vehicle.Order_Number__c;
                if( lowest == null || vehicle.Local_price__c < lowest ) {
                    lowest = vehicle.Local_price__c;
                    lowestpreviousprice  = vehicle.Previous_Price__c;

            
                }
            }

            if( lowest != null ) {
                this.price = lowest;
                this.previousprice   = lowestpreviousprice ;
            } else {
                this.price = null;
                this.previousprice = null;
            }

            if( 0 < this.assetsCount ){
                this.available = true;
            } else {
                this.available = false;
            }
            if(!this.available)
            {
                this.KMILink = tmp.KMILink__c;
            }

            
        }
        
        public Model( Product2 tmp, String deepModel ) {
            this.modelName = StringUtil.getValue( tmp.Model_Alternative__c );
            //this.modelName = StringUtil.getValue( tmp.Model__r.Model_Alternative__c);
            this.imagePath = tmp.Vehicle_IMage_L__c;
             this.isSpecial = false;
            if(deepModel == this.modelName)
            {
                this.checked = true;
            }
            else
            {
                this.checked = false;
            }
                
            //this.checked = false;
            this.assetsCount = tmp.assets.size();
            this.sortNo = tmp.Name_plate_display_order__c;
            if(tmp.Monthly_Price_From__c != null)
            this.monthlyPrice = tmp.Monthly_Price_From__c;
            if(tmp.Previous_Monthly_Price_From__c != null)
            this.previousmonthlyPrice = tmp.Previous_Monthly_Price_From__c;
            this.bodyStyle = StringUtil.getValue( tmp.BodyStyle_Alternative__c );
            this.engine = StringUtil.getValue( tmp.Engine_Capacity_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Fuel_Type_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Wheel_Driven_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Transmission_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Power_Output_Alternative__c );
            this.specification = StringUtil.getValue( tmp.Specification_Pack_Alternative__c ); 
            this.assets = tmp.assets;
            this.enginename = StringUtil.getValue( tmp.Fuel_Type_Alternative__c  ) + ' (' + StringUtil.getValue( tmp.Transmission_Alternative__c ) + ') ' + StringUtil.getValue( tmp.Engine_Capacity_Alternative__c ) + ' (' + StringUtil.getValue( tmp.Wheel_Driven_Alternative__c ) + ') ' + StringUtil.getValue( tmp.Power_Output_Alternative__c );
            

            
           Decimal lowest;
            Decimal  lowestpreviousprice; 
            for( Asset vehicle : tmp.assets ) {

                this.orderNumber = vehicle.Order_Number__c;
                this.productId = vehicle.model__c;//cosa-53
                if( lowest == null || vehicle.Local_price__c < lowest ) {
                    lowest = vehicle.Local_price__c;
                    this.priceString  =  vehicle.Local_price__c != null ? String.valueof(vehicle.Local_price__c.format()) : '';
                    lowestpreviousprice  = vehicle.Previous_Price__c;
                    
                }
            }

            if( lowest != null ) {
                this.price = lowest;
                 this.previousprice   = lowestpreviousprice ;
            } else {
                this.price = null;
                 this.previousprice = null;
            }

            if( 0 < this.assetsCount ){
                this.available = true;
            } else {
                this.available = false;
            }
            if(!this.available)
            {
                this.KMILink = tmp.KMILink__c;
            }
/*            

this.monthlyPriceString = this.monthlyPrice != null ? String.valueof(this.monthlyPrice.format()) : '';
this.previousmonthlyPriceString  = this.previousmonthlyPrice != null ? String.valueof(this.previousmonthlyPrice.format()) : '';
this.previouspriceString = this.previousprice != null ? String.valueof(this.previousprice.format()) : ''; */
            
        }
        
         public Model( Asset tmp ,String deepModel) {
            this.modelName = StringUtil.getValue( tmp.Product2.Model_Alternative__c );
            this.imagePath = tmp.Product2.Vehicle_IMage_L__c;
             this.isSpecial = false;
           system.debug('---this.modelName'+this.modelName);  
            system.debug('---deepModel '+deepModel );  
           if(deepModel == this.modelName)
            {
                this.checked = true;
            }
            else
            {
                this.checked = false;
            }
             system.debug('--- this.checked'+ this.checked);  
            this.sortNo = tmp.Product2.Name_plate_display_order__c;
            this.price = tmp.Local_price__c;
            if(tmp.Product2.Monthly_Price_From__c != null)
            this.monthlyPrice = tmp.Product2.Monthly_Price_From__c;
            this.exteriorColour = StringUtil.getValue( tmp.Exterior_Colour__c );
            this.interiorColour = StringUtil.getValue( tmp.Interior_Color__c );
            this.specification = StringUtil.getValue( tmp.Product2.Specification_Pack_Alternative__c );
            if(tmp.Product2.Previous_Monthly_Price_From__c != null)
            this.previousmonthlyPrice = tmp.Product2.Previous_Monthly_Price_From__c;
            this.bodyStyle = StringUtil.getValue( tmp.Product2.BodyStyle_Alternative__c );
           this.engine = StringUtil.getValue( tmp.Product2.Engine_Capacity_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Product2.Fuel_Type_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Product2.Wheel_Driven_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Product2.Transmission_Alternative__c ) + '_' 
                        + StringUtil.getValue( tmp.Product2.Power_Output_Alternative__c );
            this.specification = StringUtil.getValue( tmp.Product2.Specification_Pack_Alternative__c ); 
            this.enginename = StringUtil.getValue( tmp.Product2.Fuel_Type_Alternative__c  ) + ' (' + StringUtil.getValue( tmp.Product2.Transmission_Alternative__c ) + ') ' + StringUtil.getValue( tmp.Product2.Engine_Capacity_Alternative__c ) + ' (' + StringUtil.getValue( tmp.Product2.Wheel_Driven_Alternative__c ) + ') ' + StringUtil.getValue( tmp.Product2.Power_Output_Alternative__c );
            this.available = true;
            this.previousprice  = tmp.Previous_Price__c;
            this.assetid= tmp.id;
            this.orderNumber = tmp.Order_Number__c; 
            
 /*           
this.priceString  =  String.valueof(tmp.Local_price__c.format());
this.monthlyPriceString = tmp.Product2.Previous_Monthly_Price_From__c != null ? String.valueof(tmp.Product2.Monthly_Price_From__c.format()) : '';
this.previousmonthlyPriceString  = tmp.Product2.Previous_Monthly_Price_From__c != null ? String.valueof(tmp.Product2.Previous_Monthly_Price_From__c.format()) : '';
this.previouspriceString = tmp.Previous_Price__c != null ? String.valueof(tmp.Previous_Price__c.format()) : '';       
   */         
            
        }
      
        public Model( Asset tmp ) {
            this.modelName = tmp.Product2.Model_Alternative__c;
            this.APOImageLink = StringUtil.splitImageLink(tmp.pictures__c);
            this.price = tmp.Price;
            this.orderNumber = tmp.Order_Number__c;
            this.checked = false;
             this.isSpecial = false;
            if(tmp.Product2.Monthly_Price_From__c != null)
            this.monthlyPrice = tmp.Product2.Monthly_Price_From__c;
            if(tmp.Product2.Previous_Monthly_Price_From__c != null)
            this.previousmonthlyPrice = tmp.Product2.Previous_Monthly_Price_From__c;
            if(!APOImageLink.isEmpty() && APOImageLink!=null){
                APOImagePath = APOImageLink[0];
            }
            
 /*            
this.priceString  =  String.valueof(tmp.Local_price__c.format());
this.monthlyPriceString = tmp.Product2.Previous_Monthly_Price_From__c != null ? String.valueof(tmp.Product2.Monthly_Price_From__c.format()) : '';
this.previousmonthlyPriceString  = tmp.Product2.Previous_Monthly_Price_From__c != null ? String.valueof(tmp.Product2.Previous_Monthly_Price_From__c.format()) : '';
this.previouspriceString = tmp.Previous_Price__c != null ? String.valueof(tmp.Previous_Price__c.format()) : '';*/
        }

        public override String getSortKey() { 
            return( StringUtil.zeroPadding( this.sortNo , 3 ) );
        } 
            
        public override String getDistinctKey() {
            return( this.modelName );
        } 
        
    }

    public class BodyStyle extends SearchSection {
        public String bodyStyleName { get; set; }
        public String imagePath { get; set; }
        public String bodyStyleCode { get; set; }

        public BodyStyle( Asset tmp ) {
            this.init( tmp );
            this.bodyStyleName = StringUtil.getValue( tmp.Product2.BodyStyle_Alternative__c ); 
            this.bodyStyleCode = StringUtil.getValue( tmp.Body_Style_Value__c );
            this.imagePath = tmp.Body_Style_Image_M__c;
        }

        public override String getSortKey() {
            return( this.modelName + '_' + this.bodyStyleCode );
        }

        public override String getDistinctKey() {
            return( this.modelName + '_' + this.bodyStyleCode );
        }
        
    }

    public class Engine extends SearchSection { 
        public String engineName { get; set; }
        public String fuel { get; set; }
        public String drive { get; set; }
        public String engineSize { get; set; }
        public String transmission { get; set; }
        public String powerOutput { get; set; }
        //public Decimal price { get; set; }

        public String fuelCode { get; set; }
        public String transmissionCode { get; set; }
        public String powerOutputCode { get; set; }
        public String driveCode { get; set; }

        public Engine( Asset tmp ) {
            this.init( tmp );

            this.engineName = StringUtil.getValue( tmp.Product2.Engine__c );
            this.fuel = StringUtil.getValue( tmp.Product2.Fuel_Type_Alternative__c );
            this.drive = StringUtil.getValue( tmp.Product2.Wheel_Driven_Alternative__c );
            this.engineSize = StringUtil.getValue( tmp.Product2.Engine_Capacity_Alternative__c );
            this.transmission = StringUtil.getValue( tmp.Product2.Transmission_Alternative__c );
            this.powerOutput = StringUtil.getValue( tmp.Product2.Power_Output_Alternative__c );
            this.powerOutputCode = StringUtil.getValue( tmp.Power_Output_Value__c );

            this.fuelCode = StringUtil.getValue( tmp.Fuel_TypeValue__c );
            this.transmissionCode = StringUtil.getValue( tmp.TransmissionValue__c );
            this.driveCode = StringUtil.getValue( tmp.Drive_Value__c );
        }

        public override String getSortKey() {
            return( this.fuelCode + '_' + this.driveCode + '_' + this.engineSize + '_' + this.transmissionCode + '_' + this.powerOutputCode );
        }

        public override String getDistinctKey() {
            return(  this.fuelCode + '_' + this.driveCode + '_' + this.engineSize + '_' + this.transmissionCode + '_' + this.powerOutputCode );
        }
        
        public override String getValue() {
            return( this.fuel + ' (' + this.transmission + ') ' + this.engineSize + ' (' + this.drive + ') ' + this.powerOutput );
        }
    }

    public class ExteriorGroupColour extends SearchSection {
        public String colourName { get; set; }
        public String colourCode { get; set; }
        
        public ExteriorGroupColour( Asset tmp ) {
            this.init( tmp );
            this.colourName = StringUtil.getValue( tmp.Exterior_Colour_Group__c );
            this.colourCode = StringUtil.getValue( tmp.Exterior_Colour_GroupValue__c );
        }
        
        public override String getSortKey() {
            return( this.colourCode );
        }
        
        public override String getDistinctKey() {
            return( this.colourCode );
        }
    }
    
    public class ExteriorColour extends SearchSection {
        public String colourName { get; set; }
        public String imagePath { get; set; }
        public String colourCode { get; set; }
        public String colourGroupCode { get; set; }
        public String colourGroupName { get; set; }
        
        public ExteriorColour( Asset tmp ) {
            this.init( tmp );
            this.colourName = StringUtil.getValue( tmp.Exterior_Colour__c );
            this.imagePath = StringUtil.getValue( tmp.Exterior_Detail_Color_Image__c );
            this.colourCode = StringUtil.getValue( tmp.Exterior_Colour_Code__c ); //TCRM-3301
            //this.colourCode = StringUtil.getValue( tmp.Colour__c ); //TCRM-3301
            this.colourGroupCode = StringUtil.getValue( tmp.Exterior_Colour_GroupValue__c );
            this.colourGroupName = StringUtil.getValue( tmp.Exterior_Colour_Group__c );
        }

        public override String getSortKey() {
            return( this.colourGroupCode + '_' + this.colourCode );
        }

        public override String getDistinctKey() {
            return( this.colourCode );
        }
        
        public override String getValue() {
            return( '(' + this.colourGroupCode + ') ' + this.colourName );
        }
    }
    
    public class InteriorColour extends SearchSection {
        public String colourName { get; set; }
        public String colourCode { get; set; }
        public String imagePath { get; set; }
        public String exteriorColourName { get; set; }
        public String exteriorColourCode { get; set; }
        
        public InteriorColour( Asset tmp ) {
            this.init( tmp );
            this.colourName = StringUtil.getValue( tmp.Interior_Color__c );
            this.colourCode = StringUtil.getValue( tmp.Interior_colour_code__c );
            this.imagePath = StringUtil.getValue( tmp.Interior_Color_Image__c );
            this.exteriorColourName = StringUtil.getValue( tmp.Exterior_Colour__c );   
            this.exteriorColourCode = StringUtil.getValue( tmp.Exterior_Colour_Code__c ); //TCRM-3301
            //this.exteriorColourCode = StringUtil.getValue( tmp.Colour__c ); //TCRM-3301
        }

        public override String getSortKey() {
            return( this.colourName );
        }

        public override String getDistinctKey() {
            return( this.colourCode );
        }
        
        public override String getValue() {
            return( '(' + this.exteriorColourName + ')' + this.colourName );
        }
    }
    
    public class Specification extends SearchSection {
        public String specificationName { get; set; }
        public String specificationCode { get; set; }
        public String imagePath1 { get; set; }
        public String imagePath2 { get; set; }
        public String imagePath3 { get; set; }
        public String description { get; set; }
        
        public Specification( Asset tmp ) {
            this.init( tmp );
            this.specificationName = StringUtil.getValue( tmp.Product2.Specification_Pack_Alternative__c );
            this.specificationCode = StringUtil.getValue( tmp.Product2.Specification_Pack_Alternative__c );
            this.imagePath1 = tmp.Specification_Image_1__c;
            this.imagePath2 = tmp.Specification_Image_2__c;
            this.imagePath3 = tmp.Specification_Image_3__c;


            
            String key = ( this.modelName + '_' + this.specificationCode ).replaceAll( ' ' , '_' ).toUpperCase();
            key = key.replaceAll( '-' , '_' );
            this.description = CustomLabels.getInstance().getValue( key );
            if( String.isEmpty( this.description ) ) {
                key = ( this.modelName + '_' + this.specificationCode ).replaceAll( ' ' , '_' ).toUpperCase();
                this.description = CustomLabels.getInstance().getValue( key );
            }
        }

        public override String getSortKey() {
            return( this.modelName + '_' + this.specificationCode );
        }

        public override String getDistinctKey() {
            return( this.modelName + '_' + this.specificationCode );
        }
        
        public override String getValue() {
            return( this.modelName + ' ' + this.specificationName );
        }
    }
    
    public class Option extends SearchSection {
        public String optionName { get; set; }
        public String optionCode { get; set; }
        public String translatedName { get; set; }
        public String imagePath { get; set; }
        public String description {get; set; }
        
        public Option( String optionName , String optionCode , String imageRootPath , Asset tmp ) {
            this.init( tmp );
            this.optionName = StringUtil.getValue( optionCode );
            this.translatedName = StringUtil.getValue( optionName );
            this.imagePath = imageRootPath + this.optionName + '.jpg';
            
            String key = ( this.optionName ).replaceAll( ' & ' , '_' ).replaceAll( ' ' , '_' ).toUpperCase();
          
            key = key.replaceAll( '-' , '_' );

            this.description = CustomLabels.getInstance().getValue(key);


        }

        public override String getSortKey() {
            return( this.optionName );
        }

        public override String getDistinctKey() {
            return( this.optionName );
        }
    }
    
    public class Vehicle extends SearchSection {
        public Id vehicleId { get; set;}
        public Id productId;
        public String imageLPath { get; set; }
        public String imageMPath { get; set; }
        public Boolean recommendedVehicle{ get; set; }
        public Boolean FeatureVehicle{ get; set; }
        public Boolean specialVehicle{ get; set; }
        public Boolean isSpecial{ get; set; }
        public String campaign { get; set; }
        public String campaignUrlText { get; set; }
        public boolean isVehicleSaved { get; set; }
        public String billingCity { get; set; }
        public String assetVIN;
        public boolean isNew  { get; set; }
        public boolean isAPO  { get; set; }
        public Vehicle( Asset tmp ) {   
            this.init( tmp );
            this.vehicleId = tmp.Id;
            this.productId = tmp.Model__c;
            this.imageLPath = tmp.APO_Display__c  && StringUtil.splitImageLink(tmp.pictures__c).size() > 0 ? StringUtil.splitImageLink(tmp.pictures__c)[0] : tmp.Vehicle_Image_L__c;
            this.imageMPath = tmp.Vehicle_Image_M__c;
            
            this.billingCity = ApexPages.currentPage()  != null && ApexPages.currentPage().getParameters().get('market') == 'jp'  && tmp.Account.City_Name_Local__c != null ? tmp.Account.City_Name_Local__c : tmp.account.billingcity != null ? tmp.Account.billingcity : ''; 
            this.billingCity = ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().get('market') == 'br' && tmp.account.billingcity != null ? tmp.Account.name.replaceAll('[0-9]', '').replaceAll('-', '')  + ' -  '+ tmp.Account.billingcity : this.billingCity;
            this.assetVIN = tmp.VIN__C;
            this.isNew   = tmp.New_Display__c;
            this.isAPO = tmp.APO_Display__c;
            //if(tmp.account.billingcity != null)
            //this.billingCity = tmp.account.billingcity;
            
            
        }


        public override String getSortKeyPrice() {
            return( StringUtil.zeroPadding( this.price , 10 ) );
//            return( this.model + '_' + this.bodyStyle + '_' + this.exteriorColour + '_' + this.interiorColour + '_' + this.specification + '_' + this.options );
        }
        
        public override String getSortKey() {
            return( StringUtil.zeroPadding( this.sortNo , 3 ) + '_' + StringUtil.zeroPadding( this.price , 10 ) );
//            return( this.model + '_' + this.bodyStyle + '_' + this.exteriorColour + '_' + this.interiorColour + '_' + this.specification + '_' + this.options );
        }

        public override String getDistinctKey() {
            return( this.getCountDistinctKey() );
        }
        
        public override Boolean getChecked() {
            return( this.checked );
        }
/*
        public override String getCountDistinctKey() {
            return( this.modelName + '_' + this.bodyStyle + '_' + this.engine + '_' + this.exteriorColour + '_' + this.interiorColour + '_' + this.specification + '_' + this.options );
        }
*/
    }

    public class EngineSelector {
        public List<SelectOption> fuels { get; set; }
        public List<SelectOption> drives { get; set; }
        public List<SelectOption> engineSizes { get; set; }
        public List<SelectOption> transmissions { get; set; }

        public String selectedFuel { get; set; }
        public String selectedDrive { get; set; }
        public String selectedEngineSize { get; set; }
        public String selectedTransmission { get; set; }

        public EngineSelector() {
            this.fuels = new List<SelectOption>();
            this.drives = new List<SelectOption>();
            this.engineSizes = new List<SelectOption>();
            this.transmissions = new List<SelectOption>();

            this.fuels.add( new SelectOption( '' , System.label.Fuel_Type ) );
            this.drives.add( new SelectOption( '' , System.label.Drive ) );
            this.engineSizes.add( new SelectOption( '' , System.label.Engine_Size ) );
            this.transmissions.add( new SelectOption( '' , System.label.Transmission ) );

            this.selectedFuel = '';
            this.selectedDrive = '';
            this.selectedEngineSize = '';
            this.selectedTransmission = '';
        }


    }

    public class PaymentSelector {
        public String selectedType { get; set; }
        public String selectedBudget { get; set; }
        public String selectedDeposit { get; set; }
        public String selectedBonus { get; set; }
        public string selectedMinbudget {get; set;}//COSA 127
        // Add new property
        public String selectedTradeinValue { get; set; }
        
        public List<SelectOption> types { get; set; }
        
        private Set<Integer> durations = new Set<Integer>{ 6 , 10 , 12 , 18 , 20 , 24 , 30 , 36 , 42 , 48 , 54 , 60 , 66 , 72 , 78 , 84 };
        
        public PaymentSelector() {
            this.types = new List<SelectOption>();            
            this.types.add( new SelectOption( '' , '' ) );
            for( Integer tmp : this.durations ) {
                this.types.add( new SelectOption( String.valueOf( tmp ) , String.valueOf( tmp ) ) );
            }
            
            /*            
            this.types.add( new SelectOption( 'Monthly' , System.label.PAYMENT_TYPE_MONTHLY ) );
            this.types.add( new SelectOption( 'Weekly' , System.label.PAYMENT_TYPE_WEEKLY ) );
            this.types.add( new SelectOption( 'Yearly' , System.label.PAYMENT_TYPE_YEARLY ) );
            */
        }
    }
}
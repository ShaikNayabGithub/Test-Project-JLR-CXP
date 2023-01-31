public class VehicleSearchInputParameters {

    public static final String PARAM_MODELS = 'models';
    public static final String PARAM_STYLES = 'bodyStyles';
    public static final String PARAM_ENGINES = 'engines';
    public static final String PARAM_EXTERIOR_GROUP_COLOURS = 'groupColors';
    public static final String PARAM_EXTERIOR_DETAIL_COLOURS = 'exteriorColors';
    public static final String PARAM_INTERIOR_COLOURS = 'interiorColors';
    public static final String PARAM_SPECS = 'SpecStr';
    public static final String PARAM_OPTIONS = 'optionsStr';

    public List<String> models; 
    public List<String> styles;
    public List<String> engines;
    public List<String> exteriorGroupColours;
    public List<String> exteriorDetailColours;
    public List<String> interiorColours;
    public List<String> specifications;
    public List<String> options;
    public List<String> fuelTypes;
    public List<String> powertrains;
    public List<String> transmissions;
   
    public String selectedFuel;
    public String selectedDrive;
    public String selectedEngineSize;
    public String selectedTransmission;
    
    public String selectedPaymentType;
    public String inputMonthlyBudget;
    public String inputDeposit;
    public String inputBonusAmount;
    // Add new property
    public String inputTradeinValue;
    public Decimal minBudget { get; set; }
    public Decimal budget;
    
 
    public VehicleSearchInputParameters() {
        this.models = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_MODELS ) );
        this.styles = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_STYLES ) );
        this.fuelTypes= this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_STYLES ) );
        this.engines = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_ENGINES ) );
        this.exteriorGroupColours = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_EXTERIOR_GROUP_COLOURS ) );
        this.exteriorDetailColours = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_EXTERIOR_DETAIL_COLOURS ) );
        this.interiorColours = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_INTERIOR_COLOURS ) );
        this.specifications = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_SPECS ) );
        this.options = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_OPTIONS ) );
        this.powertrains = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_OPTIONS ) );
        this.transmissions = this.splitOptions( ApexPages.CurrentPage().getParameters().get( PARAM_SPECS ) );
        
        System.debug( '-------------- parameters = ' + ApexPages.CurrentPage().getParameters() );
        System.debug( '-------------- exteriorGroupCOlours = ' + this.exteriorGroupColours );
        System.debug( '-------------- exteriorDetailColours = ' + this.exteriorDetailColours );
        System.debug( '-------------- interiorColours = ' + this.interiorColours );
        System.debug( '-------------- specifications = ' + this.specifications );
        System.debug( '-------------- options = ' + this.options );
        
        
    }
    
    public String deepModel { get; set; } 
    public String deepColor { get; set; } 
    public VehicleSearchInputParameters(String deepModel) {
        this.deepModel = deepModel;
        
        if(ApexPages.CurrentPage().getParameters().containskey('colour') && ApexPages.CurrentPage().getParameters().get('colour') != '')
        this.deepColor =  ( ApexPages.CurrentPage().getParameters().get('colour') );
        system.debug('-----parameters.deepColor '+this.deepColor  );
    } 

    public VehicleSearchInputParameters( VehicleSearchBean bean ) {
        this.models = bean.getCheckedModels();
        this.styles = bean.getCheckedBodyStyles();
        this.engines = bean.getCheckedEngines();
        this.exteriorGroupColours = bean.getCheckedExteriorGroupColours();
        this.exteriorDetailColours = bean.getCheckedExteriorColours();
        this.interiorColours = bean.getCheckedInteriorColours();
        this.specifications = bean.getCheckedSpecifications();
        this.options = bean.getCheckedOptions();        
        this.budget = bean.budget;
        this.minBudget = bean.minBudget;
        System.debug( '-------------- this.styles = ' +  this.styles );
        System.debug( '-------------- exteriorDetailColours = ' + this.exteriorDetailColours );
        System.debug( '-------------- interiorColours = ' + this.interiorColours );
        System.debug( '-------------- specifications = ' + this.specifications );
        System.debug( '-------------- options = ' + this.options );
        
    }    
    
    public Integer getPaymentTypeValue() {
/*        if( 'Monthly'.equals( this.selectedPaymentType ) ) {
            return( 12 );
        } else if( 'Weekly'.equals( this.selectedPaymentType ) ) {
            return( 50 );
        } else if( 'Yearly'.equals( this.selectedPaymentType ) ) {
            return( 1 );
        }
*/
        return( IntegerUtil.valueOf( this.selectedPaymentType ) );
    }
    
    public Integer getMonthlyBudget() {
        return( IntegerUtil.valueOf( this.inputMonthlyBudget ) );
    }
    
    public Integer getDeposit() {
        return( IntegerUtil.valueOf( this.inputDeposit ) );
    }
    
    public Integer getBonusAmount() {
        return( IntegerUtil.valueOf( this.inputBonusAmount ) );
    }
    
    // Add new property
    public Integer getTradeinValue() {
        return ( IntegerUtil.valueOf( this.inputTradeinValue ) );
    }
    
    private List<String> splitOptions( String tmp ) {
        List<String> returns;
        if( ! String.isEmpty( tmp ) ) {
            returns = tmp.removeEnd(':').split(':');
        } else {
            returns = new List<String>();            
        }
        
        return( returns );
    }
}
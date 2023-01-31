public with sharing class VehicleSearchBeanSelectedOnly {
    public List<VehicleSearchBean.Model> models { get; set; }
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
    
    public VehicleSearchBeanSelectedOnly(VehicleSearchBean bean){
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
    	
    	this.selectedLanguage = bean.selectedLanguage;
    	this.selectedModelStr = bean.selectedModelStr;
    	this.selectedBodyStyleStr = bean.selectedBodyStyleStr;
    	this.selectedEngineStr = bean.selectedEngineStr;
    	this.selectedColourStr = bean.selectedColourStr;
    	this.selectedPriceStr = bean.selectedPriceStr;
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
    }
}
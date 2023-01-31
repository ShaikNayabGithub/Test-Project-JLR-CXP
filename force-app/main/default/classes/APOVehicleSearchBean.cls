public with sharing class APOVehicleSearchBean 
{
    

    // Floating bar - TBD
   
    // General Setting
    public String selectedLanguage { get; set; }
    public String selectedBrand { get; set; }
    public String selectedMarket { get; set; }

    // Selected Advanced search
    public List<String> selectedModels { get; set; }
    public Set<String> selectedModels2 { get; set; }
    public Set<String> selectedBodyStyles { get; set; }
    public Set<String> selectedSpecifications { get; set; }
    public Set<String> selectedExteriorGroupColours { get; set; }
    public Set<String> selectedInteriorColours { get; set; }
    public Set<String> selectedTransmission { get; set; }
    public Set<String> selectedEngines { get; set; }
    public Set<String> selectedFuel { get; set; }
    public Set<String> selectedEquipment { get; set; }
    public String selectedMinModelYear { get; set; }
    public String selectedMaxModelYear { get; set; }
    public String selectedMinEngine { get; set; }
    public String selectedMaxEngine { get; set; }
    public String selectedMinPrice { get; set; }
    public String selectedMaxPrice { get; set; }
    public String selectedMinMileage { get; set; }
    public String selectedMaxMileage { get; set; }
    public String selectedMinAge { get; set; }
    public String selectedMaxAge { get; set; }
    public String selectedLocation { get; set; }
    public String selectedSortBy { get; set; }
    public String selectedLocationDistance { get; set; }
    public List<String> AddressForLocation { get; set; }
    public boolean SearchLocationFlag{ get; set; }
    public APOVehicleSearchBean() {
        
    }
    
    /*public void setDeserializedBean(APOVehicleSearchBeanSelectedOnly bean) 
    {
        this.selectedModels2 = bean.selectedModels2;
        this.selectedBodyStyles = bean.selectedBodyStyles;
        this.selectedSpecifications = bean.selectedSpecifications;
        this.selectedTransmission = bean.selectedTransmission;
        //this.selectedEngines = bean.selectedEngines;
        this.selectedFuel = bean.selectedFuel;
        this.selectedExteriorGroupColours = bean.selectedExteriorGroupColours;
        this.selectedInteriorColours = bean.selectedInteriorColours;
        this.selectedMinModelYear = bean.selectedMinModelYear;
        this.selectedMaxModelYear = bean.selectedMaxModelYear;
        this.selectedMinMileage = bean.selectedMinMileage;
        this.selectedMaxMileage = bean.selectedMaxMileage;
        this.selectedMinAge = bean.selectedMinAge;
        this.selectedMaxAge = bean.selectedMaxAge;
        this.selectedMinEngine = bean.selectedMinEngine;
        this.selectedMaxEngine = bean.selectedMaxEngine;
        this.selectedMinPrice = bean.selectedMinPrice;
        this.selectedMaxPrice = bean.selectedMaxPrice;
        this.selectedLocation = bean.selectedLocation;
        //this.vehicleCount = bean.vehicleCount;
        //this.vehicles = bean.vehicles;
        this.selectedEquipment = bean.selectedEquipment;
        this.selectedSortBy = bean.selectedSortBy;
        
    }*/
}
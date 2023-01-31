public with sharing class APOVehicleSearchBeanSelectedOnly {

    //public List<VehicleWrapper> vehicles { get; set; }
    //public Integer vehicleCount { get; set; }
    
    public String selectedLanguage { get; set; }
    public String selectedBrand { get; set; }
    public String selectedMarket { get; set; }

    // Floating bar
    //public String modelStr { get; set; }
    //public String priceStr { get; set; }
    //public String mileageStr { get; set; }
    //public String ageStr { get; set; }
    //public String location { get; set; }
    //public Set<String> models { get; set; }

    // Selected Floating bar

    // Advanced Search
    //public String bodyStyleStr { get; set; }
    //public String specificationStr {get; set;}
    //public String modelYearStr { get; set; }
    //public String exteriorColoursStr { get; set; }
    //public String interiorColoursStr { get; set; }
    //public String engineStr { get; set; }
    //public String transmissionStr { get; set; }
    //public String fuelStr { get; set; }
    //public String equipmentsStr { get; set; }

    // Selected Advanced search
    //public List<String> selectedModels { get; set; }
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
    public string selectedLocationDistance {get;set;}
    public List<String> AddressForLocation { get; set; }
    public boolean SearchLocationFlag{ get; set; }
    public String selectedSortBy { get; set; }
    
    public APOVehicleSearchBeanSelectedOnly(APOVehicleSearchBean bean)
    {
        this.selectedModels2 = bean.selectedModels2;
        this.selectedBodyStyles = bean.selectedBodyStyles;
        this.selectedSpecifications = bean.selectedSpecifications;
        this.selectedTransmission = bean.selectedTransmission;
        //this.selectedEngines = bean.selectedEngines;
        this.selectedFuel = bean.selectedFuel;
        this.selectedExteriorGroupColours = bean.selectedExteriorGroupColours;
        this.selectedInteriorColours = bean.selectedInteriorColours;
        //this.selectedEquipment =　bean.selectedEquipment;
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
        this.selectedLocation =bean.selectedLocation;
        this.selectedLocationDistance =bean.selectedLocationDistance ;
        this.AddressForLocation =bean.AddressForLocation ;
        this.SearchLocationFlag=bean.SearchLocationFlag;
    }
}
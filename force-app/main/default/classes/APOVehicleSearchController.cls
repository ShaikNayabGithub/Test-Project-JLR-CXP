/**************************************************************************************************************    
Class Name    : APOVehicleSearchController
Description   : This Class contains the Logic to:
                    search an APO Vehicle for Singapore/Japan Market
                          
CreatedDate   : 6th February 2018       
Version       : 1.0     
*********************************************************************************************************************/
public without sharing class APOVehicleSearchController {
   
    public APOVehicleSearchBean bean { get; set; }
    public String LocationStr{ get; set; }
    public CreateSavedVehicleDto dto { get; set; }
    public List<String> args;
    public decimal decvalue{get;set;}
    public string checkboxval{get;set;}
    public integer yearvalue{get;set;}
    public String selectedVal{get;set;}
    public String selectedfromAgeVal{get;set;}
    public String selectedtoAgeVal{get;set;}
    public string minprice{get;set;}
    public string maxprice{get;set;}
    public string minmileage{get;set;}
    public string maxmileage{get;set;}
    public string selectedmileage{get;set;}
    public string clear{get;set;}
    public string clearfilters{get;set;}
    public string selectedfromModelYear{get;set;}
    public string selectedtoModelYear{get;set;}
    public string selectedfromEngine{get;set;}
    public string selectedtoEngine{get;set;}
    public string sortbyvalue{get;set;}
    public string sortbyvaluemobile{get;set;}
    public string mobilesort{get;set;}
    public string paramValue{get;set;}
    public boolean showpanel{get;set;}
    public boolean agepanel{get;set;}
    public boolean pricepanel{get;set;}
    public boolean mileagepanel{get;set;}
    public boolean showContent{get;set;}
    public boolean jaguarhero{get;set;}
    public string InLoadDetails{get;set;}
    public string selectdbrand;
    public boolean selectdmarket{get;set;}
    public boolean selectfinal{get;set;}
    
    public list<Vehiclewrapper> Vehiclelist{get;set;}

    public list<selectoption> sortOptions{get;set;}
    public list<selectoption> sortMobileOptions{get;set;}

    public list<selectoption>fromAgeOptions{get;set;}
    public list<selectoption>ToageOptions{get;set;}
    public list<selectoption>fromModelyearOptions{get;set;}
    public list<selectoption>toModelyearOptions{get;set;}

    public list<selectoption>fromPriceOptions{get;set;}
    public list<selectoption>ToPriceOptions{get;set;}
    public list<selectoption>FromEngineOptions{get;set;}
    public list<selectoption>ToEngineOptions{get;set;}
    public list<selectoption>minMileageOptions{get;set;}
    public list<selectoption>maxMileageOptions{get;set;}
 
    public String ApoDxLink { get; set; }

    public Set<String> Models { get; set; }
    public Set<String> BodyStyles { get; set; }
    public Set<String> Specifications { get; set; }
    public Set<String> ExteriorColors { get; set; }
    public Set<String> InteriorColors { get; set; }
    public Set<String> Transmissions { get; set; }
    public Set<String> FuelTypes { get; set; }
    public Set<String> Equipments { get; set; }

    public set<string> SelectedNameSet { get; set; }
    public set<string> advancedbodystyleSet { get; set; }
    public set<string> specificationSet { get; set; }
    public set<string> exteriorColourSet { get; set; }
    public set<string> interiorColourSet { get; set; }
    public set<string> transmissionSet { get; set; }
    public set<string> fuelTypeSet { get; set; }
    public Set<String> equipmentSet { get; set; }
    public map<decimal,string> sortModelsMap;

    public String Market { get; set; }
    public String Lang { get; set; }
    public String Brand { get; set; }
    public string RetailerName { get; set; }
    public integer count{get;set;}
    public String symbol { get; set; }
    //Bing Map
    public  static List<String> myAddress1{get;Set;}
    public  List<String> AddressForAccount{get;Set;}
    public static String gesize{get;Set;}
    public boolean SearchLocation;
    public String SearchLocationStr{get;set;}
    public String SearchLocationDistanceStr{get;set;}
    public list<selectoption> ListSearchDistance{get;set;}
    //compare
    public String CompareStr{ get; set; }
    public boolean IsCompareExist{ get; set; }
    public Set<String> CompareToshow{get;Set;}
    public String CompareStrtoShow{get;Set;}
    public Integer CompareCount{get;Set;}
   
    public APOVehicleSearchController () {
        //bing map start
        SearchLocation=false;
        myAddress1= new List<String>();
        AddressForAccount=new List<String>();
        String recTypeId = [select Id, Name from RecordType where sObjecttype = 'Account' and Name = 'Retailer' limit 1].Id;
        for( Account a:  [select Id, NameLocal, Address_Local__c from Account where RecordTypeId = :recTypeId AND Region_or_Market__c in ('JAPAN', 'JP') AND Address_Local__c!='' AND Id IN (SELECT Accountid FROM Asset) Limit 100] ){
            myAddress1.add(a.Address_Local__c);
        }
        gesize= JSON.serialize(myAddress1);
        //bingmap ends
        TempModels = new Set<String>();
        ListSearchDistance= new list<selectoption>();
        ListSearchDistance.add(new SelectOption('10 KM','10 KM'));
        ListSearchDistance.add(new SelectOption('50 KM','50 KM'));
        ListSearchDistance.add(new SelectOption('100 KM','100 KM'));
        ListSearchDistance.add(new SelectOption('300 KM','300 KM'));
        showContent = true;
        clearfilters = 'false';
        ClearModel = false;
        mobilesort = 'false';
        args = new String[]{'0','number','###,###,##0.00'};
        ShowPrev = false;
        //compare parameters
        CompareToshow= new Set<String>();
        IsCompareExist=false;
        if(ApexPages.currentPage().getParameters().get('id1')!='' && ApexPages.currentPage().getParameters().get('id1')!=null){
            CompareToshow.add(ApexPages.currentPage().getParameters().get('id1'));
        }
        if(ApexPages.currentPage().getParameters().get('id2')!='' && ApexPages.currentPage().getParameters().get('id2')!=null){
            CompareToshow.add(ApexPages.currentPage().getParameters().get('id2'));
        }
        if(ApexPages.currentPage().getParameters().get('id3')!='' && ApexPages.currentPage().getParameters().get('id3')!=null){
            CompareToshow.add(ApexPages.currentPage().getParameters().get('id3'));
        }
        CompareCount=CompareToshow.size();
        if(CompareToshow.size()>0){
            IsCompareExist=true;
            CompareStrtoShow= JSON.serialize(CompareToshow);
        }
        decvalue = 0.0;
        yearvalue = 1900;
        
        symbol = JUDAANUtil.getCurrencySymbol();
        Market = JUDAANUtil.getSimpleMarket();
        Lang = ApexPages.currentPage().getParameters().get('lang');
        Brand = ApexPages.currentPage().getParameters().get('brand');
        if(Brand!=null){
            if(Brand.startsWithIgnoreCase('land')){
                Brand = 'landrover';
                selectdbrand = 'Land%';
            }
            if(Brand.startsWithIgnoreCase('jag')){
                Brand = 'jaguar';
                selectdbrand = 'Jag%';
            }
        }
        ApoDxLink = JUDAANUtil.getApoDxLink();
        this.bean = new APOVehicleSearchBean();
        this.dto = new CreateSavedVehicleDto();
        this.dto.createSavedVehicle = new CreateSavedVehicleImplByAPOVehicleSearch();
        this.dto.url = '/APOVehicleSearch';
        this.dto.urlParameterMap = new Map<String, String>();
        this.dto.urlParameterMap.put('brand', Brand);
        this.dto.urlParameterMap.put('lang', Lang);
        this.dto.urlParameterMap.put('market', Market);
        
        if(Market != null) {
            if(Market == 'sg')
                RetailerName = 'Singapore';
            else
                RetailerName = 'HongKong';
            
            if(Market.startsWithIgnoreCase('jp')) { 
                selectdmarket = true;
            }
            if(Market.startsWithIgnoreCase('sg') || Market.startsWithIgnoreCase('hk')) { // enabling hk market                
                selectdmarket = false;
            }
        }
        SelectedNameSet =  new set<string>();
        advancedbodystyleSet = new set<string>();
        specificationSet = new set<string>();
        exteriorColourSet = new set<string>();
        interiorColourSet = new set<string>();
        transmissionSet = new set<string>();
        fuelTypeSet = new set<string>();
        equipmentSet = new Set<String>();
        fromAgeOptions = new list<selectOption>();
        ToageOptions = new list<selectOption>();
        checkSaved();
        loadDetails();
        loadModels();
        InitialModels = Models;
        loadAge();
        loadPrice();
        loadMileage();
        loadAdvansed();
        setDefaultSelectedValues();
    }

    public PageReference init() {
        // Redirect to VehicleSearch Page when market is JAPAN and Page is APOVehicleSearch
        if(market != null && market.equalsIgnoreCase('jp')) {
            String pageUrl = ApexPages.currentPage().getUrl();
            if(pageUrl != null) {
                if(pageUrl.containsIgnoreCase('apovehiclesearch')) {
                    PageReference pref = Page.VehicleSearch;
                    pref.getParameters().put('brand', brand);
                    pref.getParameters().put('market', market);
                    pref.getParameters().put('lang', lang);
                    pref.setRedirect(true);
                    return pref;
                }
            }
        }
        
        Brand = ApexPages.currentPage().getParameters().get('brand');
        if(Brand!=null){
            if(Brand.startsWithIgnoreCase('land')){
                Brand = 'landrover';
                selectdbrand = 'Land%';
            }
            if(Brand.startsWithIgnoreCase('jag')){
                Brand = 'jaguar';
                selectdbrand = 'Jag%';
            }
        }
        
        sortOptions = new list<selectOption>();
        sortOptions.add(new SelectOption(System.Label.PRICE_HIGH_TO_LOW,System.Label.PRICE_HIGH_TO_LOW));
        sortOptions.add(new SelectOption(System.Label.PRICE_LOW_TO_HIGH,System.Label.PRICE_LOW_TO_HIGH));
        sortOptions.add(new SelectOption(System.Label.AGE_HIGH_TO_LOW,System.Label.AGE_HIGH_TO_LOW));
        sortOptions.add(new SelectOption(System.Label.AGE_LOW_TO_HIGH,System.Label.AGE_LOW_TO_HIGH));
        sortOptions.add(new SelectOption(System.Label.MILEAGE_HIGH_TO_LOW,System.Label.MILEAGE_HIGH_TO_LOW));
        sortOptions.add(new SelectOption(System.Label.MILEAGE_LOW_TO_HIGH,System.Label.MILEAGE_LOW_TO_HIGH));
        
        sortMobileOptions = new list<selectOption>();
        sortMobileOptions.add(new SelectOption('--None--',System.Label.SORT_BY));
        sortMobileOptions.add(new SelectOption(System.Label.PRICE_HIGH_TO_LOW,System.Label.PRICE_HIGH_TO_LOW));
        sortMobileOptions.add(new SelectOption(System.Label.PRICE_LOW_TO_HIGH,System.Label.PRICE_LOW_TO_HIGH));
        sortMobileOptions.add(new SelectOption(System.Label.AGE_HIGH_TO_LOW,System.Label.AGE_HIGH_TO_LOW));
        sortMobileOptions.add(new SelectOption(System.Label.AGE_LOW_TO_HIGH,System.Label.AGE_LOW_TO_HIGH));
        sortMobileOptions.add(new SelectOption(System.Label.MILEAGE_HIGH_TO_LOW,System.Label.MILEAGE_HIGH_TO_LOW));
        
        if(sortbyvalue == null){
            sortbyvalue = System.Label.PRICE_LOW_TO_HIGH;
        }
        if(sortbyvaluemobile == null){
            sortbyvaluemobile = '--None--';
        }
        Market = JUDAANUtil.getSimpleMarket();
        LoadDetails();
        loadAdvansed();
        if(!ApexPages.currentPage().getParameters().containsKey('brand') || !ApexPages.currentPage().getParameters().containsKey('market')) {
            String brand;
            String url = Site.getBaseRequestUrl();
            if(url.containsIgnoreCase('jaguar')){
                brand = 'jaguar'; 
            } else {
                brand = 'landrover';
            }
            PageReference p = Page.APOVehicleSearch;
            p.getParameters().put('brand', brand);
            p.getParameters().put('market', Market);
            p.getParameters().put('lang', JUDAANUtil.getDefaultLanguage());
            p.setRedirect(true);
            return p;
        }
        else {
            return null;
        }
    }

    public void setSelectedValues() {
        // Set Selected Values
        bean.selectedBodyStyles = advancedbodystyleSet;
        bean.selectedSpecifications = specificationSet;
        bean.selectedTransmission = transmissionSet;
        bean.selectedFuel = fuelTypeSet;
        bean.selectedExteriorGroupColours = exteriorColourSet;
        bean.selectedInteriorColours = interiorColourSet;
        bean.selectedMinModelYear = selectedfromModelYear;
        bean.selectedMaxModelYear = selectedtoModelYear;
        bean.selectedMinEngine = selectedfromEngine;
        bean.selectedMaxEngine = selectedtoEngine;
        bean.selectedEquipment = equipmentSet;
        bean.selectedModels2 = SelectedNameSet;
        bean.selectedMinMileage = minmileage;
        bean.selectedMaxMileage = maxmileage;
        bean.selectedMinPrice = minprice;
        bean.selectedMaxPrice = maxprice;
        bean.selectedMinAge = selectedfromAgeVal;
        bean.selectedMaxAge = selectedtoAgeVal;
        bean.selectedSortBy = sortbyvalue;
        bean.selectedLocation = SearchLocationStr;
        bean.selectedLocationDistance = SearchLocationDistanceStr;
        bean.AddressForLocation = AddressForAccount;
        bean.SearchLocationFlag = SearchLocation;
    }

    public Boolean hasModel { get; set; }
    public Boolean hasPrice { get; set; }
    public Boolean hasMileage { get; set; }
    public Boolean hasAge { get; set; }
    public Boolean hasLocation { get; set; }
    
    public void setDefaultSelectedValues() {
        String svid = ApexPages.currentPage().getParameters().get('id');
        SelectedModels = new Set<String>();
    }

    public List<String> SelectedModels2 { get; set; }
    public String Models2 { get; set; }
    public Set<String> SelectedModels { get; set; }
    public String dynamicLoad { get; set; }
    public Set<String> TempModels { get; set; }
    
    public void LoadDetails() {
        Set<Id> SetCompareCheck = new Set<Id>();
        List<String> IdsForCompareCheck= new List<String>();
        mobilesort = Apexpages.currentPage().getParameters().get('mobilesort');
        try{
            if(mobilesort == null){
                mobilesort = 'false';
            }
            String NodeStr = CompareStr;

            If(NodeStr != null && NodeStr != ''){
                IdsForCompareCheck= ( List<String> )JSON.deserialize(NodeStr, List<string>.class ) ;
                for(String cmpid :IdsForCompareCheck){
                    SetCompareCheck.add(Id.valueof(cmpid));
                }
                
            }
            if(clearfilters == 'true') {   
                minprice = '';
                maxprice = '';
                minmileage= '';
                maxmileage= '';
                selectedfromAgeVal= '';
                selectedtoAgeVal= '';
                selectedfromModelYear ='';
                selectedtoModelYear = '';
                selectedfromEngine = '';
                selectedtoEngine ='';
                SelectedNameSet.clear();
                advancedbodystyleSet.clear();
                specificationSet.clear();
                exteriorColourSet.clear();
                interiorColourSet.clear();
                transmissionSet.clear();
                fuelTypeSet.clear();
                equipmentSet.clear();
                
            }
            isLoaded = false;
            
            string soql = 'Select id, name,Local_price__c,Exterior_Colour_Group__c,Vehicle_Initial_Registration_Date__c,APO__c,ToLabel(exterior_Colour__c),FromLocalPrice__c,'
                +'FromMileage__c,ToLocalPrice__c,ToMileage__c,ToLabel(Product2.Model_Year_Alternative__c),ToLabel(Product2.Engine_Capacity_Alternative__c),'
                +'ToLabel(Product2.Specification_Pack_Alternative__c), ToLabel(Interior_Color__c),ToLabel(Product2.Fuel_Type_Alternative__c), Product2.Make__r.Name,ToLabel(product2.Transmission_Alternative__c),'
                +'mileage__c,ToLabel(product2.APO_Body_Style_Alternative__c),Pictures__c,Approved_On_Udaan__c,ToLabel(Product2.Model_Alternative__c),'
                +'Product2.Registration_Year_Alternative__c, Product2.Name_plate_display_order__c, Product2.Name_Plate_Display_Order_SG__c, Age__c, highlighted_base__c,highlighted_local__c from Asset where Product2.Model_Alternative__c!=null and Approved_On_Udaan__c = true and APO_Display__c = true and APO__c = true and  Product2.Make__r.Name like :selectdbrand  and Account.Country_ISO_Code__c =:Market ';
 
            if(clearfilters == '')  
                clearfilters = 'false';  
            
            if(SelectedNameSet!= null &!SelectedNameSet.isEmpty() && clearfilters == 'false' ){ 
                soql+=' and Product2.Model_Alternative__c in :SelectedNameSet';
                hasModel = true;
            }
            if(minprice!=null && minprice!='' && minprice!='0.0'  && clearfilters == 'false' ){
                decimal decminprice = decimal.valueof(minprice);
                soql+=' and FromLocalPrice__c >=:decminprice';
                hasPrice = true;
            }
            if(maxprice!=null && maxprice!='' && maxprice!='0.0' && clearfilters == 'false' ){
                decimal decmaxprice = decimal.valueof(maxprice);
                soql+=' and ToLocalPrice__c <=:decmaxprice';
                hasPrice = true;
            }
            if(minmileage!=null && minmileage!='' && minmileage!='0.0' && clearfilters == 'false' ){
                decimal decminmileage = decimal.valueof(minmileage); 
                soql+=' and FromMileage__c >=:decminmileage';
                hasMileage = true;
            }
            if(maxmileage!=null && maxmileage!='' &&  maxmileage!='0.0' && clearfilters == 'false' ){
                decimal decmaxmileage = decimal.valueof(maxmileage);
                soql+=' and ToMileage__c <=:decmaxmileage';
                hasMileage = true;
            }
            if(selectedfromAgeVal!=null && selectedfromAgeVal!='' && selectedfromAgeVal!='1900' && clearfilters == 'false' ){
                integer fromageval = integer.valueof(selectedfromAgeVal);
                soql+=' and CALENDAR_YEAR(Vehicle_Initial_Registration_Date__c) >=:fromageval';
                hasAge = true;
            }
            if(selectedtoAgeVal!=null && selectedtoAgeVal!='' && selectedtoAgeVal!='1900' && clearfilters == 'false' ){
                integer toageval = integer.valueof(selectedtoAgeVal);
                soql+=' and CALENDAR_YEAR(Vehicle_Initial_Registration_Date__c)<=:toageval';
                hasAge = true;
            }
            if(AddressForAccount!= null  && clearfilters == 'false' && SearchLocation==true){ 
                soql+=' and account.Address_local__c in :AddressForAccount';
                hasLocation =true;
            }
            if(advancedbodystyleSet!= null &!advancedbodystyleSet.isEmpty() && clearfilters == 'false' ){ 
                
                soql+=' and ToLabel(Product2.APO_Body_Style_Alternative__c) in :advancedbodystyleSet';
            }
            if(specificationSet!= null &!specificationSet.isEmpty() && clearfilters == 'false' ){ 
                soql+=' and ToLabel(Product2.Specification_Pack_Alternative__c) in :specificationSet';
            }
            if(exteriorColourSet!= null &!exteriorColourSet.isEmpty() && clearfilters == 'false' ){ 
                soql+=' and ToLabel(exterior_Colour__c) in :exteriorColourSet';
            }
            if(interiorColourSet!= null &!interiorColourSet.isEmpty() && clearfilters == 'false' ){ 
                soql+=' and ToLabel(Interior_Color__c) in :interiorColourSet';
            }
            if(transmissionSet!= null &!transmissionSet.isEmpty() && clearfilters == 'false' ){ 
                soql+=' and ToLabel(Product2.Transmission_Alternative__c) in :transmissionSet';
            }
            if(fuelTypeSet!= null &!fuelTypeSet.isEmpty() && clearfilters == 'false' ){ 
                soql+=' and ToLabel(Product2.Fuel_Type_Alternative__c) in :fuelTypeSet';
            }
            if(selectedfromModelYear!=null && selectedfromModelYear!='' && selectedfromModelYear!='--None--' && (clearfilters == 'false' || clearfilters == '') ){
                soql+=' and Product2.Model_Year_Alternative__c >=:selectedfromModelYear';
            }
            if(selectedtoModelYear!=null && selectedtoModelYear!='' && selectedtoModelYear!='--None--'  && (clearfilters == 'false' || clearfilters == '')  ){
                
                soql+=' and Product2.Model_Year_Alternative__c <=:selectedtoModelYear';
            }
            if(selectedfromEngine!=null && selectedfromEngine!='' && selectedfromEngine!='--None--'  && clearfilters == 'false' ){
                soql+=' and Product2.Engine_Capacity_Alternative__c >=:selectedfromEngine';
            }
            if(selectedtoEngine!=null && selectedtoEngine!='' && selectedtoEngine!='--None--' && clearfilters == 'false' ){
                soql+=' and Product2.Engine_Capacity_Alternative__c <=:selectedtoEngine';
            }
            system.debug('------soql'+soql);
            if(mobilesort == 'false'){
                if(sortbyvalue ==System.Label.PRICE_HIGH_TO_LOW){
                    soql += ' Order by Local_price__c DESC NULLS LAST';
                }
                if(sortbyvalue ==System.Label.PRICE_LOW_TO_HIGH){
                    soql += ' Order by Local_price__c ASC NULLS LAST ';
                }
                if(sortbyvalue ==System.Label.AGE_HIGH_TO_LOW){
                    soql += ' Order by Age__c DESC  NULLS LAST';
                }
                if(sortbyvalue ==System.Label.AGE_LOW_TO_HIGH){
                    soql += ' Order by Age__c ASC NULLS LAST ';
                }
                if(sortbyvalue ==System.Label.MILEAGE_HIGH_TO_LOW){
                    soql += ' Order by mileage__c DESC NULLS LAST ';
                }
                if(sortbyvalue ==System.Label.MILEAGE_LOW_TO_HIGH){
                    soql += ' Order by mileage__c ASC NULLS LAST';
                }
            } else {
                if(sortbyvaluemobile!='--None--' && sortbyvaluemobile ==System.Label.PRICE_HIGH_TO_LOW ){
                    soql += ' Order by Local_price__c DESC NULLS LAST';
                }
                if(sortbyvaluemobile!='--None--' && sortbyvaluemobile ==System.Label.PRICE_LOW_TO_HIGH){
                    soql += ' Order by Local_price__c ASC  NULLS LAST ';
                }
                if(sortbyvaluemobile!='--None--' && sortbyvaluemobile ==System.Label.AGE_HIGH_TO_LOW){
                    soql += ' Order by Age__c DESC NULLS LAST';
                }
                if(sortbyvaluemobile!='--None--' && sortbyvaluemobile ==System.Label.AGE_LOW_TO_HIGH){
                    soql += ' Order by Age__c ASC NULLS LAST ';
                }
                if(sortbyvaluemobile!='--None--' && sortbyvaluemobile ==System.Label.MILEAGE_HIGH_TO_LOW){
                    soql += ' Order by mileage__c DESC NULLS LAST ';
                }
                if(sortbyvaluemobile!='--None--' && sortbyvaluemobile ==System.Label.MILEAGE_LOW_TO_HIGH){
                    soql += ' Order by mileage__c ASC NULLS LAST';
                }
            }
            
            List<Asset> assetList = Database.query( soql );
            Vehiclelist = new list<Vehiclewrapper>();
            FirstVehicles = new List<VehicleWrapper>();
            System.debug('assetList :: '+assetList.size());
            for(asset ast :assetList) {
                if(equipmentSet.size() > 0 && ast.highlighted_base__c != null && equipmentSet.size() != Equipments.size()) {
                    Set<String> equips = new Set<String>();
                    If(Lang=='en'){
                        equips = getEquips(ast.highlighted_base__c);
                    } else {
                        if(ast.highlighted_local__c != null){
                            equips = getEquips(ast.highlighted_local__c);
                        }
                    }
                    if(equips.containsAll(equipmentSet)) {
                        Vehiclelist.add(new Vehiclewrapper(ast, savedAssetId.contains(ast.Id) ? true : false,SetCompareCheck.contains(ast.Id) ? true : false));
                    }
                }
                else {
                    Vehiclelist.add(new Vehiclewrapper(ast, savedAssetId.contains(ast.Id) ? true : false,SetCompareCheck.contains(ast.Id) ? true : false));
                }
                
            }
            count = Vehiclelist.size();
            System.debug('count :: '+count);
            if(count >= 48) {
                for(Integer i = 0; i < 48; i++) {
                    FirstVehicles.add(VehicleList[i]);
                }
            }
            else {
                FirstVehicles = VehicleList;
            }
            setSelectedValues();
            system.debug('----bean'+bean);
            // Load age options when model changes
            if(dynamicLoad == '1') {
                loadAge();
            }
            // Load models when age changes
            if(dynamicLoad == '2' && !ClearModel) {
                loadModels();
            }
            // Load age and models when other filters are changed
            if(dynamicLoad == '3' && !ClearModel) {
                loadModels();
                loadAge();
            }
            
            ClearModel = false;
            clearfilters = 'false';
        }
        catch(Exception exp) {
            System.debug('exception :: '+exp.getStackTraceString());
        }
    }
    
    public String TempModelsStr { get; set; }
    public Boolean ShowPrev { get; set; }
    
    public void setTempModels() {
        TempModels = new Set<String>(TempModelsStr.split(','));
    }
    
    /******************************************************************************
    Method Name: reset
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to clear the selected filters on page.
    *******************************************************************************/
    public PageReference reset() {
        string paramVal = Apexpages.currentPage().getParameters().get('clearvar');
        System.debug('paramVal :: '+paramVal);
        if(paramVal!=null && paramVal!='' && paramVal=='price' ){
            minprice = '';
            maxprice = '';
        }
        if(paramVal!=null && paramVal!='' && paramVal=='mileage' ){
            minmileage= '';
            maxmileage= '';
        }
        if(paramVal!=null && paramVal!='' && paramVal=='age' ){
            selectedfromAgeVal= '';
            selectedtoAgeVal= '';
        }
        if(paramVal!=null && paramVal!='' && paramVal=='location' ){
            AddressForAccount.clear();
            SearchLocationStr='';
            SearchLocation=false;
        }
        if(paramVal!=null && paramVal!='' && paramVal=='advance' ){
            selectedfromModelYear ='';
            selectedtoModelYear = '';
            selectedfromEngine = '';
            selectedtoEngine ='';
            advancedbodystyleSet.clear();
            specificationSet.clear();
            exteriorColourSet.clear();
            interiorColourSet.clear();
            transmissionSet.clear();
            fuelTypeSet.clear();
            equipmentSet.clear(); 
            //SearchLocationStr=''; 
            //AddressForAccount.clear(); 
            //SearchLocation=false;
        }
        LoadDetails();
        return null;
    }
     
    /* **************************************************************************************
    Method Name: loadModels
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to display nameplate values
    ****************************************************************************************** */
    public pagereference loadModels(){
        sortModelsMap = new map<decimal,string>();
        list<decimal>keysort = new list<decimal>();
        Models = new Set<String>();
        if(Vehiclelist!=null){
            for(Vehiclewrapper obj : Vehiclelist){
                if(obj.model!=null){
                    sortModelsMap.put(obj.sortNo,obj.model);
                }
            }
            keysort.addall(sortModelsMap.keyset());
            keysort.sort();
            for(decimal d :keysort){
                Models.add(sortModelsMap.get(d));
            }
        }
        return null;
    }
    
    /* **************************************************************************************
    Method Name: loadAge
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to display age values 
    ****************************************************************************************** */
    public pagereference loadAge(){
        set<integer> optionval = new set<integer>();
        list<integer> optionvalList = new list<integer>();  
        fromAgeOptions = new List<SelectOption>();
        toAgeOptions = new List<SelectOption>();
        if(Vehiclelist!=null){
            for(Vehiclewrapper vh :Vehiclelist){
                if(vh.registrationDate != null){
                    if(optionval.contains(vh.registrationDate.year())) {
                        // No Logic
                    }
                    else{
                        optionval.add(vh.registrationDate.year());
                        
                    }
                }
            }
            optionvalList.addall(optionval);
            optionvalList.sort();       
            for(Integer year : optionvalList) {
                fromAgeOptions.add(new SelectOption(string.valueof(year),string.valueof(year)));
            }
            for(Integer i = fromAgeOptions.size()-1; i>=0; i--) {
                ToageOptions.add(fromAgeOptions.get(i));
            }
        }
        return null;
    }
    
    /* **************************************************************************************
    Method Name: loadPrice
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to display price of vehicles
    ****************************************************************************************** */
    public void loadPrice(){
        fromPriceOptions = new list<selectoption>();
        ToPriceOptions = new list<selectoption>();
        list<selectoption>descPriceOption = new list<selectoption>();
        set<decimal> frompriceset = new set<decimal>();
        set<decimal> topriceset = new set<decimal>();
        list<decimal> valfrom = new list<integer>();    
        list<decimal> valto = new list<integer>();  
        if(Vehiclelist!=null){
            for(Vehiclewrapper vh :Vehiclelist){
                if(vh.minPrice !=null){
                    if(frompriceset.contains(vh.minPrice)||topriceset.contains(vh.maxPrice)) {
                        // No Logic
                    }
                    else{
                        frompriceset.add(vh.minPrice);
                        topriceset.add(vh.maxPrice);
                    }
                }
            }
            valfrom.addall(frompriceset);  
            valto.addall(topriceset); 
            valfrom.sort();    
            valto.sort();     
            for(decimal price : valfrom) {
                fromPriceOptions.add(new SelectOption(string.valueof(price),string.format(price.format(),args)));
            }
            for(decimal price : valto) {
                descPriceOption.add(new SelectOption(string.valueof(price),string.format(price.format(),args)));
            }
            for(Integer i = descPriceOption.size()-1; i>=0; i--) {
                ToPriceOptions.add(descPriceOption.get(i));
            }
        }
    }
    
      /* **************************************************************************************
    Method Name: loadMileage
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to display mileage of vehicles
    ****************************************************************************************** */
    public void loadMileage(){
        minMileageOptions = new list<selectoption>();
        maxMileageOptions = new list<selectoption>(); 
        list<selectoption> descmileageOption = new list<selectoption>();
        set<decimal> fromMileageset = new set<decimal>();
        set<decimal> toMileageset = new set<decimal>();
        list<decimal> fromMileagelist = new list<decimal>();  
        list<decimal> toMileagelist = new list<decimal>();    
        if(Vehiclelist!=null){
            for(Vehiclewrapper vh :Vehiclelist){
                if(vh.mileage!=null){
                    if(fromMileageset.contains(vh.mileage)||toMileageset.contains(vh.mileage)){
                        // No Logic
                    }
                    else {
                        fromMileageset.add(vh.minMileage);
                        toMileageset.add(vh.maxMileage);
                    }
                }
            }
            fromMileagelist.addall(fromMileageset);
            toMileagelist.addall(toMileageset);
            fromMileagelist.sort();   
            toMileagelist.sort();   
            for(decimal mileage : fromMileagelist) {
                minMileageOptions.add(new SelectOption(string.valueof(mileage),string.format(mileage.format(),args)));
            }
            for(decimal mileage : toMileagelist) {
                descmileageOption.add(new SelectOption(string.valueof(mileage),string.format(mileage.format(),args)));
            }
            for(Integer i = descmileageOption.size()-1; i>=0; i--) {
                maxMileageOptions.add(descmileageOption.get(i));
            }
        }
    }
    
    /* **************************************************************************************
    Method Name: loadAdvansed
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to display the advanced section
    ****************************************************************************************** */
    
    public void loadAdvansed(){
        fromModelyearOptions = new list<selectoption>();
        toModelyearOptions = new list<selectoption>();
        FromEngineOptions =  new list<selectoption>();
        ToEngineOptions = new list<selectoption>();
        set<string>modelyearSet = new set<string>();
        BodyStyles = new Set<String>();
        Specifications = new Set<String>();
        ExteriorColors = new Set<String>();
        InteriorColors = new Set<String>();
        Transmissions = new Set<String>();
        FuelTypes = new Set<String>();
        Equipments = new Set<String>();
        
        if(Vehiclelist!=null){
            for(Vehiclewrapper obj : Vehiclelist){
                if(!String.isBlank(obj.bodyStyle))
                    BodyStyles.add(obj.bodyStyle);
                if(!String.isBlank(obj.specification))
                    Specifications.add(obj.specification);
                if(!String.isBlank(obj.fuelType))
                    FuelTypes.add(obj.fuelType);
                if(!String.isBlank(obj.transmission))
                    Transmissions.add(obj.transmission);
                if(!String.isBlank(obj.extColor))
                    ExteriorColors.add(obj.extColor);
                if(!String.isBlank(obj.intColor))
                    InteriorColors.add(obj.intColor);
                if(!String.isBlank(obj.modelYear)){
                    if(modelyearSet.contains(obj.modelYear)){
                        // No Logic
                    }
                    else{
                        modelyearSet.add(obj.modelYear);
                    }
                }
                if(!String.isBlank(obj.highlighted)) {
                    Equipments.addAll(getEquips(obj.highlighted));
                }
            } 
            for(String year : modelyearSet) {
                fromModelyearOptions.add(new SelectOption(year, year));
            }
            fromModelyearOptions.sort();
            for(Integer i = fromModelyearOptions.size()-1; i>=0; i--) {
                toModelyearOptions.add(fromModelyearOptions.get(i));
            }
        }
        
        Schema.DescribeFieldResult result = Product2.Engine_Capacity_Alternative__c.getDescribe();
        list<Schema.PicklistEntry> pickValues =result.getPicklistValues();
        for( Schema.PicklistEntry p : pickValues){  
            FromEngineOptions.add(new SelectOption(p.getLabel(), p.getValue()));    
        }
        FromEngineOptions.sort();
        for(Integer i = FromEngineOptions.size()-1; i>=0;i--)
        {
            ToEngineOptions.add(FromEngineOptions.get(i));
        }
    }
    
    /* **************************************************************************************
    Method Name: ProcessSelected
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to select the values on the filtering section in 
                        Nameplate, Price, Mileage and Age Section.
    ****************************************************************************************** */
    public void ProcessSelected(){
        string NameValue = Apexpages.currentPage().getParameters().get('checkname');
        string selectedval = Apexpages.currentPage().getParameters().get('checkval');
        if(selectedval == 'true'){
            SelectedNameSet.add(NameValue);
        }
        if(selectedval == 'false'){
            SelectedNameSet.remove(NameValue);
        }
        LoadDetails();
     }
     

    /* **************************************************************************************
    Method Name: getSelectedValues
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to get the selected values by the user on the
                        UI in the controller
    ****************************************************************************************** */
    public void getSelectedValues() {
        String selected = ApexPages.currentPage().getParameters().get('selectedValues');
        String index = ApexPages.currentPage().getParameters().get('index');
        clearfilters = 'false';
        
        if(!String.isBlank(selected)) {
            if(index == '1') {
                SelectedNameSet = new Set<String>(selected.split(','));
                dynamicLoad = '1';
            }
            if(index == '2') {
                advancedbodystyleSet = new Set<String>(selected.split(','));
            }
            if(index == '3') {
                specificationSet = new Set<String>(selected.split(','));
            }
            if(index == '4') {
                exteriorColourSet = new Set<String>(selected.split(','));
            }
            if(index == '5') {
                interiorColourSet = new Set<String>(selected.split(','));
            }
            if(index == '6') {
                transmissionSet = new Set<String>(selected.split(','));
            }
            if(index == '7') {
                fuelTypeSet = new Set<String>(selected.split(','));
            }
            if(index == '8') {
                equipmentSet = new Set<String>(selected.split(','));
            }
        }
        else {
            SelectedNameSet = Models;
            advancedbodystyleSet = BodyStyles;
            specificationSet = Specifications;
            exteriorColourSet = ExteriorColors;
            interiorColourSet = InteriorColors;
            transmissionSet = Transmissions;
            fuelTypeSet = FuelTypes;
            equipmentSet = Equipments;
        }
        LoadDetails();
    }
    
    public final Set<String> InitialModels { get; set; }
    public Boolean ClearModel { get; set; }
    
    /* **************************************************************************************
    Method Name: clear
    Input Parameters: NA
    Return Type: NA
    Method Description: This Method contains the logic to clear the selected values on NameplateSection.
    ****************************************************************************************** */
    public void clear() {
        String index = ApexPages.currentPage().getParameters().get('index');
        ClearModel = true;
        Models = InitialModels;
        if(index == '1') {
            SelectedNameSet.clear();
            dynamicLoad = '1';
        }
        LoadDetails();
    }

    /* **************************************************************************************
    class Name: Vehiclewrapper
    Input Parameters: NA
    Return Type: NA
    class Description: wrapper class created to bind vehicle nameplate values
    ****************************************************************************************** */
    public class Vehiclewrapper{    
        public String assetId { get; set; }
        public string APOImagePath{get;set;}
        public Decimal mileage{get;set;}
        public Decimal price{get;set;}
        public string Vehiclename{get;set;}
        public string bodystyle{get;set;}
        public string specification{get;set;}
        public string Transmission{get;set;}
        public string fuelType{get;set;}
        public Boolean isSaved { get; set; }
        public Boolean isCompared { get; set; }
        public Date registrationDate { get; set; }
        public string registrationDatestr { get; set; }
        public String modelYear { get; set; }
        
        // For Search
        public String model { get; set; }
        public Decimal minprice { get; set; }
        public Decimal maxPrice { get; set; }
        
        public Decimal minMileage { get; set; }
        public Decimal maxMileage { get; set; }
        
        public String extColor { get; set; }
        public String intColor { get; set; }
        public String highlighted { get; set; }
        public decimal sortNo;
        // String mk = apexpages.currentpage().getparameters().get('market');
        String mk = JUDAANUtil.getSimpleMarket();
        
        public Vehiclewrapper(asset a, Boolean isSaved, boolean isCompare) {
            if(StringUtil.splitImageLink(a.pictures__c).size() > 0) {
                this.APOImagePath = StringUtil.splitImageLink(a.pictures__c)[0];
            }
            this.price = a.Local_price__c;
            // this.Vehiclename = a.Product2.model_alternative__c+' '+a.Product2.APO_Body_Style_Alternative__c+' '+a.Product2.Specification_Pack_Alternative__c+' '+(a.Product2.Model_Year_Alternative__c);
            this.Vehiclename = a.Product2.model_alternative__c+' '+a.Product2.APO_Body_Style_Alternative__c+' '+a.Product2.Specification_Pack_Alternative__c;
            this.bodyStyle = StringUtil.getValue( a.Product2.APO_Body_Style_Alternative__c ); 
            this.specification = a.Product2.Specification_Pack_Alternative__c;
            this.modelYear = a.Product2.Model_Year_Alternative__c;
            this.transmission = a.Product2.Transmission_Alternative__c;
            this.fuelType = a.Product2.Fuel_Type_Alternative__c;
            this.registrationDate = a.Vehicle_Initial_Registration_Date__c;
            if(registrationDate != null) {
                datetime Vehiclelegalcheckterm  = datetime.newInstance(registrationDate.year(), registrationDate.month(),registrationDate.day());
                registrationDatestr = Vehiclelegalcheckterm.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            } //end
            
            this.assetId = a.id;
            this.isSaved = isSaved;
            this.model = a.Product2.model_alternative__c;
            this.minPrice = a.FromLocalPrice__c;
            this.maxPrice = a.ToLocalPrice__c;
            this.mileage = a.mileage__c;
            this.minMileage = a.FromMileage__c;
            this.maxMileage = a.ToMileage__c;
            this.extColor = a.exterior_Colour__c;
            this.intColor = a.Interior_Color__c;
            if(ApexPages.currentPage().getParameters().get('lang')=='en') {
                this.highlighted = a.highlighted_base__c;
            } else {
                this.highlighted = a.highlighted_local__c; 
            }
            if(mk == 'sg') {
                this.sortNo = a.product2.Name_Plate_Display_Order_SG__c;
            } else {
            	this.sortNo = a.product2.Name_plate_display_order__c;
            }
            if(ApexPages.currentPage().getParameters().get('id1') == a.id || ApexPages.currentPage().getParameters().get('id2') == a.id || ApexPages.currentPage().getParameters().get('id3') == a.id) {
                this.isCompared=true;
            }
            else{
                this.isCompared=isCompare;
            }
        }
    }
    
    /* **************************************************************************************
    Method Name: showMore
    Input Parameters: NA
    Return Type: NA
    Method Description: This method is executed when the end-user clicks on a image of Vehicle on UI.
                        The user is navigated to APOVehicleSingle Page.
    ****************************************************************************************** */
    public PageReference showMore() {
        String assetId = ApexPages.currentPage().getParameters().get('assetId');
        this.dto.apoVehicleSearchbean = this.bean;

        Saved_Vehicle_for_Lead__c savedVehicle = new Saved_Vehicle_for_Lead__c();
        insert savedVehicle;
        /* Blob b = Blob.valueOf(JSON.serialize(new APOVehicleSearchBeanSelectedOnly(this.dto.apoVehicleSearchBean)));
        Attachment att = new Attachment();
        att.Name = 'Bean Class.json';
        att.ParentId = savedVehicle.Id;
        att.Body = b;
        insert att; */
        PageReference singlePage = Page.APOVehicleSingle;
        singlePage.getParameters().put('svid' , savedVehicle.Id);
        singlePage.getParameters().put('lang', Lang);
        singlePage.getParameters().put('brand', Brand);
        singlePage.getParameters().put('market', Market);
        singlePage.getParameters().put('id', assetId);
        singlePage.setRedirect(true);
        return singlePage;
    }    
    
    public List<Saved_Vehicle_for_Lead__c> SavedVehicleLead { get; set; } 
    public List<Saved_Vehicle_for_Account__c> SavedVehicleAccount { get; set; }
    public Map<Id, List<Saved_Vehicle_for_Lead__c>> SavedLeadMap { get; set; }
    public Map<Id, List<Saved_Vehicle_for_Account__c>> SavedAccountMap { get; set; }
    public Set<Id> savedAssetId { get; set; } 
    public String AccountId { get; set; }
    
    /* **************************************************************************************
    Method Name: checkSaved
    Input Parameters: NA
    Return Type: NA
    Method Description: This method is used to store any vehicles saved by the End-User after the user logins.
    ****************************************************************************************** */
    public void checkSaved() {
        savedAssetId = new Set<Id>();
        if(UserDao.getUserById(UserInfo.getUserId()).size() > 0) {
            this.AccountId = UserDao.getUserById(UserInfo.getUserId())[0].AccountId;
            List<Lead> leads = new List<Lead>();
            leads = [select Id from Lead where Account__c = :AccountId];
            String leadId;
            if(leads.size() > 0) {
                leadId = leads[0].Id;                
            }
            
            SavedVehicleLead = new List<Saved_Vehicle_for_Lead__c>();
            SavedLeadMap = new Map<Id, List<Saved_Vehicle_for_Lead__c>>();
            if(leads.size() > 0) {
                SavedVehicleLead = [Select Id, Saved_Vehicle__c from Saved_Vehicle_for_Lead__c where Lead__c = :leadId];
            }
            for(Saved_Vehicle_for_Lead__c saved : SavedVehicleLead) {
                if(saved.Saved_Vehicle__c != null) {
                    savedAssetId.add(saved.Saved_Vehicle__c);
                    if(SavedLeadMap.containsKey(saved.Saved_Vehicle__c)) {
                        List<Saved_Vehicle_for_Lead__c> tempList = new List<Saved_Vehicle_for_Lead__c>();
                        
                        tempList = SavedLeadMap.get(saved.Saved_Vehicle__c);
                        tempList.add(saved);
                        SavedLeadMap.put(saved.Saved_Vehicle__c, tempList);
                    } 
                    else {
                        SavedLeadMap.put(saved.Saved_Vehicle__c, new List<Saved_Vehicle_for_Lead__c> { saved });
                    }
                }
            }
            
            SavedVehicleAccount = new List<Saved_Vehicle_for_Account__c>();
            SavedAccountMap = new Map<Id, List<Saved_Vehicle_for_Account__c>>();
            SavedVehicleAccount = [Select Id, Saved_Vehicle__c from Saved_Vehicle_for_Account__c where Account__c = :AccountId];
            for(Saved_Vehicle_for_Account__c saved : SavedVehicleAccount) {
                if(saved.Saved_Vehicle__c!= null) {
                    savedAssetId.add(saved.Saved_Vehicle__c);
                    if(SavedAccountMap.containsKey(saved.Saved_Vehicle__c)) {
                        List<Saved_Vehicle_for_Account__c> tempList =   new List<Saved_Vehicle_for_Account__c>();
                        tempList = SavedAccountMap.get(saved.Saved_Vehicle__c);
                        tempList.add(saved);
                        SavedAccountMap.put(saved.Saved_Vehicle__c, tempList);
                    }
                    else {
                        SavedAccountMap.put(saved.Saved_Vehicle__c, new List<Saved_Vehicle_for_Account__c> { saved });
                    }
                }
            }
        }
    }
    
    public void setAssetIdToDtoClass(){   
        this.dto.apoVehicleSearchbean = this.bean;
        this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
    }
    
    /* **************************************************************************************
    Method Name: getSelectedCompare
    Method Description: This method is used to store selected vehicle for compare.
    ****************************************************************************************** */
    public void getSelectedCompare(String NodeStr , PageReference p) {
        List<String> IdsForCompare= new List<String>();
        IdsForCompare= ( List<String> )JSON.deserialize(NodeStr, List<string>.class ) ;
        if(IdsForCompare != null && IdsForCompare.size() > 0) {
            if(IdsForCompare[0]!=''){
                p.getParameters().put('id1', IdsForCompare[0]);
            }
            if(IdsForCompare.size()>1){
                if(IdsForCompare[1]!=''){
                    p.getParameters().put('id2', IdsForCompare[1]);
                }
            }
            if(IdsForCompare.size()==3){
                if(IdsForCompare[2]!=''){
                    p.getParameters().put('id3',IdsForCompare[2]);
                }
            }
        }
    }
    
    /* **************************************************************************************
    Method Name: save
    Input Parameters: NA
    Return Type: NA
    Method Description: This method is used to store any vehicles saved by the End-User.
    ****************************************************************************************** */
    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        PageReference p;
        List<String> IdsForCompare= new List<String>();
        String NodeStr;
        try{
            this.dto.assetId = ApexPages.currentPage().getParameters().get('assetId');
            this.dto.apoVehicleSearchbean = this.bean;
            this.dto.createSavedVehicle.create(this.dto);
            p = Page.APOVehicleSearch;
            if('Jaguar' == this.brand) {
                p.getParameters().put('brand', 'jaguar');
            } else {
                p.getParameters().put('brand', 'landrover');
            }
            p.getParameters().put('lang', this.Lang);
            p.getParameters().put('market', this.Market);
            if(CompareStr != null)
                NodeStr = CompareStr; 
            If(!(String.isBlank(NodeStr)) &&  NodeStr != null)
                getSelectedCompare(NodeStr,p);
            p.setRedirect(true);
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return p;
    }
    
    /* **************************************************************************************
    Method Name: removeAsset
    Input Parameters: NA
    Return Type: NA
    Method Description: This method is used to remove any vehicle saved by the End-User.
    ****************************************************************************************** */
    public PageReference removeAsset() {
        Savepoint sp = Database.setSavepoint();
        String assetId = Apexpages.currentPage().getParameters().get('assetId');
        PageReference p;
        List<String> IdsForCompare= new List<String>();
        String NodeStr;
        try {
            if(SavedLeadMap.containsKey(assetId)) {
                delete SavedLeadMap.get(assetId);
            }
            if(SavedAccountMap.containsKey(assetId)) {
                delete SavedAccountMap.get(assetId);
            }
            p = Page.APOVehicleSearch;
            if('Jaguar' == this.brand) {
                p.getParameters().put('brand', 'jaguar');
            } else {
                p.getParameters().put('brand', 'landrover');
            }
            p.getParameters().put('lang', this.Lang);
            p.getParameters().put('market', this.Market);
            if(CompareStr != null)
                NodeStr = CompareStr; 
            If(!(String.isBlank(NodeStr)) &&  NodeStr != null)
                getSelectedCompare(NodeStr,p);
            p.setRedirect(true);
        }
        catch(Exception ex) {
            Database.rollback(sp);
            system.debug('---ex:' + ex.getStackTraceString());
        }
        return p;
    }
    
    /* **************************************************************************************
    Method Name: getEquips
    Input Parameters: string
    Return Type: set of string
    Method Description: This method contains the logic to display the other equipment section on the advanced
                        filter section on UI.
    ****************************************************************************************** */
    public Set<String> getEquips(String highlightBase) {
        Set<String> es = new Set<String>();
        for(String e : highlightBase.split(',')) {
            if(e.split(':').size() > 1) {
                String str = e.split(':')[1].remove('"');
                str = str.replace('{', '');
                str = str.replace('}', '');
                str = str.replace('/', ' ');
                es.add(str);
            }
        }
        return es;
    }
   
    public List<VehicleWrapper> FirstVehicles { get; set; }
    public Boolean isLoaded { get; set; }
    
    /* **************************************************************************************
    Method Name: loadMore
    Input Parameters: NA
    Return Type: NA
    Method Description: This method is executed when end-user clicks on load more on UI.                    
    ****************************************************************************************** */
    public void loadMore() {
        FirstVehicles = VehicleList;
        isLoaded = true;
    }
    
    public void assetToShow(){
        String NodeStrLoc = LocationStr;
        clearfilters = 'false';
        SearchLocation = true;
        AddressForAccount = new List<String>();
        IF(NodeStrloc != null){
            AddressForAccount = ( List<String> )JSON.deserialize(NodeStrloc, List<string>.class ) ;
            if(AddressForAccount != null){
                 loadDetails();
            }
        }
    }
    
    public PageReference CompareData() {
        List<String> IdsForCompare= new List<String>();
        CompareDto cmpdto= new CompareDto();
        PageReference p = Page.APOVehicleCompare;
        String NodeStr = CompareStr;
        If(NodeStr != null){
            
            IdsForCompare= ( List<String> )JSON.deserialize(NodeStr, List<string>.class ) ;
            if(IdsForCompare[0]!=''){
                p.getParameters().put('id1', IdsForCompare[0]);
                
            }
            if(IdsForCompare.size() > 1){
                if(IdsForCompare[1]!=''){
                    p.getParameters().put('id2', IdsForCompare[1]);
                }
            }
            if(IdsForCompare.size() == 3){
                if(IdsForCompare[2] != ''){
                    p.getParameters().put('id3', IdsForCompare[2]);
                }
            }
            String assetId = ApexPages.currentPage().getParameters().get('assetId');
            this.dto.apoVehicleSearchbean = this.bean;
            Saved_Vehicle_for_Lead__c savedVehicle = new Saved_Vehicle_for_Lead__c();
            insert savedVehicle;
            
            p.getParameters().put('svid' , savedVehicle.Id);
            p.getParameters().put('lang', ApexPages.currentPage().getParameters().get('lang'));
            p.getParameters().put('brand', brand);
            p.getParameters().put('market', Market);
            p.setRedirect(true);
        }
        return p;
    }
}
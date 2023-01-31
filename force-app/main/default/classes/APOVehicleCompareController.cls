/*** 
Requirement : APOVehicleCompare Page 
Description: 
Author : TCS TEAM 
Test class: 
Create Date: 19/06/2018
Description: Controller class with methods to call the compare scenario from APO Search Page

***/

public class APOVehicleCompareController {

    public String brand { get; set; }
    public String CurrencySym{ get; set; }
    public String language {get;set;}
    public String market { get; set; }
    public string bodystyle1{get;set;}
    public string bodystyle2{get;set;}
    public string bodystyle3{get;set;}
    public string fueltype1{get;set;}
    public string fueltype2{get;set;}
    public string fueltype3{get;set;}
    public decimal milage1{get;set;}
    public decimal milage2{get;set;}
    public decimal milage3{get;set;}
    public string modelyear1{get;set;}
    public string modelyeartile1{get;set;}
    public string modelyear2{get;set;}
    public string modelyeartile2{get;set;}
    public string modelyear3{get;set;}
    public string modelyeartile3{get;set;}
    public string engine1{get;set;}
    public string engine2{get;set;}
    public string engine3{get;set;}
    public string registration1{get;set;}
    public string registration2{get;set;}
    public string registration3{get;set;}
    public CreateSavedVehicleDto dto {get; set;}
    public String getLanguage() {
        return null;
    }

    public Set<String> FeatureSet{get;set;}
    public Set<String> FeaturesSetAsset{get;set;}
    public Map<String, Map<String,boolean>> mapOfList{get;set;}
    public Map<String,boolean> mapFeatureExist{get;set;}
    public VehicleWrapper WrapperAssetToShow1{get;set;}
    public VehicleWrapper WrapperAssetToShow2{get;set;}
    public VehicleWrapper WrapperAssetToShow3{get;set;}
    public List<VehicleWrapper> lstWrapperAsset{get;set;}
    public Boolean IsAPO { get; set; }
    public boolean IsJaguar{get;set;}

    public APOvehiclecompareController(){
        brand = ApexPages.currentPage().getParameters().get('brand');
        IsJaguar = brand== 'jaguar' ? true : false;
        language = ApexPages.currentPage().getParameters().get('lang');
        this.market = JUDAANUtil.getSimpleMarket();
        if(String.isEmpty(this.language)) {
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        if(this.language != 'ja' && this.language != 'en' &&   this.language != 'pt_BR'){
                this.language = System.label.DEFAULT_LANGUAGE;
        }
        FeatureSet= new Set<String>{'Keyless Entry and Keyless Start',
                                    'Intelligent Stop/Start System',
                                    'Analogue Audio System',
                                    'Bluetooth Telephone Connectivity',
                                    'Driver & Passenger Front Electric Seats',
                                    'Passenger Electric Seat Adjustment',
                                    'Premium Interior Mood Lighting',
                                    'Front Parking Aid',
                                    'Rear Centre Head Restraint',
                                    'Leather Steering Wheel',
                                    'Seat Memory Function',
                                    'Rear Parking Aid',
                                    'Reverse Parking Camera',
                                    'Head-Up Display',
                                    'Xenon Headlights',
                                    'BI - Xenon HeadLamps',
                                    'Climate Control',
                                    'Cruise Control',
                                    'Voice Control System',
                                    'Panoramic Roof',
                                    'Passive Entry/Push Button Start',
                                    'Stop/Start System',
                                    'Bluetooth Audio Stream',
                                    'Powered Tailgate',
                                    'Elect Front Seat Adjust with Memory'};
        
        
        
    }
    public pagereference LoadCompareData(){
        String mk = apexpages.currentpage().getparameters().get('market');
        brand = ApexPages.currentPage().getParameters().get('brand');
        language = ApexPages.currentPage().getParameters().get('lang');
        this.market = JUDAANUtil.getSimpleMarket();
        lstWrapperAsset= new List<VehicleWrapper>();
        if(String.isEmpty(this.language)) {
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        if(this.language != 'ja' && this.language != 'en' &&  this.language != 'pt_BR'){
                this.language = System.label.DEFAULT_LANGUAGE;
        }
        IsAPO =JUDAANUtil.getAPOorNot();
        CurrencySym= JUDAANUtil.getCurrencySymbol();
        mapOfList= new Map<String, Map<String,boolean>>();
        mapFeatureExist= new Map<String,boolean>();
        this.dto = new CreateSavedVehicleDto();
        this.dto.createSavedVehicle = new CreateSavedVehicleImplByAPOVehicleSearch();
        this.dto.url = '/APOVehicleCompare';
        this.dto.urlParameterMap = new Map<String, String>();
        this.dto.urlParameterMap.put('brand', Brand);
        this.dto.urlParameterMap.put('lang', this.language );
        this.dto.urlParameterMap.put('market', Market);
        FeaturesSetAsset= new Set<String>();
        
        String assetID='';
        IF( ApexPages.currentPage().getParameters().get('id1')!='' && ApexPages.currentPage().getParameters().get('id1')!=null){
            assetID=ApexPages.currentPage().getParameters().get('id1');
            getFeatureForCompare(assetID);
            WrapperAssetToShow1=getAssetWrapper(AssetDao.getAssetForCompareById(assetID)[0]);
            lstWrapperAsset.add(WrapperAssetToShow1);
            system.debug('----WrapperAssetToShow1'+AssetDao.getAssetForCompareById(assetID)[0].Product2.Transmission_Alternative__c);
            bodystyle1=WrapperAssetToShow1.assetobj.Product2.APO_Body_Style_Alternative__c;
            fueltype1 =WrapperAssetToShow1.assetobj.Product2.Fuel_Type_Alternative__c;
            milage1   =WrapperAssetToShow1.assetobj.Mileage__c;
            modelyear1=WrapperAssetToShow1.assetobj.Product2.Model_Year_Alternative__c;
            if(WrapperAssetToShow1.assetobj.Product2.Model_Year_Alternative__c != null)
            modelyeartile1 = Label.ManufactureYear + WrapperAssetToShow1.assetobj.Product2.Model_Year_Alternative__c.right(2);
            engine1   =WrapperAssetToShow1.assetobj.Product2.Engine_Name_Alternative__c;
            if(WrapperAssetToShow1.assetobj.Vehicle_Initial_Registration_Date__c != null)
            {
                datetime regDateFormat  = datetime.newInstance(WrapperAssetToShow1.assetobj.Vehicle_Initial_Registration_Date__c.year(), WrapperAssetToShow1.assetobj.Vehicle_Initial_Registration_Date__c.month(),WrapperAssetToShow1.assetobj.Vehicle_Initial_Registration_Date__c .day());
                registration1 = regDateFormat.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            }
        }
        IF( ApexPages.currentPage().getParameters().get('id2')!='' && ApexPages.currentPage().getParameters().get('id2')!=null){
            assetID=ApexPages.currentPage().getParameters().get('id2');
            getFeatureForCompare(assetID);
            WrapperAssetToShow2=getAssetWrapper(AssetDao.getAssetForCompareById(assetID)[0]);
            lstWrapperAsset.add(WrapperAssetToShow2);
            system.debug('WrapperAssetToShow1.assetobj :: '+WrapperAssetToShow1);
            bodystyle2=WrapperAssetToShow2.assetobj.Product2.APO_Body_Style_Alternative__c;
            fueltype2 =WrapperAssetToShow2.assetobj.Product2.Fuel_Type_Alternative__c;
            milage2   =WrapperAssetToShow2.assetobj.Mileage__c;
            modelyear2=WrapperAssetToShow2.assetobj.Product2.Model_Year_Alternative__c;
            
            if(WrapperAssetToShow1 != null)
            {
              if(WrapperAssetToShow1.assetobj.Product2.Model_Year_Alternative__c != null)
             modelyeartile2 = Label.ManufactureYear + WrapperAssetToShow2.assetobj.Product2.Model_Year_Alternative__c.right(2);
              
            }
            engine2   =WrapperAssetToShow2.assetobj.Product2.Engine_Name_Alternative__c;
            if(WrapperAssetToShow2.assetobj.Vehicle_Initial_Registration_Date__c != null)
            {
                datetime regDateFormat  = datetime.newInstance(WrapperAssetToShow2.assetobj.Vehicle_Initial_Registration_Date__c.year(), WrapperAssetToShow2.assetobj.Vehicle_Initial_Registration_Date__c.month(),WrapperAssetToShow2.assetobj.Vehicle_Initial_Registration_Date__c .day());
                registration2 = regDateFormat.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            }
        }
        IF( ApexPages.currentPage().getParameters().get('id3')!='' && ApexPages.currentPage().getParameters().get('id3')!=null){
           assetID=ApexPages.currentPage().getParameters().get('id3');
           getFeatureForCompare(assetID);
           WrapperAssetToShow3=getAssetWrapper(AssetDao.getAssetForCompareById(assetID)[0]);
           lstWrapperAsset.add(WrapperAssetToShow3);
           bodystyle3=WrapperAssetToShow3.assetobj.Product2.APO_Body_Style_Alternative__c;
           fueltype3 =WrapperAssetToShow3.assetobj.Product2.Fuel_Type_Alternative__c;
           milage3   =WrapperAssetToShow3.assetobj.Mileage__c;
           modelyear3=WrapperAssetToShow3.assetobj.Product2.Model_Year_Alternative__c;
            if(WrapperAssetToShow1 != null)
            {
               if(WrapperAssetToShow1.assetobj.Product2.Model_Year_Alternative__c != null)
              modelyeartile3 = Label.ManufactureYear + WrapperAssetToShow3.assetobj.Product2.Model_Year_Alternative__c.right(2); 
            
            }
           engine3   =WrapperAssetToShow3.assetobj.Product2.Engine_Name_Alternative__c;
           if(WrapperAssetToShow3.assetobj.Vehicle_Initial_Registration_Date__c != null)
            {
                datetime regDateFormat  = datetime.newInstance(WrapperAssetToShow3.assetobj.Vehicle_Initial_Registration_Date__c.year(), WrapperAssetToShow3.assetobj.Vehicle_Initial_Registration_Date__c.month(),WrapperAssetToShow3.assetobj.Vehicle_Initial_Registration_Date__c .day());
                registration3 = regDateFormat.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c );
            }
        }
        return JUDAANUtil.brandCheck();
    }
     public void getFeatureForCompare(String AssetId){
        FeaturesSetAsset= getFeatures(AssetDao.getAssetForCompareById(AssetId)[0].Features_Base__c);
        system.debug('----FeaturesSetAsset'+FeaturesSetAsset);
        List<String> FeatureList = new List<String>(FeatureSet);
        List<String> FeatureAssetList = new List<String>(FeaturesSetAsset);
        for(String StrFeature:FeatureSet){
            for(String StrAssetFeature:FeaturesSetAsset){
                system.debug('----StrAssetFeature'+StrAssetFeature);
                if(StrFeature.equalsIgnoreCase(StrAssetFeature)){
                    mapFeatureExist.put(StrFeature,true);
                    break;
                    
                }else if(isAcceptableMatch(StrFeature,StrAssetFeature,true ,true)==true){
                    mapFeatureExist.put(StrFeature,true);
                    break;
                }
                else{
                    mapFeatureExist.put(StrFeature,false);
                }
            }
        }
       if(mapFeatureExist.size()>0){
           mapOfList.put(AssetId,mapFeatureExist);
       }
       
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
            System.debug('### JSON Parsing ERROR ### ' + ex.getMessage());
        }
        return featuresSet;
    }
    
    public VehicleWrapper getAssetWrapper(Asset a){
        VehicleWrapper wrapperobj= new VehicleWrapper();
        Map<String,boolean> mapFeatureCheck= mapOfList.get(String.valueof(a.id));
        wrapperobj.assetobj=  a;
        System.debug('model year--->'+a.Product2.Model_Year_Alternative__c);
        System.debug('body style--->'+a.Product2.APO_Body_Style_Alternative__c);
        System.debug('engine--->'+a.Product2.Engine_Name_Alternative__c);
        
        if(StringUtil.splitImageLink(a.pictures__c).size() > 0)
        {
            System.debug('ImgPath :: '+StringUtil.splitImageLink(a.pictures__c)[0]);
            System.debug('ImgPath1 :: '+StringUtil.splitImageLink(a.pictures__c));
            wrapperobj.APOImagePath =StringUtil.splitImageLink(a.pictures__c)[0];
        }
         wrapperobj.Keyless_Entry_and_Keyless_Start=mapFeatureCheck.get('Keyless Entry and Keyless Start');
         wrapperobj.Intelligent_Stop_Start_System=mapFeatureCheck.get('Intelligent Stop/Start System');
         wrapperobj.Analogue_Audio_System=mapFeatureCheck.get('Analogue Audio System');
         wrapperobj.Bluetooth_Telephone_Connectivity=mapFeatureCheck.get('Bluetooth Telephone Connectivity');
         wrapperobj.Driver_Passenger_Front_Electric_Seats=mapFeatureCheck.get('Driver & Passenger Front Electric Seats');
         wrapperobj.Passenger_Electric_Seat_Adjustment=mapFeatureCheck.get('Passenger Electric Seat Adjustment');
         wrapperobj.Premium_Interior_Mood_Lighting=mapFeatureCheck.get('Premium Interior Mood Lighting');
         wrapperobj.Front_Parking_Aid=mapFeatureCheck.get('Front Parking Aid');
         wrapperobj.Rear_Centre_Head_Restraint=mapFeatureCheck.get('Rear Centre Head Restraint');
         wrapperobj.Leather_Steering_Wheel=mapFeatureCheck.get('Leather Steering Wheel');
         wrapperobj.Seat_Memory_Function=mapFeatureCheck.get('Seat Memory Function');
         wrapperobj.Rear_Parking_Aid=mapFeatureCheck.get('Rear Parking Aid');
         wrapperobj.Reverse_Parking_Camera=mapFeatureCheck.get('Reverse Parking Camera');
         wrapperobj.Head_Up_Display=mapFeatureCheck.get('Head-Up Display');
         wrapperobj.Xenon_Headlights=mapFeatureCheck.get('Xenon Headlights');
         wrapperobj.Bi_Xenon_Headlamps=mapFeatureCheck.get('BI - Xenon HeadLamps');
         wrapperobj.Climate_Control=mapFeatureCheck.get('Climate Control');
         wrapperobj.Cruise_Control=mapFeatureCheck.get('Cruise Control');
         wrapperobj.Voice_Control_System=mapFeatureCheck.get('Voice Control System');
         wrapperobj.Panoramic_Roof_Feature=mapFeatureCheck.get('Panoramic Roof');
         wrapperobj.Passive_Entry_Button=mapFeatureCheck.get('Passive Entry/Push Button Start');
         wrapperobj.Start_Stop_System=mapFeatureCheck.get('Stop/Start System');
         wrapperobj.Bluetooth_Audio_Stream=mapFeatureCheck.get('Bluetooth Audio Stream');
         wrapperobj.Powered_Tailgate=mapFeatureCheck.get('Powered Tailgate');
         wrapperobj.Elect_Front_SeatAdjust=mapFeatureCheck.get('Elect Front Seat Adjust with Memory');
         if(wrapperobj!=null){return wrapperobj;}
         else{return null;}
        
    }
    public class VehicleWrapper{
        // Asset
        public asset assetobj{get;set;}
        public string APOImagePath{get;set;}
        public boolean Keyless_Entry_and_Keyless_Start{get;set;}
        public boolean Intelligent_Stop_Start_System{get;set;}
        public boolean Analogue_Audio_System{get;set;}
        public boolean In_Dash_Single_CD_Player{get;set;}
        public boolean Jaguar_Sound_System{get;set;}
        public boolean Bluetooth_Telephone_Connectivity{get;set;}
        public boolean Bond_Grain_Leather{get;set;}
        public boolean Driver_Passenger_Front_Electric_Seats{get;set;}
        public boolean Driver_s_Electric_Seat_Adjustment{get;set;}
        public boolean Passenger_Electric_Seat_Adjustment{get;set;}
        public boolean Premium_Interior_Mood_Lighting{get;set;}
        public boolean Front_Parking_Aid{get;set;}
        public boolean Rear_Centre_Head_Restraint{get;set;}
        public boolean Leather_Steering_Wheel{get;set;}
        public boolean Jet_Seatbelts{get;set;}
        public boolean Seat_Memory_Function{get;set;}
        public boolean Flint_Grey_Carpet{get;set;}
        public boolean Console_Stitching_Non_Contrast{get;set;}
        public boolean Door_Casing_Stitching_Non_Contrast{get;set;}
        public boolean Facia_Non_Contrast_Stitching{get;set;}
        public boolean Less_Contrast_Seat_Stitching{get;set;}
        public boolean Rear_Parking_Aid{get;set;}
        public boolean Reverse_Parking_Camera{get;set;}
        public boolean Head_Up_Display{get;set;}
        public boolean Xenon_Headlights{get;set;}
        public boolean Bi_Xenon_Headlamps{get;set;}
        public boolean Climate_Control{get;set;}
        public boolean Cruise_Control{get;set;}
        public boolean Voice_Control_System{get;set;}
        public boolean Panoramic_Roof_Feature{get;set;}
        public boolean Passive_Entry_Button{get;set;}
        public boolean Start_Stop_System{get;set;}
        public boolean Bluetooth_Audio_Stream{get;set;}
        public boolean Powered_Tailgate{get;set;}
        public boolean Elect_Front_SeatAdjust{get;set;}
        
    }
     public PageReference showMore()
    {
        String SvidStr= ApexPages.currentPage().getParameters().get('svid');
        String assetId = ApexPages.currentPage().getParameters().get('assetId');
        PageReference singlePage = Page.APOVehicleSingle;
        singlePage.getParameters().put('svid' , SvidStr);
        singlePage.getParameters().put('lang', language );
        singlePage.getParameters().put('brand', Brand);
        singlePage.getParameters().put('market', Market);
        singlePage.getParameters().put('id', assetId);
        singlePage.setRedirect(true);
        return singlePage;
    } 
    public PageReference goBack()
    {
        String SvidStr= ApexPages.currentPage().getParameters().get('svid');
        String id1 = ApexPages.currentPage().getParameters().get('id1');
        String id2 = ApexPages.currentPage().getParameters().get('id2');
        String id3 = ApexPages.currentPage().getParameters().get('id3');
        PageReference apoSearchPage = Page.APOVehicleSearch;
        apoSearchPage.getParameters().put('svid' , SvidStr);
        apoSearchPage.getParameters().put('lang', language );
        apoSearchPage.getParameters().put('brand', Brand);
        apoSearchPage.getParameters().put('market', Market);
        apoSearchPage.getParameters().put('id1', id1);
        apoSearchPage.getParameters().put('id2', id2);
        apoSearchPage.getParameters().put('id3', id3);
        apoSearchPage.setRedirect(true);
        return apoSearchPage;
    }
    final integer THRESHOLD = 3;
    public string sortedWords (string s) { 
        if (String.isEmpty(s)) {
            return null; 
        } else if (!s.contains(' ')) {
            return s;
        } else {
            list<string> strList = new List<String>();
            strList = s.split(' ');
            strList.sort();
            return String.join(strList, ' ');
        }  
    }
     public boolean isAcceptableMatch(string s1, string s2, boolean ignoreCase, boolean ignoreWordOrder ) {
        if (String.isEmpty(s1) || string.isEmpty(s2)) return false;  
        if (ignoreCase) {
            s1 = s1.toUpperCase();
            s2 = s2.toUpperCase();
        }
        if (ignoreWordOrder) {
        s1 = sortedWords(s1);
        s2 = sortedWords(s2);
        } 
        integer acceptableNumberOfChanges = THRESHOLD + math.abs(s2.length()-s1.length());
        integer levDist = s1.getLevenshteinDistance(s2); 
        if (levDist <= acceptableNumberOfChanges) return true; else return false;
    }
}
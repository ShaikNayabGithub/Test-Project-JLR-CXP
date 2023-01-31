public without sharing class JUDAAN_ProtoProccessor 
{ 
	public static String PROTO_SERVER = system.label.Proto_Server;
    public static String PROTO_SESSION = system.label.Proto_Session;  
	public JUDAAN_ProtoProccessor() 
	{
		
	}
    public without sharing class VehicleWrapper
    {
        public String Brand { get; set; }
        public String Model { get; set; }
        public String Grade { get; set; }
        public String Year { get; set; }
        public String Color { get; set; }
        public Integer Mileage { get; set ;}
        public String TradeinValue { get; set; }
        public Boolean Done { get; set; }
        public VehicleWrapper() {}
        public VehicleWrapper(string brand, string model, string grade, string year, string color, integer mileage, string tradeinvalue, Boolean done)
        {
            this.Brand = brand;
            this.Model = model;
            this.Grade = grade;
            this.Year = year;
            this.Color = color;
            this.Mileage = mileage;
            this.TradeinValue = tradeinvalue;
            this.Done = done;
        } 
    }

	public static JUDAAN_Brand2Apex getBrands()
	{
		string endpointUrl = PROTO_SERVER +  '/grade/1.0/brand_h1.json?session_id=' + PROTO_SESSION; 
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
        HttpResponse response = JUDAANHttpServiceUtil.send(req); 
        
        string brandsJson= response.getBody().replace('list', 'data'); 
        JUDAAN_Brand2Apex obj = JUDAAN_Brand2Apex.parse(brandsJson);
        return obj;
	}
	public static JUDAAN_CarType2Apex getModels(Integer brand)
	{
		string endpointUrl = PROTO_SERVER + '/grade/1.0/cartype_h1.json?session_id=' + PROTO_SESSION + '&brand_cd=' + brand;  
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
    	HttpResponse response = JUDAANHttpServiceUtil.send(req); 
        string modelsJson= response.getBody().replace('list', 'data');
        JUDAAN_CarType2Apex obj = JUDAAN_CarType2Apex.parse(modelsJson);
        return obj;
	}
	public static JUDAAN_Grade2Apex getGrades(Integer model)
	{
		string endpointUrl =  PROTO_SERVER + '/grade/1.0/grade.json?session_id=' + PROTO_SESSION + '&car_cd=' + model;  
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
    	HttpResponse response = JUDAANHttpServiceUtil.send(req); 
        
        string gradesJson = response.getBody().replace('list', 'data'); 
        JUDAAN_Grade2Apex obj = JUDAAN_Grade2Apex.parse(gradesJson );
        return obj;
	}
	public static JUDAAN_Year2Apex getYears(Integer model, Integer grade)
	{
		string endpointUrl = PROTO_SERVER + '/grade/1.0/year_t1.json?session_id=' + PROTO_SESSION + '&car_cd=' + model + '&grade_cd=' + grade;               
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
    	HttpResponse response = JUDAANHttpServiceUtil.send(req);  
        string yearsJson= response.getBody().replace('list', 'data');
        JUDAAN_Year2Apex obj = JUDAAN_Year2Apex.parse(yearsJson);
        return obj;
	}
	public static JUDAAN_Category2Apex getCategories(Integer brand, Integer model, Integer year)
	{
		string endpointUrl = PROTO_SERVER  + '/grade/1.0/catalog_h1.json?session_id=' + PROTO_SESSION + '&brand_cd=' + brand + '&car_cd=' + model + '&year_s=' + year + '&year_e=' + year;
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
        HttpResponse response = JUDAANHttpServiceUtil.send(req);  
        string vehicleJson= response.getBody().replace('list', 'data');
        JUDAAN_Category2Apex obj = JUDAAN_Category2Apex.parse(vehicleJson);
        return obj;
	}
	public static JUDAAN_PriceColor2Apex getColors(String cate_id, String year_num, String handle_id)
	{
		string endpointUrl = PROTO_SERVER +  '/grade/1.0/bb_k_color.json?session_id=' + PROTO_SESSION + '&cat_id=' + cate_id + '&syear=' + year_num + '&handle_id=' + handle_id;
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
        HttpResponse response = JUDAANHttpServiceUtil.send(req);
        string colorJson= response.getBody().replace('list', 'data'); 
        JUDAAN_PriceColor2Apex obj = JUDAAN_PriceColor2Apex.parse(colorJson);
        return obj;
	}
	public static JUDAAN_WholePrice2Apex getPrice(String brand, String cate_id, String handle_id, String year_num, String color, Integer mileage)
	{
		color = color.contains(':') ? color.removeEnd(':') : color;
        String key = String.valueOf(cate_id) + ',' + String.valueOf(handle_id) + ',' + String.valueOf(year_num);
        String marginStr= 'margin_rate=' + system.label.c_default_proto_margin_rate + '&margin_bottom=' + system.label.c_default_proto_margin_bottom + '&margin_top=' + system.label.c_default_proto_margin_top;
        if((system.label.c_proto_brand_JLR).contains(brand))
        {
            marginStr = 'margin_rate=' + system.label.c_proto_margin_rate + '&margin_bottom=' + system.label.c_proto_margin_bottom + '&margin_top=' + system.label.c_proto_margin_top;
        } 
        String endpointUrl =  PROTO_SERVER + '/price/1.0/wholesaleczprice_revision_h1.json?session_id=' + PROTO_SESSION + '&cat_id=' + cate_id + '&syear=' + year_num + '&handle_id=' + handle_id + '&color_id=' + Integer.valueOf(Color) + '&kyori=' + mileage +  '&' + marginStr; 
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl,  'GET');
        HttpResponse response = JUDAANHttpServiceUtil.send(req); 
        string priceJson= response.getBody().replace('list', 'data'); 
        JUDAAN_WholePrice2Apex obj = JUDAAN_WholePrice2Apex.parse(priceJson);
        return obj;
	}
    public static List<SelectOption> setProtoDropdowns(List<JUDAAN_ProtoSelectedBean.Data> data, String defaultOption)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', defaultOption));
        for(JUDAAN_ProtoSelectedBean.Data d : data)
        {
            options.add(new SelectOption(d.Id, d.name));
        }
        return options;
    }
    public static List<SelectOption> setProtoDropdowns(List<JUDAAN_ProtoSelectedBean.Data> data)
    {
        List<SelectOption> options = new List<SelectOption>();
        for(JUDAAN_ProtoSelectedBean.Data d : data)
        {
            options.add(new SelectOption(d.Id, d.name));
        }
        return options;
    }

    public static List<JUDAAN_ProtoSelectedBean.Data> setSelectedParts(List<SelectOption> options)
    {
        List<JUDAAN_ProtoSelectedBean.Data> tempData = new List<JUDAAN_ProtoSelectedBean.Data>();
        for(SelectOption option : Options)
        {
            if(option.getValue() != '')
            {
                
                JUDAAN_ProtoSelectedBean.Data data = new JUDAAN_ProtoSelectedBean.Data(option.getValue(), option.getLabel());
                tempData.add(data);
            }
        }
        return tempData;
    }

    public static Map<Integer, String> getMapValues(List<SelectOption> options)
    {
        Map<Integer, String> tempMap = new Map<Integer, String>();
        for(SelectOption option : options)
        {
            if(option.getValue() != '')
            {
                tempMap.put(Integer.valueOf(option.getValue()), option.getLabel());
            }
        }
        return tempMap;
    } 

    public static Map<String, String> getColorMapValues(List<SelectOption> options)
    {
        Map<String, String> tempMap = new Map<String, String>();
        for(SelectOption option : options)
        {
            if(option.getValue() != '')
            {
                tempMap.put(option.getValue(), option.getLabel());
            }
        }
        return tempMap;
    } 

}
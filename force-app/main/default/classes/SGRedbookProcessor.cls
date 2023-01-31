public class SGRedbookProcessor
{
    public static final string endpoint = system.label.SGRedbook_endpoint;
    public static String ErrorMsg { get; set; }
    public static final string username = system.label.SGRedbook_username;
    public static final string pwd = system.label.SGRedbook_pwd;
    public static final string cred = 'userid=' + username + '&password=' + pwd; 
    public SGRedbookProcessor()
    {
        
    }
    
    public static Map<String, String> getMakes()
    {
        String postData = cred +'&silo=car&action=makes';
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpoint, 'POST', postData);
        HttpResponse res = JUDAANHttpServiceUtil.send(req);
        DOM.Document doc = new DOM.Document();
        doc.load(res.getBody());
        DOM.XMLNode root = doc.getRootElement();
        List<String> codes = new List<String>();
        List<String> names = new List<String>();
        List<DOM.XMLNode> elements = root.getChildElements();
        for(DOM.XMLNode e : elements)
        {
            if(res.getStatusCode() == 200)
            {
                List<DOM.XMLNode> bodyChildrenList = e.getChildElements();
                for (DOM.XMLNode make : bodyChildrenList) {
                    if(make.getName() == 'makecode')
                    {
                        codes.add(make.getText());
                    }
                    if(make.getName() == 'description')
                    {
                        names.add(make.getText());
                    }
                }
            }
           else
           {
               if(e.getName() == 'errordesc')
               {
                   ErrorMsg = e.getText();
               }
           }
        }
        Map<String, String> BrandMap = new Map<String, String>();
        for(Integer i = 0;i < codes.size(); i++)
        {
            BrandMap.put(codes[i], names[i]);
        }
        return BrandMap;
    }
    
    public static List<String> getModels(String make)
    {
        ErrorMsg = null;
        String postData = cred + '&silo=car&action=families&makecode=' + make;
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpoint, 'POST', postData);
        HttpResponse res = JUDAANHttpServiceUtil.send(req);
        DOM.Document doc = new DOM.Document();
        doc.load(res.getBody());
        DOM.XMLNode root = doc.getRootElement();
       
        List<String> modelsStr = new List<String>();
        List<DOM.XMLNode> elements = root.getChildElements();
        
        for(DOM.XMLNode e : elements)
        {
            if(res.getStatusCode() == 200)
            {
                String str = '';
                List<DOM.XMLNode> bodyChildrenList = e.getChildElements();
                for (DOM.XMLNode body : bodyChildrenList) {
                    if(body.getName() == 'familycode')
                    {
                        str += body.getText() + ',';
                    }
                     if(body.getName() == 'vehicletype')
                    {
                        str += body.getText() + ',';
                    }
                    if(body.getName() == 'description')
                    {
                        str += body.getText() + ',';
                    }
                }
                modelsStr.add(str);
           }
           else
           {
               if(e.getName() == 'errordesc')
               {
                   ErrorMsg = e.getText();
               }
           }
        } 
        
        return modelsStr;
    }
    
    public static Set<String> getYears(String make, String model, String type)
    {
        String postData = cred + '&silo=car&action=years&makecode=' + make + '&familycode=' + model + '&vehicletype=' + type;
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpoint, 'POST', postData);
        HttpResponse res = JUDAANHttpServiceUtil.send(req);
        DOM.Document doc = new DOM.Document();
        doc.load(res.getBody());
        DOM.XMLNode root = doc.getRootElement();
        
        Set<String> yearsList = new Set<String>();
        List<DOM.XMLNode> elements = root.getChildElements();
        for(DOM.XMLNode e : elements)
        {
            if(res.getStatusCode() == 200)
            {
                List<DOM.XMLNode> bodyChildrenList = e.getChildElements();
                for (DOM.XMLNode body : bodyChildrenList) {
                   if(body.getName() == 'year')
                    {
                        yearsList.add(body.getText());
                    }
                }
            }
           else
           {
               if(e.getName() == 'errordesc')
               {
                   ErrorMsg = e.getText();
               }
           }
        }  
        return yearsList;
    }
    
    public static Map<String, String> getVehicles(String make, String model, String type, Integer year)
    {
        String postData = cred + '&silo=car&action=vehicles&makecode=' + make + '&familycode=' + model+ '&vehicletype=' + type + '&year=' + year;
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpoint, 'POST', postData);
        HttpResponse res = JUDAANHttpServiceUtil.send(req);
        DOM.Document doc = new DOM.Document();
        doc.load(res.getBody());
        DOM.XMLNode root = doc.getRootElement();
        List<String> codes = new List<String>();
        List<String> names = new List<String>();
        List<DOM.XMLNode> elements = root.getChildElements();
        for(DOM.XMLNode e : elements)
        {
            if(res.getStatusCode() == 200)
            {
                List<DOM.XMLNode> bodyChildrenList = e.getChildElements();
                for (DOM.XMLNode body : bodyChildrenList) {
                    if(body.getName() == 'rbc')
                    {
                        codes.add(body.getText());
                    }
                    if(body.getName() == 'description')
                    {
                        names.add(body.getText());
                    }
                }
            }
           else
           {
               if(e.getName() == 'errordesc')
               {
                   ErrorMsg = e.getText();
               }
           }
        }
        Map<String, String> VehicleMap = new Map<String, String>();
        for(Integer i = 0;i < codes.size(); i++)
        {
            VehicleMap.put(codes[i], names[i]);
        }
        return VehicleMap;
    }
    
    public static Integer getPrice(String vehicle, String brand, String model, Integer mileage,Integer YearSelected)
    {
        String postData = cred + '&silo=car&action=autocalc&rbc=' + vehicle;
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpoint, 'POST', postData);
        HttpResponse res = JUDAANHttpServiceUtil.send(req);
        DOM.Document doc = new DOM.Document();
        doc.load(res.getBody());
        DOM.XMLNode root = doc.getRootElement();
        List<String> codes = new List<String>();
        List<String> names = new List<String>();
        List<String> prices = new List<String>();
        List<DOM.XMLNode> elements = root.getChildElements();
        Integer level = getKM(mileage);
        for(DOM.XMLNode e : elements)
        {
            if(res.getStatusCode() == 200)
            {
                List<DOM.XMLNode> bodyChildrenList = e.getChildElements();
                for (DOM.XMLNode body : bodyChildrenList) {
                   if(body.getName() == 'km')
                    {
                        if(Integer.valueOf(body.getText()) != level)
                        {
                            break;
                        }
                        codes.add(body.getText());
                    }
                    if(body.getName() == 'condition')
                    {
                        names.add(body.getText());
                    }
                    if(body.getName() == 'wholesale')
                    {
                        prices.add(body.getText());
                    }
                }
            }
           else
           {
               if(e.getName() == 'errordesc')
               {
                   ErrorMsg = e.getText();
               }
           }
        }
        Boolean brandBased = JUDAANMarketSettings__c.getValues('sg').Brand_Based__c;
        String conditionKey = brandBased ? brand : model;
        Integer price = 0;
        String condition;
        Decimal percentage;
        Integer CurrentYear=System.Today().year()-1;
        if(prices.size() > 0)
        {
            if(YearSelected != null)
            {
                if(CurrentYear-YearSelected<=3){
                     condition ='Average';
                }
                else if(CurrentYear-YearSelected>3 ){
                    condition ='Fair';
                }
                system.debug('-----cond'+condition);
                price = Integer.valueOf(prices.get(getConditionDigit(condition)));  
            }
            if(price!=NULL){
                system.debug('$$$$condition'+condition);
                price=price-4500;
            }
        }
        return price;
    }
    
    public static Integer getConditionDigit(string condition)
    {
        Map<String, Integer> conditionMapping = new Map<String, Integer> { 'As New' => 0, ' Very Good' => 1, 'Good' => 2, 'Average' => 3, 'Fair' => 4, 'Poor' => 5};
        
        return conditionMapping.get(condition);
    }
    
    public static Integer getKM(Integer mileage)
    {
        Integer level = (mileage / 5000) * 5;
        return level;
    }
    
    public class VehicleWrapper
    {
        public VehicleWrapper() { }
        public VehicleWrapper(String make, String model, Integer year, Integer mileage, Integer price,String registrationnumber) 
        {
            this.make = make;
            this.model = model;
            this.year = year;
            this.mileage = mileage;
            this.registrationnumber= registrationnumber;
            this.price = price;
            this.description = make + ' ' + model + ' ' + String.valueOf(year) + ' ' + String.valueOf(mileage);
        }
        public String make { get; set; }
        public String model { get; set; }
        public Integer Year {get; set; }
        public Integer mileage { get; set; }
        public String registrationnumber{ get; set; }
        public Integer price { get; set; }
        public String description { get; set; }
    }
    
     public static List<SGRedbookSelectedBean.Data> setSelectedParts(List<SelectOption> options)
    {
        List<SGRedbookSelectedBean.Data> tempData = new List<SGRedbookSelectedBean.Data>();
        for(SelectOption option : Options)
        {
            if(option.getValue() != '')
            {
                
                SGRedbookSelectedBean.Data data = new SGRedbookSelectedBean.Data(option.getValue(), option.getLabel());
                tempData.add(data);
            }
        }
        return tempData;
    }
    public static List<SelectOption> setDropdowns(List<SGRedbookSelectedBean.Data> data)
    {
        List<SelectOption> options = new List<SelectOption>();
        for(SGRedbookSelectedBean.Data d : data)
        {
            options.add(new SelectOption(d.Id, d.name));
        }
        return options;
    }
    
     public static List<SelectOption> setDropdowns(List<SGRedbookSelectedBean.Data> data, String defaultOption)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', defaultOption));
        for(SGRedbookSelectedBean.Data d : data)
        {
            options.add(new SelectOption(d.Id, d.name));
        }
        return options;
    }
    
    public static Map<String, String> getMapValues(List<SelectOption> options)
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
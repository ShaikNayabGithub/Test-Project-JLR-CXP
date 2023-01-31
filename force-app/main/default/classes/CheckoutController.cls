/*** 
Requirement : Checkout Page 
Author : 
Test class: CheckoutControllerTest
Description: Controller class with methods to call different sections from checkout page 

***/

public without sharing class CheckoutController 
{ 

    //start
    public boolean ret{get;set;}
    public Integer checklimit{get;set;}
   
    //end
    public String MyBrand { get; set; }
    public String MyLang { get; set; }
    public String Market { get; set; }
    public List<String> OptionList { get; set; }
    // Trade in value
    public List<SelectOption> Brands {get; set; }
    public List<SelectOption> Models {get; set; }
    public List<SelectOption> Grades { get; set; }
    public List<SelectOption> Years {get; set; } 
    public List<SelectOption> MileageOptions{ get; set; }
    public Integer Brand { get; set; }
    public Integer Model { get; set; } 
    public Integer Grade { get; set; }
    public Integer Year { get; set; }
    public Integer Price { get; set; }
    public Integer Mileage { get; set; }
    public String image { get; set; } // Checkout Img issue
    // Finance Calculation
    public List<SelectOption> RegularDurations { get; set; }
    public List<SelectOption> SmartDuration { get; set; }  
    public Decimal Rate { get; set; }
    public Boolean ShowResult { get;set; } 
    public Decimal DefaultUpRate { get; set; }
    public Integer TradeInPrice { get; set; }
    public String FinanceTradeinPrice { get; set; }
    public String NewVehicleRetailerEmail { get; set; }
    
    //Other
    public Boolean IsAPO { get; set; }
    
    // Reload handling
    public Boolean IsLoggedin { get; set; }
    public Boolean IsReloaded { get; set; }
    public Boolean TradeinDone { get; set; }
    public Boolean FinanceCalculationDone { get; set; }
    public Boolean ReloadRegular { get; set; }
    public Boolean RetailerDone { get; set; }
    public Boolean PaymentDone { get; set; }
    public Boolean PaidDeposit { get; set; }
    public void checkIsReloaded()
    {
        SelectedRetailer = Label.JP_Dummy_Retailer;
        retailerMap = new Map<Id, Account> ([select Id, Brand__c,  NameLocal, Address_Local__c, Record_Sub_Type__c, Name, merchant_id__c, service_id__c, c_udaan_marketarea1__c, c_udaan_marketarea2__c, Email_used_for_Udaan__c from Account where Id =: SelectedRetailer ]);
        if(RetailerMap != null && RetailerMap.containsKey(SelectedRetailer))
        {
            TheRetailer = RetailerMap.get(SelectedRetailer);
           
            RetailerMerchantId = TheRetailer.Merchant_Id__c;
            RetailerServiceId = TheRetailer.Service_Id__c;
        }
        
        SelectedBean = new JUDAAN_ProtoSelectedBean();
        List<User> users = [select Id, AccountId from User where Id = :UserInfo.getUserId()];
        if(users.size() > 0)
        {
            List<Opportunity> theOpps = [select Id, Finance_TradeinValue__c, Retailer__r.BillingState, Retailer_Done__c, Payment_Done__c, Terms_Accepted__c, Description, StageName, Trade_in_vehicle__c, Trade_In_Value__c, Retailer__c, Local_deposit_amount__c , Final_Payment__c, First_Payment__c, Local_vehicle_price__c, Local_total_paid_amount__c, Number_of_bonus__c, Number_of_monthly_payment__c, Local_monthly_Payment_Amount__c, Local_interest_charge__c, Interest_rate__c, Selected_finance_option__c , Local_Bonus_Payment_Amount__c, Local_loan_amount__c, Trade_In_Done__c, SelectedVehicleBean__c,  Finance_Calculation_Done__c from Opportunity where Asset__c = :Vehicle2Show.Id and AccountId = :users[0].AccountId and (StageName = 'Save a Quote' or StageName = 'Pay Deposit')];
            if(theOpps.size() > 0)
            {
                IsReloaded = true;
                Accepted = theOpps[0].Terms_Accepted__c;
                ShowResult = theOpps[0].Trade_In_Done__c;
                TradeinDone = theOpps[0].Trade_In_Done__c;
                FinanceCalculationDone = theOpps[0].Finance_Calculation_Done__c;
                RetailerDone = theOpps[0].Retailer_Done__c;
                PaymentDone = theOpps[0].Payment_Done__c;
                PaidDeposit = theOpps[0].StageName == 'Pay Deposit';
                dto.finance.tradeinvalue = theOpps[0].Trade_In_Value__c == null ? '' : String.valueOf(theOpps[0].Trade_In_Value__c);
                dto.finance.tradeinvehicle = theOpps[0].Trade_in_vehicle__c;
                
                system.debug('---theOpps[0]'+theOpps[0]);
                 system.debug('---Trade_In_Value__c[0]'+theOpps[0].Trade_In_Value__c);
                 
                   system.debug('---SelectedVehicleBean__c [0]'+theOpps[0].SelectedVehicleBean__c );
                
                // Set Trade in value
                if(theOpps[0].SelectedVehicleBean__c != null)
                {
                    SelectedBean = JUDAAN_ProtoSelectedBean.parse(theOpps[0].SelectedVehicleBean__c);
                    
                    Brands = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Brands, system.label.c_select_a_make);
                    Brand = SelectedBean.selectedBrand;
                    BrandMap = JUDAAN_ProtoProccessor.getMapValues(Brands);
                    BrandName = BrandMap.get(Brand); 
                    MileageOptions = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Mileages, system.label.c_select_a_mileage);
                    Mileage = SelectedBean.selectedMileage; 

                    Models = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Models);
                    Model = SelectedBean.selectedModel;
                    ModelMap = JUDAAN_ProtoProccessor.getMapValues(Models);
                    ModelName = ModelMap.get(Model);
                    
                    Grades = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Grades);
                    Grade = SelectedBean.selectedGrade;
                    GradeMap = JUDAAN_ProtoProccessor.getMapValues(Grades);
                    GradeName = GradeMap.get(Grade);
                    
                    Years = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Years);
                    Year = SelectedBean.selectedYear;
                    
                    Vehicles = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Cates);
                    Vehicle = SelectedBean.selectedCate;
                    
                    Colors = JUDAAN_ProtoProccessor.setProtoDropdowns(SelectedBean.Colors);
                    Color = String.valueOf(SelectedBean.selectedColor);
                    //ColorMap = JUDAAN_ProtoProccessor.getMapValues(Colors);
                    ColorMap = JUDAAN_ProtoProccessor.getColorMapValues(Colors);
                    ColorName = ColorMap.get(Color);
                    
                    releaseTradeinBtn();
                    
                    MyVehicle = SelectedBean.myVehicle;
                    cate_id = SelectedBean.cate_id;
                    handle_id = SelectedBean.handle_id;
                    year_num = SelectedBean.year_num;
                    TradeinPrice = SelectedBean.tradeinvalue;
                    if(!String.isBlank(MyVehicle))
                    {
                        ShowTradeinValue = true;
                    }
                }
                
                // Set Finance Calculation 
                if(theOpps[0].Selected_finance_option__c != null)
                { 
                    LoanPrincipal = getIntegerValue(theOpps[0].Local_loan_amount__c);
                    Rate = getDecimalValue(theOpps[0].Interest_rate__c) ;
                    InstallmentsFee = getIntegerValue(theOpps[0].Local_interest_charge__c);
                    PaymentMonthly = getIntegerValue(theOpps[0].Local_monthly_Payment_Amount__c);
                    PaymentPeriod = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                    numOfBonus = getIntegerValue(theOpps[0].Number_of_bonus__c) ;
                    TotalPayments = getIntegerValue(theOpps[0].Local_total_paid_amount__c);
                    TotalPrice = getIntegerValue(theOpps[0].Local_vehicle_price__c);
                    Payment1st = getIntegerValue(theOpps[0].First_Payment__c);
                    PaymentLast =  getIntegerValue(theOpps[0].Final_Payment__c);
                    FinanceTradeinPrice = StringUtil.formatCurrency(getStringValue(theOpps[0].Finance_TradeinValue__c));
                    if(theOpps[0].Selected_finance_option__c == 'Regular Loan')
                    {
                        Decimal fTradeinvalue = theOpps[0].Finance_TradeinValue__c == null ? 0 : theOpps[0].Finance_TradeinValue__c;
                        Decimal regDeposit = getIntegerValue(theOpps[0].Local_deposit_amount__c) - fTradeinvalue;
                        RegularDeposit = StringUtil.formatCurrency(theOpps[0].Local_deposit_amount__c);
                        RegularBonus = StringUtil.formatCurrency(theOpps[0].Local_Bonus_Payment_Amount__c);
                        DownPayment = getIntegerValue(theOpps[0].Local_deposit_amount__c) + getIntegerValue(theOpps[0].Finance_TradeinValue__c);
                        RegularNumOfPayment = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                        RegularTradeinPrice = FinanceTradeinPrice;
                        ShowRegularPlan  = true;
                        ReloadRegular = true;
                        SelectedPlan = '0';
                    }
                    if(theOpps[0].Selected_finance_option__c == 'Smart Ownership')
                    {
                        Decimal fTradeinvalue = theOpps[0].Finance_TradeinValue__c == null ? 0 : theOpps[0].Finance_TradeinValue__c;
                        Decimal sDeposit = getIntegerValue(theOpps[0].Local_deposit_amount__c) - fTradeinvalue;
                        SmartDeposit = StringUtil.formatCurrency(theOpps[0].Local_deposit_amount__c);
                        SmartBonus = StringUtil.formatCurrency(theOpps[0].Local_Bonus_Payment_Amount__c);
                        DownPayment = getIntegerValue(theOpps[0].Local_deposit_amount__c) + getIntegerValue(theOpps[0].Finance_TradeinValue__c);
                        SmartNumOfPayment = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                        SmartTradeinPrice = FinanceTradeinPrice;
                        ShowSmartPlan = true;
                        ReloadRegular = false;
                        SelectedPlan = '1';
                    }
                }
                
                //Set Retailer 
                SelectedRetailer = theOpps[0].Retailer__c;
                if(RetailerMap != null && RetailerMap.containsKey(SelectedRetailer))
                {
                     TheRetailer = RetailerMap.get(SelectedRetailer);
                     RetailerMerchantId = TheRetailer.Merchant_Id__c;
                     RetailerServiceId = TheRetailer.Service_Id__c;
                     dto.retailerEmail = TheRetailer.Email_used_for_Udaan__c;
                     Retailers = new List<Account> { TheRetailer };
                }
                
                dto.retailerid = theOpps[0].Retailer__c;
                Message2Retailer = theOpps[0].Description;
            }
             else
            {
                IsReloaded = false;
                TradeinDone = false;
                FinanceCalculationDone = false;
                RetailerDone = false;
                PaymentDone = false;
            }
            if(!String.isBlank(MyVehicle))
            {
                ShowResult = true;
            }
            if(SelectedPlan == '')
            {
                SelectedPlanName = System.Label.C_No_Finance_Plan;
            }
            else
            {
                SelectedPlanName = SelectedPlan == '0' ? System.Label.REGULAR_LOAN : System.Label.SMART_OWNERSHIP;
            }
        }
    }
    public Integer getIntegerValue(String str)
    {
        return String.isBlank(str) ? 0 : Integer.valueOf(str);
    }
    public Integer getIntegerValue(Decimal dec)
    {
        return dec == null ? 0 : Integer.valueOf(dec);
    }
    public Decimal getDecimalValue(String str)
    {
        return str == null ? 0 : Decimal.valueOf(str);
    } 
    public String getStringValue(Decimal dec)
    {
        return dec == null ? '' : String.valueOf(dec);
    } 
    public void tradeInValueInit()
    {
        Brands = new List<SelectOption>();
        Models = new List<SelectOption>(); 
        Grades = new List<SelectOption>(); 
        Years = new List<SelectOption>();  
        Colors = new List<SelectOption>(); 
        Vehicles = new List<SelectOption>();  
        ShowResult = false;
        Price = 0;
        ShowSubjectiveValue = false;
        TradeInPrice = 0;
        DoEvaluation = false;
        MileageOptions = JUDAANUtil.getMileageOptions();
        TradeinDone = false;
    }
    // Control the current section when loading the page
    public void setPointer()
    {
        Pointer = '2';
        if(RetailerDone)
        {
            Pointer = '5';
        }
        else
        {
            if(!TradeinDone)
            {
                Pointer = '2';
            }
            else if(!FinanceCalculationDone)
            {
                Pointer = '3';
            }
            else if(!RetailerDone)
            {
                Pointer = '4';
            }
            else if(!PaymentDone)
            {
                Pointer = '0';
            }
            else
            {
                Pointer = '0';
            }
        }
    }
    
    public void setDefaultRate()
    {
        String key = Vehicle2Show.Product2.Model_Alternative__c.toUpperCase() + ',' + String.valueOf(SmartNumOfPayment);
        
        system.debug('---key1:' + Vehicle2Show.Product2);
        system.debug('---key1:' + Vehicle2Show.Product2.Model_Alternative__c);
        system.debug('---key1:' + key);
        String theUpRate;
        if(RatesMapping.containsKey(key))
        {
            theUpRate = RatesMapping.get(key);
            UpRate = Decimal.valueOf(theUpRate.remove('%')) / 100;
            system.debug('---up rate:' + UpRate);
            Decimal vehiclePrice = Vehicle2Show.local_price__c == null ? 0 : Vehicle2Show.local_price__c;
            differedCost = Integer.valueOf(vehiclePrice * UpRate / 10000) * 10000;
            TotalPrice = Integer.valueOf(vehiclePrice); 
            DefaultUpRate = 0;
            if(TotalPrice != 0)
            {
                DefaultUpRate = Decimal.valueOf(differedCost * 100).divide(TotalPrice, 4).setScale(2);
            } 
        }
    }
    
    Map<String, String> RatesMapping { get; set; }
    public void financeCalculationInit()
    {
        SelectedPlan = '';
        FinanceCalculationDone = false;
        Rate = JUDAAN_JACCSProccesor.Rate;
        RatesMapping =  new Map<String, String>();
        for(FinanceRates__c frate : [select Id, Name, DefaultRate__c,DefaultRate_APO__c from FinanceRates__c  where NamePlate__c = :Vehicle2Show.Product2.Model_Alternative__c])
        {
             if(JUDAANUtil.getAPOorNot())
            {
                RatesMapping.put(frate.Name, frate.DefaultRate_APO__c);
            }
            else{
                RatesMapping.put(frate.Name, frate.DefaultRate__c);
            }
        }
        Decimal vehiclePrice = Vehicle2Show.local_price__c == null ? 0 : Vehicle2Show.local_price__c;
        TotalPrice = Integer.valueOf(vehiclePrice); 
        ReloadRegular = true;
        RegularDurations = new List<SelectOption>();
        RegularDurations = JUDAAN_JACCSProccesor.setRegularPeriods();

        SmartDuration = new List<SelectOption>();
        SmartDuration = JUDAAN_JACCSProccesor.setSmartPeriods();
        Prefecture = '';
        searchRetailers();
    }
    
    public Boolean ShowCheckPage { get; set; }
    public String Pointer { get; set; }
    public String JSURL { get; set; } 
    public CheckoutController()
    { 
    //start tm
     IsAPO =JUDAANUtil.getAPOorNot();
     ret = JUDAANUtil.payHoldingDepositLimit();
     NewVehicleRetailerEmail ='';
     decimal check=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Reservation_Limit__c ;
     checklimit=check.intValue();

        Accepted = false;
        SelectedRetailer = Label.JP_Dummy_Retailer;
        IsAPO =JUDAANUtil.getAPOorNot();
        JSURL = system.label.c_softbank_token_js;
        String vid = ApexPages.currentPage().getParameters().get('vid');
        MyBrand = ApexPages.currentPage().getParameters().get('brand');
        MyLang = ApexPages.currentPage().getParameters().get('lang');
        Market = JUDAANUtil.getSimpleMarket();
        IsLoggedin = UserInfo.getUserType() == 'Guest' ? false : true;
        if(vid instanceOf ID)
        {
            ShowCheckPage = true;
            dto = new CreateSavedVehicleDto();
            List<User> users = [select Id, FirstName, Username from User where Id = :UserInfo.getUserId()];
            if(users.size() > 0)
            {
                CurrentUser = users[0];
                dto.userId = CurrentUser.Id;
            } 
            dto.finance = new JUDAAN_JACCSProccesor.FinanceWrapper();
            dto.vehicle = new JUDAAN_ProtoProccessor.VehicleWrapper();
            dto.url = '/VehicleSearch';
            dto.brand = MyBrand == 'jaguar' ? 'Jaguar' : 'Land Rover';
            dto.market = Market;
            dto.createSavedVehicle = new CreateSavedQuoteImplByCheckout();
            dto.finance.FinanceCalculationDone = false;
            IsReloaded = false;
            showVehicle(); 
            dto.finance.vehicle = Vehicle2Show.Id;
            tradeInValueInit();        
        }
        else
        {
            ShowCheckPage = false;
        }
    }

    public PageReference setInit()
    {
        getRecords();
        getPrefecureWards();
        financeCalculationInit();
        paymentInit();
        checkIsReloaded();
        // Destination Test
        setPointer();
        return JUDAANUtil.brandCheck();
    } 
    // Trade in value - Get Brands - Step 1
    public Map<Integer, String> BrandMap { get; set; }
    public JUDAAN_ProtoSelectedBean SelectedBean { get; set; }
    public void getBrands()
    {   
        SelectedBean = new JUDAAN_ProtoSelectedBean(); 
        Brands = new List<SelectOption>();
        Brands.add(new SelectOption('',system.label.c_select_a_make));
        BrandMap = new Map<Integer, String>();
        JUDAAN_Brand2Apex obj = JUDAAN_ProtoProccessor.getBrands(); 
        for(JUDAAN_Brand2Apex.Data val : obj.data)
        { 
            if(val.Brand_CD != null)
            {
                Brands.add(new SelectOption(String.valueOf(val.Brand_CD), val.Brand_NAME));
                BrandMap.put(val.Brand_CD, val.Brand_NAME); 
            }
        }  
    }
    
    // Trade in value - Get Models - Step 2
    public Map<Integer, String> ModelMap {get; set; } 
    public String ModelName { get; set; }
    public String BrandName { get; set; }
    public PageReference getModels()
    {
        if(Brand != null)
        { 
            BrandName = BrandMap.get(Brand);
            Models = new List<SelectOption>();
            Models.add(new SelectOption('',system.label.c_select_a_model));
            ModelMap = new Map<Integer, String>();
            JUDAAN_CarType2Apex obj = JUDAAN_ProtoProccessor.getModels(Brand);
            for(JUDAAN_CarType2Apex.Data val : obj.data)
            {
                if(val.CAR_CD != null)
                {
                     Models.add(new SelectOption(String.valueOf(val.CAR_CD), val.CAR_NAME));
                     ModelMap.put(val.car_cd, val.car_name);
                }
            }  
            
        }
        else
        {
            Models = new List<SelectOption>();
            Models.add(new SelectOption('',system.label.c_select_a_model));
        }

        // Clear values
        Grades = new List<SelectOption>();
        Grades.add(new SelectOption('', system.label.c_select_a_grade));

        Years = new List<SelectOption>();
        Years.add(new SelectOption('', system.label.c_select_a_year));

        Vehicles = new List<SelectOption>();
        Vehicles.add(new SelectOption('', system.label.c_select_a_vehicle));

        Colors = new List<SelectOption>();
        Colors.add(new SelectOption('', system.label.c_select_a_color));

        Mileage = null;
        DoEvaluation = false;
        return null;        
    }

    // Trade in value - Get Body styles(Grades) - Step 3
    public Map<Integer, String> GradeMap { get; set; }
    public PageReference getGrades()
    {
        if(Model != null)
        {
            if(ModelMap == null)
            {
                ModelMap = JUDAAN_ProtoProccessor.getMapValues(Models);
            }
            ModelName = ModelMap.get(Model); 
            Grades = new List<SelectOption>();
            Grades.add(new SelectOption('', system.label.c_select_a_grade));
            GradeMap = new Map<Integer, String>();
            JUDAAN_Grade2Apex obj = JUDAAN_ProtoProccessor.getGrades(Model);
            for(JUDAAN_Grade2Apex.Data val : obj.data)
            { 
                if(val.GRade_CD != null)
                {
                    Grades.add(new SelectOption(String.valueOf(val.GRade_CD), val.Grade_NAME));
                    GradeMap.put(val.grade_cd, val.grade_name); 
                }
            }  
        }
        else
        {
            Grades = new List<SelectOption>();
            Grades.add(new SelectOption('', system.label.c_select_a_grade));
        }

        // Clear values
        Years = new List<SelectOption>();
        Years.add(new SelectOption('', system.label.c_select_a_year));

        Vehicles = new List<SelectOption>();
        Vehicles.add(new SelectOption('', system.label.c_select_a_vehicle));

        Colors = new List<SelectOption>();
        Colors.add(new SelectOption('', system.label.c_select_a_color));

        Mileage = null;
        DoEvaluation = false;

        return null;
    }
    
    // Trade in value - Get Years - Step 4
    public String GradeName { get; set; }
    public Boolean NoYear { get; set; }
    public Boolean DoEvaluation { get; set; }
    public PageReference getYears()
    {
        if(Model != null && Grade != null)
        {  
            if(GradeMap == null)
            {
                GradeMap = JUDAAN_ProtoProccessor.getMapValues(Grades);
            }
            GradeName = GradeMap.get(Grade);

            Years = new List<SelectOption>();
            Years.add(new SelectOption('', system.label.c_select_a_year));
            Map<String, String> YearsMap = new Map<String, String>(); 
            JUDAAN_Year2Apex obj = JUDAAN_ProtoProccessor.getYears(Model, Grade);
            NoYear = obj.data.size() > 0 ? false : true;
            if(NoYear)
            {
                TradeinErrorMsg = system.label.c_vehicle_not_exit;
            }
            else
            {
                TradeinErrorMsg = '';
            }
            for(JUDAAN_Year2Apex.Data val : obj.data)
            { 
                if(val.YEAR_NUM != null)
                {
                    YearsMap.put(String.valueOf(val.YEAR_NUM), String.valueOf(val.YEAR_NUM));
                }
            }  

            for(String year : YearsMap.keySet())
            {
                Years.add(new SelectOption(year, YearsMap.get(year)));
            }
            
        }
        
        Year = null;
        // Clear values
        Vehicles = new List<SelectOption>();
        Vehicles.add(new SelectOption('', system.label.c_select_a_vehicle));
        

        Colors = new List<SelectOption>();
        Colors.add(new SelectOption('', system.label.c_select_a_color));
        Color = '';

        Mileage = null;
        DoEvaluation = false;

        return null;
    }

    // Trade in value - Get Vehicle Category  - Step 5
    public List<SelectOption> Vehicles { get; set; }
    public String Vehicle { get; set; }
    public Map<String, String> VehicleMap { get; set; }
    public PageReference getCatID()
    {  
        if(Brand != null && Model != null && Year != null)
        {
            if(ColorMap == null)
            {
                ColorMap = JUDAAN_ProtoProccessor.getColorMapValues(Colors);
            }
            Vehicles = new List<SelectOption>();
            Vehicles.add(new SelectOption('', system.label.c_select_a_vehicle));
            VehicleMap = new Map<String, String>();
            JUDAAN_Category2Apex obj = JUDAAN_ProtoProccessor.getCategories(Brand, Model,Year);
            for(JUDAAN_Category2Apex.Data val : obj.data)
            {
                if(val.grade_cd == Grade)
                { 
                    Vehicles.add(new SelectOption(String.valueOf(val.cat_id) + ',' + String.valueOf(val.year_num) + ',' + String.valueOf(val.handle_id), val.brand_name + ', ' + val.car_name + ', ' + val.grade_name + ', ' + val.handle_name + ', ' + val.drive_name +  ', ' + val.body_name + ', ' + val.exhaust_name +  ', ' + val.door_name + ', ' + val.TEIIN_NAME + ', ' + val.SHIFT_NAME));
                    VehicleMap.put(String.valueOf(val.cat_id) + ',' + String.valueOf(val.year_num) + ',' + String.valueOf(val.handle_id), val.brand_name + ', ' + val.car_name + ', ' + val.grade_name + ', ' + val.handle_name + ', ' + val.drive_name +  ', ' + val.body_name + ', ' + val.exhaust_name +  ', ' + val.door_name + ', ' + val.TEIIN_NAME + ', ' + val.SHIFT_NAME);
                } 
            }

            Colors = new List<SelectOption>();
            Colors.add(new SelectOption('', system.label.c_select_a_color));

            Color = '';
            Mileage = null;
            DoEvaluation = false;
        }
        return null;
    }

    // Trade in value - Get Colors - Step 6
    public List<SelectOption> Colors { get; set; }
    public Map<String, String> ColorMap { get; set; }
    public String ColorName { get; set; }
    public String Color { get; set; }
    public String cate_id { get; set; }
    public String year_num { get; set; }
    public String handle_id { get; set; } 
    public Boolean NoColor { get; set; }
    public String TradeinErrorMsg { get; set; }
    public PageReference getPriceColor()
    {
        if(!String.isBlank(Vehicle))
        {
            List<String> key = Vehicle.split(','); 
            if(key.size() >= 3)
            {
                cate_id = key[0];
                year_num = key[1];
                handle_id = key[2];
                JUDAAN_PriceColor2Apex obj = JUDAAN_ProtoProccessor.getColors(cate_id, year_num, handle_id);
                Colors = new List<SelectOption>();
                Colors.add(new SelectOption('', system.label.c_select_a_color));
                Color = '';
                Mileage = null;
                ColorMap = new Map<String, String>();
                NoColor = obj.data.size() > 0 ? false : true;
                if(NoColor)
                {
                    TradeinErrorMsg = system.label.c_vehicle_not_exit;
                }
                else
                {
                    TradeinErrorMsg = null;
                }
                for(JUDAAN_PriceColor2Apex.Data val : obj.data)
                {

                    if(val.color_id != null)
                    {
                        if(!ColorMap.containsKey(String.valueOf(val.color_id)))
                        {
                            Colors.add(new SelectOption(String.valueOf(val.color_id), String.valueOf(val.color_nm)));
                            ColorMap.put(String.valueOf(val.color_id), val.color_nm);
                        }
                        else
                        {
                            Colors.add(new SelectOption(String.valueOf(val.color_id) + ':', String.valueOf(val.color_nm)));
                            ColorMap.put(String.valueOf(val.color_id) + ':', val.color_nm);
                        }
                    }
                } 
            }
            DoEvaluation = false;
        }    

        return null;
    }
    public PageReference getColorName()
    {
        ColorName = ColorMap.get(Color);
        return null;
    }
    public void releaseTradeinBtn()
    {
        if(!String.isBlank(Color))
        {
            DoEvaluation =true;
        }
        else
        {
            DoEvaluation = false;
        }
    }

    // Trade in value - Get Price - Step 7
    public String MyVehicle { get; set; }
    public PageReference getWholePrice()
    {
        if(ModelMap == null)
        {
            ModelMap = JUDAAN_ProtoProccessor.getMapValues(Models);
        }
        if(GradeMap == null)
        {
            GradeMap = JUDAAN_ProtoProccessor.getMapValues(Grades);
        }
        if(ColorMap == null)
        {
            ColorMap = JUDAAN_ProtoProccessor.getColorMapValues(Colors);
        }
        getColorName();
        JUDAAN_WholePrice2Apex obj = JUDAAN_ProtoProccessor.getPrice(BrandName, cate_id, handle_id, year_num, Color, Mileage);
        if(obj != null)
        {
            TradeInPrice = obj.data[0].PRICE_0 * 1000; 
        }
        else
        {
            TradeInPrice = 0;
        } 
        TradeinDone = true;
        ShowResult = true;
        ShowSubjectiveValue = false;
        ModelName = ModelMap.get(Model);
        GradeName = GradeMap.get(Grade);

        MyVehicle = BrandName + ' ' + ModelName + ' ' + GradeName + ' ' + Year + ' ' + ColorName;
        // Set dto
        vehicle_w = new JUDAAN_ProtoProccessor.VehicleWrapper(BrandName, ModelName, GradeName, String.valueOf(Year), ColorName, Mileage, String.valueOf(TradeinPrice), false); 
        dto.vehicle = vehicle_w;
        return null;
    }
    
    public Boolean ShowSubjectiveValue { get; set; }
    public void setSelectedVehicleBean()
    {
        SelectedBean.Brands = JUDAAN_ProtoProccessor.setSelectedParts(Brands);
        SelectedBean.selectedBrand = Brand;
        
        SelectedBean.Models = JUDAAN_ProtoProccessor.setSelectedParts(Models);
        SelectedBean.selectedModel = Model;
        
        SelectedBean.Grades = JUDAAN_ProtoProccessor.setSelectedParts(Grades);
        SelectedBean.selectedGrade = Grade;
        
        SelectedBean.Years = JUDAAN_ProtoProccessor.setSelectedParts(Years);
        SelectedBean.selectedYear = Year;
        
        SelectedBean.Cates = JUDAAN_ProtoProccessor.setSelectedParts(Vehicles);
        SelectedBean.selectedCate = Vehicle;
        
        SelectedBean.Colors = JUDAAN_ProtoProccessor.setSelectedParts(Colors);
        if(Color != null)
        {
            SelectedBean.selectedColor = getIntegerValue(Color.remove(':'));
        }
        
        SelectedBean.Mileages = JUDAAN_ProtoProccessor.setSelectedParts(MileageOptions);
        SelectedBean.selectedMileage = Mileage;
        
        SelectedBean.myVehicle = MyVehicle;
        SelectedBean.cate_id = cate_id;
        SelectedBean.handle_id = handle_id;
        SelectedBean.year_num = year_num;
        SelectedBean.tradeinvalue = TradeinPrice;
        
        dto.SelectedVehicleBeanStr = JSON.serialize(SelectedBean);
    }
    public void setSubjectiveValue()
    {
        ShowSubjectiveValue = true;
        ShowResult = true;
        Price = 0;
    }
    public Boolean ShowTradeinValue { get; set; }
    public void setDeposit()
    {
        Price = ShowSubjectiveValue ? Price : TradeInPrice;  
        FinanceTradeinPrice = StringUtil.formatCurrency(String.valueOf(Price));
        RegularTradeinPrice = StringUtil.formatCurrency(String.valueOf(Price));
        SmartTradeinPrice = StringUtil.formatCurrency(String.valueOf(Price));
        //TradeinDone = true;
        ShowTradeinValue = true;
        dto.protoTradeinValue = TradeinPrice;
    }  
    
    public void setTradein()
    {
        TradeinDone = true;
        RegularTradeinPrice = '';
        SmartTradeinPrice = '';
    }

    // Finance Calculation
    public Integer RegularNumOfPayment { get; set; }
    public Integer SmartNumOfPayment { get; set; } 
    public String RegularDeposit { get; set; }
    public String SmartDeposit { get; set; } 
    public String RegularBonus { get; set; }
    public String SmartBonus { get; set; }
    public Integer DifferedCost { get; set; }

    // Response
    public Integer LoanPrincipal { get; set; }
    public Integer Payment1st { get; set; }
    public Integer PaymentLast { get; set; }
    public Integer PaymentMonthly { get; set; } 
    public Integer NumOfBonus { get; set; }
    public Integer InstallmentsFee { get; set; }
    public Integer InstallmentsTotal { get; set; }
    public Integer TotalPayments { get; set; }
    public Integer PaymentPeriod { get; set; } 
    public Integer TotalPrice { get; set; }
    
    public String SelectedPlan { get; set; }
    public String SelectedPlanName { get; set; }
    public void setPlan()
    {
        SelectedPlan = ApexPages.currentPage().getParameters().get('plan'); 
        if(SelectedPlan == '')
        {
            SelectedPlanName = System.Label.C_No_Finance_Plan;
        }
        else
        {
            SelectedPlanName = SelectedPlan == '0' ? System.Label.REGULAR_LOAN : System.Label.SMART_OWNERSHIP;
            system.debug('RegularTradeinPrice--'+RegularTradeinPrice +' -- SmartTradeinPrice --'+SmartTradeinPrice );
            Price =  SelectedPlan == '0' && ((RegularTradeinPrice != NULL && RegularTradeinPrice != ''))  ? Integer.valueof(RegularTradeinPrice.remove(',')) :  (SmartTradeinPrice != NULL && SmartTradeinPrice != '') ? Integer.valueof(SmartTradeinPrice.remove(',')) : 0 ;
            
        }
        
        FinanceCalculationDone = true;
    }

    public void skipPlan()
    {
        FinanceCalculationDone = true;
        SelectedPlan = '';        
        price = 0;
    }
    public void setDTOFinance()
    {
        system.debug('----selected plan:' + SelectedPlan);
       
        if(!String.isBlank(SelectedPlan))
        {
            //dto.finance.deposit = SelectedPlan == '0' ? RegularDeposit.remove(',') :  SmartDeposit.remove(',');
            dto.finance.LoanPrincipal  = String.valueOf(loanPrincipal);
            dto.finance.TheRate = String.valueOf(JUDAAN_JACCSProccesor.Rate);
            dto.finance.InstallmentsFee = String.valueOf(installmentsFee);
            dto.finance.PaymentMonthly = String.valueOf(paymentMonthly);
            dto.finance.PaymentPeriod = String.valueOf(paymentPeriod);
           // dto.finance.BonusPayment = SelectedPlan == '0' ? RegularBonus.remove(',') :  SmartBonus.remove(',');
            dto.finance.BonusPeriod = String.valueOf(numOfBonus);
            dto.finance.SelectedPlan = SelectedPlan == '0' ? 'Regular Loan' : 'Smart Ownership';
            dto.finance.TotalPayment = String.valueOf(totalPayments);
            dto.finance.TotalPrice = String.valueOf(TotalPrice);
            dto.finance.Payment1st = String.valueOf(payment1st);
            dto.finance.PaymentLast = String.valueOf(paymentLast);
            dto.finance.Vehicle =Vehicle2Show.Id;
            // Trade in info 
            if(SelectedPlan == '0')
            {
                dto.finance.tradeinvalue = '0';
            }
            if(SelectedPlan == '1')
            {
                dto.finance.tradeinvalue = '0';
            } 
            system.debug('---RegularTradeinPrice'+RegularTradeinPrice); 
            system.debug('---SmartTradeinPrice'+SmartTradeinPrice);           
        }
        else
        {
            dto.finance.SelectedPlan = '';
            dto.finance.Deposit = '';
            dto.finance.LoanPrincipal  = '';
            dto.finance.TheRate = '';
            dto.finance.InstallmentsFee = '';
            dto.finance.PaymentMonthly = '';
            dto.finance.PaymentPeriod = '';
            dto.finance.BonusPayment = '';
            dto.finance.BonusPeriod = '';
            dto.finance.SelectedPlan = '';
            dto.finance.TotalPayment = '';
            dto.finance.TotalPrice = '';
            dto.finance.Payment1st = '';
            dto.finance.PaymentLast = '';
            dto.finance.Vehicle = Vehicle2Show.Id;
            dto.finance.Tradeinvalue = '';
        }
    }

    public String ErrorMsg { get; set; }
    public Boolean ShowError { get; set; }
    
    public Decimal UpRate { get; set; }
    public Decimal BottomRate { get; set; }
    
    public  void Calculate(Integer totalPrice, String plan, Integer numOfPayments, Integer earnestCost, Integer bonusAdditionalCost, Integer differedCost)
    { 
        JUDAAN_JACCSProccesor financeCal = new JUDAAN_JACCSProccesor(); 
        JUDAAN_NormalPrice2Apex fianceDetails = financeCal.doNormalCalculation(totalPrice, plan, numOfPayments, earnestCost, bonusAdditionalCost, differedCost);     
        if(fianceDetails.calcResult == '0')
        {
            ShowError = false;
            ErrorMsg = '';
            TotalPrice = totalPrice;
            LoanPrincipal = fianceDetails.loanPrincipal;
            Payment1st = fianceDetails.payment1st;
            PaymentMonthly = fianceDetails.paymentMonthly;
            NumOfBonus = fianceDetails.numOfBonus;
            InstallmentsFee = fianceDetails.installmentsFee;
            InstallmentsTotal = fianceDetails.installmentsTotal;
            TotalPayments = fianceDetails.totalPayments;
            PaymentPeriod = fianceDetails.paymentPeriod;
            if(plan == '1')
            {
                PaymentLast = fianceDetails.paymentLast;
            }
        }
        else
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + fianceDetails.error);
            ErrorMsg = fianceDetails.error;
            ShowError = true; 
            ApexPages.addMessage(errorMessage);
        } 
    }
    public Boolean ShowRegularPlan { get; set; }
    
    public Integer DownPayment { get; set; }
    public String RegularTradeinPrice { get; set; }
    public void calculateRegular()
    {
        ShowRegularPlan = true;
        DownPayment = getIntegerValue(RegularDeposit.remove(',')) + getIntegerValue(RegularTradeinPrice.remove(',')); 
        Calculate(TotalPrice, '0', RegularNumOfPayment, DownPayment, getIntegerValue(RegularBonus.remove(',')), 0);
        if(String.isBlank(RegularBonus.remove(',')))
        {
            RegularBonus = '0';
        }
    }

    public Boolean ShowSmartPlan { get; set; }
    public String SmartTradeinPrice { get; set; }
    public void calculateSmart()
    {
        ShowSmartPlan = true;
        DownPayment = getIntegerValue(SmartDeposit.remove(',')) + getIntegerValue(SmartTradeinPrice.remove(',')); 
        Calculate(TotalPrice, '1', SmartNumOfPayment, DownPayment, getIntegerValue(SmartBonus.remove(',')), differedCost);
        if(String.isBlank(SmartBonus.remove(',')))
        {
            SmartBonus = '0';
        }
    }
    
    public List<SelectOption> Prefectures { get; set; }
    public String Prefecture { get; set; }
    public List<Account> Retailers { get; set; }
    public String SelectedRetailer { get; set; }
    public void searchRetailers()
    {
        Retailers = new List<Account>();
        String currentBrand = MyBrand == 'jaguar' ? 'Jaguar' : 'Land Rover';
        String recTypeId = [select Id, Name from RecordType where sObjecttype = 'Account' and Name = 'Retailer' limit 1].Id;
        Set<String> selectedPref = new Set<String> { Prefecture2 };
        Set<String> selectedWard = new Set<String> { Ward2 };
        if(!String.isBlank(Prefecture2) && !IsAPO)
        {
            if(!PrefectureWardMapping.containsKey(Prefecture2))
            {
                Retailers = [select Id, Email_used_for_Udaan__c,parentid, Merchant_Id__c, Service_Id__c, NameLocal, Address_Local__c from Account where RecordTypeId = :recTypeId and Record_Sub_Type__c = 'Branded' and Brand__c = :currentBrand and Region_or_Market__c in ('JAPAN', 'JP') and c_udaan_marketarea1__c includes (:Prefecture2)];
            }
            else
            {
                if(!String.isBlank(Ward2))
                {
                    Retailers = [select Id, Email_used_for_Udaan__c, parentid,Merchant_Id__c, Service_Id__c, NameLocal, Address_Local__c from Account where RecordTypeId = :recTypeId and Record_Sub_Type__c = 'Branded' and Brand__c = :currentBrand and Region_or_Market__c in ('JAPAN', 'JP') and c_udaan_marketarea1__c includes (:Prefecture2) and c_udaan_marketarea2__c includes (:Ward2)];
                }
            }
            if(Retailers.size() > 0){
                if(Retailers[0].Parentid!=null && String.valueof(Retailers[0].Parentid)!=''){
                    NewVehicleRetailerEmail =[select id,Email_used_for_Udaan__c from Account WHERE id=:Retailers[0].Parentid limit 1].Email_used_for_Udaan__c;
                }
            }
        }
        else if(IsAPO){
            String vid = ApexPages.currentPage().getParameters().get('vid');
            if(vid instanceOf ID)
            {
                Asset AssetforRetailer= [select Id, AccountId from Asset where Id =:vid]; 
                Retailers = [select Id, Email_used_for_Udaan__c, Merchant_Id__c, Service_Id__c, NameLocal, Address_Local__c from Account where RecordTypeId = :recTypeId and Region_or_Market__c in ('JAPAN', 'JP') and id=: AssetforRetailer.Accountid];
            }
        }

        if(Retailers.size() > 0)
        {
            SelectedRetailer = Retailers[0].Id;
            dto.retailerId = SelectedRetailer; 
            RetailerDone = true;
            TheRetailer = Retailers[0];
            if(NewVehicleRetailerEmail !=null && NewVehicleRetailerEmail !=''){
                dto.retailerEmail=NewVehicleRetailerEmail ;
            }else{
                dto.retailerEmail = TheRetailer.Email_used_for_Udaan__c;
            }
            RetailerMerchantId = TheRetailer.Merchant_Id__c;
            RetailerServiceId = TheRetailer.Service_Id__c;
            Retailers = new List<Account> { Retailers[0] };
        }
        else
        {
            SelectedRetailer = '';
            RetailerDone = false;
        }
    }

    // Payment
    public string Cc_number { get; set; } 
    public string Security_Code { get; set; }
    public Integer Amount { get; set; }
    public List<SelectOption> Cc_Year { get; set; }
    public List<selectOption> Cc_Month { get; set; }
    public String SelectedMonth { get; set; }
    public String SelectedYear { get; set; }
    public String ResultMsg { get; set; }
    public void paymentInit()
    {
        Amount = Integer.valueOf(system.label.c_deposit_amount);
        Cc_number = '';
        SelectedYear = '';
        SelectedMonth = '';
        Security_Code = '';
        Cc_Year =  new List<SelectOption>();
        Cc_Year.add(new SelectOption('', system.label.c_year));
        Cc_Month = new List<SelectOption>();
        Cc_Month.add(new SelectOption('', system.label.c_month));
        String optionValue = '';
        for( Integer i = 1; i <13; i ++ )
        {
            Cc_Month.add(new SelectOption( i < 10 ? '0' + String.valueOf(i) : String.valueOf(i), String.valueOf(i)));
        }
        
        Integer startYear = Date.Today().Year();
        Integer endYear = startYear + Integer.valueOf(system.label.c_year_range);
        for(Integer j = startYear; j < endYear; j ++)
        {
            Cc_Year.add(new SelectOption(String.valueOf(j), String.valueOf(j)));
        }
        PaymentDone = false;
    }
    public String Message2Retailer { get; set; }
    public Boolean ShowPaymentError { get; set; }
    public PageReference doPayment()
    {  
        setRetailer();
        system.debug('---SelectedRetailer'+SelectedRetailer);
        String token = ApexPages.currentPage().getParameters().get('token');
        String tokenKey = ApexPages.currentPage().getParameters().get('tokenKey'); 
        if(SelectedRetailer != null)
        {
            if(TheRetailer != null)
            {
                if(!String.isBlank(VehicleName) && !String.isBlank(VehicleVIN))
                {
                    JUDAAN_SoftbankProccessor p = new JUDAAN_SoftbankProccessor(CurrentUser.Id, VehicleName, VehicleVIN, TheRetailer.Merchant_Id__c, TheRetailer.Service_Id__c, token, tokenKey);
                    string result = p.doPayment();
                    if(JUDAAN_SoftbankProccessor.DoSucceed)
                    {
                        SoftbankTrackingId = JUDAAN_SoftbankProccessor.TheTrackingId;
                        ResultMsg = result; 
                        PaymentDone = true;
                        if(FinanceCalculationDone)
                        {
                            setDTOFinance();
                        }
                        dto.willSend = true;
                        dto.protoTradeinValue = TradeinPrice;
                        dto.finance.tradeinvehicle = MyVehicle;
                        If(Retailers.size()>0){
                            RetailerDone=true;
                        }
                        dto.IsFirst = false; 
                        dto.IsTradeInSave=false;
                        dto.IsPayment=true;
                        dto.sbpsId = SoftbankTrackingId;
                        dto.retailerDone = RetailerDone;
                        dto.paymentDone = PaymentDone;
                        dto.finance.tradeinDone = TradeinDone;
                        dto.finance.financeCalculationDone = FinanceCalculationDone;
                        setSelectedVehicleBean(); 
                        
                        vehicle_w = new JUDAAN_ProtoProccessor.VehicleWrapper(BrandName, ModelName, GradeName, String.valueOf(Year), ColorName, Mileage, String.valueOf(TradeinPrice), false); 
                        dto.vehicle = vehicle_w;
                        
                        dto.createSavedVehicle.create(dto);
                        /*PageReference customerPage = Page.CustomerAccountPage; 
                        if(MyBrand.contains('J'))
                        {
                            MyBrand = MyBrand.replace('J', 'j');
                        }
                        //if(JUDAANUtil.runningInASandbox())
                        //{
                            dto.url += '&market=' + Market;
                        //}
                        customerPage.getParameters().put('market', Market);
                        customerPage.getParameters().put('brand', MyBrand);
                        customerPage.getParameters().put('lang', MyLang);
                        customerPage.setRedirect(true);
                        return  customerPage; */
                        PageReference thankyouPage = Page.ReservationConfirmThankYou;
                        thankyouPage.getParameters().put('market', Market);
                        thankyouPage.getParameters().put('brand', MyBrand);
                        thankyouPage.getParameters().put('lang', MyLang);
                        thankyouPage.getParameters().put('vid', ApexPages.currentPage().getParameters().get('vid'));
                        
                        if(MyBrand.contains('J'))
                        {
                            MyBrand = MyBrand.replace('J', 'j');
                        }
                        thankyouPage.setRedirect(true);
                        return  thankyouPage;
                    }
                    else
                    {
                        ShowPaymentError = true;
                        String code = result.substring(3,5);
                        SBPS_Error_Codes__c error = SBPS_Error_Codes__c.getInstance(code);
                        if(error != null)
                        {
                            ResultMsg = getLabels(error.Description__c);
                        }
                        else
                        {
                            ResultMsg = system.label.c_general_error;
                        }
                        return null;
                    } 
                }
                else
                {
                    ShowPaymentError = true;
                    ResultMsg = system.label.c_general_error;
                    return null;
                }
            }
        } 
        return null;
    } 

    public Asset Vehicle2Show { get; set; }
    public JUDAAN_Campaign__c Camp2Show { get; set; }    
    public Boolean IsJaguar { get; set; }
    public Boolean Accepted { get; set; }
    public String VehicleName { get; set; }
    public String VehicleVIN { get; set; }
    public VehicleWrapper wrapper { get; set; }
    public void getRecords(){
        String assetId = ApexPages.currentPage().getParameters().get('vid');
        List<Asset> assetList = AssetDao.getAssetById(assetId);
        if(assetList.size() != 0){
            JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c();
            List<JUDAAN_Campaign__c> camps = JUDAAN_CampaignDao.getActiveCampaignByProductId(assetList.get(0).Model__c, Market);
            if(camps.size() > 0)
            {   
                camps[0] = new VehicleSingleController().checkCampaign(assetList.get(0), camps);
                campaign = camps[0];
            }
            this.wrapper = new VehicleWrapper(assetList.get(0), campaign);
        }
    }
    public void showVehicle()
    {
        String vid = ApexPages.currentPage().getParameters().get('vid');
        if(vid instanceOf ID)
        {
            Vehicle2Show = [select Id, VIN__c, Reserved__c, Model__r.Name, Account.Email_used_for_Udaan__c, 
                                AccountId, Product2.Name, Brand__r.Name, Status,pictures__c,// added pictures__c for checkout issue 
                                Exterior_Colour__c, Interior_Color__c, Vehicle_Image_L__c, Local_Price__c, Options__c,
                                Product2.Model_Alternative__c, Product2.BodyStyle_Alternative__c, Product2.Specification_Pack_Alternative__c,
                                Product2.Registration_Year_Alternative__c, Product2.Fuel_Type_Alternative__c, Product2.Transmission_Alternative__c,
                                Product2.Engine_Capacity_Alternative__c,Order_Number__c, Product2.Power_Output_Alternative__c, Product2.Wheel_Driven_Alternative__c
                                from Asset where Id =:vid]; 
            if(Vehicle2Show.Options__c != null)
            {
                OptionList = Vehicle2Show.Options__c.split(';');
            }
            else
            {
                OptionList = new List<String>();
            }
            Date myDate = Date.today();
            List<JUDAAN_Campaign__c> camps = JUDAAN_CampaignDAO.getActiveCampaignByProductId(Vehicle2Show.Model__c, Market);
            if(camps.size() > 0)
            {
                camps[0] = new VehicleSingleController().checkCampaign(Vehicle2Show, camps);
                Camp2Show = camps[0];
            }
            else
            {
                Camp2Show = new JUDAAN_Campaign__c();
            }
            IsJaguar = MyBrand == 'jaguar' ? true : false;
            dto.assetId = Vehicle2Show.Id;
            dto.relatedAsset = Vehicle2Show;
            dto.finance.vehicle = Vehicle2Show.Id;
            VehicleName = MyBrand + ' ' + Vehicle2Show.Product2.Model_Alternative__c + Vehicle2Show.Product2.BodyStyle_Alternative__c;
            VehicleVIN = Vehicle2Show.VIN__c;
            // Checkout Image issue starts
            if(JUDAANUtil.getAPOorNot() == true){ // If its APO----
             if(Vehicle2Show.pictures__c!=null){
                    List<string> images = new List<String>();
                    images = Vehicle2Show.pictures__c.split(',');
                    if(!images.isEmpty()){
                        image = images[0];
                    }
                }
            }
            else{ // if Its new vehicle --
                image = Vehicle2Show.Vehicle_Image_L__c;
            }
            // checkout Image issue ends
        }
        else
        {
            Vehicle2Show = new Asset();
            Camp2Show = new JUDAAN_Campaign__C();
        }
    }  
    public String SoftbankTrackingId { get; set; }
    public Account TheRetailer { get; set; }
    public Map<Id, Account> RetailerMap { get; set; }
    public String RetailerMerchantId { get; set; }
    public String RetailerServiceId { get; set; }
    
    public void setRetailer()
    { 
        SelectedRetailer = Label.JP_Dummy_Retailer;
        dto.retailerId = SelectedRetailer; 
        RetailerDone = true;
        retailerMap = new Map<Id, Account> ([select Id, Brand__c,  NameLocal, Address_Local__c, Record_Sub_Type__c, Name, merchant_id__c, service_id__c, c_udaan_marketarea1__c, c_udaan_marketarea2__c, Email_used_for_Udaan__c from Account where Id =: SelectedRetailer ]);
        if(RetailerMap != null && RetailerMap.containsKey(SelectedRetailer))
        {
            TheRetailer = RetailerMap.get(SelectedRetailer);
            dto.retailerEmail = TheRetailer.Email_used_for_Udaan__c;
            RetailerMerchantId = TheRetailer.Merchant_Id__c;
            RetailerServiceId = TheRetailer.Service_Id__c;
        }
        
    } 
    public CreateSavedVehicleDto dto { get; set; }
    public JUDAAN_ProtoProccessor.VehicleWrapper vehicle_w { get; set; } 
    public String FromDeposit { get; set; } 
    public User CurrentUser { get; set; }
    public PageReference saveQuote()
    { 
        setRetailer();
        FromDeposit = ApexPages.currentPage().getParameters().get('fromDeposit');
        PageReference returnPage;
        if(FromDeposit == '1')
        {
            dto.url = '/checkout?vid=' + Vehicle2Show.Id + '&brand=' + MyBrand + '&lang=' + MyLang + '&svid=' + ApexPages.currentPage().getParameters().get('svid');
            dto.willSend = false;
            dto.termsAccepted = true;
            returnPage = Page.Checkout;
            returnPage.getParameters().put('vid', Vehicle2Show.Id);
            returnPage.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
            if(Retailers.size() > 0)
            {
                RetailerDone=true;
            }
        }
        else
        {
            dto.willSend = true;
            if(JUDAANUtil.getAPOorNot() == true)
            {
              dto.url = '/CustomerAccountPage?brand=' + MyBrand + '&lang=' + MyLang;
             returnPage = Page.CustomerAccountPage;  
            }
            else
            {
                dto.url = '/CustomerAccountPage_New?brand=' + MyBrand + '&lang=' + MyLang;
             returnPage = Page.CustomerAccountPage_New;
            }
             
        }
        //if(JUDAANUtil.runningInASandbox())
        //{
            dto.url += '&market=' + Market;
            
        //}
        if(FinanceCalculationDone)
        {
            setDTOFinance();
        }
        if(Retailers.size() > 0)
        {
            dto.retailerId = Retailers[0].Id;
            if(NewVehicleRetailerEmail !=null && NewVehicleRetailerEmail !=''){
                dto.retailerEmail=NewVehicleRetailerEmail ;
            }else{
                dto.retailerEmail = Retailers[0].Email_used_for_Udaan__c;
            }
            RetailerDone=true;
        }
        
        system.debug('---TradeinPrice'+TradeinPrice);
        system.debug('---MyVehicle'+MyVehicle);
        dto.finance.tradeinvehicle = MyVehicle;
        dto.protoTradeInValue = TradeinPrice;
        dto.IsFirst = true; 
        dto.IsPayment=false;
        dto.IsTradeInSave=false;
        dto.finance.message = Message2Retailer; 
        dto.retailerDone = RetailerDone;
        dto.paymentDone = PaymentDone;
        dto.finance.tradeinDone = TradeinDone;
        dto.finance.financeCalculationDone = FinanceCalculationDone;
        setSelectedVehicleBean(); 
        
        vehicle_w = new JUDAAN_ProtoProccessor.VehicleWrapper(BrandName, ModelName, GradeName, String.valueOf(Year), ColorName, Mileage, String.valueOf(TradeinPrice), false); 
        dto.vehicle = vehicle_w;
        
        dto.createSavedVehicle.create(dto);
        returnPage.getParameters().put('brand', MyBrand);
        returnPage.getParameters().put('lang', MyLang);
        returnPage.getParameters().put('market', Market);
        returnPage.setRedirect(true);
        return returnPage;
    }
    public String Level { get; set;}
    public void setURL()
    {
        Level = ApexPages.currentPage().getParameters().get('level');
        if(level == '1')
        {
            dto.url = '/customeraccountpage?brand=' + MyBrand + '&lang=' + MyLang;
            dto.willSend = true;
        }
        if(level == '2')
        {
            dto.url = '/checkout?vid=' + Vehicle2Show.Id + '&brand=' + MyBrand + '&lang=' + MyLang + '&svid=' + ApexPages.currentPage().getParameters().get('svid');
            dto.willSend = false;
            if(Retailers.size() > 0)
            {
                RetailerDone = True;
            }
        }
        //if(JUDAANUtil.runningInASandbox())
        //{
            dto.url += '&market=' + Market;
        //}
        if(FinanceCalculationDone)
        {
            setDTOFinance();
        }
        if(Retailers.size() > 0)
        {
            dto.retailerId = Retailers[0].Id;
            //dto.retailerEmail = Retailers[0].Email_used_for_Udaan__c;
            if(NewVehicleRetailerEmail !=null && NewVehicleRetailerEmail !=''){
                dto.retailerEmail=NewVehicleRetailerEmail ;
            }else{
                dto.retailerEmail = Retailers[0].Email_used_for_Udaan__c;
            }
        }
        
        dto.protoTradeinValue = TradeinPrice;
        dto.finance.tradeinvehicle = MyVehicle;
        dto.IsFirst = true; 
        dto.IsPayment=false;
        dto.IsTradeInSave=false;
        dto.finance.message = Message2Retailer;
        dto.retailerDone = RetailerDone;
        dto.paymentDone = PaymentDone;
        dto.finance.tradeinDone = TradeinDone;
        dto.finance.financeCalculationDone = FinanceCalculationDone;
        setSelectedVehicleBean(); 
    }
    
    public String  getLabels(String labelName)
    {
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelName + '}';
        return String.valueOf(output.value);
    }
    
    public List<SelectOption> Prefectures2 { get; set; }
    public String Prefecture2 { get; set; }
    public List<SelectOption> Wards2 { get; set; }
    public String Ward2 { get; set; }
    public Map<String, List<String>> PrefectureWardMapping { get; set; }
    public void getPrefecureWards()
    {
        ShowWard = false;
        Retailers = new List<Account>();
        String currentBrand = MyBrand == 'jaguar' ? 'Jaguar' : 'Land Rover';
        String recTypeId = [select Id, Name from RecordType where sObjecttype = 'Account' and Name = 'Retailer' limit 1].Id;
        RetailerMap = new Map<Id, Account> ([select Id, Brand__c,  NameLocal, Address_Local__c, Record_Sub_Type__c, Name, merchant_id__c, service_id__c, c_udaan_marketarea1__c, c_udaan_marketarea2__c, Email_used_for_Udaan__c from Account where RecordTypeId = :recTypeId and Record_Sub_Type__c = 'Branded' and Brand__c = :currentBrand and Region_or_Market__c in ('JAPAN', 'JP')]);
        Map<String, String> PrefectureMap = new Map<String, String>();
        PrefectureMap = JUDAANUtil.getPicklistValues('Account', 'c_udaan_marketarea1__c');
        Prefectures2 = new List<SelectOption>();
        Prefectures2.add(new SelectOption('', system.label.SELECT_A_PREFECTURE));
        for(String key : PrefectureMap.keySet())
        {
            Prefectures2.add(new SelectOption(key, PrefectureMap.get(key)));
        }
        Map<String, String> WardMap = new Map<String, String>();
        WardMap = JUDAANUtil.getPicklistValues('Account', 'c_udaan_marketarea2__c');
        Wards2 = new List<SelectOption>();
        Wards = new List<SelectOption>();
        Wards2.add(new SelectOption('', system.label.SELECT_A_WARD));
        for(String key : WardMap.keySet())
        {
            Wards2.add(new SelectOption(key, WardMap.get(key)));
            Wards.add(new SelectOption(key, WardMap.get(key)));
        }
        
        PrefectureWardMapping = new Map<String, List<String>>();
        for(JUDAAN_Prefecture_Ward__c pw : [select Id, Prefecture__c, Ward__c, Name from JUDAAN_Prefecture_Ward__c ORDER BY Name ASC])
        {
            if(!PrefectureWardMapping.containsKey(pw.Prefecture__c))
            {
                PrefectureWardMapping.put(pw.Prefecture__c, new List<String> { pw.Ward__c });
            }
            else
            {
                PrefectureWardMapping.get(pw.Prefecture__c).add(pw.Ward__c);
            }           
        }
        Prefecture2 = '';
        Ward2 = '';
        Message2Retailer = '';
        WardsLabelMap = new Map<String, String>();
        for(SelectOption so : Wards)
        {
            wardsLabelMap.put(so.getValue(), so.getLabel());
        }
    }
    public List<SelectOption> Wards { get; set; }
    public Map<String, String> WardsLabelMap { get; set; }
    public Boolean ShowWard { get; set; }
    public void filterWards()
    {
        Wards2 = new List<SelectOption>();
        Wards2.add(new SelectOption('', system.label.select_a_ward));
        if(PrefectureWardMapping.containsKey(Prefecture2))
        {
            for(String ward : PrefectureWardMapping.get(Prefecture2))
            {   
                if(wardsLabelMap.containsKey(ward))
                {
                    Wards2.add( new SelectOption(ward, WardsLabelMap.get(ward)));
                }
            }
        }
        else
        {
            searchRetailers();
        }
        if(Wards2.size() > 1)
        {
            ShowWard = true;
        }
        else
        {
            ShowWard = false;
        }
    }

    public PageReference goBack()
    {
        PageReference singlePage;
        if(!IsAPO){
            singlePage = Page.VehicleSingle;
            singlePage.getParameters().put('order', Vehicle2Show.Order_Number__c);
        }else{
            singlePage = Page.APOVehicleSingle;
        }
        singlePage.getParameters().put('brand', MyBrand);
        singlePage.getParameters().put('lang', MyLang);
        //if(JUDAANUtil.runningInASandbox())
        //{
            singlePage.getParameters().put('market', Market);
        //}
        singlePage.getParameters().put('id', Vehicle2Show.Id);
        singlePage.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
        singlePage.setRedirect(true);
        return singlePage;
    }
    
    public class VehicleWrapper
    {
        // Asset
        public Asset asset;
        public Id vid {get;set;}
        public String model { get; set; }
        public String image {get;set;}
        public String bodystyle { get; set; }
        public String specification { get; set; }
        public String registration { get; set; }
        public String fuelType { get; set; }
        public String transmission { get; set; }
        public String engine { get; set; }
        public String PowerOutput { get; set; }
        public String drive { get; set; }
        public String option { get; set; }
        public List<String> optionList {get;set;}
        public String extColor { get; set; }
        public String intColor { get; set; }
        public String intImage { get; set; }
        public Decimal price { get; set; }
        public Decimal previousprice{ get; set; }
        public String brand {get; set;}
        public String linkForDetail { get; set; }
        public String linkForUserd {get; set; } 
        public String availability { get; set; }
        
        // Campaign
        public JUDAAN_Campaign__c campaign{get; set;}
        public String campaignEnglish {get; set;}
        public String campaignJapanese {get; set;}
        public String campaignTextUrl {get; set;}
        
        
        public VehicleWrapper(Asset asset, JUDAAN_Campaign__c campaign)
        {
            
            this.asset = asset;
            this.vid = asset.Id;
            this.model = asset.Product2.Model_Alternative__c;
            this.image = asset.Vehicle_Image_L__c;
            this.bodystyle = asset.Product2.BodyStyle_Alternative__c;
            this.specification = asset.Product2.Specification_Pack_Alternative__c;
            if(asset.Product2.Model_Year_Alternative__c != null &&  JUDAANUtil.getAPOorNot() == true)
            this.registration = Label.ManufactureYear + asset.Product2.Model_Year_Alternative__c.right(2);
            else
            {
                if(asset.Product2.Registration_Year_Alternative__c != null && JUDAANUtil.getAPOorNot() == false)
                this.registration= Label.ManufactureYear + asset.Product2.Registration_Year_Alternative__c.right(2);
            }  
            
            this.fuelType = asset.Product2.Fuel_Type_Alternative__c;
            this.transmission = asset.Product2.Transmission_Alternative__c;
            this.engine= asset.Product2.Engine_Capacity_Alternative__c;
            this.PowerOutput= asset.Product2.Power_Output_Alternative__c;
            this.drive = asset.Product2.Wheel_Driven_Alternative__c;
            this.option = asset.Options__c; 
            if(Option != null)
            {
                this.optionList = Option.split(';');
            }else
            {
                this.optionList = new List<String>();
            }
            this.extColor = asset.Exterior_Colour__c;
            this.intColor = asset.Interior_Color__c;
            this.intImage = asset.Vehicle_interior_image_L__c;
            this.price = asset.Local_price__c;
            this.previousprice = asset.Previous_price__c;
            this.brand = asset.product2.Make__r.name;
            this.linkForDetail = asset.Link_for_detail_page_on_DX__c;
            this.linkForUserd = asset.Link_for_used_car_page_on_DX__c;
            
            if(asset.Is_Available_on_Website__c)
            {
                this.availability = Label.Available_Now ;
            }else
            {
                this.availability = Label.Not_Available_Now;
            }
            
            this.campaign = campaign;
            this.campaignEnglish = campaign.EnglishDescription__c;
            this.campaignJapanese = campaign.JapaneseDescription__c;
            this.campaignTextUrl = campaign.Campaign_Url_Text__c;
        }
    }
     
   /* public string ret{get{return holdingDepositLimit();}}
    public string holdingDepositLimit(){
    
    system.debug('inside controller');
    ret = JUDAANUtil.payHoldingDepositLimit();
    return ret;
    
    }*/
}
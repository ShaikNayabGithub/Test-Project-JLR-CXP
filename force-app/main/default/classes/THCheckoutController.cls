/*** 
Requirement : thcheckout Page 
Author : 
Test class: thCheckoutControllerTest
Description: Controller class with methods to call different sections from thcheckout page 

***/

public without sharing class THCheckoutController 
{ 
     //start
    public boolean ret{get;set;}
    public string msg{get;set;}
   
    //end
    public String MyBrand { get; set; }
    public String MyLang { get; set; }
    public List<String> OptionList { get; set; }
    // Trade in value
    public List<SelectOption> Brands {get; set; }
    public List<SelectOption> Models {get; set; }
    public List<SelectOption> Grades { get; set; }
    public List<SelectOption> Years {get; set; } 
    public Integer Brand { get; set; }
    public Integer Model { get; set; } 
    public Integer Grade { get; set; }
    public Integer Year { get; set; }
    public Integer Price { get; set; }
    public String RegistrationStr { get; set; }
    public Integer Mileage { get; set; }
    public String image { get; set; } 
    
    public String Market { get; set; }
    public String Make { get; set; }
    
    // Finance Calculation
    public Set<Integer> REGULAR_OPTIONS = new Set<Integer> {  48 , 60 , 72 , 84 }; 
    public List<SelectOption> RegularDurations { get; set; }
    public Decimal Rate { get; set; }
    public Boolean ShowResult { get;set; } 
    public Integer TradeInPrice { get; set; }
    public Decimal TradeInPriceUppermargin { get; set; }
    public Decimal TradeInPriceLowermargin { get; set; }
    public String FinanceTradeinPrice { get; set; }
    
    // Reload handling
    public Boolean IsLoggedin { get; set; }
    public Boolean IsReloaded { get; set; }
    public Boolean TradeinDone { get; set; }
    public Boolean FinanceCalculationDone { get; set; }
    public Boolean ReloadRegular { get; set; }
    public Boolean RetailerDone { get; set; }
    public Boolean PaymentDone { get; set; }
    public Boolean PaidDeposit { get; set; }

    public Boolean DownPaymentValid { get; set; }
    public Boolean RateValid { get; set; }
    public Boolean isValid { get; set; }
    public void doValidation()
    {
        if(DownPaymentValid & RateValid)
        {
            isValid = true;
        }
        else
        {
            isValid = false;
        }
    }
    public void checkIsReloaded()
    {
        SelectedBean = new SGRedbookSelectedBean();
        List<User> users = [select Id, AccountId from User where Id = :UserInfo.getUserId()];
        system.debug('----Make'+Make);
        if(users.size() > 0)
        {
            List<Opportunity> theOpps = [select Id,Trade_in_Registration_Number__c, Finance_TradeinValue__c, Retailer__r.BillingState, Retailer_Done__c, Payment_Done__c, Terms_Accepted__c, Description, StageName, Trade_in_vehicle__c, Trade_In_Value__c , Retailer__c, Local_deposit_amount__c , Final_Payment__c, First_Payment__c, Local_vehicle_price__c, Local_total_paid_amount__c, Number_of_bonus__c, Number_of_monthly_payment__c, Local_monthly_Payment_Amount__c, Local_interest_charge__c, Interest_rate__c, Selected_finance_option__c , Local_Bonus_Payment_Amount__c, Local_loan_amount__c, Trade_In_Done__c, SelectedVehicleBean__c,  Finance_Calculation_Done__c from Opportunity where Asset__c = :Vehicle2Show.Id and AccountId = :users[0].AccountId and (StageName = 'Save a Quote' or StageName = 'Pay Deposit' or StageName = 'Trade-in Valuation')];
            if(theOpps.size() > 0)
            {
                IsReloaded = true;
                Accepted = theOpps[0].Terms_Accepted__c;
                ShowResult = theOpps[0].Trade_In_Done__c;
                TradeinDone = theOpps[0].Trade_In_Done__c;
                RegistrationStr = theOpps[0].Trade_in_Registration_Number__c;
                FinanceCalculationDone = theOpps[0].Finance_Calculation_Done__c;
                RetailerDone = theOpps[0].Retailer_Done__c;
                PaymentDone = theOpps[0].Payment_Done__c;
                PaidDeposit = theOpps[0].StageName == 'Pay Deposit';
                dto.finance.tradeinvalue = theOpps[0].Trade_In_Value__c  == null ? '' : String.valueOf(theOpps[0].Trade_In_Value__c );
                dto.finance.tradeinvehicle = theOpps[0].Trade_in_vehicle__c;
                // Set Trade in value
                if(theOpps[0].SelectedVehicleBean__c != null)
                {
                    SelectedBean = SGRedbookSelectedBean.parse(theOpps[0].SelectedVehicleBean__c);
                    Brands = SGRedbookProcessor.setDropdowns(SelectedBean.Brands, system.label.c_select_a_make);
                    Make =SelectedBean.selectedBrand;
                    sBrandMap = SGRedbookProcessor.getMapValues(Brands);
                    BrandName = sBrandMap.get(Make); 
                    
                    Mileage = SelectedBean.mileage;
                    if(SelectedBean.price!=null){
                        TradeInPriceUppermargin= SelectedBean.price+(SelectedBean.price*0.05);
                        TradeInPriceLowermargin= SelectedBean.price-(SelectedBean.price*0.05);
                    }

                    Models = SGRedbookProcessor.setDropdowns(SelectedBean.Models);
                    sModel = SelectedBean.selectedModel;
                    sModelMap = SGRedbookProcessor.getMapValues(Models);
                    system.debug('-----SGRedbookProcessor----'+ sModelMap );
                    
                    ModelName = sModelMap.get(sModel);
                    
                     system.debug('-----SelectedBean----'+SelectedBean);
                    Years = SGRedbookProcessor.setDropdowns(SelectedBean.Years);
                    Year = SelectedBean.selectedYear;
                    
                    Vehicles = SGRedbookProcessor.setDropdowns(SelectedBean.Vehicles);
                    Vehicle = SelectedBean.selectedVehicle;
                    
                    releaseTradeinBtn();
                    
                    MyVehicle = SelectedBean.myVehicle;
                    
                    TradeinPrice = SelectedBean.price;
                    if(!String.isBlank(MyVehicle))
                    {
                        ShowTradeinValue = true;
                    }
                }
                
                FinanceTradeinPrice = StringUtil.formatCurrency(getStringValue(theOpps[0].Finance_TradeinValue__c));
                
                // Set Finance Calculation 
                if(theOpps[0].Selected_finance_option__c != null)
                {
                
                   if(theOpps[0].Selected_finance_option__c == 'Hire Purchase')
                    {
                        Decimal fTradeinvalue = theOpps[0].Finance_TradeinValue__c == null ? 0 : theOpps[0].Finance_TradeinValue__c;
                        Decimal regDeposit = getIntegerValue(theOpps[0].Local_deposit_amount__c) - fTradeinvalue;
                        RegularDeposit = StringUtil.formatCurrency(theOpps[0].Local_deposit_amount__c);
                        
                        DownPayment = getIntegerValue(theOpps[0].Local_deposit_amount__c) + getIntegerValue(theOpps[0].Finance_TradeinValue__c);
                        RegularNumOfPayment = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                        RegularTradeinPrice = FinanceTradeinPrice;
                        
                        LoanPrincipal = getIntegerValue(theOpps[0].Local_loan_amount__c);
                        Rate = getDecimalValue(theOpps[0].Interest_rate__c) ;
                        InstallmentsFee = getIntegerValue(theOpps[0].Local_interest_charge__c);
                        PaymentMonthly = getIntegerValue(theOpps[0].Local_monthly_Payment_Amount__c);
                        PaymentPeriod = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                        TotalPayments = getIntegerValue(theOpps[0].Local_total_paid_amount__c);
                        TotalPrice = getIntegerValue(theOpps[0].Local_vehicle_price__c);
                        ShowSmartPlan = true;
                        
                        
                        ReloadRegular = true;
                        SelectedPlan = '0';
                    }
                    if(theOpps[0].Selected_finance_option__c == 'Finance Lease')
                    {
                        Decimal fTradeinvalue = theOpps[0].Finance_TradeinValue__c == null ? 0 : theOpps[0].Finance_TradeinValue__c;
                        Decimal sDeposit = getIntegerValue(theOpps[0].Local_deposit_amount__c) - fTradeinvalue;
                        RegularDepositForFL = StringUtil.formatCurrency(theOpps[0].Local_deposit_amount__c);
                       
                        DownPaymentForFL = getIntegerValue(theOpps[0].Local_deposit_amount__c) + getIntegerValue(theOpps[0].Finance_TradeinValue__c);
                        RegularNumOfPaymentForFL  = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                        RegularTradeinPriceForFL  = FinanceTradeinPrice;
                        
                        LoanPrincipalForFL = getIntegerValue(theOpps[0].Local_loan_amount__c);
                        interestRateForFL = getDecimalValue(theOpps[0].Interest_rate__c) ;
                        InstallmentsFeeForFL = getIntegerValue(theOpps[0].Local_interest_charge__c);
                        PaymentMonthlyForFL = getIntegerValue(theOpps[0].Local_monthly_Payment_Amount__c);
                        PaymentPeriod = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                        TotalPaymentsForFL = getIntegerValue(theOpps[0].Local_total_paid_amount__c);
                        TotalPrice = getIntegerValue(theOpps[0].Local_vehicle_price__c);
                        
                        ShowRegularPlan  = false; 
                        
                        ReloadRegular = false;
                        SelectedPlan = '1';
                    }  
                
                }
                Rate = getDecimalValue(theOpps[0].Interest_rate__c) ;
                Payment1st = getIntegerValue(theOpps[0].First_Payment__c);
                 PaymentLast =  getIntegerValue(theOpps[0].Final_Payment__c);
                // Set Finance Calculation 
              /*  LoanPrincipal = getIntegerValue(theOpps[0].Local_loan_amount__c);
               
                InstallmentsFee = getIntegerValue(theOpps[0].Local_interest_charge__c);
                PaymentMonthly = getIntegerValue(theOpps[0].Local_monthly_Payment_Amount__c);
                PaymentPeriod = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                TotalPayments = getIntegerValue(theOpps[0].Local_total_paid_amount__c);
                TotalPrice = getIntegerValue(theOpps[0].Local_vehicle_price__c);
                Payment1st = getIntegerValue(theOpps[0].First_Payment__c);
                PaymentLast =  getIntegerValue(theOpps[0].Final_Payment__c);
                FinanceTradeinPrice = StringUtil.formatCurrency(getStringValue(theOpps[0].Finance_TradeinValue__c));
                
                Decimal fTradeinvalue = theOpps[0].Finance_TradeinValue__c == null ? 0 : theOpps[0].Finance_TradeinValue__c;
                Decimal regDeposit = getIntegerValue(theOpps[0].Local_deposit_amount__c) - fTradeinvalue;
                RegularDeposit = StringUtil.formatCurrency(theOpps[0].Local_deposit_amount__c);
                DownPayment = getIntegerValue(theOpps[0].Local_deposit_amount__c) + getIntegerValue(theOpps[0].Finance_TradeinValue__c);
                RegularNumOfPayment = getIntegerValue(theOpps[0].Number_of_monthly_payment__c); 
                RegularTradeinPrice = FinanceTradeinPrice;
                
                ShowRegularPlan  = true;
                ReloadRegular = true;
                        
                */
                
                //Set Retailer 
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
            if(!FinanceCalculationDone)
            {
                Decimal vehiclePrice = Vehicle2Show.local_price__c == null ? 0 : Vehicle2Show.local_price__c;
                TotalPrice = Integer.valueOf(vehiclePrice); 
                Decimal rate = Decimal.valueOf(system.label.HK_Min_Downpayment_Rate);
                RegularDeposit = String.valueOf((vehiclePrice * 0.35).round(System.RoundingMode.CEILING));
                system.debug('--RegularDeposit '+RegularDeposit );
                RegularNumOfPayment = 48;
                // Integer.valueOf(system.label.SG_Default_RegularDuration);
                interestRate = 2.6;
                
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
                SelectedPlanName = SelectedPlan == '0' ? 'Hire Purchase' : 'Finance Lease';
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
        Vehicles = new List<SelectOption>();  
        ShowResult = false;
        Price = 0;
        ShowSubjectiveValue = false;
        DoEvaluation = false;
        TradeinDone = false;
    }
    // Control the current section when loading the page
    public void setPointer()
    {
        Pointer = '3';
        if(RetailerDone)
        {
            Pointer = '5';
            system.debug('--Pointer::'+Pointer);
        }
        else
        {
            /*if(!TradeinDone)
            {
                Pointer = '2';
            }*/
            if(!FinanceCalculationDone)
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
            system.debug('--Pointer::'+Pointer);
        }
    }
    
    Map<String, String> RatesMapping { get; set; }
    public string RegularNote { get; set; }
    public string RegularNoteforFL { get; set; }
 
    
    public void financeCalculationInit()
    {
        SelectedPlan = '';
      
            //InterestRateForFL = Decimal.valueOf(system.label.Default_Interest_Rate_HK);
            //InterestRate  = Decimal.valueOf(system.label.Default_Interest_Rate_HK);
            RegularNumOfPaymentforFL = Integer.valueOf(system.label.SG_Default_RegularDuration);
            
            RegularNoteforFL = '';
            RegularNote = '';
            
       
            
        
        FinanceCalculationDone = false;
        SkipFinance = false;
        Decimal vehiclePrice = Vehicle2Show.local_price__c == null ? 0 : Vehicle2Show.local_price__c;
        TotalPrice = Integer.valueOf(vehiclePrice); 
        Decimal rate = Decimal.valueOf(system.label.HK_Min_Downpayment_Rate);
        RegularDeposit = String.valueOf((vehiclePrice * 0.35).round(System.RoundingMode.CEILING));
        System.debug('RegularDeposit :: '+RegularDeposit);
        DownPayment = Integer.valueOf((vehiclePrice *  0.35).round(System.RoundingMode.CEILING));
        downPaymentRate = 35;
        RegularNumOfPayment = Integer.valueOf(system.label.SG_Default_RegularDuration);
        ReloadRegular = true;
        RegularDurations = new List<SelectOption>();
        RegularDurations = setOptions(REGULAR_OPTIONS); // -- Added by RT --
        //List<string> regularList = new List<string>();
        //regularList.addALL( )JUDAAN_JACCSProccesor.setSGRegularPeriods());
        //RegularDurations = RegularDurations.addALL( (list<SelectOption>) regularList);
    }
    
    public Boolean ShowCheckPage { get; set; }
    public String Pointer { get; set; }
    public String JSURL { get; set; } 
    public String CurrencySym{ get; set; }
    public String termsAndCondition{ get; set; }
   
    public THCheckoutController()
    {  
        //start tm
        IsAPO =JUDAANUtil.getAPOorNot();
        ret = JUDAANUtil.payHoldingDepositLimit();
        decimal check=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).Reservation_Limit__c ;
           
        Integer checklimit=check.intValue();
      
        //msg = Label.PAY_HOLDING_DEPOSIT_1 + ' ' +checklimit + ' ' + Label.PAY_HOLDING_DEPOSIT_2;
        msg = Label.PAY_HOLDING_DEPOSIT_1;
        //end tm
        IsSandbox = JUDAANUtil.runningInASandbox();
        MyLang = ApexPages.currentPage().getParameters().get('lang');    
        CurrencySym= JUDAANUtil.getCurrencySymbol();
        IsAPO = JUDAANUtil.IsAPO();
        termsAndCondition = '';
        if(JUDAANUtil.getAPOorNot() == true)
        {
            string customSettingVal=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).TsCs_UsePolicy_APO__c ;
            if(customSettingVal != null)
            {
            string[] label=customSettingVal.split(',');
            for(Integer i=0;i<label.size();i++)
            {
            termsAndCondition=termsAndCondition+JUDAANUtil.getLabels(label[i])+'\n';
            }
            }
        }
        else
        {
            string customSettingVal=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).TsCs_UsePolicy_New__c ;
            string[] label=customSettingVal.split(',');
            for(Integer i=0;i<label.size();i++)
            {
                termsAndCondition=termsAndCondition+JUDAANUtil.getLabels(label[i])+'\n';
            } 
        }
            
        Accepted = false;
        JSURL = system.label.c_softbank_token_js;
        String vid = ApexPages.currentPage().getParameters().get('vid');
        MyBrand = ApexPages.currentPage().getParameters().get('brand');
        Market = JUDAANUtil.getSimpleMarket();
        CurrencySymbol = JUDAANUtil.getCurrencySymbol();
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
            
            //Set Retailer
            dto.retailerId = Vehicle2Show.AccountId;
            dto.retailerEmail = Vehicle2Show.Account.Email_used_for_Udaan__c;
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
        setTermsConditions();
        financeCalculationInit();
        paymentInit();
        checkIsReloaded();
        // Destination Test
        setPointer();
        return JUDAANUtil.brandCheck();
    } 

    public void setTermsConditions()
    {
        termsAndCondition = '';
        if(JUDAANUtil.getAPOorNot() == true)
        {
            string customSettingVal=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).TsCs_UsePolicy_APO__c ;
            if(customSettingVal != null)
            {
            string[] label=customSettingVal.split(',');
            for(Integer i=0;i<label.size();i++)
            {
            termsAndCondition=termsAndCondition+JUDAANUtil.getLabels(label[i])+'\n';
            }
            }
        }
        else
        {
            string customSettingVal=JUDAANMarketSettings__c.getValues(JUDAANUtil.getSimpleMarket()).TsCs_UsePolicy_New__c ;
            string[] label=customSettingVal.split(',');
            for(Integer i=0;i<label.size();i++)
            {
            termsAndCondition=termsAndCondition+JUDAANUtil.getLabels(label[i])+'\n';
            } 
        }
    }
    // Trade in value - Get Brands - Step 1
    public SGRedbookSelectedBean SelectedBean { get; set; }
    public void getBrands()
    {   
        SelectedBean = new SGRedbookSelectedBean(); 
        Brands = new List<SelectOption>();
        Brands.add(new SelectOption('',system.label.c_select_a_make));
        getMakes(); 
    }
    
    // Trade in value - Get Models - Step 2
    public String ModelName { get; set; }
    public String BrandName { get; set; }
    public Boolean DoEvaluation { get; set; }
    
    // Trade in value - Get Vehicle Category  - Step 5
    public List<SelectOption> Vehicles { get; set; }
    public String Vehicle { get; set; }
    public String Color { get; set; }
    public String TradeinErrorMsg { get; set; }
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

    public String MyVehicle { get; set; }
    public Boolean ShowSubjectiveValue { get; set; }
    public void setSelectedVehicleBean()
    {
        SelectedBean.Brands = SGRedbookProcessor.setSelectedParts(Brands);
        SelectedBean.selectedBrand = Make;
        
        SelectedBean.Models = SGRedbookProcessor.setSelectedParts(Models);
        SelectedBean.selectedModel = sModel;
        
        SelectedBean.Years = SGRedbookProcessor.setSelectedParts(Years);
        SelectedBean.selectedYear = Year;
        
        
        SelectedBean.Vehicles = SGRedbookProcessor.setSelectedParts(Vehicles);
        SelectedBean.selectedVehicle = Vehicle;
        
        SelectedBean.mileage = Mileage;
        
        SelectedBean.myVehicle = MyVehicle;
        
        SelectedBean.price= TradeinPrice;
        
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
        //TradeinDone = true;
        ShowTradeinValue = true;
        dto.protoTradeinValue = TradeinPrice;
        saveOppForTradeIn();
    }  
    
    public void setTradein()
    {
        TradeinDone = true;
    }

    // Finance Calculation
    public Integer RegularNumOfPayment { get; set; }
    public String RegularDeposit { get; set; }
    //public String RegularBonus { get; set; }
    public Decimal interestRate { get; set; }
    public Decimal downPaymentRate { get; set; }

    // Response
    public Integer LoanPrincipal { get; set; }
    public Integer Payment1st { get; set; }
    public Integer PaymentLast { get; set; }
    public Integer PaymentMonthly { get; set; } 
    public Integer InstallmentsFee { get; set; }
    public Integer InstallmentsTotal { get; set; }
    public Integer TotalPayments { get; set; }
    public Integer PaymentPeriod { get; set; } 
    public Integer TotalPrice { get; set; }
    public Integer selectedPeriod { get; set; }
    public String SelectedPlan { get; set; }
    public String SelectedPlanName { get; set; }
    public Boolean SkipFinance { get; set; }
    public Decimal SelectedRate { get; set; }
    public void setDownPaymentAmount()
    {
         SelectedRate = Decimal.valueOf(ApexPages.currentPage().getParameters().get('selectedRate'));
         System.debug('SelectedRate :: '+SelectedRate);
         System.debug('TotalPrice :: '+TotalPrice);
         RegularDeposit = String.valueOf(Integer.valueOf(TotalPrice * (SelectedRate/100)));
         System.debug('RegularDeposit :: '+RegularDeposit);
         selectedPeriod  = selectedPeriod == null ? 48 : RegularNumOfPayment;
         setInterestRate();
    }
    public void setInterestRate()
    {
       interestRate = null;
       
        if(selectedPeriod != null)
        {
        system.debug('--selectedRate'+downPaymentRate);
        //SelectedRate  = string.valueof(ApexPages.currentPage().getParameters().get('selectedRate')); 
        /*
             if(selectedPeriod == 48 || selectedPeriod == 36 || selectedPeriod == 24)
            interestRate = Decimal.valueOf(Label.interestRateFor48MonTH);
         else if (selectedPeriod == 60)
            interestRate = Decimal.valueOf(Label.interestRateFor60MonTH);
            else if (selectedPeriod == 72)
            interestRate = Decimal.valueOf(Label.interestRateFor72MonTH);
            else if (selectedPeriod == 84)
            interestRate = Decimal.valueOf(Label.interestRateFor84MonTH);*/
            
           if(downPaymentRate == 20) 
           interestRate =  selectedPeriod == 48 ?    2.90  : selectedPeriod == 60 ? 3.00 : selectedPeriod == 72 ? 3.55 : selectedPeriod == 84 ? 4 : 2.6;
           
           if(downPaymentRate == 25) 
           interestRate =  selectedPeriod == 48 ?    2.80  : selectedPeriod == 60 ? 2.90 : selectedPeriod == 72 ? 3.20 : selectedPeriod == 84 ? 3.90 : 2.6;
           
           if(downPaymentRate == 30) 
           interestRate =  selectedPeriod == 48 ?    2.70  : selectedPeriod == 60 ? 2.80 : selectedPeriod == 72 ? 3.20 : selectedPeriod == 84 ? 3.80 : 2.6;
           
           if(downPaymentRate >= 35 && downPaymentRate <=50) 
           interestRate =  selectedPeriod == 48 ?    2.60  : selectedPeriod == 60 ? 2.70 : selectedPeriod == 72 ? 3.20 : selectedPeriod == 84 ? 3.80 : 2.6;
        }
        
        System.debug('selectedPeriod'+selectedPeriod);
    }
    public void setPlan()
    {
        SelectedPlan = ApexPages.currentPage().getParameters().get('plan'); 
        if(SelectedPlan == '')
        {
            SelectedPlanName = System.Label.C_No_Finance_Plan;
            SkipFinance = true;
        }
        else
        {
            SelectedPlanName = SelectedPlan == '0' ? 'Hire Purchase' : 'Finance Lease';
            SkipFinance = false;
        }
        
        FinanceCalculationDone = true;
        //SkipFinance = false;
    }

    public void skipPlan()
    {
        FinanceCalculationDone = true;
        SkipFinance = true;  
        SelectedPlan = '';  
        ShowRegularPlan = false;
        ShowSmartPlan = false;
               
    }
    public void setDTOFinance()
    {
        if(!SkipFinance)
        {
            SelectedPlanName = SelectedPlan == '0' ? 'Hire Purchase' : 'Finance Lease';
            if( SelectedPlan == '0'){
            dto.finance.deposit =  RegularDeposit.remove(',');
            dto.finance.LoanPrincipal  = String.valueOf(loanPrincipal);
                System.debug('InterestRate :: '+InterestRate);
                 System.debug('Rate :: '+Rate);
            dto.finance.TheRate = String.valueOf(Rate);
            dto.finance.InstallmentsFee = String.valueOf(installmentsFee);
            dto.finance.PaymentMonthly = String.valueOf(paymentMonthly);
            dto.finance.PaymentPeriod = String.valueOf(paymentPeriod);
            dto.finance.SelectedPlan = SelectedPlan == '0' ? 'Hire Purchase' : 'Finance Lease';
            dto.finance.TotalPayment = String.valueOf(totalPayments);
            dto.finance.TotalPrice = String.valueOf(TotalPrice);
            dto.finance.Payment1st = String.valueOf(payment1st);
            dto.finance.PaymentLast = String.valueOf(paymentLast);
            dto.finance.Vehicle =Vehicle2Show.Id;
            // Trade in info 
            //dto.finance.tradeinvalue = String.isBlank(RegularTradeinPrice.remove(',')) ? '' : RegularTradeinPrice.remove(',');
            }
            else{
            
            dto.finance.deposit =  RegularDeposit.remove(',');
            dto.finance.LoanPrincipal  = String.valueOf(loanPrincipalForFL );
            dto.finance.TheRate = String.valueOf(InterestRateForFL);
            dto.finance.InstallmentsFee = String.valueOf(installmentsFeeForFL);
            dto.finance.PaymentMonthly = String.valueOf(paymentMonthlyForFL);
            dto.finance.PaymentPeriod = String.valueOf(paymentPeriod);
            dto.finance.SelectedPlan = SelectedPlan == '0' ? 'Hire Purchase' : 'Finance Lease';
            dto.finance.TotalPayment = String.valueOf(TotalPaymentsForFL);
            dto.finance.TotalPrice = String.valueOf(TotalPrice);
            dto.finance.Payment1st = String.valueOf(payment1st);
            dto.finance.PaymentLast = String.valueOf(paymentLast);
            dto.finance.Vehicle =Vehicle2Show.Id;
            // Trade in info 
            if(RegularTradeinPrice != null && RegularTradeinPrice != '')
            dto.finance.tradeinvalue = String.isBlank(RegularTradeinPrice.remove(',')) ? '' : RegularTradeinPrice.remove(',');
            
            
            
            }
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
            dto.finance.SelectedPlan = '';
            dto.finance.TotalPayment = '';
            dto.finance.TotalPrice = String.valueOf(TotalPrice);
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
    
     
    public Boolean ShowRegularPlan { get; set; }
    
    public Integer DownPayment { get; set; }
    public String RegularTradeinPrice { get; set; }
   
    public String HireorFL{ get; set; }
   
     public string RegularTradeinPriceForFL { get; set; }
      public Integer DownPaymentForFL { get; set; }
       public Integer totalPaymentsForFL { get; set; }
        public Integer installmentsFeeForFL { get; set; }
         public Integer RateForFL { get; set; }
          public Integer paymentMonthlyForFL { get; set; }
           public Integer loanPrincipalForFL { get; set; }
            public string RegularDepositForFL { get; set; }
             public Integer RegularDurationsForFL { get; set; }
              public Decimal interestRateForFL { get; set; }
               public Integer RegularNumOfPaymentForFL{ get; set; }
    public Integer AdvancePayment{ get; set; } 
   public Boolean ShowSmartPlan { get; set; }
     
    public void calculateRegular(){
        try{
       // HireorFL = Apexpages.currentPage().getParameters().get('hirep') != NULL  ? Apexpages.currentPage().getParameters().get('hirep') : Apexpages.currentPage().getParameters().get('fl') ;
        system.debug('Inside  calculateRegular '+RegularDeposit);
        system.debug('Inside  calculateRegular1 '+Integer.valueOf(TotalPrice * Decimal.valueOf(Label.TH_Min_Downpayment_Rate)));
            
        if(interestRate != null)
        {
            if((Integer.valueOf(RegularDeposit.remove(',')) <(TotalPrice * Decimal.valueOf(Label.TH_Min_Downpayment_Rate))) || (Integer.valueOf(RegularDeposit.remove(','))>(TotalPrice * Decimal.valueOf(Label.TH_Max_Downpayment_Rate))))
            {
               ShowSmartPlan = false; 
            }
            else
             ShowSmartPlan = true;
            
             Rate = interestRate ;
            if(RegularDeposit != null && RegularDeposit != '')
             DownPayment = Integer.valueOf(RegularDeposit.remove(',')); 
             system.debug('--TotalPrice --'+TotalPrice );
             system.debug('--RegularDeposit--'+RegularDeposit);
            
            system.debug('--interestRate--'+interestRate);
            
            system.debug('--selectedPeriod--'+selectedPeriod);
            
             selectedPeriod = selectedPeriod == null ? selectedPeriod = 48 : selectedPeriod;
             Decimal paymentMonth = ((((TotalPrice -  Integer.valueOf(RegularDeposit.remove(','))) * (interestRate/100)*(selectedPeriod/12))+(TotalPrice-Integer.valueOf(RegularDeposit.remove(','))))/selectedPeriod);    
             
            paymentMonthly = Integer.valueof(paymentMonth.round(System.RoundingMode.CEILING));
            // totalPayments = ((Integer.valueOf(DownPayment+((TotalPrice-DownPayment)*(interestRate/100)))*(selectedPeriod/12))+(TotalPrice-DownPayment));
             totalPayments = Integer.valueOf(RegularDeposit.remove(',')) + Integer.valueOf(((TotalPrice-Integer.valueOf(RegularDeposit.remove(',')))*(interestRate/100))*(selectedPeriod/12)) + (TotalPrice-Integer.valueOf(RegularDeposit.remove(',')));
            RegularNumOfPayment =  selectedPeriod;
            PaymentPeriod = RegularNumOfPayment;
            LoanPrincipal = TotalPrice - DownPayment;
            InstallmentsFee = LoanPrincipal + ((PaymentMonthly * RegularNumOfPayment) - LoanPrincipal); 
            system.debug('paymentMonthly -----'+paymentMonthly );
             system.debug('totalPayments -----'+totalPayments );
        }
        }catch(Exception e)
        {
            System.debug('Exception caught :: '+e.getStackTraceString());
            System.debug('Exception caught :: '+e.getMessage());
        }
       /* PaymentPeriod = RegularNumOfPayment;
        DownPayment = getIntegerValue(RegularDeposit.remove(',')) + getIntegerValue(RegularTradeinPrice.remove(',')); 
        system.debug('RegularTradeinPrice-----'+RegularTradeinPrice);
        LoanPrincipal = TotalPrice - DownPayment;
        
        system.debug('TotalPrice-----'+TotalPrice);
        system.debug('DownPaymentForFL-----'+DownPayment);
        system.debug('interestRateForFL-----'+interestRate);
        system.debug('RegularNumOfPaymentForFL-----'+RegularNumOfPayment);
        
        
        // Call Finance Calculator Method for calculating monthly installment
        PaymentMonthly=Integer.valueOf(SGFinanceCalculator.getFinanceOffer(TotalPrice,DownPayment,interestRate,RegularNumOfPayment));
        Rate = interestRate ; 
       
        
        InstallmentsFee = LoanPrincipal + ((PaymentMonthly * RegularNumOfPayment) - LoanPrincipal);
        TotalPayments = DownPayment + InstallmentsFee;
        
        system.debug('DownPayment-----'+DownPayment );
        system.debug('InstallmentsFee-----'+InstallmentsFee);*/
         
         
    }
    
    public void calculateFinanceLease(){
       /* HireorFL = Apexpages.currentPage().getParameters().get('hirep') != NULL  ? Apexpages.currentPage().getParameters().get('hirep') : Apexpages.currentPage().getParameters().get('fl') ;
        system.debug('HireorFL -----'+HireorFL );
        
        
        
        ShowRegularPlan = false;
        PaymentPeriod = RegularNumOfPaymentForFL;
        DownPaymentForFL = getIntegerValue(RegularDepositForFL.remove(',')) + getIntegerValue(RegularTradeinPriceForFL.remove(',')); 
        system.debug('RegularTradeinPrice-----'+RegularTradeinPrice);
        loanPrincipalForFL = TotalPrice - DownPaymentForFL;
        
        system.debug('TotalPrice-----'+TotalPrice);
        system.debug('DownPaymentForFL-----'+DownPaymentForFL);
        system.debug('interestRateForFL-----'+interestRateforFL);
        system.debug('RegularNumOfPaymentForFL-----'+RegularNumOfPaymentForFL);
        
        // Call Finance Calculator Method for calculating monthly installment
        paymentMonthlyForFL=Integer.valueOf(SGFinanceCalculator.getFinanceOffer(TotalPrice,DownPaymentForFL,interestRateforFL,RegularNumOfPaymentForFL));
        Rate = interestRateforFL; 
        AdvancePayment = 0;
        
        if(Apexpages.currentPage().getParameters().get('market') == 'th' && HireorFL  == 'fl' ){
          AdvancePayment  =( ( RegularNumOfPayment / 12 )+ 1 )  * paymentMonthlyForFL; 
          installmentsFeeForFL= loanPrincipalForFL + ((paymentMonthlyForFL * RegularNumOfPayment) - DownPaymentForFL )  + AdvancePayment  ;
         
          TotalPaymentsForFL = DownPaymentForFL + installmentsFeeForFL;
            system.debug('LoanPrincipal -----'+LoanPrincipal );
            system.debug('TotalPrice-----'+TotalPrice);
            system.debug('AdvancePayment  -----'+AdvancePayment  );
            system.debug('PaymentMonthly  -----'+paymentMonthlyForFL );
            system.debug('RegularNumOfPayment-----'+RegularNumOfPaymentforFL );
            system.debug('DownPayment  -----'+DownPayment  );
        }
        
        installmentsFeeForFL = paymentMonthlyForFL * RegularNumOfPayment;
        TotalPaymentsForFL = DownPaymentForFL + installmentsFeeForFL;
        
        system.debug('DownPayment-----'+DownPaymentForFL );
        system.debug('InstallmentsFee-----'+InstallmentsFeeForFL);
        */ 
    }
    
    // Payment
    public string Cc_number { get; set; } 
    public string Security_Code { get; set; }
    public Integer Amount { get; set; }
    public String currencySymbol { get; set; }
    public List<SelectOption> Cc_Year { get; set; }
    public List<selectOption> Cc_Month { get; set; }
    public String SelectedMonth { get; set; }
    public String SelectedYear { get; set; }
    public String ResultMsg { get; set; }
    public void paymentInit()
    {
        Amount = Integer.valueOf(system.label.THPaypal_deposit);
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
    public String TrackingID { get; set; }
    
    public Boolean IsSandbox { get; set; }
    public PageReference doPayment()
    {  
        String result = ApexPages.currentPage().getParameters().get('payId');
        system.debug('---result:' + result + '/' + TrackingID);
        List<User> u = UserDao.getUserById(UserInfo.getUserId());
        TrackingId = result;
        ResultMsg = result; 
        PaymentDone = true;
        if(FinanceCalculationDone)
        {
            setDTOFinance();
        }
        dto.willSend = true;
        dto.IsFirst = false; 
        dto.IsPayment = true; 
        dto.IsTradeInSave=false; 
        dto.sbpsId = TrackingID;
        dto.retailerDone = RetailerDone;
        dto.paymentDone = PaymentDone;
        dto.finance.tradeinDone = TradeinDone;
        dto.finance.financeCalculationDone = FinanceCalculationDone;
        setSelectedVehicleBean(); 
        
        vehicle_sg = new SGRedbookProcessor.VehicleWrapper(BrandName, ModelName, Year, Mileage, TradeinPrice,RegistrationStr );
        dto.vehicle_sg = vehicle_sg;
        
        dto.createSavedVehicle.create(dto);
        /*PageReference customerPage = Page.CustomerAccountPage; 
        if(MyBrand.contains('J'))
        {
            MyBrand = MyBrand.replace('J', 'j');
        }
        customerPage.getParameters().put('brand', MyBrand);
        customerPage.getParameters().put('lang', MyLang);
        //if(JUDAANUtil.RunningInAsandbox())
        //{
            customerPage.getParameters().put('market', Market);
        //}
        customerPage.setRedirect(true);
        return  customerPage;*/
        
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
                camps[0] = new VehicleSingleController().checkCampaign(Vehicle2Show, camps);
                campaign = camps[0];
                system.debug('campaign'+campaign);
                Map<string,string> mapAssetIdtoCampaignText  = new Map<string,string>();
                mapAssetIdtoCampaignText   = assetLevelVINCampaign(campaign);
                system.debug('-----mapAssetIdtoCampaignText[0]'+mapAssetIdtoCampaignText);
                campaign.EnglishDescription__c =  mapAssetIdtoCampaignText !=null && !mapAssetIdtoCampaignText.isEmpty() && mapAssetIdtoCampaignText.containsKey(assetList.get(0).VIN__C) ? mapAssetIdtoCampaignText.get(assetList.get(0).VIN__C): campaign.EnglishDescription__c ;    
            }
            this.wrapper = new VehicleWrapper(assetList.get(0), campaign);
        }
    }
    public void showVehicle()
    {
        String vid = ApexPages.currentPage().getParameters().get('vid');
        if(vid instanceOf ID)
        {
            List<Asset> alists = AssetDao.getAssetById(vid);
            Vehicle2Show = alists[0];
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
            
            if(JUDAANUtil.getAPOorNot() == true){ // If its APO----
                VehicleName = MyBrand + ' ' + Vehicle2Show.Product2.Model_Alternative__c + Vehicle2Show.Product2.APO_Body_Style_Alternative__c;
            }
            else{
                VehicleName = MyBrand + ' ' + Vehicle2Show.Product2.Model_Alternative__c + Vehicle2Show.Product2.BodyStyle_Alternative__c;
            }
            VehicleVIN = Vehicle2Show.VIN__c;
        }
        else
        {
            Vehicle2Show = new Asset();
            Camp2Show = new JUDAAN_Campaign__C();
        }
    }  
    public String SoftbankTrackingId { get; set; }
    public CreateSavedVehicleDto dto { get; set; }
    public String FromDeposit { get; set; } 
    public User CurrentUser { get; set; }
    
    public SGRedbookProcessor.VehicleWrapper vehicle_sg { get; set; }
    public void setTradeinDetails()
    {
        if(vehicle_sg == null)
        {
            vehicle_sg = new SGRedbookProcessor.VehicleWrapper(BrandName, ModelName, Year, Mileage, TradeinPrice,RegistrationStr );
            dto.vehicle_sg = vehicle_sg;
        }
    }
    
    public PageReference saveQuote()
    { 
       
        String params = ApexPages.currentPage().getParameters().get('fromDeposit');
        if(params.contains(','))
        {
            RetailerDone = true;
            FromDeposit = params.split(',')[0];
        }
        else
        {
            FromDeposit = params;
        }
        PageReference returnPage;
        if(FromDeposit == '1')
        {
            dto.url = '/thcheckout?vid=' + Vehicle2Show.Id + '&brand=' + MyBrand + '&lang=' + MyLang + '&svid=' + ApexPages.currentPage().getParameters().get('svid');
            dto.willSend = false;
            dto.termsAccepted = true;
            returnPage = Page.thcheckout;
            returnPage.getParameters().put('vid', Vehicle2Show.Id);
            returnPage.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
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
            returnPage.getParameters().put('market', Market);
        //}
        if(FinanceCalculationDone)
        {
            setDTOFinance();
        }
        
        dto.finance.tradeinvehicle = MyVehicle;
        dto.protoTradeInValue = TradeinPrice;
        dto.IsFirst = true; 
        dto.IsPayment = false; 
        dto.IsTradeInSave=false;
        dto.finance.message = Message2Retailer; 
        dto.summaryNotes = RegularNoteforFL != null ? RegularNoteforFL : RegularNote;
        dto.retailerDone = RetailerDone;
        dto.paymentDone = PaymentDone;
        dto.finance.tradeinDone = TradeinDone;
        dto.finance.financeCalculationDone = FinanceCalculationDone;
        setSelectedVehicleBean(); 
        system.debug('---finance in save quote:' + dto.finance);
        
        setTradeinDetails();
        
        dto.createSavedVehicle.create(dto);
        returnPage.getParameters().put('brand', MyBrand);
        returnPage.getParameters().put('lang', MyLang);
        returnPage.setRedirect(true);
        return returnPage;
    }
    public String Level { get; set;}
    public void setURL()
    {
        String params = ApexPages.currentPage().getParameters().get('level');
        if(params.contains(','))
        {
            RetailerDone = true;
            Level = params.split(',')[0];
        }
        else
        {
            Level = params;
        }
        system.debug('---level:' + Level);
        
        if(level == '1')
        {
            dto.url = '/customeraccountpage?brand=' + MyBrand + '&lang=' + MyLang;
            dto.willSend = true;
            
        }
        if(level == '2')
        {
            dto.url = '/thcheckout?vid=' + Vehicle2Show.Id + '&brand=' + MyBrand + '&lang=' + MyLang + '&svid=' + ApexPages.currentPage().getParameters().get('svid');
            dto.willSend = false;
        }
        //if(JUDAANUtil.runningInASandbox())
        //{
            dto.url += '&market=' + Market;
        //}
        if(FinanceCalculationDone)
        {
            setDTOFinance();
        }
        dto.protoTradeinValue = TradeinPrice;
        dto.finance.tradeinvehicle = MyVehicle;
        dto.IsFirst = true; 
        dto.IsPayment = false; 
        dto.IsTradeInSave=false;
        dto.summaryNotes  = 
        dto.finance.message = Message2Retailer;
        dto.retailerDone = RetailerDone;
        dto.paymentDone = PaymentDone;
        dto.finance.tradeinDone = TradeinDone;
        dto.finance.financeCalculationDone = FinanceCalculationDone;
        setSelectedVehicleBean(); 
    }
     public void setURLForLogin()
    {
        String params = ApexPages.currentPage().getParameters().get('level');
        dto.url = '/thcheckout?vid=' + Vehicle2Show.Id + '&brand=' + MyBrand + '&lang=' + MyLang + '&svid=' + ApexPages.currentPage().getParameters().get('svid');
        dto.url += '&market=' + Market;
        dto.IsFirst = false; 
        dto.IsPayment = false; 
        dto.IsTradeInSave=false;
    }
   public Boolean IsAPO { get; set; }
   public PageReference goBack()
    {
        PageReference singlePage;
        if(JUDAANUtil.IsAPO())
        {
            singlePage = Page.APOVehicleSingle;
        }
        else
        {
            singlePage = Page.VehicleSingle;
            singlePage.getParameters().put('order',  Vehicle2Show.Order_Number__c);
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
        public Decimal previousprice  { get; set; }
        public String brand {get; set;}
        public String linkForDetail { get; set; }
        public String linkForUserd {get; set; } 
        public String availability { get; set; }
        public String localretailerName { get; set; }
        public String localretailerAdd { get; set; }
        
        // Campaign
        public JUDAAN_Campaign__c campaign{get; set;}
        public String campaignEnglish {get; set;}
        public String campaignJapanese {get; set;}
        public String campaignTextUrl { get; set; }
        
        public VehicleWrapper(Asset asset, JUDAAN_Campaign__c campaign)
        {
            this.asset = asset;
            this.vid = asset.Id;
            this.model = asset.Product2.Model_Alternative__c;
            this.image = asset.Vehicle_Image_L__c;
            if(JUDAANUtil.getAPOorNot() == true){ // --If its APO----
                this.bodystyle = asset.Product2.APO_Body_Style_Alternative__c;
            }
            else{
                this.bodystyle = asset.Product2.BodyStyle_Alternative__c;
            }
            
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
            
            system.debug('testing @@@ '+asset.Account.NameLocal);
            system.debug('testing @@@ '+asset.Account.Address_Local__c);
            system.debug('testing @@@ '+asset.Account);
            this.localretailerName=asset.Account.NameLocal;
            this.localretailerAdd=asset.Account.Address_Local__c;
        }
    }
    
    public Map<String, String> sBrandMap { get; set; }
    public void getMakes()
    {
        sBrandMap = SGRedbookProcessor.getMakes();
        for(String code : sBrandMap.keySet())
        {
            Brands.add(new SelectOption(code, sBrandMap.get(code)));
        }
        TradeinErrorMsg = SGRedbookProcessor.ErrorMsg;
    }
    
    public String sModel { get; set;}
    public String sType { get; set; }
    public Map<String, String> modelTypes { get; set; }
    public Map<String, String> sModelMap {get; set; }
    public PageReference getModels()
    {
        Models = new List<SelectOption>();
        Models.add(new SelectOption('',system.label.c_select_a_model));
        sModelMap = new Map<String, String>();
        modelTypes = new Map<String, String>();
        List<String> modelsStr = SGRedbookProcessor.getModels(Make);
        for(String model : modelsStr)
        {
            List<String> detail = model.split(',');
            sModelMap.put(detail[0], detail[2]);
            Models.add(new SelectOption(detail[0], detail[2]));
            modelTypes.put(detail[0], detail[1]);
        }
        TradeinErrorMsg = SGRedbookProcessor.ErrorMsg;
        BrandName = sBrandMap.get(Make);
        return null;
    }
    
    public PageReference getYears()
    {
        Years = new List<SelectOption>();
        Years.add(new SelectOption('', system.label.c_select_a_year));
        Year = null;
        Set<String> yearsList = new Set<String>();
        yearsList = SGRedbookProcessor.getYears(Make, sModel, modelTypes.get(sModel));
        for(String year : yearsList)
        {
            Years.add(new SelectOption(year, year));
        }
        TradeinErrorMsg = SGRedbookProcessor.ErrorMsg;
        ModelName = sModelMap.get(sModel);
        return null;
    }
    
    public PageReference getVehicles()
    {
        Vehicles = new List<SelectOption>();
        Vehicles.add(new SelectOption('', system.label.c_select_a_vehicle));
        DoEvaluation = true;
        
        Map<String, String> vehicleMap = new Map<String, String>();
        vehicleMap = SGRedbookProcessor.getVehicles(Make, sModel, modelTypes.get(sModel), Year);
        for(String vehicle : vehicleMap.keySet())
        {
            Vehicles.add(new SelectOption(vehicle, vehicleMap.get(vehicle)));
        }
        
        system.debug('---vehicles:' + Vehicles);
        TradeinErrorMsg = SGRedbookProcessor.ErrorMsg;
        return null;
    }
    public PageReference getTradeinPrice()
    {
        if(!hasError())
        {
            TradeinDone = true;
            TradeinPrice = SGRedbookProcessor.getPrice(Vehicle, BrandName, ModelName, Mileage,Year);
            TradeInPriceUpperMargin=TradeinPrice+(TradeinPrice*0.05);
            TradeInPriceLowerMargin=TradeinPrice-(TradeinPrice*0.05);
            MyVehicle = BrandName + ' ' + ModelName + ' '  + Year ;             
            system.debug('---price:' + TradeinPrice);
            system.debug('---e1:' + TradeinErrorMsg );
            TradeinErrorMsg = SGRedbookProcessor.ErrorMsg;
            system.debug('---e2:' + TradeinErrorMsg );
            ShowResult = true;
            ShowSubjectiveValue = false;
            
        }
        else
        {
            ShowResult = false;
        }
        
        return null;
    }
    
    public Boolean hasError()
    {
        system.debug('---make:' + make + sModel + Year);
        if(String.isBlank(make))
        {
            TradeinErrorMsg = system.label.SG_Select_Make;
        }
        else if(String.isBlank(sModel))
        {
            TradeinErrorMsg = system.label.SG_Select_Model;
        }
        else if(Year == null)
        {
            TradeinErrorMsg = system.label.SG_Select_Year;
        }
        else if(String.isBlank(Vehicle))
        {
            TradeinErrorMsg = system.label.SG_Select_Vehicle;
        }
        else if(Mileage == 0)
        {
            TradeinErrorMsg = system.label.SG_Input_Mileage;
        }
        else
        {
            TradeinErrorMsg = null;
        }
        return String.isBlank(TradeinErrorMsg) ? false : true;
    }
    public PageReference saveOppForTradeIn()
    { 
        
        PageReference returnPage;
   
            dto.url = '/thcheckout?vid=' + Vehicle2Show.Id + '&brand=' + MyBrand + '&lang=' + MyLang + '&svid=' + ApexPages.currentPage().getParameters().get('svid');
            dto.willSend = false;
            dto.termsAccepted = true;
            returnPage = Page.thcheckout;
            returnPage.getParameters().put('vid', Vehicle2Show.Id);
            returnPage.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));
       
        //if(JUDAANUtil.runningInASandbox())
        //{
            dto.url += '&market=' + Market;
            returnPage.getParameters().put('market', Market);
        //}
        if(FinanceCalculationDone)
        {
            setDTOFinance();
        }
        
        dto.finance.tradeinvehicle = MyVehicle;
        dto.protoTradeInValue = TradeinPrice;
        dto.IsFirst = false; 
        dto.IsPayment = false; 
        dto.IsTradeInSave=true;
        dto.finance.message = Message2Retailer; 
        dto.retailerDone = RetailerDone;
        dto.paymentDone = PaymentDone;
        dto.finance.tradeinDone = TradeinDone;
        dto.finance.financeCalculationDone = FinanceCalculationDone;
        setSelectedVehicleBean(); 
        system.debug('---finance in save quote:' + dto.finance);
        
        setTradeinDetails();
        
        dto.createSavedVehicle.create(dto);
        returnPage.getParameters().put('brand', MyBrand);
        returnPage.getParameters().put('lang', MyLang);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    public Map<string,string> assetLevelVINCampaign(JUDAAN_Campaign__c campaign){
     
      Map<string,string> mapAssetIdtoCampaignText = new Map<string,string>();
                                
        List<String> lstcampaignText = new List<string>();
        
        
        if(campaign.VIN_Asset_Level_ID__c != null ){
         
            List<String> lstAssetID =   campaign.VIN_Asset_Level_ID__c.contains(',') ? campaign.VIN_Asset_Level_ID__c.split(',') : new List<string> {campaign.VIN_Asset_Level_ID__c} ;
            
                if(lstAssetID != null ){
                lstcampaignText = campaign.VIN_Level_Campaign_Text__c.contains(',') ? campaign.VIN_Level_Campaign_Text__c.split(',') : new List<string>{campaign.VIN_Level_Campaign_Text__c};
                
                    if(lstcampaignText != null)
                    for(Integer j= lstAssetID.size()-1; j>= 0 ; j--){
                       String strassetid =  lstAssetID[j];
                        String strCampaignText =  lstcampaignText.size()== 1 ? lstcampaignText[0] :lstcampaignText[j];
                        mapAssetIdtoCampaignText.put(strassetid,strCampaignText );
                        
                    }
                return mapAssetIdtoCampaignText;
                
                }
            
            
        }
        return null;
     }
     
      public static List<SelectOption> setOptions(Set<Integer> options)
    {
        List<SelectOption> selectList = new List<SelectOption>();
        selectList.add(new SelectOption('', system.label.c_select_duration));
        for(Integer option : options)
        {
            selectList.add(new SelectOption(String.valueOf(option), String.valueOf(option)));
        }
        return selectList;
    }
}
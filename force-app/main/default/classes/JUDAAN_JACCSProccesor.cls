public without sharing class JUDAAN_JACCSProccesor
{ 
    public  String message {get; set; }
    public  String err {get; set; }
    public  String rawResponse {get; set; }
    
    public String ErrorMsg { get; set; }
    public String RequestId { get; set; }
    public String PlanId { get; set; } 
    public String  RegistrationMonth { get; set; } 
    public static Integer BONUS_MONTH1 = 6;
    public static Integer BONUS_MONTH2 = 12;
    public static Integer BonusAdditionalCost = 0;
    public static Decimal Rate= getRate();
    public static Decimal getRATE()  {
        Decimal LocalRate;
        if(JUDAANUtil.getAPOorNot())
        {
            LocalRate=Decimal.valueOf(system.label.c_apofinancerate);
        }
        else{
            LocalRate=Decimal.valueOf(system.label.c_finance_rate);
        }
        return LocalRate;
    } 
    public static Set<Integer> REGULAR_OPTIONS = new Set<Integer> { 6 , 10 , 12 , 18 , 20 , 24 , 30 , 36 , 42 , 48 , 54 , 60 , 66 , 72 , 78 , 84 };
    public static Set<Integer> SMART_OPTIONS = new Set<Integer> { 37, 49, 61};
    public static Set<Integer> SG_REGULAR_OPTIONS = new Set<Integer> { 12 , 24 , 36 , 48 , 60 , 72 , 84 };  // -- Added by RT ----
    public static Set<Integer> TH_REGULAR_OPTIONS = new Set<Integer> {  48 , 60 };
	
    public JUDAAN_JACCSProccesor()
    { 
        // Time format: 2017-08-09 hh:mm:ss -> 20170809hhmmss
        RequestId = String.valueOf(Datetime.now()).remove('-').remove(':').remove(' '); 
        // Set to Next Month: 201708 -> 210709
        RegistrationMonth = String.valueOf(Date.today().addDays(32)).substring(0,7).remove('-'); 
    
    }

    // Used in the Setmybudget on VehicleSelector Page
    public Integer doBackCalculation(Integer numOfPayments, Integer splitPayment, Integer earnestCost, Integer tradeinValue)
    {
        String endpointUrl = Label.JACCS_BACK_API_URL;
        Integer downPayment = earnestCost + tradeinValue;
        numOfPayments = numOfPayments == null ? 60 : numOfPayments;
        splitPayment = splitPayment == null ? 0 : splitPayment;
        earnestCost = earnestCost == null ? 0 : earnestCost;
        tradeinValue  = tradeinValue == null ? 0 : tradeinValue;
        String body = 'requestid=' + RequestId + '&planId=0' + '&rate=' + Rate;
                body += '&numOfPayments=' + numOfPayments + '&splitPayment=' + splitPayment + '&earnestCost=' + downPayment;
                body += '&registrationMonth=' +  registrationMonth +  '&bonusMonth1=' + BONUS_MONTH1 + '&bonusMonth2=' + BONUS_MONTH2 + '&bonusAdditionalCost=' + bonusAdditionalCost;
   
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl, 'POST', body); 
        HttpResponse res = JUDAANHttpServiceUtil.send(req);        
        String backpriceJson = res.getBody(); 
        JUDAAN_BackPrice2Apex obj = JUDAAN_BackPrice2Apex.parse(backpriceJson);
        if(obj.calcResult == '0')
        { 
          return obj.backPrice;
        }
        else
        {
          ErrorMsg = obj.error;
          return -1;
        } 
    }

    // Used in the finance simulation on the Checkout page
    public JUDAAN_NormalPrice2Apex doNormalCalculation(Integer totalPrice, String planId2, Integer numOfPayments, Integer earnestCost, Integer bonusAdditionalCost, Integer differedCost)
    {  
        String endpointUrl = Label.JACCS_NORMAL_API_URL; 
        String body = 'requestid=' + RequestId + '&planId=' + planId2 + '&totalPrice=' + totalPrice + '&rate=' + Rate;
                 body += '&numOfPayments=' + numOfPayments + '&monthlyPayment=0' +  '&earnestCost=' + earnestCost;
                 body += '&registrationMonth=' +  registrationMonth +  '&bonusMonth1=' + BONUS_MONTH1 + '&bonusMonth2=' + BONUS_MONTH2 + '&bonusAdditionalCost=' + bonusAdditionalCost; 
        if(planId2 == '1')
        {
          body += '&differedCost=' + differedCost;
        }
        
        HttpRequest req = JUDAANHttpServiceUtil.getRequest(endpointUrl, 'POST', body); 
        HttpResponse res = JUDAANHttpServiceUtil.send(req);    
        String jsonStr = res.getBody(); 
        JUDAAN_NormalPrice2Apex obj = JUDAAN_NormalPrice2Apex.parse(jsonStr);
        return obj;
    } 

    public without sharing class FinanceWrapper
    {
        public string Deposit { get; set; }
        public string LoanPrincipal { get; set; }
        public string TheRate { get; set; }
        public string InstallmentsFee { get; set; }
        public string PaymentMonthly { get; set; }
        public string PaymentPeriod { get; set; }
        public string BonusPayment { get; set; }
        public string BonusPeriod { get; set; }
        public string SelectedPlan { get; set; }
        public string TotalPayment { get; set; }
        public string TotalPrice { get; set; }
        public string Payment1st { get; set; }
        public string PaymentLast { get; set; }
        public string vehicle { get; set; }
        public string TradeinValue { get; set; }
        public string TradeinVehicle { get; set; }
        public string Message { get; set; }
        public string FinanceTradeinValue { get; set; }
        public Boolean TradeinDone { get; set; }
        public Boolean FinanceCalculationDone { get; set; }
        public FinanceWrapper() {}
        public FinanceWrapper(string deposit, string financeTradeinValue, string loanPrincipal, string theRate, string installmentFee, string paymentMonthly, string paymentPeriod, string bonusPayment, string bonusPeriod, string selectedPlan, string totalPayment, string totalPrice, string payment1st, string paymentLast, string vehicle, string tradeinvalue, string tradeinvehicle, Boolean done)    
        {
            this.Deposit = deposit;
            this.FinanceTradeinValue = financeTradeinValue;
            this.LoanPrincipal = loanPrincipal;
            this.TheRate = theRate;
            this.InstallmentsFee = installmentFee;
            this.PaymentMonthly = paymentMonthly;
            this.PaymentPeriod = paymentPeriod;
            this.BonusPayment = bonusPayment;
            this.BonusPeriod = bonusPeriod;
            this.SelectedPlan = selectedPlan;
            this.TotalPayment = totalPayment;
            this.TotalPrice = totalPrice;
            this.vehicle = vehicle;
            this.TradeinValue = tradeinvalue;
            this.TradeinVehicle = tradeinVehicle;
        }
    }

    public static List<SelectOption> setRegularPeriods()
    {
        return setOptions(REGULAR_OPTIONS);
    }
    
    // -- Added by RT ----
    /* **************************************************
    Method Name: setRegularPeriods
    Input Parameters: NA
    Return Type: List<SelectOption> (list of month interval)
    Method Description: Method to set month interval values for Singapore 
                        in a list drop down to be displayed on page
    ****************************************************** */  
     public static List<SelectOption> setSGRegularPeriods() {
        return setOptions(SG_REGULAR_OPTIONS);
    }
    // -- Ends here ---
	/* **************************************************
    Method Name: setRegularPeriods
    Input Parameters: NA
    Return Type: List<SelectOption> (list of month interval)
    Method Description: Method to set month interval values for Thailand 
                        in a list drop down to be displayed on page
    ****************************************************** */  
     public static List<SelectOption> setTHRegularPeriods() {
        return setOptions(TH_REGULAR_OPTIONS);
    }
    // -- Ends here ---

    public static List<SelectOption> setSmartPeriods()
    {
        return setOptions(SMART_OPTIONS);
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
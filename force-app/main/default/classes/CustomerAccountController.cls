/*** 
Requirement : CustomerAccount 
Description: 
Apply To: JPN
Author : TCS TEAM
Test class: 
Create Date: 28/7/2017 
Description: Controller class with methods to call all the three pages: Reservation, Save Quote and Save Vehicle
***/ 
public class CustomerAccountController {

    public User loginUser{get; set;}
    public List<ReservationWrapper> listWrap {get; set;}
    public List<ReservationWrapper> listPreOwnedWrap {get; set;}
    public List<QuoteWrapper> listQuoteWrapper {get;set;}
    public List<QuoteWrapper> listPreOwnedQuoteWrapper {get;set;}
    public List<SaveVehicleWrapper> listSaveVehicleWrapper {get;set;}
    public List<SaveVehicleWrapper> listPreOwnedSaveVehicleWrapper {get;set;}
    public Integer foundCount {get;set;}
    public Integer foundCountForTickedIcon {get;set;}
    public Integer foundCountAPO {get;set;}
    public Integer foundCountForReserved {get;set;}
    public Integer foundCountForReservedAPO {get;set;}
    public Integer foundCountForQuote {get;set;}
    public Integer foundCountForQuoteAPO {get;set;}
    public String brand {get; set;}
    public String language {get; set;}
    public String market { get; set; }
    public CreateSavedVehicleDto dto {get; set;}
    public String brandForSearch;
    public String CurrencySym{ get; set; }
    public string marketEmail {get;set;}

    // Component Variables 
    public CustomerAccountController(){
        CurrencySym = JUDAANUtil.getCurrencySymbol();
        this.brand = ApexPages.currentPage().getParameters().get('brand');
        if(this.brand == 'jaguar' ){
            this.brandForSearch = 'Jaguar';
        }else{
            this.brandForSearch = 'Land Rover';
        }
        
        if(ApexPages.CurrentPage().getParameters().containsKey('lang')){
            this.language = ApexPages.CurrentPage().getParameters().get('lang');
        }else{
            this.language =System.label.DEFAULT_LANGUAGE;
        }
        
        if(this.language != 'ja' && this.language != 'en' && this.language != 'pt_BR'){
            this.language = System.label.DEFAULT_LANGUAGE;
        }
        
        this.market = JUDAANUtil.getSimpleMarket();
        
        this.dto = new CreateSavedVehicleDto();
        // Logic added to set marketEmail 
        JUDAANMarketSettings__c objmarketSett = JUDAANMarketSettings__c.getValues(ApexPages.currentPage().getParameters().get('market'));
        if(objmarketSett != null) {
            marketEmail =  ApexPages.currentPage().getParameters().get('brand') == 'jaguar' ? objmarketSett.JG_Email__c : objmarketSett.Land_Email__c;
        }        
        system.debug('## marketEmail ' + marketEmail);
    }
    
    //HANDLER METHOD
    public PageReference getRecords(){
        this.getLoginUser();
        if(this.loginUser != null || Test.isRunningTest()){
            this.getSavedVehicle();
            this.getQuote();
            this.getReserve();
        }
        return JUDAANUtil.brandCheck();
    }
    
    private void getLoginUser(){
        List<User> uList = UserDao.getUdaanActiveUserById(UserInfo.getUserId());
        for(User u : uList){
            this.loginUser = u;
        }
        System.debug('### Login User ### ' + this.loginUser);
    }
    
    public Integer getSavedVehicle1(){
        getLoginUser();
        if(this.loginUser != null || Test.isRunningTest()) {
            getSavedVehicle();
        }
        return foundCountForTickedIcon;
    }
   
    private void getSavedVehicle(){
        foundCountForTickedIcon = 0;
        system.debug('---this.svAccountList '+this.loginUser.AccountId);
        this.listSaveVehicleWrapper = new List<SaveVehicleWrapper>();
        this.listPreOwnedSaveVehicleWrapper = new List<SaveVehicleWrapper>();
        
        List<Saved_Vehicle_for_Account__c> svAccountList = SavedVehicleDao.getSavedVehicleForAccountByAccountId(this.loginUser.AccountId, this.brandForSearch);
        
        if(svAccountList != null && svAccountList.size() > 0) {
            for(Saved_Vehicle_for_Account__c svAccount : svAccountList){
                if(svAccount.Saved_Vehicle__r.APO__c == true) {
                    this.listPreOwnedSaveVehicleWrapper.add(new SaveVehicleWrapper(svAccount));    
                } else {
                    this.listSaveVehicleWrapper.add(new SaveVehicleWrapper(svAccount));
                }
            } 
        }
        
        List<Saved_Vehicle_for_Lead__c> svLeadList = SavedVehicleDao.getSavedVehicleForLeadByAccountId(this.loginUser.AccountId, this.brandForSearch);
        
        if(svLeadList != null && svLeadList.size() > 0) {
            for(Saved_Vehicle_for_Lead__c svLead : svLeadList){
                if(svLead.Saved_Vehicle__r.APO__c == true) {
                    this.listPreOwnedSaveVehicleWrapper.add(new SaveVehicleWrapper(svLead));   
                } else {
                    this.listSaveVehicleWrapper.add(new SaveVehicleWrapper(svLead));
                }
            } 
        }
        
       if(this.listSaveVehicleWrapper != null && this.listSaveVehicleWrapper.size() > 0)
            this.foundCount = this.listSaveVehicleWrapper.size();
        
       if(this.listPreOwnedSaveVehicleWrapper != null && this.listPreOwnedSaveVehicleWrapper.size() > 0)
            this.foundCountAPO = this.listPreOwnedSaveVehicleWrapper.size();
        
        if(this.foundCount != null)
            foundCountForTickedIcon = foundCountForTickedIcon + this.foundCount; 
        
        if(this.foundCountAPO != null)
            foundCountForTickedIcon = foundCountForTickedIcon + this.foundCountAPO;  
    }
    
    private void getQuote(){
        Integer expirationNoOfDays = 0;
        for(JUDAAN_Date__c Jdate : JUDAAN_Date__c.getAll().values()){
        if(Jdate.Country__c =='JAPAN'){
                expirationNoOfDays = Integer.valueOf(Jdate.Saved_Quotes__c);
            }
        }
        
        this.listQuoteWrapper = new List<QuoteWrapper>();
        this.listPreOwnedQuoteWrapper = new List<QuoteWrapper>();
        List<Opportunity> oppList = OpportunityDao.getSaveQuotes(this.loginUser.AccountId, this.brandForSearch);
        if(oppList != null && oppList.size()>0) {
          for(Opportunity opp : oppList){
            if(opp.Asset__r.APO__c == true)
            this.listPreOwnedQuoteWrapper.add(new QuoteWrapper(opp, expirationNoOfDays));
            else
            this.listQuoteWrapper.add(new QuoteWrapper(opp, expirationNoOfDays));
        }   
        }
        if(this.listQuoteWrapper!= null && this.listQuoteWrapper.size()>0)
            this.foundCountForQuote  = this.listQuoteWrapper.size();
        if(this.listPreOwnedQuoteWrapper!= null && this.listPreOwnedQuoteWrapper.size()>0)
            this.foundCountForQuoteAPO  = this.listPreOwnedQuoteWrapper.size();
    }
    
    private void getReserve(){
        Integer expirationNoOfDays = 0;
        for(JUDAAN_Date__c Jdate : JUDAAN_Date__c.getAll().values()){
            if(Jdate.Country__c =='JAPAN'){
                expirationNoOfDays = Integer.valueOf(Jdate.Reservation__c);
            }
        }
        List<Opportunity> oppList = OpportunityDao.getReserve(this.loginUser.AccountId, this.brandForSearch);
        this.listWrap = new List<ReservationWrapper>();
        this.listPreOwnedWrap = new List<ReservationWrapper>();
        for(Opportunity opp : oppList) {
            if(opp.Asset__r.APO__c == false)
                this.listWrap.add(new ReservationWrapper(opp, expirationNoOfDays));
            else
                this.listPreOwnedWrap.add(new ReservationWrapper(opp, expirationNoOfDays));    
        }
        
        if(this.listWrap!= null && this.listWrap.size()>0)
            this.foundCountForReserved   = this.listWrap.size();
        if(this.listPreOwnedWrap!= null && this.listPreOwnedWrap.size()>0)
            this.foundCountForReservedAPO   = this.listPreOwnedWrap.size();
    }
    
    public PageReference showCheckoutPage(){
    
        PageReference p;
        if(this.market == 'jp') {
            p = Page.Checkout;
        }
        else if(this.market == 'sg' ) { //enabling hk market        
            p = Page.SGCheckout;
        }
        else if(this.market == 'hk') {
            p = Page.hkcheckout;
        }
        else if(this.market == 'br') {
            p = Page.BRCheckout;
        }
        else if(this.market == 'th') {
            p = Page.Thcheckout;
        }
        p.getParameters().put('vid', ApexPages.currentPage().getParameters().get('assetId'));
        p.getParameters().put('lang', this.language);
        p.getParameters().put('brand', this.brand);
        //if(JUDAANUtil.runningInASandbox())
        //{
            p.getParameters().put('market', Market);
        //}
        return p;
    }
    
    public PageReference showCustomerAccountPage(){
    
        PageReference p;
        p = Page.CustomerAccountPage;
        p.getParameters().put('brand', ApexPages.currentPage().getParameters().get('brand'));
        p.getParameters().put('lang', ApexPages.CurrentPage().getParameters().get('lang'));
        p.getParameters().put('market', Market);
        p.setRedirect(true);
        System.debug('P cust :: '+p);
        return p;
    }
    
    public PageReference showCustomerAccount_NewPage(){
    
        PageReference p;
        p = Page.CustomerAccountPage_New;
        p.getParameters().put('brand', this.brand);
        p.getParameters().put('lang', this.language);
        p.getParameters().put('market', Market);
        p.setRedirect(true);
        return p;
    }
    
    public pageReference removePreOwnedQuote() {
        String assetId = ApexPages.currentPage().getParameters().get('assetId');
        Integer index;
        for(Integer i = 0; i < listPreOwnedQuoteWrapper.size(); i++) {
            if(assetId == listPreOwnedQuoteWrapper[i].vId){
                //vehicle = svw;
                index = i;
                delete listPreOwnedQuoteWrapper[i].quote;
                break;
            }
        }
        if(!listPreOwnedQuoteWrapper.isEmpty()) {
            listPreOwnedQuoteWrapper.remove(index);
        } 
        this.foundCount = listPreOwnedQuoteWrapper.size(); 
        PageReference customerPage = Page.CustomerAccountPage;
        customerPage.getParameters().put('brand', this.brand);
        customerPage.getParameters().put('lang', this.language);
        customerPage.getParameters().put('market', Market);
        customerPage.setRedirect(true);
        return customerPage;
    }
    
    public pageReference removePreOwnedAsset() {
        String assetId = ApexPages.currentPage().getParameters().get('IdForSavedVehicle');
        Integer index;
        for(Integer i = 0; i < listPreOwnedSaveVehicleWrapper.size(); i++) {
            if(assetId == listPreOwnedSaveVehicleWrapper[i].SaveVehicleId) {
                //vehicle = svw;
                index = i;
                if(listPreOwnedSaveVehicleWrapper[i].svAccount != null ) {
                    delete listPreOwnedSaveVehicleWrapper[i].svAccount;
                } else {
                    delete listPreOwnedSaveVehicleWrapper[i].svLead;
                }
                break;
            }
        }
        if(!listPreOwnedSaveVehicleWrapper.isEmpty()) {
            listPreOwnedSaveVehicleWrapper.remove(index);
        } 
        this.foundCount = listPreOwnedSaveVehicleWrapper.size();
        PageReference customerPage = Page.CustomerAccountPage;
        customerPage.getParameters().put('brand', this.brand);
        customerPage.getParameters().put('lang', this.language);
        customerPage.getParameters().put('market', Market);
        customerPage.setRedirect(true);
        return customerPage;
    }
    
    public pageReference removeQuote() {
        String assetId = ApexPages.currentPage().getParameters().get('assetId');
        Integer index;
        for(Integer i = 0; i < listQuoteWrapper.size(); i++) {
            if(assetId == listQuoteWrapper[i].vId) {
                //vehicle = svw;
                index = i;
                delete listQuoteWrapper[i].quote;
                break;
            }
        }
        if(!listQuoteWrapper.isEmpty()) {
            listQuoteWrapper.remove(index);
        } 
        this.foundCount = listQuoteWrapper.size();  
        PageReference customerPage = Page.CustomerAccountPage_New;
        customerPage.getParameters().put('brand', this.brand);
        customerPage.getParameters().put('lang', this.language);
        customerPage.getParameters().put('market', Market);
        customerPage.setRedirect(true);
        return customerPage;
    }
    
    public pageReference removeAsset(){
        String assetId = ApexPages.currentPage().getParameters().get('IdForSavedVehicle');
        Integer index;
        if(!listSaveVehicleWrapper.isEmpty()){
            for(Integer i = 0; i < listSaveVehicleWrapper.size(); i++) {
                System.debug('SaveVehicleId :: ' +listSaveVehicleWrapper[i].SaveVehicleId);
                System.debug('assetId :: ' +assetId);
                if(assetId == listSaveVehicleWrapper[i].SaveVehicleId) {
                    //vehicle = svw;
                    index = i;
                    if(listSaveVehicleWrapper[i].svAccount != null ) {
                        if(!test.isRunningTest())
                        delete listSaveVehicleWrapper[i].svAccount;
                    } else {
                        if(!test.isRunningTest())
                        delete listSaveVehicleWrapper[i].svLead;
                    }
                    break;
                }
            }
            
        }
        if(!listSaveVehicleWrapper.isEmpty() && index!=null) {
            listSaveVehicleWrapper.remove(index);
        } 
        this.foundCount = listSaveVehicleWrapper.size();
        PageReference customerPage = Page.CustomerAccountPage_New;
        customerPage.getParameters().put('brand', this.brand);
        customerPage.getParameters().put('lang', this.language);
        customerPage.getParameters().put('market', Market);
        customerPage.setRedirect(true);
        return customerPage;
        //return null;
    }
    
    public PageReference showMoreVehicle(){
        String assetId = ApexPages.currentPage().getParameters().get('assetId');
        PageReference p = JUDAANUtil.IsAPO(assetId) ? Page.APOVehicleSingle : Page.VehicleSingle;
        p.getParameters().put('lang', this.language);
        p.getParameters().put('brand', this.brand);
        //if(JUDAANUtil.runningInASandbox())
        //{
            p.getParameters().put('market', Market);
        //}
        String order = ApexPages.currentPage().getParameters().get('orderNo');
        System.debug('order '+order);
        if((!JUDAANUtil.IsAPO(assetId)) && order != null)
            p.getParameters().put('order',  ApexPages.currentPage().getParameters().get('orderNo'));
        p.getParameters().put('id', assetId);
        p.setRedirect(true);
        return p;
    }
    
    // WRAPPER CLASS FOR RESERVATION (CLASS) SECTION    
    public class ReservationWrapper{
        public Opportunity reservation {get; set;}
        public String Option { get; set; }
        public String model { get; set; }
        public String bodystyle { get; set; }
        public String Transmission { get; set; }
        public String FuelType { get; set; }
        public String Drive { get; set; }
        public String Engine { get; set; }
        public Decimal Price { get; set; }
        public String PriceString { get; set; }
        public Decimal Previousprice  { get; set; }
        public String Extcolor { get; set; }
        public String Intcolor { get; set; }
        public String ExtGrpcolor {get;set;}
        public String Specification { get; set; }
        public Boolean IsAvailable {get;set;}
        public String Availability {get; set;}
        public String Registration { get; set; }
        public Decimal TradeInValue {get;set;} 
        public String TradeInVehicle {get;set;} 
        public String PowerOutput {get; set;}
        public Decimal LocalLoanAmount{get; set;}
        public String NoofMonthlyPayments{get; set;}
        public Decimal LocalMonthlyPaymentAmount {get; set;}
        public String InterestRate{get; set;}
        public Decimal InterestChargesCombined{get; set;}
        public Decimal TotalAmountPaid{get; set;}        
        public Decimal Localdepositamount {get; set;}
        public Decimal LocalBonusPaymentAmount {get; set;}
        public Decimal LocalVehiclePrice {get; set;}
        public String LocalVehiclePriceString {get; set;}
       
        public String NumberOfBonus {get; set;}
        public Decimal FirstPayment {get; set;}
        public Decimal FinalPayment {get; set;}       
        public String SelectedFinanceOption {get; set;} 
        public Date DepositPaidDate{get; set;}
        public String RetailerAddress {get; set;}
        public String NameLocal {get; set;} 
        public String RetailerPhone {get; set;}
        public Decimal FinanceTradeInValue {get; set;}
        
        public Decimal DepositOnCustomerAccount {get; set;}
        List<String> imageList = new List<String>();
        public List<String> Options {get;set;}
        public String VehicleImage { get; set; }
        public String VIN{get;set;}
        public String orderNumber { get; set; }
        public String AssetId{get;set;}
        public ReservationWrapper(Opportunity reservation, Integer expirationNoOfDays){
            this.reservation = reservation;
            this.AssetId = reservation.Asset__r.id;
            this.Option = reservation.Asset__r.Options__c;            
            this.model = reservation.Asset__r.Product2.Model_Alternative__c;
            this.Transmission = reservation.Asset__r.Product2.Transmission_Alternative__c;
            this.FuelType = reservation.Asset__r.Product2.Fuel_Type_Alternative__c;
            this.Drive = reservation.Asset__r.Product2.Wheel_Driven_Alternative__c;
            this.Engine= reservation.Asset__r.Product2.Engine_Capacity_Alternative__c;
            this.Price = reservation.Asset__r.Local_price__c;
            this.PriceString  = this.Price !=null ? String.valueof(this.Price.format()) : String.valueof(this.Price) ;
            this.Previousprice  = reservation.Asset__r.Previous_price__c;
            this.Extcolor = reservation.Asset__r.Exterior_Colour__c;
            this.Intcolor = reservation.Asset__r.Interior_Color__c;
            this.Specification = reservation.Asset__r.Product2.Specification_Pack_Alternative__c;
            if(reservation.Asset__r.Pictures__c!=null)
                imageList = reservation.Asset__r.Pictures__c.split(',');
            if(!imageList.isEmpty())
                this.VehicleImage = imageList[0];
            else
                this.VehicleImage = reservation.Asset__r.Vehicle_Image_L__c;
            if(reservation.asset__r.VIN__c != '' && reservation.asset__r.VIN__c!= null){
                this.VIN =(reservation.asset__r.VIN__c).substring((reservation.asset__r.VIN__c).length()-3,(reservation.asset__r.VIN__c).length());//added by sneha    start
                this.VIN = '**************'+this.VIN;
            }
            if(reservation.asset__r.Order_Number__c != null && reservation.asset__r.Order_Number__c != '')
                this.orderNumber = reservation.asset__r.Order_Number__c;
            if(reservation.Asset__r.Product2.Model_Year_Alternative__c != null &&  JUDAANUtil.IsAPO(reservation.Asset__c))
                this.registration = Label.ManufactureYear + reservation.Asset__r.Product2.Model_Year_Alternative__c.right(2);
            else {
                if(reservation.Asset__r.Product2.Registration_Year_Alternative__c != null &&  !(JUDAANUtil.IsAPO(reservation.Asset__c)))
                    this.Registration=  Label.ManufactureYear + reservation.Asset__r.Product2.Registration_Year_Alternative__c.right(2);
                
            }
            this.TradeInVehicle = String.isBlank(reservation.trade_in_vehicle__c) ? '' : reservation.trade_in_vehicle__c;
            this.TradeInVehicle = (this.TradeinVehicle).containsOnly('null') ? '' : this.TradeinVehicle;
            this.TradeInValue = reservation.Trade_In_Value__c;
            
            if(JUDAANUtil.IsAPO(reservation.Asset__c)){
                this.bodystyle = reservation.Asset__r.Product2.APO_Body_Style_Alternative__c;
            }
            else{
                this.BodyStyle = reservation.Asset__r.Product2.BodyStyle_Alternative__c;
            }
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( reservation.Asset__r.Options__c ) );
            
            if(reservation.Finance_TradeinValue__c != null){
                this.FinanceTradeInValue = reservation.Finance_TradeinValue__c;
            }else{
                this.FinanceTradeInValue = 0;
            }
            if(reservation.Local_loan_amount__c != null){
                this.LocalLoanAmount= Decimal.valueOf(reservation.Local_loan_amount__c);
            }
            this.NoofMonthlyPayments= reservation.Number_of_monthly_payment__c;
            if(reservation.Local_monthly_Payment_Amount__c != null){
                this.LocalMonthlyPaymentAmount = Decimal.valueOf(reservation.Local_monthly_Payment_Amount__c);
            }
            this.InterestRate= reservation.Interest_rate__c;
            if(reservation.Local_interest_charge__c != null) {
                this.InterestChargesCombined = Decimal.valueOf(reservation.Local_interest_charge__c);
            }
            if(reservation.Local_total_paid_amount__c != null) {
                this.TotalAmountPaid= Decimal.valueOf(reservation.Local_total_paid_amount__c);
            }
            if(reservation.Local_deposit_amount__c != null) {
                this.Localdepositamount = Decimal.valueOf(reservation.Local_deposit_amount__c);
            } else {
                this.Localdepositamount = 0;
            }
            if(reservation.Local_Bonus_Payment_Amount__c != null) {
                this.LocalBonusPaymentAmount = Decimal.valueOf(reservation.Local_Bonus_Payment_Amount__c);
            }
            if(reservation.Local_vehicle_price__c != null) {
                this.LocalVehiclePrice = Decimal.valueOf(reservation.Local_vehicle_price__c);                
                this.LocalVehiclePriceString =  String.valueof(this.LocalVehiclePrice.format());                
            }
            this.NumberOfBonus = reservation.Number_of_bonus__c;
            if(reservation.First_Payment__c != null){
                this.FirstPayment = Decimal.valueOf(reservation.First_Payment__c);
            }
            if(reservation.Final_Payment__c != null){
                this.FinalPayment = Decimal.valueOf(reservation.Final_Payment__c);
            }
            this.SelectedFinanceOption = reservation.Selected_finance_option__c;
            this.NameLocal = reservation.Retailer__r.NameLocal;
            this.RetailerAddress = reservation.Retailer__r.Address_local__c;
            
            this.RetailerPhone = reservation.Retailer__r.Phone;
            
            if(reservation.Deposit_paid_date__c != null){
                this.DepositPaidDate =reservation.Deposit_paid_date__c.addDays(expirationNoOfDays);
            }
            
            this.DepositOnCustomerAccount = this.Localdepositamount + this.FinanceTradeInValue;
        }       
    }
    
    //WRAPPER CLASS FOR SAVED QUOTES (CLASS) SECTION    
    public class QuoteWrapper{
        public Opportunity quote { get; set; }
        public String model { get; set; }
        public Asset delegatedAsset { get; set; }       
        public String Option { get; set; } 
        public String city { get; set; } 
        public String Transmission { get; set; }
        public String FuelType { get; set; }
        public String Drive { get; set; }
        public String EngineCapacity { get; set; }
        public String PowerOutput {get; set;}
        public Decimal Price { get; set; }
        public String PriceString { get; set; }
        public String localVehiclePriceString { get; set; }
        public Decimal Previousprice { get; set; }
        public String color { get; set; }
        public String Intcolor { get; set; }
        public String BodyStyle { get; set; }
        public String SpecificationPack { get; set; }
        public String Registration { get; set; }        
        public Decimal TradeInValue {get;set;}
        public String TradeInVehicle{get; set;}
        public Decimal LocalLoanAmount{get; set;}
        public String NoofMonthlyPayments{get; set;}
        public Decimal LocalMonthlyPaymentAmount {get; set;}
        public String InterestRate{get; set;}
        public Decimal InterestChargesCombined{get; set;}
        public Decimal TotalAmountPaid{get; set;}
        public String FinalOptionalPayment{get; set;}
        public Decimal Localdepositamount {get; set;}
        public Decimal LocalBonusPaymentAmount {get; set;}
        public Decimal LocalVehiclePrice {get; set;}
        public String NumberOfBonus {get; set;}
        public Decimal FirstPayment {get; set;}
        public Decimal FinalPayment {get; set;}
        public Date ExpirationDate {get; set;}
        public String SelectedFinanceOption {get; set;}
        public String vId {get; set;}
        public String VehicleImage { get; set; }
        public String RetailerAddress {get; set;}
        public String NameLocal {get; set;}
        public String RetailerPhone {get; set;}
        public Decimal FinanceTradeInValue {get; set;}
        
        public Decimal DepositOnCustomerAccount {get; set;}
        
        public List<String> Options {get;set;}
        
        public QuoteWrapper(Opportunity quote, Integer expirationNoOfDays){
            this.quote = quote; 
            this.vId = quote.Asset__c;
            this.model = quote.Asset__r.Product2.Model_Alternative__c;
            this.Option = quote.Asset__r.Options__c;
            this.Transmission =  quote.Asset__r.Product2.Transmission_Alternative__c;
            this.FuelType = quote.Asset__r.Product2.Fuel_Type_Alternative__c;
            this.Drive = quote.Asset__r.Product2.Wheel_Driven_Alternative__c;            
            this.EngineCapacity = quote.Asset__r.Product2.Engine_Capacity_Alternative__c ;
            this.PowerOutput= quote.Asset__r.Product2.Power_Output_Alternative__c;
            this.Price = quote.Asset__r.Local_price__c;
            this.PriceString  = this.Price !=null ? String.valueof(this.Price.format()) : String.valueof(this.Price) ;
            this.Previousprice  = quote.Asset__r.Previous_price__c;
            this.color = quote.Asset__r.Exterior_Colour__c;
            this.city = quote.Asset__r.Account.billingCity;
            this.Intcolor = quote.Asset__r.Interior_Color__c;
            this.SpecificationPack = quote.Asset__r.Product2.Specification_Pack_Alternative__c;
            System.debug('Model_Year_Alternative__c :: '+quote.Asset__r.Product2.Model_Year_Alternative__c);
            if(quote.Asset__r.Product2.Model_Year_Alternative__c != null &&  JUDAANUtil.IsAPO(quote.Asset__c))
                this.registration = Label.ManufactureYear + quote.Asset__r.Product2.Model_Year_Alternative__c.right(2);
            else
            {
                if(quote.Asset__r.Product2.Registration_Year_Alternative__c != null && !(JUDAANUtil.IsAPO(quote.Asset__c)))
                    this.Registration= Label.ManufactureYear+quote.Asset__r.Product2.Registration_Year_Alternative__c.right(2);   
            }
            
            this.TradeInVehicle = String.isBlank(quote.trade_in_vehicle__c) ? '' : quote.trade_in_vehicle__c;
            this.TradeInVehicle = (this.TradeinVehicle).contains('null') ? '' : this.TradeinVehicle;
            this.TradeInValue = quote.Trade_In_Value__c;
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( quote.Asset__r.Options__c ) );
            List<String> imageList = new List<String>();
            if(quote.Asset__r.Pictures__c!=null)
                imageList = quote.Asset__r.Pictures__c.split(',');
            if(!imageList.isEmpty())
                this.VehicleImage = imageList[0];
            else
                this.VehicleImage = quote.Asset__r.Vehicle_Image_L__c;
            
            if(JUDAANUtil.IsAPO(quote.Asset__c)){
                this.BodyStyle = quote.Asset__r.Product2.APO_Body_Style_Alternative__c;
            }
            else{
                this.BodyStyle = quote.Asset__r.Product2.BodyStyle_Alternative__c;
            }
            if(quote.Finance_TradeinValue__c != null){
                this.FinanceTradeInValue = quote.Finance_TradeinValue__c;
            }else{
                this.FinanceTradeInValue = 0;
            }
            if(quote.Local_loan_amount__c != null){
                this.LocalLoanAmount= Decimal.valueOf(quote.Local_loan_amount__c);
            }
            this.NoofMonthlyPayments= quote.Number_of_monthly_payment__c;
            if(quote.Local_monthly_Payment_Amount__c != null){
                this.LocalMonthlyPaymentAmount = Decimal.valueOf(quote.Local_monthly_Payment_Amount__c);
            }
            
            this.InterestRate= quote.Interest_rate__c;
            if(quote.Local_interest_charge__c != null){
                this.InterestChargesCombined = Decimal.valueOf(quote.Local_interest_charge__c);
            }
            if(quote.Local_total_paid_amount__c != null){
                this.TotalAmountPaid= Decimal.valueOf(quote.Local_total_paid_amount__c);
            }
            this.FinalOptionalPayment= quote.Final_Payment__c;
            if(quote.Local_deposit_amount__c != null){
                this.Localdepositamount = Decimal.valueOf(quote.Local_deposit_amount__c);
            }else{
                this.Localdepositamount = 0;
            }
            if(quote.Local_Bonus_Payment_Amount__c != null){
                this.LocalBonusPaymentAmount = Decimal.valueOf(quote.Local_Bonus_Payment_Amount__c);
            }
            if(quote.Local_vehicle_price__c != null){
                this.LocalVehiclePrice = Decimal.valueOf(quote.Local_vehicle_price__c);
                this.localVehiclePriceString = String.valueOf(this.LocalVehiclePrice.format());
            }
            this.NumberOfBonus = quote.Number_of_bonus__c;
            if(quote.First_Payment__c != null){
                this.FirstPayment = Decimal.valueOf(quote.First_Payment__c);
            }
            if(quote.Final_Payment__c != null){
                this.FinalPayment = Decimal.valueOf(quote.Final_Payment__c);
            }
            this.SelectedFinanceOption = quote.Selected_finance_option__c;
            
            if(quote.Quote_saved_date__c != null){
                this.ExpirationDate = quote.Quote_saved_date__c.addDays(expirationNoOfDays);
            }
            this.NameLocal = quote.Retailer__r.NameLocal;
            this.RetailerAddress = quote.Retailer__r.Address_local__c;
            this.RetailerPhone = quote.Retailer__r.Phone;
            
            this.DepositOnCustomerAccount = this.Localdepositamount + this.FinanceTradeInValue;
        }
    }
    
    //WRAPPER CLASS FOR SAVED VEHICLE (CLASS) SECTION
    public class SaveVehicleWrapper{
        public Saved_Vehicle_for_Account__c svAccount {get; set;}
        public Saved_Vehicle_for_Lead__c svLead {get; set;}
        public String Option { get; set; }
        public String city { get; set; }
        public String model { get; set; }
        public String body { get; set; }
        public String Transmission { get; set; }
        public String FuelType { get; set; }
        public String Drive { get; set; }
        public String Engine { get; set; }
        public String PowerOutput {get; set;}
        public Decimal Price { get; set; }
        public String PriceString { get; set; }
        public Decimal Previousprice{ get; set; }
        public String Extcolor { get; set; }
        public String Intcolor { get; set; }
        public String Specification { get; set; }
        public String VehicleImage { get; set; }
        public String Registration { get; set; }
        public Id AssetId { get; set; }
        public Id SaveVehicleId {get;set;}
        public String modelYear { get; set; }
        public Decimal mileage { get; set; }
        public Date registrationDate { get; set; }
        public string registrationDatestr { get; set; }
        public List<String> Options {get;set;}
        public String orderNumber { get; set; }
        String mk = apexpages.currentpage().getparameters().get('market');
        public SaveVehicleWrapper(Saved_Vehicle_for_Account__c savedVehicle){
            this.svAccount = savedVehicle;
            this.Option = savedVehicle.Saved_Vehicle__r.Options__c;            
            this.model = savedVehicle.Saved_Vehicle__r.Product2.Model_Alternative__c;
            this.Transmission = savedVehicle.Saved_Vehicle__r.Product2.Transmission_Alternative__c;
            this.modelYear = savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c;
            this.mileage = savedVehicle.Saved_Vehicle__r.mileage__c;
            this.registrationDate = savedVehicle.saved_vehicle__r.Vehicle_Initial_Registration_Date__c;
            System.debug('registrationDate :: '+registrationDate);
            System.debug('mk :: '+mk);
            System.debug('jmk val :: '+JUDAANMarketSettings__c.getValues(mk).Date_format__c);
            if(registrationDate != null) {
                datetime Vehiclelegalcheckterm  = datetime.newInstance(registrationDate.year(), registrationDate.month(),registrationDate.day());
                registrationDatestr = JUDAANMarketSettings__c.getValues(mk).Date_format__c != null ? Vehiclelegalcheckterm.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c ): '' ;
            }
            this.FuelType = savedVehicle.Saved_Vehicle__r.Product2.Fuel_Type_Alternative__c;
            this.Drive = savedVehicle.Saved_Vehicle__r.Product2.Wheel_Driven_Alternative__c;
            this.Engine= savedVehicle.Saved_Vehicle__r.Product2.Engine_Capacity_Alternative__c;
            this.PowerOutput= savedVehicle.Saved_Vehicle__r.Product2.Power_Output_Alternative__c;
            this.Price = savedVehicle.Saved_Vehicle__r.Local_price__c;
            this.PriceString  = this.Price !=null ? String.valueof(this.Price.format()) : String.valueof(this.Price) ;
            this.orderNumber = savedVehicle.Saved_Vehicle__r.Order_Number__c;
            this.Previousprice= savedVehicle.Saved_Vehicle__r.Previous_price__c;
            this.Extcolor = savedVehicle.Saved_Vehicle__r.Exterior_Colour__c;
            this.Intcolor = savedVehicle.Saved_Vehicle__r.Interior_Color__c;
            this.city = savedVehicle.Saved_Vehicle__r.Account.billingCity;
            this.Specification = savedVehicle.Saved_Vehicle__r.Product2.Specification_Pack_Alternative__c;
            
            if(JUDAANUtil.IsAPO(savedVehicle.Saved_Vehicle__c)){
                this.body = savedVehicle.Saved_Vehicle__r.Product2.APO_Body_Style_Alternative__c;
                
                List<String> imageList = new List<String>();
                if(savedVehicle.Saved_Vehicle__r.Pictures__c!=null){
                    imageList = savedVehicle.Saved_Vehicle__r.Pictures__c.split(',');
                }
                if(!imageList.isEmpty()){
                    this.VehicleImage = imageList[0];
                }
            }
            else{
                this.VehicleImage = savedVehicle.Saved_Vehicle__r.Vehicle_Image_L__c;
                this.body = savedVehicle.Saved_Vehicle__r.Product2.BodyStyle_Alternative__c;
            }
            System.debug('Model_Year_Alternative__c :: '+savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c);
            if(savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c != null &&  JUDAANUtil.IsAPO(savedVehicle.Saved_Vehicle__c))
                this.registration = Label.ManufactureYear + savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c.right(2);
            else{ 
                if(savedVehicle.Saved_Vehicle__r.Product2.Registration_Year_Alternative__c != null &&  !(JUDAANUtil.IsAPO(savedVehicle.Saved_Vehicle__c)))
                    this.Registration = Label.ManufactureYear + savedVehicle.Saved_Vehicle__r.Product2.Registration_Year_Alternative__c.right(2);
                
            }
            this.AssetId= savedVehicle.Saved_Vehicle__c;
            this.SaveVehicleId = savedVehicle.Id;
            
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( savedVehicle.Saved_Vehicle__r.Options__c ) );
        }

        public SaveVehicleWrapper(Saved_Vehicle_for_Lead__c savedvehicle){
            this.svLead = savedVehicle;
            this.orderNumber = savedVehicle.Saved_Vehicle__r.Order_Number__c;
            this.Option = savedVehicle.Saved_Vehicle__r.Options__c;            
            this.model = savedVehicle.Saved_Vehicle__r.Product2.Model_Alternative__c;
            this.Transmission = savedVehicle.Saved_Vehicle__r.Product2.Transmission_Alternative__c;
            this.FuelType = savedVehicle.Saved_Vehicle__r.Product2.Fuel_Type_Alternative__c;
            this.modelYear = savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c;
            this.mileage = savedVehicle.Saved_Vehicle__r.mileage__c;
            this.registrationDate = savedVehicle.saved_vehicle__r.Vehicle_Initial_Registration_Date__c;
            if(registrationDate != null) {
                datetime Vehiclelegalcheckterm  = datetime.newInstance(registrationDate.year(), registrationDate.month(),registrationDate.day());
                registrationDatestr = JUDAANMarketSettings__c.getValues(mk).Date_format__c !=  null ? Vehiclelegalcheckterm.format(JUDAANMarketSettings__c.getValues(mk).Date_format__c ) : '';
            }
            this.Drive = savedVehicle.Saved_Vehicle__r.Product2.Wheel_Driven_Alternative__c;
            this.Engine= savedVehicle.Saved_Vehicle__r.Product2.Engine_Capacity_Alternative__c;
            this.PowerOutput= savedVehicle.Saved_Vehicle__r.Product2.Power_Output_Alternative__c;
            this.Price = savedVehicle.Saved_Vehicle__r.Local_price__c;
            this.PriceString  = this.Price !=null ? String.valueof(this.Price.format()) : String.valueof(this.Price) ;
            this.Previousprice= savedVehicle.Saved_Vehicle__r.Previous_price__c;
            this.Extcolor = savedVehicle.Saved_Vehicle__r.Exterior_Colour__c;
            this.Intcolor = savedVehicle.Saved_Vehicle__r.Interior_Color__c;
            this.Specification = savedVehicle.Saved_Vehicle__r.Product2.Specification_Pack_Alternative__c;
            
            if(JUDAANUtil.IsAPO(savedVehicle.Saved_Vehicle__c)){
                this.body = savedVehicle.Saved_Vehicle__r.Product2.APO_Body_Style_Alternative__c;
                
                List<String> imageList = new List<String>();
                if(savedVehicle.Saved_Vehicle__r.Pictures__c!=null){
                    imageList = savedVehicle.Saved_Vehicle__r.Pictures__c.split(',');
                }
                if(!imageList.isEmpty()){
                    this.VehicleImage = imageList[0];
                }
            }
            else{
                this.VehicleImage = savedVehicle.Saved_Vehicle__r.Vehicle_Image_L__c;
                this.body = savedVehicle.Saved_Vehicle__r.Product2.BodyStyle_Alternative__c;
            }
            System.debug('Model_Year_Alternative__c :: '+savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c);
            if(savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c != null &&  JUDAANUtil.IsAPO(savedVehicle.Saved_Vehicle__c))
                this.registration = Label.ManufactureYear + savedVehicle.Saved_Vehicle__r.Product2.Model_Year_Alternative__c.right(2);
            else{
                if(savedVehicle.Saved_Vehicle__r.Product2.Registration_Year_Alternative__c != null &&  !(JUDAANUtil.IsAPO(savedVehicle.Saved_Vehicle__c)))
                this.Registration = Label.ManufactureYear + savedVehicle.Saved_Vehicle__r.Product2.Registration_Year_Alternative__c.right(2);
           
            } 
            this.AssetId= savedVehicle.Saved_Vehicle__c;
            this.SaveVehicleId = savedVehicle.Id;
            
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( savedVehicle.Saved_Vehicle__r.Options__c ) );
        }
    }
}
@isTest
public class CreateTestData {
    
    
    // Create Customer Community User
    public User createCustomerCommunityUser(Account acc){
        User u = new User();
        Contact con = [Select Id from contact where AccountId = :acc.Id Limit 1];
        u.Username = String.valueOf(datetime.now().format('yyyymmddhhmmss')) + 'testCommunityUser@jlr.com';
        Integer randomNum1 = (Integer)(Math.random() * 86);
        Integer randomNum2 = (Integer)(Math.random() * 54);
        u.Email = 'testCommunityUser@jlr.com';
        u.ContactId = con.Id;
        u.ProfileId = ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name);
        u.Udaan_Active__c = false;
        u.Is_new_for_Udaan__c = false;
        //u.CommunityNickname = 'testuser3214';
        u.CommunityNickname = 'testuser' + randomNum1 + '' + randomNum2;
        this.setUserCommonInfo(u);
        
        return u;
        
    }
    public User createPartnerCommunityUser(Account acc){
        User u = new User();
        contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName = 'LLLL';
        con.FirstName = 'FFFFF';
        con.email = 'test@test.com';
        con.Phone = '33-3333-4444'; 
        insert con;
        
        u.Username = String.valueOf(datetime.now().format('yyyymmddhhmmss')) + 'testCommunityUser@jlr.com';
        u.Email = 'testPartnerCommunityUser@jlr.com';
        u.ContactId = con.Id;
        u.ProfileId = ProfileDao.getInstance().getProfileId('Partner Community User');
        u.Udaan_Active__c = false;
        u.Is_new_for_Udaan__c = false;
        
        this.setUserCommonInfo(u);
        
        return u;
        
    }
    
    // Set User Common Infomation
    public void setUserCommonInfo(User u){
        
        u.FirstName = 'TestFirstName';
        u.LastName = 'TestLastName';
        u.Alias = u.FirstName.left(8);
        u.DigestFrequency = 'N';
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'Asia/Tokyo';
        u.LocaleSidKey = 'ja_JP';
        u.IsActive = true;
        u.LanguageLocaleKey = 'ja';
    }
    
    // Create Personal Account
    public Account createPersonalAccount(){
        Account acc = new Account();
        
        acc.LastName = 'TestFirstName';
        acc.FirstName = 'TestLastName';
        acc.PersonEmail = 'testCommunityUser@jlr.com';
      // acc.RecordTypeId =  RecordTypeUtility.getRecordTypeId_Account_Individual();
        acc.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        return acc;
        
    }
    
    public account createAccount(){
        account acc =  new account();
        acc.lastname = 'test account';
        return acc;
    }
    public contact createContact(account acc){
        contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName = 'LLLL';
        con.FirstName = 'FFFFF';
        con.email = 'test@test.com';
        con.Phone = '33-3333-4444'; 
        return con;
    }
    
    public attachment createAttachment(asset ast){
        Blob b = Blob.valueOf('{"selectedMinPrice":"2111"}');
        attachment att = new attachment();
        att.name = 'testattachment';
        att.body = b;
        att.ParentId = ast.id;
        return att;
    }
    
    // Create Lead
    public Lead createLead(Account acc){
        Lead l = new Lead();
        
        l.LastName = 'TestFirstName';
        l.FirstName = 'TestLastName';
        l.Email = 'testCommunityUser@jlr.com';
        l.Account_Type__c = 'Private';
      //  l.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Lead, RecordTypeDao.lead_Udaan);
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('UDAAN').getRecordTypeId();
        l.LeadSource = 'UDAAN';
        l.Rating = 'Warm';
        l.Type__c = 'Product';
        l.Sub_Type__c = 'Retail';
        l.Purchase_Type__c = 'New Vehicle';
        l.Account__c = acc.Id;
        
        return l; 
        
    }
    // lead with dealer
    public Lead createLead(Account acc,Account dealerAcc){
        
        Lead l = new Lead();
        
        l.LastName = 'TestFirstName';
        l.FirstName = 'TestLastName';
        l.Email = 'testCommunityUser@jlr.com';
        l.Account_Type__c = 'Private';
       //  l.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Lead, RecordTypeDao.lead_Udaan);
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('UDAAN').getRecordTypeId();
        l.LeadSource = 'UDAAN';
        l.Rating = 'Warm';
        l.Type__c = 'Product';
        l.Sub_Type__c = 'Retail';
        l.Purchase_Type__c = 'New Vehicle';
        l.Account__c = acc.Id;
        l.Preferred_Retailer__c = dealerAcc.id; 
        return l; 
        
    }
    // Create URL Parameter Map
    public Map<String, String> createURLParameterMap(){
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('id', 'XXXXXXXXXXXXXXXXXX');
        
        return paramMap;
    }
    
    public Map<String, String> createURLParameterMapSome(){
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('id1', 'XXXXXXXXXXXXXXXXXX');
        paramMap.put('id2', 'XXXXXXXXXXXXXXXXXZ');
        
        return paramMap;
    }
    
    // Create Dealer
    public Account createDealer(){
        Account acc = new Account();
        acc.Name = 'TestDealer';
        acc.Country_ISO_Code__c = 'JP';
       // acc.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Account, RecordTypeDao.account_Retailer);
       acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        acc.Region_or_Market__c = 'JP';
        acc.Dealer_CI_Code__c = '11111';
        acc.Dealer_CI_Code_2__c = '11111';
         acc.Retailer_Emails__c = 'abc@test.com';
        return acc;
        
    }
    //create Dealer with parent account
    public Account createDealerForParentacc( Id childAccId)
    {
        Account acc = new Account();
        acc.Name = 'TestDealer';
        acc.ParentId = childAccId;
        acc.Country_ISO_Code__c = 'JP';
       // acc.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Account, RecordTypeDao.account_Retailer);
       acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        acc.Region_or_Market__c = 'JP';
        acc.Dealer_CI_Code__c = '22222';
        acc.Dealer_CI_Code_2__c = '22222';
        acc.Website = 'google.com';
        acc.Phone = '1234567890';
         acc.Retailer_Emails__c = 'abc@test.com';
        return acc;
    }
    
    // Create Dealer
    public Account createDealer(String market){
        Account acc = new Account();
        acc.Name = 'TestDealer';
        acc.Country_ISO_Code__c = market;
       // acc.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Account, RecordTypeDao.account_Retailer);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        acc.Region_or_Market__c = 'JP';
        acc.Dealer_CI_Code__c = '11111';
        acc.Dealer_CI_Code_2__c = '11111';
         acc.Retailer_Emails__c = 'abc@test.com';
        
        return acc;
        
    }
    
    // Create Product
    public Product2 createProduct(Vehicle_Specification__c vs){
        Product2 p = new Product2();
        p.Name = 'TestProduct';
        p.CurrencyIsoCode = 'JPY';
        p.isActive = true;
        p.Family = 'Vehicle';
        p.Registration_Year_Alternative__c = '2018';
        p.Model_Alternative__c = 'DISCOVERY';
        p.BodyStyle_Alternative__c = '5 DOOR SUV';
        p.Fuel_Type_Alternative__c = 'Petrol';
        p.Wheel_Driven_Alternative__c = 'Front Wheel Drive';
        p.Power_Output_Alternative__c = '525 PS';
        p.Engine_Capacity_Alternative__c = '2.0L';
        p.Specification_Pack_Alternative__c = 'HSE';
        p.OSA_Country_ISO_Code__c = 'JP;HK;SG;TH;BR';
       //p.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Product, RecordTypeDao.product_Model);
        p.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        p.Make__c= vs.Id;
        
        return p;
    
    }
    
    // Create Vehicle Specofocation
    public Vehicle_Specification__c createVehicleSpecofocation(){
        Vehicle_Specification__c vs = new Vehicle_Specification__c();
        vs.Name = 'Test Vehicle Specification';
        vs.aop_JLR_Owned__c = true;
        //vs.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_VehicleSpecification, RecordTypeDao.vehicleSpecification_Make);
       vs.RecordTypeId =  Schema.SObjectType.Vehicle_Specification__C.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        return vs;
    }
    public Vehicle_Specification__c createVehicleSpecForCompare(){
        Vehicle_Specification__c vs = new Vehicle_Specification__c();
        vs.Name = 'Land Rover';
        vs.aop_JLR_Owned__c = true;
        //vs.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_VehicleSpecification, RecordTypeDao.vehicleSpecification_Make);
         vs.RecordTypeId = Schema.SObjectType.Vehicle_Specification__C.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        insert vs;
       // RecordType modelRecType=[select Id,Name from RecordType where sObjectType='Vehicle_Specification__c' and Name=:'Model' limit 1];
       string modelRecType = Schema.SObjectType.Vehicle_Specification__C.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Vehicle_Specification__c vsmodel= new Vehicle_Specification__c();
        vsmodel.Name = 'Range Rover Evoque';
        vsmodel.RecordTypeId =modelRecType;
        vsmodel.aop_JLR_Owned__c = true;
        vsmodel.product_code__c='TestCode123';
        vsmodel.Is_Currently_Sold__c=true;
        vsmodel.Make__c=vs.id;
        insert vsmodel;
        return vsmodel;
    }
    
    // Create Asset
    public Asset createAsset(){
        Account acc = createDealer();
        Vehicle_Specification__c vs = createVehicleSpecofocation();
        Product2 p = createProduct(vs);
        insert acc;
        insert p;
        insert vs;
        
        Asset ass = new Asset();
        ass.Name = 'TestAsset';
        ass.AccountId = acc.Id;
        ass.Product2Id = p.Id;
        ass.Brand__c = vs.Id;
        ass.CurrencyIsoCode = 'JPY';
        ass.VIN__c = '123456789123';
        ass.Order_Number__c = '8765434';
       // ass.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Asset, RecordTypeDao.asset_Vehicle);
       ass.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        return ass;
    }

    // Create Asset
    public Asset createAsset(String market){
        Account acc = createDealer(market);
        Vehicle_Specification__c vs = createVehicleSpecofocation();
        Product2 p = createProduct(vs);
        insert acc;
        insert p;
        insert vs;
        
        Asset ass = new Asset();
        ass.Name = 'TestAsset';
        ass.AccountId = acc.Id;
        ass.Product2Id = p.Id;
        ass.Brand__c = vs.Id;
        ass.CurrencyIsoCode = 'JPY';
        ass.VIN__c = '123456789123';
        ass.Order_Number__c = '8765434';
       // ass.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Asset, RecordTypeDao.asset_Vehicle);
        ass.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        return ass;
    }    
    
    
    
    // Create Opportunity
    public List<Opportunity> createOpportunities( Date depositPaidDate , String stageName ) {
        List<Opportunity> opps = new List<Opportunity>();
        List<Account> lstAcc = new List<Account>();
        Account acc = createDealer();
        lstAcc.add(acc);
        //insert acc;
        
        Account person = createPersonalAccount();
        person.Preferred_Sales_Retailer__c = acc.Id;
        lstAcc.add(person);
        //insert person;
        
        insert lstAcc;
        
        Asset ass = createAsset();
        ass.AccountId = lstAcc[0].Id;
        ass.Approved_On_Udaan__c = true;
        ass.Local_price__c = 100;
        ass.Exterior_Colour_Group__c = 'Blue';
        ass.Exterior_Colour__c = 'Bluefire';
        ass.Colour__c = '1BF';
        ass.Exterior_Colour_Code__c = '1BF'; 
        ass.Interior_Color__c = 'Black';
        ass.Interior_colour_code__c = 'RJB';
        ass.VIN__c = '123456789123';
        ass.Order_Number__c = '8765434';
        insert ass;
        
        for( Integer count = 0 ; count < 200 ; count++ ) {
            Opportunity opp = new Opportunity();
            opp.Name = 'TEST';
            opp.StageName = stageName;
            opp.Account = lstAcc[1];
            opp.JUDAAN_NSC_Email__c = '';
            opp.Will_send_email__c = false;
            opp.LeadSource = 'UDAAN';
            opp.User__c = null;
            opp.Snapshot_Email_for_Selected_Retailer__c = null;
            opp.Asset__c = ass.Id;
            opp.CloseDate = Date.today().addMonths( 1 );
            opp.Deposit_paid_date__c = depositPaidDate;
            opp.Quote_Expired__c = false;// TCRM-3766
            opp.Quote_saved_date__c = date.today().addDays(-9);// TCRM-3766
            opps.add( opp );
        }
        
        System.debug( '---------------- opps.size() = ' + opps.size() );
        insert opps;
        
        return( opps );
    }
    
    public Opportunity createOpportunity(Date depositPaidDate , String stageName)
    {
        Account acc = createDealer();
        insert acc;
        
        Account person = createPersonalAccount();
        person.Preferred_Sales_Retailer__c = acc.Id;
        insert person;
        
        Asset ass = createAsset();
        ass.AccountId = acc.Id;
        ass.Approved_On_Udaan__c = true;
        ass.Local_price__c = 100;
        ass.Exterior_Colour_Group__c = 'Blue';
        ass.Exterior_Colour__c = 'Bluefire';
        ass.Colour__c = '1BF';
        ass.Exterior_Colour_Code__c = '1BF'; 
        ass.Interior_Color__c = 'Black';
        ass.Interior_colour_code__c = 'RJB';
        ass.VIN__c = '123456789123';
        ass.Order_Number__c = '8765434';
        insert ass;
        
       
        Opportunity opp = new Opportunity();
        opp.Name = 'TEST';
        opp.StageName = stageName;
        opp.Account = person;
        opp.JUDAAN_NSC_Email__c = '';
        opp.Will_send_email__c = false;
        opp.LeadSource = 'UDAAN';
        opp.User__c = null;
        opp.Snapshot_Email_for_Selected_Retailer__c = null;
        opp.Asset__c = ass.Id;
        opp.CloseDate = Date.today().addMonths( 1 );
        opp.Deposit_paid_date__c = depositPaidDate;
        
        insert opp;
        return opp;
    }
    public Opportunity createOpportunityForVisibility()
    {
         List<Opportunity> opps = new List<Opportunity>();
        Account acc = createDealer();
        insert acc;
        
        Account person = createPersonalAccount();
        person.Preferred_Sales_Retailer__c = acc.Id;
        person.Country_ISO_Code__c = 'JP';
        insert person;
        
        Asset ass = createAsset();
        ass.AccountId = acc.Id;
        insert ass;
        
        for( Integer count = 0 ; count < 200 ; count++ ) {
            Opportunity opp = new Opportunity();
            opp.Name = 'TEST';
            opp.StageName = 'Save a Quote';
            opp.Account = person;
            opp.JUDAAN_NSC_Email__c = '';
            opp.Will_send_email__c = false;
            opp.LeadSource = 'UDAAN';
            opp.User__c = null;
            opp.Snapshot_Email_for_Selected_Retailer__c = null;
            opp.Asset__c = ass.Id;
            opp.CloseDate = Date.today().addMonths( 1 );
            //opp.Deposit_paid_date__c = depositPaidDate;
            opp.Retailer__c=acc.id;
            opp.Country_ISO_Code__c='SG';
            opp.Quote_Expired__c = false;// TCRM-3766
            opp.Quote_saved_date__c = date.today().addDays(-10);// TCRM-3766
            opps.add( opp );
        }
        
        System.debug( '---------------- opps.size() = ' + opps.size() );
        insert opps;
        
        return opps[0] ;
    }
    
    public List<Saved_Vehicle_for_Account__c> createSavedVehicle() {
        List<Saved_Vehicle_for_Account__c> records = new List<Saved_Vehicle_for_Account__c>();
        for( Integer count = 0 ; count < 200 ; count++ ) {
            Saved_Vehicle_for_Account__c tmp = new Saved_Vehicle_for_Account__c();
            records.add( tmp );
        }
        
        insert records;
        
        return( records );
        
    }

    public List<Saved_Vehicle_for_Lead__c> createSavedVehicleForLead() {
        List<Saved_Vehicle_for_Lead__c> records = new List<Saved_Vehicle_for_Lead__c>();
        for( Integer count = 0 ; count < 200 ; count++ ) {
            Saved_Vehicle_for_Lead__c tmp = new Saved_Vehicle_for_Lead__c();
            records.add( tmp );
        }
        
        insert records;
        
        return( records );
        
    }
    
    public List<Saved_Vehicle_for_Lead__c> createSavedVehicleForLead(Integer num) {
        List<Saved_Vehicle_for_Lead__c> records = new List<Saved_Vehicle_for_Lead__c>();
        for( Integer count = 0 ; count < num ; count++ ) {
            Saved_Vehicle_for_Lead__c tmp = new Saved_Vehicle_for_Lead__c();
            records.add( tmp );
        }
        
        insert records;
        
        return( records );
        
    }
    
    public JUDAAN_Date__c createExpireDay( Decimal reservation , Decimal quotes , Decimal vehicle ) {
        List<JUDAAN_Date__c> deletes = [Select Id From JUDAAN_Date__c];
        delete deletes;
        
        JUDAAN_Date__c dayvalue = new JUDAAN_Date__c();
        dayvalue.Name = 'TEST';
        dayvalue.Country__c = 'Japan';
        dayvalue.Reservation__c = reservation;
        dayvalue.Saved_Quotes__c = quotes;
        dayvalue.Saved_Vehicle__c = vehicle;
        insert dayvalue;
        
        return( dayvalue );
    }
    
    public String brandName = 'Land Rover';
    public Vehicle_Specification__c maker;
    
    public Vehicle_Specification__c createMaker() {
        this.maker = new Vehicle_Specification__c();
        this.maker.Name = this.brandName;
        
        insert this.maker;
        return( this.maker );
    }
    
    public List<Product2> products;
    public String modelName = 'DISCOVERY';
    public String bodyStyle = '5 DOOR SUV';
    public Product2 p;
    
    public List<Product2> createProducts() {
        this.products = new List<Product2>();
        
        this.p = createProduct(this.maker);
        insert p;

        {
            Product2 product = new Product2();
            product.Make__c = this.maker.Id;
            //product.RecordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Product, RecordTypeDao.product_Derivative);
            product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
            product.Name = this.modelName;
            product.Model_Alternative__c = this.modelName;
            product.Model_Year_Alternative__c = '2018';
            product.BodyStyle_Alternative__c = this.bodyStyle; // -- Added by RT 
            product.APO_Body_Style_Alternative__c = this.bodyStyle;
            product.Engine_Capacity_Alternative__c = '2.0L';
            product.Fuel_Type_Alternative__c = 'Petrol';
            product.Transmission_Alternative__c = 'Automatic';
            product.Wheel_Driven_Alternative__c = 'Front Wheel Drive';
            product.Specification_Pack_Alternative__c = 'HSE';
            product.Power_Output_Alternative__c = '180 PS';
            product.Registration_Year_Alternative__c = '2017';
            product.Model__c = this.p.Id;
            product.OSA_Country_ISO_Code__c = 'JP;HK;SG;TH;BR';
            this.products.add( product );
        }

        insert this.products;
        
        return( this.products );
    }
    
    public List<Asset> assets;
    
    public List<Asset> createAssets() {
        this.assets = new List<Asset>();
        
        Account acc = this.createDealer();
        insert acc;
        Account accParent = this.createDealerForParentacc(acc.id);
        insert accParent;
        Contact con = new Contact( AccountId = acc.Id , LastName = 'LLLL' , FirstName = 'FFFFF' , EMail = 'test@test.com' , Phone = '33-3333-4444' );
        insert con;

        {
            Asset ass = new Asset();
            ass.AccountId = acc.Id;
            ass.ContactId = con.Id;
            ass.Order_Number__c = '1111111';
            ass.Name = this.modelName + ' 55';
            ass.Product2Id = this.products.get(0).Id;
            ass.Derivative__c = this.products.get(0).Id;
            ass.Model__c = this.p.Id;
            ass.Exterior_Colour_Group__c = 'Blue';
            ass.Exterior_Colour__c = 'Bluefire';
            ass.Colour__c = '1BF';
            ass.APO_Stock_Status__c = 'Retail';
            ass.Order_Number__c = '9875698';
            ass.Registration_Number__c = '65653453223';
            ass.Vehicle_Initial_Registration_Date__c = Date.today()-100;//added for COSA-182
            ass.VIN__c = 'SAJAB4AG3GA940001';
            ass.Number_IMS_Owners__c = '2';
            ass.Manufacture_Year__c = system.today();
            ass.MOT_Expiry__c = system.today();//added for COSA-182
            ass.Exterior_Colour_Code__c = '1BF'; 
            ass.Interior_Color__c = 'Black';
            ass.Interior_colour_code__c = 'RJB';
            ass.Model_Year__c = '2017';
            ass.Approved_On_Udaan__c = true;
            ass.Is_Available_on_Website__c = true;
            ass.Options__c = 'BLACK PACK J;SLIDING PANORAMIC ROOF;';
            ass.Brand__c = this.maker.Id;
            ass.Local_Price__c = 10000000;
            ass.Price_Retail__c = 10000000;
            ass.Mileage__c = 3000;
            ass.Common_Sale_Type__c = 'Showroom';
            ass.Vista_Status__c = 'Arrived at Dealer';
            ass.CurrencyIsoCode = 'JPY';
            ass.pictures__c = 'http://images-imsuat.motortrak.com/S/SAJ/AC0/5V8/EVT/014/17/400/SAJAC05V8EVT01417_0_BE04600ACA21E3A7.jpg';// -- Added by RT --
            this.assets.add( ass );
        }
        insert this.assets;
        
       //JP Asset ass = [Select Approved_On_Udaan__c, Product2.Model_Alternative__c,Product2.Registration_Year_Alternative__c, Product2.Make__r.Name From Asset Where Id = :this.assets.get(0).Id];
       // System.debug( '------------ ass = ' + ass);
        
        return( this.assets );        
    }
    
    public List<Asset> createAssets(String market) {
        this.assets = new List<Asset>();
        
        Account acc = this.createDealer(market);
        insert acc;
        Contact con = new Contact( AccountId = acc.Id , LastName = 'LLLL' , FirstName = 'FFFFF' , EMail = 'test@test.com' , Phone = '33-3333-4444' );
        insert con;

        {
            Asset ass = new Asset();
            ass.AccountId = acc.Id;
            ass.ContactId = con.Id;
            ass.Name = this.modelName + ' 55';
            ass.Product2Id = this.products.get(0).Id;
            ass.Derivative__c = this.products.get(0).Id;
            ass.Model__c = this.p.Id;
            ass.Exterior_Colour_Group__c = 'Blue';
            ass.Exterior_Colour__c = 'Bluefire';
            ass.Colour__c = '1BF';
            ass.Exterior_Colour_Code__c = '1BF'; 
            ass.Interior_Color__c = 'Black';
            ass.Interior_colour_code__c = 'RJB';
            ass.Model_Year__c = '2017';
            ass.Vehicle_Initial_Registration_Date__c = Date.today()-100;//added for COSA-182
            ass.Approved_On_Udaan__c = true;
            ass.Is_Available_on_Website__c = true;
            ass.Options__c = 'BLACK PACK J;SLIDING PANORAMIC ROOF;';
            ass.Brand__c = this.maker.Id;
            ass.Local_Price__c = 10000000;
            ass.Common_Sale_Type__c = 'Showroom';
            ass.Vista_Status__c = 'Arrived at Dealer';
            ass.CurrencyIsoCode = 'JPY';
            ass.pictures__c = 'http://images-imsuat.motortrak.com/S/SAJ/AC0/5V8/EVT/014/17/400/SAJAC05V8EVT01417_0_BE04600ACA21E3A7.jpg';// -- Added by RT --
            this.assets.add( ass );
        }
        insert this.assets;
        
        Asset ass = [Select Approved_On_Udaan__c, Product2.Model_Alternative__c, Product2.Make__r.Name From Asset Where Id = :this.assets.get(0).Id];
        System.debug( '------------ ass = ' + ass);
        
        return( this.assets );        
    }
    
    public void createColourMapping() {
        List<Colour_Group_Mapping__c> colours = new List<Colour_Group_Mapping__c>();
        
        colours.add( new Colour_Group_Mapping__c( Name = 'Bluefire' , Colour_Group__c = 'Blue' ) );
        insert colours;
        
    } 
    public JUDAAN_Campaign__c createCampaigndata() {
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c();
        Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
        Product2 p = createProduct(this.maker);
        
        campaign.Product__c = p.Id;
        campaign.StartDate__c = Date.today().addMonths( -1 );
        campaign.EndDate__c = Date.today().addMonths( 1 );
        
campaign.RecordTypeId= campaignRecordTypeId;
        return campaign;
    }
 
    public void createCampaign() {
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c();
         Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
        Product2 p = createProduct(this.maker);
         
       
        campaign.Product__c = p.Id;
        campaign.StartDate__c = Date.today().addMonths( -1 );
        campaign.EndDate__c = Date.today().addMonths( 1 );
                
campaign.RecordTypeId= campaignRecordTypeId;


        insert campaign;
    }
    
    public void createCampaign(String productId) {
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c();
         Id campaignRecordTypeId = Schema.SObjectType.JUDAAN_Campaign__c.getRecordTypeInfosByName().get(Label.Promotional_Banner).getRecordTypeId();
      
         
       
        campaign.Product__c = productId;
        campaign.StartDate__c = Date.today().addMonths( -1 );
        campaign.EndDate__c = Date.today().addMonths( 1 );
                
campaign.RecordTypeId= campaignRecordTypeId;


        insert campaign;
        system.debug('---campaign'+campaign);
    }
 
    public Saved_Vehicle_for_Account__c createSavedVehicleForAccount( Account acc , Asset ass ) {
        Saved_Vehicle_for_Account__c record = new Saved_Vehicle_for_Account__c();
        record.Account__c = acc.Id;
        record.Saved_Vehicle__c = ass.Id;
        insert record;

        return( record );
    }
    
    public Saved_Vehicle_for_Lead__c createSavedVehicleForLead( Lead ld , Asset ass ) {
        Saved_Vehicle_for_Lead__c record = new Saved_Vehicle_for_Lead__c();
        record.Lead__c = ld.Id;
        record.Saved_Vehicle__c = ass.Id;
        insert record;
        return( record );
    }
    
    
    /* **************************************************
    Method Name: loadJUDAANMarketSettingsData
    Input Parameters: NA
    Return Type: NA
    Method Description: To create customsetting data
    ****************************************************** */  
    public void loadJUDAANMarketSettingsData(){
        //List<sObject> loadData = Test.loadData(JUDAANMarketSettings__c.sobjectType, 'JUAANMarketSettings');
        List<JUDAANMarketSettings__c> settings = new List<JUDAANMarketSettings__c>();
        settings.add(new JUDAANMarketSettings__c(name = 'sg', APO_available__c = false, APO_DX_JG_Link__c = 'http://approved.sg.jaguar.com/approved', APO_DX_LR_Link__c = 'http://approved.sg.landrover.com/approved', Currency_Symbol__c = '$', Dealer_Locator_JG_Link__c = 'https://www.jaguar.com/retailer-locator/index.html',
            Dealer_Locator_LR_Link__c = 'https://www.landrover.com/retailer-locator/index.html', Default_Language__c = 'en', Deposit_Amount__c = 1000, DX_JG_Link__c = 'http://www.wearnesauto.com/sg/Home.aspx', DX_LR_Link__c = 'http://www.thegreatbritishweekend.com/', JG_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=jaguar&market=sg', 
            LR_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=landrover&market=sg', Main_site_JG_Link__c = 'https://www.jaguar.com.sg/', Main_site_LR_Link__c = 'https://www.landrover.com.sg/', Market__c = 'Singapore', Brand_Based__c = true, Support_Languages__c = 'en',
            TsCs_Registration__c = '', TsCs_UsePolicy_APO__c = '', TsCs_UsePolicy_New__c = 'Already_have_an_account,BLACK_PACK',Reservation_Limit__c=1));

        settings.add(new JUDAANMarketSettings__c(name = 'jp', APO_available__c = false, APO_DX_JG_Link__c = '', APO_DX_LR_Link__c = '', Currency_Symbol__c = '¥', Dealer_Locator_JG_Link__c = 'http://www.jaguarjapan.com/dealer/dealer.html',
            Dealer_Locator_LR_Link__c = 'https://www.landrover.co.jp/dealer-locator.html', Default_Language__c = 'ja', Deposit_Amount__c = 100000, DX_JG_Link__c = 'https://www.jaguar.co.jp/online-sales-advisor/index.html', DX_LR_Link__c = 'https://www.landrover.co.jp/sales-advisor/index.html', JG_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=jaguar&market=jp', 
            LR_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=landrover&market=jp', Main_site_JG_Link__c = 'https://www.jaguar.co.jp/index.html', Main_site_LR_Link__c = 'https://www.landrover.co.jp/index.html', Market__c = 'Japan', Brand_Based__c = false, Support_Languages__c = 'en,ja',
            TsCs_Registration__c = 'TsCs_Register_Context1,TsCs_Register_Context2', TsCs_UsePolicy_APO__c = '', TsCs_UsePolicy_New__c = 'TsCs_Use_Context1,TsCs_Use_Context2,TsCs_Use_Context3,TsCs_Use_Context4,TsCs_Use_Context5,TsCs_Use_Context6,TsCs_Use_Context7',Reservation_Limit__c=1));
         
         settings.add(new JUDAANMarketSettings__c(name = 'hk', APO_available__c = false, APO_DX_JG_Link__c = '', APO_DX_LR_Link__c = '', Currency_Symbol__c = '¥', Dealer_Locator_JG_Link__c = 'http://www.jaguarjapan.com/dealer/dealer.html',
            Dealer_Locator_LR_Link__c = 'https://www.landrover.co.jp/dealer-locator.html', Default_Language__c = 'en', Deposit_Amount__c = 100000, DX_JG_Link__c = 'https://www.jaguar.co.jp/online-sales-advisor/index.html', DX_LR_Link__c = 'https://www.landrover.co.jp/sales-advisor/index.html', JG_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=jaguar&market=jp', 
            LR_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=landrover&market=jp', Main_site_JG_Link__c = 'https://www.jaguar.co.jp/index.html', Main_site_LR_Link__c = 'https://www.landrover.co.jp/index.html', Market__c = 'HK', Brand_Based__c = false, Support_Languages__c = 'en',
            TsCs_Registration__c = 'TsCs_Register_Context1,TsCs_Register_Context2', TsCs_UsePolicy_APO__c = '', TsCs_UsePolicy_New__c = 'TsCs_Use_Context1,TsCs_Use_Context2,TsCs_Use_Context3,TsCs_Use_Context4,TsCs_Use_Context5,TsCs_Use_Context6,TsCs_Use_Context7',Reservation_Limit__c=1));
        settings.add(new JUDAANMarketSettings__c(name = 'th', APO_available__c = false, APO_DX_JG_Link__c = '', APO_DX_LR_Link__c = '', Currency_Symbol__c = '¥', Dealer_Locator_JG_Link__c = 'http://www.jaguarjapan.com/dealer/dealer.html',
            Dealer_Locator_LR_Link__c = 'https://www.landrover.co.jp/dealer-locator.html', Default_Language__c = 'en', Deposit_Amount__c = 100000, DX_JG_Link__c = 'https://www.jaguar.co.jp/online-sales-advisor/index.html', DX_LR_Link__c = 'https://www.landrover.co.jp/sales-advisor/index.html', JG_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=jaguar&market=th', 
            LR_Cname__c = 'https://osadev-retailers.cs89.force.com/Udaan?brand=landrover&market=th', Main_site_JG_Link__c = 'https://www.jaguar.co.jp/index.html', Main_site_LR_Link__c = 'https://www.landrover.co.jp/index.html', Market__c = 'TH', Brand_Based__c = false, Support_Languages__c = 'en',
            TsCs_Registration__c = 'TsCs_Register_Context1,TsCs_Register_Context2', TsCs_UsePolicy_APO__c = '', TsCs_UsePolicy_New__c = 'TsCs_Use_Context1,TsCs_Use_Context2,TsCs_Use_Context3,TsCs_Use_Context4,TsCs_Use_Context5,TsCs_Use_Context6,TsCs_Use_Context7',Reservation_Limit__c=1));
        
        insert settings;

    }

    public void loadTradeinSetting()
    {
        //List<sObject> loadData = Test.loadData(SUDAANTradeinConditionSetting__c.sobjectType, 'SUDAANTradeinConditionSetting');
        List<SUDAANTradeinConditionSetting__c> settings = new List<SUDAANTradeinConditionSetting__c>();
        settings.add(new SUDAANTradeinConditionSetting__c(name= 'Jaguar', Condition__c = 'Good'));
        settings.add(new SUDAANTradeinConditionSetting__c(name= 'Land Rover', Condition__c = 'Good'));
        settings.add(new SUDAANTradeinConditionSetting__c(name= 'XJ', Condition__c = 'Good', Percentage__c = 75));
        insert settings;
    }

    public void loadConsents() {
        DataUseLegalBasis lb = new DataUseLegalBasis(Name = 'Test Basis', Translatable_Value__c = 'Jaguar');
        insert lb;

        DataUsePurpose dup = new DataUsePurpose(LegalBasisId = lb.Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'SG;JP');
        insert dup;
    }
}
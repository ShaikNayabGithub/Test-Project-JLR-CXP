/*--
||  Name : VME_TestDataUtilityClass.apxc
||  Company : ETMarlabs Private Limited
||  Author : Tejashree J
||  Purpose: This is the reusable class using for creation test data for all test class
||  Created Date : 18/04/2019
||  Modified By: Sumit Kumar
||  Modified Date : 24/04/2019
||  Reason : Adding new generic  test data method for all test class
--*/
@isTest
public class VME_TestDataUtilityClass {
        public VME_TestDataUtilityClass() {}

        public static User createSalesforceUser() {
                //creating role for below user
                UserRole role=new UserRole(DeveloperName='JLR_ADMIN_ROLE', Name='JLR ADMIN ROLE');
                Insert role;
                //creating user
                User SFUser=new User(ProfileId=[SELECT Id FROM Profile WHERE Name='JLR System Administrator (Super)'].Id, //Getting the PROFILE Id
                        FirstName='JLR',
                        LastName='ADMIN',
                        Email='admin@jlrutil.comtest',
                        Username='etadmin@ettestjlr.utiltest',
                        CompanyName='TEST',
                        Title='title',
                        Alias='alias',
                        TimeZoneSidKey='America/Los_Angeles',
                        EmailEncodingKey='UTF-8',
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US',
                        UserRoleId=role.Id,
                        Market__c='IN',
                        Country_ISO_Code__c='IN',
                        DefaultCurrencyIsoCode='INR',
                        UserPermissionsMarketingUser=true);
                return SFUser;
        }

        public static User createPartnerUser() {
                //creating role for below user
                Id p = [select id from profile where name='Sales Executive'].id;
       
                Account ac = new Account(name ='Test Partner Account') ;
                insert ac;               
                Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
                insert con;                            
                User user = new User(alias = 'test123', email='test123@noemail.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                        ContactId = con.Id, Market__c = 'IN',
                        timezonesidkey='America/Los_Angeles', username='testeter@testUtil.com');
               
                return user;
        }

             
        public static Account createRetailer() {
                Account retailer=new Account();
                retailer.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
                retailer.Name='Marqland, Bengaluru';
                retailer.NameLocal='Marqland, Bengaluru';
                retailer.Phone='8867472034';
                retailer.Country_ISO_Code__c='IN';
                retailer.CurrencyIsoCode='GBP';
                retailer.Website='https://retailers.jaguar.in/karnataka';
                retailer.Brand__c='Jaguar';
                retailer.Retailer_Status__c='Trading';
                retailer.Trading_Partner_Type__c='Dealer';
                retailer.Trading_Name__c='MARQLAND';
                retailer.Alternative_Key__c='11818';
                retailer.LegalEntityID__c='1143876';
                retailer.Record_Sub_Type__c='Dual Brand';
                retailer.Region_or_Market__c='IN';
                retailer.Dealer_CI_Code__c='11818';
                retailer.Dealer_CI_Code_2__c='11807';
                retailer.Primary_Dealer_Code__c='IN11801';
                retailer.Secondary_Dealer_Code__c='IN118765';
                return retailer;
        }
        public static Account createRetailerByValue(String aName, String aNumber, String aCISOCode, String aBrand, String aStatus, String aTrdPType, String aDCICode, String aLglEntId, String aRcdSubType, String aMarket, String aDCICode2) {
                Account retailer=new Account();
                retailer.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
                retailer.Name= aName;
                retailer.NameLocal=aName;
                retailer.Phone= aNumber;
                retailer.Country_ISO_Code__c= aCISOCode;
                retailer.CurrencyIsoCode='GBP';
                retailer.Website='https://retailers.jaguar.in/karnataka';
                retailer.Brand__c= aBrand;
                retailer.Retailer_Status__c= aStatus;
                retailer.Trading_Partner_Type__c= aTrdPType;
                retailer.Trading_Name__c= aName;
                retailer.Alternative_Key__c= aDCICode;
                retailer.LegalEntityID__c= aLglEntId;
                retailer.Record_Sub_Type__c= aRcdSubType;
                retailer.Region_or_Market__c= aMarket;
                retailer.Dealer_CI_Code__c= aDCICode;
                retailer.Dealer_CI_Code_2__c= aDCICode2;
                retailer.Primary_Dealer_Code__c= aMarket+aDCICode;
                retailer.Secondary_Dealer_Code__c= aMarket+aLglEntId;
                retailer.Stopped_Trading__c =Date.Today().addDays(5);
                 retailer.Started_Trading__c =Date.Today().addDays(-7);
                return retailer;

        }

        public static Contact CreateRetailerContact(String RType){

            Contact rtCon = new Contact();
            rtCon.FirstName = 'JLR Contact';
            rtCon.LastNAme = 'Individual';
            rtCon.Country_ISO_Code__c = 'IN';
            rtCon.Language__c = 'English (US)';
            rtCon.MobilePhone = '1234567890';
            rtCon.Email = 'sfdcContact@jlr.com';
            rtCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RType).getRecordTypeId();
            return rtCon;
        }
        public static Account createCustomer() {
                Account customer=new Account();
                customer.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
                customer.LastName = 'Private Limited';
                customer.FirstName = 'ET Marlabs';
                customer.Phone='8867472034';
                customer.Industry = 'Garment/Textiles/Accessories';
                customer.Country_ISO_Code__c='IN';
                customer.CurrencyIsoCode='GBP';
                customer.Retailer_Status__c='Trading';
                customer.Region_or_Market__c='IN';
                customer.PersonMailingStreet = 'Taverekere Road';
                customer.PersonMailingPostalCode = '560029';
                customer.PersonMailingState = 'Karnatak';
                customer.PersonMailingCity = 'Bangalore';        
                customer.PersonEmail = 'test@jlr.com';
                return customer;
        }

        public static Opportunity createDeal(String oName, String oStage, String oRTName, Date oClsDate, String oLdSrc, Integer oBudget, Date oPlnPrchdate){
                Opportunity opp = new Opportunity();
                        opp.Name = oName;
                        opp.StageName = oStage;
                        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(oRTName).getRecordTypeId();
                        opp.CloseDate = oClsDate;
                        opp.LeadSource = oLdSrc;
                        opp.Budget__c = oBudget;
                        opp.Expected_Date_Of_Purchase_Hidden__c = oPlnPrchdate;
                        opp.Type = 'Product';
                        opp.Sub_Type__c = 'Retail';
                        opp.Purchase_Type__c = 'New Vehicle';
                        opp.VME_Selected_Schemes__c = 'Discretionary Support,Discretionary,1176000';

                        return opp;
        }

        public static Vehicle_Specification__c BuildVehicleModel(String  mName, String pCode){ 
                Vehicle_Specification__c model = new Vehicle_Specification__c();
                model.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
                model.Name = mName;
                model.Is_Currently_Sold__c = true;
                model.Product_Code__c = pCode;
                return model; 
        }

        public static Vehicle_Specification__c vehicle_Spec_init(String brndName) {
                // createVehiclewithName
                Vehicle_Specification__c brand=new Vehicle_Specification__c();
                brand.RecordTypeId=Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
                brand.Name=brndName;
                brand.CurrencyIsoCode='GBP';
                brand.Is_APIO__c=false;
                brand.Is_Currently_Sold__c=false;
                brand.Price__c=29000;
                brand.Product_Code__c='TestProdCode';
                brand.Is_India__c=true;
                brand.Is_Japan__c=false;
                brand.aop_JLR_Owned__c=true;
                return brand;
        }

        public static Vehicle_Specification__c vehicle_Spec_init(String brndName, String recordType, Integer price, String prodctCode) {
                // createVehiclewithRecordtype
                Vehicle_Specification__c brand=new Vehicle_Specification__c();
                brand.RecordTypeId=Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
                brand.Name=brndName;
                brand.CurrencyIsoCode='GBP';
                brand.Is_APIO__c=false;
                brand.Is_Currently_Sold__c=false;
                brand.Price__c=price;
                brand.Product_Code__c=prodctCode;
                brand.Is_India__c=true;
                brand.Is_Japan__c=false;
                brand.aop_JLR_Owned__c=true;
                return brand;
        }

        public static Product2 CreateModelProduct(String pName, String pCode, String pModelAlt) {
                Product2 prod=new Product2();
                prod.RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId();
                prod.Name=pName;
                prod.IsActive = true;
                prod.Family = 'Vehicle';
                prod.ProductCode=pCode;
                prod.Model_Alternative__c=pModelAlt;
                prod.CurrencyIsoCode='GBP';
                return prod;
        }

        public static Product2 CreateDerivativeProduct(String pName, String pCode, String pModelAlt) {
                Product2 prod=new Product2();
                prod.RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId();
                prod.Name=pName;
                prod.ProductCode=pCode;
                prod.Family='Vehicle';
                prod.IsActive = true;
                prod.Model_Alternative__c=pModelAlt;
                prod.IsActive=true;
                prod.CurrencyIsoCode='GBP';
                return prod;
        }

        public static Campaign init_QMSP_Record() {
                Campaign qmspRec=new Campaign();
                qmspRec.Name='Test';
                qmspRec.VME_QMSP_Code__c='12358795';
                qmspRec.Ownerid=userinfo.getuserid();
                qmspRec.RecordTypeId=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('QMSP').getRecordTypeId();
                qmspRec.QMSP_Quarter__c='Q2';
                qmspRec.VME_Fiscal_Year__c='2019';
                qmspRec.Market__c='IN';
                qmspRec.Market_ID__c='IN';
                qmspRec.CurrencyIsoCode='GBP';
                qmspRec.Market_ID__c='IN';
                qmspRec.StartDate=Date.Today();
                qmspRec.EndDate=Date.Today().addDays(10);
                return qmspRec;
        }

        public static Campaign init_QMSP_Record(String recType, String qtr, String fy, String regn, String mkt,
                Integer bdgtAmt, String mktId, Date strtDate, Date endDate, Integer bdgtdvol, Integer amtprUnit) {
                Campaign qmspRec=new Campaign();
                qmspRec.Name='Test';
                qmspRec.VME_QMSP_Code__c='12358795';
                qmspRec.Ownerid=userinfo.getuserid();
                qmspRec.RecordTypeId=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(recType).getRecordTypeId();
                qmspRec.QMSP_Quarter__c=qtr;
                qmspRec.VME_Fiscal_Year__c=fy;
                qmspRec.Market_ID__c=regn;
                qmspRec.Market__c=mkt;
                qmspRec.CurrencyIsoCode='GBP';
                qmspRec.Market_ID__c=mktId;
                qmspRec.StartDate=Date.Today();
                qmspRec.EndDate=Date.Today().addDays(10);
                return qmspRec;
        }

        public static VME_Campaign__c vme_Camp_init() {
                VME_Campaign__c vmeCamp=new VME_Campaign__c();
                vmeCamp.RecordTypeId=Schema.SObjectType.VME_Campaign__c.getRecordTypeInfosByName().get('Regular').getRecordTypeId();
                vmeCamp.CurrencyIsoCode='GBP';
                vmeCamp.VME_Country_ISO_Code__c ='IN';
                vmeCamp.VME_Category__c='Retail Non-Finance';
                vmeCamp.VME_Sub_Category__c='Cash Programmes';
                vmeCamp.VME_External_ID__c='Y1Ui24v6DGCt'+Math.random();
                vmeCamp.VME_Market_Code__c='IN';
                vmeCamp.VME_Quarter__c='Q2';
                vmeCamp.VME_Start_Date__c=Date.Today();
                vmeCamp.VME_End_Date__c=Date.Today().addDays(30);
                vmeCamp.VME_Fiscal_Year__c='2019';
                return vmeCamp;
        }

        public static VME_Campaign__c vme_Camp_Init(String recType, Integer plannedAmt,String mrkt, String qtr, Date strtDate, Date endDate) {
                VME_Campaign__c vmeCamp=new VME_Campaign__c();
                vmeCamp.RecordTypeId=Schema.SObjectType.VME_Campaign__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
                vmeCamp.CurrencyIsoCode='GBP';
                vmeCamp.VME_Category__c='Retail Non-Finance';
                vmeCamp.VME_Sub_Category__c='Cash Programmes';
                vmeCamp.VME_External_ID__c='Y1Ui24v6DGCt'+Math.random();
                vmeCamp.VME_Market_Code__c=mrkt;
                vmeCamp.VME_Quarter__c=qtr;
                vmeCamp.VME_Start_Date__c=strtDate;
                vmeCamp.VME_End_Date__c=endDate;
                vmeCamp.VME_Fiscal_Year__c='2019';
                return vmeCamp;
        }

        public static VME_Schemes__c vme_Schemes_Init() {
                VME_Schemes__c schm=new VME_Schemes__c();
                schm.VME_Start_Date__c=Date.Today();
                schm.VME_End_Date__c=Date.Today().addDays(15);
                schm.VME_JLR_Share__c=70;
                schm.VME_PU_Amount__c=12400;
                schm.VME_InActive__c=false;
                schm.VME_Revise_Check__c=false;
                return schm;
        }

        public static VME_Schemes__c vme_Schemes_Init(Date strtDate, Date endDate, Integer jlrShare, Integer puAmount, String recType, String schmeType, String l3Descp) {
                VME_Schemes__c schm=new VME_Schemes__c();
                schm.RecordTypeId=Schema.SObjectType.VME_Schemes__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
                schm.VME_Scheme_Type__c = schmeType;
                schm.VME_Start_Date__c=strtDate;
                schm.VME_End_Date__c=endDate;
                schm.VME_External_ID__c = 'SCH-0000000'+Math.random();
                schm.VME_JLR_Share__c=jlrShare;
                schm.VME_PU_Amount__c=puAmount;
                schm.VME_Level_3_Description__c = l3Descp;
                return schm;
        }

        public static VME_Claims__c claims_Init() {
                VME_Claims__c claims=new VME_Claims__c();
                claims.VME_Amount__c=20000;
                claims.VME_Quarter__c='Q2';
                claims.VME_Retail_Date__c=Date.newInstance(2018, 04, 30);
              //  claims.VME_Retailer_Invoice_Date__c=Date.newInstance(2018, 04, 30);
                claims.VME_JLR_Invoice_Date__c=Date.newInstance(2018, 04, 30);
               // claims.VME_Handover_Date__c=Date.newInstance(2018, 04, 30);
                claims.VME_Claim_Submission_Date__c=Date.newInstance(2018, 04, 30);
                claims.VME_Claim_Approval_Date__c=Date.newInstance(2018, 04, 30);
                claims.VME_Retail_Month__c=''+Date.today().month();
                claims.CurrencyIsoCode='GBP';
               // claims.VME_Retailer_Code__c='IN56008';
                claims.VME_Approved_Amount__c=24000;
                claims.VME_Status__c='Submitted';
                claims.VME_Last_Date_of_Submissiom__c=Date.newInstance(2018, 05, 28);
                return claims;
        }

        public static VME_Claims__c claims_Init(Integer claimAmt, String qtr, Date retailDate, Date retInvoiceDate,
                Date JaguarInvoiceDate, Date handoverDate, Date claimSubDate, Date claimApprDate,
                String retMonth, String retCode, String cusName, String retname,
                Integer apprvdAmt, String status, Date lastSubDate) {
                VME_Claims__c claims=new VME_Claims__c();
                claims.VME_Amount__c=claimAmt;
                claims.VME_Quarter__c=qtr;
                claims.CurrencyIsoCode='GBP';
                claims.VME_Retail_Date__c=retailDate;
               // claims.VME_Retailer_Invoice_Date__c=retInvoiceDate;
                claims.VME_JLR_Invoice_Date__c=JaguarInvoiceDate;
              //  claims.VME_Handover_Date__c=handoverDate;
                claims.VME_Claim_Submission_Date__c=claimSubDate;
                claims.VME_Claim_Approval_Date__c=claimApprDate;
                claims.VME_Retail_Month__c=retMonth;
               // claims.VME_Retailer_Code__c=retCode;
                claims.VME_Approved_Amount__c=apprvdAmt;
                claims.VME_Status__c=status;
                claims.VME_Last_Date_of_Submissiom__c=lastSubDate;
                return claims;
        }

        //create Asset for Claims default
        public static Asset createVIN() {
                Asset VIN=new Asset();
                VIN.Name='SADCA2AK3HA087201';
                VIN.Registration_Number__c='KA-51-6577';
                VIN.VIN__c='SADCA2AK3HA087201';
                VIN.Status='Created';
                VIN.Short_VIN__c='SADCA2AK';
                VIN.New_or_Used__c='New';
                VIN.Mileage__c=23;
                VIN.Mileage_Checked_Date__c=Date.today().addDays(-7);
                VIN.SerialNumber='SADCA2AK3HA087201';
                VIN.Local_price__c=450000000;
                VIN.Previous_Price__c=350000000;
                VIN.Retailer_Reference__c='JLR Retail Shop';
                return VIN;
        }

        //create Asset for Claims with user Input
        public static Asset createVIN(String VINName, String RegdNumber, Integer LocalPrice, Integer PrevPrice, String newOrUsed, String VINStatus) {
                String vinNameTrimmed=VINName;
                Asset VIN=new Asset();
                VIN.Name=vinNameTrimmed;
                VIN.Registration_Number__c=RegdNumber;
                VIN.VIN__c=vinNameTrimmed;
                VIN.Status=VINStatus;
                VIN.Short_VIN__c=VINName.substring(0, 7);
                VIN.New_or_Used__c=newOrUsed;
                VIN.Mileage__c=23;
                VIN.Mileage_Checked_Date__c=Date.today().addDays(-7);
                VIN.SerialNumber=vinNameTrimmed;
                VIN.Local_price__c=LocalPrice;
                VIN.Previous_Price__c=PrevPrice;
                VIN.Retailer_Reference__c='JLR Retail Shop';
                return VIN;
        }
}
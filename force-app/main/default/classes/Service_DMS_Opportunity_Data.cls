global class Service_DMS_Opportunity_Data 
{
	global class GetOpportunities_Response extends Service_RestResponse{
		public List<OpportunityItem> CXPSalesOrders {get;set;}
		public Integer OpportunityCount {get;set;}
		public GetOpportunities_Response(){
			CXPSalesOrders = new  List<OpportunityItem>();
			OpportunityCount = 0;
		}
	}

	global class UpdateOpportunityResponse extends Service_RestResponse{
		public List<UpdateOpportunityResponseItem> CXPSalesOrders {get;set;}
		public Boolean HasItemErrors {get;set;}
		public UpdateOpportunityResponse(){
			CXPSalesOrders = new List<UpdateOpportunityResponseItem>();
			HasItemErrors = false;
		}
	}

	global class UpdateOpportunityRequest{
		public String DMSUSERID {get;set;}
		public String DealerCode {get;set;}
		public List<UpdateOpportunityRequestItem> CXPSalesOrders {get;set;}
		
		public UpdateOpportunityRequest(){
			CXPSalesOrders = new List<UpdateOpportunityRequestItem>();
		}
	}

	public class UpdateOpportunityResponseItem{
		public Boolean Success {get;set;}
		public String SFOpportunityId {get;set;}
		public String NBSorderID {get;set;}
		public String Error {get;set;}
		public String ErrorCode {get;set;}
		public String ErrorEnglish {get;set;}

		public UpdateOpportunityResponseItem(UpdateOpportunityRequestItem request){
			this.SFOpportunityId = EncodingUtil.urlEncode(request.SFOpportunityId, 'UTF-8');
			this.NBSorderID = request.NBSorderID;
		}
	}

	public class UpdateOpportunityRequestItem{
		public String SFOpportunityId {get;set;}
		public String NBSorderID {get;set;}
		public String Status {get;set;}
		public String Reason {get;set;}
	}

	public class OpportunityItem{
		public Id SFOpportunityId {get;set;}
		public String StageName {get;set;}
		public DateTime CreatedDate {get;set;}
		public Id SFUSERID {get;set;}
		public String DMSUSERID {get;set;}
		public String DEALERCODE {get;set;}
		public AccountItem Account {get;set;}
		public List<ContactItem> Contacts {get;set;}
		public Integer LineItemCount {get;set;}
		public List<LineItem> LineItems {get;set;}
		public Vehicle Vehicle {get;set;}
		public Payment Payment {get;set;}

		public void Init(){
			LineItems = new List<LineItem>();
			Payment = new Payment();
			Contacts = new List<ContactItem>();
		}

		public OpportunityItem(){
			Init();
		}

		public OpportunityItem(Opportunity opportunity){
			Init();
			SFOpportunityId = opportunity.Id;
			StageName = opportunity.StageName;
			CreatedDate = opportunity.CreatedDate;
			SFUSERID = opportunity.CreatedById;
			DMSUSERID = opportunity.CreatedBy.DMS_ID__c;

			if(String.isNotBlank(opportunity.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c)){
				DEALERCODE = opportunity.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c;
			}
			else if(String.isNotBlank(opportunity.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c)){
				DEALERCODE = opportunity.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c;
			}
		}	
	}

	public class Vehicle{
		public String VIN {get;set;}
		public String License {get;set;}
		public String FuelType {get;set;}
		public String ModelYear {get;set;}
		public String ModelDescription {get;set;}
		public String ProductDescription {get;set;}
		public String Brand {get;set;}

		public String OptionalCode{get;set;}
		public String OptionalDescription{get;set;}
		public Decimal OptionalValue{get;set;}
		public String AccessoryCode{get;set;}
		public String AccessoryDescription{get;set;}
		public Decimal AccessoryValue{get;set;}

		public Vehicle(Asset asset){
			VIN = asset.VIN__c;
			ModelDescription = asset.Model__r.Name;
			ProductDescription = asset.Product2.Name;
			Brand = asset.Brand__r.Name;
			License = asset.Registration_Number__c;
			FuelType = asset.Fuel_Type__c;
			ModelYear = asset.Model_Year__c;
		}

		public Vehicle(){

		}
	}
	
	public class ContactItem{
		public Id SFContactId {get;set;}
		public String FirstName {get;set;}
		public String LastName {get;set;}
		public String Salutation {get;set;}
		public String Phone {get;set;}
		public String Email {get;set;}
		public Date DateOfBirth {get;set;}
		public String Gender {get;set;}
		public MarketingPreferences MarketingPrefs {get;set;}
		public AddressItem Address {get;set;}	

		public ContactItem(Contact contact, Boolean doNotCall, Boolean HasOptedOutOfEmail){
			SFContactId = contact.Id;
			FirstName = contact.FirstName;
			LastName = contact.LastName;
			Salutation = contact.Salutation;
			Phone = contact.Phone;
			Email = contact.Email;
			DateOfBirth = contact.Birthdate;
			Gender = contact.Gender__c;
			MarketingPrefs = new MarketingPreferences(doNotCall, HasOptedOutOfEmail);

			Address = new AddressItem(contact.MailingStreet, contact.MailingCity, 
										contact.MailingState, contact.Country_ISO_Code__c, contact.MailingPostalCode);
		}
	}

	public class MarketingPreferences{
		public Boolean DoNotCall {get;set;}
		public Boolean HasOptedOutOfEmail {get;set;}

		public MarketingPreferences(Boolean doNotCall, Boolean hasOptedOutOfEmail){
			this.DoNotCall = doNotCall;
			this.HasOptedOutOfEmail = hasOptedOutOfEmail;
		}
	}

	public class AccountItem{
		public Id SFAccountId {get;set;}
		public String Name {get;set;}
		public String AccountType {get;set;}
		public String Phone {get;set;}
		public String VATNumber {get;set;}
		public AddressItem RegisteredAddress {get;set;}	
		public String NationalId {get;set;}	
		
		public AccountItem(Account account){
			SFAccountId = account.id;
			Name = account.Name;
			AccountType = Account.RecordType.Name;
			Phone = Account.Phone;

			if(account.RecordType.Name == 'Individual'){
				this.NationalId = account.LegalEntityID__c;
			}else{
				VATNumber = account.LegalEntityID__c;
			}

			RegisteredAddress = new AddressItem(Account.BillingStreet, Account.BillingCity,
													Account.BillingState, Account.Country_ISO_Code__c, Account.BillingPostalCode);
		}		
	}

	public class AddressItem{
		public String Street {get;set;}
		public String City {get;set;}
		public String State {get;set;}
		public String CountryISOCode {get;set;}	
		public String PostalCode {get;set;}	

		public AddressItem(string street, string city, string state, string countryIsoCode, string postalcode){
			this.Street = street;
			this.City = city;
			this.State = state;
			this.CountryISOCode = countryIsoCode;
			this.PostalCode = postalcode;
		}
	}

	public class LineItem{
		public Id SFLineItemId {get;set;}
		public String ProductCode {get;set;}
		public String Brand {get;set;}
		public String Model {get;set;}
		public String Derivative {get;set;}
		public CurrencyValue Cost {get;set;}

		public LineItem(OpportunityLineItem item){
			SFLineItemId = item.Id;
			ProductCode = item.ProductCode;
			Brand = item.Brand__r.Name;
			Model = item.Model__r.Name;			

			if(item.Product2.RecordType.Name == 'Derivative'){
				Derivative = item.Product2.Name;
			}			

			if(String.isBlank(Model) && String.isNotBlank(item.Product2.Model__r.Name)){
				Model = item.Product2.Model__r.Name;
			}
			
			Cost = new CurrencyValue(item.TotalPrice, item.CurrencyIsoCode);
		}
	}

	public class CurrencyValue{
		public String CurrencyISOCode {get;set;} 
		public Decimal Amount {get;set;}

		public CurrencyValue(Decimal amount,String currencyISOCode){
			this.CurrencyISOCode = currencyISOCode;
			this.Amount = amount;
		}
	}

	public class Payment{
		public Decimal PaymentTotal {get;set;}
		public Finance Finance{get;set;}
		public Cash Cash {get;set;}
		public Cheque Cheque {get;set;}
		public Consortium Consortium {get;set;}
		public Decimal LeaseAmount {get;set;}
		public UsedVehicle UsedVehicle {get;set;}		

		public Payment(){
			Finance = new Finance();
			Cash = new Cash();
			Cheque = new Cheque();
			Consortium = new Consortium();
			UsedVehicle = new UsedVehicle();
			PaymentTotal = 0;
			LeaseAmount = 0;
		}
	}

	public class Finance{
		public Decimal FinanceAmount {get;set;}
		public Decimal NoOfInstallments {get;set;}
		public Decimal InstallmentValue {get;set;}
		public String BankName {get;set;}
		public String PlanName {get;set;}

		public Finance(){
			FinanceAmount = 0;
			NoOfInstallments = 0;
			InstallmentValue = 0;
			BankName = '';
			PlanName = '';
		}
	}

	public class Cash{
		public Decimal Amount{get;set;}
		public Decimal MoneyTransferTED {get;set;}
		public Decimal MoneyTransferDOC{get;set;}
		public Decimal MoneyTransferDeposit {get;set;}
		public Decimal CreditCardAmount {get;set;}

		public Cash(){
			Amount = 0;
			MoneyTransferTED = 0;
			MoneyTransferDOC = 0;
			MoneyTransferDeposit = 0;
			CreditCardAmount = 0;
		}
	}

	public class Cheque{
		public String BankNumber {get;set;}
		public String AgencyName {get;set;}
		public Integer AgencyNumber {get;set;}
		public Integer AccountNumber {get;set;}
		public Integer ChequeNumber {get;set;}
		public Decimal ChequeAmount {get;set;}
		public String ChequeIsThirdParty {get;set;}

		public Cheque(){
			BankNumber = '';
			AgencyName = '';
			AgencyNumber = 0;
			AccountNumber = 0;
			ChequeNumber = 0;
			ChequeAmount = 0;
		}
	}

	public class Consortium{
		public String GroupName {get;set;}
		public String Quota {get;set;}
		public String Situation {get;set;}
		public Decimal Amount {get;set;}
		public String Administration {get;set;}
		public Date ReleaseDate {Get;set;}

		public Consortium(){
			GroupName = '';
			Quota = '';
			Situation = '';
			Amount = 0;
			Administration = '';
			//ReleaseDate - default date??
		}
	}

	public class UsedVehicle{
		public Decimal Amount {get;set;}
		public Decimal OtherAmount1 {get;set;}
		public Decimal OtherAmount2 {get;set;}
		public Decimal Change1 {get;set;}
		public Decimal Change2 {get;set;}
		public Decimal Change3 {get;set;}

		public UsedVehicle(){
			Amount = 0;
			OtherAmount1 = 0;
			OtherAmount2 = 0;
			Change1 = 0;
			Change2 = 0;
			Change3 = 0;
		}
	}
}
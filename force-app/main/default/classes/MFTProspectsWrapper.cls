// Created by Jatin Gupta | Changi Consulting | Aug-2020.

public class MFTProspectsWrapper {
	
    public String LeadHubID {get;set;}
	public String CustomeruniqueNumber {get;set;} 
	public String Salutation {get;set;} 
	public String FirstName {get;set;} 
	public String Surname {get;set;} 
	public String CompanyName {get;set;} 
	public String Gender {get;set;} 
	public String Language {get;set;} 
	public String EmploymentStatus {get;set;} 
	public String Industry {get;set;} 
	public String Occupation {get;set;} 
	public String LeadSource {get;set;} 
	public String Mobile {get;set;} 
	public String Phone {get;set;} 
	public String HomePhone {get;set;} 
	public String Email {get;set;} 
	public String Email2 {get;set;} 
	public String Address {get;set;} 
	public String Address1 {get;set;} 
	public String Address2 {get;set;} 
	public String Address3 {get;set;} 
	public String Address4 {get;set;} 
	public String EnquirySource {get;set;} 
	public String NationalityCode {get;set;} 
	public String AccountOwner {get;set;} 
	public String LastEditDate {get;set;} 
	public String LeadOwner {get;set;} 
	public String Brand {get;set;} 
	public String Model {get;set;} 
	public String Demo {get;set;} 
	public String Quote {get;set;} 
	public String Order {get;set;} 
	public String Lost {get;set;} 
    public String EventType {get;set;} 
	public String LostSaleRef {get;set;} 
	public String TypeNewUsed {get;set;} 
	public String VehicleIdentificationNumber {get;set;} 
	public string Price {get;set;} 
	public string VAT {get;set;} 
	public String DeliveryDate {get;set;} 
	public String InvoiceDate {get;set;} 
	public String RegistrationDate {get;set;} 

	public MFTProspectsWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'Lead Hub ID') {
						LeadHubID = parser.getText();
					}else if (text == 'Customer unique Number') {
						CustomeruniqueNumber = parser.getText();
					} else if (text == 'Salutation') {
						Salutation = parser.getText();
					} else if (text == 'First Name') {
						FirstName = parser.getText();
					} else if (text == 'Surname') {
						Surname = parser.getText();
					} else if (text == 'Company Name') {
						CompanyName = parser.getText();
					} else if (text == 'Gender') {
						Gender = parser.getText();
					} else if (text == 'Language') {
						Language = parser.getText();
					} else if (text == 'Employment Status') {
						EmploymentStatus = parser.getText();
					} else if (text == 'Industry') {
						Industry = parser.getText();
					} else if (text == 'Occupation') {
						Occupation = parser.getText();
					} else if (text == 'Lead Source') {
						LeadSource = parser.getText();
					} else if (text == 'Mobile') {
						Mobile = parser.getText();
					} else if (text == 'Phone') {
						Phone = parser.getText();
					} else if (text == 'Home Phone') {
						HomePhone = parser.getText();
					} else if (text == 'Email') {
						Email = parser.getText();
					} else if (text == 'Email 2') {
						Email2 = parser.getText();
					} else if (text == 'Address') {
						Address = parser.getText();
					} else if (text == 'Address__1') {
						Address1 = parser.getText();
					} else if (text == 'Address__2') {
						Address2 = parser.getText();
					} else if (text == 'Address__3') {
						Address3 = parser.getText();
					} else if (text == 'Address__4') {
						Address4 = parser.getText();
					} else if (text == 'Enquiry Source') {
						EnquirySource = parser.getText();
					} else if (text == 'Nationality Code') {
						NationalityCode = parser.getText();
					} else if (text == 'Account Owner') {
						AccountOwner = parser.getText();
					} else if (text == 'Last Edit Date') {
						LastEditDate = parser.getText();
					} else if (text == 'Lead Owner') {
						LeadOwner = parser.getText();
					} else if (text == 'Brand') {
						Brand = parser.getText();
					} else if (text == 'Model') {
						Model = parser.getText();
					} else if (text == 'Demo') {
						Demo = parser.getText();
					} else if (text == 'Quote') {
						Quote = parser.getText();
					} else if (text == 'Order') {
						Order = parser.getText();
					} else if (text == 'Lost') {
						Lost = parser.getText();
                    } else if (text == 'Event Type') {
						EventType = parser.getText();
                    } else if (text == 'Lost Sale Ref') {
						LostSaleRef = parser.getText();
					} else if (text == 'Type (NEW/USED)') {
						TypeNewUsed = parser.getText();
					} else if (text == 'Vehicle Identification Number') {
						VehicleIdentificationNumber = parser.getText();
					} else if (text == 'Price') {
						Price = parser.getText();
					} else if (text == 'VAT') {
						VAT = parser.getText();
					} else if (text == 'Delivery Date') {
						DeliveryDate = parser.getText();
					} else if (text == 'Invoice Date') {
						InvoiceDate = parser.getText();
					} else if (text == 'Registration Date') {
						RegistrationDate = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'Prospects JSON unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<MFTProspectsWrapper> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfJSON2Apex(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
	private static List<MFTProspectsWrapper> arrayOfJSON2Apex(System.JSONParser p) {
        List<MFTProspectsWrapper> res = new List<MFTProspectsWrapper>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new MFTProspectsWrapper(p));
        }
        return res;
    }
}
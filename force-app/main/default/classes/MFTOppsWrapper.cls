// Created by Jatin Gupta | Changi Consulting | Sept-2021.

public class MFTOppsWrapper {

	public String CXPID {get;set;} 
	public String JobRouterID {get;set;} 
	public String User {get;set;} 
	public String UpdateDate {get;set;} 
	public String FirstName {get;set;} 
	public String LastName {get;set;} 
	public String Mobile {get;set;} 
	public String Phone {get;set;} 
	public String Email {get;set;} 
	public String Brand {get;set;} 
	public String PrimaryModelInterest {get;set;} 
	public String Description {get;set;} 
	public String Budget {get;set;} 
	public String TestDriveDate {get;set;} 
	public String Stage {get;set;} 
	public String TradeIn {get;set;} 
	public String TradeInValue {get;set;} 
	public String SalesPrice {get;set;} 
	public String LocalDepositAmount {get;set;} 
	public String OfferApplied {get;set;} 
	public String VAT {get;set;} 
	public String VIN {get;set;} 
	public String HandoverDate {get;set;} 
	public String DateLost {get;set;} 
	public String LossCategory {get;set;} 
	public String LossReason {get;set;} 
	public String LossNotes {get;set;} 
	public String RetargetDate {get;set;} 
	public String CopiedeLossCategory {get;set;} 
	public String CopiedeLossReason {get;set;} 

	public MFTOppsWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'CXP ID') {
						CXPID = parser.getText();
					} else if (text == 'JobRouter ID') {
						JobRouterID = parser.getText();
					} else if (text == 'User') {
						User = parser.getText();
					} else if (text == 'Update Date') {
						UpdateDate = parser.getText();
					} else if (text == 'First Name') {
						FirstName = parser.getText();
					} else if (text == 'Last name') {
						LastName = parser.getText();
					} else if (text == 'Mobile') {
						Mobile = parser.getText();
					} else if (text == 'Phone') {
						Phone = parser.getText();
					} else if (text == 'Email') {
						Email = parser.getText();
					} else if (text == 'Brand') {
						Brand = parser.getText();
					} else if (text == 'Primary Model Interest') {
						PrimaryModelInterest = parser.getText();
					} else if (text == 'Description') {
						Description = parser.getText();
					} else if (text == 'Budget') {
						Budget = parser.getText();
					} else if (text == 'Test Drive Date') {
						TestDriveDate = parser.getText();
					} else if (text == 'Stage') {
						Stage = parser.getText();
					} else if (text == 'Trade In') {
						TradeIn = parser.getText();
					} else if (text == 'Trade in Value') {
						TradeinValue = parser.getText();
					} else if (text == 'Sales Price') {
						SalesPrice = parser.getText();
					} else if (text == 'Local Deposit Amount') {
						LocalDepositAmount = parser.getText();
					} else if (text == 'Offer Applied') {
						OfferApplied = parser.getText();
					} else if (text == 'VAT %') {
						VAT = parser.getText();
					} else if (text == 'VIN') {
						VIN = parser.getText();
					} else if (text == 'Handover Date') {
						HandoverDate = parser.getText();
					} else if (text == 'Date Lost') {
						DateLost = parser.getText();
					} else if (text == 'Loss Category') {
						LossCategory = parser.getText();
					} else if (text == 'Loss Reason') {
						LossReason = parser.getText();
					} else if (text == 'Loss Notes') {
						LossNotes = parser.getText();
					} else if (text == 'Retarget Date') {
						RetargetDate = parser.getText();
					} else if (text == 'Copie de Loss Category') {
						CopiedeLossCategory = parser.getText();
					} else if (text == 'Copie de Loss Reason') {
						CopiedeLossReason = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<MFTOppsWrapper> parse(String json) {
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
	

    private static List<MFTOppsWrapper> arrayOfJSON2Apex(System.JSONParser p) {
        List<MFTOppsWrapper> res = new List<MFTOppsWrapper>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new MFTOppsWrapper(p));
        }
        return res;
    }
}
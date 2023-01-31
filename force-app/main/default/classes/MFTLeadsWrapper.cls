// Created by Jatin Gupta | Changi Consulting | Aug-2020.

public class MFTLeadsWrapper {

    public String ExternalOemReferenceID {get;set;} 
    public String LeadHubID {get;set;}
	public String FirstName {get;set;} 
	public String Surname {get;set;} 
	public String Status {get;set;} 
	public String EnquiryType {get;set;} 
	public String Mobile {get;set;} 
	public String Phone {get;set;} 
	public String Email {get;set;} 
	public String TaskActionOwner {get;set;} 
	public String DateLeadAssigned {get;set;}
    public String RejectConvOwner {get;set;}
    public String LostLeadComments {get;set;} 
	public String EditedOn {get;set;} 
	public String EditedAt {get;set;} 

	public MFTLeadsWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'External Oem Reference ID') {
						ExternalOemReferenceID = parser.getText();
					} else if (text == 'Lead Hub ID') {
						LeadHubID = parser.getText();
					}else if (text == 'First Name') {
						FirstName = parser.getText();
					} else if (text == 'Surname') {
						Surname = parser.getText();
					} else if (text == 'Status') {
						Status = parser.getText();
					} else if (text == 'Enquiry Type') {
						EnquiryType = parser.getText();
					} else if (text == 'Mobile') {
						Mobile = parser.getText();
					} else if (text == 'Phone') {
						Phone = parser.getText();
					} else if (text == 'Email') {
						Email = parser.getText();
					} else if (text == 'Task Action Owner') {
						TaskActionOwner = parser.getText();
					} else if (text == 'Date Lead Assigned') {
						DateLeadAssigned = parser.getText();
                    } else if (text == 'Reject\\Conv User') {
                        RejectConvOwner = parser.getText();
					} else if (text == 'Lost Lead Comments') {
						LostLeadComments = parser.getText();
					} else if (text == 'Edited On') {
						EditedOn = parser.getText();
					} else if (text == 'Edited At') {
						EditedAt = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'Leads JSON unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<MFTLeadsWrapper> parse(String json) {
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
	
    private static List<MFTLeadsWrapper> arrayOfJSON2Apex(System.JSONParser p) {
        List<MFTLeadsWrapper> res = new List<MFTLeadsWrapper>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new MFTLeadsWrapper(p));
        }
        return res;
    }
}
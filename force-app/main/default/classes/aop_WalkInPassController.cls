public with sharing class aop_WalkInPassController {
    public CampaignMember campaignMemb {get; set;} 
    public Contact eventRepContact {get;set;}
    public Campaign eventRepCampaign {get; set;}
    public string formatDate {get;set;}
    public string upperEventName {get;set;}
    public Request__c eventReq;
    
    public aop_WalkInPassController(ApexPages.StandardController stdController)
    { 
	    this.eventReq = (Request__c)stdController.getRecord();
	    campaignMemb = getCampaignMemb();
	    eventRepContact = getEventRepContact();
	    eventRepCampaign = getEventRepCampaign();
	    upperEventName = getUpperEventName();
	    formatDate = getFormatDate();
	}
	
    public aop_WalkInPassController()
    {
        
    }
    
    public CampaignMember getCampaignMemb()
    {
        ID campaignID = eventReq.Campaign__c;
        ID contactID = eventReq.aop_Customer__c;
        List<CampaignMember> campaignMembers = [SELECT  Id, CampaignId, aop_Session_Start__c, aop_Booking_Id__c  
        										FROM CampaignMember WHERE CampaignId =: campaignID AND ContactId =: contactID];
        if(!campaignMembers.isEmpty())
        {
            return campaignMembers[0];
        }
        else
        {
            return null;
        }
    }
    
    public string getUpperEventName()
    {
        List<Campaign> camps = [SELECT Name FROM Campaign WHERE Id =: eventReq.Campaign__c LIMIT 1];
        if(!camps.isEmpty())
        {
        	Campaign camp = camps[0];
        	String upperName = camp.Name.toUpperCase();
        	return upperName;
        }  
        return null;
    }
    
    public String getFormatDate()
    {
        if(campaignMemb != null)
        {
	        DateTime theTime  = campaignMemb.aop_Session_Start__c;
	        Date returnDate = Date.newInstance(theTime.year(), theTime.month(), theTime.day());
	        String returnString = string.valueOf(returnDate.day()) + '/' + string.valueOf(returnDate.month()) + '/' + string.valueOf(returnDate.year());
	        System.debug(returnString);
	        return returnString;
        }
        return null;
    }
    
    public Contact getEventRepContact()
    {
        ID contactID = eventReq.aop_Customer__c;        
        List<Contact> contacts = [SELECT  Name, FirstName, LastName FROM Contact WHERE Id =: contactID];
        if(!contacts.isEmpty())
        {
        	return contacts[0];
        }
        return null;
    }
    
    public Campaign getEventRepCampaign()
    {
        ID campaignID = eventReq.Campaign__c;
        List<Campaign> campaigns = [SELECT  Name, aop_Event_TimeZone__c FROM Campaign WHERE Id =: campaignID];
        if(!campaigns.isEmpty())
        {
        	return campaigns[0];
        }
        return null;
    }
    
}
public with sharing class aop_ISOCodeController {
    public string upperLastName{get;set;}
    public string upperFirstName{get;set;}
    public string upperCampaignName{get;set;}
    public CampaignMember campaignMemb;

Public aop_ISOCodeController()
    {   
    }

    public aop_ISOCodeController(ApexPages.StandardController stdController)
    { 
    	this.campaignMemb = (CampaignMember)stdController.getRecord(); 
        upperLastName = getUpperName();
        upperFirstName = getUpperFirstName();
        upperCampaignName = getUpperEvent();     
	}

    public Contact getContact()
    {
        List<Contact> contacts = [SELECT FirstName, LastName FROM Contact WHERE Id =: campaignMemb.ContactId];
        return contacts[0];
    }

    public string getUpperEvent()
    {
        List<Campaign> campaigns = [SELECT Name FROM Campaign WHERE Id =: campaignMemb.CampaignId LIMIT 1];
        if(!campaigns.isEmpty())
        {
        	Campaign campaign = campaigns[0];
        	if(campaign != null)
        {
	            return campaign.Name.toupperCase();
	        }
        }
        return null;
    }

    public string getUpperName()
    {
        Contact con = getContact();
        string lastName = con.LastName;
        string uperName = lastName.toUpperCase();
        return uperName;
    }

    public string getUpperFirstName()
    {
        Contact con = getContact();
        string firstName = con.FirstName;
        string uperName = firstName.toUpperCase();
        return uperName;
    }

}
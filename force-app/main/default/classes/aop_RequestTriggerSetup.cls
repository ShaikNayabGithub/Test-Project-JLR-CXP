public class aop_RequestTriggerSetup {
    public static List<RecordType> GetRecordTypes()
    {
        List<RecordType> returnList = [SELECT Id, DeveloperName, Name, sObjectType FROM RecordType 
                                        WHERE sObjectType =: 'Request__c' OR sObjectType =: 'Account'];             
        return returnList;
    }

    public static List<Account> GetAccounts(List<Request__c> requestList)
    {
        List<string> codeList = new List<string>();
        for(Request__c evReq : requestList)
        {
            if(evReq.Preferred_Retailer_Code__c != null && evReq.aop_Country__c != null)
            {
                aop_NationalityToISOCode__c countryMap = aop_NationalityToISOCode__c.getInstance(evReq.aop_Country__c);
                string isoCode = '';
                if(countryMap != null)
                {
                     isoCode  = countryMap.aop_ISO_Code__c;
                }
                string dealerCode = 'J'  + isoCode + evReq.Preferred_Retailer_Code__c;
                codeList.add(dealerCode);
            }
            
        }
        List<Account> returnList = [SELECT Id, Secondary_Dealer_Code__c, ownerid,
                                    (SELECT Name, Id, StageName, IsClosed FROM Account.Opportunities)
                                    FROM Account
                                    WHERE Secondary_Dealer_Code__c IN :codeList];          
        return returnList;
    }

    public static List<Contact> GetContacts(List<Id> idList)
    {
        List<Contact> returnList = [SELECT Id, AccountId, FirstName, LastName, Email, aop_Country__c, Language__c FROM Contact WHERE Id IN:  idList];
        return returnList;
    }

    public static List<aop_Area_Configuration__c> GetConfigs()
    {
        List<aop_Area_Configuration__C> eventConfigs  = [SELECT aop_Community_Permission_Set__c, aop_Community_URL__c, 
                                                            aop_Qualify_if_Opportunity__c, aop_Minimum_Age__c, 
                                                            aop_New_Record_Owner__c, aop_Auto_Qualification__c,   
                                                            aop_Auto_Rejection_Enabled__c, aop_Checkfront_Instance__c, 
                                                            aop_Customer_Queue_Name__c, aop_Retailer_Queue_Name__c 
                                                            FROM aop_Area_Configuration__c];
        return eventConfigs;
    }
}
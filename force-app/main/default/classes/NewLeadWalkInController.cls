public class NewLeadWalkInController {
    
    public class accountWrapper{
        @AuraEnabled
        public string accId{get;set;}
        @AuraEnabled
        public string accFName{get;set;}
        @AuraEnabled
        public string accLName{get;set;}
        @AuraEnabled
        public string accEmail{get;set;}
        @AuraEnabled
        public string accMobile{get;set;}
        
        public accountWrapper(string accId, string accFName, string accLName, string accEmail, string accMobile){
            this.accId = accId;
            this.accFName = accFName;
            this.accLName = accLName;
            this.accEmail = accEmail;
            this.accMobile = accMobile;
        }
    }
    
    public class opportunityWrapper{
        @AuraEnabled
        public string OppId{get;set;}
        @AuraEnabled
        public string OppName{get;set;}
        @AuraEnabled
        public string OppBrand{get;set;}
        @AuraEnabled
        public string OppPrimaryModel{get;set;}
        @AuraEnabled
        public string OppPrimaryContact{get;set;}
        @AuraEnabled
        public string OppOwner{get;set;}
        @AuraEnabled
        public string OppCreatedDate{get;set;}
        @AuraEnabled
        public string StageName{get;set;}
        
        public opportunityWrapper(string OppId, string OppName, string OppBrand, string OppPrimaryModel, string OppPrimaryContact, string OppOwner, string OppCreatedDate, string stageName){
            this.OppId = OppId;
            this.OppName = OppName;
            this.OppBrand = OppBrand;
            this.OppPrimaryModel = OppPrimaryModel;
            this.OppPrimaryContact = OppPrimaryContact;
            this.OppOwner = OppOwner;
            this.OppCreatedDate = OppCreatedDate;
            this.StageName = StageName;
        }
    }
    
    @AuraEnabled
    public static List<string> getEnquiryValues(){
        List<string> valuesToReturn = new list<string>();
        /*List<Schema.PicklistEntry> rtList = Lead.Enquiry_Type__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry Rt : rtList)
            valuesToReturn.add(Rt.getValue());*/
        valuesToReturn.add('Approved Pre-owned');
        valuesToReturn.add('e-Brochure');
        valuesToReturn.add('Extended Warranty');
        valuesToReturn.add('Find & Price Enquiry');
        valuesToReturn.add('Fleet and Business Enquiry');
        valuesToReturn.add('Generic');
        valuesToReturn.add('JLR Event');
        valuesToReturn.add('KMI');
        valuesToReturn.add('Mobile Lead');
        valuesToReturn.add('Online Reservation');
        valuesToReturn.add('Personalised Brochure Request');
        valuesToReturn.add('Resurrected Lead');
        valuesToReturn.add('Test Drive Request');
        valuesToReturn.add('Vehicle Configuration');
        return valuesToReturn;
    }
    
    @AuraEnabled
    public static List<string> getBrandValues(){
        List<string> valuesToReturn = new list<string>();
        List<Schema.PicklistEntry> rtList = Lead.Brand_Offline__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry Rt : rtList)
            valuesToReturn.add(Rt.getValue());
        return valuesToReturn;
    }
    
    @AuraEnabled
    public static Map<Object,List<String>> getBrandModelsMap(){
        return getDependentPicklistValues(Lead.Vehicle_Model_Offline__c);
    }
    
    @AuraEnabled
    public static boolean getCampaignCreateAccess(){
        return Schema.sObjectType.campaign.fields.name.isCreateable();
    }
    
    public static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        if(controllerField == null){
            return null;
        } 
        
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
        
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';		//It is used to decode the characters of the validFor fields. 
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        system.debug('dependentPicklistValues:::'+dependentPicklistValues);
        return dependentPicklistValues;
    }
    
    @AuraEnabled
    public static List<accountWrapper> getAccount(string firstName, string lastName, string phoneNo, string email){
        List<accountWrapper> wrapperToReturn = new List<accountWrapper>();
        List<String> excludedEmails = new List<String>();
        if(system.label.Lead_Walkin_Excluded_Emails.contains(';'))
        	excludedEmails.addAll(system.label.Lead_Walkin_Excluded_Emails.split(';'));
        else if(system.label.Lead_Walkin_Excluded_Emails.contains(','))
            excludedEmails.addAll(system.label.Lead_Walkin_Excluded_Emails.split(','));
        
        if(excludedEmails.contains(email))
            email = '';
        
        /*** Commented as part of CXPD-1670 *****
        string query = 'Select id, firstname, lastname, PersonEmail, PersonMobilePhone from account where recordtype.name = \'Individual\' and ';
        if(string.isNotBlank(firstName))
            query += 'firstName = \'' + firstName + '\' and ';
        if(string.isNotBlank(lastName))
            query += 'lastName = \'' + lastName + '\' and ';
        if(string.isNotBlank(phoneNo))
            query += 'PersonMobilePhone = \'' + phoneNo + '\' and ';
        if(string.isNotBlank(email))
            query += 'PersonEmail = \'' + email + '\' and ';
        query = query.removeEnd('and ');
		*** Commented as part of CXPD-1670 *****/     

        String query = 'SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone FROM Account WHERE RecordType.DeveloperName = \'Individual\' ';
        // Check First Name
        if(String.isNotBlank(firstName))
            query += ' AND firstName = \'' + firstName + '\' ';
        // Check Last Name
        if(String.isNotBlank(lastName))
            query += ' AND lastName = \'' + lastName + '\' ';
        // Check Email and Mobile
        if(String.isNotBlank(email) && String.isNotBlank(phoneNo)) {
            query += ' AND (PersonEmail = \'' + email + '\' OR PersonMobilePhone = \'' + phoneNo + '\') ';
        } else if(String.isNotBlank(email)) {
            query += ' AND PersonEmail = \'' + email + '\' ';
        } else if(String.isNotBlank(phoneNo)) {
            query += ' AND PersonMobilePhone = \'' + phoneNo + '\' ';
        }
		System.debug('<<< Query >>> ' + query);        
        
        for(account acc : database.query(query)) {
            wrapperToReturn.add(new accountWrapper(acc.id, acc.firstname, acc.lastname, acc.PersonEmail, acc.PersonMobilePhone));
        }
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static List<opportunityWrapper> getOpportunity(string accountId){
        List<opportunityWrapper> wrapperToReturn = new List<opportunityWrapper>();
        for(Opportunity opp : [SELECT Id, Name, Brand__r.Name, Primary_Model_Interest__r.Name, Account.FirstName, Account.LastName, Owner.Name, CreatedDate, StageName FROM Opportunity WHERE AccountId =: accountId AND IsClosed = false]){
            wrapperToReturn.add(new opportunityWrapper(opp.Id, opp.Name, opp.Brand__r.Name, opp.Primary_Model_Interest__r.Name, opp.Account.FirstName + ' ' + opp.Account.LastName, opp.Owner.Name, string.valueOf(opp.CreatedDate), opp.StageName));
        }
        return wrapperToReturn;
    }
    
    @AuraEnabled
    public static string saveLead(Lead newLead, string campaignId){
        List<Account> ExistingAccountList = [Select lastname, personemail, PersonMobilePhone from account 
                                             where Recordtype.DeveloperName = 'Individual' 
                                             and lastname =: newLead.lastname 
                                             and ((personemail =: newLead.email and personemail != null) or (PersonMobilePhone =: newLead.MobilePhone And PersonMobilePhone != null))];
        if(ExistingAccountList.size() == 0){
            system.debug('campaignId::'+campaignId);
            List<Vehicle_Specification__c> brand = [Select Id FROM Vehicle_Specification__c WHERE RecordType.developername='Make' AND Name = :newLead.Brand_Offline__c LIMIT 1];
            Id leadProcessStreamlinedRTID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Process - Streamlined').getRecordTypeId();
            newLead.RecordTypeId = leadProcessStreamlinedRTID;
            newLead.Status = 'New';
            newLead.LeadSource = 'Walk-in';            
            newLead.Brand__c = brand.size() > 0 ? brand[0].Id : null; 
            newLead.Mapping_Primary_Model_of_Interest__c = newLead.Vehicle_Model_Offline__c; 
            insert newLead; 
            
            if(string.isNotBlank(campaignId)){
                CampaignMember mem = new CampaignMember (campaignid=campaignId, leadid=newLead.id);
                insert mem;}
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(newLead.Id);  
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            return lcr.getOpportunityId();
        }
        else
            return 'Existing Account';
    }
    
    @AuraEnabled
    public static string saveOpportunity(Lead newLead, string campaignId, string accountId){
        List<Vehicle_Specification__c> brand = [Select Id FROM Vehicle_Specification__c WHERE RecordType.developername='Make' AND Name = :newLead.Brand_Offline__c LIMIT 1];
        List<Vehicle_Specification__c> vehicle = [Select Id FROM Vehicle_Specification__c WHERE RecordType.developername='Model' AND Make__c =: brand[0].Id and Name = :newLead.Vehicle_Model_Offline__c and Is_Currently_Sold__c = true and Not_Sold_In__c EXCLUDES ('MENA') LIMIT 1];
        Opportunity oppRec = new Opportunity();
        oppRec.name = newLead.firstname + ' ' + newLead.lastname;
        oppRec.stagename = 'Qualified';
        oppRec.accountId = accountId;
        oppRec.CampaignId = campaignId;
        oppRec.recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Process with RDA').getRecordTypeId();
        oppRec.Brand__c = brand.size() > 0 ? brand[0].Id : null; 
       	oppRec.Primary_Model_Interest__c = vehicle.size() > 0 ? vehicle[0].Id : null;
        oppRec.Type = 'Product';
        oppRec.LeadSource  = 'Walk-in';
        oppRec.Purchase_Type__c = 'New Vehicle';
        oppRec.Enquiry_Type__c = newLead.Enquiry_Type__c;
        oppRec.closedate = system.today();
        insert oppRec;
        
        return oppRec.id;
    }
    
}
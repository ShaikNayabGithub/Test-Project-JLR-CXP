public class AvokaFormInformation_Retriever {

    public AvokaFormInformation Retrieve(Request__c requestRecord)   
    {    
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        List<String> splitCode = requestRecord.Request_Source__c.split('-');
        
        AvokaFormMapping_Local__c localMapping = AvokaFormMapping_Local__c.getInstance(splitCode[2]);
        if (AvokaFormMapping_Local__c.getInstance(splitCode[2])==null){
            this.SetBrand(avokaFormInformation, splitCode[0]);
            this.SetRecordType(avokaFormInformation, splitCode[1]);
            this.SetLocal(avokaFormInformation, requestRecord.Country_Code__c);
        } else {
            avokaFormInformation = this.Retrieve(requestRecord.Request_Source__c);
        }
        return avokaFormInformation;
    }
    
    public AvokaFormInformation Retrieve(string formCode)
    {
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        List<String> splitCode = formCode.split('-');
        
        this.SetBrand(avokaFormInformation, splitCode[0]);
        this.SetRecordType(avokaFormInformation, splitCode[1]);
        this.SetLocal(avokaFormInformation, splitCode[2]);
        
        return avokaFormInformation;
    }
    
    private void SetBrand(AvokaFormInformation avokaFormInformation, string brand)
    {
        AvokaFormMapping_Brand__c brandMapping = AvokaFormMapping_Brand__c.getInstance(brand);
        if(brandMapping == null) { return; }
        String brandName = brandMapping.Salesforce_Value__c;
        
        List<Vehicle_Specification__c> brands = [Select Id From Vehicle_Specification__c Where Name=:brandName Limit 1];
        if(brands.size() == 0){ return; }
        avokaFormInformation.Brand = brands[0];
    }
    
    private void SetRecordType(AvokaFormInformation avokaFormInformation, string avokaRecordType)
    {
        AvokaRequestTypeToLeadRecordType__c recordTypeMapping = AvokaRequestTypeToLeadRecordType__c.getInstance(avokaRecordType);
        if(recordTypeMapping == null) { return; }
        
        String recordType = recordTypeMapping.Lead_Record_Type__c;
        avokaFormInformation.AssignToRetailerQueue = recordTypeMapping.AssignToRetailerQueue__c;
        
        List<RecordType> recordTypes = [Select Id From RecordType  Where SobjectType = 'Lead' And IsActive = true And DeveloperName=:recordType Limit 1];
        if(recordTypes.size() == 0){ return; }
        avokaFormInformation.RecordType = recordTypes[0];
    }
    private void SetLocal(AvokaFormInformation avokaFormInformation, string local)
    {
        local = local.toLowerCase(local);
        AvokaFormMapping_Local__c localMapping = AvokaFormMapping_Local__c.getInstance(local);
        if(localMapping == null) { return; }
        
        avokaFormInformation.CountryISOCode = localMapping.Country_ISO_Code__c;
        avokaFormInformation.RecordCurrency = localMapping.Currency__c;
        
        if(String.isEmpty(localMapping.NSC_Queue__c)){ return; }
        List<Group> nscQueues = [Select Id from Group Where Name=:localMapping.NSC_Queue__c AND Type = 'Queue' limit 1];
        if(nscQueues.size() == 0){ return; }
        avokaFormInformation.NSCQueue = nscQueues[0];
    }
}
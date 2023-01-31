public class A_DMSMessager_Siebel extends A_DMSMessager implements I_HttpMessager_Siebel{
    private static final string DMLInsertOperator = 'Insert';
    private static final string DMLUpdateOperator = 'Update';
        
    public A_DMSMessager_Siebel (HttpRequestFactory httpRequestFactory, DMS_Connection__c connectionDetails)
    {
        super(httpRequestFactory, connectionDetails);
    }

    protected override string BuildSOAPHeaders()
    {
        return String.format('<UsernameToken xmlns="http://siebel.com/webservices">{0}</UsernameToken>'+
                '<PasswordText xmlns="http://siebel.com/webservices">{1}</PasswordText>'+
                '<SessionType xmlns="http://siebel.com/webservices">None</SessionType>', new String []{ connectionDetails.Username__c, connectionDetails.Password__c });
    }
    
    
    public string GetSiebelDMLAction(string dmsRecordId)
    {
        if(String.isEmpty(dmsRecordId)){ return DMLInsertOperator; }
        return DMLUpdateOperator;
    }
    
    public string GetDMSInnerException(string soapBody)
    {
        string[] splitOnNodeStart = soapBody.split('<siebelf:errormsg>');
        if(splitOnNodeStart.size() < 2){ return ''; }
        return splitOnNodeStart[1].split('</siebelf:errormsg>')[0];
    }
}
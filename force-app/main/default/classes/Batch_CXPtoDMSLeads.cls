public class Batch_CXPtoDMSLeads implements Database.Batchable<sobject>, Database.AllowsCallouts, schedulable{

    public void execute( schedulableContext sc ){
        Database.executeBatch( new Batch_CXPtoDMSLeads());
    }
    
    Public Database.QueryLocator Start( Database.BatchableContext bc ){
        String query = label.CXP_to_DMS_Lead;
        return Database.getQueryLocator( query );
    }
    
    Public void execute( Database.BatchableContext bc, List<Lead> scope ){
        List<Lead> leadsToUpdate = new List<Lead>();
        BaseMulesoftConnector conn = new BaseMulesoftConnector(Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_CXP_TO_CDK);
        for(Lead rec : scope){
            if(rec.createddate <= Datetime.now().addMinutes(integer.valueOf(label.CXP_to_DMS_Lead_Interval))){
                CXPtoCDKWrapper.inputWrapper requestPayload = new  CXPtoCDKWrapper.inputWrapper(rec.id);
                String body = Json.serialize(requestPayload);
                System.debug(body);
                String response = conn.doCallout(HttpMethods.POST, body);
                If(response.containsAny(label.CDK_Lead_Success_Message ))
                    leadsToUpdate.add(new Lead(id = rec.id, Sent_To_CDK__c = True));
                else
                    leadsToUpdate.add(new Lead(id = rec.id, CDK_Integration_Error__c = response, CDK_Error__c = true));
            }
        }
        
        if(leadsToUpdate.size()>0)
            update leadsToUpdate;
    }
    
    Public void finish( Database.BatchableContext bc ){}
}
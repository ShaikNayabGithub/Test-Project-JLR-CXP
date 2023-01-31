public class Vista_OpportunityOrderCancelledLogic {
    public static string EVENTCANCELLED = 'Order Cancelled';
    public Opportunity setCancelledDateAndStageIfCancelled(OpportunityLineItem oppLineItem, Vista_RequestCollection  requestCollection){
        
        Opportunity opp = null;
        Vista_Request__c latestRequest = null;
        Map<id,Vista_Request__c> requestsForOrderNumber =  new   Map<id,Vista_Request__c>();
        Vista_RequestWrapper[] reqList = new List<Vista_RequestWrapper>(); 
        //get all vista request groups via the vista ordernumber 
        List<Vista_RecordGroup> orderRecordGroups = requestCollection.RecordGroups.get(oppLineItem.Vista_Order_Number__c );
        
        if(orderRecordGroups != null && orderRecordGroups.size() > 0){
            for(Vista_RecordGroup vGroup : orderRecordGroups){
                if(vGroup.Request != null){
                    //put all requests in a map and a wrapper list for ordering
                    requestsForOrderNumber.put(vGroup.Request.id,vGroup.Request);
                    reqList.add(new Vista_RequestWrapper(vGroup.Request));
                }
                
            }
            if(requestsForOrderNumber.size() >0){
                //sorted by createdDate .. for now
                reqList.sort();
                //get first one most recent
                latestRequest =requestsForOrderNumber.get(reqList[0].req.id);        
            }
            System.debug('Latest Request '+Json.serializePretty(latestRequest));
            if(latestRequest != null && latestRequest.CommonStatusPoint__c != null &&latestRequest.CommonStatusPoint__c == EVENTCANCELLED){
                opp = new Opportunity();                
                
                if(latestRequest.EventDateTime__c != null){
                    opp.Id = oppLineItem.OpportunityId;
                    opp.Date_Cancelled_Time__c = latestRequest.EventDateTime__c;  
                }            
                               
                OpportunityLineItem originalOpp = requestCollection.OpportunityLineItems.get(oppLineItem.Vista_Order_Number__c);
                                
                //if at won stage and cancelled set back to negotiation
                if(originalOpp != null && originalOpp.Opportunity.IsWon != null && originalOpp.Opportunity.IsWon == true){
                    opp.StageName = 'Negotiation';
                    //if this doesnt work may need to set recordtype aswell
                }                
            }
        }
        return opp;
    }
    
    
}
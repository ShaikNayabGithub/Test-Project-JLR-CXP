global class Vista_RequestWrapper implements Comparable{
    
    public Vista_Request__c req;
    
    public Vista_RequestWrapper(Vista_Request__c re){
        
        req = re;
    }
    global integer compareTo(Object compareTo){
        Vista_RequestWrapper compareToReq = (Vista_RequestWrapper)compareTo;
        integer returnValue = 0;
        if(req.EventDateTime__c == null || compareToReq.req.EventDateTime__c == null || req.EventDateTime__c == compareToReq.req.EventDateTime__c   ){
            
             if(req.CreatedDate < compareToReq.req.CreatedDate){
            returnValue = 1;
            
        }else if(req.CreatedDate > compareToReq.req.CreatedDate){
            returnValue = -1;
        }
            
            
        }else{
                  if(req.EventDateTime__c < compareToReq.req.EventDateTime__c){
            returnValue = 1;
            
        }else if(req.EventDateTime__c > compareToReq.req.EventDateTime__c){
            returnValue = -1;
        }
            
        }
       
        return returnValue;
    }

}
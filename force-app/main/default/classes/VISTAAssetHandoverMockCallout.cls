@isTest
global class VISTAAssetHandoverMockCallout implements HttpCalloutMock {
    global static Boolean isSuccess;
    global VISTAAssetHandoverMockCallout(Boolean istrue){
        isSuccess = istrue;
    }
    global HttpResponse respond(HttpRequest req) {
        // Create a fake response
        String body ='' ;
         if(isSuccess)
         body = body+'<?xml version="1.0" encoding="UTF-8"?><ConfirmPostBrandOccurrence xmlns="http://www.ford.com/oagis" xmlns:oa="http://www.openapplications.org/oagis/9" systemEnvironmentCode="Test" versionID="1.0.0" releaseID="9.0"><oa:ApplicationArea><oa:Sender><oa:LogicalID>Land Rover</oa:LogicalID><oa:ComponentID>CXP</oa:ComponentID><oa:TaskID>Handover</oa:TaskID><oa:AuthorizationID>CXP</oa:AuthorizationID></oa:Sender><oa:CreationDateTime>2019-09-04T11:48:01Z</oa:CreationDateTime><oa:BODID>D58DC24590894920BD5DF099ACE351A3</oa:BODID></oa:ApplicationArea><DataArea><oa:Confirm /><PostBrandOccurrence><AcceptRejectIndicator>A</AcceptRejectIndicator></PostBrandOccurrence></DataArea></ConfirmPostBrandOccurrence>';
        else
          body = body+'<?xml version="1.0" encoding="UTF-8"?><ConfirmPostBrandOccurrence xmlns="http://www.ford.com/oagis" xmlns:oa="http://www.openapplications.org/oagis/9" systemEnvironmentCode="Test" versionID="1.0.0" releaseID="9.0"><oa:ApplicationArea><oa:Sender><oa:LogicalID>Land Rover</oa:LogicalID><oa:ComponentID>CXP</oa:ComponentID><oa:TaskID>Handover</oa:TaskID><oa:AuthorizationID>CXP</oa:AuthorizationID></oa:Sender><oa:CreationDateTime>2019-09-04T11:48:01Z</oa:CreationDateTime><oa:BODID>D58DC24590894920BD5DF099ACE351A3</oa:BODID></oa:ApplicationArea><DataArea><oa:Confirm /><PostBrandOccurrence><AcceptRejectIndicator>R</AcceptRejectIndicator><Messages><Message><MessageType>EXCEPTION</MessageType><Description>Interface Error details logged in VISTA_INTERFACE_ERROR table, key = 6268319  Exception details logged in VISTA_ERROR_LOG table, key = 3444674</Description></Message></Messages></PostBrandOccurrence></DataArea></ConfirmPostBrandOccurrence>';
         
        HttpResponse res = new HttpResponse();
        res.setBody(body);
        res.setStatusCode(200);
        res.setStatus('OK');
        return res; 
    }
}
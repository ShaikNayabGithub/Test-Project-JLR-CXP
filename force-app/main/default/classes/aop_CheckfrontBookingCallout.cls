public class aop_CheckfrontBookingCallout {
    public string GetCalloutResponse(aop_Area_Configuration__c areaConfig, string queryString)
    {
        if(areaConfig != null  && areaConfig.aop_Checkfront_Token__c != null && areaConfig.aop_Checkfront_Instance__c != null)
        {
            Http httpReq = new Http();
       		HttpRequest req = new HttpRequest();
            String endPoint = 'https://'+ areaConfig.aop_Checkfront_Instance__c + queryString;
            req.setEndpoint(endPoint);
            req.setHeader('Authorization', 'Basic ' + areaConfig.aop_Checkfront_Token__c);
            req.setHeader('X-On-Behalf', '1');
            req.setMethod('GET');
            HttpResponse  restResp = httpReq.send(req);
            string rawResponse = restResp.getBody();
            system.debug(rawResponse);
            
            rawResponse = rawResponse.replace('"limit":', '"aoplimit":');
            rawResponse = rawResponse.replace('"time":', '"aoptime":');
            rawResponse = rawResponse.replace('"id":','"aopid":');     
            rawResponse = rawResponse.replace('"1":','"one":');
            return rawResponse;
        }
        else
        {
            throw new aop_AOPException('Insufficient data on Area Configuration to get booking details from Checkfront');
        }

    }

    public aop_CheckfrontCalloutBookingParser.aop_Container ParseToCalloutBooking(string jsonString)
    {
        string toParse = '{"Checkfront":' + jsonString + '}';
        JSONParser parser = JSON.createParser(toParse);
        parser.nextToken();
        parser.nextToken();
        parser.nextToken();
        aop_CheckfrontCalloutBookingParser.aop_Container newBooking = (aop_CheckfrontCalloutBookingParser.aop_Container)parser.readValueAs(aop_CheckfrontCalloutBookingParser.aop_Container.class);
        return newBooking;
    }

    public aop_CheckfrontItemCalloutParser.aop_Container ParseToCalloutItem(string jsonString)
    {
        jsonString = '{"Checkfront":' + jsonString + '}';
        JSONParser parser = JSON.createParser(jsonString);
        parser.nextToken();
        parser.nextToken();
        parser.nextToken();
        aop_CheckfrontItemCalloutParser.aop_Container  newItem = (aop_CheckfrontItemCalloutParser.aop_Container)parser.readValueAs(aop_CheckfrontItemCalloutParser.aop_Container.class);
        return newItem;
    }

}
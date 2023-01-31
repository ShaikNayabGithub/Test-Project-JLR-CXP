@RestResource(urlMapping='/checkfrontitemwebservice')
global class aop_CheckfrontItemWebService {
    @HttpPost
    global static void doPost()
    {
        RestRequest restReq = RestContext.request;
        string itemString = restReq.requestBody.toString();
        system.debug(itemString);
        itemString = ReplaceRestrictedChars(itemString);
        system.debug('Item string ' + itemString);
        JSONParser parser = JSON.createParser(itemString); 
        aop_CheckfrontItemParser.aop_ItemContainer newContainer = (aop_CheckfrontItemParser.aop_ItemContainer)parser.readValueAs(aop_CheckfrontItemParser.aop_ItemContainer.class);
        aop_CheckfrontItemLogic businessLogic = new aop_CheckfrontItemLogic();
        if(newContainer != null)
        {
            businessLogic.HandleCampaignCreation(newContainer);
        }
    }

    public static string ReplaceRestrictedChars(string itemString)
    {
        itemString = itemString.replace('"image":[]', '"image":{}');
        itemString = itemString.replace('"image":""', '"image":{}');
        itemString = itemString.replace('"meta":"{', '"meta":{');
        itemString = itemString.replace('\\"', '"');
        itemString = itemString.replace('}"', '}');
        itemString = itemString.replace('"1":', '"one":');
        itemString = itemString.replace('"2":', '"two":');
        itemString = itemString.replace('"3":', '"three":');
        itemString = itemString.replace('"4":', '"four":');
        itemString = itemString.replace('"5":', '"five":');
        itemString = itemString.replace(':"{"param"', ':{"param"');
        return itemString;
    }

}
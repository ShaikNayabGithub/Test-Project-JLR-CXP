/**
 * Created by caleb@argologic.com.au on 8/02/2021.
 */

public with sharing class InvocableGetCommunityUrl
{
    @InvocableMethod(Label='Get Community Url')
    public static List<string> getCommunityUrl()
    {
        return new List<String> { Constants.RETAILER_COMMUNITY_URL };
    }
}
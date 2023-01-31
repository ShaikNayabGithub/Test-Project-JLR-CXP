/**
 * Created by caleb on 17/10/2019.
 */

public with sharing class NidasuOpportunityUpdateAttributeDto
{
    public String NidasuOpportunityId {get; set;}
    public String SalesforceOpportunityId {get; set;}
    public Boolean isSuccess {get; set;}
}
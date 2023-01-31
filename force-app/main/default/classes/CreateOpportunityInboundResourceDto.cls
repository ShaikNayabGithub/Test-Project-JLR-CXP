/**
 * Created by caleb@argologic.com.au on 26/05/2020.
 */

global with sharing class CreateOpportunityInboundResourceDto extends BaseResourceDto
{
    global CreateOpportunityInboundAttributeDto Attributes {get; set;}
}
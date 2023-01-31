/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class GetOpportunitiesResponseDto extends BaseOpportunityResponseDto{

    global GetOpportunitiesResponseDto()
    {
        super();
    }

    global GetOpportunitiesResponseDto(List<Opportunity> opps)
    {
        this();
        this.Data = transform(opps);
    }

    public static OpportunityResourceDto transform(Opportunity op)
    {

        OpportunityResourceDto resource = new OpportunityResourceDto();
        resource.Id = op.Id;
        resource.Type = 'Opportunity';
        resource.Attributes.Name = op.Name;
        //resource.Attributes.Priority = op.Status__c;
        resource.Attributes.BuyerNameLast = op.Account.LastName;
        resource.Attributes.Stage = op.StageName;
        resource.Attributes.AccountName = op.Account.Name;
        resource.Attributes.AccountId = op.AccountId;
        resource.Attributes.SaleType = op.Sale_Type__c;
        resource.Attributes.Pricebook2Id = op.Pricebook2Id;
        resource.Attributes.LeadSource = op.LeadSource;
        resource.Attributes.ContactPhoneMobile = op.Primary_Contact__r.MobilePhone;
        resource.Attributes.ContactEmail = op.Primary_Contact__r.Email;
        resource.Attributes.PrimaryContactName = op.Primary_Contact__r.Name;
        resource.Attributes.PrimaryContactId = op.Primary_Contact__c;
        resource.Attributes.EnquiryType = op.Enquiry_Type__c;
        resource.Attributes.HasMatchedCorporatePartnerAccount = (op.Corporate_Partner_Account__c != null);
        resource.Attributes.MatchedCorporatePartnerAccountId = op.Corporate_Partner_Account__c;
        resource.Attributes.VehicleBrand = op.Brand__r.Name;
        resource.Attributes.VehicleModel = op.Primary_Model_Interest__r.Name;
        resource.Attributes.IsPersonAccount = op.Account.IsPersonAccount;
        if (resource.Attributes.HasMatchedCorporatePartnerAccount){
            resource.Attributes.MatchedCorporatePartnerAccountName = op.Corporate_Partner_Account__r.Name;

        }
        return resource;
    }


    public static List<OpportunityResourceDto> transform(List<Opportunity> opps)
    {
        List<OpportunityResourceDto> resources = new List<OpportunityResourceDto>();
        for (Opportunity op : opps)
        {
            resources.add(transform(op));
        }
        return resources;
    }
}
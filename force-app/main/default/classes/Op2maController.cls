/**
 * Created by caleb on 19/09/2019.
 */

public with sharing class Op2maController
{
    public static final String OPPORTUNITY_STAGE_LOST = 'Lost';
    public static final String OPPORTUNITY_STAGE_SENT = 'Lost - Sent to Concierge';

    public static final String LEAD_STATUS_LOST = 'Lost';

    public static final String CONCIERGE_STATUS_READY = 'Ready for Concierge';
    public static final String CONCIERGE_STATUS_SENT = 'Sent to Concierge';

    public static final String TEST_DRIVE_YES = 'Yes';
    public static final String TEST_DRIVE_NO = 'No';

    public static final List<String> OP2MA_LEAD_REQUIRED_FIELDS = new List<String> {};
    public static final List<String> OP2MA_OPPORTUNITIES_REQUIRED_FIELDS = new List<String> { 'Make', 'Dealership' };

    public static final Date CXP_GO_LIVE_LOST_OPPORTUNITY_SERVICE_DATETIME = Date.newInstance(2020, 12, 1);

    public static GetLostOpportunitiesResponseDto getLostOpportunities(GetLostOpportunitiesRequestDto request)
    {
        List<Opportunity> unfilterdOpps = [SELECT id,
				 CloseDate,
                 Date_Lost__c,
				 CreatedDate,
				 Account.FirstName,
				 Account.LastName,
				 Mobile_Phone__c,
				 Phone__c,
                 Email__c,
				 Brand__r.Name,
				 Primary_Model_Interest__r.Name,
                 Retailer_Name__c,
                 Owner.Name,
				 Test_Drive_Reached__c,
                 Owner.Contact.Account.Dealer_CI_Code__c,
                 Owner.Contact.Account.Dealer_CI_Code_2__c,
                 LeadSource,
				 Campaign.Name,
                 Enquiry_Type__c,
                 Primary_Contact__r.FirstName,
                 Primary_Contact__r.LastName,
                 Primary_Contact__r.MobilePhone,
                 Primary_Contact__r.HomePhone,
                 Primary_Contact__r.Email,
                 Retailer_Loss_Type__c
            FROM Opportunity
            WHERE StageName = :OPPORTUNITY_STAGE_LOST
            AND Sent_to_lost_opportunities__c = FALSE
            AND Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
            AND CreatedDate > :CXP_GO_LIVE_LOST_OPPORTUNITY_SERVICE_DATETIME
            AND Enquiry_Type__c != 'Service Interception'
            AND (
                    Primary_Contact__r.All_Communications_opt_out__c != TRUE
                    OR Primary_Contact__r.HasOptedOutOfEmail != TRUE
            )
        ];

        List<Opportunity> openOppsLast90Days = [
                SELECT
                        Primary_Contact__c,
                        AccountId,
                        Brand__r.Name,
                        Primary_Model_Interest__r.Name
                FROM Opportunity
                WHERE StageName != :OPPORTUNITY_STAGE_LOST
                AND Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
                AND CreatedDate >= :Date.today().addDays(-90)
        ];

        Set<String> removeString = new Set<String>();
        for (Opportunity opp : openOppsLast90Days)
        {
            removeString.add(string.valueOf(opp.Primary_Contact__c) + opp.AccountId);
        }

        List<Opportunity> opps = new List<Opportunity>();
        for (Opportunity opp : unfilterdOpps)
        {
            if (!removeString.contains(string.valueOf(opp.Primary_Contact__c) + opp.AccountId))
            {
                opps.add(opp);
            }
        }

        List<String> accountIds = new List<String>();
        for (Opportunity opp : opps) accountIds.add(opp.Owner.Contact.AccountId);
        Map<String, Account> parentToChildJagMap = ChildDealershipUtility.getParentToChildDealershipMap(accountIds, true);
        Map<String, Account> parentToChildLandroverMap = ChildDealershipUtility.getParentToChildDealershipMap(accountIds, false);
        List<OpportunityLostDataDto> opportunityDtos = new List<OpportunityLostDataDto>();

        for (Opportunity o : opps)
        {
            OpportunityLostDataDto opportunityDto = new OpportunityLostDataDto();
            opportunityDto.Id = o.Id;
            opportunityDto.StartDate = String.valueOf(o.CreatedDate);
            opportunityDto.CloseDate = String.valueOf(o.Date_Lost__c) + ' 00:00:00';
            opportunityDto.NameFirst = o.Primary_Contact__r.FirstName;
            opportunityDto.NameLast = o.Primary_Contact__r.LastName;
            opportunityDto.PhoneMobile = o.Primary_Contact__r.MobilePhone;
            opportunityDto.PhoneHome = o.Primary_Contact__r.HomePhone;
            opportunityDto.Email = o.Primary_Contact__r.Email;
            opportunityDto.Make = o.Brand__r.Name;
            opportunityDto.Model = o.Primary_Model_Interest__r.Name;
            if (o.Brand__r.Name == Constants.MAKE_NAME_JAGUAR && parentToChildJagMap.containsKey(o.Owner.Contact.AccountId))
            {
                opportunityDto.Dealership = parentToChildJagMap.get(o.Owner.Contact.AccountId).Name;
            }
            else if (o.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER && parentToChildLandroverMap.containsKey(o.Owner.Contact.AccountId))
            {
                opportunityDto.Dealership = parentToChildLandroverMap.get(o.Owner.Contact.AccountId).Name;
            }
            opportunityDto.SalesPerson = o.Owner.Name;
            opportunityDto.TestDrive = o.Test_Drive_Reached__c ? TEST_DRIVE_YES : TEST_DRIVE_NO;
            opportunityDto.LeadSource = o.LeadSource;
            opportunityDto.CampaignName = o.Campaign.Name;
            opportunityDto.LostReason = o.Retailer_Loss_Type__c;
            opportunityDto.EnquiryType = o.Enquiry_Type__c;
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            opportunityDto.OpportunityLink = baseUrl + '/lightning/r/Opportunity/' + o.Id + '/view';
            // do not add if a mandatory field is missing
            //List<String> missingFields = JSONManditoryFieldValidator.getMissingFields(opportunityDto, OP2MA_OPPORTUNITIES_REQUIRED_FIELDS);
            opportunityDtos.add(opportunityDto);
        }
        GetLostOpportunitiesResponseDto response = new GetLostOpportunitiesResponseDto();
        response.Data = opportunityDtos;
        return response;
    }

    private static Map<String, Account> getDealerCodeToDealerMap(List<Opportunity> opps)
    {
        // get list of dealer codes
        Set<String> dealerCodes = new Set<String>();
        for (Opportunity o : opps)
        {
            if (o.Brand__r.Name == Constants.MAKE_NAME_JAGUAR)
            {
                dealerCodes.add(o.Owner.Contact.Account.Dealer_CI_Code__c);
            }
            else if (o.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER)
            {
                dealerCodes.add(o.Owner.Contact.Account.Dealer_CI_Code_2__c);
            }
        }
        // get dealers
        List<Account> dealersJaguar = [
                SELECT Id, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                FROM Account
                WHERE Dealer_CI_Code__c IN :dealerCodes AND ParentId != NULL
        ];
        List<Account> dealersLandRover = [
                SELECT Id, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                FROM Account
                WHERE Dealer_CI_Code_2__c IN :dealerCodes AND ParentId != NULL
        ];
        // make code to dealer map
        Map<String, Account> dealerCodeToDealerMap = new Map<String, Account>();
        for (Account dealer : dealersJaguar)
        {
            dealerCodeToDealerMap.put(dealer.Dealer_CI_Code__c, dealer);
        }
        for (Account dealer : dealersLandRover)
        {
            dealerCodeToDealerMap.put(dealer.Dealer_CI_Code_2__c, dealer);
        }
        return dealerCodeToDealerMap;
    }


    public static UpdateLostOpportunitiesResponseDto updateLostOpportunities(UpdateLostOpportunitiesRequestDto request)
    {
        List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity WHERE Id IN :request.OpportunityIds];
        for (Opportunity o : opps)
        {
            o.Sent_to_lost_opportunities__c = true;
        }
        Database.update(opps, false);
        UpdateLostOpportunitiesResponseDto response = new UpdateLostOpportunitiesResponseDto();
        response.IsSuccess = true;
        return response;
    }

    public static GetLeadsResponseDto getConciergeLeads(GetLeadsRequestDto request)
    {
        // todo - adjust field mapping if required and map vehicle field
        List<Lead> leads = [SELECT id, FirstName, LastName, MobilePhone, Email, Phone, PostalCode, CreatedDate, Enquiry_Type__c, Campaign__r.Name, Brand__r.Name, Primary_Model_Interest__r.Name, LeadSource, Preferred_Retailer__r.Name
                FROM Lead
                WHERE IsConverted = false
                AND Concierge_Status__c = :CONCIERGE_STATUS_READY
                AND Status != :LEAD_STATUS_LOST
                AND Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
                AND CreatedDate >= :JlrDateParser.parseStringAsDate(Label.Op2ma_Service_Go_Live_Date)
        ];
        List<LeadConciergeDataDto> leadDtos = new List<LeadConciergeDataDto>();
        for (Lead l : leads)
        {
            LeadConciergeDataDto leadDto = new LeadConciergeDataDto();
            leadDto.Id = l.Id;
            leadDto.NameFirst = l.FirstName;
            leadDto.NameLast = l.LastName;
            leadDto.PhoneMobile = l.MobilePhone;
            leadDto.Email = l.Email;
            leadDto.PhoneHome = l.Phone;
            leadDto.PostCode = l.PostalCode;
            leadDto.StartDate = String.valueOf(l.CreatedDate);
            leadDto.LeadSource = l.LeadSource;
            leadDto.Make = l.Brand__r.Name;
            leadDto.Model = l.Primary_Model_Interest__r.Name;
            leadDto.EnquiryType = l.Enquiry_Type__c;
            leadDto.Campaign = l.Campaign__r.Name;
            leadDto.FranchiseName = l.Preferred_Retailer__r.Name;
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            leadDto.LeadLink = baseUrl + '/lightning/r/Lead/' + l.Id + '/view';
            // Do not add to response if mandatory fields are missing
            List<String> missingFields = JSONManditoryFieldValidator.getMissingFields(leadDto, OP2MA_LEAD_REQUIRED_FIELDS);
            if (missingFields.size() > 0)
            {
                System.debug('Missing fields = ' + missingFields);
            }
            else
            {
                leadDtos.add(leadDto);
            }
        }
        GetLeadsResponseDto response = new GetLeadsResponseDto();
        response.Data = leadDtos;
        return response;
    }

    public static UpdateConciergeLeadsResponseDto updateConciergeLeads(UpdateConciergeLeadsRequestDto request)
    {
        List<Lead> leads = [SELECT Id, Concierge_Status__c FROM Lead WHERE Id IN :request.LeadIds];
        for (Lead l : leads)
        {
            l.Concierge_Status__c = CONCIERGE_STATUS_SENT;
        }
        List<Database.SaveResult> results = Database.update(leads, false);
        UpdateConciergeLeadsResponseDto response = new UpdateConciergeLeadsResponseDto();

        for (Database.SaveResult res : results)
        {
            if (!res.isSuccess())
            {
                ErrorDto err = new ErrorDto(res.getErrors()[0]);
                response.addError(err);
            }
        }

        return response;
    }

}
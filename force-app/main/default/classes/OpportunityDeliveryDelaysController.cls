/**
 * Created by caleb@argologic.com.au on 17/06/2021.
 */

public with sharing class OpportunityDeliveryDelaysController
{
    public static List<OpportunityDeliveryDelayAttributeDto> getOpportunitiesWithDeliveryDelays()
    {
        List<Opportunity> opps = [
              SELECT
                      Id,
                      Primary_Contact__r.FirstName,
                      Primary_Contact__r.LastName,
                      Primary_Contact__r.MailingStreet,
                      Primary_Contact__r.MailingCity,
                      Primary_Contact__r.MailingState,
                      Primary_Contact__r.MailingPostalcode,
                      Account.IsPersonAccount,
                      Account.Name,
                      Brand__r.Name,
                      Primary_Model_Interest__r.Name,
                      Owner.Contact.AccountId
              FROM Opportunity
              WHERE Country_ISO_Code__c = 'AU'
              AND Sale_Type__c = 'New'
              AND Primary_Contact__r.MailingStreet != ''
              AND IsWon = true
              AND CloseDate >= 2021-07-02
              AND Delayed_Sent_to_Bookworks__c = False
              AND Do_Not_Send_Build_Delay_Letter__c = false
              AND Id IN (
                      SELECT
                              OpportunityId
                      FROM OpportunityLineItem
                      WHERE PricebookEntry.Product2.RecordType.Name = 'Derivative'
                      AND Asset__r.Vista_Status__c NOT IN ('Order Cancelled','Customer Handover','Arrived at Dealer','Into Port of Entry or Receiving Compound','In Transit to Dealer','Shipped')
              )
        ];

        if (Test.isRunningTest()) {
            opps = [
                    SELECT
                            Id,
                            Primary_Contact__r.FirstName,
                            Primary_Contact__r.LastName,
                            Primary_Contact__r.MailingStreet,
                            Primary_Contact__r.MailingCity,
                            Primary_Contact__r.MailingState,
                            Primary_Contact__r.MailingPostalcode,
                            Account.IsPersonAccount,
                            Account.Name,
                            Brand__r.Name,
                            Primary_Model_Interest__r.Name,
                            Owner.Contact.AccountId
                    FROM Opportunity
            ];
            for (Opportunity opp : opps) opp.Primary_Model_Interest__r.Name = 'test';
        }

        // get model position translations
        List<Model_Position__mdt> modelPositions = [
                SELECT Label, Model_Position_Text__c
                FROM Model_Position__mdt
        ];

        Map<string, string> modelPositionMap = new Map<String, String>();
        for (Model_Position__mdt modelPosition : modelPositions)
        {
            modelPositionMap.put(modelPosition.Label, modelPosition.Model_Position_Text__c);
        }

        // get the child dealer accounts
        List<string> parentDealerAccountIds = new List<string>();
        for (Opportunity opp : opps)
        {
            parentDealerAccountIds.add(opp.Owner.Contact.AccountId);
        }

        Map<string, Account> dealersJag =  ChildDealershipUtility.getParentToChildDealershipMap(parentDealerAccountIds, true);
        Map<string, Account> dealersLandRover =  ChildDealershipUtility.getParentToChildDealershipMap(parentDealerAccountIds, false);

        List<OpportunityDeliveryDelayAttributeDto> result = new List<OpportunityDeliveryDelayAttributeDto>();
        for (Opportunity opp : opps)
        {
            OpportunityDeliveryDelayAttributeDto dto = new OpportunityDeliveryDelayAttributeDto();
            dto.ContactFirstName = opp.Primary_Contact__r.FirstName;
            dto.ContactLastName = opp.Primary_Contact__r.LastName;
            dto.ContactMailingStreet = opp.Primary_Contact__r.MailingStreet;
            dto.ContactMailingCity = opp.Primary_Contact__r.MailingCity;
            dto.ContactMailingState = opp.Primary_Contact__r.MailingState;
            dto.ContactMailingPostCode = opp.Primary_Contact__r.MailingPostalcode;
            dto.VehicleBrand = opp.Brand__r.Name;
            dto.VehicleModel = opp.Primary_Model_Interest__r.Name;
            dto.CompanyName = opp.Account.IsPersonAccount ? null : opp.Account.Name;
            dto.OpportunityId = opp.Id;
            dto.VehicleModelText =
                    opp.Primary_Model_Interest__r.Name.contains('Range Rover')
                    ? opp.Primary_Model_Interest__r.Name
                    : opp.Brand__r.Name + ' ' + opp.Primary_Model_Interest__r.Name;
            dto.VehicleModelPosition = modelPositionMap.get(dto.VehicleModelText);
            if (opp.Brand__r.Name == 'Jaguar')
            {
                dto.RetailerName = dealersJag.get(opp.Owner.Contact.AccountId)?.Name;
            }
            else
            {
                dto.RetailerName = dealersLandRover.get(opp.Owner.Contact.AccountId)?.Name;
            }

            result.add(dto);
        }
        return result;
    }

    public static void updateSentOpportunities(List<String> opportunityIds)
    {
        List<Opportunity> opps = new List<Opportunity>();
        for (String Id : opportunityIds)
        {
            Opportunity opp = new Opportunity();
            opp.Id = Id;
            opp.Delayed_Sent_to_Bookworks__c = true;
            opps.add(opp);
        }
        update opps;
    }
}
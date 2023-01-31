/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 12/11/2019.
 */

@IsTest
public class TestClass_Op2maControllerDataBuilder {

    public static List<Lead> generateLeads()
    {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 10; i++)
        {
            Lead lead = new Lead();
            lead.FirstName = 'Test';
            lead.LastName = 'Test' + i;
            lead.Purchase_Type__c = 'New Vehicle';
            lead.Email = 'test@test.com';
            lead.Concierge_Status__c = Op2maController.CONCIERGE_STATUS_READY;
            leads.add(lead);
        }
        insert leads;
        return leads;
    }

    public static List<Opportunity> generateOpportunities()
    {
        List<Opportunity> opps = TestClass_OpportunityCreator.createOppList_Australia();
        for (Opportunity o : opps)
        {
            o.StageName = Op2maController.OPPORTUNITY_STAGE_LOST;
            o.Approved_Lost_Date_Time__c = DateTime.now();
            o.Agency_Loss_Type__c = 'Brand Image';
            o.Agency_Loss_Description__c = 'Test';
            o.Agency_Loss_Category__c = 'Experience';


        }
        update opps;
        return opps;
    }
}
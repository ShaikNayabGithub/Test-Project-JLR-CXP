/**
 * Created by caleb@argologic.com.au on 18/12/2020.
 */

@IsTest
public with sharing class JlrServiceErrorSubmitter_Test
{
    public static string getBodyOpp(string dealerCode)
    {
        CreateOpportunityInboundAttributeDto atts1 = new CreateOpportunityInboundAttributeDto();
        atts1.DealerCode = dealerCode;
        atts1.ProspectNameFirst = 'fn';
        atts1.ProspectNameLast = 'ln';
        CreateOpportunityInboundResourceDto res1 = new CreateOpportunityInboundResourceDto();
        res1.Attributes = atts1;
        CreateOpportunityInboundRequestDto req1 = new CreateOpportunityInboundRequestDto();
        req1.Data = res1;
        return JSON.serialize(req1);
    }

    public static string getBodyLead(string dealerCode)
    {
        LeadAttributesDto atts1 = new LeadAttributesDto();
        atts1.DealerCode = dealerCode;
        atts1.ProspectNameFirst = 'fn';
        atts1.ProspectNameLast = 'ln';
        LeadResourceDto res1 = new LeadResourceDto();
        res1.Attributes = atts1;
        CreateLeadRequestDto req1 = new CreateLeadRequestDto();
        req1.Data = res1;
        return JSON.serialize(req1);
    }

    public static Jlr_Service_Error__c makeJlrServiceError(Boolean isOpp, string dealerCode)
    {
        if (isOpp)
        {
            Jlr_Service_Error__c err = new Jlr_Service_Error__c();
            err.Endpoint__c = '/v1/Opportunities/';
            err.Body__c = getBodyOpp(dealerCode);
            return err;
        }
        else
        {
            Jlr_Service_Error__c err = new Jlr_Service_Error__c();
            err.Endpoint__c = '/v1/leads/';
            err.Body__c = getBodyLead(dealerCode);
            return err;
        }
    }

    public static Jlr_Service_Error__c makeOppExporterError(String id)
    {
        Jlr_Service_Error__c err = new Jlr_Service_Error__c();
        err.Endpoint__c = 'InvocableOpportunityExportProcessor';
        err.Body__c = '["' + id + '"]';
        return err;
    }


    @IsTest
    public static void test1()
    {
        List<Jlr_Service_Error__c> errors = new List<Jlr_Service_Error__c>
        {
                makeJlrServiceError(true, '1234'),
                makeJlrServiceError(true, '1234'),
                makeJlrServiceError(false, '1234'),
                makeJlrServiceError(false, '1234'),
                makeJlrServiceError(false, '2345'),
                makeJlrServiceError(true, '2345'),
                makeOppExporterError('00606000012ttfuAAA'),
                makeOppExporterError('00606000012ttfuAAA'),
                makeOppExporterError('00606000013ttfuAAA')
        };
        insert errors;

        test.startTest();
        JlrServiceErrorAuReSubmitter reSubmitter = new JlrServiceErrorAuReSubmitter();
        SchedulableContext sc = null;
        reSubmitter.execute(sc);
        test.stopTest();
    }
}
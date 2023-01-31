/**
 * Created by caleb@argologic.com.au on 16/12/2020.
 */

public with sharing class JlrServiceErrorAuReSubmitter implements Schedulable
{
    public static List<string> TO_ADDRESSES = new List<String> { 'caleb@argologic.com.au', 'dhughe40@partner.jaguarlandrover.com' };

    // email every day
    public void execute(SchedulableContext ctx)
    {
        reSubErrors();

        List<Jlr_Service_Error__c> errors = [
                SELECT
                        Endpoint__c,
                        Body__c,
                        Error_Message__c
                FROM Jlr_Service_Error__c
                WHERE Is_Processed__c = FALSE
        ];

        if (errors.size() > 0)
        {
            sendEmails(errors);
        }
    }

    public static void sendEmails(List<Jlr_Service_Error__c> errors)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(TO_ADDRESSES);
        mail.saveAsActivity = false;
        mail.setSubject('Jlr Service Error');
        string body = 'There are currently ' + errors.size() + '\n';
        for (Jlr_Service_Error__c err : errors)
        {
            body += err.Endpoint__c + ', ' + err.Error_Message__c + '\n';
        }
        mail.setPlainTextBody(body);
        mail.setCharset('UTF-8');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static void reSubErrors()
    {
        List<Jlr_Service_Error__c> errors = [
                SELECT
                        Endpoint__c,
                        Body__c,
                        Error_Message__c
                FROM Jlr_Service_Error__c
                WHERE Is_Processed__c = FALSE
        ];

        List<Jlr_Service_Error__c> errsDeduped = dedupeErrors(errors);
        List<Jlr_Service_Error__c> toUpdate = new List<Jlr_Service_Error__c>();
        for (Jlr_Service_Error__c err : errsDeduped)
        {
            if (tryResubmit(err))
            {
                toUpdate.addAll(allMatching(err, errors));
            }
        }

        for (Jlr_Service_Error__c err : toUpdate)
        {
            err.Is_Processed__c = true;
            err.Datetime_Processed__c = Datetime.now();
        }
        update toUpdate;
    }

    public static Boolean tryResubmit(Jlr_Service_Error__c err)
    {
        if (err.Endpoint__c == '/v1/Opportunities/')
        {
            try
            {
                CreateOpportunityInboundRequestDto obj = (CreateOpportunityInboundRequestDto)JSON.deserialize(err.Body__c, CreateOpportunityInboundRequestDto.class);
                OpportunityInboundController.create(obj);
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
        if (err.Endpoint__c == '/v1/leads/')
        {
            try
            {
                CreateLeadRequestDto obj = (CreateLeadRequestDto)JSON.deserialize(err.Body__c, CreateLeadRequestDto.class);
                LeadsController.create(obj);
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }

        }
        if (err.Endpoint__c == 'InvocableOpportunityExportProcessor')
        {
            try
            {
                List<Id> ids = (List<Id>)JSON.deserialize(err.Body__c, List<Id>.class);
                InvocableOpportunityExportProcessor.sendOppsToMule(ids);
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }

        }
        return false;
    }

    public static List<Jlr_Service_Error__c> dedupeErrors(List<Jlr_Service_Error__c> errs)
    {
        List<Jlr_Service_Error__c> result = new List<Jlr_Service_Error__c>();
        for (Integer i = 0; i < errs.size(); i++)
        {
            Boolean isDupe = false;
            for (Integer j = 0; j < i; j++)
            {
                if (isDupe(errs[i], errs[j]))
                {
                    isDupe = true;
                    break;
                }
            }
            if (!isDupe) result.add(errs[i]);
        }
        return result;
    }

    public static List<Jlr_Service_Error__c> allMatching(Jlr_Service_Error__c err, List<Jlr_Service_Error__c> errors)
    {
        List<Jlr_Service_Error__c> result = new List<Jlr_Service_Error__c>();
        for (Jlr_Service_Error__c e : errors)
        {
            if (isDupe(e, err))
            {
                result.add(e);
            }
        }
        return result;
    }

    public static Boolean isDupe(Jlr_Service_Error__c err1, Jlr_Service_Error__c err2)
    {
        if (err1.Endpoint__c != err2.Endpoint__c) return false;

        if (err1.Endpoint__c == '/v1/Opportunities/')
        {
            CreateOpportunityInboundRequestDto obj1 = (CreateOpportunityInboundRequestDto)JSON.deserialize(err1.Body__c, CreateOpportunityInboundRequestDto.class);
            CreateOpportunityInboundRequestDto obj2 = (CreateOpportunityInboundRequestDto)JSON.deserialize(err2.Body__c, CreateOpportunityInboundRequestDto.class);
            if (obj1.Data.Attributes.ProspectNameFirst == obj2.Data.Attributes.ProspectNameFirst
                    && obj1.Data.Attributes.ProspectNameLast == obj2.Data.Attributes.ProspectNameLast
                    && obj1.Data.Attributes.DealerCode == obj2.Data.Attributes.DealerCode)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        if (err1.Endpoint__c == '/v1/leads/')
        {
            CreateLeadRequestDto obj1 = (CreateLeadRequestDto)JSON.deserialize(err1.Body__c, CreateLeadRequestDto.class);
            CreateLeadRequestDto obj2 = (CreateLeadRequestDto)JSON.deserialize(err2.Body__c, CreateLeadRequestDto.class);
            if (obj1.Data.Attributes.ProspectNameFirst == obj2.Data.Attributes.ProspectNameFirst
                    && obj1.Data.Attributes.ProspectNameLast == obj2.Data.Attributes.ProspectNameLast
                    && obj1.Data.Attributes.DealerCode == obj2.Data.Attributes.DealerCode)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        if (err1.Endpoint__c == 'InvocableOpportunityExportProcessor')
        {
            List<Id> ids1 = (List<Id>)JSON.deserialize(err1.Body__c, List<Id>.class);
            List<Id> ids2 = (List<Id>)JSON.deserialize(err1.Body__c, List<Id>.class);
            return ids1.equals(ids2);
        }
        return true;
    }

}
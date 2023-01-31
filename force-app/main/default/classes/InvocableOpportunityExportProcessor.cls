/**
 * Author : Grant Millgate - Argo Logic - grant@argologic.com.au
 *
 */
public class InvocableOpportunityExportProcessor {

    public InvocableOpportunityExportProcessor(){

    }

    @InvocableMethod(Label='Send To Vital')
    public static void process(List<Id> ids) {
        System.debug('Process : ' + ids);
        processCallout(ids);
    }

    @Future(Callout=true)
    public static void processCallout(List<Id> ids)
    {
        try
        {
            sendOppsToMule(ids);
        }
        catch (Exception ex)
        {
            ServiceErrorLogger.logError('InvocableOpportunityExportProcessor', JSON.serialize(ids), ex);
        }
    }

    public static void sendOppsToMule(List<Id> ids)
    {
        List<Opportunity> opps = [SELECT id, Primary_Contact__c, ContactId, Account.PersonContactId, Account.IsPersonAccount
        FROM Opportunity
        WHERE Id IN :ids AND (ContactId != null OR Account.IsPersonAccount = True)];

        List<String> contactIds = new List<String>();
        for (Opportunity opp : opps)
        {
            if (opp.Account.IsPersonAccount)
            {
                contactIds.add(opp.Account.PersonContactId);
            }
            else
            {
                contactIds.add(opp.ContactId);
            }
        }

        Map<String, Contact> contacts = new Map<String, Contact>(
        [
                SELECT
                        Id,
                        Title,
                        FirstName,
                        LastName,
                        Jaguar_Whitemail_Opt_Out__c,
                        Jaguar_Email_Opt_Out__c,
                        Jaguar_Phone_Opt_Out__c,
                        Jaguar_SMS_Opt_Out__c,
                        Land_Rover_Whitemail_Opt_Out__c,
                        Land_Rover_Email_Opt_Out__c,
                        Land_Rover_Phone_Opt_Out__c,
                        Land_Rover_SMS_Opt_Out__c,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingPostalCode,
                        MobilePhone,
                        Phone,
                        Email
                FROM Contact WHERE Id IN :contactIds
        ]
        );

        List<Opportunity> ops = [
                SELECT
                        Id,
                        Type,
                        Campaign.Name,
                        Enquiry_Type__c,
                        Enquiry_Year__c,
                        Enquiry_Body_Type__c,
                        Enquiry_Engine_Description__c,
                        CreatedDate,
                        Account.IsPersonAccount,
                        ContactId,
                        Owner.Contact.Account.Dealer_CI_Code__c,
                        Owner.Contact.Account.Dealer_CI_Code_2__c,
                        Primary_Contact__c,
                        Primary_Contact__r.Title,
                        Primary_Contact__r.FirstName,
                        Primary_Contact__r.LastName,
                        Primary_Contact__r.Jaguar_Whitemail_Opt_Out__c,
                        Primary_Contact__r.Jaguar_Email_Opt_Out__c,
                        Primary_Contact__r.Jaguar_Phone_Opt_Out__c,
                        Primary_Contact__r.Jaguar_SMS_Opt_Out__c,
                        Primary_Contact__r.Land_Rover_Whitemail_Opt_Out__c,
                        Primary_Contact__r.Land_Rover_Email_Opt_Out__c,
                        Primary_Contact__r.Land_Rover_Phone_Opt_Out__c,
                        Primary_Contact__r.Land_Rover_SMS_Opt_Out__c,
                        Primary_Contact__r.MailingStreet,
                        Primary_Contact__r.MailingCity,
                        Primary_Contact__r.MailingState,
                        Primary_Contact__r.MailingPostalCode,
                        Primary_Contact__r.MobilePhone,
                        Primary_Contact__r.Phone,
                        Primary_Contact__r.Email,
                        Brand__r.Name,
                        Primary_Model_Interest__r.Name,
                        LeadSource,
                        CampaignId,
                        Asset__r.Brand__r.Name,
                        Asset__r.Model__r.Name,
                        Asset__r.Model_Year__c,
                        Purchase_Type__c,
                        Dealer_CI_Code__c,
                        Dealer_CI_Code_2__c,
                        Description,
                        Revised_Trade_in_Brand__c,
                        Revised_Trade_in_Model__c,
                        Revised_Trade_in_Mileage__c,
                        Revised_Trade_in_Value__c,
                        Account.PersonContactId,
                        Sale_Type__c,
                        Revised_Trade_in_Model_Year__c
                FROM Opportunity
                WHERE Id IN :ids
        ];

        List<OpportunityResourceDto> data = new List<OpportunityResourceDto>();
        for (Opportunity op : ops){
            if (op.Primary_Contact__c == null)
            {
                if (op.Account.IsPersonAccount)
                {
                    op.Primary_Contact__r = contacts.get(op.Account.PersonContactId);
                }
                else
                {
                    op.Primary_Contact__r = contacts.get(op.ContactId);
                }
            }
            OpportunityResourceDto resource = new OpportunityResourceDto(op);
            data.add(resource);
        }

        VitalExportRequest request = new VitalExportRequest(data);


        BaseMulesoftConnector conn = new BaseMulesoftConnector(
                Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_SEND_TO_VITAL);
        String body = JSON.serialize(request, true);
        System.debug(body);
        conn.doCallout(HttpMethods.POST, body);
    }
}
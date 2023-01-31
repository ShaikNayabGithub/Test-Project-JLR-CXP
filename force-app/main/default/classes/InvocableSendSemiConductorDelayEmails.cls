/**
 * Created by caleb@argologic.com.au on 15/11/2021.
 */

public with sharing class InvocableSendSemiConductorDelayEmails
{
    public static Map<String, String> featureRemovalStageToNextActionDescription = new Map<String, String>
    {
        'Identified' => 'Create opportunity in CXP and add the customer Asset.',
        'Pending' => 'Ineligible sale type, contact your RPM.',
        'Awaiting Customer Outcome' => 'Sales Exec needs to complete task in CXP.'
    };

    @InvocableMethod
    public static void SendEmails()
    {
        List<Asset> assetsWithSemiConductorDelays = [
                SELECT Id, Account.Id, Account.Queue_ID__c, Account.Sales_Region_Australia__c, Name, Semiconductor_Supply_Issue__c, Feature_Removal_Stage__c, Common_Sale_Type__c
                FROM Asset
                WHERE Semiconductor_Supply_Issue__c != NULL
                AND Feature_Removal_Stage__c IN ('Awaiting Customer Outcome', 'Identified', 'Pending')
                AND Asset.Account.RecordType.DeveloperName = 'Retailer'
                ORDER BY Feature_Removal_Stage__c DESC
        ];

        System.debug('assetsWithSemiConductorDelays.size() = ' + assetsWithSemiConductorDelays.size());

        Map<Account, List<Asset>> accountToAssets = new Map<Account, List<Asset>>();
        for (Asset ass : assetsWithSemiConductorDelays)
        {
            if (accountToAssets.containsKey(ass.Account))
            {
                accountToAssets.get(ass.Account).add(ass);
            }
            else
            {
                accountToAssets.put(ass.Account, new List<Asset> { ass });
            }
        }

        List<String> assetIds = new List<String>();
        for (Asset ass : assetsWithSemiConductorDelays)
        {
            assetIds.add(ass.Id);
        }

        List<OpportunityLineItem> olis = [
                SELECT Id, Opportunity.Name, Opportunity.CreatedDate, Asset__c
                FROM OpportunityLineItem
                WHERE Asset__c IN :assetIds
        ];

        Map<String, Opportunity> assetIdToOpportunity = new Map<String, Opportunity>();
        for (OpportunityLineItem oli : olis)
        {
            if (!assetIdToOpportunity.containsKey(oli.Asset__c))
                assetIdToOpportunity.put(oli.Asset__c, oli.Opportunity);
            else if (assetIdToOpportunity.containsKey(oli.Asset__c) && assetIdToOpportunity.get(oli.Asset__c).CreatedDate < oli.Opportunity.CreatedDate)
                assetIdToOpportunity.put(oli.Asset__c, oli.Opportunity);
        }

        Map<String, Account> queueIdToAccount = new Map<String, Account>();
        for (Account acc : accountToAssets.keySet())
        {
            queueIdToAccount.put(acc.Queue_ID__c, acc);
        }

        List<GroupMember> groupMembers = [
                SELECT Id, UserOrGroupId, GroupId
                FROM GroupMember
                WHERE GroupId IN :queueIdToAccount.keySet()
        ];

        Map<String, String> userIdToQueueId = new Map<String, String>();
        for (GroupMember gm : groupMembers)
        {
            userIdToQueueId.put(gm.UserOrGroupId, gm.GroupId);
        }

        List<User> users = [
                SELECT Id, Email
                FROM User
                WHERE Id IN :userIdToQueueId.keySet()
                AND IsActive = TRUE
        ];

        List<String> accountSalesRegions = new List<String>();
        for (Account acc : accountToAssets.keySet())
        {
            accountSalesRegions.add(acc.Sales_Region_Australia__c);
        }

        Map<Account, List<User>> accountToUsers = new Map<Account, List<User>>();
        for (User u : users)
        {
            Account acc = queueIdToAccount.get(userIdToQueueId.get(u.Id));
            if (accountToUsers.containsKey(acc))
            {
                accountToUsers.get(acc).add(u);
            }
            else
            {
                accountToUsers.put(acc, new List<User> { u });
            }
        }

        List<User> regionalUsers = [
                SELECT Id, Email, Sales_Region_Australia__c
                FROM User
                WHERE User.Country_ISO_Code__c = 'AU'
                AND User.Sales_Region_Australia__c IN :accountSalesRegions
        ];

        Map<String, User> salesRegionToUser = new Map<String, User>();
        for (User u : regionalUsers)
        {
            salesRegionToUser.put(u.Sales_Region_Australia__c, u);
        }

        // generate the email bodys for every user
        for (Account acc : accountToUsers.keySet())
        {
            List<String> emails = new List<String>();
            if (salesRegionToUser.containsKey(acc.Sales_Region_Australia__c))
                emails.add(salesRegionToUser.get(acc.Sales_Region_Australia__c).Email);

            for (User u : accountToUsers.get(acc))
            {
                emails.add(u.Email);

                if (emails.size() == 5)
                {
                    SendFormattedEmail(emails, acc, assetIdToOpportunity, accountToAssets);
                    emails = new List<String>();
                }
            }

            if (emails.size() > 0)
                SendFormattedEmail(emails, acc, assetIdToOpportunity, accountToAssets);

        }
    }

    public static void SendFormattedEmail(List<String> emails, Account acc, Map<String, Opportunity> assetIdToOpportunity, Map<Account, List<Asset>> accountToAssets)
    {
        String email = String.join(emails, ',');

        String body = '<style>\n' +
                'table, td, th {\n' +
                '  border: 1px solid black;\n' +
                '  padding-left: 10px;\n' +
                '  padding-right: 10px;\n' +
                '  padding: 5px;\n' +
                '}\n' +
                '\n' +
                'table {\n' +
                '  width: 100%;\n' +
                '  border-collapse: collapse;\n' +
                '}\n' +
                '</style>';
        body += '<table>';
        body += '<tr>\n' +
                '    <th>VIN</th>\n' +
                '    <th>Opportunity Name</th>\n' +
                '    <th>Common Sale Type</th>\n' +
                '    <th>Feature Removal Stage</th>\n' +
                '    <th>Semiconductor Supply Issue</th>\n' +
                '    <th>Next Action</th>\n' +
                '</tr>';
        for (Asset ass : accountToAssets.get(acc))
        {
            body += '<tr>\n';
            body += '<td>' + ass.Name + '</td>';
            body += '<td>' + (assetIdToOpportunity.containsKey(ass.Id) ? assetIdToOpportunity.get(ass.Id).Name : '<div style="color: red;">Please Add an Opportunity</div>') + '</td>';
            body += '<td>' + ass.Common_Sale_Type__c + '</td>';
            body += '<td>' + ass.Feature_Removal_Stage__c + '</td>';
            body += '<td>' + ass.Semiconductor_Supply_Issue__c + '</td>';
            body += '<td>' + featureRemovalStageToNextActionDescription.get(ass.Feature_Removal_Stage__c) + '</td>';
            body += '</tr>\n';
        }
        body += '</table>';

        Map<String, Object> flowInput = new Map<String, Object>
        {
                'email' => email,
                'htmlTable' => body
        };
        Flow.Interview.AutoLaunched_Send_Semiconductor_Delay_Retailer_Email f = new Flow.Interview.AutoLaunched_Send_Semiconductor_Delay_Retailer_Email(flowInput);
        f.start();
    }
}
/**
 * Created by caleb@argologic.com.au on 16/11/2021.
 */

public with sharing class InvocableGetSemiconductorCompensationRow
{
    @InvocableMethod
    public static List<InvocableGetSemiconductorCompensationDto> get(List<String> assetIds)
    {
        List<Asset> assets = [
                SELECT Id, Model__r.Model_Alternative__c, Semiconductor_Supply_Issue__c
                FROM Asset
                WHERE Id IN :assetIds
        ];

        List<String> modelNames = new List<String>();
        for (Asset ass : assets)
        {
            modelNames.add(ass.Model__r.Model_Alternative__c);
        }

        List<Semiconductor_Claim_Matrix__mdt> mdts = [
                SELECT
                        Claim_Amount__c,
                        Description__c,
                        DeveloperName,
                        Feature_Code__c,
                        Model_Name__c,
                        NamespacePrefix,
                        QualifiedApiName
                FROM Semiconductor_Claim_Matrix__mdt
                WHERE Model_Name__c IN :modelNames
        ];

        Map<String, Semiconductor_Claim_Matrix__mdt> modelNameToMdt = new Map<String, Semiconductor_Claim_Matrix__mdt>();
        for (Semiconductor_Claim_Matrix__mdt mdt : mdts)
        {
            modelNameToMdt.put(mdt.Model_Name__c + ':' + mdt.Feature_Code__c, mdt);
        }

        List<InvocableGetSemiconductorCompensationDto> result = new List<InvocableGetSemiconductorCompensationDto>();
        for (Asset ass : assets)
        {

            List<String> supplyIssues = ass.Semiconductor_Supply_Issue__c.split(';');
            List<Semiconductor_Claim_Matrix__mdt> assetCorrespondingMatrixRows = new List<Semiconductor_Claim_Matrix__mdt>();
            for (String supplyIssue : supplyIssues)
            {
                String key = ass.Model__r.Model_Alternative__c + ':' + supplyIssue.split(' ')[0];
                if (modelNameToMdt.containsKey(key))
                    assetCorrespondingMatrixRows.add(modelNameToMdt.get(key));
            }

            InvocableGetSemiconductorCompensationDto dto = new InvocableGetSemiconductorCompensationDto();
            dto.tableHtml = getTableHtml(assetCorrespondingMatrixRows);
            dto.totalCompensation = 0;
            for (Semiconductor_Claim_Matrix__mdt mdt : assetCorrespondingMatrixRows)
            {
                dto.totalCompensation += mdt.Claim_Amount__c;
            }
            result.add(dto);
        }
        return result;
    }

    public static String getTableHtml(List<Semiconductor_Claim_Matrix__mdt> mdts)
    {
        String styleTableTdTh = 'border: 1px solid black; padding-left: 10px; padding-right: 10px; padding: 5px;';
        String styleTable = 'width: 100%; border-collapse: collapse;';

        String body = '<table style="' + styleTableTdTh + styleTable + '">';
        body += '<tr style="' + styleTableTdTh + '">\n' +
                '    <th style="' + styleTableTdTh + '">Models Impacted</th>\n' +
                '    <th style="' + styleTableTdTh + '">Feature Code</th>\n' +
                '    <th style="' + styleTableTdTh + '">Description</th>\n' +
                '    <th style="' + styleTableTdTh + '">Customer / Retailer Claim Accessory Amount</th>\n' +
                '</tr>';
        for (Semiconductor_Claim_Matrix__mdt mdt : mdts)
        {
            body += '<tr style="' + styleTableTdTh + '">\n';
            body += '<td style="' + styleTableTdTh + '">' + mdt.Model_Name__c + '</td>';
            body += '<td style="' + styleTableTdTh + '">' + mdt.Feature_Code__c + '</td>';
            body += '<td style="' + styleTableTdTh + '">' + mdt.Description__c + '</td>';
            body += '<td style="' + styleTableTdTh + '">' + mdt.Claim_Amount__c + '</td>';
            body += '</tr>\n';
        }
        body += '</table>';

        return body;
    }
}
/**
 * Created by caleb@argologic.com.au on 31/08/2021.
 */

@IsTest
public with sharing class VwfsServiceTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        string reqString = '[{"FSProduct":"ConsumerLoan84mth","FinancedAmount":58398.0,"TermTenor":84.0,"VinchassisNumber":"SADCA2AK2HA048499","BalloonGMFV":0.0,"InvoicePrice":72920.0,"CustomerDeposit":10000.0,"DAF":750.0,"EstablishmentFee":398.0,"NormalInstallment":939.27,"ContractRate":0.0899,"NewDemoUsed":"DemoPassenger","IsHardshipActive":"","MarketingConsent":"Y","LoanId":594727.0,"ActiveFlag":0.0,"ArrearsTotalDays":0.0,"OverdueAmount":0.0,"CampaignCode":"Empty","DealerCode":"3021","DealerGroup":"SCC","DealerAlternativeTradingName":"SouthernClassicJaguarandLandrover","Make":"JAGUAR","MaturityDate":"2024-12-15T00:00:00","DaystoMaturity":1679.0,"MaturityYYYYMM":"202412","MonthsToMaturity":68.0,"NewUsed":"New","OriginalTerm":84.0,"ProductType":"ConsumerLoan","Gfvflag":0.0,"SnapshotDate":"2021-07-29T00:00:00","StartDate":"2017-12-16T10:40:46","YearOfManufacture":2016.0,"CurrentBalance":0.0}]';
        List<VwsfAttributeDto> request = (List<VwsfAttributeDto>)JSON.deserialize(reqString, List<VwsfAttributeDto>.class);

        // ACT
        Test.startTest();
        VwfsService.create(request);
        Test.stopTest();

        // ASSERT

    }
}
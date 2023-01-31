/**
 * Created by caleb@argologic.com.au on 13/08/2021.
 */

public with sharing class VwfsController
{
    public static String AccountIdIfNoMatchingAccountFound = '0011o00001unF2aAAE';

    public static void create(List<VwsfAttributeDto> requestsUnfilterd)
    {
        List<VwsfAttributeDto> requests = new List<VwsfAttributeDto>();
        for (VwsfAttributeDto r : requestsUnfilterd)
        {
            if (!r.allFieldsAreBlank())
                requests.add(r);
        }

        // generate mdt map
        Map<String, String> vwfsToJagCode = new Map<String, String>();
        Map<String, String> vwfsToLandRoverCode = new Map<String, String>();
        for (VWFS_Dealer_Code_Mapping__mdt mdt : [SELECT VWFS_Code__c, JLRA_Jaguar_Code__c, JLRA_Land_Rover_Code__c FROM VWFS_Dealer_Code_Mapping__mdt])
        {
            vwfsToJagCode.put(mdt.VWFS_Code__c, mdt.JLRA_Jaguar_Code__c);
            vwfsToLandRoverCode.put(mdt.VWFS_Code__c, mdt.JLRA_Land_Rover_Code__c);
        }

        // asset
        List<String> assetVins = new List<String>();
        for (VwsfAttributeDto request : requests)
        {
            assetVins.add(request.VinchassisNumber);
        }

        List<Asset> assets = [
                SELECT
                        Id,
                        VIN__c,
                        AccountId
                FROM Asset
                WHERE VIN__c IN :assetVins
        ];

        Map<String, Asset> vinToAsset = new Map<String, Asset>();
        for (Asset asset : assets)
        {
            vinToAsset.put(asset.VIN__c.toUppercase(), asset);
        }

        // dealers
        List<Account> retailers = [
                SELECT Id, ParentId, Dealer_CI_Code__c, Dealer_CI_Code_2__c
                FROM Account
                WHERE ((Dealer_CI_Code__c IN :vwfsToJagCode.values() AND Dealer_CI_Code_2__c = NULL)
                OR (Dealer_CI_Code__c = NULL AND Dealer_CI_Code_2__c IN :vwfsToLandRoverCode.values()))
                AND ParentId != NULL
        ];

        Map<String, String> dealerCodeToRetailerMap = new Map<String, String>();
        for (Account retailer : retailers)
        {
            dealerCodeToRetailerMap.put(
                    retailer.Dealer_CI_Code__c != null ? retailer.Dealer_CI_Code__c : retailer.Dealer_CI_Code_2__c,
                    retailer.ParentId);
        }

        // existsing contracts
        List<String> vwfsLoanIds = new List<String>();
        for (VwsfAttributeDto request : requests)
        {
            vwfsLoanIds.add(String.valueOf(Math.round(request.LoanId)));
        }

        List<Contract> existingContacts = [
                SELECT
                        VWFS_Loan_Id__c,
                        AccountId
                FROM Contract
                WHERE VWFS_Loan_Id__c IN :vwfsLoanIds
        ];

        Map<String, Contract> loanIdContract = new Map<String, Contract>();
        for (Contract con : existingContacts)
        {
            loanIdContract.put(con.VWFS_Loan_Id__c, con);
        }


        List<Contract> toInsert = new List<Contract>();
        for (VwsfAttributeDto request : requests)
        {
            Contract toAdd = new Contract();
            if (vinToAsset.get(request.VinchassisNumber.toUppercase()) == null)
            {
                toAdd.Asset__c = null;
                toAdd.VWFS_Vin_Text__c = request.VinchassisNumber.toUppercase();
                toAdd.AccountId = AccountIdIfNoMatchingAccountFound;
            }
            else
            {
                toAdd.Asset__c = vinToAsset.get(request.VinchassisNumber.toUppercase()).Id;
                if (vinToAsset.get(request.VinchassisNumber.toUppercase()).AccountId == null)
                {
                    String loadIdString = String.valueOf(Math.round(request.LoanId));
                    if (!loanIdContract.containsKey(loadIdString) || loanIdContract.get(loadIdString).AccountId == null)
                        toAdd.AccountId = AccountIdIfNoMatchingAccountFound;
                }
                else
                {
                    String loadIdString = String.valueOf(Math.round(request.LoanId));
                    if (!loanIdContract.containsKey(loadIdString) || loanIdContract.get(loadIdString).AccountId == null)
                        toAdd.AccountId = vinToAsset.get(request.VinchassisNumber.toUppercase()).AccountId;
                }
            }

            String dealerCode = vwfsToJagCode.get(request.DealerCode);
            if (dealerCode == null) dealerCode = vwfsToLandRoverCode.get(request.DealerCode);

            if (dealerCode == null || dealerCodeToRetailerMap.get(dealerCode) == null)
            {
                toAdd.VWFS_Dealer_Code_Text__c = request.DealerCode;
            }
            else
            {
                toAdd.Selling_Retailer__c = dealerCodeToRetailerMap.get(dealerCode);
            }

            toAdd.Country_ISO_Code__c = 'AU';
            toAdd.Finance_Partner__c = 'Volkswagen Financial Services';
            toAdd.Finance_Product_Local__c = request.FSProduct;
            toAdd.Amount_Financed__c = request.FinancedAmount;
            toAdd.Existing_Contract_Term_months__c = request.TermTenor;
            toAdd.GMFV_Balloon__c = request.BalloonGMFV;
            toAdd.Invoice_Price__c = request.InvoicePrice;
            toAdd.Deposit__c = request.CustomerDeposit;
            toAdd.Finance_Facility_Fee__c = request.EstablishmentFee;
            toAdd.Instalment_Amount__c = request.NormalInstallment;
            toAdd.APR__c = request.ContractRate * 100;
            toAdd.Is_Hardship_Active__c = request.IsHardshipActive;
            toAdd.VWFS_Marketing_Consent__c = request.MarketingConsent == 'Y';
            toAdd.VWFS_Loan_Id__c = String.valueOf(Math.round(request.LoanId));
            toAdd.Is_Active__c = request.ActiveFlag == -1.0;
            toAdd.Arrears_Total_Days__c = request.ArrearsTotalDays;
            toAdd.Overdue_Amount__c = request.OverdueAmount;

            toAdd.EndDate = JlrDateParser.parseStringAsDate(request.MaturityDate);
            toAdd.Vehicle_Type__c = request.NewUsed;
            toAdd.ContractTerm = Math.round(request.OriginalTerm);
            toAdd.Finance_Type__c = request.ProductType;
            toAdd.GFV_Flag__c = request.Gfvflag == 1.0;
            toAdd.Snapshot_Date__c = JlrDateParser.parseStringAsDate(request.SnapshotDate);
            toAdd.StartDate = JlrDateParser.parseStringAsDate(request.StartDate);
            toAdd.Outstanding_Balance__c = request.CurrentBalance;
            toAdd.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
                    .get('Finance').getRecordTypeId();

            toInsert.add(toAdd);
        }
        upsert toInsert VWFS_Loan_Id__c;
    }

    public static Decimal parseCurrency(String str)
    {
        return Decimal.valueOf(str.replace(',', '').replace('$', ''));
    }
}
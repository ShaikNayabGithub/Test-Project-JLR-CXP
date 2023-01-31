/**
 * Created by caleb@argologic.com.au on 13/08/2021.
 */

global with sharing class VwsfAttributeDto
{
    public String FSProduct {get; set;}
    public Decimal FinancedAmount {get; set;}
    public Decimal TermTenor {get; set;}
    public String VinchassisNumber {get; set;}
    public Decimal BalloonGMFV {get; set;}
    public Decimal InvoicePrice {get; set;}
    public Decimal CustomerDeposit {get; set;}
    public Decimal DAF {get; set;}
    public Decimal EstablishmentFee {get; set;}
    public Decimal NormalInstallment {get; set;}
    public Decimal ContractRate {get; set;} // need to remove %
    public String NewDemoUsed {get; set;}
    public String IsHardshipActive {get; set;}
    public String MarketingConsent {get; set;}
    public Decimal LoanId {get; set;}
    public Decimal ActiveFlag {get; set;}
    public Decimal ArrearsTotalDays {get; set;}
    public Decimal OverdueAmount {get; set;}
    public String CampaignCode {get; set;}
    public String DealerCode {get; set;}
    public String Make {get; set;}
    public String MaturityDate {get; set;}
    public String NewUsed {get; set;}
    public Decimal OriginalTerm {get; set;}
    public String ProductType {get; set;}
    public Decimal Gfvflag {get; set;}
    public String SnapshotDate {get; set;}
    public String StartDate {get; set;}
    public Decimal CurrentBalance {get; set;}

    public Boolean allFieldsAreBlank()
    {
        return String.isEmpty(FSProduct) && String.isEmpty(VinchassisNumber) && String.isEmpty(NewDemoUsed) && String.isEmpty(IsHardshipActive) && String.isEmpty(MarketingConsent) && String.isEmpty(CampaignCode) && String.isEmpty(DealerCode) && String.isEmpty(Make) && String.isEmpty(MaturityDate) && String.isEmpty(NewUsed) && String.isEmpty(ProductType) && String.isEmpty(SnapshotDate) && String.isEmpty(StartDate);
    }
}
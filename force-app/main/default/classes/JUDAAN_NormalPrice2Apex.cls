public class JUDAAN_NormalPrice2Apex 
{
    public String requestid;
    public String calcResult;
    public Integer loanPrincipal;
    public Integer payment1st;
    public Integer paymentMonthly;
    public Integer bonusAdditionalCost;
    public Integer numOfBonus;
    public Integer installmentsFee;
    public Integer installmentsTotal;
    public Integer totalPayments;
    public Integer paymentPeriod;
    public Integer paymentLast;
    public String  error;
    public static JUDAAN_NormalPrice2Apex parse(String json) 
    {
        return (JUDAAN_NormalPrice2Apex) System.JSON.deserialize(json, JUDAAN_NormalPrice2Apex.class);
    }
}
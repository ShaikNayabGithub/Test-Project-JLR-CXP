/**
 * Created by caleb@argologic.com.au on 4/12/2019.
 */

public with sharing class TestClass_LoyaltyPointsTransaction
{
    public static Loyalty_Points_Transaction__c createTransaction(String LoyaltyPointsId, String rdaId)
    {
        Loyalty_Points_Transaction__c trans = new Loyalty_Points_Transaction__c();
        trans.Loyalty_Points__c = LoyaltyPointsId;
        trans.Base_Points__c = 10;
        trans.Bonus_Points__c = 10;
        trans.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        trans.Multiplier__c = 1;
        trans.RDA__c = rdaId;
        trans.Transaction_Date__c = Datetime.now().date();
        trans.Transaction_Delivery_Status__c = Constants.LOYALTY_TRANSACTION_WAITING;
        insert trans;
        return trans;
    }
}
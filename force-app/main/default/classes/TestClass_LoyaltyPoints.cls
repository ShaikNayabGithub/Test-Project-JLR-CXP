/**
 * Created by caleb@argologic.com.au on 4/12/2019.
 */

public with sharing class TestClass_LoyaltyPoints
{
    public static Loyalty_Points__c createLoyaltyPointsQFF(String loyaltySchemeId)
    {
        Loyalty_Points__c points = new Loyalty_Points__c();
        points.Bonus_Points__c = 0;
        points.Corporate_multiplier__c = 0;
        points.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        points.Indicator__c = 'This is an indicator';
        points.Individual_multiplier__c = 1;
        points.Is_Eligible__c = true;
        points.Loyalty_type__c = Constants.LOYALTY_TYPE_PERSON_ACCOUNT;
        points.Name = 'Qantas Frequent Flyer';
        points.Loyalty_Scheme__c = loyaltySchemeId;
        points.Number_of_Points__c = 101;
        points.Offer_End_Date__c = Datetime.now().addYears(1).date();
        points.Offer_Start_Date__c = Datetime.now().addYears(-1).date();
        insert points;
        return points;
    }

    public static Loyalty_Points__c createLoyaltyPointsQBR(String loyaltySchemeId)
    {
        Loyalty_Points__c points = new Loyalty_Points__c();
        points.Bonus_Points__c = 0;
        points.Corporate_multiplier__c = 0;
        points.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        points.Indicator__c = 'This is an indicator';
        points.Individual_multiplier__c = 1;
        points.Is_Eligible__c = true;
        points.Loyalty_type__c = Constants.LOYALTY_TYPE_CORPORATE_ACCOUNT;
        points.Name = 'Qantas Business Rewards';
        points.Loyalty_Scheme__c = loyaltySchemeId;
        points.Number_of_Points__c = 101;
        points.Offer_End_Date__c = Datetime.now().addYears(1).date();
        points.Offer_Start_Date__c = Datetime.now().addYears(-1).date();
        insert points;
        return points;
    }
}
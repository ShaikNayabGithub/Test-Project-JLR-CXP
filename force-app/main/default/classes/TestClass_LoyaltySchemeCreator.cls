/**
 * Created by caleb@argologic.com.au on 4/12/2019.
 */

public with sharing class TestClass_LoyaltySchemeCreator
{
    public static Loyalty_Scheme__c createQantasScheme()
    {
        Loyalty_Scheme__c scheme = new Loyalty_Scheme__c();
        scheme.Country_ISO_Code__c = Constants.COUNTRY_CODE_AU;
        scheme.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        scheme.Name = 'Qantas';
        insert scheme;
        return scheme;
    }
}
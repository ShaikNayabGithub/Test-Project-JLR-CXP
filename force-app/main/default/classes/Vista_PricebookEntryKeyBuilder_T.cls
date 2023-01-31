@isTest
public class Vista_PricebookEntryKeyBuilder_T {
    static testmethod void Build_ReturnsA_B_GivenAandB()
    {
        String productCode = 'A';
        String market = 'B';

        String result = Vista_PricebookEntryKeyBuilder.Build(productCode, market);

        System.assertEquals('A_B', result);
    }

    static testmethod void Build_ReturnsUnderscore_GivenEmptyandEmpty()
    {
        String productCode = '';
        String market = '';

        String result = Vista_PricebookEntryKeyBuilder.Build(productCode, market);

        System.assertEquals('_', result);
    }
    
    static testmethod void getPricebookFromLabel()
    {
    
       String pricebook= Vista_PricebookEntryKeyBuilder.getPriceBookNameFromLabel('Taiwan');
       System.assertNotEquals('',pricebook);
    
    }
}
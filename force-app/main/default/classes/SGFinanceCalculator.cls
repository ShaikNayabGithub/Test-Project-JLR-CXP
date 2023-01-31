/* *************************************************************************************************************    
Class Name    : SGFinanceCalculator
Description   : This class is used for performing Finance Calculation for Singapore on Checkout page 
CreatedDate   : 08 Feb 2018         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                

***************************************************************************************************************** */
public without sharing class SGFinanceCalculator{
    
    /* **************************************************
    Method Name: getFinanceOffer
    Input Parameters: String,String,String,String
    Return Type: Integer (Monthly Installment)
    Method Description: Method to calculate Monthly Installment on click of Calculate Finance offer button
    ****************************************************** */  
    public static Decimal getFinanceOffer(Integer localPrice, Integer depositAmount, Decimal interestRate, Integer loanTenure){
         Decimal interestRatePer = interestRate/100;
         Decimal monthlyInstallment = ((localPrice - depositAmount)  * interestRatePer * loanTenure / 12 +(localPrice - depositAmount))/ loanTenure ;
         System.debug('monthlyInstallment >>'+monthlyInstallment );
         return monthlyInstallment;
    }
   
    /* **************************************************
    Method Name: calculateLocalPriceforBudget
    Input Parameters: Integer,Integer,Integer
    Return Type: decimal (Vehicle local price)
    Method Description: Method to calculate local price for vehicle 
                        under budget section on Vehicle search page
    ****************************************************** */  
    public static decimal calculateLocalPriceforBudget(Integer monthlyInterest, Integer downpayment, Integer noOfPayment){
        Decimal interestRate = Decimal.valueOf(System.label.Flat_Interest_Rate);
        Decimal localPrice = (monthlyInterest*noOfPayment*12/((interestRate*noOfPayment)+12))+downpayment;
        System.debug('localPrice>>'+localPrice);
        return localPrice;
    }
    
}
@isTest
public class TestClass_PricebookCreator {
    
    public static Pricebook2 CreatePricebook(){
    	return CreatePricebook('India');
    }
    
    public static Pricebook2 CreatePricebook(String pricebookName){
		Pricebook2 countryBook = new Pricebook2(Name=pricebookName, IsActive=true);
		insert countryBook;
		return countryBook;
    }

}
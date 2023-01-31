public class PriceBookUtilities {
    public static PriceBook2 StandardPriceBook { get {
    	if(StandardPriceBook == null) {
    		StandardPriceBook = [Select Id From PriceBook2 Where IsStandard = true Limit 1];
    	}
    	return StandardPriceBook;
    } private set; }
    
    public static Map<String, PriceBook2> ExistingPricebooks { get {
    	if(ExistingPricebooks == null) {
    		ExistingPricebooks = new Map<String, PriceBook2>();
    		List<PriceBook2> pricebooks = [Select Name From PriceBook2];
	    	for(PriceBook2 pricebook : pricebooks) {
	    		ExistingPricebooks.put(pricebook.Name, pricebook);
	    	}
    	}
    	return ExistingPricebooks;
    } private set; }
}
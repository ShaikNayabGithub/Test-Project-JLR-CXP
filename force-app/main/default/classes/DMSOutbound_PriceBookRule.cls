public class DMSOutbound_PriceBookRule implements I_OpportunityValidator{
	private final string RequiredPriceBookName = 'India';

	public void Validate(Opportunity opportunity)
    {
    	if(opportunity.Pricebook2Id != null){
	    	PriceBook2 priceBook = [Select Name From PriceBook2 Where Id=:opportunity.Pricebook2Id Limit 1];
	    	if(priceBook.Name == this.RequiredPriceBookName){ return; }
	    }
	    string exceptionMessage = String.format(System.Label.DMSException_InvalidPriceBook, new List<String> {this.RequiredPriceBookName});
		throw new DMSOutbound_InvalidDataException(exceptionMessage);
    }
}
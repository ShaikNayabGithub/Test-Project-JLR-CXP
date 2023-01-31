public class JUDAAN_BackPrice2Apex 
{
	public String calcResult {get; set; }
	public Integer backPrice { get; set; }
	public String error { get; set; }
	public JUDAAN_BackPrice2Apex() 
    { 
        
	}
	public static JUDAAN_BackPrice2Apex parse(String json) 
    {
        JUDAAN_BackPrice2Apex backprice;
        try {
            backprice = (JUDAAN_BackPrice2Apex) System.JSON.deserialize(json, JUDAAN_BackPrice2Apex.class);
        } catch( Exception ex ) {
            backprice  = new JUDAAN_BackPrice2Apex();
        }
		return backprice;
	}
}
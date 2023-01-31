/**
 * CSVReader contains static methods used for reading a CSV file and returning
 * the contained values in a nested List of Strings.
 *
 * @author  Marty Y. Chang
 * @version beta
 */
 /**
* CSVValue is a class structure containing information about a CSV
* value that was read from a CSV file, including such information as
* whether the value was encapsulated in double-quotes.
*/
 public class CSVValue {
    /**
     * The field value that was read from the CSV file.
     */
    public String value;
    
    /**
     * Whether the value was surrounded by double-quotes.
     */
    public Boolean enclosed;
    
    /**
     * The comma or CRLF delimiter that identified the end of the CSV value.
     */
    public String delimiter;
    
    /**
     * Default constructor, setting all members to null.
     */
    public CSVValue() {
        this(null, null, null);
    }
    
    /**
     * Constructor.
     *
     * @param value     the field value
     * @param enclosed  whether the value was surrounded by double-quotes
     * @param delimiter the delimiter that identified the end
     *                  of the CSV value
     */
    public CSVValue(String value, Boolean enclosed, String delimiter) {
        this.value = value;
        this.enclosed = enclosed;
        this.delimiter = delimiter;
    }
    
    /**
     * Returns the number of characters to remove from the data
     * String which produced the CSVValue in order to reach the next
     * value in the data String.
     */
    public Integer biteSize() {
      Integer biteSize = value
             .replaceAll(CSVParser.DQUOTE, CSVParser.DQUOTEDQUOTE).length()
                     + delimiter.length();
      
      if (enclosed) {
        biteSize += CSVParser.DQUOTE.length() * 2;
      }
      
      return biteSize;
    }
    
    /**
     * Returns whether a CSVValue has the same <code>value</code> and
     * <code>enclosed</code> as another CSVValue.
     */
    public Boolean equals(CSVValue compCSVValue) {
        return this.value.equals(compCSVValue.value)
                && this.enclosed == compCSVValue.enclosed
                        && this.delimiter == compCSVValue.delimiter;
    }
    
    /**
     * Asserts that two <code>CSVValue</code> instances have the same
     * <code>value</code> and <code>enclosed</code>.
     */
    public void assertEquals(CSVValue compCSVValue) {
        System.assertEquals(value, compCSVValue.value);
        System.assertEquals(enclosed, compCSVValue.enclosed);
        System.assertEquals(delimiter, compCSVValue.delimiter);
    }
}
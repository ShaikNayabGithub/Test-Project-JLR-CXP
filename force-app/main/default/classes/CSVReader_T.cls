/**
 * CSVReader contains static methods used for reading a CSV file and returning
 * the contained values in a nested List of Strings.
 *
 * @author  Marty Y. Chang
 * @version beta
 */
@isTest
public class CSVReader_T {
    /**
     * Test some use cases for reading IETF RFC 4180-compliant CSV values.
     */
    public static testMethod void readIETFRFC4180CSVValueTest() {
        String data = null;  // Placeholder for data to use in testing.
        
        System.debug(data = CSVParser.LF);
        new CSVValue('', false, CSVParser.LF)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '""' + CSVParser.LF);
        new CSVValue('', true, CSVParser.LF)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"",asdf' + CSVParser.LF);
        new CSVValue('', true, CSVParser.COMMA)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = ',asdf' + CSVParser.LF);
        new CSVValue('', false, CSVParser.COMMA)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"' + CSVParser.LF + '",blah' + CSVParser.LF);
        new CSVValue(CSVParser.LF, true, CSVParser.COMMA)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"""marty""","""chang"""' + CSVParser.CRLF);
        new CSVValue('"marty"', true, CSVParser.COMMA)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
        System.debug(data = '"com""pli""cate' + CSVParser.LF + 'd"'
                + CSVParser.LF);
        new CSVValue('com"pli"cate' + CSVParser.LF + 'd', true, CSVParser.LF)
                .assertEquals(CSVReader.readIETFRFC4180CSVValue(data));
        
      
    }
    
    /**
     * Tests one case of parsing a CSV file that contains the following data:
     *
     * abc,"def","g""h""i"
     * "j
     * kl","m
     * n""o""",
     */
    public static testMethod void readIETFRFC4180CSVFile() {
      String data = 'abc,"def","g""h""i"' + CSVParser.LF + '"j' + CSVParser.LF
             + 'kl","m' + CSVParser.LF + 'n""o""",';
      
      List<List<String>> fileValues =
             CSVReader.readIETFRFC4180CSVFile(data);
    }
}
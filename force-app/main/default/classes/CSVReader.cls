/**
 * CSVReader contains static methods used for reading a CSV file and returning
 * the contained values in a nested List of Strings.
 *
 * @author  Marty Y. Chang
 * @version beta
 */
 public class CSVReader {
    /**
     * Returns a List containing Lists of Strings that represents
     * the values contained in an IETF RFC 4180-compliant CSV file.
     *
     * Each element in the outer list represents a row in the CSV file.
     * Each element in the inner list is the value in the field specified
     * by the row-column combination.
     *
     * @param  file the CSV file to read
     * @return      the List<List<String>> containing values read from the
     *              CSV file
     */
    public static List<List<String>> readIETFRFC4180CSVFile(String fileString) {        
        if (!fileString.endsWith(CSVParser.LF)) {
          fileString = fileString + CSVParser.LF;
        }
        
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();
        
        Boolean eod = false;  // Whether end of CSV data is reached
        while (!eod) {
            csvValue = readIETFRFC4180CSVValue(fileString);
            
            //jlr added trim()
            rowValues.add(csvValue.value.trim());
            
            if (csvValue.delimiter == CSVParser.LF) {
              fileValues.add(rowValues);
              
              if (fileValues.size() > 0) {
                System.assertEquals(fileValues.get(0).size(),
                      rowValues.size());
              }
              
              rowValues = new List<String>();
            }
            
            if (csvValue.biteSize() == fileString.length()) {
              eod = true;
            }
            else {
              fileString = fileString.substring(csvValue.biteSize());
            }
        }
        
        System.debug('this is the fileString: '+fileString);
        
        return fileValues;
    }
    
    /**
     * Returns the first String value read from a String representation of
     * data contained in an IETF RFC 4180-compliant CSV file.
     *
     * The data is assumed to be terminated with a CRLF.
     *
     * @param  data the textual CSV data in one long string
     * @return      the first CSV value read from <code>data</code>.
     *              null is returned if no value is discerned.
     */
    public static CSVValue readIETFRFC4180CSVValue(String data) {
        System.assert(data.endsWith(CSVParser.LF));
        
        CSVValue csvValue = new CSVValue();
        
        if (data.startsWith(CSVParser.DQUOTE)) {
          csvValue.enclosed = true;
          
            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE
                            
            Boolean closerFound = false;
            
            while (!closerFound) {
                dquoteIndex = data.indexOf(CSVParser.DQUOTE, searchIndex);
                
                dquotesIndex = data.indexOf(CSVParser.DQUOTEDQUOTE,
                        searchIndex);
                
                System.assert(dquoteIndex != -1);
                
                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex
                            + CSVParser.DQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }
            
            csvValue.value = data.substring(
                    CSVParser.DQUOTE.length(), dquoteIndex)
                            .replaceAll(CSVParser.DQUOTEDQUOTE, CSVParser.DQUOTE);
            
            Integer commaIndex = data.indexOf(CSVParser.COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(CSVParser.LF, dquoteIndex);
        
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = CSVParser.COMMA;
            }
            else {
                csvValue.delimiter = CSVParser.LF;
            }
        }
        else {
          csvValue.enclosed = false;
          
            Integer commaIndex = data.indexOf(CSVParser.COMMA);
            Integer crlfIndex = data.indexOf(CSVParser.LF);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = CSVParser.COMMA;
            }
            else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = CSVParser.LF;
            }
        }
                
        return csvValue;
    }
}
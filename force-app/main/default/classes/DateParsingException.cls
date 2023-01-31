/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 23/10/2019.
 */

/**
 * The purpose of this class is to capture errors caused by the parsing of dates from strings
 *
 */
global with sharing class DateParsingException extends Exception {

   global String DateString {get; set;}
}
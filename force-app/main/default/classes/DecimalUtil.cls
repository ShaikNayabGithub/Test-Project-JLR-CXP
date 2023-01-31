public class DecimalUtil {
    
    public static Decimal valueOf( String value ) {
        value = value.replaceAll( ',' , '' );
        Decimal returnValue = 0;
        try {
            returnValue = Decimal.valueOf( value );
        } catch( Exception ex ) {
            
        }
        
        return( returnValue );
    }
}
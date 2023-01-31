public class IntegerUtil {

    public static Integer valueOf( String value ) {
        if( value == null ) {
            return( null );
        }
        value = value.replaceAll( ',' , '' );
        Integer returnValue = 0;
        try {
            returnValue = Integer.valueOf( value );
        } catch( Exception ex ) {
            
        }
        
        return( returnValue );
    }
    
    public static Integer getValue( Integer value ) {
        if( value == null ) {
            return( 0 );
        } else {
            return( value );
        }
    }
}
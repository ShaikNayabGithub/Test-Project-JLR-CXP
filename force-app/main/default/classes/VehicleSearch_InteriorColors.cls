public class VehicleSearch_InteriorColors {

    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_InteriorColors( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
    public VehicleSearch_InteriorColors( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market);
        this.parameters = parameters;
    }

    public VehicleSearchBean getInteriorColourOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        if( ! this.parameters.engines.isEmpty() ) {
            bean.interiorColours = this.dao.getDistinctInteriorColour( this.parameters );
            bean.vehicleCount = this.dao.getCount();
        }
        
        System.debug( '----------- getInteriorColourOptions bean.interiorColours.size() = ' + bean.interiorColours.size() );
        return( bean );
    }
}
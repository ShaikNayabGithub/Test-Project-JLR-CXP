public class VehicleSearch_ExteriorColors {

    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_ExteriorColors( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
    public VehicleSearch_ExteriorColors( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market );
        this.parameters = parameters;
    }

    public VehicleSearchBean getExteriorGroupColourOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        if( ! this.parameters.engines.isEmpty() ) {
            bean.exteriorGroupColours = this.dao.getDistinctExteriorColourGroup( this.parameters );
            bean.vehicleCount = this.dao.getCount();
        }
        System.debug( '----------- group colour , vehicleCount = ' + bean.vehicleCount );
        return( bean );
    }

    /*
     *  get detail colours
     */    
    public VehicleSearchBean getExteriorDetailColourOptions() {
        System.debug( '------------- getExteriorDetailColourOptions' );
        VehicleSearchBean bean = new VehicleSearchBean();
        if( ! this.parameters.engines.isEmpty() && ! this.parameters.exteriorGroupColours.isEmpty() ) {
            bean.exteriorColours = this.dao.getDistinctExteriorColourDetail( this.parameters );
            bean.vehicleCount = this.dao.getCount();
        }
        System.debug( '----------- detail colour , vehicleCount = ' + bean.vehicleCount );
        return( bean );
    }
   
}
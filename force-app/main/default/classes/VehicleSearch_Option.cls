public class VehicleSearch_Option {
    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_Option( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
    public VehicleSearch_Option( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market);
        this.parameters = parameters;
    }

    public VehicleSearchBean getOptionOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        if( ! this.parameters.engines.isEmpty() ) {
            bean.options = this.dao.getDistinctOptions( this.parameters );
            bean.vehicleCount = this.dao.getCount();
        }
        return( bean );
    }
}
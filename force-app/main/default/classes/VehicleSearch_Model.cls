public class VehicleSearch_Model {
    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_Model( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
    public VehicleSearch_Model( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market );
        this.parameters = parameters;
    }

    public VehicleSearchBean getSelectOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        bean.models = this.dao.getDistinctModel( this.parameters );
        bean.vehicleCount = this.dao.getCount();
        
        return( bean );
    }

}
public class VehicleSearch_BodyStyle {

    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_BodyStyle( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
    public VehicleSearch_BodyStyle( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market );
        this.parameters = parameters;
    }

    public VehicleSearchBean getSelectOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        bean.bodyStyles = this.dao.getDistinctBodyStyle( this.parameters );
        bean.vehicleCount = this.dao.getCount();
        
        return( bean );
    }

}
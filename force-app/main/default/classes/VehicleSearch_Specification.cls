public class VehicleSearch_Specification {
    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_Specification( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
     public VehicleSearch_Specification( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market);
        this.parameters = parameters;
    }

    public VehicleSearchBean getSpecificationOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        if( ! this.parameters.engines.isEmpty() ) {
            bean.specifications = this.dao.getDistinctSpecification( this.parameters );
            bean.vehicleCount = this.dao.getCount();
        }
        return( bean );
    }
}
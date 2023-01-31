public class VehicleSearch_AvailableVehicle {
    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    //public VehicleSearch_AvailableVehicle( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;
    //}
    
    public VehicleSearch_AvailableVehicle( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market );
        this.parameters = parameters;
    }

    public VehicleSearchBean getAvailableVehicles() {
        VehicleSearchBean bean = new VehicleSearchBean();
      //Commeted for special vehicles -  if(! this.parameters.engines.isEmpty()  ) 
        {
            bean.vehicles = this.dao.getAvailableVehicle( this.parameters );
            
        }
        return( bean );
    }
}
public class VehicleSearch_RecommendModel {
    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    
    
    public VehicleSearch_RecommendModel ( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market );
        this.parameters = parameters;
    }

    public VehicleSearchBean getSelectOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        bean.recommendedModels = this.dao.getDistinctRecommended( this.parameters );
        bean.vehicleCount = this.dao.getCount();
        
        return( bean );
    }

}
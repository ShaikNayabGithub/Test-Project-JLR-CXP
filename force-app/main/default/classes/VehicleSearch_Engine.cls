public class VehicleSearch_Engine {

    VehicleSearch_AssetDao dao;
    VehicleSearchInputParameters parameters;
    
    Map<String , SelectOption> fuelOptions;
    Map<String , SelectOption> driveOptions;
    Map<String , SelectOption> engineSizeOptions;
    Map<String , SelectOption> transmissionOptions;

    //public VehicleSearch_Engine( String brandName , VehicleSearchInputParameters parameters ) {
    //    this.dao = new VehicleSearch_AssetDao( brandName );
    //    this.parameters = parameters;

    //    this.fuelOptions = new Map<String , SelectOption>();
    //    this.driveOptions = new Map<String , SelectOption>();
    //    this.engineSizeOptions = new Map<String , SelectOption>();
    //    this.transmissionOptions = new Map<String , SelectOption>();

    //    this.fuelOptions.put( '' , new SelectOption( '' , System.label.Fuel_Type ) );
    //    this.driveOptions.put( '' , new SelectOption( '' , System.label.Drive ) );
    //    this.engineSizeOptions.put( '' , new SelectOption( '' , System.label.Engine_Size ) );
    //    this.transmissionOptions.put( '' , new SelectOption( '' , System.label.Transmission ) );
    //}

    public VehicleSearch_Engine( String brandName , String market, VehicleSearchInputParameters parameters ) {
        this.dao = new VehicleSearch_AssetDao( brandName, market);
        this.parameters = parameters;

        this.fuelOptions = new Map<String , SelectOption>();
        this.driveOptions = new Map<String , SelectOption>();
        this.engineSizeOptions = new Map<String , SelectOption>();
        this.transmissionOptions = new Map<String , SelectOption>();

        this.fuelOptions.put( '' , new SelectOption( '' , System.label.Fuel_Type ) );
        this.driveOptions.put( '' , new SelectOption( '' , System.label.Drive ) );
        this.engineSizeOptions.put( '' , new SelectOption( '' , System.label.Engine_Size ) );
        this.transmissionOptions.put( '' , new SelectOption( '' , System.label.Transmission ) );
    }

    public VehicleSearchBean getSelectOptions() {
        VehicleSearchBean bean = new VehicleSearchBean();
        bean.engines = this.dao.getDistinctEngine( this.parameters );
        bean.vehicleCount = this.dao.getCount();

        for( VehicleSearchBean.Engine tmp : bean.engines ) {
            this.fuelOptions.put( tmp.fuelCode , new SelectOption( tmp.fuelCode , tmp.fuel ) );
            this.driveOptions.put( tmp.driveCode , new SelectOption( tmp.driveCode , tmp.drive ) );
            this.engineSizeOptions.put( tmp.engineSize , new SelectOption( tmp.engineSize , tmp.engineSize ) );
            this.transmissionOptions.put( tmp.transmissionCode , new SelectOption( tmp.transmissionCode , tmp.transmission ) );
        }
        
        return( bean );
    }

    public List<SelectOption> getFuelOptions() {
        return( this.fuelOptions.values() );
    }

    public List<SelectOption> getDriveOptions() {
        return( this.driveOptions.values() );
    }

    public List<SelectOption> getEngineSizeOptions() {
        return( this.engineSizeOptions.values() );
    }

    public List<SelectOption> getTransmissionOptions() {
        return( this.transmissionOptions.values() );
    }

}
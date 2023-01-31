public class VehicleSearch_Budget {
    VehicleSearchInputParameters parameters;
    
    public VehicleSearch_Budget( String brandName , VehicleSearchInputParameters parameters ) {
        this.parameters = parameters;
    }

    public VehicleSearchBean getBudget() {
        VehicleSearchBean bean = new VehicleSearchBean();

        if( this.parameters.getPaymentTypeValue() != null && this.parameters.getMonthlyBudget() != null ) {
            JUDAAN_JACCSProccesor proc = new JUDAAN_JACCSProccesor();
            Integer price = proc.doBackCalculation( this.parameters.getPaymentTypeValue() , this.parameters.getMonthlyBudget() , this.parameters.getDeposit() , this.parameters.getTradeinValue() );
			bean.budget = Decimal.valueOf( price );
        } else { 
            bean.budget = IntegerUtil.getValue( this.parameters.getDeposit() ) + IntegerUtil.getValue( this.parameters.getTradeinValue() );
        }
        
        return( bean );
    }

}
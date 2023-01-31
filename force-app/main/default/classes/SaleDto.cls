global class SaleDto extends SimpleResourceDto
{

    private static final String RESOURCE_TYPE = 'SaleType';

    public SaleDto(){
        super();
        this.Type = RESOURCE_TYPE;
    }
}
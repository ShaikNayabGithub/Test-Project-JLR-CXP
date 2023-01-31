/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

global with sharing class GetVehicleOwnersResponseDto extends BaseResponseDto
{
    public Integer NPages {get; set;}
    public String ExportNumber {get; set;}

    public GetVehicleOwnersResponseDto(){
        init();
    }

    public GetVehicleOwnersResponseDto(List<Role__c> roles, Datetime startDatetime)
    {
        this();
        For(Role__c role: roles)
        {
            try
            {
                VehicleOwnersResourceDto dto = new VehicleOwnersResourceDto(role, startDatetime);
                this.Data.add(dto);
            }
            catch (NullPointerException ex)
            {
                System.Debug('Skipping as the Asset does not qualify');
                System.Debug(ex.getMessage() + ex.getLineNumber());
            }
        }
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<VehicleOwnersResourceDto>();
        }
    }

    public List<VehicleOwnersResourceDto> Data {get; set;}

}
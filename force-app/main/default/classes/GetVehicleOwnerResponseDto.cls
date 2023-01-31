/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

global with sharing class GetVehicleOwnerResponseDto {


    public GetVehicleOwnerResponseDto(){
        init();
    }
    
    private void init(){
        if (this.Data == null){
            this.Data = new List<VehicleOwnersResourceDto>();
        }
    }

    public List<VehicleOwnersResourceDto> Data {get; set;}

}
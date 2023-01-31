/**
 * Created by caleb@argologic.com.au on 11/12/2019.
 */

global with sharing class UpdateVehicleOwnersRequestDto
{

    public List<UpdateVehicleOwnersResourceDto> Data {get; set;}

    private void init()
    {
        if (Data == null)
        {
            this.Data = new List<UpdateVehicleOwnersResourceDto>();
        }
    }

    public UpdateVehicleOwnersRequestDto()
    {
        init();
    }
}
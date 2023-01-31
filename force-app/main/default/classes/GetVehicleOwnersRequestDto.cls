/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019..
 */

global with sharing class GetVehicleOwnersRequestDto extends BaseRequestDto {

    public DateTime DateStart {get; set;}
    public String StartNumber {get; set;}

}
/**
 * Created by caleb@argologic.com.au on 17/12/2019.
 */

public with sharing class UpdateVehicleOwnersResourceDto
{
    public enum OwnerType { NewOwner, EndOfOwnership}
    public OwnerType OwnershipType {get; set;}
    public UpdateVehicleOwnersAttributeDto Attributes {get; set;}
}
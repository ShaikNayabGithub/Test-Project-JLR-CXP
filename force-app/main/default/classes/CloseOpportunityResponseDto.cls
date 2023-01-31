/**
 * Created by caleb@argologic.com.au on 5/02/2020.
 */

public with sharing class CloseOpportunityResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public Boolean AssetAlreadyAssignedToOpportunity;

    @AuraEnabled
    public List<SetAssetOpportunityDto> DuplicateOpportunities;

    public CloseOpportunityResponseDto()
    {
        this.DuplicateOpportunities = new List<SetAssetOpportunityDto>();
    }
}
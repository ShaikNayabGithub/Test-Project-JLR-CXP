/**
 * Created by caleb on 10/09/2019.
 */

public with sharing class CreateAssetResponseDto extends BaseResponseDto
{
    public CreateAssetResponseDto()
    {

    }

    public CreateAssetResponseDto(string assetId)
    {
        this();
        this.assetId = assetId;
    }

    @AuraEnabled
    public string AssetId;
}
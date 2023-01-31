/**
 * Created by caleb on 11/09/2019.
 */

public with sharing class AssetResourceDto extends BaseResourceDto
{

    private void init()
    {
        if (this.Attributes == null)
        {
            this.Attributes = new AssetAttributeDto();
        }
    }

    public AssetResourceDto()
    {
        init();
    }
    @AuraEnabled
    public AssetAttributeDto Attributes {get; set;}
}
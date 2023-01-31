/**
 * Created by caleb@argologic.com.au on 1/12/2020.
 */

@IsTest
public with sharing class DeleteOpportunityProductDtoTest
{
    @IsTest
    public static void test1()
    {
        DeleteOpportunityProductDto dto = new DeleteOpportunityProductDto();
        dto.DoDeleteProduct = false;
        dto.DoDeleteAsset = false;
        dto.DoDeleteServicePlan = false;
        dto.OpportunityId = '1234';
    }
}
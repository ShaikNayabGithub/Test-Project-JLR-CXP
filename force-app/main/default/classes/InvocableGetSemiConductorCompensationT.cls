/**
 * Created by ethan@argologic.com.au on 18/11/21.
 */

@IsTest
private class InvocableGetSemiConductorCompensationT
{

    @IsTest(SeeAllData=true)
    static void testBehavior()
    {
        // Arrange
        Id sandboxAssetId = [SELECT Id FROM Asset LIMIT 1].Id;
        Id prodAssetId = '02i0600001DDJvs';
        Id testId = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ? sandboxAssetId : prodAssetId;
        // Act
        Test.startTest();
        InvocableGetSemiconductorCompensationRow.get(new List<Id> {testId});
        Test.stopTest();

        // Assert

    }

    @IsTest
    static void testCoverDto()
    {
        InvocableGetSemiconductorCompensationDto dto = new InvocableGetSemiconductorCompensationDto();
        dto.tableHtml = 'html';
        dto.totalCompensation = 1;
    }
}
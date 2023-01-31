@isTest
private class aop_CheckfrontItemParserTest {

    static testMethod void TestSettingVariables() {
    	Test.startTest();
        aop_CheckfrontItemParser newParser = new aop_CheckfrontItemParser();
        aop_CheckfrontItemParser.aop_ItemContainer  container = new aop_CheckfrontItemParser.aop_ItemContainer();
        container.version = 'one';
        Test.stopTest();
        
        System.assertEquals(container.version, 'one');
    }
}
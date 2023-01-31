@IsTest
private class JUDAAN_BackPrice2Apex_Test {
    
    static testMethod void testParse() {
        String json = '{\"calcResult\":\"0\",\"backPrice\":6697000}';
        JUDAAN_BackPrice2Apex obj = JUDAAN_BackPrice2Apex.parse(json);
        obj.calcResult = '';
        obj.backPrice = 0;
        obj.error = '';
        System.assert(obj != null);
    }
    
    static testMethod void testParse2() {
        String json = '';
        JUDAAN_BackPrice2Apex obj = JUDAAN_BackPrice2Apex.parse(json);
        obj.calcResult = '';
        obj.backPrice = 0;
        obj.error = '';
        System.assert(obj != null);
    }
}
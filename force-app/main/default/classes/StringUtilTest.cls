/* *************************************************************************************************************    
Class Name    : StringUtilTest 
Description   : This class is used for testing functionality of StringUtill 
CreatedDate   : 23 Mar 2018         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                

***************************************************************************************************************** */

@isTest
private class StringUtilTest {
    Static list<string>teststring;

    static testMethod void TestStringutil() {
        teststring = new list<string>{'testing string'};
        StringUtil.splitMultiplePickList('test;string;');
        stringUtil.formatCurrency('455');
        stringUtil.zeroPadding(3,2);
        stringUtil.getValue('testing');
        stringUtil.splitImageLink('testing,string');
        stringUtil.getInOperatorValue('testing,string');
        stringUtil obj = new stringUtil();
        obj.isoLangCode2('Abkhazian');
        obj.isoCountryCode3 ('AX');
    }
    
}
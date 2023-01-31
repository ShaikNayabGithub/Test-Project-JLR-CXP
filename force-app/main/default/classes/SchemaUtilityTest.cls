@isTest
public class SchemaUtilityTest {
static TestMethod void getObjectLabelMapTest(){
SchemaUtility.getObjectLabelMap('Account');
SchemaUtility.getPickListValues('Account','Industry');
SchemaUtility.getObjectFieldSetFieldNames('Account','');

}
}
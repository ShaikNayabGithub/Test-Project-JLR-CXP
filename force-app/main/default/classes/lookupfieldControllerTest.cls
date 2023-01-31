@isTest
public class lookupfieldControllerTest {
    
    @isTest
    public static void testMethod1(){
        lookupfieldController.GetRecentRecords('Lead', new List<String>{'LastName'}, 5);
        lookupfieldController.SearchRecords('Lead', new List<String>{'LastName'}, new List<String>{'LastName'}, '', '', '', 5, '');
        lookupfieldController.GetRecord('Lead', new List<String>{'LastName'}, '');
        lookupfieldController.findObjectIcon('Lead');
        lookupfieldController.getObjectDetails('Lead');
    }

}
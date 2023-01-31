@isTest
public class TestClass_LockableRecordInserter {
    public static void AttemptInsert(List<SObject> record, integer maximumNumberOfAttempts)
    {
        integer numberOfAttempts = 0;
        boolean recordInserted = false;
        
        while (recordInserted == false) {
            numberOfAttempts++;            
            try{
                insert record;
                recordInserted = true; //NTTData uncommented code to ensure infinite loop does not occur in Unit Tests (18/01/2017)
            }
            catch(DMLException e) { 
                if(numberOfAttempts == maximumNumberOfAttempts) {
                    throw e;
                }
            }
        }
    }
    
    public static void AttemptInsert(SObject record, integer maximumNumberOfAttempts)
    {
        List<SObject> records = new List<SObject>();
        records.add(record);
        AttemptInsert(records, maximumNumberOfAttempts);
    }
}
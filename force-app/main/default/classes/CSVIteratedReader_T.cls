@isTest
public class CSVIteratedReader_T {
    static testMethod void Read_ReturnsEmptyMap_GivenEmptyList()
    {
        CSVIteratedReader reader = new CSVIteratedReader();

        List<String> csvRows = new List<String>();


        Map<Integer, List<String>> result = reader.Read(csvRows);


        System.assertEquals(0, result.Size());
    }

    static testMethod void Read_ReturnsEmptyMap_GivenListOfIgnoredChars()
    {
        CSVIteratedReader reader = new CSVIteratedReader();

        String row1 = ',,,,,,,,,,';

        List<String> csvRows = new List<String> { row1 };


        Map<Integer, List<String>> result = reader.Read(csvRows);


        System.assertEquals(0, result.Size());
    }

    static testMethod void Read_ReturnsC1R1_GivenC1R1()
    {
        CSVIteratedReader reader = new CSVIteratedReader();

        Integer row1Index = 0;
        String column1row1Value = 'c1r1';
        String row1String = row1Index + CSVParser.ROW_NUMBER_TAG + '"' + column1row1Value + '"';

        List<String> csvRows = new List<String> { row1String };


        Map<Integer, List<String>> result = reader.Read(csvRows);


        System.assertEquals(column1row1Value, result.get(row1Index)[0]);
    }

    static testMethod void Read_ReturnsC2R1_GivenC2R1()
    {
        CSVIteratedReader reader = new CSVIteratedReader();

        Integer row1Index = 0;
        String column1row1Value = 'c1r1';
        String column2row1Value = 'c2r1';
        String row1String = row1Index + CSVParser.ROW_NUMBER_TAG + '"' + column1row1Value + '",' + column2row1Value;

        List<String> csvRows = new List<String> { row1String };


        Map<Integer, List<String>> result = reader.Read(csvRows);


        System.assertEquals(column2row1Value, result.get(row1Index)[1]);
    }

    static testMethod void Read_ReturnsC2R2_GivenC1R1AndC2R2()
    {
        CSVIteratedReader reader = new CSVIteratedReader();

        Integer row1Index = 1;
        String column1row1Value = 'c1r1';
        String column2row1Value = 'c2r1';
        String row1String = row1Index + CSVParser.ROW_NUMBER_TAG + '"' + column1row1Value + '",' + column2row1Value;
        Integer row2Index = 2;
        String column1row2Value = 'c1r2';
        String column2row2Value = 'c2r2';
        String row2String = row2Index + CSVParser.ROW_NUMBER_TAG + '"' + column1row2Value + '",' + column2row2Value;

        List<String> csvRows = new List<String> { row1String, row2String };


        Map<Integer, List<String>> result = reader.Read(csvRows);


        System.assertEquals(column2row2Value, result.get(row2Index)[1]);
    }
    
     static testMethod void Iterator_constructor()
    {
      CSVIterator csvIter = new CSVIterator('test1,test2,test3\n', CSVParser.lf);
      csvIter.hasNext();
      String next= CSVIter.next();
      
      System.assertEquals('1::RN::test1,test2,test3',next);
     
     }
     
     static testMethod void testHeader(){
         
         Map<String, Integer> parseHeader;
         Apex_job__c apexJob= new apex_job__c();
         apexJob.File_Header__c='1::RN::test1,test2';
         
         insert apexJob;
         
         CSVIteratedReader reader= new CSVIteratedReader ();
         
         CSVUpload_HeaderParser headerParser= new CSVUpload_HeaderParser(reader);
         parseHeader=headerParser.ParseHeader(apexJob);
         
         System.assertNotEquals(null,parseHeader);
     } 
     
     static testMethod void testPairedListPopulator(){
     
        Map<Integer, SObject> recordsByRowIndex= new Map<integer,sobject>();
        account acc= new Account(lastName='test1',phone='0743432233');
        insert acc;
        
        List<Integer> RowIndexes = new List<Integer>();
        List<SObject> Records = new List<SObject>();
        
        rowIndexes.add(1); 
        records.add(acc);
        
        Map<Integer, CSVRowStatus> lineStatusesByRowIndex= new Map<Integer,CSVRowStatus>();
        CSVUpload_ErrorProcessor errorProcessor= new CSVUpload_ErrorProcessor();  
        CSVUpload_PairedList insertList = new CSVUpload_PairedList();
        insertList.rowIndexes=rowIndexes;
        insertList.records=records;
        
        CSVUpload_PairedList updateList = new CSVUpload_PairedList();
        CSVUpload_PairedListPopulator pairedListPopulator= new CSVUpload_PairedListPopulator ();
        Database.SaveResult[] insertResults = Database.Insert(insertList.Records, false);

       pairedListPopulator.PopulateLists(insertList, updateList, recordsByRowIndex, lineStatusesByRowIndex);
     
     }
     
     static testMethod void testLogger(){
        
        Map<Integer,asset> mapIntToAsset= new Map<Integer,asset>();
        Map<Integer, CSVRowStatus> LineStatusesByRowIndex=new Map<Integer, CSVRowStatus>();
        Asset asset1= TestClass_AssetBuilder.buildvehicle();
        insert asset1;
        
        LineStatusesByRowIndex.put(1, new CSVRowStatus()) ;
        
        mapIntToAsset.put(1,asset1);
        FinanceUpload_RecordCollection recordCollection = new FinanceUpload_RecordCollection();
        recordcollection.AssetsByRowId=mapIntToAsset;
        String headers='1::RN::test1,test2';
        String test1='test1,test2\n';
        List<String> listString= new List<String>();
        liststring.add(headers);
        List<String> listStringValues= new List<String>();
        liststringvalues.add(test1);
        Map<Integer, List<String>> LinesByRowIndex=new  Map<Integer, List<String>>();
        LinesByRowIndex.put(1,liststring);
        LinesByRowIndex.put(2,liststringvalues);
        Map<String, Integer> ColumnIndexesByFieldName= new Map<String, Integer>();
        
        ColumnIndexesByFieldName.put('VIN',0);
        ColumnIndexesByFieldName.put('Phone',1);
        
        CSVUpload_DataCollection csvdatacollection = new CSVUpload_DataCollection ();
        Apex_job__c apexJob= new apex_job__c();
        apexJob.File_Header__c='1::RN::test1,test2';
         
        insert apexJob;
        
        csvdatacollection.ApexJob=apexjob;
        csvdatacollection.LineStatusesByRowIndex=LineStatusesByRowIndex;
        recordCollection.csvdatacollection=  csvdatacollection ;
        recordCollection.csvdatacollection.linesbyrowindex=LinesByRowIndex;
        recordCollection.csvdatacollection.ColumnIndexesByFieldName =ColumnIndexesByFieldName ;
        
        CSVUpload_ResultsLogger logger= new CSVUpload_ResultsLogger ();
        logger.LogResults(recordCollection.csvdatacollection);
     
        
        List<apex_job__c> listJobs=[select id,Results_Log__c from apex_job__c where id=:apexJob.id];
        apex_job__c updatedJob= listjobs[0];
        
        System.assertEquals('1::RN::"Success"',updatedJob.Results_Log__c); 
     
     }
     
     
     
     
}
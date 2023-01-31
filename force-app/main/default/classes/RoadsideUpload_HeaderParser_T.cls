@isTest
public class RoadsideUpload_HeaderParser_T {
    static testMethod void ParseHeader_ReturnsEmptyMap_GivenJobWithNoHeaders() 
    {
        RoadsideUpload_HeaderParser headerParser = BuildParser();

        Apex_Job__c apexJob = new Apex_Job__c();


        Map<String, Integer> result = headerParser.ParseHeader(apexJob);


        System.assertEquals(0, result.Size());
    }

    static testMethod void ParseHeader_Returns0ByH1_GivenJobWithHeaderH1()
    {
        RoadsideUpload_HeaderParser headerParser = BuildParser();

        String header1 = 'H1';
        Apex_Job__c apexJob = new Apex_Job__c(
            File_Header__c = CSVParser.ROW_START_INDEX + CSVParser.ROW_NUMBER_TAG + '"' + header1 + '"'
        );


        Map<String, Integer> result = headerParser.ParseHeader(apexJob);


        System.assertEquals(0, result.get(header1));
    }

  


    static RoadsideUpload_HeaderParser BuildParser()
    {
        CSVIteratedReader csvReader = new CSVIteratedReader();

        return new RoadsideUpload_HeaderParser(csvReader);
    }
}
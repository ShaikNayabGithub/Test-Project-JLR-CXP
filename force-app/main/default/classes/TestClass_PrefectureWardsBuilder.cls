/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 25/10/2019.
 */

public with sharing class TestClass_PrefectureWardsBuilder {

    public static void generatePrefectureWardsMapping(String prefecture, List<String> wards)
    {
        List<JUDAAN_Prefecture_Ward__c> pws = new List<JUDAAN_Prefecture_Ward__c>();
        for(String ward : wards)
        {
            pws.add(new JUDAAN_Prefecture_Ward__c(Name = ward, Prefecture__c = prefecture, Ward__c = ward));
        }
        insert pws;
    }

}
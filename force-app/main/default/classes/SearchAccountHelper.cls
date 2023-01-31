public with sharing class SearchAccountHelper {
    
     public static List<List<SObject>> getSearchRecords(string searchQuery){
         return search.query(searchQuery);
     }

}
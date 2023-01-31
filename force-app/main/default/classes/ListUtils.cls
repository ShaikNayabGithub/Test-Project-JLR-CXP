/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 26/11/2019.
 */

public with sharing class ListUtils {

    public static Boolean isNullOrEmpty(List<SObject> aList){
        return aList == null || aList.isEmpty();
    }

    public static Boolean isNullOrEmpty(List<PricebookEntry> aList){
        return aList == null || aList.isEmpty();
    }

    public static Boolean isNullOrEmpty(List<String> aList){
        return aList == null || aList.isEmpty();
    }

    public static Boolean isNotNullOrEmpty(List<SObject> aList){
        return !(aList == null || aList.isEmpty());
    }

    public static Boolean isNotNullOrEmpty(List<PricebookEntry> aList){
        return !(aList == null || aList.isEmpty());
    }

    public static Boolean isNotNullOrEmpty(List<String> aList){
        return !(aList == null || aList.isEmpty());
    }
}
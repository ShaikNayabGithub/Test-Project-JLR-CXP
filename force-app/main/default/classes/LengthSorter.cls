public class LengthSorter implements Comparable
{
    public Dispensable_Value__mdt record;
    final Integer length;
    public LengthSorter(Dispensable_Value__mdt record)
    {
        this.record = record;
        if (String.isBlank(record.Label)) length = 0;
        else length = record.Label.length();
    }
    public Integer compareTo(Object instance)
    {
        LengthSorter that = (LengthSorter)instance;
        return that.length - this.length;
    }
}
/*
List<LengthSorter> wrappers = new List<LengthSorter>();
for (User record : [SELECT Name FROM User])
    wrappers.add(new LengthSorter(record));
wrappers.sort(); */
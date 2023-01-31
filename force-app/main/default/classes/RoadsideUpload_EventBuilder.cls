public class RoadsideUpload_EventBuilder {
    private final RoadsideUpload_AssetGetter assetGetter;
    private final RoadsideUpload_WhoGetter whoGetter;
    private final RoadsideUpload_SimpleFieldSetter simpleFieldSetter;


    public RoadsideUpload_EventBuilder(RoadsideUpload_AssetGetter assetGetter,
            RoadsideUpload_WhoGetter whoGetter, RoadsideUpload_SimpleFieldSetter simpleFieldSetter)
    {
        this.assetGetter = assetGetter;
        this.whoGetter = whoGetter;
        this.simpleFieldSetter = simpleFieldSetter;
    }


    public void Build(RoadsideUpload_RecordCollection recordCollection)
    {
        if(recordCollection.EventByCSVRowNumber == null) {
            recordCollection.EventByCSVRowNumber = new Map<Integer, Event>();
        }

        for(Integer csvRowIndex : recordCollection.CSVData.LinesByRowIndex.keySet()) {
            CSVRowStatus rowStatus = recordCollection.CSVData.LineStatusesByRowIndex.get(csvRowIndex);
            if(rowStatus != null && rowStatus.HasErrored == true) continue;

            Event eventRecord = new Event(RecordTypeId = EventUtilities.RecordTypes.get('Roadside').Id);
            recordCollection.EventByCSVRowNumber.put(csvRowIndex, eventRecord);

            List<String> rowData = recordCollection.CSVData.LinesByRowIndex.get(csvRowIndex);
            Asset what = this.assetGetter.GetAsset(rowData, recordCollection);
            SObject who = this.whoGetter.GetWho(rowData, recordCollection);
           
            boolean whoIdisNotLead;
            String idPrefix;
            
            if(who != null) {
                idPrefix = String.valueOf(who.id).substring(0,3);
                if(idPrefix!='00Q')
                    whoIdisNotLead=true;    
                
                if(whoIdisNotLead==true)
                    eventRecord.WhoId = who.Id;
            }
            
             if(what != null ) {
                eventRecord.WhatId = what.Id;
            }

            eventRecord.IsReminderSet = false;
            eventRecord.Subject = 'Roadside';
            
           

            this.simpleFieldSetter.SetSimpleFields(eventRecord, rowData, recordCollection.CSVData);

            eventRecord.StartDateTime = eventRecord.Time_Call_Received__c;
            eventRecord.EndDateTime = eventRecord.Resolution_Time__c;
            
            System.debug('event created: '+eventRecord);
        }
    }
}
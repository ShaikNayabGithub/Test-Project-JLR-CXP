public class RoadsideUpload_BatchProcessor_F implements FileUpload_BatchProcessor_FI {
    public String GetLabel() {
        return System.Label.Roadside;
    }

    public String GetName() {
        return 'Roadside';
    }

    public Set<String> GetSupportedFileFormats() {
        return new Set<String> { 'csv' };
    }


    public Database.Batchable<String> Create(Id attachmentId, Id apexJobId) {
        return new RoadsideUpload_BatchProcessor_Batch(attachmentId, apexJobId);
    }
    
      public Document GetTemplate() {
        List<Document> tempateList = [SELECT Id FROM Document WHERE DeveloperName = 'Roadside_Template'];
        if(tempateList.Size() == 0) return null;
        else return tempateList[0];
    }
}
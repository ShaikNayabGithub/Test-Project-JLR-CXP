public class FileUpload_Controller {
    public Blob file { get; set; }
    public String fileName { get; set; }
    public String contentType { get; set; }
    public String processorName { get; set; }
    public List<String> templateIds { get; private set; }

    private final Map<String, FileUpload_BatchProcessor_FI> batchProcessorFactoriesByName;
    private final FileUpload_FileValidator fileValidator;


    public FileUpload_Controller()
    {
        FileUpload_BatchProcessorFRetriever batchProcessorFactoryRetriever = new FileUpload_BatchProcessorFRetriever();
        this.batchProcessorFactoriesByName = batchProcessorFactoryRetriever.RetrieveFactories();
        this.fileValidator = new FileUpload_FileValidator();
        this.templateIds = new List<String>();
    }


    public List<SelectOption> getProcessors()
    {
        List<SelectOption> options = new List<SelectOption> {
                new SelectOption('--None--', '--' + System.Label.None + '--') };

        for(String processorName : batchProcessorFactoriesByName.keySet()) {
            FileUpload_BatchProcessor_FI batchProcessorFactory = batchProcessorFactoriesByName.get(processorName);
            SelectOption selectOption = new SelectOption(batchProcessorFactory.GetLabel(), batchProcessorFactory.GetName());
            options.add(selectOption);
            
            Document template = batchProcessorFactory.GetTemplate();
            if(template != null && String.isNotEmpty(template.Id)) this.templateIds.add(template.Id);           
        }

        return options;
    }

    public PageReference Refresh() 
    {
        PageReference thisPage = Page.FileUpload;
        thisPage.setRedirect(true);
        return thisPage;
    }

    public void Upload()
    {
        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Status = ApexPages.Severity.CONFIRM;
        fileStatus.Message = System.Label.File_Queued;

        FileUpload_BatchProcessor_FI batchProcessorFactory = this.batchProcessorFactoriesByName.get(this.processorName);
        if(batchProcessorFactory == null) return;

        this.fileValidator.ValidateSize(this.file, fileStatus);
        this.fileValidator.ValidateExtension(this.fileName, batchProcessorFactory, fileStatus);

        if(fileStatus.Status == ApexPages.Severity.CONFIRM) {
            Savepoint savepoint = Database.setSavepoint();
            try {
                Apex_Job__c apexJob = this.CreateApexJob();
                ContentVersion conVer = this.SaveFile(apexJob.Id);

                Database.Batchable<String> batchProcessor = batchProcessorFactory.Create(conVer.Id, apexJob.Id);
                Id batchJobId = Database.ExecuteBatch(batchProcessor);

                apexJob.Name = batchJobId;
                update apexJob;
            } 
            catch(System.DMLException e)
            {
                Database.rollback(savepoint);
                fileStatus.Status = ApexPages.Severity.ERROR;
                fileStatus.Message = e.getMessage();    
            }
        }

        this.ProcessStatus(fileStatus);
    }


    private Apex_Job__c CreateApexJob()
    {
        Apex_Job__c apexJob = new Apex_Job__c (
            Name = 'Temp',
            Status__c = ApexJobUtilities.QUEUED_STATUS
        );
        insert apexJob;
        return apexJob;     
    }

    private ContentVersion SaveFile(Id parentId)
    {
        ContentVersion conVer= new ContentVersion();
        conVer.Title=this.fileName;
        conVer.PathOnClient=this.fileName;
        conVer.IsMajorVersion=true;
        conVer.VersionData=this.file;
        insert conVer;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = parentId;
        conDocLink.ContentDocumentId = conDocId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        /*Attachment attachment = new Attachment (
            Name = this.fileName,
            Body = this.file,
            ContentType = this.ContentType,
            ParentID = parentId
        );
        insert attachment;*/
        return conVer;
    }

    private void ProcessStatus(FileUpload_FileStatus fileStatus)
    {
        ApexPages.addMessage(new ApexPages.Message(fileStatus.Status, fileStatus.Message));
        this.file = null;  
        this.fileName = '';
        this.ContentType = '';
    }
}
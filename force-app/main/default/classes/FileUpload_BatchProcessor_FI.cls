public interface FileUpload_BatchProcessor_FI {
	String GetLabel();
	String GetName();
	Set<String> GetSupportedFileFormats();
	Document GetTemplate();
	Database.Batchable<String> Create(Id attachmentId, Id apexJobId);
}
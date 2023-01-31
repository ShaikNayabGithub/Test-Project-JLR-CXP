public interface I_HttpMessager_Siebel extends I_HttpMessager{
	string GetSiebelDMLAction(string dmsRecordId);
	string GetDMSInnerException(string soapBody);
}
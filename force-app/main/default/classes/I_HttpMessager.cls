public interface I_HttpMessager {
	HttpResponse SendRequest(string soapBody, boolean isOutbound);
}
public class DMS_PrefixHandler {
	private final string prefix;

	public DMS_PrefixHandler(string prefix) {
		this.prefix = prefix;
	}

	public string RemovePrefix(string id)
	{
		if(String.isEmpty(id)){ return ''; }
		return id.replace(prefix, '');
	}

	public string AddPrefix(string id)
	{
		if(String.isEmpty(id)){ return ''; }
		return prefix + id;
	}
}
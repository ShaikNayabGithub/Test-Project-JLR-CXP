public class VISTAResponseWrapper {

	public class Sender {
		public String LogicalID;
		public String ComponentID;
		public String TaskID;
		public String AuthorizationID;
	}

	public class ConfirmPostBrandOccurrence {
		public ApplicationArea ApplicationArea;
		public DataArea DataArea;
		public String systemEnvironmentCode;
		public String environment;
		public String versionID;
		public String releaseID;
	}

	public class PostBrandOccurrence {
		public String AcceptRejectIndicator;
		public Messages Messages;
	}

	public class DataArea {
		public PostBrandOccurrence PostBrandOccurrence;
	}

	public ConfirmPostBrandOccurrence ConfirmPostBrandOccurrence;

	public class Message {
		public String MessageType;
		public String Description;
	}

	public class Messages {
		public Message Message;
	}

	public class ApplicationArea {
		public Sender Sender;
		public String CreationDateTime;
		public String BODID;
	}

	
	public static VISTAResponseWrapper parse(String json) {
		return (VISTAResponseWrapper) System.JSON.deserialize(json, VISTAResponseWrapper.class);
	}
}
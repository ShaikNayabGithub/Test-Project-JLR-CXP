public class LockWonOpps {
	
	public static void lock(List<Opportunity> wonOpps) {
		
		for (Opportunity opp : wonOpps) {
			
			Approval.lock(opp.Id);
		}
	}
}
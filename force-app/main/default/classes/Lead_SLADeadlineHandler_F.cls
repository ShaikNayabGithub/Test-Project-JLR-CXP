public class Lead_SLADeadlineHandler_F {
	public Lead_SLADeadlineHandler Create()
	{
		BusinessHours_ByOwnerMapper businessHoursMapper = new BusinessHours_ByOwnerMapper();
		Lead_SLADeadlineSetter slaDeadlineSetter = new Lead_SLADeadlineSetter();

		return new Lead_SLADeadlineHandler(businessHoursMapper, slaDeadlineSetter);
	}
}
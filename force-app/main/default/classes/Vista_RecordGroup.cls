global class Vista_RecordGroup implements Comparable {
	public Vista_Request__c Request;
	public Vista_OrderService.VehicleOrder VistaVehicleOrder;

    private final Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
    private static final Map<String, Integer> EVENT_CODE_VALUES = new Map<String, Integer> {
        Vista_EventCodes.CONFIRMOK => 1,
        Vista_EventCodes.RETRY => 2,
        Vista_EventCodes.DLRTAG => 3,
        Vista_EventCodes.PLANNING => 4,
        Vista_EventCodes.STATUS => 5,
        Vista_EventCodes.SHIPPING => 6,
        Vista_EventCodes.NONSPEC => 7,
        Vista_EventCodes.SPECMEND => 8,
        Vista_EventCodes.HANDOVER => 9,
        Vista_EventCodes.SECHDOVER => 10,
        Vista_EventCodes.DELETE_CODE => 11
    };


    //.sort() ranks lowest to highest
    global Integer compareTo(Object compareTo) {
    	Vista_RecordGroup compareToGroup = (Vista_RecordGroup)compareTo;

    	if(compareToGroup.VistaVehicleOrder == null && this.VistaVehicleOrder == null) {
            return 0;
    	}
        else if(this.VistaVehicleOrder == null) {
            return -1;
        } else if(compareToGroup.VistaVehicleOrder == null) {
            return 1;
        }
        else if(this.Request.CreatedDate != compareToGroup.Request.CreatedDate){
            if(this.Request.CreatedDate < compareToGroup.Request.CreatedDate) {
                return -1;
            }
            else if(this.Request.CreatedDate > compareToGroup.Request.CreatedDate) {
                return 1;
            }
        }
        else {
            Integer thisEventValue = EVENT_CODE_VALUES.get(this.VistaVehicleOrder.Eventcode);
            Integer comparedEventValue = EVENT_CODE_VALUES.get(compareToGroup.VistaVehicleOrder.Eventcode);

            if(thisEventValue == null && comparedEventValue == null){
                return 0;
            }else if(thisEventValue == null) {
                return -1;
            } else if(comparedEventValue == null) {
                return 1;
            }

            if(thisEventValue < comparedEventValue) {
                return -1;
            }
            else if(thisEventValue > comparedEventValue) {
                return 1;
            }
        }

        return 0;
    }
}
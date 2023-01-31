public class Vista_OrderBuilder_F {
    public Vista_OrderBuilder Create()
    {
        Map<String, Vista_OrderBuilder_A> eventHandlers = new Map<String, Vista_OrderBuilder_A>();
        
        Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();

        Vista_OrderBuilder_CONFIRMOK confirmOkHandler = new Vista_OrderBuilder_CONFIRMOK();
        Vista_OrderBuilder_HANDOVER handoverHandler = new Vista_OrderBuilder_HANDOVER();
        Vista_OrderBuilder_2NDHDOVER secondhandoverHandler = new Vista_OrderBuilder_2NDHDOVER();
        Vista_OrderBuilder_CANHDOVER cancelHandoverHandler = new Vista_OrderBuilder_CANHDOVER();
        Vista_OrderBuilder_NONSPEC nonSpecHandler = new Vista_OrderBuilder_NONSPEC(dateAdapter);
        Vista_OrderBuilder_SPECMEND specMendHandler = new Vista_OrderBuilder_SPECMEND();
        Vista_OrderBuilder_DELETE deleteHandler = new Vista_OrderBuilder_DELETE();
        Vista_OrderBuilder_RETRY retryHandler = new Vista_OrderBuilder_RETRY();
        Vista_OrderBuilder_Default dlrtagHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.DLRTAG);
        Vista_OrderBuilder_Default planningHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.PLANNING);
        Vista_OrderBuilder_Default statusHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.STATUS);
        Vista_OrderBuilder_Default shippingHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.SHIPPING);
        Vista_OrderBuilder_Default bmyuokHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.BMYUOK);
        Vista_OrderBuilder_Default holdHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.HOLD);  
        Vista_OrderBuilder_Default lifecyclHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.LIFECYCL);  
        Vista_OrderBuilder_Default neworderHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.NEWORDER);
        Vista_OrderBuilder_Default nsccpddupdHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.NSCCPDDUPD);
        Vista_OrderBuilder_Default pullxferHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.PULLXFER);
        Vista_OrderBuilder_Default registratiHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.REGISTRATI);
        Vista_OrderBuilder_Default uncTradeHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.UNCTRADE);
        Vista_OrderBuilder_Default vehupdtHandler = new Vista_OrderBuilder_Default(Vista_EventCodes.VEHUPDT);  

        eventHandlers.put(confirmOkHandler.EventCode, confirmOkHandler);
        eventHandlers.put(handoverHandler.EventCode, handoverHandler);
        eventHandlers.put(secondhandoverHandler.EventCode, secondhandoverHandler );
        eventHandlers.put(cancelHandoverHandler.EventCode, cancelHandoverHandler);
        eventHandlers.put(nonSpecHandler.EventCode, nonSpecHandler);
        eventHandlers.put(specMendHandler.EventCode, specMendHandler);
        eventHandlers.put(retryHandler.EventCode, retryHandler);
        eventHandlers.put(dlrtagHandler.EventCode, dlrtagHandler);
        eventHandlers.put(planningHandler.EventCode, planningHandler);
        eventHandlers.put(statusHandler.EventCode, statusHandler);
        eventHandlers.put(shippingHandler.EventCode, shippingHandler);
        eventHandlers.put(bmyuokHandler.EventCode, bmyuokHandler );
        eventHandlers.put(holdHandler.EventCode, holdHandler );
        eventHandlers.put(lifecyclHandler.EventCode, lifecyclHandler);
        eventHandlers.put(neworderHandler.EventCode, neworderHandler);
        eventHandlers.put(nsccpddupdHandler.EventCode, nsccpddupdHandler);
        eventHandlers.put(pullxferHandler.EventCode, pullxferHandler);
        eventHandlers.put(registratiHandler.EventCode, registratiHandler);
        eventHandlers.put(uncTradeHandler.EventCode, uncTradeHandler);
        eventHandlers.put(vehupdtHandler.EventCode, vehupdtHandler);
        eventHandlers.put(deleteHandler.EventCode, deleteHandler);
  
        return new Vista_OrderBuilder(eventHandlers);
    }
}
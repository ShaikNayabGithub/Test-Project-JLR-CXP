public class Vista_AssetBuilder_F {
    public Vista_AssetBuilder Create()
    {
        Map<String, Vista_AssetBuilder_A> eventHandlers = new Map<String, Vista_AssetBuilder_A>();

        Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
        Vista_AssetNonSpecSetter nonSpecSetter = new Vista_AssetNonSpecSetter(dateAdapter);
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();

        Vista_AssetBuilder_CONFIRMOK confirmOkHandler = new Vista_AssetBuilder_CONFIRMOK(nonSpecSetter, specSetter);
        Vista_AssetBuilder_HANDOVER handoverHandler = new Vista_AssetBuilder_HANDOVER(nonSpecSetter, specSetter, dateAdapter);
        Vista_AssetBuilder_2NDHDOVER secondhandoverHandler = new Vista_AssetBuilder_2NDHDOVER (nonSpecSetter, specSetter, dateAdapter);
        Vista_AssetBuilder_CANHDOVER cancelHandoverHandler = new Vista_AssetBuilder_CANHDOVER(nonSpecSetter, specSetter, dateAdapter);
        Vista_AssetBuilder_NONSPEC nonSpecHandler = new Vista_AssetBuilder_NONSPEC(nonSpecSetter, specSetter);
        Vista_AssetBuilder_SPECMEND specMendHandler = new Vista_AssetBuilder_SPECMEND(nonSpecSetter, specSetter);
        Vista_AssetBuilder_RETRY retryHandler = new Vista_AssetBuilder_RETRY(nonSpecSetter, specSetter);
        Vista_AssetBuilder_Default dlrtagHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.DLRTAG);
        Vista_AssetBuilder_Default planningHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.PLANNING);
        Vista_AssetBuilder_Default statusHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.STATUS);
        Vista_AssetBuilder_Default shippingHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.SHIPPING);
        Vista_AssetBuilder_Default bmyuokHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.BMYUOK);
        Vista_AssetBuilder_Default holdHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.HOLD);  
        Vista_AssetBuilder_Default lifecyclHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.LIFECYCL);  
        Vista_AssetBuilder_Default neworderHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.NEWORDER);
        Vista_AssetBuilder_Default nsccpddupdHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.NSCCPDDUPD);
        Vista_AssetBuilder_Default pullxferHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.PULLXFER);
        Vista_AssetBuilder_Default registratiHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.REGISTRATI);
        Vista_AssetBuilder_Default uncTradeHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.UNCTRADE);
        Vista_AssetBuilder_Default vehupdtHandler = new Vista_AssetBuilder_Default(nonSpecSetter, specSetter, 
                Vista_EventCodes.VEHUPDT);  

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

        return new Vista_AssetBuilder(eventHandlers);
    }
}
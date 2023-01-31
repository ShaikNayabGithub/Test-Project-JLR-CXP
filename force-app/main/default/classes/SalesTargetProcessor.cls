public class SalesTargetProcessor {
    
    public static SalesTargetWrapper processTargets(
        SalesTargetWrapper salesupdateWrap,
        String salesPersonId,
        Integer mnth,
        Integer curryear,
        decimal recCnt,
        String type){
            
            SalesTargetWrapper salesWrap;
            if(salesupdateWrap == null){
                salesWrap = new SalesTargetWrapper();
            }else{
                salesWrap = salesupdateWrap;
            }
            salesWrap.salesPersonId = salesPersonId;
            salesWrap.year = curryear; 
            
            if(type == 'Order' || type == 'Order Taken'){
                
                if(mnth == 1) if(salesWrap.aprOrder == null) salesWrap.aprOrder = recCnt; else salesWrap.aprOrder += recCnt;
                if(mnth == 2) if(salesWrap.mayOrder == null) salesWrap.mayOrder = recCnt; else salesWrap.mayOrder += recCnt;
                if(mnth == 3) if(salesWrap.junOrder == null) salesWrap.junOrder = recCnt; else salesWrap.junOrder += recCnt;
                if(mnth == 4) if(salesWrap.julOrder == null) salesWrap.julOrder = recCnt; else salesWrap.julOrder += recCnt;
                if(mnth == 5) if(salesWrap.augOrder == null) salesWrap.augOrder = recCnt; else salesWrap.augOrder += recCnt;
                if(mnth == 6) if(salesWrap.sepOrder == null) salesWrap.sepOrder = recCnt; else salesWrap.sepOrder += recCnt;
                if(mnth == 7) if(salesWrap.octOrder == null) salesWrap.octOrder = recCnt; else salesWrap.octOrder += recCnt;
                if(mnth == 8) if(salesWrap.novOrder == null) salesWrap.novOrder = recCnt; else salesWrap.novOrder += recCnt;
                if(mnth == 9) if(salesWrap.decOrder == null) salesWrap.decOrder = recCnt; else salesWrap.decOrder += recCnt;
                if(mnth == 10) if(salesWrap.janOrder == null) salesWrap.janOrder = recCnt; else salesWrap.janOrder += recCnt;
                if(mnth == 11) if(salesWrap.febOrder == null) salesWrap.febOrder = recCnt; else salesWrap.febOrder += recCnt;
                if(mnth == 12) if(salesWrap.marOrder == null) salesWrap.marOrder = recCnt; else salesWrap.marOrder += recCnt;
                
            }else if(type == 'Handover'){
                
                if(mnth == 1) if(salesWrap.aprHandover == null) salesWrap.aprHandover = recCnt; else salesWrap.aprHandover += recCnt;
                if(mnth == 2) if(salesWrap.mayHandover == null) salesWrap.mayHandover = recCnt; else salesWrap.mayHandover += recCnt;
                if(mnth == 3) if(salesWrap.junHandover == null) salesWrap.junHandover = recCnt; else salesWrap.junHandover += recCnt;
                if(mnth == 4) if(salesWrap.julHandover == null) salesWrap.julHandover = recCnt; else salesWrap.julHandover += recCnt;
                if(mnth == 5) if(salesWrap.augHandover == null) salesWrap.augHandover = recCnt; else salesWrap.augHandover += recCnt;
                if(mnth == 6) if(salesWrap.sepHandover == null) salesWrap.sepHandover = recCnt; else salesWrap.sepHandover += recCnt;
                if(mnth == 7) if(salesWrap.octHandover == null) salesWrap.octHandover = recCnt; else salesWrap.octHandover += recCnt;
                if(mnth == 8) if(salesWrap.novHandover == null) salesWrap.novHandover = recCnt; else salesWrap.novHandover += recCnt;
                if(mnth == 9) if(salesWrap.decHandover == null) salesWrap.decHandover = recCnt; else salesWrap.decHandover += recCnt;
                if(mnth == 10) if(salesWrap.janHandover == null) salesWrap.janHandover = recCnt; else salesWrap.janHandover += recCnt;
                if(mnth == 11) if(salesWrap.febHandover == null) salesWrap.febHandover = recCnt; else salesWrap.febHandover += recCnt;
                if(mnth == 12) if(salesWrap.marHandover == null) salesWrap.marHandover = recCnt; else salesWrap.marHandover += recCnt;
            }
            return salesWrap;
        }
    
}
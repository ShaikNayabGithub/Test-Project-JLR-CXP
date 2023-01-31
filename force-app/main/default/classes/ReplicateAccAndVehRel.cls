/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		21/05/2021			CXPD-1214: Added additional request and response fields if length of string is greater than field length
* 
*/
global with sharing class ReplicateAccAndVehRel{
    
    global class replicatevehicleandvehicleownershipout {}
    
    webservice static replicateVehicleAndVehicleOwnershipResponse upsertVehicleAndVehicleOwnership(AccountVehicle replicateVehicleAndVehicleOwnership)
    {
        replicateVehicleAndVehicleOwnershipResponse response = new replicateVehicleAndVehicleOwnershipResponse();
        Integration_Log__c log=new Integration_Log__c();
        ReplicateAccAndVehRelProcessor processor = new ReplicateAccAndVehRelProcessor();
        try
        {
            response.ResponseMessage=processor.process(replicateVehicleAndVehicleOwnership);
            if(  response.ResponseMessage == '' ||  response.ResponseMessage == 'Success') {
                log.status__c='Success';  
            } else {
                log.Status__c = 'Error';
            }
            
            return response;
            
        }
        
        catch(Exception e)
        {
            system.debug('ex --> '+e.getMessage());
            system.debug('ex1 --> '+e.getStackTraceString());
            system.debug('ex2 --> '+e.getLineNumber());
            String erroMessage = e.getMessage()+' - '+e.getStackTraceString()+' - '+e.getLineNumber();
            response.ResponseMessage= erroMessage; //String.valueOf(e);
            response.isSuccess=false;
            
            log.status__c='Error';
            //ReplicateAccAndVehRelProcessor.SendErrorEmail(response.ResponseMessage,e);
            return  response;
        }
        Finally{
            if(String.isNotBlank(response.ResponseMessage)){//1.0 - Added additional field - Response_Additional__c
                log.Response__c = response.ResponseMessage.length() < 131070 ? response.ResponseMessage : response.ResponseMessage.substring(0, 131070);
                log.Response_Additional__c = response.ResponseMessage.length() < 131070 ? '' : response.ResponseMessage.substring(131070);
            }
            if(String.isNotBlank(json.serializePretty(replicateVehicleAndVehicleOwnership))){//1.0 - Added additional field - Request_Additional__c
                log.Request__c = json.serializePretty(replicateVehicleAndVehicleOwnership).length() < 131070 ? json.serializePretty(replicateVehicleAndVehicleOwnership) : json.serializePretty(replicateVehicleAndVehicleOwnership).substring(0, 131070);
                log.Request_Additional__c = json.serializePretty(replicateVehicleAndVehicleOwnership).length() < 131070 ? '' : json.serializePretty(replicateVehicleAndVehicleOwnership).substring(131070);
            }
            log.service__c='MENA Integration';
            if(replicateVehicleAndVehicleOwnership !=null 
               && replicateVehicleAndVehicleOwnership.Vhcl !=null)
            {
                log.VIN__c = replicateVehicleAndVehicleOwnership.Vhcl.VIN;
                if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns !=null
                   && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn !=null
                   && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0] !=null)
                {
                    log.Account_Country__c 	= replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].CntryCd;
                    log.Start_Date__c		= string.isEmpty(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].StartDt) ? null : date.valueOf(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].StartDt);
                    if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct!=null){
                        log.Customer_ID__c			= replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.AcctId;
                        log.First_Name__c			= replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.FstNm;
                        log.Last_Name__c			= replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.LstNm;
                        log.Preferred_Language__c	= processor.getPreferredLanguage(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.prefLang);
                        if(replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails!=null
                           && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email !=null
                           && replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email[0] !=null)
                            log.Account_Email__c    = replicateVehicleAndVehicleOwnership.Vhcl.VhclAcctRltns.VhclAcctRltn[0].Acct.Emails.Email[0].EmailAddr;
                    }
                }
            }
            If(replicateVehicleAndVehicleOwnership != null && replicateVehicleAndVehicleOwnership.Vhcl != null && replicateVehicleAndVehicleOwnership.Vhcl.VhclTrdPrtnrs != null && replicateVehicleAndVehicleOwnership.Vhcl.VhclTrdPrtnrs.VhclTrdPrtnr != null && replicateVehicleAndVehicleOwnership.Vhcl.VhclTrdPrtnrs.VhclTrdPrtnr[0]!=null && replicateVehicleAndVehicleOwnership.Vhcl.VhclTrdPrtnrs.VhclTrdPrtnr[0].TrdPrtnr != null && replicateVehicleAndVehicleOwnership.Vhcl.VhclTrdPrtnrs.VhclTrdPrtnr[0].TrdPrtnr.TrdPrtnrCd != null ){
                log.Retailer_Code__c	= replicateVehicleAndVehicleOwnership.Vhcl.VhclTrdPrtnrs.VhclTrdPrtnr[0].TrdPrtnr.TrdPrtnrCd;
                
            }
            
            //log.headers__c = String.valueOf(replicateVehicleAndVehicleOwnership.Envelope.Header);
            //log.Http_Method__c = RestContext.request.httpMethod;
            //log.requestURI__c = RestContext.request.requestURI;
            //log.Resource_Path__c = RestContext.request.resourcePath;
            //log.ip_address__c = RestContext.request.remoteAddress;    
            insert log;
        }
        
    }
    
    global class replicateVehicleAndVehicleOwnershipResponse{
        webservice boolean IsSuccess;
        webservice string ErrorCode;
        webservice string ResponseMessage;
        
        
        public replicateVehicleAndVehicleOwnershipResponse()
        {
            this.IsSuccess = true;
        }
        
    }
    
    
    global class Envelope {
        webservice Body Body;
    }
    global class Body {
        webservice AccountVehicle replicateVehicleAndVehicleOwnership;
        
    }
    global class AccountVehicle {
        webservice CRMHeader CRMHeader;
        webservice JLRTxnAudit JLRTxnAudit;
        webservice Vhcl Vhcl;
        webservice String mssext; //OK:Found Required
        
    }
    global class CRMHeader {
        webservice String DealerCode;   //test
        webservice String Brand;    //test
        webservice String BusinessProcessReference; //null
        webservice String MaxSearchResults; //test
        webservice String NoOfSearchResults;    //test
        webservice String InfoMessage;  //test
        webservice String ServiceProvider;  //test
        webservice String ServiceType;  //test
        webservice String ManualFlag;   //test
        webservice String NSCRef;   //test
        webservice String NS1;  //OK:Found Required
    }
    global class JLRTxnAudit {
        webservice String TxnType;  //test
        webservice String TxnDateTime;  //test
        webservice String TxnUserId;    //test
        webservice String NS4; //OK:Found Required
    }
    global class Vhcl {
        webservice String VhclId;   //test
        webservice String VIN;  //test
        webservice String Brand;    //test
        webservice String ChassisNo;    //test
        webservice String CurrVhclMlg;  //test
        webservice String MdlNm;    //test
        webservice String MlgUOM;   //test
        webservice String DescGrpId;    //test
        webservice String MdlYear;  //test
        webservice String EngNo;    //test
        webservice String OrdNo;    //test
        webservice String ExDemoInd;    //test
        webservice String OwnshipSts;   //test
        webservice String ReacqFlg; //test
        webservice String RegNo;    //test
        webservice String RegType;  //test
        webservice String ShortVIN; //test
        webservice String SpecMkt;  //test
        webservice String VhclSoldCntry;    //test
        webservice String MdlDrvtv; //test
        webservice String FuelTyp;  //test
        webservice String Trnsmssn; //test
        webservice String ExtVhclClr;   //test
        webservice String FleetMngmtCd; //test
        webservice String EngType;  //test
        webservice String EngCpcty; //test
        webservice String EngPwr;   //test
        webservice String BdyStyle; //test
        webservice String WhlsDrvn; //test
        webservice String AltVIN;   //test
        webservice String HndOfDrv; //test
        webservice String Fctry;    //test
        webservice String MdlPgmCd; //test
        webservice String SVOClass; //test
        webservice VhclAcctRltns VhclAcctRltns;
        webservice Ftrs Ftrs;
        webservice VhclTrdPrtnrs VhclTrdPrtnrs;
        webservice VhclDts VhclDts;
        webservice VhclSrlNos VhclSrlNos;
        webservice VhclAcqstns VhclAcqstns;
        webservice SalesCntrcts SalesCntrcts;
        webservice String OldVsn;  //test
        webservice String NewVsn;  //test
        webservice String LstUpdBySys; //test
    }
    global class VhclAcctRltns {
        webservice List<VhclAcctRltn> VhclAcctRltn;
        
    }
    global class VhclAcctRltn {
        webservice String RltnType; //test
        webservice String AccntId;  //test
        webservice String VhclId;   //test
        webservice String CntryCd;  //test
        webservice String StartDt;  //test
        webservice String EndDt;    //test
        webservice String PrDlrCd;  //test
        webservice String SecDlrCd; //test
        webservice Acct Acct;
    }
    global class Acct {
        webservice String AcctId;   //test
        webservice String AcctType; //test
        webservice String Ttl;  //test
        webservice String AcdmcTtl; //test
        webservice String NonAcdmcTtl;  //test
        webservice String Initials; //test
        webservice String FstNm;    //test
        webservice String MidNm;    //test
        webservice String LstNm;    //test
        webservice String AddLstNm; //test
        webservice String NmPrfx;   //test
        webservice String KnownAs;  //test
        webservice String SrchTerm; //test
        webservice String NmValSts; //test
        webservice String NmDataQlty;   //test
        webservice String Gender;   //test
        webservice String DOB;  //test
        webservice String DtOfDth;  //test
        webservice String MrtlSts;  //test
        webservice String Gnrtn;    //test
        webservice String PrefLang; //test
        webservice String JobTtl;   //test
        webservice String JobTtlOthr;   //test
        webservice String EmplyrNm; //test
        webservice String OrgNm1;   //test
        webservice String OrgNm2;   //test
        webservice String OrgType;  //test
        webservice String TrdngNm;  //test
        webservice String LegFrm;   //test
        webservice String PrefConMthd;  //test
        webservice String PrefConTime;  //test
        webservice String AcctOrgn; //test
        webservice String Source;   //test
        webservice String VIPFlg;   //test
        webservice String CorresLang;   //test
        webservice String DeclToGiveEmail;  //test
        webservice String DtDeclToGiveEmail;    //test
        webservice String CreatingDlrPrDlrCd;   //test
        webservice String CreatingDlrSecDlrCd;  //test
        webservice String Cntry;    //test
        webservice String ArchvFlg; //test
        webservice AcctRels AcctRels;
        webservice FltMngmnt FltMngmnt;
        webservice Nts Nts;
        webservice OrgCons OrgCons;
        webservice BrndRels BrndRels;
        webservice DlrRels DlrRels;
        webservice MktgAttrbs MktgAttrbs;
        webservice AcctDts AcctDts;
        webservice AcctAddrs AcctAddrs;
        webservice Prmssns Prmssns;
        webservice LyltyStss LyltyStss;
        webservice Tels Tels;
        webservice Emails Emails;
        webservice SrvyFlags SrvyFlags;
        webservice ExtAcctIds ExtAcctIds;
        webservice AcctRls AcctRls;
        webservice Websites Websites;
        webservice String OldVsn;  //test
        webservice String NewVsn;  //test
        webservice String LstUpdBySys; //test
    }
    global class AcctRels {
        webservice List<AcctRel> AcctRel;
    }
    global class AcctRel {
        webservice String ParentAcctId; //test
        webservice String ChildAcctId;  //test
        webservice String RelType;  //test
        webservice String Inflnce;  //test
        webservice String ActnCd;  //test
    }
    global class FltMngmnt {
        webservice String CCDWaiver;    //test
        webservice String RlvntFltMngmnt;   //test
        webservice FltAllwnces FltAllwnces;
        webservice PurchMthds PurchMthds;
        webservice FltVhclCnts FltVhclCnts;
    }
    global class FltAllwnces {
        webservice List<FltAllwnce> FltAllwnce;
    }
    global class FltAllwnce {
        webservice String Banding;  //test
        webservice String Grde; //test
        webservice String FndngMthd;    //test
        webservice String QtyOnFlt; //test
        webservice String MnthlyAllwnceHghrVal; //test
        webservice String Opprtnty; //test
        webservice String MnthlyAllwnceLwrVal;  //test
        webservice String TaxValLmt;    //test
        webservice String AllwnceCurrencyCd;    //test
        webservice String AllowEmplContr;   //test
        webservice String ChngCycleMlg; //test
        webservice String MlgUOM;   //test
        webservice String ChngCycleMnths;   //test
        webservice String CO2Cap;   //test
        webservice String RstrctdBdgPol;    //test
        webservice String Sgmnts;   //test
        webservice String VolPssngrVhcl;    //test
        webservice String VolCommVhcl;  //test
        webservice String Comment;  //test
        webservice FltAllwnceExcls FltAllwnceExcls;
    }
    global class FltAllwnceExcls {
        webservice List<FltAllwnceExcl> FltAllwnceExcl;
    }
    global class FltAllwnceExcl {
        webservice String Excl; //test
        webservice String ExclNt;   //test
    }
    global class PurchMthds {
        webservice List<PurchMthd> PurchMthd;
    }
    global class PurchMthd {
        webservice String PurchMthd;    //test
    }
    global class FltVhclCnts {
        webservice List<FltVhclCnt> FltVhclCnt;
    }
    global class FltVhclCnt {
        webservice String CntType;  //test
        webservice String Cnt;  //test
    }
    global class Nts {
        webservice List<Nt> Nt;
    }
    global class Nt {
        webservice String NtType;   //test
        webservice String Nt;   //test
    }
    global class OrgCons {
        webservice List<OrgCon> OrgCon;
    }
    global class OrgCon {
        webservice String RelType;  //test
        webservice String Func; //test
        webservice String FuncOthr; //test
        webservice String Dept; //test
        webservice String DeptOthr; //test
        webservice String RelAcctId;    //test
        webservice String ActnCd ;  //test
    }
    global class BrndRels {
        webservice List<BrndRel> BrndRel;
    }
    global class BrndRel {
        webservice String Brand;    //test
        webservice String BrandRel; //test
    }
    global class DlrRels {
        webservice List<DlrRel> DlrRel;
    }
    global class DlrRel {
        webservice String RelType;  //test
        webservice String PrDlrCd;  //test
        webservice String SecDlrCd; //test
        webservice String Brnd; //test
        webservice TrdPrtnr TrdPrtnr;
        webservice String ActnCd ;  //test
    }
    global class TrdPrtnr {
        webservice String TrdPrtnrType; //test
        webservice String TrdPrtnrId;   //test
        webservice String TrdPrtnrCd;   //test
        webservice String OrgNm1;   //test
        webservice String OrgNm1LocalLang;  //test
        webservice String OrgNm2;   //test
        webservice String OrgNm3;   //test
        webservice String MktCd;    //test
        webservice String Cntry;    //test
        webservice ExtTrdPrtnrIds ExtTrdPrtnrIds;
    }
    global class ExtTrdPrtnrIds {
        webservice List<ExtTrdPrtnrId> ExtTrdPrtnrId;
    }
    global class ExtTrdPrtnrId {
        webservice String IdType;   //test
        webservice String IdValue;  //test
    }
    global class MktgAttrbs {
        webservice List<MktgAttrb> MktgAttrb;
    }
    global class MktgAttrb {
        webservice String Set1;  //test
        webservice String Type; //test
        webservice String Value;    //test
        webservice String ActnCd ;  //test
    }
    global class AcctDts {
        webservice List<AcctDt> AcctDt;
    }
    global class AcctDt {
        webservice String Type; //test
        webservice String Dt;   //test
    }
    global class AcctAddrs {
        webservice List<AcctAddr> AcctAddr;
    }
    global class AcctAddr {
        webservice String StartDt;  //test
        webservice String EndDt;    //test
        webservice String AddrType; //test
        webservice String PrFlg;    //test
        webservice String DataQlty; //test
        webservice Addr Addr;
    }
    global class Addr {
        webservice String POBox;    //test
        webservice String PremNum;  //test
        webservice String Prfx1;    //test
        webservice String Prfx2;    //test
        webservice String Street;   //test
        webservice String Suppl1;   //test
        webservice String Suppl2;   //test
        webservice String Suppl3;   //test
        webservice String CityTown; //test
        webservice String RegState; //test
        webservice String PostCdZIP;    //test
        webservice String Cntry;    //test
        webservice String ValSts;   //test
    }
    global class Prmssns {
        webservice List<Prmssn> Prmssn;
    }
    global class Prmssn {
        webservice String PrmssnSupprType;  //test
        webservice String DtOfCnsnt;    //test
        webservice String Cnsnt;    //test
        webservice String FrmOfCnsnt;   //test
        webservice String SupprRsn; //test
    }
    global class LyltyStss {
        webservice List<LyltySts> LyltySts;
    }
    global class LyltySts {
        webservice String Brand;    //test
        webservice String Sts;  //test
    }
    global class Tels {
        webservice List<Tel> Tel;
    }
    global class Tel {
        webservice String PhNum;    //test
        webservice String PhExtn;   //test
        webservice String PhNumType;    //test
        webservice String Cntry;    //test
        webservice String ValSts;   //test
        webservice String DataQlty; //test
        webservice String DoNotUseFlg;  //test
        webservice String PrFlg;    //test
        webservice String ActnCd ;  //test
    }
    global class Emails {
        webservice List<Email> Email;
    }
    global class Email {
        webservice String EmailAddr;    //test
        webservice String ValSts;   //test
        webservice String DataQlty; //test
        webservice String DoNotUseFlg;  //test
        webservice String SftBnceCntr;  //test
        webservice String HrdBnceCntr;  //test
        webservice String PrFlg;    //test
        webservice String ActnCd ;  //test
    }
    global class SrvyFlags {
        webservice List<SrvyFlag> SrvyFlag;
    }
    global class SrvyFlag {
        webservice String Brand;    //test
        webservice String FlgType;  //test
        webservice String FlgSts;   //test
    }
    global class ExtAcctIds {
        webservice List<ExtAcctId> ExtAcctId;
    }
    global class ExtAcctId {
        webservice String IdType;   //test
        webservice String IdVal;    //test
        webservice String RespInst; //test
        webservice String ActnCd ;  //test
    }
    global class AcctRls {
        webservice List<AcctRl> AcctRl;
    }
    global class AcctRl {
        webservice String Role; //test
        webservice String ActnCd ;  //test
    }
    global class Websites {
        webservice List<Website> Website;
    }
    global class Website {
        webservice String WebAddr;  //test
        webservice String DoNotUseFlg;  //test
        webservice String ActnCd ;  //test
    }
    global class Ftrs {
        webservice List<Ftr> Ftr;
    }
    global class Ftr {
        webservice String FtrType;  //test
        webservice String FtrCd;    //test
        webservice String FtrGrp;   //test
        webservice String OptInd;   //test
        webservice String DispGrp;  //test
        webservice FtrDescs FtrDescs;
    }
    global class FtrDescs {
        webservice List<FtrDesc> FtrDesc;
    }
    global class FtrDesc {
        webservice String Desc1; //test
        webservice String LangCd;   //test
    }
    global class VhclTrdPrtnrs {
        webservice List<VhclTrdPrtnr> VhclTrdPrtnr;
    }
    global class VhclTrdPrtnr {
        webservice String RltnType; //test
        webservice String VhclId;   //test
        webservice String TrdPrtnrId;   //test
        webservice TrdPrtnr TrdPrtnr;
    }
    global class VhclDts {
        webservice List<VhclDt> VhclDt;
    }
    global class VhclDt {
        webservice String DateType; //test
        webservice String Date1; //test
    }
    global class VhclSrlNos {
        webservice List<VhclSrlNo> VhclSrlNo;
    }
    global class VhclSrlNo {
        webservice String Type; //test
        webservice String SerialNumber; //test
    }
    global class VhclAcqstns {
        webservice List<VhclAcqstn> VhclAcqstn;
    }
    global class VhclAcqstn {
        webservice String AcqstnType;   //test
        webservice String CertSts;  //test
        webservice String CertTxnDt;    //test
        webservice String AcqstnDt; //test
        webservice String OdmRding; //test
        webservice String MlgUOM;   //test
        webservice String InspPssdFlg;  //test
        webservice String CertFailRsn;  //test
        webservice String Nt;   //test
        webservice String AcqDlrCd; //test
        webservice String CertDt;   //test
        webservice String Cert; //test
    }
    global class SalesCntrcts {
        webservice List<SalesCntrct> SalesCntrct;
    }
    global class SalesCntrct {
        webservice String CntrctId; //test
        webservice String LcnsngDstrct; //test
        webservice String PrmtNmbr; //test
        webservice String AcqFrom;  //test
        webservice String BrandOrdType; //test
        webservice String BrandStsPt;   //test
        webservice String CancDate; //test
        webservice String CancInd;  //test
        webservice String CancTS;   //test
        webservice String CancVsnNo;    //test
        webservice String CommonOrdNo;  //test
        webservice String CommonOrdType;    //test
        webservice String CommonSaleTypeCd; //test
        webservice String ConsignInd;   //test
        webservice String CntrctCrtDt;  //test
        webservice String CntrctCrtTm;  //test
        webservice String CntrctNo; //test
        webservice String CntrctVsnDt;  //test
        webservice String CntrctVsnNo;  //test
        webservice String CntrctVsnTS;  //test
        webservice String CurrCntrctVsn;    //test
        webservice String DlrRefNo; //test
        webservice String ExDemoInd;    //test
        webservice String FctryOrdNo;   //test
        webservice String FinPlanType;  //test
        webservice String FinCo;    //test
        webservice String FinCoOth; //test
        webservice String MthlyRepymntAmt;  //test
        webservice String ResidVal; //test
        webservice String FinCntrctEndDt;   //test
        webservice String PymntType;    //test
        webservice String LeasingFinDrtn;   //test
        webservice String LdId; //test
        webservice String MrktingPgm;   //test
        webservice String MetaOrdNo;    //test
        webservice String NSCOrdNo; //test
        webservice String PartExMfctrr; //test
        webservice String PartExMdl;    //test
        webservice String PrevVhclMfctrr;   //test
        webservice String PrevVhclMdl;  //test
        webservice String PurchMthd;    //test
        webservice String SalesmanCdId; //test
        webservice String NewUsedVhclInd;   //test
        webservice String RtlLeaseInd;  //test
        webservice String SaleCtgy; //test
        webservice String SalePrice;    //test
        webservice String CurrCd;   //test
        webservice String ExtWrrntyPln; //test
        webservice String TransPrty;    //test
        webservice String CorpSvcNo;    //test
        webservice String CorpSvcCoNm;  //test
        webservice String BuyerType;    //test
        webservice String PredMlg;  //test
        webservice String PredMlgPrd;   //test
        webservice String MlgUOM;   //test
        webservice String PredReplDt;   //test
        webservice String PredReplMlg;  //test
        webservice String PrVhclUse;    //test
        webservice String PredUsg;  //test
        webservice String PrVhclUSeDesc;    //test
        webservice String CntrctType;   //test
        webservice SalesCntrctTrdPrtnrs SalesCntrctTrdPrtnrs;
    }
    global class SalesCntrctTrdPrtnrs {
        webservice List<TrdPrtnr> TrdPrtnr;
    }
    
    
}
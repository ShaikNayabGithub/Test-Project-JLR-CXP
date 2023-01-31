@IsTest
private class EVHCTest{

    @isTest static void testProcessOfJson() {
    
     String json='{"BatchRequestHeader":{"JLRSecurityHeader":{"SecurityType":"UsernameTokenProfile","UsernameTokenProfile":{"Username":"SC132BTCXQ","Password":"fO19mXCC"}},"JLRCommonHeader":'
    +' {"ContextId":"87a23a7440cd","EndpointReference":null,"Timestamp":"","Logging":false,"NullMessage":null,"LanguageCode":"EN","ConsumerRef":"BTC","NSCRef":null},"JLRCommonBatchHeader":{"TotalNoOfMsgs":45}}'
    +',"BatchRequestBody":{"BatchMessages":{"CreateOrUpdateServiceOrRepairEventForVehicle":[{"CRMHeader":{"BusinessProcessReference":"ASM","NSCRef":"M0134","DealerCode":"LRIN70206"},"SerOrRep":'
    +'{"RprOrdrTyp":"00011","RprOrdrRef":"3648","UnqSrcSystmID":"1008396956","RprOrdrCrtnDt":null,"RprOrdrOpnDt":null,"RprOrdrClsdDt":null,"VhclCllctnDt":null,"SrvcCmpltd":null,"MlgIn":36825'
    +',"MlgOut":null,"PymntMthd":null,"AppntmntFlg":null,"ExtnddWrrntyPrvdr":null,"SrvcTchncnCmmnts":null,"CstmrCmmnts":null,"TtlActlLbrHrs":null,"TtlBlldLbrHrs":null,"Dprtmnt":null'
    +',"Stts":"Open","RprDscrptn":null,"MlgUOM":"Kilometres","InspctnDt":"2019-01-05","NxtSvc":null,"RprItms":{"RprItm":[{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00012","'
    +'Lvl2Ctgry":"00022","OprtnActn":null,"TchncnCmmnts":"test comment","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":'
    +'"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":20500.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":2700.00,"CrrncyCd":"IN"}'
    +',{"Itm":"00004","Prc":23200.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":'
    +'null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE",'
    +'"AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00002","Lvl2Ctgry":"00004","OprtnActn":null,"TchncnCmmnts":'
    +'"kk.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":'
    +'null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00023","Lvl2Ctgry":"00046","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,'
    +'"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,'
    +'"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00014","Lvl2Ctgry":"00101","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":'
    +'null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,'
    +'"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00017","Lvl2Ctgry":"00084","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":'
    +'null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},'
    +'{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00029","Lvl2Ctgry":"00086","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd"'
    +':null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,'
    +'"Lvl1Ctgry":"00002","Lvl2Ctgry":"00073","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,'
    +'"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,'
    +'"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00027","Lvl2Ctgry":"00109","OprtnActn":null,"TchncnCmmnts":"  Tyre Condition","CstmrCmmnts":null,"PymntTyp":'
    +'null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,'
    +'"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00027","Lvl2Ctgry":"00109","OprtnActn":null,"TchncnCmmnts":"depth low.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null'
    +',"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":31500.00,"CrrncyCd":"IN"},{"Itm"'
    +':"00001","Prc":1080.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":32580.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":'
    +'{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,'
    +'"LstNm":"GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00012","Lvl2Ctgry":"00025","OprtnActn":null,'
    +'"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":'
    +'"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00003","Lvl2Ctgry":"00075","OprtnActn":null,"TchncnCmmnts":'
    +'"thickness low.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Deferred",'
    +'"RprItmPrcs":{"RprItmPrc":[{"Itm":"00001","Prc":1620.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":1620.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":'
    +'[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician",'
    +'"Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"'
    +'00022","Lvl2Ctgry":"00106","OprtnActn":null,"TchncnCmmnts":"REAR SUSPENSION BOOT TORN.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":'
    +'"Amber","InspctnRcmmndedDueDt":"2019-04-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply"'
    +':{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,'
    +'"LstNm":"GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00010","Lvl2Ctgry":"00017","OprtnActn":null,'
    +'"TchncnCmmnts":"test 800A(EN) ).","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm"'
    +':"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":22200.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":1620.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":23820.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,'
    +'"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581",'
    +'"LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},'
    +'{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00003","Lvl2Ctgry":"00075","OprtnActn":null,"TchncnCmmnts":"2.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"'
    +'CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":27000.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":1620.00,'
    +'"CrrncyCd":"IN"},{"Itm":"00004","Prc":28620.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin",'
    +'"MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","'
    +'AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00003","Lvl2Ctgry":"00075","OprtnActn":null,"TchncnCmmnts":"ok."'
    +',"CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"'
    +'RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00003","Lvl2Ctgry":"00076","OprtnActn":null,"TchncnCmmnts":"kk.","CstmrCmmnts":null,'
    +'"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,'
    +'"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00003","Lvl2Ctgry":"00076","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs"'
    +':null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"'
    +'TrdngPrtnrEmplys":null}'
    +',{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00031","Lvl2Ctgry":"00079","OprtnActn":null,"TchncnCmmnts":"test 2.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt"'
    +':null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":7600.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc"'
    +':540.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":8140.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"'
    +'Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"'
    +'GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00010","Lvl2Ctgry":"00019","OprtnActn":null,"Tchnc'
    +'nCmmnts":"PLATE BULB 01","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Def'
    +'erred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":12550.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":540.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":13090.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprI'
    +'tm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","Lb'
    +'rRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"Crrn'
    +'cyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00006","Lvl2Ctgry":"00097","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"Blld'
    +'Hrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPr'
    +'tnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00022","Lvl2Ctgry":"00106","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"Bll'
    +'dHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"Trdng'
    +'PrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00032","Lvl2Ctgry":"00082","OprtnActn":null,"TchncnCmmnts":"FRONT ONT BUMMER HD.","CstmrCmmnts":null,"PymntTyp":null,"Lbr'
    +'Hrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Sold","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":900'
    +'0.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":4320.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":13320.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnr'
    +'Emply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Tech'
    +'nician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl'
    +'1Ctgry":"00032","Lvl2Ctgry":"00104","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":'
    +'"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ct'
    +'gry":"00032","Lvl2Ctgry":"00102","OprtnActn":null,"TchncnCmmnts":"fog lamp switch sticky   steering wheel switch sticky.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBll'
    +'ngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","InspctnOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00001","Prc":1350.00,"CrrncyCd":"IN"},{"Itm":"00'
    +'004","Prc":1350.00000,"CrrncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm'
    +'":"Patil","AddtnlLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlL'
    +'stNm":null,"FllNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00027","Lvl2Ctgry":"00109","OprtnActn":null,"Tchncn'
    +'Cmmnts":"depth LOW.  ","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","Inspct'
    +'nOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":31500.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":1080.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":32580.00000,"Crr'
    +'ncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","Addtn'
    +'lLstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"Fll'
    +'Nm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00003","Lvl2Ctgry":"00076","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrC'
    +'mmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprIt'
    +'mPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":null},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00027","Lvl2Ctgry":"00109","OprtnActn":null,"TchncnCm'
    +'mnts":"depth LOW.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"InspctnStts":"Red","InspctnRcmmndedDueDt":"2019-02-05","Inspctn'
    +'Outcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":31500.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":1080.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":32580.00000,"Crr'
    +'ncyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","Addtnl'
    +'LstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"FllN'
    +'m":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}},{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00022","Lvl2Ctgry":"00040","OprtnActn":null,"TchncnCmmnts":"SHOCK UP MOUN'
    +'TING WEAK   SHOCKUP INSULATOR  02  MOUNTING 02  NUT 08  NUT 02  LINK NUT 02.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrBllngRt":null,"CrrncyCd":null,"Inspctn'
    +'Stts":"Red","InspctnRcmmndedDueDt":"2019-02-05"'
    +',"InspctnOutcm":"Deferred","RprItmPrcs":{"RprItmPrc":[{"Itm":"00003","Prc":42360.00,"CrrncyCd":"IN"},{"Itm":"00001","Prc":3240.00,"CrrncyCd":"IN"},{"Itm":"00004","Prc":45600.00000,"Crrn'
    +'cyCd":"IN"}]},"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrEmplys":{"TrdngPrtnrEmply":[{"JbTtl":"Service Advisor","Emply":{"FrstNm":"Ashwin","MddlNm":null,"LstNm":"Patil","Addtnl'
    +'LstNm":null,"FllNm":null,"ExtrnlEmplyId":"86581","LbrRt":null,"CrrncyCd":null}},{"JbTtl":"Technician","Emply":{"FrstNm":"UMAKANT","MddlNm":null,"LstNm":"GOLE","AddtnlLstNm":null,"Fl'
    +'lNm":null,"ExtrnlEmplyId":"116016","LbrRt":null,"CrrncyCd":null}}]}}'
    +',{"OprtnCd":null,"OprtnDscrptn":null,"Lvl1Ctgry":"00020","Lvl2Ctgry":"00039","OprtnActn":null,"TchncnCmmnts":"ok.","CstmrCmmnts":null,"PymntTyp":null,"LbrHrs":null,"BlldHrs":null,"LbrB'
    +'llngRt":null,"CrrncyCd":null,"InspctnStts":"Green","InspctnRcmmndedDueDt":"2019-01-29","InspctnOutcm":"Deferred","RprItmPrcs":null,"RprItmCsts":null,"RprItm_Prts":null,"TrdngPrtnrE'
    +'mplys":null}]},"Vehicle":{"Brand":null,"MdlNm":null,"RegNum":"MH04GL300","CrrntVhMilg":null,"MlgUOM":null,"VIN":"SAJAC05V1EVT01792"},"RprOrdrCsts":null,"RprOrdrPrcs":null,"Acct":{"Acct'
    +'Num":"0","AcctType":"Individual","FstNm":"Urvish","MidNm":null,"Ttl":"Ms","LstNm":"Rameshchandra Vora","AcdmcTtl":null,"DOB":null,"EmplyrNm":null,"PrefLang":null,"PrefConMthd":null,"PrefC'
    +'onTm":null,"AcctOrgn":"Dealer","Gender":null,"OrgNm1":null,"OrgNm2":null,"Cntry":"India","Gnrtn":null,"Prmssns":null,"Emails":{"Email":{"EmailAddr":"testurvora@rediffmail.com","DoNotUs'
    +'eFlg":true,"ActnCd":"Z0"}},"AcctAddrs":{"AcctAddr":{"AddrType":"Home 1","Addr":{"POBox":null,"PremNum":null,"Prfx1":null,"Prfx2":null,"Street":"HJ","Suppl1":null,"Suppl2":null,"Sup'
    +'pl3":null,"CityTown":null,"RegState":null,"PostCdZIP":"5454","Cntry":null}}},"Tels":{"Tel":[{"PhNum":"1122334455","PhNumType":null,"DoNotUseFlg":"true","ActnCd":"Z0"},{"PhNum":"98202'
    +'84100","PhNumType":null,"DoNotUseFlg":"false","ActnCd":"Z0"}]},"AcctRls":{"AcctRl":{"Role":"Account","ActnCd":"Z0"}}},"TrdngPrtnr":{"TrdngPrtnrTyp":"Dealer","OrgnstnNm1":"Pvt Ltd","Orgns'
    +'tnNm2":null,"Cntry":null,"TrdngPrtnrCd":"JIN70206"}}}]}}}';
   
    Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

    List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
    lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
    lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
    insert lbList;

    List<DataUsePurpose> dupList = new List<DataUsePurpose>();
    dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;IN'));
    dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;IN'));
    dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;IN'));
    dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;IN'));
    insert dupList;    

    Account account= new account();
    account.name='test retailer';
    account.phone='07543434';
    account.Primary_Dealer_Code__c ='LRIN70206';
    account.recordtypeid=SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id;
    account.Country_ISO_Code__c = 'IN';
    insert account;
    
    asset asset= new asset();
    asset.accountid=TestClass_AccountCreator.CreatePersonAccount().id;
    asset.vin__c='SAJAC05V1EVT01792';
    asset.name='SAJAC05V1EVT01792';
    asset.brand__c= TestClass_VehicleSpecificationBuilder.BuildMake().id; 
    
    insert asset;
    
    Test.startTest();
   
    RestRequest req = new RestRequest();   
    req.requestbody=Blob.valueOf(json);
    RestResponse res = new RestResponse();
    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/evhc/snapon/v1/'; 
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;    

    EVHC_Service.doPost();
    
    List<evhc__c> listEvhc=[select id from evhc__c where evhcid__c='1008396956'];
    evhc__c recordCreated;
    evhc_item__c evhcItemCreated;
    
    if(!listEVHC.isEmpty())
        recordCreated=listEvhc[0];
        
    System.assertNotEquals(recordCreated,null); 
    
    list<Evhc_item__c > listItems=[select id,evhcId__c from Evhc_item__c where evhcid__c='1008396956'];
    if(!listItems.isEmpty())
        evhcItemCreated=listItems[0];
    
    System.assertNotEquals(evhcItemCreated,null); 
    
    Test.stopTest();

       
    }
  
}
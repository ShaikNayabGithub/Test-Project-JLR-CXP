public  class VME_BatchClassWBSMappingTransformData {
    public  static  List<VME_WBS_Mapping__c> createBatchData() {

       Period quarterDetail = [SELECT Id, FiscalYearSettingsId, Type, StartDate, EndDate, SystemModstamp, IsForecastPeriod, QuarterLabel, PeriodLabel, Number, FullyQualifiedLabel FROM Period WHERE Type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
          List<VME_WBS_Mapping__c>  wbsList =new List<VME_WBS_Mapping__c>();
       if(quarterDetail!=null){
                VME_WBS_Mapping__c  wbs1 =new VME_WBS_Mapping__c();
                wbs1.VME_WBS_Code__c ='V-20-IN02-TASS-AGE-'+quarterDetail.Number+'-X-X7';
                wbs1.VME_Volume__c= '45';
                wbs1.VME_P_U_LLC__c='-550000';
                wbs1.VME_L3_Description__c='MY18 Jan - Sept Mfd Stock';
                wbs1.VME_Total_VME__c='24818946';
                wbs1.VME_ISO_Code__c='IN';
                wbs1.VME_Model__c='X760';
                wbs1.CurrencyCode__c='INR';
                wbsList.add(wbs1);

                VME_WBS_Mapping__c  wbs2 =new VME_WBS_Mapping__c();
                wbs2.VME_WBS_Code__c ='V-20-IN02-TASS-AGE'+quarterDetail.Number+'X-X7';
                wbs2.VME_Volume__c= '80';
                wbs2.VME_P_U_LLC__c='20000';
                wbs2.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs2.VME_Total_VME__c='15974929';
                wbs2.VME_ISO_Code__c='IN';
                wbs2.VME_Model__c='X760';
                wbs2.CurrencyCode__c='INR';
                wbsList.add(wbs2);
                           
                VME_WBS_Mapping__c  wbs3 =new VME_WBS_Mapping__c();
                wbs3.VME_WBS_Code__c ='V-20-IN02-TASS-AGE'+quarterDetail.Number+'X-X7';
                wbs3.VME_Volume__c= '31';
                wbs3.VME_P_U_LLC__c='-10000';
               // wbs3.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs3.VME_Total_VME__c='-3,10,000';
                wbs3.VME_ISO_Code__c='IN';
                wbs3.VME_Model__c='X760';
                wbs3.CurrencyCode__c='INR';
                wbsList.add(wbs3);
           
                VME_WBS_Mapping__c  wbs4 =new VME_WBS_Mapping__c();
                wbs4.VME_WBS_Code__c ='V-20-IN02-TINC-INV'+quarterDetail.Number+'X-X7';
                wbs4.VME_Volume__c= '125';
                wbs4.VME_P_U_LLC__c='-25,000';
                wbs4.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs4.VME_Total_VME__c='-31,25,000';
                wbs4.VME_ISO_Code__c='IN';
                wbs4.VME_Model__c='X760';
                wbs4.CurrencyCode__c='INR';
                wbsList.add(wbs4);
                  
           
                VME_WBS_Mapping__c  wbs5 =new VME_WBS_Mapping__c();
                wbs5.VME_WBS_Code__c ='V-20-IN02-DDIS-DSC'+quarterDetail.Number+'X-X7';
                wbs5.VME_Volume__c= '125';
                wbs5.VME_P_U_LLC__c='-45,000';
                wbs5.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs5.VME_Total_VME__c='-56,25,000';
                wbs5.VME_ISO_Code__c='IN';
                wbs5.VME_Model__c='X760';
                wbs5.CurrencyCode__c='INR';
                wbsList.add(wbs5);
           
                VME_WBS_Mapping__c  wbs6 =new VME_WBS_Mapping__c();
                wbs6.VME_WBS_Code__c ='Q-20-IN02-DDIS-DSC'+quarterDetail.Number+'X-X7';
                wbs6.VME_Volume__c= '23';
                wbs6.VME_P_U_LLC__c='-21,000';
                wbs6.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs6.VME_Total_VME__c='-4,83,000';
                wbs6.VME_ISO_Code__c='IN';
                wbs6.VME_Model__c='X760';
              //  wbs6.CurrencyCode__c='INR';
                wbsList.add(wbs6);
               
                VME_WBS_Mapping__c  wbs7 =new VME_WBS_Mapping__c();
                wbs7.VME_WBS_Code__c ='V-ab-IN02-TINC-AGE'+quarterDetail.Number+'X-X7';
                wbs7.VME_Volume__c= '90';
                wbs7.VME_P_U_LLC__c='-98,000';
                wbs7.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs7.VME_Total_VME__c='-88,20,000';
                wbs7.VME_ISO_Code__c='IN';
                wbs7.VME_Model__c='X760';
                wbs7.CurrencyCode__c='INR';
                wbsList.add(wbs7);
                  
                VME_WBS_Mapping__c  wbs8 =new VME_WBS_Mapping__c();
                wbs8.VME_WBS_Code__c ='V-20-IN01-TASS-AGE'+quarterDetail.Number+'X-X7';
                wbs8.VME_Volume__c= '40';
                wbs8.VME_P_U_LLC__c='-87,000';
                wbs8.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs8.VME_Total_VME__c='-34,80,000';
                wbs8.VME_ISO_Code__c='IN';
                wbs8.VME_Model__c='X760';
                wbs8.CurrencyCode__c='INR';
                wbsList.add(wbs8);

                VME_WBS_Mapping__c  wbs9 =new VME_WBS_Mapping__c();
                wbs9.VME_WBS_Code__c ='V-20-IN02-XASS-AGE'+quarterDetail.Number+'X-X7';
                wbs9.VME_Volume__c= '70';
                wbs9.VME_P_U_LLC__c='-64,000';
                wbs9.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs9.VME_Total_VME__c='-44,80,000';
                wbs9.VME_ISO_Code__c='IN';
                wbs9.VME_Model__c='X760';
                wbs9.CurrencyCode__c='INR';
                wbsList.add(wbs9);
           
                VME_WBS_Mapping__c  wbs10 =new VME_WBS_Mapping__c();
                wbs10.VME_WBS_Code__c ='V-20-IN02-TFCK-AGE'+quarterDetail.Number+'X-X7';
                wbs10.VME_Volume__c= '100';
                wbs10.VME_P_U_LLC__c='-89,000';
                wbs10.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs10.VME_Total_VME__c='-89,00,000';
                wbs10.VME_ISO_Code__c='IN';
                wbs10.VME_Model__c='X760';
                wbs10.CurrencyCode__c='INR';
                wbsList.add(wbs10);

                VME_WBS_Mapping__c  wbs11 =new VME_WBS_Mapping__c();
                wbs11.VME_WBS_Code__c ='V-20-IN02-TASS-KCF'+quarterDetail.Number+'X-X7';
                wbs11.VME_Volume__c= '101';
                wbs11.VME_P_U_LLC__c='-77,000';
                wbs11.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs11.VME_Total_VME__c='-77,77,000';
                wbs11.VME_ISO_Code__c='IN';
                wbs11.VME_Model__c='X760';
                wbs11.CurrencyCode__c='INR';
                wbsList.add(wbs11);

                VME_WBS_Mapping__c  wbs12 =new VME_WBS_Mapping__c();
                wbs12.VME_WBS_Code__c ='V-20-IN02-TINC-INV-6-X-X7';
                wbs12.VME_Volume__c= '67';
                wbs12.VME_P_U_LLC__c='-20,000';
                wbs12.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs12.VME_Total_VME__c='-13,40,000';
                wbs12.VME_ISO_Code__c='IN';
                wbs12.VME_Model__c='X760';
                wbs12.CurrencyCode__c='INR';
                wbsList.add(wbs12);
                
                VME_WBS_Mapping__c  wbs13 =new VME_WBS_Mapping__c();
                wbs13.VME_WBS_Code__c ='V-20-IN02-TASS-AGE-1-X-X7';
                wbs13.VME_Volume__c= '69';
                wbs13.VME_P_U_LLC__c='-21,000';
                wbs13.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs13.VME_Total_VME__c='-14,49,000';
                wbs13.VME_ISO_Code__c='IN';
                wbs13.VME_Model__c='X760';
                wbs13.CurrencyCode__c='INR';
                wbsList.add(wbs13);
               
               VME_WBS_Mapping__c  wbs14=new VME_WBS_Mapping__c();
                wbs14.VME_WBS_Code__c ='V-20-IN02-TASS-AGE'+quarterDetail.Number+'Y-X7';
                wbs14.VME_Volume__c= '11';
                wbs14.VME_P_U_LLC__c='-14,000';
                wbs14.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs14.VME_Total_VME__c='-1,54,000';
                wbs14.VME_ISO_Code__c='IN';
                wbs14.VME_Model__c='X760';
               // wbs14.CurrencyCode__c='INR';
                wbsList.add(wbs14);
              
               VME_WBS_Mapping__c  wbs15=new VME_WBS_Mapping__c();
                wbs15.VME_WBS_Code__c ='V-20-IN02-TASS-AGE'+quarterDetail.Number+'X-YY';
                wbs15.VME_Volume__c= '30';
                wbs15.VME_P_U_LLC__c='-70,000';
                wbs15.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs15.VME_Total_VME__c='-21,00,000';
                wbs15.VME_ISO_Code__c='IN';
                wbs15.VME_Model__c='X760';
               wbs15.CurrencyCode__c='INR';
                wbsList.add(wbs15);
           
             VME_WBS_Mapping__c  wbs16=new VME_WBS_Mapping__c();
                wbs16.VME_WBS_Code__c ='V-20-IN02-RRNF-CAS'+quarterDetail.Number+'X-X7';
                wbs16.VME_Volume__c= '22';
                wbs16.VME_P_U_LLC__c='abcdef';
                wbs16.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs16.VME_Total_VME__c='1,00,00,000';
                wbs16.VME_ISO_Code__c='IN';
                wbs16.VME_Model__c='X760';
               wbs16.CurrencyCode__c='INR';
                wbsList.add(wbs16);
           
             VME_WBS_Mapping__c  wbs17=new VME_WBS_Mapping__c();
                wbs17.VME_WBS_Code__c ='V-20-IN02-RRNF-CAS'+quarterDetail.Number+'X-X7';
                wbs17.VME_Volume__c= '0';
                wbs17.VME_P_U_LLC__c='-4,000';
                wbs17.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs17.VME_Total_VME__c='10,00,00,000';
                wbs17.VME_ISO_Code__c='IN';
                wbs17.VME_Model__c='X760';
               wbs17.CurrencyCode__c='INR';
                wbsList.add(wbs17);
           
             VME_WBS_Mapping__c  wbs18=new VME_WBS_Mapping__c();
                wbs18.VME_WBS_Code__c ='V-20-IN02-RRNF-CAS'+quarterDetail.Number+'X-X7';
                wbs18.VME_Volume__c= '11';
                wbs18.VME_P_U_LLC__c='-70,000';
                wbs18.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs18.VME_Total_VME__c='-8,80,000';
                wbs18.VME_ISO_Code__c='IN';
                wbs18.VME_Model__c='X760';
               wbs18.CurrencyCode__c='INR';
                wbsList.add(wbs18);
           
             VME_WBS_Mapping__c  wbs19=new VME_WBS_Mapping__c();
                wbs19.VME_WBS_Code__c ='V-20-IN02-RRNF-CAS'+quarterDetail.Number+'X-X7';
              //  wbs19.VME_Volume__c= '30';
                wbs19.VME_P_U_LLC__c='-31,000';
                wbs19.VME_L3_Description__c='MY18 Jan - Sept Mfd Stock';
                wbs19.VME_Total_VME__c='-6,20,000';
                wbs19.VME_ISO_Code__c='IN';
                wbs19.VME_Model__c='X760';
               wbs19.CurrencyCode__c='INR';
                wbsList.add(wbs19);
           
             VME_WBS_Mapping__c  wbs20=new VME_WBS_Mapping__c();
                wbs20.VME_WBS_Code__c ='V-20-IN02-RRNF-CAS'+quarterDetail.Number+'X-X7';
                wbs20.VME_Volume__c= '43';
                wbs20.VME_P_U_LLC__c='41000';
                wbs20.VME_L3_Description__c='MY18 Oct - Dec Mfd Stock';
                wbs20.VME_Total_VME__c='17,63,000';
                wbs20.VME_ISO_Code__c='XO';
                wbs20.VME_Model__c='X760';
               wbs20.CurrencyCode__c='INR';
                wbsList.add(wbs20);
           
       }
       return wbsList;
    }
}
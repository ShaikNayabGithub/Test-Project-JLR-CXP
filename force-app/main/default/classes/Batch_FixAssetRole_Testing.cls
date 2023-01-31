@IsTest (SeeAllData=true)
public class Batch_FixAssetRole_Testing {
    
    
    @IsTest(SeeAllData=true)
    static void Test_Logic() {
        List<Asset> allAusAssets;
        string vins = Label.testingVins;
        if(vins.contains(',')){
            List<string> vinsList = vins.split(',');
            allAusAssets = [Select id,name,accountid,account.name,Account.Primary_Account__c,Registration_Number__c, account.country_iso_code__c, (Select id,account__r.name, name,account__c,Account__r.Primary_Account__c, Driver__c, Handover_Date__c  from RDAs__r  order by Handover_Date__c desc ),  (Select  Id,Name, Account__r.name, Account__r.Primary_Account__c, Account__c, Role__c, Vehicle__c, Effective_From__c, Effective_To__c, LastModifiedDate, LastModifiedBy.name, CreatedDate, CreatedBy.name   from Roles__r order by CreatedDate desc) from asset where account.country_iso_code__c = 'AU'
                            and name IN:vinsList 
                           ];
            
        }else{
            allAusAssets = [Select id,name,accountid,account.name,Account.Primary_Account__c,Registration_Number__c, account.country_iso_code__c, (Select id,account__r.name, name,account__c,Account__r.Primary_Account__c, Driver__c, Handover_Date__c  from RDAs__r  order by Handover_Date__c desc ),  (Select  Id,Name, Account__r.name, Account__r.Primary_Account__c, Account__c, Role__c, Vehicle__c, Effective_From__c, Effective_To__c, LastModifiedDate, LastModifiedBy.name, CreatedDate, CreatedBy.name   from Roles__r order by CreatedDate desc) from asset where account.country_iso_code__c = 'AU'
                            and name =: Label.testingVins 
                           ];
        }
        
        Test.startTest();
        DateTime migratedDate = Datetime.newInstance(2019, 11, 14);
        
        List<role__c> mismatchedNewRoles = new List<role__c>();
        string origNam;
        list<role__c> deleteAssRoles = new list<role__c>();
        
        for(Asset ass :allAusAssets ){
            boolean rdaSourced = false;
            system.debug('Asset found '+ass.name);
            origNam= ass.account.name;
            if(ass.RDAs__r != null && ass.RDAs__r.size() > 0 && ass.Roles__r != null && ass.Roles__r.size() > 0 ){
                list<RDA__c> rdas = new list<RDA__c>(); 
                list<role__c> assRoles = new  list<role__c>(); 
                Id accountId;
                String accountName;
                rdas = ass.RDAs__r;
                assRoles = ass.Roles__r;
                RDA__c mostRecentRDA;
                Role__c mostRecentRole;
                Role__c mostRecentNonBatchRole;
                List<Role__c> nonBatchRoles;
                Role__c mostRecentBatchRole;
                Role__c potentialDuplicate;
                for(RDA__c rda : rdas){
                    if(mostRecentRDA == null || mostRecentRDA.Handover_Date__c == null || mostRecentRDA.Handover_Date__c < rda.Handover_Date__c ){
                        mostRecentRDA = rda;                                        
                    }
                }
                
                for(role__c role : assRoles){
                    
                    if(mostRecentRole == null ||  mostRecentRole.createdDate < role.createdDate ){
                        mostRecentRole = role;  
                        
                        
                    }
                    if(role.CreatedBy.Name == 'JLR Admin Patman' || role.CreatedBy.Name == 'Malcolm Lonsdale' ){
                        deleteAssRoles.add(role); 
                        if(mostRecentBatchRole == null ||  mostRecentBatchRole.createdDate < role.createdDate ){
                            mostRecentBatchRole = role;
                            
                            
                        } 
                    }
                    if(role.CreatedBy.Name != 'JLR Admin Patman' && role.CreatedBy.Name != 'Malcolm Lonsdale' ){
                        if(nonBatchRoles == null){
                            nonBatchRoles = new List<Role__c>();
                        }
                        
                        
                        nonBatchRoles.add(role);
                        if(mostRecentNonBatchRole == null ||  mostRecentNonBatchRole.createdDate < role.createdDate ){
                            mostRecentNonBatchRole = role;                            
                            
                        } 
                    }                  
                    
                }
                //If no rda exist with handover date after 11th, and no asset roles created after 11 by non-batch set to most recent asset role.
                //If no rda exist with handover date after 11th,  asset roles created after 11 by non-batch set to most recent non-batch asset role. or leave
                if(mostRecentRDA.Handover_Date__c < migratedDate ){
                    system.debug('from  most recent nonbatch');
                    accountId = mostRecentNonBatchRole.Account__c;
                    accountName = mostRecentNonBatchRole.Account__r.name;
                    deleteAssRoles.add(mostRecentNonBatchRole);
                }else{
                    //If RDA(s) exists with handover date after 11th set to most recent RDA unless Asset role exists which is created after that date and created by non-batch
                    if(mostRecentNonBatchRole !=null){
                        
                        system.debug('mostRecentNonBatchRole '+mostRecentNonBatchRole);
                        if(mostRecentRDA.Handover_Date__c > migratedDate &&  mostRecentNonBatchRole.createdDate > mostRecentRDA.Handover_Date__c ){
                            system.debug('from  most recent non batch2');
                            accountId = mostRecentNonBatchRole.Account__c;
                            accountName = mostRecentNonBatchRole.Account__r.name;
                            deleteAssRoles.add(mostRecentNonBatchRole);
                        }else{
                            if(mostRecentRDA.Handover_Date__c > migratedDate &&  mostRecentNonBatchRole.createdDate < mostRecentRDA.Handover_Date__c){
                                system.debug('from rda ');
                                rdaSourced = true;
                                accountId = mostRecentRDA.Account__c;
                                accountName = mostRecentRDA.Account__r.name;
                            }
                        }                
                        
                    }
                    
                    
                }
                system.debug('KEY Should be account Name '+accountName);
                system.debug('KEY accountId '+accountId);
                system.debug('ass '+ass.name);
                if(accountId !=  null && ((ass.Account.Primary_Account__c != null && accountId != ass.Account.Primary_Account__c && accountId != ass.AccountId ) || (ass.Account.Primary_Account__c == null && accountId != ass.AccountId)) ){
                    //the account  found or doesn't match of the asset
                    //create asset role
                    system.debug('Mismatch');
                      system.debug('Asset Account does not match most recent');
                    Role__c newRole = new Role__c();
                    if(rdaSourced){                       
                        newRole.Account__c = accountId;
                    }else{
                        newRole = mostRecentNonBatchRole.clone();                        
                    }
                    newRole.Role__c = 'Current Owner';
                    newRole.Vehicle__c = ass.Id;
                    
                    
                    mismatchedNewRoles.add(newRole);
                }else{
                   system.debug('Asset Account does match most recent');
                    system.debug('Left asset account as  '+ass.account.name);
                    //if no asset roles have an account which either matches 
                    if(rdaSourced){
                        boolean oneExists = false;
                        for(Role__c rl : assRoles){
                            if(rl.Role__c == 'Current Owner' && (rl.Account__c == ass.accountid || (ass.Account.Primary_Account__c != null && rl.Account__c == ass.Account.Primary_Account__c))){
                                oneExists =true;                               
                            }
                        }
                        if(!oneExists){
                            system.debug('add new one');
                            Role__c rl = new Role__c();
                            rl.Role__c = 'Current User';
                            rl.Vehicle__c = ass.Id;
                            rl.Account__c = ass.AccountId;
                            mismatchedNewRoles.add(rl);
                        }                        
                    }
                    Integer j = 0;
                    if(deleteAssRoles != null && deleteAssRoles.size() > 0 ){
                        while (j < deleteAssRoles.size())
                        {
                            //don't remove current owner if keeping the same
                            if(deleteAssRoles.get(j).role__c == 'Current Owner')
                            {
                                potentialDuplicate = deleteAssRoles.get(j);
                                deleteAssRoles.remove(j);                                
                            }
                            j++;
                        } 
                    }
                    
                    if(potentialDuplicate != null && nonBatchRoles != null ){
                      //  system.debug('Potential Duplicates '+potentialDuplicate);
                     //   system.debug('nonBatchRoless '+nonBatchRoles);
                        for(Role__c role : nonBatchRoles ){
                            if( ((role.Account__c == potentialDuplicate.Account__c ) || ( role.Account__r.Primary_Account__c != null && role.Account__r.Primary_Account__c == potentialDuplicate.Account__c ) ||(potentialDuplicate.Account__r.Primary_Account__c != null && role.Account__c == potentialDuplicate.Account__r.Primary_Account__c ) ) && role.Role__c == 'Previous Owner' ){
                                deleteAssRoles.add(role);
                            }
                        }
                    }              
                }             
            }
            
        }
        if(mismatchedNewRoles.size()>0){
            insert mismatchedNewRoles;   
            system.debug('FINAL Number of Roles to add '+mismatchedNewRoles.size());
            system.debug('New Roles here '+mismatchedNewRoles);           
        }
        if(deleteAssRoles != null && deleteAssRoles.size()> 0 ){
           List<Role__c> uniqueDeleteRoles = new List<Role__c>();
            // delete deleteAssRoles;
            Set<Id> deleteIds = new Set<Id>();
            system.debug('FINAL deleteAssRoles ');
            for(Role__c rl : deleteAssRoles){
                if(!deleteIds.contains(rl.Id)){
                    deleteIds.add(rl.Id);
                    uniqueDeleteRoles.add(rl);
                    system.debug('Name of deleted '+rl.name); 
                }
               
            }
             system.debug('FINAL delete Number '+deleteIds.size());
         delete uniqueDeleteRoles;
        }
        test.stopTest();
     /*   List<Asset> resultingAssets;
       
        if(vins.contains(',')){
            List<string> vinsList = vins.split(',');
            resultingAssets = [Select id,name,accountid,account.name, (Select  Id,Name, Account__r.name,  Account__c, Role__c  from Roles__r order by CreatedDate desc) from asset where account.country_iso_code__c = 'AU'
                            and name IN:vinsList 
                           ];
            
        }else{
           resultingAssets = [Select id,name,accountid,account.name, (Select  Id,Name, Account__r.name,  Account__c, Role__c   from Roles__r order by CreatedDate desc) from asset where account.country_iso_code__c = 'AU'
                       and name =: Label.testingVins 
                           ];
        }
        System.debug('RESULTS  ');
              System.debug('KEY Asset End Name '+resultingAssets[0].Name);
         System.debug('KEY Account End Name '+resultingAssets[0].Account.Name);
        System.debug('  '+Json.serializePretty(resultingAssets)); */
    }   
}
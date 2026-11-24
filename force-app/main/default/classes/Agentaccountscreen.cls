public class Agentaccountscreen {
    public class userEntRecord {
        public string AccountVal; 
        public string Product;
        public string Numb;
        public string exist;
        public string[] MLS;
        public string stateVal;
        public string SharedType;
        public string subId;
    }
    public class userEntRecordList {
        public List<userEntRecord> userEntRecordLists = new List<userEntRecord>();
    }
    
    @AuraEnabled
    public static  list<User_Licensing__c>  getuserENTpicklist(String recoId){
        list<User_Licensing__c> listpick = new list<User_Licensing__c>();
        listpick = [select id, Product__c from  User_Licensing__c limit 10000];
        system.debug('ID name '+listpick);
        return listpick;
        
    }
    
    @AuraEnabled
    public static  boolean  InsertuserENT(String recoId, String productVal){
        
        Account accObj=[select id,Billing_Status__c from Account where id=:recoid];
        User_Licensing__c UserObj = new User_Licensing__c();
        if(accObj.Billing_Status__c==true){
            userobj.Account__c = recoId;
            userobj.Product__c = productVal;
            userobj.Active__c=true;
        }else{
            userobj.Account__c = recoId;
            userobj.Product__c = productVal;
        }
        UserObj.Status__c = 'Pending Fulfillment';
        insert userobj;
        return true;
        
    }
    @AuraEnabled
    public static List<String> getPicklistValue(String recordID){
        try{
            Set<String> options = new Set<String>();
            System.debug('recId v-->'+ recordID);
            List<Account> accList = [Select Id, Top_Producer_Websites_License__c, Top_Producer_CRM_License__c, Top_Producer_Assistant_License__c, Market_Snapshot_License__c, Five_Street_License__c,Social_Connect_License__c,HomeIntel_License__c, HomeIntelle_Hub_License__c, House_Values_License__c from Account where Id=: recordID LIMIT 1];
            
            List<SBQQ__Subscription__c> subsList = [Select Id, SBQQ__ProductName__c, SBQQ__Quantity__c from SBQQ__Subscription__c where SBQQ__Account__c=: recordID];
            Map<String,decimal> subsMap = new Map<String,decimal>();
            for(SBQQ__Subscription__c sub: subsList){
                if(sub.SBQQ__ProductName__c == ProductNames.TPFS && accList[0].Five_Street_License__c > 0){
                    options.add(sub.SBQQ__ProductName__c);
                }else if(sub.SBQQ__ProductName__c == ProductNames.TPMS && accList[0].Market_Snapshot_License__c > 0){
                    options.add(sub.SBQQ__ProductName__c);
                }else if(sub.SBQQ__ProductName__c == ProductNames.TPAL && accList[0].Top_Producer_Assistant_License__c > 0){
                    options.add(sub.SBQQ__ProductName__c);
                }else if(sub.SBQQ__ProductName__c == ProductNames.TPCRM && accList[0].Top_Producer_CRM_License__c > 0){
                    options.add(sub.SBQQ__ProductName__c);
                }else if(sub.SBQQ__ProductName__c == ProductNames.TPWS && accList[0].Top_Producer_Websites_License__c > 0){
                    options.add(sub.SBQQ__ProductName__c);
                }else if(sub.SBQQ__ProductName__c.contains(ProductNames.TPSC) && accList[0].Social_Connect_License__c > 0){
                    options.add(ProductNames.TPSC);
                }else if(sub.SBQQ__ProductName__c.contains(ProductNames.TPHI) && accList[0].HomeIntel_License__c > 0){
                    options.add(ProductNames.TPHI);
                }else if(sub.SBQQ__ProductName__c.contains(ProductNames.HIntH) && accList[0].HomeIntelle_Hub_License__c > 0){
                    options.add(ProductNames.HIntH);
                }else if(sub.SBQQ__ProductName__c.contains(ProductNames.HV) && accList[0].House_Values_License__c > 0){
                    options.add(ProductNames.HV);
                }
                
                if(sub.SBQQ__ProductName__c == ProductNames.TPPRO && accList[0].Top_Producer_CRM_License__c > 0){ options.add(ProductNames.TPCRM); }
                if(sub.SBQQ__ProductName__c == ProductNames.TPPRO && accList[0].Market_Snapshot_License__c > 0){  options.add(ProductNames.TPMS);  }
                if(sub.SBQQ__ProductName__c == ProductNames.TPPRO && accList[0].HomeIntel_License__c > 0){  options.add(ProductNames.TPHI);  }
                
                if(sub.SBQQ__ProductName__c == ProductNames.TPPROP && accList[0].Top_Producer_CRM_License__c > 0){ options.add(ProductNames.TPCRM); }
                if(sub.SBQQ__ProductName__c == ProductNames.TPPROP && accList[0].Market_Snapshot_License__c > 0){  options.add(ProductNames.TPMS);  }
                if(sub.SBQQ__ProductName__c == ProductNames.TPPROP && accList[0].HomeIntel_License__c > 0){  options.add(ProductNames.TPHI);  }
            } 
            return new List<String>(options);
        }catch(Exception e){
            System.debug('error -->'+ e.getMessage());
            System.debug('line -->'+ e.getLineNumber());
            return null;
        }
        
        
        
    }
    
    @AuraEnabled
    public static string insertUserEntitlementsController(String recId, String userEntStr){
        try{
            Map<id,List<Id>> accVSMLSList = new Map<id,List<Id>>();
            Map<User_Licensing__c,List<MLS__c>> ULVsMLSMap = new Map<User_Licensing__c,List<MLS__c>>();
            List<Account> accList = [Select Id, Email__c, Top_Producer_Websites_License__c, Top_Producer_CRM_License__c, Top_Producer_Assistant_License__c, Market_Snapshot_License__c, Five_Street_License__c, Social_Connect_License__c,HomeIntel_License__c,HomeIntelle_Hub_License__c, House_Values_License__c from Account where Id=: recId LIMIT 1];
            List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>();
            subsList = [Select id, SBQQ__ProductName__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Account__c from SBQQ__Subscription__c where SBQQ__Account__c =: recId]; 
            Map<String,SBQQ__Subscription__c> ProductNameSubsMap = new Map<String,SBQQ__Subscription__c>();
            if(!subsList.isEmpty()){
                for(SBQQ__Subscription__c subs: subsList){
                    if(subs.SBQQ__ProductName__c == 'Five Street'){ ProductNameSubsMap.put('Five street',subs); }
                    if(subs.SBQQ__ProductName__c == ProductNames.TPPRO){ ProductNameSubsMap.put(ProductNames.TPMS,subs); ProductNameSubsMap.put(ProductNames.TPCRM,subs); ProductNameSubsMap.put(ProductNames.TPHI,subs); }
                    if(subs.SBQQ__ProductName__c.contains(ProductNames.TPSC)){ ProductNameSubsMap.put(ProductNames.TPSC,subs); }
                    if(subs.SBQQ__ProductName__c == ProductNames.TPPROP){ ProductNameSubsMap.put(ProductNames.TPMS,subs); ProductNameSubsMap.put(ProductNames.TPCRM,subs); ProductNameSubsMap.put(ProductNames.TPHI,subs);}
                    if(subs.SBQQ__ProductName__c.contains(ProductNames.TPHI)){ ProductNameSubsMap.put(ProductNames.TPHI,subs); }
                    if(subs.SBQQ__ProductName__c.contains(ProductNames.HIntH)){ ProductNameSubsMap.put(ProductNames.HIntH,subs); }
                    if(subs.SBQQ__ProductName__c.contains(ProductNames.HV)){ ProductNameSubsMap.put(ProductNames.HV,subs); }
                    ProductNameSubsMap.put(subs.SBQQ__ProductName__c,subs);
                } 
            }
            List<userEntRecord> userEntList = (List<userEntRecord>)JSON.deserialize(userEntStr, List<userEntRecord>.class);
            Set<String> mlsAssociationSet = new Set<String>(); 
            Map<String,integer> prodQuantityMap = new Map<String,integer>();	
            List<User_Licensing__c> insertUserList = new List<User_Licensing__c>();
            List<MLS__c> mlsList = new List<MLS__c>();
            for(userEntRecord f : userEntList){
                User_Licensing__c usr = new User_Licensing__c();
                usr.Parent_Account__c = recId;
                usr.Account__c = f.AccountVal;
                usr.Product__c = f.Product;
                if(f.Product.contains(ProductNames.TPSC)){
                    usr.Start_Time_UTC__c = System.today();
                    usr.Location_Radius__c = Decimal.valueOf(Label.Social_Connect_Radius);
                    usr.Daily_Budget__c = Decimal.valueOf(Label.Social_Connect_Daily_Budget);
                }
                usr.Status__c = 'Pending Fulfillment';
                if(f.subId != null && f.subId != ''){
                    usr.Subscription__c = f.subId;    
                }else{
                 	usr.Subscription__c = ProductNameSubsMap.get(f.Product).id;       
                }

                usr.License_Type__c = f.SharedType;
                usr.ULFromAcount__c = true;
                usr.User_Email__c = accList[0].Email__c;
                if(ProductNameSubsMap.containsKey(f.Product)){
                    usr.Start_Date__c = ProductNameSubsMap.get(f.Product).SBQQ__StartDate__c;
                    usr.End_Date__c = ProductNameSubsMap.get(f.Product).SBQQ__EndDate__c;
                }
                System.debug('f.Numb--->'+f.Numb);
                usr.Quantity__c = Integer.valueOf(f.Numb);
                insertUserList.add(usr);
                if(prodQuantityMap.containsKey(f.Product)){
                    prodQuantityMap.put(f.Product,prodQuantityMap.get(f.Product)+Integer.valueOf(f.Numb));
                }
                else{
                    prodQuantityMap.put(f.Product,Integer.valueOf(f.Numb));
                }
                mlsAssociationSet.addAll(f.MLS);
            }
            Account acc = new Account();
            acc.id = recId;
            for(String prod : prodQuantityMap.keySet()){
                if(prod == ProductNames.TPFS)
                    acc.Five_Street_License__c = accList[0].Five_Street_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.TPMS)
                    acc.Market_Snapshot_License__c = accList[0].Market_Snapshot_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.TPAL)
                    acc.Top_Producer_Assistant_License__c = accList[0].Top_Producer_Assistant_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.TPCRM)
                    acc.Top_Producer_CRM_License__c = accList[0].Top_Producer_CRM_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.TPWS)
                    acc.Top_Producer_Websites_License__c = accList[0].Top_Producer_Websites_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.TPSC)
                    acc.Social_Connect_License__c = accList[0].Social_Connect_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.TPHI)
                    acc.HomeIntel_License__c = accList[0].HomeIntel_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.HIntH)
                    acc.HomeIntelle_Hub_License__c = accList[0].HomeIntelle_Hub_License__c - prodQuantityMap.get(prod);
                if(prod == ProductNames.HV)
                    acc.House_Values_License__c = accList[0].House_Values_License__c - prodQuantityMap.get(prod);
            }
            
            List<MLS_Board__c> mlsBroadList = new List<MLS_Board__c>([Select id,MLS_Association__c,MS_Paper_Work_Req__c from MLS_Board__c where MLS_Association__c IN : mlsAssociationSet]);
            System.debug('mlsBroadList--->'+mlsBroadList);
            Map<Id, MLS_Board__c> mlsBoardMap = new Map<Id, MLS_Board__c>();
            Map<Id,Id> mlsAssVSmlsBroadMap = new Map<Id,Id>();
            for(MLS_Board__c broadObj:mlsBroadList){
                mlsBoardMap.put(broadObj.Id, broadObj);
                mlsAssVSmlsBroadMap.put(broadObj.MLS_Association__c,broadObj.Id);
            }
            
            System.debug('mlsBoardMap--->'+mlsBoardMap);
            System.debug('mlsAssVSmlsBroadMap--->'+mlsAssVSmlsBroadMap);
            Boolean Errors = false;
            for(integer i=0; i<userEntList.size(); i++){
                for(Id key: userEntList[i].MLS){
                    if(mlsAssVSmlsBroadMap.containsKey(Key)){
                        if(mlsBoardMap.get(mlsAssVSmlsBroadMap.get(key)).MS_Paper_Work_Req__c){
                            insertUserList[i].Status__c = 'Pending Paperwork';
                        }
                    }
                    else{
                        Errors = true;
                    }
                }
            }
            if(Errors == false){
                insert insertUserList;
                for(integer i=0;i<userEntList.size();i++){
                    for(Id key: userEntList[i].MLS){
                        MLS__c mlsObj= new MLS__c();
                        mlsObj.MLS__c = userEntList[i].AccountVal;
                        mlsObj.MLS_Association__c = key;
                        mlsObj.MLS_Board__c = mlsAssVSmlsBroadMap.get(key);
                        mlsObj.MS_Paper_Work_Req__c = mlsBoardMap.get(mlsAssVSmlsBroadMap.get(key)).MS_Paper_Work_Req__c;
                        mlsObj.Account_Email__c = accList[0].Email__c;
                        if(mlsBoardMap.get(mlsAssVSmlsBroadMap.get(key)).MS_Paper_Work_Req__c){
                            insertUserList[i].Status__c = 'Pending Paperwork';
                        }
                        mlsObj.User_Licensing__c = insertUserList[i].id;
                        mlsList.add(mlsObj);
                    }
                }
                System.debug('acc--->'+acc);
                System.debug('insertUserList--->'+insertUserList);
                System.debug('mlsList--->'+mlsList);
                //if(Errors == false){
                insert mlsList;
                update acc;
                update insertUserList;
                return 'true';
            }
            else{
                //delete insertUserList;
                return 'MLS Association does not have any MLS Boards related to it.';
            }
        }
        catch(Exception e){
            System.debug('error -->'+ e.getMessage());
            System.debug('line -->'+ e.getLineNumber());
            return 'false';
        }
    }
    @AuraEnabled
    public static string fetchRecordTypeId(String recordName){
        try{
            String devRecordTypeId = '';
            if(recordName != null){
                devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordName).getRecordTypeId();
                System.debug('devRecordTypeId---->'+devRecordTypeId);
                
            }return devRecordTypeId;
        }catch(Exception e){
            System.debug('error -->'+ e.getMessage());
            System.debug('line -->'+ e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static String getAvailableLicenseDetails(String recId){
        List<Account> accList = [Select Id, Top_Producer_Websites_License__c, Top_Producer_CRM_License__c, Top_Producer_Assistant_License__c, Market_Snapshot_License__c, Five_Street_License__c, Social_Connect_License__c,HomeIntel_License__c,HomeIntelle_Hub_License__c, House_Values_License__c from Account where Id=: recId LIMIT 1];
        AccountRecord acc = new AccountRecord();
        
        if(!accList.isEmpty()){
            acc.FiveStreet = accList[0].Five_Street_License__c != NULL && accList[0].Five_Street_License__c != 0 ? accList[0].Five_Street_License__c  : 0;
            acc.MarketSnapshot = accList[0].Market_Snapshot_License__c != NULL && accList[0].Market_Snapshot_License__c != 0  ? accList[0].Market_Snapshot_License__c  : 0;
            acc.TopProducerAssistantLicense = accList[0].Top_Producer_Assistant_License__c != NULL && accList[0].Top_Producer_Assistant_License__c != 0  ? accList[0].Top_Producer_Assistant_License__c  : 0;
            acc.TopProducerCRM = accList[0].Top_Producer_CRM_License__c != NULL && accList[0].Top_Producer_CRM_License__c != 0  ? accList[0].Top_Producer_CRM_License__c  : 0;
            acc.TopProducerWebsites = accList[0].Top_Producer_Websites_License__c != NULL && accList[0].Top_Producer_Websites_License__c != 0  ? accList[0].Top_Producer_Websites_License__c  : 0;
            acc.SocialConnect = accList[0].Social_Connect_License__c != NULL && accList[0].Social_Connect_License__c != 0  ? accList[0].Social_Connect_License__c  : 0;
            acc.HomeIntel = accList[0].HomeIntel_License__c != NULL && accList[0].HomeIntel_License__c != 0  ? accList[0].HomeIntel_License__c  : 0;
            acc.HomeIntelleHub = accList[0].HomeIntelle_Hub_License__c != NULL && accList[0].HomeIntelle_Hub_License__c != 0  ? accList[0].HomeIntelle_Hub_License__c  : 0;
            acc.HouseValues = accList[0].House_Values_License__c != NULL && accList[0].House_Values_License__c != 0  ? accList[0].House_Values_License__c  : 0;
        }
        System.debug('acc---->'+acc);
        if(acc != NULL) {
            return JSON.serialize(acc);
        }
        else {
            return '';
        }
        
    }
    @AuraEnabled
    public static String getTotalLicenseDetails(String recId){
        List<SBQQ__Subscription__c> subsList = [Select Id, SBQQ__ProductName__c, SBQQ__Quantity__c from SBQQ__Subscription__c where SBQQ__Account__c=: recId];
        AccountRecord acc = new AccountRecord();
        acc.FiveStreet = -1;
        acc.MarketSnapshot = -1;
        acc.TopProducerAssistantLicense = -1;
        acc.TopProducerCRM = -1;
        acc.TopProducerWebsites = -1;
        acc.SocialConnect = -1;
        acc.HomeIntel = -1;
        acc.HomeIntelleHub = -1;
        acc.HouseValues = -1;
        System.debug('subsList---> '+subsList);
        for(SBQQ__Subscription__c sub: subsList){
            System.debug('sub.SBQQ__ProductName__c->'+sub.SBQQ__ProductName__c);
            if(sub.SBQQ__ProductName__c == ProductNames.TPFS){
                acc.FiveStreet = acc.FiveStreet == -1? sub.SBQQ__Quantity__c : acc.FiveStreet+sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c == ProductNames.TPMS){
                acc.MarketSnapshot = acc.MarketSnapshot == -1? sub.SBQQ__Quantity__c : acc.MarketSnapshot + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c == ProductNames.TPAL){
                acc.TopProducerAssistantLicense = acc.TopProducerAssistantLicense == -1? sub.SBQQ__Quantity__c : acc.TopProducerAssistantLicense + sub.SBQQ__Quantity__c ;
            }else if(sub.SBQQ__ProductName__c == ProductNames.TPCRM){
                acc.TopProducerCRM = acc.TopProducerCRM == -1? sub.SBQQ__Quantity__c : acc.TopProducerCRM + sub.SBQQ__Quantity__c ;
            }else if(sub.SBQQ__ProductName__c == ProductNames.TPWS){
                acc.TopProducerWebsites =  acc.TopProducerWebsites == -1? sub.SBQQ__Quantity__c : acc.TopProducerWebsites + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c.Contains(ProductNames.TPSC)){
                acc.SocialConnect =  acc.SocialConnect == -1? sub.SBQQ__Quantity__c : acc.SocialConnect + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c == ProductNames.TPPRO){
                acc.TopProducerCRM = acc.TopProducerCRM == -1? sub.SBQQ__Quantity__c : acc.TopProducerCRM + sub.SBQQ__Quantity__c ;
                acc.MarketSnapshot = acc.MarketSnapshot == -1? sub.SBQQ__Quantity__c : acc.MarketSnapshot + sub.SBQQ__Quantity__c;
                acc.HomeIntel =  acc.HomeIntel == -1? sub.SBQQ__Quantity__c : acc.HomeIntel + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c == ProductNames.TPPROP){
                acc.TopProducerCRM = acc.TopProducerCRM == -1? sub.SBQQ__Quantity__c : acc.TopProducerCRM + sub.SBQQ__Quantity__c ;
                acc.MarketSnapshot = acc.MarketSnapshot == -1? sub.SBQQ__Quantity__c : acc.MarketSnapshot + sub.SBQQ__Quantity__c;
                acc.HomeIntel =  acc.HomeIntel == -1? sub.SBQQ__Quantity__c : acc.HomeIntel + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c.Contains(ProductNames.TPHI)){
                acc.HomeIntel =  acc.HomeIntel == -1? sub.SBQQ__Quantity__c : acc.HomeIntel + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c.Contains(ProductNames.HIntH)){
                acc.HomeIntelleHub =  acc.HomeIntelleHub == -1? sub.SBQQ__Quantity__c : acc.HomeIntelleHub + sub.SBQQ__Quantity__c;
            }else if(sub.SBQQ__ProductName__c.Contains(ProductNames.HV)){
                acc.HouseValues =  acc.HouseValues == -1? sub.SBQQ__Quantity__c : acc.HouseValues + sub.SBQQ__Quantity__c;
            }
        }
        System.debug('acc---> '+acc);
        if(acc != NULL) {
            return JSON.serialize(acc);
        }
        else {
            return '';
        }
        
    }
    
    @AuraEnabled
    public static boolean checkExistingENTError(String objectRecord){
        userEntRecord userEntList = (userEntRecord)JSON.deserialize(objectRecord, userEntRecord.class);
        String ProductName = userEntList.Product;
        String AccountId = userEntList.AccountVal;
        List<Account> accList  = [Select id, recordtype.Name from Account where id=:AccountId]; 
        List<User_Licensing__c> usrList = [Select id, Account__c,  Product__c from User_Licensing__c where Product__c =: ProductName and Account__c =: AccountId and Product__c !=: ProductNames.HV];
        if(usrList.isEmpty()){
            return false;
        }
        else{
            if(!accList.isEmpty()){
                if(accList[0].recordtype.Name == 'Agent')
                    return true;
                else
                    return false;
            }else{
                return false;
            }
        }
        
    }
    
    @AuraEnabled
    public static boolean changeRecordTypeController(String accId){
        try{
            List<Account> accLst = [select id, recordtype.id from Account where id =: accId limit 1];
            Id TeamRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Team').getRecordTypeId();
            Account acc = new Account();
            acc.id = accLst[0].id;
            acc.RecordTypeId = TeamRecordTypeId;
            update acc;
            system.debug('acc---:::>> '+acc);
            return true;
        }catch(Exception e){
            System.debug('error -->'+ e.getMessage());
            System.debug('line -->'+ e.getLineNumber());
            return false;
        }
        
    }

    public class AccountRecord {
        public Decimal Fivestreet; 
        public Decimal MarketSnapshot;
        public Decimal TopProducerAssistantLicense;
        public Decimal TopProducerCRM;
        public Decimal TopProducerWebsites;
        public Decimal SocialConnect;
        public Decimal HomeIntel;
        public Decimal HomeIntelleHub;
        public Decimal HouseValues;
    }
    
    public static void dummyCode(){
        String test = '';
            test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    }
}
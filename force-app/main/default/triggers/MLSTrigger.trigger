trigger MLSTrigger on MLS__c (after insert) {
    UserLicensingTriggerHandler handler = new UserLicensingTriggerHandler(Trigger.isExecuting, Trigger.size);
    private final String FS = 'FiveStreet', TPCRM = 'Top Producer CRM', MS = 'Market Snapshot', TPW = 'Top Producer Website';
    if(Trigger.isInsert){
        set<ID> licenseIds = new set<ID>();
        set<Id> setBoardIds = new set<Id>();
        List<String> lstMlsBoards = new List<String>();
        for(MLS__c mls : trigger.New){
            licenseIds.add(mls.User_Licensing__c);
            setBoardIds.add(mls.MLS_Board__c);            
        }
        if(setBoardIds.size() > 0){
            for(MLS_Board__c mlsBoard : [Select Id,MLS_Board_ID__c from MLS_Board__c where Id IN :setBoardIds]){
                lstMlsBoards.add(mlsBoard.MLS_Board_ID__c);
                System.debug('MLS_Board_ID__c: ' + mlsBoard.MLS_Board_ID__c);
            }
        }
        Map<String,String> licAccIds = new Map<String,String>();
        
        Map<Id,User_Licensing__c> newLicenses = new Map<Id,User_Licensing__c>([Select Id,Quantity__c,Username__c,Account__c,Parent_Account__c,Status__c,Product__c,Account__r.Name,Account__r.Email__c,Account__r.Phone,Account__r.Owner.Name from User_Licensing__c where Status__c = 'Pending Fulfillment' AND Product__c=:MS AND Id IN :licenseIds]);
        for(User_Licensing__c license : newLicenses.values()){
            if(license.Account__c != null) {
                licAccIds.put(license.Id,license.Account__c);
                
            }else{
                licAccIds.put(license.Id,license.Parent_Account__c);
            }
        }
        List<User_Licensing__c> existingLicenses = new List<User_Licensing__c>();
        if(licAccIds.size() > 0){
            existingLicenses = [Select Id,Username__c,Account__c,Parent_Account__c,TPAccountId__c,TPUserID__c,Status__c,Product__c from User_Licensing__c 
                                where Account__c IN :licAccIds.Values() and Product__c =: TPCRM and Status__c = 'Fulfilled'];
            if(existingLicenses.size() > 0){
                Map<ID,Account> mapOfAccount = new Map<Id,Account>([SELECT RecordTypeId ,RecordType.Name,Name,Phone,Email__c,(SELECT Accountid,FirstName,LastName FROM Contacts where isPrimaryContact__c = true) FROM Account WHERE Id IN : licAccIds.values()]);
                Account acc;
                for(User_Licensing__c license : newLicenses.values()){
                    acc = license.Account__c != null ? mapOfAccount.get(license.Account__c) : mapOfAccount.get(license.Parent_Account__c);   
                    for(Contact con : acc.Contacts){
                        if(license.Product__c.equals(MS)){
                            TPMSUtility.CreateAccount(con.FirstName,con.LastName,acc.Phone,acc.Email__c,acc.Name,license.Id,existingLicenses.get(0).TPAccountId__c,
                                                      existingLicenses.get(0).TPUserID__c,existingLicenses.get(0).Username__c,lstMlsBoards);
                        }
                    }
                }   
            }
        }
    }
}
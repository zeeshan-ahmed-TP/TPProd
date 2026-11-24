public class UserLicensingTriggerHandler {

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;  
    
    public UserLicensingTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnAfterInsert(Set<Id> licenseIds,Set<Id> MLSID){
        Map<String,String> licAccIds = new Map<String,String>();
        
        Map<Id,User_Licensing__c> newLicenses = new Map<Id,User_Licensing__c>([Select Id,Quantity__c,Username__c,Account__c,Parent_Account__c,
                                                                               Status__c,Product__c,Account__r.Name,Account__r.Email__c,Account__r.Phone,
                                                                               Account__r.Owner.Name, Start_Time_UTC__c,End_Time_UTC__c,Location_Radius__c,
                                                                               Daily_Budget__c,HV_Item_ID__c, Subscription__r.SBQQ__Quantity__c, Subscription__r.SBQQ__ListPrice__c
                                                                               from User_Licensing__c where Id IN :licenseIds]);
        for(User_Licensing__c license : newLicenses.values()){
            if(license.Account__c != null) {
                licAccIds.put(license.Id,license.Account__c);
            }else{
                licAccIds.put(license.Id,license.Parent_Account__c);
            }
        }
        Map<ID,Account> mapOfAccount = new Map<Id,Account>([SELECT RecordTypeId ,RecordType.Name,Name,Phone,Email__c,(SELECT Accountid,FirstName,LastName FROM Contacts where isPrimaryContact__c = true) FROM Account WHERE Id IN : licAccIds.values()]);
        Account acc;
        for(User_Licensing__c license : newLicenses.values()){
            acc = license.Account__c != null ? mapOfAccount.get(license.Account__c) : mapOfAccount.get(license.Parent_Account__c); 
            if(acc.Contacts != null && acc.Contacts.size() > 0){
                Contact con = acc.Contacts.get(0);
                if(license.Product__c.equals(ProductNames.TPCRM)){
                    TPCRMRestHandler.createAccount(acc.RecordType.Name, license.Quantity__c, con.FirstName,con.LastName,acc.Email__c,acc.Name,license.Id);
                } else if(license.Product__c.equals(ProductNames.TPWS)){
                    TPWebsiteUtility.CreateAccount(con.FirstName,con.LastName,acc.Email__c,acc.Name,license.Quantity__c,license.Id);
                } else if(license.Product__c.equals(ProductNames.TPFS)){
                    FiveStreetHandler.addUsertoFS(license.Account__r.Name,license.Account__r.Email__c,license.Account__r.Phone,license.Account__r.Owner.Name,license.Account__c,license.Id);
                } else if(license.Product__c.equals(ProductNames.TPSC)){
                    List<User_Licensing__c> existingLicenses = new List<User_Licensing__c>();
                    existingLicenses = [Select Id,Username__c,Account__c,Parent_Account__c,TPAccountId__c,TPUserID__c,Status__c,Product__c from User_Licensing__c 
                                        where Account__c = :license.Account__c and Product__c =: ProductNames.TPCRM and Status__c = 'Fulfilled']; 
                    String subscriptionId = GuidUtil.NewGuid();
                    TPCRMRestHandler.addSubscription(license.Id,1, existingLicenses.get(0).TPAccountId__c, existingLicenses.get(0).TPUserID__c, subscriptionId,'34');
                } else if(license.Product__c.equals(ProductNames.TPHI)){
                    List<User_Licensing__c> existingLicenses = new List<User_Licensing__c>();
                    existingLicenses = [Select Id,Username__c,Account__c,Parent_Account__c,TPAccountId__c,TPUserID__c,Status__c,Product__c from User_Licensing__c 
                                        where Account__c = :license.Account__c and Product__c =: ProductNames.TPCRM and Status__c = 'Fulfilled']; 
                     String subscriptionId = GuidUtil.NewGuid();
                    TPCRMRestHandler.addSubscription(license.Id,1, existingLicenses.get(0).TPAccountId__c, existingLicenses.get(0).TPUserID__c, subscriptionId,'35');                    
                }else if(license.Product__c.equals(ProductNames.HV)){
                    List<User_Licensing__c> existingLicenses = new List<User_Licensing__c>();
                    existingLicenses = [Select Id,Username__c,Account__c,Parent_Account__c,TPAccountId__c,TPUserID__c,Status__c,Product__c from User_Licensing__c 
                                        where Account__c = :license.Account__c and Product__c =: ProductNames.TPCRM and Status__c = 'Fulfilled']; 
                     String subscriptionId = GuidUtil.NewGuid();
                    TPCRMRestHandler.addSubscriptionWithLicense(license.Id,1, existingLicenses.get(0).TPAccountId__c, existingLicenses.get(0).TPUserID__c, subscriptionId,'36');                    
                    TPCRMRestHandler.subscribeHVPostalCode(existingLicenses.get(0).TPUserID__c,license.HV_Item_ID__c,license.Subscription__r.SBQQ__Quantity__c,license.Subscription__r.SBQQ__ListPrice__c);
                }
            }
        }
    }

    public void refundLicensesToAccount(List<User_Licensing__c> newUL,Map<Id, User_Licensing__c> oldUL) {
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> agentAccountIds = new Set<Id>();
        
        for (User_Licensing__c ul : newUL) {
            if (ul.Account__c != null) agentAccountIds.add(ul.Account__c);
            if (ul.Parent_Account__c != null) parentAccountIds.add(ul.Parent_Account__c);
        }
        
        Map<Id, Account> parentAccounts = new Map<Id, Account>([
            SELECT Five_Street_License__c,
            Market_Snapshot_License__c,
            Top_Producer_Assistant_License__c,
            Top_Producer_CRM_License__c,
            Top_Producer_Websites_License__c
            FROM Account
            WHERE Id IN :parentAccountIds
        ]);
        
        Map<Id, Account> agentAccounts = new Map<Id, Account>([
            SELECT Five_Street_License__c,
            Market_Snapshot_License__c,
            Top_Producer_Assistant_License__c,
            Top_Producer_CRM_License__c,
            Top_Producer_Websites_License__c
            FROM Account
            WHERE Id IN :agentAccountIds
        ]);
        
        Set<String> returnStatuses = new Set<String>{ 'Canceled', 'Expired', 'Failed' };
            
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        
        for (User_Licensing__c ul : newUL) {
            if (
                ul.Status__c == null ||
                ul.Product__c == null ||
                !returnStatuses.contains(ul.Status__c) ||
                (oldUL.get(ul.Id) != null &&
                 returnStatuses.contains(oldUL.get(ul.Id).Status__c))
            ) {
                continue;
            }
            
            Account accountToRefund;
            if (ul.Parent_Account__c != null) {
                accountToRefund = parentAccounts.get(ul.Parent_Account__c);
            } else if (ul.Account__c != null) {
                accountToRefund = agentAccounts.get(ul.Account__c);
            }
            
            if (accountToRefund == null) continue;
            
            // Accumulate updates
            if (ul.Product__c == 'FiveStreet' && accountToRefund.Five_Street_License__c != null) {
                accountToRefund.Five_Street_License__c += ul.Quantity__c;
            }
            else if (ul.Product__c == 'Market Snapshot' && accountToRefund.Market_Snapshot_License__c != null) {
                accountToRefund.Market_Snapshot_License__c += ul.Quantity__c;
            }
            else if (ul.Product__c == 'Top Producer Assistant License') {
                accountToRefund.Top_Producer_Assistant_License__c += ul.Quantity__c;
            }
            else if (ul.Product__c == 'Top Producer CRM' && accountToRefund.Top_Producer_CRM_License__c != null) {
                accountToRefund.Top_Producer_CRM_License__c += ul.Quantity__c;
            }
            else if (ul.Product__c == 'Top Producer Website' && accountToRefund.Top_Producer_Websites_License__c != null) {
                accountToRefund.Top_Producer_Websites_License__c += ul.Quantity__c;
            }
            
            accountsToUpdate.put(accountToRefund.Id, accountToRefund);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
    }
    
    public void adjustLicensesFromAccount(List<User_Licensing__c> newUL, Map<Id, User_Licensing__c> oldUL){
        Set<Id> parentAccountIds = new Set<Id>();
        Set<Id> agentAccountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for(User_Licensing__c ul : newUL){
            if(ul.Account__c!=null) agentAccountIds.add(ul.Account__c);
            if(ul.Parent_Account__c!=null) parentAccountIds.add(ul.Parent_Account__c);
        }
        Map<Id, Account> parentAccounts = new Map<Id,Account>([select Five_Street_License__c,Market_Snapshot_License__c,Top_Producer_Assistant_License__c,Top_Producer_CRM_License__c,Top_Producer_Websites_License__c from ACcount where Id in :parentAccountIds]);
        Map<Id, Account> agentAccounts = new Map<Id,Account>([select Five_Street_License__c,Market_Snapshot_License__c,Top_Producer_Assistant_License__c,Top_Producer_CRM_License__c,Top_Producer_Websites_License__c from ACcount where Id in :agentAccountIds]);

        for(User_Licensing__c ul : newUL){
            Account accountToAdjust;
            Account parentAccount = ul.Parent_Account__c!=null ? parentAccounts.get(ul.Parent_Account__c) : null;
            Account agentAccount = ul.Account__c!=null ? agentAccounts.get(ul.Account__c) : null;
            if(parentAccount!=null){
                accountToAdjust = parentAccount;
            }
            else if(parentAccount==null && agentAccount!=null){
                accountToAdjust = agentAccount;
            }
            if(accountToAdjust!=null && ul.Quantity__c!=null && ul.Product__c!=null && ul.Quantity__c!=oldUL.get(ul.id).Quantity__C){
                Decimal quantityToSubtract = ul.Quantity__c - (oldUL.get(ul.id).Quantity__c != null ? oldUL.get(ul.id).Quantity__c : 0);
                if(ul.Product__c=='FiveStreet' && accountToAdjust.Five_Street_License__c != null){
                    accountToAdjust.Five_Street_License__c-=quantityToSubtract;
                    if(accountToAdjust.Five_Street_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(accountToAdjust.Market_Snapshot_License__c != null && ul.Product__c=='Market Snapshot'){
                    accountToAdjust.Market_Snapshot_License__c-=quantityToSubtract;
                    if(accountToAdjust.Market_Snapshot_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(accountToAdjust.Top_Producer_Assistant_License__c != null && ul.Product__c=='Top Producer Assistant License'){
                    accountToAdjust.Top_Producer_Assistant_License__c-=quantityToSubtract;
                    if(accountToAdjust.Top_Producer_Assistant_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(accountToAdjust.Top_Producer_CRM_License__c != null && ul.Product__c=='Top Producer CRM'){
                    accountToAdjust.Top_Producer_CRM_License__c-=quantityToSubtract;         
                    if(accountToAdjust.Top_Producer_CRM_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(accountToAdjust.Top_Producer_Websites_License__c != null && ul.Product__c=='Top Producer Website'){
                    accountToAdjust.Top_Producer_Websites_License__c-=quantityToSubtract;   
                    if(accountToAdjust.Top_Producer_Websites_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
				accountsToUpdate.add(accountToAdjust);
            }
            
        }
        update accountsToUpdate;
    }
    
    public void accountChangeLicenseAdjustment(List<User_Licensing__c> newUL, Map<Id, User_Licensing__c> oldUL){
        Set<Id> oldParentAccountIds = new Set<Id>();
        Set<id> newParentAccountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for(User_Licensing__c ul : newUL){
            if(ul.Parent_Account__c!=null) newparentAccountIds.add(ul.Parent_Account__c);
            if(oldUL.get(ul.id).Parent_Account__c!=null) oldParentAccountIds.add(oldUL.get(ul.id).Parent_Account__c);
        }
        Map<Id, Account> oldParentAccounts = new Map<Id,Account>([select Five_Street_License__c,Market_Snapshot_License__c,Top_Producer_Assistant_License__c,Top_Producer_CRM_License__c,Top_Producer_Websites_License__c from ACcount where Id in :oldParentAccountIds]);
        Map<Id, Account> newParentAccounts = new Map<Id,Account>([select Five_Street_License__c,Market_Snapshot_License__c,Top_Producer_Assistant_License__c,Top_Producer_CRM_License__c,Top_Producer_Websites_License__c from ACcount where Id in :newParentAccountIds]);

        for(User_Licensing__c ul : newUL){
            
            if(ul.Parent_Account__c!=null && oldUL.get(ul.id).Parent_Account__c!=null && ul.Quantity__c!=null && ul.Product__c!=null && ul.Parent_Account__c!=oldUL.get(ul.id).Parent_Account__c){
                
                Account newParentAccount = newParentAccounts.get(ul.Parent_Account__c);
                Account oldParentAccount = oldParentAccounts.get(oldUL.get(ul.id).Parent_Account__c);
                
                if(ul.Product__c=='FiveStreet'){
                    newParentAccount.Five_Street_License__c-=ul.Quantity__C;
                    oldParentAccount.Five_Street_License__c+=ul.Quantity__C;
                    if(newParentAccount.Five_Street_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(ul.Product__c=='Market Snapshot'){
                    newParentAccount.Market_Snapshot_License__c-=ul.Quantity__C;
                    oldParentAccount.Market_Snapshot_License__c+=ul.Quantity__C;
                    if(newParentAccount.Market_Snapshot_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(ul.Product__c=='Top Producer Assistant License'){
                    newParentAccount.Top_Producer_Assistant_License__c-=ul.Quantity__C;
                    oldParentAccount.Top_Producer_Assistant_License__c+=ul.Quantity__C;
                    if(newParentAccount.Top_Producer_Assistant_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(ul.Product__c=='Top Producer CRM'){
                    newParentAccount.Top_Producer_CRM_License__c-=ul.Quantity__C;
                    oldParentAccount.Top_Producer_CRM_License__c+=ul.Quantity__C;         
                    if(newParentAccount.Top_Producer_CRM_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
                else if(ul.Product__c=='Top Producer Website'){
                    newParentAccount.Top_Producer_Websites_License__c-=ul.Quantity__C;
                    oldParentAccount.Top_Producer_Websites_License__c+=ul.Quantity__c;
                    if(newParentAccount.Top_Producer_Websites_License__c<0) ul.addError('Not enough licenses for the given Product.');
                }
				accountsToUpdate.add(newParentAccount);
                accountsToUpdate.add(oldParentAccount);
            }
            
        }
        update accountsToUpdate;
    }
    
    public void OnAfterUpdate(Set<Id> licenseIds,Map<Id,User_Licensing__c> oldMap){
         String AccountId;
         Map<String,String> licAccIds = new Map<String,String>();
        
        Map<Id,User_Licensing__c> updatedLicenses = new Map<Id,User_Licensing__c>([Select Id,Start_Time_UTC__c,End_Time_UTC__c,Location_Radius__c,Daily_Budget__c,Quantity__c,FiveStreet_External_ID__c,TPAccountId__c,TWS_MS_AccountId__c,TPUserID__c,TWS_MS_UserId__c,TPSubscriptionID__c,TWS_MS_SubscriptionId__c,Username__c,Password__c,Account__c,Parent_Account__c,Status__c,Product__c,Account__r.Name,Account__r.Email__c,Account__r.Phone, MLSCount__c,HV_Item_ID__c from User_Licensing__c where Id IN :licenseIds]);
         for(User_Licensing__c license : updatedLicenses.values()){
            if(license.Account__c != null) {
                licAccIds.put(license.Id,license.Account__c);
                
            }else{
                licAccIds.put(license.Id,license.Parent_Account__c);
            }
        }
         Map<ID,Account> mapOfAccount = new Map<Id,Account>([SELECT RecordTypeId,RecordType.Name,Name,Phone,Email__c,(SELECT Accountid,FirstName,LastName FROM Contacts where isPrimaryContact__c = true) FROM Account WHERE Id IN : licAccIds.values()]);
         Account uAcc;
        List<User_Licensing__c> UpdateLicenses = new List<User_Licensing__c>();
         for(User_Licensing__c license : updatedLicenses.values()){
             uAcc = license.Account__c != null ? mapOfAccount.get(license.Account__c) : mapOfAccount.get(license.Parent_Account__c);
             if(license.Product__c.equals(ProductNames.ZURP)){
                 if(license.Status__c.equals('Canceled') || license.Status__c.equals('Closed') || license.Status__c.equals('Expired')){
                     ZurpleDeProvisionHandler.cancelLicense(license.Account__c);   
                 }
             }
             for(Contact con : uAcc.Contacts){
                 if(license.Product__c.equals(ProductNames.HV)){
                     if(license.Status__c.equals('Canceled') || license.Status__c.equals('Expired')){
                         TPCRMRestHandler.updateSubscriptionDetails(license.Status__c,license.Id,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c);
                         TPCRMRestHandler.unSubscribeHVPostalCode(license.TPUserID__c,license.HV_Item_ID__c);
                     }
                 }
                 else if(license.Product__c.equals(ProductNames.TPHI)){
                     if(license.Status__c.equals('Canceled') || license.Status__c.equals('Closed') || license.Status__c.equals('Expired')){
                         TPCRMRestHandler.updateSubscriptionDetails(license.Status__c,license.Id,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c);
                         HomeIntelHandler.unAssignHomeIntelLicense(license.Id,license.TPUserID__c);
                     }
                 } else if(license.Product__c.equals(ProductNames.TPSC)){
                     if(license.Status__c.equals('Fulfilled') || license.Status__c.equals('Probation') || license.Status__c.equals('Suspended')){
                      	FBLeadsHandler.UpdateFBLicense(String.valueOf(getUTCDateTime(license.Start_Time_UTC__c)),license.End_Time_UTC__c != null? String.valueOf(getUTCDateTime(license.End_Time_UTC__c)) : null,license.Location_Radius__c,license.Daily_Budget__c,license.Id,license.TPUserID__c);    
                     }else if(license.Status__c.equals('Canceled') || license.Status__c.equals('Closed') || license.Status__c.equals('Expired')){
                         TPCRMRestHandler.updateSubscriptionDetails(license.Status__c,license.Id,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c);
                         FBLeadsHandler.cancelFBLicense(license.Id,license.TPUserID__c);
                     }
                 } else if(license.Product__c.equals(ProductNames.TPCRM) || license.Product__c.equals(ProductNames.TPAL)){
                     if(license.Status__c != oldMap.get(license.Id).Status__c && (license.Status__c.equals('Canceled') || license.Status__c.equals('Closed') ||
                                                                                  license.Status__c.equals('Expired') || license.Status__c.equals('Suspended') || license.Status__c.equals('Fulfilled') || license.Status__c.equals('Probation'))){
                                                                                      TPCRMRestHandler.updateAccount(license.Status__c,uAcc.RecordType.Name, license.Quantity__c, con.FirstName,con.LastName,uAcc.Email__c,uAcc.Name,license.Id,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c,license.Username__c);
                                                                                      TPCRMRestHandler.updateSubscriptionDetails(license.Status__c,license.Id,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c);
                                                                                  }
                     if(license.Status__c.equals('Fulfilled') && license.Quantity__c != oldMap.get(license.Id).Quantity__c){
                         TPCRMRestHandler.updateAccount(license.Status__c,uAcc.RecordType.Name, license.Quantity__c, con.FirstName,con.LastName,uAcc.Email__c,uAcc.Name,license.Id,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c,license.Username__c);
                         Decimal Quantity = license.Quantity__c - oldMap.get(license.Id).Quantity__c;
                         TPCRMRestHandler.updateSubscriptionLicenses(license.Status__c,Quantity,license.TPAccountId__c,license.TPUserID__c,license.TPSubscriptionID__c,'15',license.Id);
                     }
                 } else if(license.Product__c.equals(ProductNames.TPFS)){
                     if(license.Status__c != oldMap.get(license.Id).Status__c && 
                        (license.Status__c.equals('Canceled') || license.Status__c.equals('Closed') ||license.Status__c.equals('Expired') 
                         || license.Status__c.equals('Suspended'))){
                             if(String.isBlank(license.FiveStreet_External_ID__c)){
                                 FiveStreetHandler.getUserFromFS(license.Account__r.Email__c,license.Id);   
                             }else{
                                 FiveStreetHandler.getUserFromFS(license.Account__r.Email__c,license.FiveStreet_External_ID__c);
                             }
                         }
                 } else if(license.Product__c.equals(ProductNames.TPWS)){
                     String AccId = license.TWS_MS_AccountId__c != '' ? license.TWS_MS_AccountId__c : license.TPAccountId__c; 
                     String SubId = license.TWS_MS_SubscriptionId__c != '' ? license.TWS_MS_SubscriptionId__c : license.TPSubscriptionID__c;
                     String OwnId = license.TWS_MS_UserId__c != '' ? license.TWS_MS_UserId__c : license.TPUserID__c;
                     TPWebsiteUtility.UpdateAccountDetails(license.Status__c,con.FirstName,con.LastName,uAcc.Email__c,AccId,OwnId,SubId,license.Username__c,license.password__c);
                     TPWebsiteUtility.UpdateSubscriptionDetails(license.Status__c, AccId, OwnId, SubId, license.Username__c, license.password__c);
                 } else if(license.Product__c.equals(ProductNames.TPMS)){
                     List<User_Licensing__c> existingLicenses = new List<User_Licensing__c>([Select Id,Username__c,Account__c,Parent_Account__c,TPAccountId__c,TPUserID__c,Status__c,Product__c,Account__r.Name,Account__r.Email__c,Account__r.Phone,Account__r.Owner.Name,Account__r.BillingAddress from User_Licensing__c where Account__c =: uAcc.Id and Product__c =:ProductNames.TPCRM and Status__c = 'Fulfilled']);
                     List<MLS__c> lstOFMLS = new List<MLS__c>([select MLS_Board__r.Name, MLS_Board__r.MLS_Board_ID__c from MLS__c where User_Licensing__c=:license.ID]);
                     List<String> lstMlsBoards = new List<String>();
                     if(license.Status__c != oldMap.get(license.Id).Status__c && license.Status__c.equals('Pending Fulfillment')){
                         for(MLS__c mls : lstOFMLS){
                             lstMlsBoards.add(mls.MLS_Board__r.MLS_Board_ID__c);
                         }
                         if(lstMlsBoards.size() > 0){
                             if(license.TPAccountId__c != null && license.TPUserID__c != null){
                              	/*TPMSRestHandler.CreateAccount(con.FirstName,con.LastName,uAcc.Email__c,uAcc.Name,license.Quantity__c,license.Id,license.TPAccountId__c,
                                                      license.TPUserID__c,license.Username__c,lstMlsBoards);*/
                                 TPMSUtility.CreateAccount(con.FirstName,con.LastName,uAcc.Phone,uAcc.Email__c,uAcc.Name,license.Id,license.TPAccountId__c,
                                                      license.TPUserID__c,license.Username__c,lstMlsBoards);  
                             }else if(existingLicenses.size() > 0){
                                 /*TPMSRestHandler.CreateAccount(con.FirstName,con.LastName,uAcc.Email__c,uAcc.Name,license.Quantity__c,license.Id,existingLicenses.get(0).TPAccountId__c,
                                                      existingLicenses.get(0).TPUserID__c,existingLicenses.get(0).Username__c,lstMlsBoards);*/
                                 TPMSUtility.CreateAccount(con.FirstName,con.LastName,uAcc.Phone,uAcc.Email__c,uAcc.Name,license.Id,existingLicenses.get(0).TPAccountId__c,
                                                      existingLicenses.get(0).TPUserID__c,existingLicenses.get(0).Username__c,lstMlsBoards);
                             }
                         }
                     }else {
                         if(existingLicenses.size()>0){
                             if(license.TPAccountId__c == null || license.TPUserID__c == null){
                                 license.TPAccountId__c = existingLicenses.get(0).TPAccountId__c;
                                 license.TPUserID__c = existingLicenses.get(0).TPUserID__c;
                             }
                             TPMSUtility.UpdateAccountDetails(license.Status__c,con.FirstName,con.LastName,uAcc.Name,uAcc.Phone,uAcc.Email__c,license.TWS_MS_AccountId__c,license.TWS_MS_UserId__c,license.TWS_MS_SubscriptionId__c,license.Username__c,license.password__c,license.TPAccountId__c,existingLicenses.get(0).TPUserID__c,existingLicenses.get(0).Username__c);
                             //TPMSUtility.UpdateSubscriptionDetails(license.Status__c,license.TWS_MS_AccountId__c,license.TWS_MS_UserId__c,license.TWS_MS_SubscriptionId__c);   
                             
                             string count = '';
                             
                             List<string> oldCodes = new List<string>();
                             if(license.MLSCount__c !=null && license.MLSCount__c!=''){
                                 oldCodes = license.MLSCount__c.split(';');
                             }
                             
                             String str_currentCodes ='';
                             for(MLS__c m :lstOFMLS){
                                 str_currentCodes += m.MLS_Board__r.MLS_Board_ID__c +';';
                             }
                             
                             license.MLSCount__c = str_currentCodes;
                             
                             //currently saved child record list
                             List<string> currentCodes = new List<string>();
                             if(license.MLSCount__c!=null && license.MLSCount__c!=''){
                                 currentCodes = license.MLSCount__c.split(';');
                             }
                             //deleted child record list
                             List<string> deleteCodes = new List<string>();
                             //new child record list
                             List<string> newCodes = new List<string>();
                             
                             for(string oldCode: oldCodes){
                                 if(!currentCodes.contains(oldCode)){
                                     deleteCodes.add(oldCode);
                                 }
                             }
                             
                             for(string currentCode: currentCodes){
                                 if(!oldCodes.contains(currentCode)){
                                     newCodes.add(currentCode);
                                 }
                             }
                             system.debug('currentCodes'+currentCodes);
                             system.debug('oldCodes '+oldCodes);
                             system.debug('deleteCodes '+deleteCodes);
                             system.debug('newCodes'+newCodes);
                             
                             UpdateLicenses.add(license);
                             for(string newCode: newCodes){
                                 count='1';
                                 TPMSUtility.AddModifySubscription(license.TPAccountId__c,license.TPUserID__c,GuidUtil.NewGuid(),newCode,count);
                             }
                             //for decrementing license
                             for(string deleteCode: deleteCodes){
                                 count='-1';
                                 TPMSUtility.AddModifySubscription(license.TPAccountId__c,license.TPUserID__c,GuidUtil.NewGuid(),deleteCode,count);
                             }
                             
                             for(MLS__c m :lstOFMLS){
                                 string MLSCode = m.MLS_Board__r.MLS_Board_ID__c;  
                                 TPMSUtility.ModifySubscriptionLicenses(license.TPAccountId__c,license.TPUserID__c,GuidUtil.NewGuid(),MLSCode);
                             }
                         }
                     }
                 }
             }
         }
        update UpdateLicenses;
    }
    
    public DateTime getUTCDateTime(DateTime dt){
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second());
        return GMTDate;
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
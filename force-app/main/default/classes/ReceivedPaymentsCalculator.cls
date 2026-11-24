public class ReceivedPaymentsCalculator implements ICalculate{
    
	private static ReceivedPaymentsCalculator instance = null;
    
    private ReceivedPaymentsCalculator(){
    }  
    
    // Making sure Class is Singlton    
    public static ReceivedPaymentsCalculator getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null)
        {
            instance = new ReceivedPaymentsCalculator();
        }
        return instance;
    } 
    
    public void Calculate(List<sObject> lRecords){
        List<blng__Invoice__c> records = (List<blng__Invoice__c>) lRecords;
        Set<Id> setOrderIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        for(blng__Invoice__c invoice : records){
            if(invoice.blng__Order__c != null){
             	setOrderIds.add(invoice.blng__Order__c);
            }
            if(invoice.blng__Account__c != null){
                setAccountIds.add(invoice.blng__Account__c);
            }
        }
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select Id, User_Licensing_Status__c,Account_Sub_Type__c from Account where Id In : setAccountIds]);
        Map<Id,Order> mapOrders = new Map<Id,Order>([Select Id,Overdue_Invoice_Flag__c,Overdue_Invoice_Count__c from Order where Id IN : setOrderIds]);
        List<blng__Invoice__c> lstInvoiceToBeUpdated = new List<blng__Invoice__c>();
        Map<Id,Decimal> mapOrderOverdueInvoices = new Map<Id,Decimal>();
        Map<Id,Integer> mapAccountStatus = new Map<Id,Integer>();
        Integer status = 0;
        for(blng__Invoice__c invoice : records){
            if(invoice.blng__Order__c == null){
                continue;
            }
            if(invoice.blng__PaymentStatus__c == 'Paid' && invoice.blng__Balance__c == 0 && invoice.Aging_Invoice__c == true){
                invoice.Aging_Invoice__c = false;
                lstInvoiceToBeUpdated.add(invoice);
                if(mapOrderOverdueInvoices.containsKey(invoice.blng__Order__c)){
                    if(mapOrderOverdueInvoices.get(invoice.blng__Order__c) > 0){
                        mapOrderOverdueInvoices.put(invoice.blng__Order__c,mapOrderOverdueInvoices.get(invoice.blng__Order__c) - 1);
                    }
                }
                else{
                    if(mapOrders.containsKey(invoice.blng__Order__c) && mapOrders.get(invoice.blng__Order__c).Overdue_Invoice_Count__c != null && 
                       mapOrders.get(invoice.blng__Order__c).Overdue_Invoice_Count__c != 0){
                           mapOrderOverdueInvoices.put(invoice.blng__Order__c, mapOrders.get(invoice.blng__Order__c).Overdue_Invoice_Count__c - 1);
                       }else{
                           mapOrderOverdueInvoices.put(invoice.blng__Order__c, 0);   
                       }
                }
                status = 0;
                if(mapAccountStatus.containsKey(invoice.blng__Account__c)){
                    if(mapAccountStatus.get(invoice.blng__Account__c) < status){
                        mapAccountStatus.put(invoice.blng__Account__c, status);
                    }
                }else{
                    mapAccountStatus.put(invoice.blng__Account__c, status);
                }
                
            }else if(invoice.blng__Account__r.User_Licensing_Status__c != 'Closed'){
                if(invoice.blng__DueDate__c != null && invoice.blng__DueDate__c + 1 <= System.today()){
                    if(invoice.blng__DueDate__c + 1 <= System.today() && invoice.blng__DueDate__c + 15 >= System.today()){
                        status = 1;
                    }else if(invoice.blng__DueDate__c + 16 <= System.today() && invoice.blng__DueDate__c + 30 >= System.today()){
                        status = 2;
                    }else if(invoice.blng__DueDate__c + 31 <= System.today()){
                        status = 3;
                    }
                    System.debug('status: ' + status);
                    if(mapAccountStatus.containsKey(invoice.blng__Account__c)){
                        //mapAccountStatus.put(invoice.blng__Account__c, status);
                        System.debug('existing Status: ' + mapAccountStatus.get(invoice.blng__Account__c));
                        if(mapAccountStatus.get(invoice.blng__Account__c) < status){
                            mapAccountStatus.put(invoice.blng__Account__c, status);
                        }
                    }else{
                        mapAccountStatus.put(invoice.blng__Account__c, status);
                    }
                }
            }
        }
        
        if(mapAccountStatus.size() > 0){
            Integer openStatus;
            for(blng__Invoice__c openInv : [Select Id, blng__Account__c, blng__DueDate__c from blng__Invoice__c 
                                            where blng__Account__c IN :mapAccountStatus.keySet() 
                                            and blng__Order__c != null 
                                            and blng__DueDate__c < TODAY 
                                            and (blng__PaymentStatus__c != 'Paid' OR blng__Balance__c != 0)]){
                openStatus = 0;
                if(openInv.blng__DueDate__c + 1 <= System.today() && openInv.blng__DueDate__c + 15 >= System.today()){
                    openStatus = 1;
                }else if(openInv.blng__DueDate__c + 16 <= System.today() && openInv.blng__DueDate__c + 30 >= System.today()){
                    openStatus = 2;
                }else if(openInv.blng__DueDate__c + 31 <= System.today()){
                    openStatus = 3;
                }
                if(mapAccountStatus.get(openInv.blng__Account__c) < openStatus){
                    mapAccountStatus.put(openInv.blng__Account__c, openStatus);
                }
            }
        }
        
        List<Order> lstOrderToBeUpdated = new List<Order>();
        Order tempOrder;
        for(Id orderId : mapOrderOverdueInvoices.keySet()){
            tempOrder = mapOrders.get(orderId);
            tempOrder.Overdue_Invoice_Count__c = mapOrderOverdueInvoices.get(orderId);
            if(tempOrder.Overdue_Invoice_Count__c == 0){
             	tempOrder.Overdue_Invoice_Flag__c = false;   
            }
            lstOrderToBeUpdated.add(tempOrder);
        }
        if(lstOrderToBeUpdated.size() > 0){
            update lstOrderToBeUpdated;
        }
        if(lstInvoiceToBeUpdated.size() > 0){
            update lstInvoiceToBeUpdated;
        }
        
        List<Account> lstAccountsToBeUpdated = new List<Account>();
        List<Id> updatedAccountIds = new List<Id>();
        Map<Integer,String> mapULStatus = new Map<Integer,String>{0 => 'Fulfilled', 1 => 'Probation', 2 => 'Suspended', 3 => 'Closed'};
        Account tempAccount;
        for(Id accountId : mapAccountStatus.KeySet()){
            // Closed accounts stay Closed until every overdue invoice is paid
            if(mapAccounts.get(accountId).User_Licensing_Status__c == 'Closed' && mapAccountStatus.get(accountId) != 0){
                continue;
            }
            if(mapAccounts.get(accountId).User_Licensing_Status__c != mapULStatus.get(mapAccountStatus.get(accountId)) && mapAccounts.get(accountId).Account_Sub_Type__c != 'VIP'){
                tempAccount = mapAccounts.get(accountId);
                tempAccount.User_Licensing_Status__c = mapULStatus.get(mapAccountStatus.get(accountId));
                //tempAccount.Cascade_Status__c = true;
                lstAccountsToBeUpdated.add(tempAccount);
                updatedAccountIds.add(accountId);
            }
        }
        
        if(lstAccountsToBeUpdated.size() > 0){
            update lstAccountsToBeUpdated;
        }
        System.debug('updatedAccountIds: ' + updatedAccountIds);
        if(updatedAccountIds.size() > 0){
            List<String> lstAllowedStatuses = new List<String>{'Suspended','Probation','Fulfilled','Closed'};
            List<User_Licensing__c> lstUserLicensing = [Select Id, Name,Account__r.User_Licensing_Status__c, Account__c,Status__c from User_Licensing__c where Account__c IN :updatedAccountIds and Status__c IN :lstAllowedStatuses];
            System.debug('lstUserLicensing: ' + lstUserLicensing.size());
            UpdateUserLicencesJob ulJob = new UpdateUserLicencesJob(lstUserLicensing);
            ID jobID=System.enqueueJob(ulJob);
            //UpdateUserLicensingWS.updateUserLicenseRecords(updatedAccountIds);
        }
        
        Set<Id> setAccIdForCollectionCases = new Set<Id>();
        for(Account acc : lstAccountsToBeUpdated){
            if(acc.User_Licensing_Status__c == 'Fulfilled'){
                setAccIdForCollectionCases.add(acc.Id);
            }
        }
        if(!setAccIdForCollectionCases.isEmpty()){
            List<Case> lstCases = [Select Id, Status, Outcome__c from Case Where AccountId IN :setAccIdForCollectionCases AND Type = 'Billing' AND Area__c = 'Collections' AND Status != 'Closed'];
            for(Case sCase :  lstCases){
                if(sCase.Outcome__c == null){
                    sCase.Outcome__c = 'Closed by System';
                }
                sCase.Status = 'Closed';
            }
            if(lstCases !=null && lstCases.size() > 0){
                update lstCases;
            }
        }
    } 
    
    public string Name()
    {
        return 'Received Payment Calculator to count the received payments';
    }
}
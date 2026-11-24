public class MissedPaymentsCalculator implements ICalculate{
    
    private static MissedPaymentsCalculator instance = null;
    
    private MissedPaymentsCalculator(){
    }  
    
    // Making sure Class is Singlton    
    public static MissedPaymentsCalculator getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null)
        {
            instance = new MissedPaymentsCalculator();
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
        Integer status=0;
        for(blng__Invoice__c invoice : records){
            if(invoice.blng__Order__c == null){
                continue;
            }
            if(invoice.blng__DueDate__c != null && invoice.blng__DueDate__c + 1 <= System.today()){
                status=0;
                invoice.Aging_Invoice__c = true;
                lstInvoiceToBeUpdated.add(invoice);
                if(invoice.blng__DueDate__c + 1 <= System.today() && invoice.blng__DueDate__c + 15 >= System.today()){
                    status = 1;
                }else if(invoice.blng__DueDate__c + 16 <= System.today() && invoice.blng__DueDate__c + 30 >= System.today()){
                    status = 2;
                }else if(invoice.blng__DueDate__c + 31 <= System.today()){
                    status = 3;
                }
                
                if(mapAccountStatus.containsKey(invoice.blng__Account__c)){
                    if(mapAccountStatus.get(invoice.blng__Account__c) < status){
                        mapAccountStatus.put(invoice.blng__Account__c, status);
                    }
                }else{
                    mapAccountStatus.put(invoice.blng__Account__c, status);
                }
                
                if(mapOrderOverdueInvoices.containsKey(invoice.blng__Order__c)){
                    mapOrderOverdueInvoices.put(invoice.blng__Order__c,mapOrderOverdueInvoices.get(invoice.blng__Order__c) + 1);
                }else{
                    if(mapOrders.containsKey(invoice.blng__Order__c) && mapOrders.get(invoice.blng__Order__c).Overdue_Invoice_Count__c != null && 
                       mapOrders.get(invoice.blng__Order__c).Overdue_Invoice_Count__c != 0){
                           mapOrderOverdueInvoices.put(invoice.blng__Order__c, mapOrders.get(invoice.blng__Order__c).Overdue_Invoice_Count__c + 1);
                       }else{
                           mapOrderOverdueInvoices.put(invoice.blng__Order__c, 1);   
                       }
                }
            }
        }
        List<Order> lstOrderToBeUpdated = new List<Order>();
        Order tempOrder;
        for(Id orderId : mapOrderOverdueInvoices.keySet()){
            tempOrder = mapOrders.get(orderId);
            tempOrder.Overdue_Invoice_Count__c = mapOrderOverdueInvoices.get(orderId);
            tempOrder.Overdue_Invoice_Flag__c = true;
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
        Map<Integer,String> mapULStatus = new Map<Integer,String>{1 => 'Probation', 2 => 'Suspended', 3 => 'Closed'};
        Map<String,Integer> mapStatusRank = new Map<String,Integer>{'Probation' => 1, 'Suspended' => 2, 'Closed' => 3};
        Account tempAccount;
        for(Id accountId : mapAccountStatus.KeySet()){
            Integer currentRank = mapStatusRank.containsKey(mapAccounts.get(accountId).User_Licensing_Status__c) ? mapStatusRank.get(mapAccounts.get(accountId).User_Licensing_Status__c) : 0;
            if(mapAccountStatus.get(accountId) > currentRank && mapAccounts.get(accountId).Account_Sub_Type__c != 'VIP'){
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
        
    }
    
    public string Name()
    {
        return 'Missed Payment Calculator to count the missed payments';
    }
}
public class UnlockInvoicesCalculator implements ICalculate{
    
    private static UnlockInvoicesCalculator instance = null;
    
    private UnlockInvoicesCalculator(){
    }  
    
    // Making sure Class is Singlton    
    public static UnlockInvoicesCalculator getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null)
        {
            instance = new UnlockInvoicesCalculator();
        }
        return instance;
    } 
    
    public void Calculate(List<sObject> lRecords){
        List<blng__Invoice__c> records = (List<blng__Invoice__c>) lRecords;
        for(blng__Invoice__c inv : records){
            inv.blng__LastPaymentRunProcessingMessage__c = '';
            inv.blng__CorrectiveAction__c = null;
        }
        blng__BillingConfig__c blngConfig = blng__BillingConfig__c.getInstance('DISABLE_TRIGGERS');
        if(blngConfig != null){
            blngConfig.blng__BooleanValue__c = true;
            update blngConfig;
            try {
                update records;
            }catch (DmlException e) {
                System.debug('An error occurred while updating the record: ' + e.getMessage());
            }
            blngConfig.blng__BooleanValue__c = false;
            update blngConfig;
        }
    }
    
    public string Name()
    {
        return 'Unlock Invoices Calculator to unlock the locked invoices';
    }
}
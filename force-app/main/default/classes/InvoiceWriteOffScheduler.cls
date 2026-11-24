global without sharing class InvoiceWriteOffScheduler implements Schedulable{
    global void execute(SchedulableContext sc)
    {      
        List<blng__Invoice__c> invoices = [
            SELECT Id 
            FROM blng__Invoice__c 
            WHERE blng__PaymentBatch__c = 'Batch 5' 
            AND blng__Balance__c > 0 
            AND blng__DueDate__c = THIS_YEAR  
            AND blng__InvoiceStatus__c = 'Posted'
            AND Written_Off__c = false
            AND blng__Account__r.Do_not_Write_off__c = false
            AND Days_Outstanding__c > 30
            LIMIT 500
        ];
        Set<Id> invoiceIds = new Set<Id>();
        for (blng__Invoice__c inv : invoices) {
            invoiceIds.add(inv.Id);
        }
        InvoiceWriteOffService.writeOffInvoicesAsync(invoiceIds);
    }
}
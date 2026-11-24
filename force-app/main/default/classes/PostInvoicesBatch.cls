// PostInvoicesBatch.cls
global class PostInvoicesBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            Select Id, name, CreatedDate, blng__InvoiceStatus__c 
            from blng__Invoice__c where blng__DueDate__c = TODAY 
            and RecordType.Name = 'Top Producer' 
            and blng__InvoiceStatus__c !='Posted' 
        ]);
    }

    global void execute(Database.BatchableContext bc, List<blng__Invoice__c> scope) {

        List<blng__Invoice__c> updates = new List<blng__Invoice__c>();

        for (blng__Invoice__c inv : scope) {
            inv.blng__InvoiceStatus__c = 'Posted';
            updates.add(inv);
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Invoice posting batch completed.');
    }
}
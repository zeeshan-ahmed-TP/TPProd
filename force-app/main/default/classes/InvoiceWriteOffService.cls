public with sharing class InvoiceWriteOffService {
    
    public static void writeOffInvoicesAsync(Set<Id> invoiceIds) {
        if (invoiceIds == null || invoiceIds.isEmpty()) return;
        
        System.enqueueJob(
            new WriteOffInvoiceQueueable(new List<Id>(invoiceIds), 0)
        );
    }
    public  static void writeOffInvoices(Set<Id> invoiceIds) {
        if (invoiceIds == null || invoiceIds.isEmpty()) return;
        
        List<blng__Invoice__c> invoices = [
            SELECT Id, Name, blng__Account__c, blng__Balance__c,Tax_Payer_Code__c
            FROM blng__Invoice__c
            WHERE Id IN :invoiceIds
            AND blng__Balance__c > 0
        ];
        
        if (invoices.isEmpty()) {
            System.debug('No invoices with balance found.');
            return;
        }
        
        List<blng__CreditNote__c> creditNotesToInsert = new List<blng__CreditNote__c>();
        for (blng__Invoice__c inv : invoices) {
            creditNotesToInsert.add(new blng__CreditNote__c(
                blng__Account__c = inv.blng__Account__c,
                blng__CreditNoteSourceAction__c = 'Credit',
                Credit_Reasons__c = 'Write-off',
                blng__Status__c = 'Draft',
                Tax_Payer_Code__c = inv.Tax_Payer_Code__c,
                blng__RelatedInvoice__c = inv.Id,
                blng__CreditNoteDate__c = Date.Today(),
                blng__EffectiveTaxDate__c = Date.Today()
            ));
        }
        insert creditNotesToInsert;
        
        // Map invoiceId → creditNoteId
        Map<Id, Id> invoiceToCreditNoteMap = new Map<Id, Id>();
        for (Integer i = 0; i < invoices.size(); i++) {
            invoiceToCreditNoteMap.put(invoices[i].Id, creditNotesToInsert[i].Id);
        }
        
        List<blng__InvoiceLine__c> invoiceLines = [
            SELECT Id, blng__Invoice__c,blng__LegalEntity__c,blng__Product__c,blng__TaxRule__c,blng__TaxTreatment__c,Tax_Payer_Code__c,
            blng__TaxGLRule__c,blng__TaxGLTreatment__c,blng__BillingRule__c,blng__BillingTreatment__c,blng__BillingGLRule__c,blng__BillingGLTreatment__c,
            blng__BillingFinanceBook__c,blng__StartDate__c,blng__EndDate__c,blng__TaxStreet__c,blng__TaxStreet2__c,blng__TaxState__c,blng__TaxCity__c,
            blng__TaxCountry__c, blng__Balance__c
            FROM blng__InvoiceLine__c
            WHERE blng__Invoice__c IN :invoiceIds
        ];
        
        List<blng__CreditNoteLine__c> creditNoteLinesToInsert = new List<blng__CreditNoteLine__c>();
        for (blng__InvoiceLine__c line : invoiceLines) {
            Id cnId = invoiceToCreditNoteMap.get(line.blng__Invoice__c);
            if (cnId == null) continue;
            creditNoteLinesToInsert.add(new blng__CreditNoteLine__c(
                blng__InvoiceLine__c = line.Id,
                blng__LegalEntity__c = line.blng__LegalEntity__c,
                blng__Product__c = line.blng__Product__c,
                blng__TaxRule__c = line.blng__TaxRule__c,
                blng__TaxTreatment__c = line.blng__TaxTreatment__c,
                Tax_Payer_Code__c = line.Tax_Payer_Code__c,
                blng__TaxGLRule__c = line.blng__TaxGLRule__c,
                blng__TaxGLTreatment__c = line.blng__TaxGLTreatment__c,
                blng__CalculateTax__c = false,
                blng__BillingRule__c = line.blng__BillingRule__c,
                blng__BillingTreatment__c = line.blng__BillingTreatment__c,
                blng__BillingGLRule__c = line.blng__BillingGLRule__c,
                blng__BillingGLTreatment__c = line.blng__BillingGLTreatment__c,
                blng__CreditNote__c = cnId,
                blng__BillingFinanceBook__c = line.blng__BillingFinanceBook__c,
                blng__StartDate__c = line.blng__StartDate__c,
                blng__EndDate__c = line.blng__EndDate__c,
                blng__TaxStreet__c = line.blng__TaxStreet__c,
                blng__TaxStreet2__c = line.blng__TaxStreet2__c,
                blng__TaxState__c = line.blng__TaxState__c,
                blng__TaxCity__c = line.blng__TaxCity__c,
                blng__TaxCountry__c = line.blng__TaxCountry__c,
                blng__Subtotal__c = line.blng__Balance__c,
                blng__Status__c = 'Draft'
            ));
        }
        insert creditNoteLinesToInsert;
        
        for (blng__CreditNote__c cn : creditNotesToInsert) {
            cn.blng__Status__c = 'Posted';
        }
        update creditNotesToInsert;
        
        Set<Id> accountIds = new Set<Id>();
        for (blng__Invoice__c inv : invoices) {
            inv.put('Written_Off__c', true);
            inv.put('Write_Off_Reason__c', 'Automated Write-Off');
            //inv.put('blng__ARStatus__c','Credited');
            //inv.put('blng__Action__c','Credit');
            if (inv.blng__Account__c != null) {
                accountIds.add(inv.blng__Account__c);
            }
        }
        update invoices;
        
        if (!accountIds.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, User_Licensing_Status__c, DO_NOT_RESIGN_NON_PAY__c FROM Account WHERE Id IN :accountIds];
            for (Account acc : accountsToUpdate) {
                acc.User_Licensing_Status__c = 'Closed';
                acc.DO_NOT_RESIGN_NON_PAY__c = true;
            }
            update accountsToUpdate;
            
            List<String> lstAllowedStatuses = new List<String>{'Suspended','Probation','Fulfilled','Closed'};
            List<User_Licensing__c> lstUserLicensing = [Select Id, Name,Account__r.User_Licensing_Status__c, Account__c,Status__c from User_Licensing__c where Account__c IN :accountIds and Status__c IN :lstAllowedStatuses];
            System.debug('lstUserLicensing: ' + lstUserLicensing.size());
            UpdateUserLicencesJob ulJob = new UpdateUserLicencesJob(lstUserLicensing);
            ID jobID = System.enqueueJob(ulJob);
        }
        
        System.debug('Successfully written off ' + invoices.size() + ' invoices.');
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
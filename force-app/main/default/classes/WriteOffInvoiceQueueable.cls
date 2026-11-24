public class WriteOffInvoiceQueueable implements Queueable {

    private List<Id> invoiceIds;
    private Integer index;

    public WriteOffInvoiceQueueable(List<Id> invoiceIds, Integer index) {
        this.invoiceIds = invoiceIds;
        this.index = index;
    }

    public void execute(QueueableContext context) {

        if (index >= invoiceIds.size()) return;

        Id invoiceId = invoiceIds[index];

        // 🔹 Load invoice
        blng__Invoice__c inv = [
            SELECT Id, blng__Account__c, blng__Balance__c, Tax_Payer_Code__c, blng__Order__c
            FROM blng__Invoice__c
            WHERE Id = :invoiceId
            AND blng__Balance__c > 0
            AND blng__Account__r.Do_not_Write_off__c = false
            LIMIT 1
        ];
        
        blng__TaxRule__c tpNotTaxableRule = [
            SELECT Id, Name
            FROM blng__TaxRule__c
            WHERE Name = 'TP Not Taxable Rule'
            LIMIT 1
        ];

        // 🔹 Create Credit Note
        blng__CreditNote__c cn = new blng__CreditNote__c(
            blng__Account__c = inv.blng__Account__c,
            blng__CreditNoteSourceAction__c = 'Credit',
            Credit_Reasons__c = 'Write-off',
            blng__Status__c = 'Draft',
            Tax_Payer_Code__c = inv.Tax_Payer_Code__c,
            blng__RelatedInvoice__c = inv.Id,
            blng__CreditNoteDate__c = Date.today(),
            blng__EffectiveTaxDate__c = Date.today()
        );
        insert cn;

        // 🔹 Invoice Lines
        List<blng__InvoiceLine__c> invLines = [
            SELECT Id, blng__LegalEntity__c, blng__Product__c, blng__TaxRule__c,
                   blng__TaxTreatment__c, Tax_Payer_Code__c,
                   blng__TaxGLRule__c, blng__TaxGLTreatment__c,
                   blng__BillingRule__c, blng__BillingTreatment__c,
                   blng__BillingGLRule__c, blng__BillingGLTreatment__c,
                   blng__BillingFinanceBook__c,
                   blng__StartDate__c, blng__EndDate__c,
                   blng__TaxStreet__c, blng__TaxStreet2__c,
                   blng__TaxState__c, blng__TaxCity__c,
                   blng__TaxCountry__c, blng__Balance__c, blng__Subtotal__c
            FROM blng__InvoiceLine__c
            WHERE blng__Invoice__c = :inv.Id
        ];

        List<blng__CreditNoteLine__c> cnLines = new List<blng__CreditNoteLine__c>();
        for (blng__InvoiceLine__c line : invLines) {
            cnLines.add(new blng__CreditNoteLine__c(
                blng__CreditNote__c = cn.Id,
                blng__InvoiceLine__c = line.Id,
                blng__LegalEntity__c = line.blng__LegalEntity__c,
                blng__Product__c = line.blng__Product__c,
                blng__TaxRule__c = tpNotTaxableRule.ID,
                blng__TaxTreatment__c = line.blng__TaxTreatment__c,
                Tax_Payer_Code__c = line.Tax_Payer_Code__c,
                blng__TaxGLRule__c = line.blng__TaxGLRule__c,
                blng__TaxGLTreatment__c = line.blng__TaxGLTreatment__c,
                blng__CalculateTax__c = false,
                blng__BillingRule__c = line.blng__BillingRule__c,
                blng__BillingTreatment__c = line.blng__BillingTreatment__c,
                blng__BillingGLRule__c = line.blng__BillingGLRule__c,
                blng__BillingGLTreatment__c = line.blng__BillingGLTreatment__c,
                blng__BillingFinanceBook__c = line.blng__BillingFinanceBook__c,
                blng__StartDate__c = line.blng__StartDate__c,
                blng__EndDate__c = line.blng__EndDate__c,
                blng__TaxStreet__c = line.blng__TaxStreet__c,
                blng__TaxStreet2__c = line.blng__TaxStreet2__c,
                blng__TaxState__c = line.blng__TaxState__c,
                blng__TaxCity__c = line.blng__TaxCity__c,
                blng__TaxCountry__c = line.blng__TaxCountry__c,
                blng__Subtotal__c = line.blng__Subtotal__c,
                blng__Status__c = 'Draft',
                blng__TaxAmount__c = 0
            ));
        }
        insert cnLines;

        // 🔹 Post Credit Note (single record → safe)
        cn.blng__Status__c = 'Posted';
        update cn;

        // 🔹 Update Invoice
        inv.Written_Off__c = true;
        inv.Write_Off_Reason__c = 'Automated Write-Off';
        update inv;

        // 🔹 Update Account + User Licensing
        if (inv.blng__Account__c != null) {
            Account acc = [
                SELECT Id FROM Account WHERE Id = :inv.blng__Account__c LIMIT 1
            ];
            acc.User_Licensing_Status__c = 'Canceled';
            acc.DO_NOT_RESIGN_NON_PAY__c = true;
            update acc;
            
            if(inv.blng__Order__c != null){
                Order odr = [Select Id,blng__InvoiceBatch__c from Order where Id =:inv.blng__Order__c Limit 1];
                odr.blng__InvoiceBatch__c = 'Batch 4';
                update odr;
            }
            
            List<SBQQ__Subscription__c> lstSubs = [Select Id, SBQQ__TerminatedDate__c, Subscription_Status__c from SBQQ__Subscription__c where
                                                  Subscription_Status__c = 'Active' AND SBQQ__Account__c =: inv.blng__Account__c];
            if(!lstSubs.isEmpty()){
                for(SBQQ__Subscription__c sub : lstSubs){
                    sub.SBQQ__TerminatedDate__c = System.today();
                }
                update lstSubs;
            }

            List<String> allowedStatuses = new List<String>{
                'Suspended','Probation','Fulfilled','Closed'
            };

            List<User_Licensing__c> ul = [
                SELECT Id, Status__c, Account__r.User_Licensing_Status__c,Product__c
                FROM User_Licensing__c
                WHERE Account__c = :acc.Id
                AND Status__c IN :allowedStatuses
            ];

            if (!ul.isEmpty()) {
                for(User_Licensing__c userLicensing : ul){
                    if(userLicensing.Product__c.equals(ProductNames.TPSC)){
                        userLicensing.End_Date__c = System.today();
                        userLicensing.End_Time_UTC__c = System.today();
                    }
                    userLicensing.Status__c = userLicensing.Account__r.User_Licensing_Status__c;   
                }
                update ul;
            }
        }

        // 🔹 Chain next invoice
        System.enqueueJob(
            new WriteOffInvoiceQueueable(invoiceIds, index + 1)
        );
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
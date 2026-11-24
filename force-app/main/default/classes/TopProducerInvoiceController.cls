public class TopProducerInvoiceController {

    public blng__Invoice__c invoice { get; private set; }
    public List<blng__InvoiceLine__c> invoiceLines { get; private set; }

    public TopProducerInvoiceController() {
        Id invoiceId = (Id) ApexPages.currentPage().getParameters().get('id');
        
        if (invoiceId == null) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'No Invoice Id provided in the URL.'));
            return;
        }
        invoice = [
            SELECT
                Id,
                Name,
                blng__InvoiceDate__c,
                blng__DueDate__c,
                Payment_Term__c,
            	Shipping_Country__c,
                blng__BillToContact__r.Name,
                blng__BillToContact__r.MailingStreet,
                blng__BillToContact__r.MailingCity,
                blng__BillToContact__r.MailingState,
                blng__BillToContact__r.MailingPostalCode,
                blng__Account__r.Name,
                blng__Account__r.BillingStreet,
                blng__Account__r.BillingCity,
                blng__Account__r.BillingState,
                blng__Account__r.BillingPostalCode,
                blng__TotalAmount__c,
                blng__TaxAmount__c,
                blng__Subtotal__c,
            	Record_Type__c
            FROM blng__Invoice__c
            WHERE Id = :invoiceId
            LIMIT 1
        ];

        invoiceLines = [
            SELECT
                Id,
                Name,
                blng__Product__r.Name,
                blng__Quantity__c,
                blng__UnitPrice__c,
                blng__TotalAmount__c
            FROM blng__InvoiceLine__c
            WHERE blng__Invoice__c = :invoiceId
            ORDER BY CreatedDate ASC
        ];
        ApexPages.currentPage().getHeaders().put(
    'Content-Disposition',
    'attachment; filename="' + getPdfFileName() + '.pdf"'
);
    }

    /* ── Billing address helper ──
       Prefers Contact mailing address; falls back to Account billing address */
    public String getBillToName() {
        if (invoice.blng__BillToContact__c != null) {
            return invoice.blng__BillToContact__r.Name;
        }
        return invoice.blng__Account__r.Name;
    }
    
    public String getPdfFileName(){
        Date invDate = invoice.blng__InvoiceDate__c;
        return 'Invoice For ' + getBillToName() + ' - ' + String.valueOf(invDate);
    }

    public String getBillToStreet() {
        if (invoice.blng__BillToContact__c != null) {
            return invoice.blng__BillToContact__r.MailingStreet;
        }
        return invoice.blng__Account__r.BillingStreet;
    }

    public String getBillToCity() {
        if (invoice.blng__BillToContact__c != null) {
            return invoice.blng__BillToContact__r.MailingCity;
        }
        return invoice.blng__Account__r.BillingCity;
    }

    public String getBillToState() {
        if (invoice.blng__BillToContact__c != null) {
            return invoice.blng__BillToContact__r.MailingState;
        }
        return invoice.blng__Account__r.BillingState;
    }

    public String getBillToPostalCode() {
        if (invoice.blng__BillToContact__c != null) {
            return invoice.blng__BillToContact__r.MailingPostalCode;
        }
        return invoice.blng__Account__r.BillingPostalCode;
    }
}
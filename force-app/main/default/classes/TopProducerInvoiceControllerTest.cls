@IsTest
private class TopProducerInvoiceControllerTest {

    @TestSetup
    static void setupData() {

        Account acc = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Lahore',
            BillingState = 'Punjab',
            BillingPostalCode = '54000'
        );
        insert acc;

        Contact con = new Contact(
            LastName = 'Ahmed',
            AccountId = acc.Id,
            MailingStreet = '456 Contact St',
            MailingCity = 'Islamabad',
            MailingState = 'ICT',
            MailingPostalCode = '44000'
        );
        insert con;

        blng__Invoice__c inv = new blng__Invoice__c(
            blng__Account__c = acc.Id,
            blng__BillToContact__c = con.Id,
            blng__InvoiceDate__c = Date.today()
        );
        insert inv;

        blng__InvoiceLine__c line = new blng__InvoiceLine__c(
            blng__Invoice__c = inv.Id,
            blng__Quantity__c = 2,
            blng__UnitPrice__c = 100
        );
        insert line;
    }

    @IsTest
    static void testControllerWithInvoiceId() {

        blng__Invoice__c inv = [
            SELECT Id, blng__InvoiceDate__c
            FROM blng__Invoice__c
            LIMIT 1
        ];

        Test.setCurrentPage(Page.GenerateInvoiceVF);
        ApexPages.currentPage().getParameters().put('id', inv.Id);

        Test.startTest();
        TopProducerInvoiceController controller =
            new TopProducerInvoiceController();
        Test.stopTest();

        System.assertNotEquals(null, controller.invoice);
        System.assertEquals(inv.Id, controller.invoice.Id);

        System.assertEquals(
            1,
            controller.invoiceLines.size()
        );

        System.assert(
            controller.getBillToName().contains('Ahmed')
        );

        System.assert(
            controller.getPdfFileName().contains('Invoice For')
        );

        System.assertEquals(
            '456 Contact St',
            controller.getBillToStreet()
        );

        System.assertEquals(
            'Islamabad',
            controller.getBillToCity()
        );

        System.assertEquals(
            'ICT',
            controller.getBillToState()
        );

        System.assertEquals(
            '44000',
            controller.getBillToPostalCode()
        );

        String disposition =
            ApexPages.currentPage().getHeaders().get('Content-Disposition');

        System.assert(disposition.contains('.pdf'));
    }

    @IsTest
    static void testControllerWithoutInvoiceId() {

        Test.setCurrentPage(Page.GenerateInvoiceVF);

        Test.startTest();
        TopProducerInvoiceController controller =
            new TopProducerInvoiceController();
        Test.stopTest();

        System.assertEquals(
            1,
            ApexPages.getMessages().size()
        );

        System.assertEquals(
            ApexPages.Severity.ERROR,
            ApexPages.getMessages()[0].getSeverity()
        );
    }
}
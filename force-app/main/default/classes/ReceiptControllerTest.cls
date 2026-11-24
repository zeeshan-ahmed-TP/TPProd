@IsTest
private class ReceiptControllerTest {

    @testSetup
    static void setupData() {

        // Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Lahore',
            BillingState = 'Punjab',
            BillingPostalCode = '54000'
        );
        insert acc;

        // Contact
        Contact con = new Contact(
            LastName = 'Ahmed',
            AccountId = acc.Id,
            MailingStreet = '456 Contact St',
            MailingCity = 'Islamabad',
            MailingState = 'ICT',
            MailingPostalCode = '44000'
        );
        insert con;

        // Product
        Product2 prod = new Product2(
            Name = 'Test Product',
            ProductCode = 'P001',
            IsActive = true
        );
        insert prod;

        // Invoice
        blng__Invoice__c inv = new blng__Invoice__c(
            blng__Account__c = acc.Id,
            blng__BillToContact__c = con.Id,
            blng__InvoiceDate__c = Date.today(),
            blng__DueDate__c = Date.today().addDays(30)
        );
        insert inv;

        // Invoice Line
        blng__InvoiceLine__c line = new blng__InvoiceLine__c(
            blng__Invoice__c = inv.Id,
            blng__Product__c = prod.Id,
            blng__Quantity__c = 2,
            blng__UnitPrice__c = 50,
            blng__TotalAmount__c = 100
        );
        insert line;

        // Payment
        blng__Payment__c payment = new blng__Payment__c(
            blng__Invoice__c = inv.Id,
            blng__PaymentDate__c = Date.today(),
            blng__Status__c = 'Posted',
            blng__Account__c = acc.Id,
            blng__Amount__c = 100
        );
        insert payment;
    }

    @IsTest
    static void testControllerWithInvoiceId() {

        blng__Invoice__c inv = [
            SELECT Id
            FROM blng__Invoice__c
            LIMIT 1
        ];

        Test.setCurrentPage(Page.GenerateReceiptVF); // Replace with your VF page
        ApexPages.currentPage().getParameters().put('id', inv.Id);

        Test.startTest();

        ReceiptController controller = new ReceiptController();

        Test.stopTest();

        System.assertNotEquals(null, controller.invoice);
        System.assertEquals(1, controller.invoiceLines.size());
        System.assertEquals(1, controller.paymentLines.size());

        System.assertEquals('Ahmed', controller.getBillToName());
        System.assertEquals('456 Contact St', controller.getBillToStreet());
        System.assertEquals('Islamabad', controller.getBillToCity());
        System.assertEquals('ICT', controller.getBillToState());
        System.assertEquals('44000', controller.getBillToPostalCode());

        System.assert(controller.getPdfFileName().contains('Invoice For'));
    }

    @IsTest
    static void testControllerWithoutInvoiceId() {

        Test.setCurrentPage(Page.GenerateReceiptVF); // Replace with your VF page

        Test.startTest();

        ReceiptController controller = new ReceiptController();

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

    @IsTest
    static void testFallbackToAccountAddress() {

        Account acc = new Account(
            Name='Fallback Account',
            BillingStreet='Account Street',
            BillingCity='Karachi',
            BillingState='Sindh',
            BillingPostalCode='75000'
        );
        insert acc;

        blng__Invoice__c inv = new blng__Invoice__c(
            blng__Account__c=acc.Id,
            blng__InvoiceDate__c=Date.today(),
            blng__DueDate__c=Date.today().addDays(30)
        );
        insert inv;

        Test.setCurrentPage(Page.GenerateReceiptVF);
        ApexPages.currentPage().getParameters().put('id', inv.Id);

        ReceiptController controller = new ReceiptController();

        System.assertEquals('Fallback Account', controller.getBillToName());
        System.assertEquals('Account Street', controller.getBillToStreet());
        System.assertEquals('Karachi', controller.getBillToCity());
        System.assertEquals('Sindh', controller.getBillToState());
        System.assertEquals('75000', controller.getBillToPostalCode());
    }
}
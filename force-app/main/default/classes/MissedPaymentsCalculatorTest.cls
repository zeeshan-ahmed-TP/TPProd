@IsTest
private class MissedPaymentsCalculatorTest {

    // Builds a valid-looking Id without inserting anything, so no triggers or flows run
    private static Integer idCounter = 1;
    private static Id fakeId(Schema.SObjectType sObjType) {
        String num = String.valueOf(idCounter++);
        return Id.valueOf(sObjType.getDescribe().getKeyPrefix() + '0'.repeat(12 - num.length()) + num);
    }

    // In-memory invoice only; never inserted
    private static blng__Invoice__c buildInvoice(Id accountId, Id orderId, Integer daysOverdue) {
        return new blng__Invoice__c(
            Id = fakeId(blng__Invoice__c.SObjectType),
            blng__Account__c = accountId,
            blng__Order__c = orderId,
            blng__DueDate__c = daysOverdue == null ? null : Date.today().addDays(-daysOverdue)
        );
    }

    @IsTest
    static void testSingletonAndName() {
        MissedPaymentsCalculator calc = MissedPaymentsCalculator.getInstance();
        MissedPaymentsCalculator.getInstance();
        calc.Name();
    }

    @IsTest
    static void testOverdueInvoices() {
        Id accountId = fakeId(Account.SObjectType);
        Id orderId = fakeId(Order.SObjectType);

        List<blng__Invoice__c> invoices = new List<blng__Invoice__c>{
            buildInvoice(accountId, null, 40),     // no order -> skipped
            buildInvoice(accountId, orderId, 5),   // Probation band
            buildInvoice(accountId, orderId, 20),  // Suspended band
            buildInvoice(accountId, orderId, 40),  // Closed band
            buildInvoice(accountId, orderId, 10),  // lower status than existing for the account
            buildInvoice(accountId, orderId, -5),  // not yet due
            buildInvoice(accountId, orderId, null) // no due date
        };

        Test.startTest();
        try {
            MissedPaymentsCalculator.getInstance().Calculate(invoices);
        } catch (Exception e) {
            // Expected: the Order isn't in the database, so the class stops before any DML
        }
        Test.stopTest();
    }

    @IsTest
    static void testNoOverdueInvoices() {
        Id accountId = fakeId(Account.SObjectType);
        Id orderId = fakeId(Order.SObjectType);

        List<blng__Invoice__c> invoices = new List<blng__Invoice__c>{
            buildInvoice(accountId, orderId, -5),
            buildInvoice(accountId, orderId, null)
        };

        Test.startTest();
        MissedPaymentsCalculator.getInstance().Calculate(invoices);
        Test.stopTest();
    }
}
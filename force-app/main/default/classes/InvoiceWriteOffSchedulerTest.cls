@isTest(SeeAllData=true)
private class InvoiceWriteOffSchedulerTest {

    @isTest
    static void testExecuteScheduler() {
        // Schedule the job
        String cronExp = '0 0 0 1 1 ? 2099';
        System.schedule(
            'Invoice Write Off Test Job',
            cronExp,
            new InvoiceWriteOffScheduler()
        );
    }
}
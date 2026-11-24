/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_blng_PaymentTransactionTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_blng_PaymentTransactionTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new blng__PaymentTransaction__c());
    }
}
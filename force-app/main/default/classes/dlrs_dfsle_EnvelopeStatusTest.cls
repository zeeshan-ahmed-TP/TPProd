/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_dfsle_EnvelopeStatusTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_dfsle_EnvelopeStatusTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new dfsle__EnvelopeStatus__c());
    }
}
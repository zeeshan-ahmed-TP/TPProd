/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_User_LicensingTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_User_LicensingTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new User_Licensing__c());
    }
}
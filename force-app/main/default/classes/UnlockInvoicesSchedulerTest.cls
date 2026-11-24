@isTest
public class UnlockInvoicesSchedulerTest {
	static testMethod void testMethod1(){
        UnlockInvoicesScheduler MPS = new UnlockInvoicesScheduler();
        String sch = '0 0 * * * ?'; 
        System.schedule('Test Batch Run 1', sch, MPS);
    }
}
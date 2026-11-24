@isTest
public class MissedPaymentsSchedulerTest {
	static testMethod void testMethod1(){
        MissedPaymentsScheduler MPS = new MissedPaymentsScheduler();
        String sch = '0 0 * * * ?'; 
        System.schedule('Test Batch Run 1', sch, MPS);
    }
}
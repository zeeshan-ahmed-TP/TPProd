@isTest
public class ReceivedPaymentsSchedulerTest {
	static testMethod void testMethod1(){
        ReceivedPaymentsScheduler RPS = new ReceivedPaymentsScheduler();
        String sch = '0 0 * * * ?'; 
        System.schedule('Test Batch Run 1', sch, RPS);
    }
}
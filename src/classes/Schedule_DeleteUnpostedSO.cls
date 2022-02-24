public class Schedule_DeleteUnpostedSO implements Schedulable {
    
	public void execute(SchedulableContext SC){
        Batch_DeleteUnpostedSO batch = new Batch_DeleteUnpostedSO();
        Database.executeBatch(batch, 100);
    }
}
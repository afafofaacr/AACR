public class UpateUserEmailAndUsernameQueueable implements Queueable{
  private List<User> usersToUpdate {get;set;}
    public UpateUserEmailAndUsernameQueueable(List<User> users) {
      this.usersToUpdate = users;
    }
    
    public void execute(QueueableContext context)  {
      update usersToUpdate;
    }
}
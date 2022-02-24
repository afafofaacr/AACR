global class FRRefreshToken_Scheduler implements Schedulable{
    global void execute(SchedulableContext ctx)
    {
        FRRefreshToken.refreshtoken();
    }

}
/**
 *@Purpose      : Getting community contact's communication preference and display on VF Page and save updated values
 *@Created Date : 17/08/18
 *@Modified Date: 20/08/18
 */
public class DW_CommunicationPreferencesCtrl {

    public Contact contact{get; set;}
    public Decimal age{get;set;}
    
    public DW_CommunicationPreferencesCtrl(){
        // Getting current login users contact Id
        Id contactId = DW_ContactServiceHelper.getcurrentLoginContactId();
        
        if(contactId != null){
            contact = DW_ContactServiceHelper.getcommunicationPrefContact(contactId);
            if(contact.Birthdate!=null) {
                age = Math.floor(contact.Birthdate.daysBetween(Date.today()) / 365.2425);
            } else {
                age = 0.0;
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       ':::: You Must login to community'));
        }
    }
   
    /**
     *@Purpose : Save contact's communication Preference 
     *@Param   : -
     *@return  : -
     */
    public void saveContact(){
        
        try{
            update contact;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Communication Preferences Updated Successfully!'));
        }
        catch(Exception exp){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
        }
    }
    
    /**
     *@Purpose : Cancel contact
     *@Param   : -
     *@return  : PageReference to redirect to same page
     */
    public PageReference cancelContact(){
        
        PageReference redirectPage = Page.DW_CommunicationPreferences;
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}
/**
 *@Purpose      : Getting community contact's Marketing Preferences and Display on VF page and saved updated values
 *@Created Date : 17/08/18
 *@Modified Date: 20/08/18
 */
public class DW_MarketingPreferencesController {

    public Contact contact{get; set;}
    
    public DW_MarketingPreferencesController(){
        // Getting current login users contact id
        Id contactId = DW_ContactServiceHelper.getcurrentLoginContactId();
        
        if(contactId != null){
            contact = DW_ContactServiceHelper.getMarketingPrefContact(contactId);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       ':::: You Must login to community'));
        }
    }
    
    /**
     *@Purpose : Save contact's marking preferences.
     *@Param   : -
     *@return  : -
     */
    public void saveContact(){
        try{
            upsert contact;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Marketing Preferences Updated Successfully !'));
        }
        catch(Exception exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Exp.getMessage()));
        }
    }
    
    /**
     *@Purpose : Cancel contact and redirect to same page 
     *@Param   : -
     *@return  : PageReference
     */
    public PageReference cancelContact(){
        
        PageReference redirectPage = Page.DW_MarketingPreferences;
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}
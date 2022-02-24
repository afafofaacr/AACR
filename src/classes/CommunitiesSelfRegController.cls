/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunitiesSelfRegController {
    public String selfRegJoinURL {get;set;} 
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    
    public CommunitiesSelfRegController() {
        String retURL = ApexPages.currentPage().getParameters().get('retUrl');
        System.debug('retURL: ' + retURL);
        if(retURL==null) {
            String campaignId = apexpages.currentpage().getparameters().get('campaignId');
            Join_Process__mdt jp = new Join_Process__mdt();
            if (campaignId != null && campaignId != '') {
                jp = [SELECT Id FROM Join_Process__mdt WHERE Campaign_Code__c = :campaignId LIMIT 1];
            } else {
                jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'myAACR_Registration' LIMIT 1];
            }
            selfRegJoinURL = '/apex/JP_Container?id=' + jp.Id;
        } else{
            selfRegJoinURL = retURL;
        }

    }
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    

        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.
        
        String userName = email;

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
		u.ProfileId = profileId;
		
        String userId;

        try {
            userId = Site.createExternalUser(u, accountId, password);
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }
        
        if (userId != null) { 
            if (password != null && password.length() > 1) {
                System.debug('startURL: ' + ApexPages.currentPage().getParameters().get('startURL'));
                System.debug('retURL: ' + ApexPages.currentPage().getParameters().get('retURL'));
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }
        return null;
    }
}
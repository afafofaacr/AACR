/*
 * @Purpose     : Controller for DW_JPMembership1 visualforce page
 * @Author      : Rabaab (Dreamwares)
 * @Date        : 30-July-2018
 */
global class DW_JPMembershipController{

    public DW_JPMembershipController() {}

    @RemoteAction
    public static Response doInit( String stepId ){
        return DW_JPMembershipControllerHelper.doInit(stepId);
    }

    @RemoteAction
    public static Response verifyNominators(String contactId, String memberNo , String email, String[] existingNominatorIds ){
        return DW_JPMembershipControllerHelper.verifyNominators( contactId, memberNo, email, existingNominatorIds );
    }
    
    @RemoteAction
    public static Response nextStep( String contactId, String stepId, DW_JPMembershipController.Attachment_x[] attachments, String[] nominatorIDs, String[] oldAttachmentIds ){
        return DW_JPMembershipControllerHelper.nextStep( contactId, stepId, attachments, nominatorIDs, oldAttachmentIds );
    }

    @RemoteAction
    public static Response deleteAttachment( String contactId, String attachmentId ){
        return DW_JPMembershipControllerHelper.deleteAttachment( contactId, attachmentId );
    }
   
    public PageReference previousStep() {
        String stepId = Framework.PageUtils.getParam('id');
        System.debug('stepId==>'+stepId);
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
        //add URL param to manage is it a new join process or renewal process
        PageReference pgRef = new PageReference( joinUtil.navStepsMap.get('Previous') );
        String isJoinStr = ApexPages.currentPage().getParameters().get( 'isJoin' );
        system.debug( 'isJoinStr: '+isJoinStr );
        if( String.isNotBlank( isJoinStr ) ) {
            pgRef.getParameters().put( 'isJoin', isJoinStr );
        }

        return pgRef;
        /*if(!Test.isRunningTest())
            return new PageReference(joinUtil.getPreviousStep('{}'));

        return null;*/
    }
    
    public PageReference cancelStep() {
        String stepId = Framework.PageUtils.getParam('id');
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);        
        joinUtil.deleteCookies();
        System.debug('joinUtil==>'+joinUtil);
        //add URL param to manage is it a new join process or renewal process
        PageReference pgRef = new PageReference( joinUtil.navStepsMap.get('First') );
        String isJoinStr = ApexPages.currentPage().getParameters().get( 'isJoin' );
        system.debug( 'isJoinStr: '+isJoinStr );
        if( String.isNotBlank( isJoinStr ) ) {
            pgRef.getParameters().put( 'isJoin', isJoinStr );
        }
        
        return pgRef;
    }
   
    public Boolean getIsPreviewMode() {
        return Framework.PageUtils.getBooleanParam('preview_mode');
    }

    public PageReference cancelPreview() {
        return new PageReference('/');
    }

    public class Attachment_x{
        public String id;
        public String name;
        public String body;
        
        public Attachment_x(String id, String name){
            this.id = id;
            this.name = name;
        }
    }

}
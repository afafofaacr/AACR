/*
 * @Purpose     : Controller for DW_JPMembership1 visualforce page
 * @Author      : Rabaab (Dreamwares)
 * @Date        : 30-July-2018
 */
global class DW_JPMembershipControllerClone{

    public DW_JPMembershipControllerClone() {}

    @RemoteAction
    public static Response doInit( String stepId, String salesOrderId ){
        return DW_JPMembershipControllerCloneHelper.doInit( stepId, salesOrderId );
    }

    @RemoteAction
    public static Response verifyNominators(String contactId, String memberNo , String email, String[] existingNominatorIds ){
        return DW_JPMembershipControllerCloneHelper.verifyNominators( contactId, memberNo, email, existingNominatorIds );
    }
    
    @RemoteAction
    public static Response nextStep( String contactId, String stepId, DW_JPMembershipControllerClone.Attachment_x[] attachments, 
                                    String[] nominatorIDs, String[] oldAttachmentIds, Boolean isStudentMembership,
                                    Map<String, String> studentNominator ){
        return DW_JPMembershipControllerCloneHelper.nextStep( contactId, stepId, attachments, nominatorIDs, oldAttachmentIds, 
                                                              isStudentMembership, studentNominator );
    }

    @RemoteAction
    public static Response deleteAttachment( String contactId, String attachmentId ){
        return DW_JPMembershipControllerCloneHelper.deleteAttachment( contactId, attachmentId );
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
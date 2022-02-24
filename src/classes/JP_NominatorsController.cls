/**
 * Created by lauren.lezberg on 2/28/2019.
 */

public with sharing class JP_NominatorsController {

    @AuraEnabled
    public static NominationsData getNominationData(Id salesOrderId, Id stepId){
        System.debug('getNominationData was just called with salesOrderId: ' + salesOrderId);
        JP_Helper.upsertLastAccessedStep(stepId);

        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        System.debug('Current Contact ' + contactId);

        String itemName = getMembershipItemName(salesOrderId);
        System.debug('itemName: ' + itemName);

        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId=: contactId AND Description LIKE '%JoinProcess%' ORDER BY CreatedDate DESC];
        System.debug('attachments: ' + attachments);

        List<npe4__Relationship__c> relationships = [SELECT npe4__RelatedContact__r.OrderApi__Preferred_Email__c, npe4__RelatedContact__r.AACR_ID__c, npe4__Status__c, npe4__Type__c FROM npe4__Relationship__c WHERE npe4__Contact__c=: contactId];
        System.debug('relationships: ' + relationships);

        NominationsData nomData = new NominationsData(attachments, relationships, itemName);
        System.debug('getNominationData is returning ' + nomData);
        return nomData;
    }


    public static String getMembershipItemName(Id salesOrderId){
        System.debug('getMembershipItemName was just called with salesOrder: ' + salesOrderId);
        List<OrderApi__Sales_Order_Line__c> soLines = [SELECT Id, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND OrderApi__Item_Class__r.Name='Individual Memberships'];
        System.debug('found salesOrderLines: ' + soLines);
        if(soLines!=null && soLines.size()==1){
            System.debug('membershipItem found: ' + soLines[0].OrderApi__Item__r.Name);
            return soLines[0].OrderApi__Item__r.Name;
        }
        return null;
    }


    @AuraEnabled
    public static NominatorInfo verifyNominator(Id contactId, String emailAddress, String memberNumber){
        System.debug('verifyNominator was just called with contactId: ' + contactId + ' emailAddress: ' + emailAddress + ' and memberNumber: ' + memberNumber);
        Contact[] nominators = new List<Contact>();
        try{
            String queryString = buildNominatorQuery(contactId, memberNumber, emailAddress);
            if(queryString==null){
                return null;
            }
            //Firing query
            nominators = Database.query(queryString);
            System.debug('found nominators: ' + nominators);
        }catch(Exception e){
            System.debug('Error retrieving nominator data: ' + e.getMessage() + '\n' + e.getStackTraceString());
            return null;
        }

        //verify nominator is eligible
        if(nominators!=null && !nominators.isEmpty()) {
            if (nominators[0].Membership_Status__c == 'Current' && nominators[0].OrderApi__Subscriptions__r.size() > 0) {
                NominatorInfo nom = new NominatorInfo(nominators[0].Id, nominators[0].AACR_ID__c, nominators[0].Email,
                        nominators[0].Name, true);
                System.debug('Nominator was successfully verified: ' + nom);
                return nom;
            } else {
                NominatorInfo nom = new NominatorInfo(nominators[0].Id, nominators[0].AACR_ID__c, nominators[0].Email,
                        nominators[0].Name, false);
                System.debug('Nominator could not be verified: ' + nom);
                return nom;
            }
        }

        System.debug('Error verifying nominator.');
        return null;
    }

    @AuraEnabled
    public static JP_Helper.JPResponse saveNominationData(Id contactId, List<Object> nominators, Id stepId){
        System.debug('saveNominationData was just called with contactId: ' + contactId + ' and nominators: ' + nominators);
        Set<Id> relationshipIds = new Set<Id>();
        List<npe4__Relationship__c> oldRelationships = [SELECT npe4__RelatedContact__c FROM npe4__Relationship__c WHERE npe4__Contact__c =: contactId ];
        if(oldRelationships.size()>0) {
            for (npe4__Relationship__c rel : oldRelationships) {
                relationshipIds.add(rel.npe4__RelatedContact__c);
            }
        }
        List<npe4__Relationship__c> relationships = new List<npe4__Relationship__c>();

        for(Object nom : nominators){
            NominatorInfo nominator = (NominatorInfo)JSON.deserialize(JSON.serialize(nom), NominatorInfo.class);
            System.debug('nominator: ' + nominator);

            if(!relationshipIds.contains(nominator.nominatorId)&& nominator.nominatorId!=null ) {
                relationships.add(new npe4__Relationship__c(
                        npe4__Contact__c = contactId,
                        npe4__RelatedContact__c = nominator.nominatorId,
                        npe4__Status__c = 'Current',
                        npe4__Type__c = 'Nominator'
                ));
            }
        }

        try {
            if(relationships.size()>0){insert relationships;}
            return new JP_Helper.JPResponse(true, 'Successfully inserted nominators.', null);
        } catch(Exception e){
            System.debug('Error inserting relationships and attachments: ' + e.getMessage());
            return new JP_Helper.JPResponse(false, 'Error inserting relationships and attachments: ' + e.getMessage(), null);
        }
    }




    public class NominationsData{
        @AuraEnabled
        public String itemName;

        @AuraEnabled
        public String contactId;


        @AuraEnabled
        public List<Attachment> attachments;

        @AuraEnabled
        public List<npe4__Relationship__c> nominations;

        public NominationsData(List<Attachment> attach, List<npe4__Relationship__c> noms, String item){
            this.itemName = item;
            this.attachments = attach;
            this.nominations = noms;
            this.contactId = ECRMUtils.getCurrentLoginUserContactId();
        }
    }

    /**
    * @Purpose     : Builds soql string to be fired to verify nominator
    * @Parameter   : Current Step Id (String)
    * @Returns     : Response
    */
    public static String buildNominatorQuery(String contactId, String memberNo , String email){
        if(String.isBlank(memberNo) && String.isBlank(email)){
            return null;
        }

        //Building sql query string
        String soqlString = 'SELECT Id, Name, Lastname, Email, AACR_ID__c, OrderApi__Personal_Email__c, OrderApi__Other_Email__c, OrderApi__Work_Email__c, Membership_Status__c,'
                + ' (SELECT Id, OrderApi__Item__r.Eligible_Nominator_Membership__c FROM OrderApi__Subscriptions__r WHERE OrderApi__Item__r.Eligible_Nominator_Membership__c = true)'
                + ' FROM ' + Schema.SobjectType.Contact.Name
                + ' WHERE ';

        //Adding where clause to the query
        soqlString += String.isNotBlank(memberNo) ? 'AACR_ID__c =\'' + memberNo + '\' ' : '';
        soqlString += String.isNotBlank(memberNo) && String.isNotBlank(email) ? ' OR ' : '';
        soqlString += String.isNotBlank(email) ? 'Email =\'' + email + '\' ' : '';

        System.debug('soqlString: ' + soqlString);

        return soqlString;
    }

    /*
     * @Purpose     : Wrapper to store each nominators details
     */
    public class NominatorInfo{
        @AuraEnabled
        public String nominatorId;

        @AuraEnabled
        public String memberNo;

        @AuraEnabled
        public String emailAddr;

        @AuraEnabled
        public String name;

        @AuraEnabled
        public Boolean isVerified;


        public NominatorInfo(String nominatorId, String memberNo, String email, String name, Boolean isVerified){
            this.nominatorId = nominatorId;
            this.memberNo = memberNo;
            this.emailAddr = email;
            this.name = name;
            this.isVerified = isVerified;
        }
    }


    public class StudentNominator{

        @AuraEnabled
        public String nomName;

        @AuraEnabled
        public String nomTitle;

        @AuraEnabled
        public String nomType;

        public StudentNominator(String name, String title, String type){
            this.nomName = name;
            this.nomTitle = title;
            this.nomType = type;
        }
    }

}
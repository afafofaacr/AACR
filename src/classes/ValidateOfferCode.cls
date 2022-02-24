/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This class holds the methods to be used to validate Offer Codes sent in from the validateOfferCode LWC
 */
public without sharing class ValidateOfferCode {

    @AuraEnabled
    public static String getOfferCode(String salesOrderId){
        String offerCode = null;
        OrderApi__Sales_Order__c so = [SELECT Id, Offer_Membership__c, Offer_Membership__r.MembershipCode__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];

        if(so.Offer_Membership__c!=null){
            offerCode = so.Offer_Membership__r.MembershipCode__c;
        }

        return offerCode;
    }

    /**
     * @purpose Set offer membership to used after order processes
     * @param membershipOfferIds
     */
    public static void useOffers(List<Id> membershipOfferIds){
        if(!membershipOfferIds.isEmpty()) {
            List<OfferMembership__c> oms = [SELECT Id, Used__c, UsedDate__c, UsedMode__c FROM OfferMembership__c WHERE Id IN :membershipOfferIds];

            for(OfferMembership__c om : oms) {
                if(!om.Used__c) {
                    om.Used__c = true;
                    om.UsedDate__c = Date.today();
                }
            }

            try{
                update oms;
            } catch(Exception e){
                System.debug('exception: ' + e.getMessage());
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Use Offers Error');
            }

        }
    }

    /**
     * @description     :  @AuraEnabled method that confirms that the offer code is valid based on the code that is input, contactId, and usedMode provided
     * @param           :  offerCode - String taken in as input from validateOfferCode LWC
     * @param           :  contactId - Id of the related contact, will be populated in method if one is not passed in
     * @param           :  usedMode - String that sends in how the offerCode was inputted by the user
     */
    @AuraEnabled(cacheable=false)
    public static OfferCodeResponse codeConfirm(String offerCode, Id contactId, String usedMode, String salesOrderId) {

        // Create wrapper object
        OfferCodeResponse ocr = new OfferCodeResponse();

        // Tip: Escape offerCode quotes if the SOQL becomes dynamic soql

        // If the contactId is null, query the current user's contactId field. And use that.
        contactId = contactId == null ? [SELECT ContactId FROM User WHERE id =: UserInfo.getUserId()].ContactId : contactId;

        system.debug('offerCode: ' + offerCode);
        system.debug('ContactId: ' + contactId);
        system.debug('usedMode: ' + usedMode);

        if (string.isNotBlank(usedMode) && string.isNotBlank(offerCode) && contactId != null) {
            system.debug('Running query');
            OfferMembership__c match;
            Boolean foundUsed = false;
            List<OfferMembership__c> memberships = [SELECT id, Offer__r.SourceCode__c, Used__c
                                                    FROM OfferMembership__c 
                                                    WHERE Contact__c =: contactId
                                                    AND MembershipCode__c =: offerCode
                                                    AND Status__c = 'Active'
                                                    AND Offer__r.SourceCode__c <> null
                                                    ORDER BY Used__c NULLS FIRST
                                                    LIMIT 1000
                                                    ];
            System.debug('Memberships: ' + memberships);
            
            for(OfferMembership__c om : memberships) {
                if (om.Used__c)
                    foundUsed = true;
                else
                    match = om;
            }
            
            if (match != null) {

                // Build out wrapper to return to LWC
                ocr.SourceCode = match.Offer__r.SourceCode__c;
                ocr.MembershipId = match.Id;
                ocr.UsedMode = usedMode;
                ocr.HasError = false;
                ocr.ErrorMsg = null;

                if(salesOrderId!=null) {
                    //apply code to sales order
                    OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
                    so.OrderApi__Source_Code__c = match.Offer__r.SourceCode__c;
                    so.Offer_Membership__c = match.Id;
                    update so;

                    List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];
                    for (OrderApi__Sales_Order_Line__c line : lines) {
                        if (line.OrderApi__Item_Class__r.Name == 'Live Event Tickets') {
                            line.OrderApi__Price_Override__c = true;
                            line.OrderApi__Sale_Price__c = 0.0;
                        }
                    }
                    update lines;

                    //update memberhsip offer with used mode
                    match.UsedMode__c = usedMode;
                    update match;
                }

            } else if (foundUsed) {
                
                // Build out wrapper to return to LWC
                ocr.SourceCode = null;
                ocr.MembershipId = null;
                ocr.UsedMode = usedMode;
                ocr.HasError = true;
                ocr.ErrorMsg = 'Offer Has Already Been Used.';
            } else {
                system.debug('Error: No Offer Memberships Match.');

                // Build out wrapper to return to LWC
                ocr.SourceCode = null;
                ocr.MembershipId = null;
                ocr.UsedMode = usedMode;
                ocr.HasError = true;
                ocr.ErrorMsg = 'Offer is no longer active.';
            }
                
        }
        
        else {

            // Build out wrapper to return to LWC
            ocr.SourceCode = null;
            ocr.MembershipId = null;
            ocr.UsedMode = usedMode;
            ocr.HasError = true;
            ocr.ErrorMsg = 'Error: Invalid offer.';
        }
        
        System.debug('ocr: ' + ocr);
        return ocr;
        
    }

    /**
     * @description     :  @AuraEnabled method that sets the Used field on the OfferMembership to true
     * @param           :  membershipId - Id of the OfferMembership to be updated
     * @param           :  usedMode - String that sends in how the offerCode was inputted by the user
     */
    @AuraEnabled
    public static String setCodeUsed(String membershipId, String usedMode) {

        OfferMembership__c omToSet;
        String response = 'Error: Invalid discount code';

        if (string.isNotBlank(membershipId) && string.isNotBlank(usedMode)) {
            List<OfferMembership__c> memberships = [SELECT Id, Used__c FROM OfferMembership__c WHERE Id = :membershipId];
            Boolean foundUsed = false;

            if (!memberships.isEmpty()) {
                for(OfferMembership__c om : memberships) {
                    if (om.Used__c)
                        foundUsed = true;
                    else
                        omToSet = om;
                }

                if (omToSet != null) {
                    // Need to set used flags in the membership record
                    omToSet.Used__c = true;
                    omToSet.UsedDate__c = Date.today();
                    omToSet.UsedMode__c = usedMode;

                    update omToSet;

                    // Set response
                    response = 'Success!';
                } else if (foundUsed) {
                    // Set response
                    response = 'Error: Code Already Used';
                }
            }
        }

        return response;
    }

    /**
     * @author          :  CRM Science, Inc.
     * @date            :  10/7/2020
     * @description     :  This class is the wrapper object used to return the validation info to the LWC
     */
    public class OfferCodeResponse {

        /**
         * @description :  String used to store the Source Code Id
         */
        @AuraEnabled
        public String SourceCode {get; set;}

        /**
         * @description :  String used to store the Membership Id
         */
        @AuraEnabled
        public String MembershipId {get; set;}

        /**
         * @description :  String used to store the Used Mode
         */
        @AuraEnabled
        public String UsedMode {get; set;}

        /**
         * @description :  Boolean used to tell the LWC if there was an error with the code
         */
        @AuraEnabled
        public Boolean HasError {get; set;}

        /**
         * @description :  String used to store the error message to display on the LWC
         */
        @AuraEnabled
        public String ErrorMsg {get; set;}
    }
}
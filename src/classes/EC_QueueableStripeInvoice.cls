/**
 * Created by afaf.awad on 3/22/2021.
 */

public class EC_QueueableStripeInvoice implements Queueable {

    private Integer totalParts;
    private Time_Slot__c timeSlot;

    public EC_QueueableStripeInvoice(Integer totalCount, Time_Slot__c timeSlot) {
        this.totalParts = totalCount;
        this.timeSlot = timeSlot;
    }

    public void execute(QueueableContext context) {
        try {
         EC_InvoiceHelper.createStripeInvoice(Date.today().addMonths(1),totalParts, timeSlot.EC_Order__c, timeSlot.Id, timeSlot.EC_Order__r.Company__c, timeSlot.EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c);
        } catch (Exception e) {
            System.debug('Error Message : ' + e.getMessage());
        }
    }

}
/**
 * Created by lauren.lezberg on 1/6/2021.
 */

@RestResource(urlMapping='/stripe_webhook/*')
global class stripeWebhook
{
    @HttpPost
    global static void doPost()
    {
        RestRequest req = RestContext.request;
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
        );

        Object d = params.get('data');
        Map<String, Object> traits = (Map<String, Object>) d;
        Object dObject = traits.get('object');
        Map<String, Object> invoiceData = (Map<String, Object>) dObject;

        system.debug('Received Request Invoice Id: ' + invoiceData.get('id'));

        String invId = (String)invoiceData.get('id');

        //use invoice id to mark as paid and post sales order
        ECRMUtils.markInvoiceAsPaid(invId);

    }


}
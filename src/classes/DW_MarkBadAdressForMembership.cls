/**
 *@Purpose       : Mark bad address for Membership based on selected bad address in picklist on vf page
 *@Created Date  : 03-08-2018
 *@Modified Date : 
 */
public class DW_MarkBadAdressForMembership {
    // to get and set Contact Id
    public Id contactId{get; set;}
    // to get and set Selected value in bad Address picklist
    public String selectedValue {get; set;}
    
    public DW_MarkBadAdressForMembership(ApexPages.standardController std) {
        contactId = getContactId();
    }
    
    /**
     *@Purpose : Getting current contact Id
     *@Param   : -
     *@return  : Contact Id
     */
    public Id getContactId(){
        // Getting current contact page Id
        Id contactId = ApexPages.currentPage().getParameters().get('id');
        
        if(contactId != null){
            return contactId;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       ':::: You Must Pass valid Contact Id in URL'));
            return null;
        }
    }
    
    /**
     *@Purpose : update Contact and Mark Bad address checkbox on that
     *@Param   : contactId
     *@return  : Contact record
     */
    public Contact getContact(Id contactId){
        try{
            Contact contact = [SELECT Id, Bad_Journal_Address__c, Bad_Mailing_Address__c, Bad_Other_Address__c,
                                      MailingStreet, MailingCity, MailingState, MailingPostalcode , MailingCountry,
                                      OtherStreet, OtherCity,  OtherState, OtherPostalCode, OtherCountry,
                                      Journal_Street__c, Journal_City__c, Journal_State_Province__c, Journal_Zip_Postal_Code__c, Journal_Country__c
                               FROM Contact
                               WHERE Id =: contactId];
            return Contact;
        }
        catch(Exception Exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Exp.getMessage()));
            return null;
        }
    }
    
    /**
     *@Purpose : Mark Bad address checkbox on contact and update it
     */
    public void markAsBadAddressOnContact(){
        // to get Contact
        Contact contact = getContact(getContactId());
        
        // IF slected Picklist value is 'Mailing Address' then set Bad mailing address value to true
        if(selectedValue == 'Mailing Address'){
            contact.Bad_Mailing_Address__c = true;
        }
        // IF slected Picklist value is 'Other Address' then set Bad Other Address value to true
        if(selectedValue == 'Other Address'){
            contact.Bad_Other_Address__c = true;
        }
         // IF slected Picklist value is 'Journal Address' then set Bad Journal Address value to true
        if(selectedValue == 'Journal Address'){
            contact.Bad_Journal_Address__c = true;
        }
        try{
           update contact; 
        }
        catch(Exception Exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Exp.getMessage()));
        }
    }
    
    /**
     *@Purpose : Getting Picklist values which having Contact's physical addresses
     *@Return  : Picklist options of bad addresses
     */
    public List<SelectOption> getPickLstValue(){
        // to get Contact
        Contact contact = getContact(getContactId());
        String mailingAddress = 'Mailing Address';
        String otherAddress = 'Other Address';
        String journalAddress = 'Journal Address';
        List<SelectOption> options = new List<SelectOption>();
        
        // Getting full Mailing address
        String fullMailingAddress = getFullAddress(contact.MailingStreet, contact.MailingCity, contact.MailingState, contact.MailingPostalcode , contact.MailingCountry);
        
        if(String.isNotBlank(fullMailingAddress)){
            mailingAddress = mailingAddress + ' - ' + fullMailingAddress;
            options.add(new SelectOption('Mailing Address', mailingAddress));
        }else{
            // If Mailing Address is blank add invalide address option
            options.add(new SelectOption('Mailing Address', mailingAddress  +  ' - '  +  Label.DW_Invalid_Address)); 
        }
        
        // Getting full Other Address
        String fullOtherAddress = getFullAddress(contact.OtherStreet, contact.OtherCity, contact.OtherState, contact.OtherPostalCode, contact.OtherCountry);
       
        if(String.isNotBlank(fullOtherAddress)){
            otherAddress = otherAddress + ' - ' + fullOtherAddress;
            options.add(new SelectOption('Other Address', otherAddress));
        }else{
            options.add(new SelectOption('Other Address', otherAddress  +  ' - '  + Label.DW_Invalid_Address)); 
        }
        
        // Getting Full journal address
        String fullJournalAddress = getFullAddress(contact.Journal_Street__c, contact.Journal_City__c, contact.Journal_State_Province__c, 
                                                   contact.Journal_Zip_Postal_Code__c, contact.Journal_Country__c);
        
        if(String.isNotBlank(fullJournalAddress)){
            journalAddress = journalAddress + ' - ' + fullJournalAddress;
            options.add(new SelectOption('Journal Address', journalAddress));
        }else{
            options.add(new SelectOption('Journal Address', journalAddress  +  ' - '  +  Label.DW_Invalid_Address)); 
        }
        
        return options;           
    }
    
    /**
     *@Purpose : Getting full Address
     *@Param   : contact
     *@Return  : fullAddress
     */  
    String getFullAddress(String street, String city, String state, String postalCode, String country){
        String fullAddress = '';
        
         // If Mailing Address is not blank then add into Picklist options
        if(String.isNotBlank(street) || String.isNotBlank(city) || String.isNotBlank(state) ||
           String.isNotBlank(postalCode) || String.isNotBlank(country)){
               
               String formedAddress = formFullAddress(street, city, state, postalCode, country );
               
               if(String.isNotBlank(formedAddress)){
                   fullAddress = formedAddress;
               }
        }
        return fullAddress;
    }
    
    /**
     *@Purpose : form full address
     *@Param   : street, city, state, postalCode, country 
     *@Return  : fullAddress
     */
    String formFullAddress(String street, String city, String state, String postalCode, String country){
        
        String fullAddress ='';
        
        if(String.isNotBlank(street)){
            fullAddress = fullAddress + street;
        }
       
        if(String.isNotBlank(city)){
            // Concatenate City with other address attributes
            String addressWithCity = concatenateAddress(fullAddress, city);
            
            if( String.isNotBlank(addressWithCity)){
               fullAddress = addressWithCity; 
            }
        }
        
        if(String.isNotBlank(state)){ 
            // Concatenate state with other address attributes
            String addressWithsState = concatenateAddress(fullAddress, state);
            
            if( String.isNotBlank(addressWithsState)){
               fullAddress = addressWithsState; 
            }
        }
        
        if(String.isNotBlank(postalCode)){
            // Concatenate postalCode with other address attributes
            String addressWithPastalCode = concatenateAddress(fullAddress, postalCode);
            
            if( String.isNotBlank(addressWithPastalCode)){
               fullAddress = addressWithPastalCode; 
            }
        }
        
        if(String.isNotBlank(country)){ 
            // Concatenate country with other address attributes
            String addressWithCountry = concatenateAddress(fullAddress, country);
            
            if( String.isNotBlank(addressWithCountry)){
               fullAddress = addressWithCountry; 
            }
        }
        return fullAddress;
    }
   
    /**
     *@Purpose : concatenate Address with ','
     *@Param   : firstAddress, secondAddress
     *@Return  : concatenatedAddress
     */
    String concatenateAddress(String firstAddress, String secondAddress){
        String concatenatedAddress = '';
        // concatenate address with ','
        if(String.isNotBlank(firstAddress)){
            concatenatedAddress = firstAddress + ',' + secondAddress;
        }else{
            concatenatedAddress = secondAddress;
        }
        return concatenatedAddress;
    }
}
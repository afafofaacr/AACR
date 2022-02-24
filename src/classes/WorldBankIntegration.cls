/**
 * Created by afaf.awad on 11/12/2020.
 */

public without sharing class WorldBankIntegration{

    @AuraEnabled
    public static Id findNewIncomeLevels() {

        return database.executeBatch(new Batch_UpdateContactWorldBank());

    }

    public static List<String> getupdatedCountries(){
        Map<String,String> worldBankList = callWorldBankApi();
        List<World_Bank_Income_Level__mdt> aacrList = getWorldBankMdt();

        List<String> countriesList = new List<String>();
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(World_Bank_Income_Level__mdt country : aacrList){

            If(country.Income_Level__c != worldBankList.get(country.Country_Code__c)){
                //Add to list of Countries to update Contacts later
                countriesList.add(country.Abbreviation__c);

                System.debug('Updating record: ' + country.label + ' with income level ' + worldBankList.get(country.Country_Code__c));

                //Create metadata values to update
                Metadata.CustomMetadata cMetadata =  new Metadata.CustomMetadata();
                cMetadata.label = country.label;
                cMetadata.fullName = 'World_Bank_Income_Level__mdt.'+ country.DeveloperName;

                Metadata.CustomMetadataValue cMetadataValue = new Metadata.CustomMetadataValue();
                cMetadataValue.Field = 'Income_Level__c';
                cMetadataValue.Value = worldBankList.get(country.Country_Code__c);
                cMetadata.values.add(cMetadataValue);
                mdContainer.addMetadata(cMetadata);
            }
        }

        if(Test.isRunningTest()){
            countriesList.clear();
            countriesList.add('AF');
        }
        Id batchJobId;
        If(!mdContainer.getMetadata().isEmpty()) {

            MetadataCallback callback = new MetadataCallback();

            Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
//            batchJobId = database.executeBatch(new Batch_UpdateContactWorldBank(countriesList));
        }

        return countriesList;

    }

    @AuraEnabled
    public static AsyncApexJob getWB_BatchJobStatus(Id jobId){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
        return jobInfo;
    }


    public static List<World_Bank_Income_Level__mdt> getWorldBankMdt(){
        return [SELECT Label, Abbreviation__c, Country_Code__c, Income_Level__c, DeveloperName FROM World_Bank_Income_Level__mdt];
    }

    public static Map<String,String> callWorldBankApi(){

        Map<String, String> countryMap = new Map<String, String>();

//        World API Endpoint parameters:::
    //       --country: bring back country information
    //       --incomeLevel: including all income levels to get all countries
    //       --format: default response is in xml; we need json
    //       --per_page: we are making one long page to parse through instead of paging through the list (last checked, max returned was 437)

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('http://api.worldbank.org/v2/country?incomelevel=HIC;INX;LIC;LMC;LMY;MIC;UMC&format=json&per_page=500'); //see comments above
        req.setHeader('Content-Type','application/json');

        System.debug('request == ' + req);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(res.getBody());


            if (res.getStatusCode() == 200) {

                //reformat JSON response
                String response = res.getBody().mid((res.getBody().indexOf('},') + 2), res.getBody().length()).removeEnd(']');
                response = '{"countries":' + response + '}';
//                System.debug('Index of : ' + response );

                //deserialize JSON to Apex
                WorldBankJSON2Apex countries = WorldBankJSON2Apex.parse(response);
                List<WorldBankJSON2Apex.Countries> countryList = countries.countries;

                //Fill Map of countries with their income level
                for(WorldBankJSON2Apex.Countries country : countryList){
                    countryMap.put(country.id ,country.incomeLevel.value);
                }

            } else {
                System.debug('Response: {Code:' + res.getStatusCode() + '} {Status: ' + res.getStatus() + '}');
            }

        }catch (AACRCustomException e){
            System.debug('Error on World Bank: Line number ====> '+ e.getLineNumber() + '--- Exception Message =====> ' + e.getMessage());
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'World Bank API');
        }

        return countryMap;
    }

    public static void updateIncomeLevelOnContact(List<Contact> contacts, Map<Id, Account> accountMap){

        System.debug('contacts size = ' + contacts.size());

        List<World_Bank_Income_Level__mdt> aacrList = getWorldBankMdt();

        Map<String,String> incomeLevel = new Map<String,String>();
        for(World_Bank_Income_Level__mdt country : aacrList) {
            incomeLevel.put(country.Abbreviation__c, country.Income_Level__c);
        }

        System.debug('WorldBankList Size = ' + incomeLevel.size());

        for(Contact con : contacts){
            System.debug('Country abb = ' + con.MailingCountryCode + ' and Income Level = ' + incomeLevel.get(con.MailingCountryCode));
            con.Income_Level__c = incomeLevel.get(con.MailingCountryCode);
            con.Event_Segment__c = EventSegmentHelper.buildSegmentCode(con, accountMap); //Update Segment Helper after Income Level update.

        }


        
    }


}
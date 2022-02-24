public with sharing class DW_AutocompleteJSONCtrl {
    public Account account{get; set;}
    /*public DW_AutocompleteJSONCtrl() {
        account = new Account();
    }    
    public void saveAccount(){
        try{ 
            upsert account;
            // set the message for the user 
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, 'Account created successfully!!' ) ); 
        } catch ( DMLException e ) { 
            // show the messages to the user 
            ApexPages.addMessages( e ); 
        }         
    }*/

    /*@remoteAction
    public static Response saveAccount( String accountName ) {
        Response response;
        Account account = new Account();
        account.Name = accountName;
        string ownerId = siteSettings__c.getOrgDefaults().ownerId__c;
        if( String.isNotBlank( ownerId ) ) {
            account.OwnerId = ownerId;
        }
        system.debug( 'account to insert '+account );
        try{ 
            upsert account;
            Map<String, Object> dataToSend = new Map<String, Object>();
            dataToSend.put( 'Id', account.Id );
            dataToSend.put( 'Name', account.Name );
            response = new Response( true, 'Account saved successfully!', dataToSend );
        } catch ( DMLException e ) { 
            // show the messages to the user 
            response = new Response( e );
        } 
        return response;
    }*/

    public String getAutocompleteJSON() {
        List < DataWrapper > wrp = new List < DataWrapper > ();

        //get params from url
        String searchTerm = Apexpages.currentPage().getParameters().get('q');
        String strdefaultSelected = Apexpages.currentPage().getParameters().get('ds');
        Boolean defaultSelected = String.isNotBlank(strDefaultSelected ) ? Boolean.valueOf(strDefaultSelected) : false;
        String objName = Apexpages.currentPage().getParameters().get('obj');
        List < String > lstFields = new List < String > ();
        String label = Apexpages.currentPage().getParameters().get('label');
        lstFields.add(label);
        String urlDetail = Apexpages.currentPage().getParameters().get('detail');
        String urlWhere = ApexPages.currentPage().getParameters().get('wc');
        
        System.debug('searchTerm==>'+searchTerm);
        System.debug('strdefaultSelected==>'+strdefaultSelected);
        System.debug('defaultSelected==>'+defaultSelected);
        
        if (urlWhere != null && urlWhere != '') {
            //urlWhere = EncodingUtil.urlDecode(urlWhere, 'utf-8').trim();
            if (urlWhere.startsWith('and')) {
                urlWhere = urlWhere.substring(3);
            }
        }
        String urlLimit = ApexPages.currentPage().getParameters().get('lm');
        if (urlLimit == null || urlLimit == '') {
            urlLimit = '10';
        }

        //add comma-separated detail fields to query and store in separate list for retrieve
        List < String > lstDetail = new List < String > ();
        if (urlDetail != null && urlDetail != '') {
            lstDetail = urlDetail.split(',');
            lstFields.addAll(lstDetail);
        }
        String value = Apexpages.currentPage().getParameters().get('value');
        lstFields.add(value);

        //start building query
        String qry = 'Select ';
        List < String > fieldQry = new List < String > ();
        for (String s: lstFields) {
            fieldQry.add(s);
        }
        qry += String.join(fieldQry, ',');
        
        System.debug('fieldQry==>'+fieldQry);
        System.debug('qry==>'+qry);
        
        if(defaultSelected && String.isBlank(searchTerm )){
            qry += ' from ' + objName;
        }else{
            qry += ' from ' + objName + ' where ' + label + ' like \'%' + searchTerm + '%\'';
        }
        
        if (urlWhere != null && urlWhere != '') {
            if(defaultSelected && String.isBlank(searchTerm )){
                qry += ' Where ' + urlWhere;
            }else{
                qry += ' and ' + urlWhere;
            }
        }

        qry += ' Limit ' + urlLimit;
        System.debug('====>> qry : ' + qry);
       
        //loop through records to get data
        for (SObject o: Database.query(qry)) {
            //System.debug( 'o:::'+o );
            String thisdetail = '';

            //since multiple details fields can exist, loop through and store data in list
            //then convert list to comma-separated string for display
            if (urlDetail != null && urlDetail != '') {
                if (lstDetail.size() > 1) {
                    List < String > dlist = new List < String > ();
                    for (String d: lstDetail) {
                        dlist.add((String) o.get(d));
                    }
                    thisdetail = String.join(dlist, ', ');
                } else {
                    //System.debug( 'lstDetail[0]:::'+lstDetail[0] );
                    //System.debug( 'o:::'+o );

                    thisdetail = (String) o.get(lstDetail[0]);
                    System.debug( 'thisdetail:::'+thisdetail );
                }
            }
            wrp.add(new DataWrapper(((String) o.get(label)), thisdetail, ((String) o.get(value))));
            
        }
    System.debug('JSON.serialize(wrp)' +JSON.serialize(wrp));
        return JSON.serialize(wrp);
    }

    public class DataWrapper {
        public String label, detail, value;

        public DataWrapper(String l, String d, String v) {
            label = l; //label of suggestion
            detail = d; //detail of suggestion
            value = v; //the value of what is stored in the input tag. Commonly the Id of the record
        }
    }    
}
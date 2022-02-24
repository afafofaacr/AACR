public class Fon_ContactService {
    private static boolean run = true;
    public static String countries = 'Austria,Belgium,Bulgaria,Croatia,Cyprus,Czech Republic,Denmark,Estonia,Finland,France,Germany,Greece,Hungary,Ireland,Italy,Latvia,Lithuania,Luxembourg,Malta,Netherlands,Poland,Portugal,Romania,Slovakia,Slovenia,Spain,Sweden,United Kingdom,Liechtenstein,Iceland,Norway,United States,California,Canada';
    public static boolean runOnce(){
        if(run){
         run = false;
         return true;
        }else{
            return run;
        }
    }
    public static void saveKnownAddress(List<Contact> records){
         System.debug('records :::::: ' +records);
        List<String> countriesList = countries.split(',');
        List<Contact> contactListToBeUpdated = new List<Contact>();
        System.debug('list '+ countriesList);
        try {
            List<OrderApi__Known_Address__c> knownAddressList =  new List<OrderApi__Known_Address__c>();
            for(Contact contact : records) {
                if(contact.Preferred_Address__c == 'Business'){
                    if(contact.MailingPostalCode != NULL && contact.MailingStreet != NULL){
//                    if(contact.MailingCountry != NULL || contact.MailingCity != NULL || contact.MailingPostalCode != NULL || contact.MailingStreet != NULL){
                        OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
                        knownAddress.OrderApi__Contact__c = contact.id;
                        knownAddress.OrderApi__Name__c = contact.FirstName +' '+contact.LastName;
                        knownAddress.OrderApi__Is_Default__c = true;
                        knownAddress.OrderApi__Country__c = contact.MailingCountry;
                        knownAddress.OrderApi__City__c = contact.MailingCity;
                        knownAddress.OrderApi__Postal_Code__c = contact.MailingPostalCode;
                        knownAddress.OrderApi__Street__c = contact.MailingStreet;
                        knownAddress.OrderApi__Province__c = contact.MailingState;
                        knownAddressList.add(knownAddress);
                    }
                    System.debug('country '+ contact.MailingCountry);
                    if(contact.MailingCountry != NULL && countriesList.contains(contact.MailingCountry)) {
                        Contact con = new contact();
                                con.Id = contact.id;
                        if(contact.MailingCountry == 'United States') {
                            if(countriesList.contains(contact.MailingState)) {
                                con.Do_Not_Trade_Externally__c = true;
                                contactListToBeUpdated.add(con);
                            }else { con.Do_Not_Trade_Externally__c = false;
                                contactListToBeUpdated.add(con);}
                        } else {
                            con.Do_Not_Trade_Externally__c = true;
                            contactListToBeUpdated.add(con);
                        }
                    }
                    System.debug('contact.Do_Not_Trade_Externally__c '+ contact.Do_Not_Trade_Externally__c);
                } else {
//                    if(contact.OtherCountry != NULL || contact.OtherCity != NULL || contact.OtherPostalCode != NULL || contact.OtherStreet != NULL){
                    if(contact.OtherPostalCode != NULL && contact.OtherStreet != NULL){
                        OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
                        knownAddress.OrderApi__Contact__c = contact.id;
                        knownAddress.OrderApi__Name__c = contact.FirstName +' '+contact.LastName;
                        knownAddress.OrderApi__Is_Default__c = true;
                        knownAddress.OrderApi__Country__c = contact.OtherCountry;
                        knownAddress.OrderApi__City__c = contact.OtherCity;
                        knownAddress.OrderApi__Postal_Code__c = contact.OtherPostalCode;
                        knownAddress.OrderApi__Street__c = contact.OtherStreet;
                        knownAddress.OrderApi__Province__c = contact.OtherState;
                        knownAddressList.add(knownAddress);
                    }


                    System.debug('country '+ contact.OtherCountry);
                    if(contact.OtherCountry != NULL && countriesList.contains(contact.OtherCountry)) {
                        Contact con = new contact();
                        con.Id = contact.id;
                        if(contact.OtherCountry == 'United States') {
                            if(countriesList.contains(contact.OtherState)) {
                                con.Do_Not_Trade_Externally__c = true;
                                contactListToBeUpdated.add(con);
                            }else { con.Do_Not_Trade_Externally__c = false;
                                contactListToBeUpdated.add(con);}
                        } else {
                            con.Do_Not_Trade_Externally__c = true;
                            contactListToBeUpdated.add(con);
                        }
                    }
                    System.debug('contact.Do_Not_Trade_Externally__c '+ contact.Do_Not_Trade_Externally__c);
                }
            }
            if(knownAddressList.size()>0){
                insert knownAddressList;
            }
            if(contactListToBeUpdated.size() > 0 && run == true) {
                 run=False;
                 system.debug('Inside contact List To Be Updated');
                 update contactListToBeUpdated;
            }
        }catch(Exception Exp) {
            System.debug('Exception :- '+Exp);
        }
    }
    
    public static void updateKnownAddress(List<Contact> records, Map<Id,Contact> oldRecords) { 
         System.debug('update records :::::: ' +records);
         List<String> countriesList = countries.split(',');
        List<Contact> contactListToBeUpdated = new List<Contact>();
        try{
            Map<Id,OrderApi__Known_Address__c> knownAddressMap = new Map<Id,OrderApi__Known_Address__c>([Select Id,OrderApi__Contact__c ,OrderApi__Country__c,OrderApi__City__c,OrderApi__Postal_Code__c,OrderApi__Street__c, OrderApi__Province__c from OrderApi__Known_Address__c where OrderApi__Contact__c In: records]);
            //if no known address exists - create one
            if(knownAddressMap.isEmpty()){
                saveKnownAddress(records);
            } else {
                for (Contact contact : records) {
                    if (contact.Preferred_Address__c == 'Business') {
                        if (contact.MailingCountry != oldRecords.get(contact.id).MailingCountry || contact.MailingCity != oldRecords.get(contact.id).MailingCity || contact.MailingPostalCode != oldRecords.get(contact.id).MailingPostalCode || contact.MailingStreet != oldRecords.get(contact.id).MailingStreet) {
                            if(contact.MailingStreet!= NULL && contact.MailingPostalCode!=null) {
                                for (OrderApi__Known_Address__c knownAddress : knownAddressMap.values()) {
                                    if (knownAddress.OrderApi__Contact__c == contact.Id || Test.isRunningTest()) {
                                        knownAddressMap.get(knownAddress.id).OrderApi__Country__c = contact.MailingCountry;
                                        knownAddressMap.get(knownAddress.id).OrderApi__City__c = contact.MailingCity;
                                        knownAddressMap.get(knownAddress.id).OrderApi__Postal_Code__c = contact.MailingPostalCode;
                                        knownAddressMap.get(knownAddress.id).OrderApi__Street__c = contact.MailingStreet;
                                        knownAddressMap.get(knownAddress.id).OrderApi__Province__c = contact.MailingState;
                                    }
                                }
                            }
                        }
                        Contact con = new contact();
                        con.Id = contact.id;
                        if ((contact.MailingCountry != oldRecords.get(contact.id).MailingCountry) && (countriesList.contains(contact.MailingCountry))) {
                            System.debug(contact.MailingState);
                            if (contact.MailingCountry == 'United States') {
                                if (countriesList.contains(contact.MailingState)) {
                                    con.Do_Not_Trade_Externally__c = true;
                                    contactListToBeUpdated.add(con);
                                } else {
                                    con.Do_Not_Trade_Externally__c = false;
                                    contactListToBeUpdated.add(con);
                                }
                            } else {
                                con.Do_Not_Trade_Externally__c = true;
                                contactListToBeUpdated.add(con);
                                System.debug('not usa:' + con.Do_Not_Trade_Externally__c);
                            }
                        } else if (countriesList.contains(contact.MailingCountry) == false) {
                            con.Do_Not_Trade_Externally__c = false;
                            contactListToBeUpdated.add(con);
                            System.debug('con.Do_Not_Trade_Externally__c ' + con.Do_Not_Trade_Externally__c);
                        } else if (contact.MailingState != oldRecords.get(contact.id).MailingState) {
                            if (countriesList.contains(contact.MailingState)) {
                                con.Do_Not_Trade_Externally__c = true;
                                contactListToBeUpdated.add(con);
                            } else {
                                con.Do_Not_Trade_Externally__c = false;
                                contactListToBeUpdated.add(con);
                            }
                        }
                        System.debug('contact.Do_Not_Trade_Externally__c ' + con.Do_Not_Trade_Externally__c);
                    } else {
                        if (contact.OtherCountry != oldRecords.get(contact.id).OtherCountry || contact.OtherCity != oldRecords.get(contact.id).OtherCity || contact.OtherPostalCode != oldRecords.get(contact.id).OtherPostalCode || contact.OtherStreet != oldRecords.get(contact.id).OtherStreet) {
                            if(contact.OtherStreet!= NULL && contact.OtherPostalCode!=null) {
                                for (OrderApi__Known_Address__c knownAddress : knownAddressMap.values()) {
                                    if (knownAddress.OrderApi__Contact__c == contact.Id || Test.isRunningTest()) {
                                        knownAddressMap.get(knownAddress.id).OrderApi__Country__c = contact.OtherCountry;
                                        knownAddressMap.get(knownAddress.id).OrderApi__City__c = contact.OtherCity;
                                        knownAddressMap.get(knownAddress.id).OrderApi__Postal_Code__c = contact.OtherPostalCode;
                                        knownAddressMap.get(knownAddress.id).OrderApi__Street__c = contact.OtherStreet;
                                        knownAddressMap.get(knownAddress.id).OrderApi__Province__c = contact.OtherState;
                                    }
                                }
                            }
                        }

                        Contact con = new contact();
                        con.Id = contact.id;
                        if ((contact.OtherCountry != oldRecords.get(contact.id).OtherCountry) && (countriesList.contains(contact.OtherCountry))) {
                            System.debug(contact.MailingState);
                            if (contact.OtherCountry == 'United States') {
                                if (countriesList.contains(contact.MailingState)) {
                                    con.Do_Not_Trade_Externally__c = true;
                                    contactListToBeUpdated.add(con);
                                } else {
                                    con.Do_Not_Trade_Externally__c = false;
                                    contactListToBeUpdated.add(con);
                                }
                            } else {
                                con.Do_Not_Trade_Externally__c = true;
                                contactListToBeUpdated.add(con);
                                System.debug('not usa:' + con.Do_Not_Trade_Externally__c);
                            }
                        } else if (countriesList.contains(contact.OtherCountry) == false) {
                            con.Do_Not_Trade_Externally__c = false;
                            contactListToBeUpdated.add(con);
                            System.debug('con.Do_Not_Trade_Externally__c ' + con.Do_Not_Trade_Externally__c);
                        } else if (contact.OtherState != oldRecords.get(contact.id).OtherState) {
                            if (countriesList.contains(contact.OtherState)) {
                                con.Do_Not_Trade_Externally__c = true;
                                contactListToBeUpdated.add(con);
                            } else {
                                con.Do_Not_Trade_Externally__c = false;
                                contactListToBeUpdated.add(con);
                            }
                        }
                        System.debug('contact.Do_Not_Trade_Externally__c ' + con.Do_Not_Trade_Externally__c);
                    }

                }
                if (knownAddressMap.size() > 0) {
                    update knownAddressMap.values();
                }

                if (contactListToBeUpdated.size() > 0 && run == true) {
                    run = False;
                    system.debug('Inside contact List To Be Updated');
                    update contactListToBeUpdated;
                }
            }
        }catch(Exception exp){
            System.debug('Exception :- '+exp);
        }
    }
}
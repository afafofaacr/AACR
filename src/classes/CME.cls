global class CME extends Framework.Domain {
 
    public CME (List<CME__c> sObjectList) {
        super(sObjectList);
    }
 
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new CME (sObjectList);
        }
    }
}
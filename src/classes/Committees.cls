global class Committees extends Framework.Domain {
 
    public Committees (List<Committees__c> sObjectList) {
        super(sObjectList);
    }
 
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new Committees (sObjectList);
        }
    }
}
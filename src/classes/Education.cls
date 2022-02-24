global class Education extends Framework.Domain {
 
    public Education (List<Education__c> sObjectList) {
        super(sObjectList);
    }
 
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new Education (sObjectList);
        }
    }
}
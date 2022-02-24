global class Fon_ContactTrigger extends Framework.Domain{

    public Fon_ContactTrigger(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_ContactTrigger(sObjectList);
        }
    }

    public override void beforeInsert(){
    }
    public override void afterInsert(){
        Framework.Log.push(Fon_ContactTrigger.class.getName(),'afterInsert');
//        Fon_ContactService.saveKnownAddress((List<Contact>) records);
        Framework.Log.pop();
    }

    public override void afterUpdate(Map<Id,SObject> oldMap){
        System.debug('entry update');
        Framework.Log.push(Fon_ContactTrigger.class.getName(),'afterUpdate');
//            Fon_ContactService.updateKnownAddress((List<Contact>)records,(Map<Id,Contact>)oldMap);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Fon_ContactTrigger.class.getName(),'beforeUpdate');
        Framework.Log.pop();
    }

    /*public override void beforeDelete(){
        
    } */

}
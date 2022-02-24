public class DW_ProgressBarCtrl {
    public list<String> pageNamesWithSO    { get; set; }
    public String soId { get; set; }
    public DW_ProgressBarCtrl() {
        soId = '';
        pageNamesWithSO = new List<String>();
        DW_ManagePagesWithSalesOrder__c mc = DW_ManagePagesWithSalesOrder__c.getValues( 'Page Names' );
        system.debug( 'settingsVal: '+mc.Page_Name__c );
        pageNamesWithSO = mc.Page_Name__c.split(',');
        system.debug( 'pageNames with SO: '+pageNamesWithSO );
        
        Contact UserContactData = new Contact();
        UserContactData = DW_ECRMHelper.getCurrentLoginContact();
        system.debug( 'current contact data: '+UserContactData ); 
        if( UserContactData != NULL && String.isNotBlank( UserContactData.Id ) ) {
            soId = DW_ECRMUtils.getSalesOrderId( UserContactData.Id );
        }
    }
	@RemoteAction
	public static DW_ECRMDTO.Response getProgressBarDetails( String stepId, Boolean isFirstStep ) {
    	system.debug('stepId from DW_ProgressBarCtrl: '+stepId );
    	String joinProcessId = '';
    	Integer lastAccessdStepOrder = 0;  
    	//Integer stepsCount = 0;
    	Map<String,Object> progressBarData = new Map<String,Object>();
    	//get which join process is accessed from current step Id
    	if( String.isNotBlank( stepId ) ){
            try{
                joinProcessId = [ SELECT Id, joinapi__Join_Process__c FROM joinapi__Step__c WHERE Id =: stepId ].joinapi__Join_Process__c;
            } catch( Exception exp ){
                return new DW_ECRMDTO.Response( false, 'Exception Occured while fetching join process: '+ exp.getMessage() + '\t' + exp.getStackTraceString(), NULL );
            }
        }
        system.debug( 'joinProcessId: '+joinProcessId );
        //get all steps of current join process and add in steps list
        if( String.isNotBlank( joinProcessId ) ) { 
           
            Decimal order = [SELECT Id, joinapi__Join_Process__c, joinapi__Order__c 
                             FROM joinapi__Step__c 
                             WHERE joinapi__Join_Process__c =: joinProcessId
                             ORDER BY joinapi__Order__c LIMIT 1].joinapi__Order__c;
            
        	//get current community user contact
        	Contact UserContactData = new Contact();
        	UserContactData = DW_ECRMHelper.getCurrentLoginContact();
        	system.debug( 'current contact data: '+UserContactData ); 
        	if( UserContactData != NULL && String.isNotBlank( UserContactData.Id ) ) {
        	/*try{
                stepsCount = database.countQuery( 'SELECT count() FROM joinapi__Step__c WHERE joinapi__Join_Process__c =: joinProcessId' );
            } catch( Exception exp ){
                return new DW_ECRMDTO.Response( false, 'Exception Occured while fetching join process steps: '+ exp.getMessage() + '\t' + exp.getStackTraceString(), NULL );
            }
        	if( stepsCount > 0 ) {*/
        		//get current step data
        		joinapi__Step__c currentStep = new joinapi__Step__c();
                if( isFirstStep ) {
                    currentStep = [ SELECT Id, Name, joinapi__Next_Step__c, joinapi__Page_Title__c, joinapi__Order__c, Hide_in_Progress_Bar__c,
                    joinapi__Visual_Force_Page_API_Name__c FROM joinapi__Step__c WHERE joinapi__Order__c =: order 
                    AND joinapi__Join_Process__c =: joinProcessId ];
                } else {
        			currentStep = [ SELECT Id, Name, joinapi__Next_Step__c, joinapi__Page_Title__c, joinapi__Order__c,Hide_in_Progress_Bar__c, 
                    joinapi__Visual_Force_Page_API_Name__c FROM joinapi__Step__c WHERE Id =: stepId 
                    AND joinapi__Join_Process__c =: joinProcessId ];
                }
                String nextStepURL = new joinApi.JoinUtils(currentStep.Id).navStepsMap.get('Next');
                String prevStepURL = new joinApi.JoinUtils(currentStep.Id).navStepsMap.get('Previous');
                /*
                * Append sales order id for those pages which need it ( Journal subscrption, Working groups, Optional Items )
                * Pages added in custom settings
                */
                DW_ManagePagesWithSalesOrder__c mc = DW_ManagePagesWithSalesOrder__c.getValues( 'Page Names' );
                system.debug( 'settingsVal: '+mc.Page_Name__c );
                List<String> pageNames = mc.Page_Name__c.split(',');
                system.debug( 'pageNames: '+pageNames );
                for( String pageName : pageNames ) {
                	//if previous step url contains page name then append salesorder id in url
                	if( prevStepURL != NULL && prevStepURL.contains( pageName.trim() ) ) {
                		system.debug( 'prevStepURL: '+prevStepURL+' contains: '+prevStepURL.contains( pageName )+ 'pageName: '+pageName );
                		//get sales order of current user which is closed and posted
                		String salesOrderId = DW_ECRMUtils.getSalesOrderId( UserContactData.Id );
                        system.debug( 'salesOrderId: '+salesOrderId );
                		//prevStepURL = appendUrlParam( prevStepURL,'salesOrder', salesOrderId );
                		if( salesOrderId != Null ) {
	                		if( prevStepURL.contains( '?' ) ) {
					    		prevStepURL = prevStepURL+'&salesOrder='+salesOrderId;
					    	} else {
					    		prevStepURL = prevStepURL+'?salesOrder='+salesOrderId;
					    	}
				    	}
                	}
                }
                /*if( currentStep.joinapi__Visual_Force_Page_API_Name__c != NULL && 
                	list.contains( currentStep.joinapi__Visual_Force_Page_API_Name__c ) ) {
					
                }*/
                DW_ECRMDTO.StepDTO singleStep = new DW_ECRMDTO.StepDTO();
                singleStep.Id = currentStep.Id;
                singleStep.nextStepUrl = nextStepURL;
                singleStep.prevStepUrl = prevStepURL;
                singleStep.nextStepId = currentStep.joinapi__Next_Step__c;
                singleStep.order = Integer.valueOf( currentStep.joinapi__Order__c );
                singleStep.title = currentStep.joinapi__Page_Title__c;
                singleStep.pageName = currentStep.joinapi__Visual_Force_Page_API_Name__c;
                
                singleStep.isSkip = currentStep.Hide_in_Progress_Bar__c ? true : false ;
        		progressBarData.put( 'step', singleStep ); 

        		//get last accessed step from junction object of contact and join process
	        	List<contact_last_accessed_step__c> lastAccessedStepData = new List<contact_last_accessed_step__c>();
	        	lastAccessedStepData = [ SELECT Id, Name, Step_Order__c FROM contact_last_accessed_step__c WHERE Contact__c =: UserContactData.Id AND Join_Process__c =: joinProcessId LIMIT 1 ];
	        	system.debug( 'lastAccessedStepData:'+lastAccessedStepData );
	        	if( lastAccessedStepData.size() > 0 ) {
	        		lastAccessdStepOrder = Integer.valueOf( lastAccessedStepData[ 0 ].Step_Order__c );
	        	}
	        	//progressBarData.put( 'totalSteps', stepsCount );
	        	progressBarData.put( 'lastAccessdStepOrder', lastAccessdStepOrder );
	        	progressBarData.put( 'joinProcessId', joinProcessId ); 
	        	progressBarData.put( 'contactId', UserContactData.Id ); 
        	//} 
        	}       	      	
        	
        }
    	return new DW_ECRMDTO.Response( true, '', progressBarData );
    }

    public String appendUrlParam( String currentUrl, String paramKey, String paramValue ) {
    	if( currentUrl.contains( '?' ) ) {
    		currentUrl = currentUrl+'&'+paramKey+'='+paramValue;
    	} else {
    		currentUrl = currentUrl+'?'+paramKey+'='+paramValue;
    	}
    	return currentUrl;
    }
}
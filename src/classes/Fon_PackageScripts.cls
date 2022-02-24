/**************************************************************************************************************************************************************************************************************************************************************
Name            :-  Fon_PackageScripts
Created Date    :-  05/15/2018
Updated Date    :-  
Created By      :-  Arpita Munjal
Dependencies    :-  
Description     :-  Spark Admin and test class
**************************************************************************************************************************************************************************************************************************************************************/

public with sharing class Fon_PackageScripts {

    public static void install() {

        Framework.RegisteredApp AACREApp = new Framework.RegisteredApp();
        AACREApp.apexNamespace = '';
        AACREApp.namespace = 'AACR';
        AACREApp.installClass = Fon_PackageScripts.Install.class.getName();
        AACREApp.isManaged = false;
        AACREApp.isEnabled = true;
        AACREApp.isPaid = false;
        AACREApp.developerEmail = 'implementations@fonteva.com';
        AACREApp.owner = 'AACR';
        AACREApp.description = 'Customizations built by Fonteva to support the implementation of MemberNation for AACR.';
        AACREApp.Name = 'AACR Customizations';
        Framework.Config.push(AACREApp);


        //Register Objects
        Framework.RegisteredObject[] regObjects = new List<Framework.RegisteredObject>();
        

        //Framework.Config.push(regObjects);

        // Routing Rules --- Alphabetically --- 
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
       
        Framework.RoutingRule sos = new Framework.RoutingRule();
        sos.apexClass = Fon_TransactionTrigger.class.getName();
        sos.namespace = 'AACR';
        sos.isEnabled = true;
        sos.sObjectName = 'OrderApi__Transaction__c';
        sos.executionOrder = 1;
        rules.add(sos);


        Framework.Config.push(rules);

    }

    /*public class Rollups implements Framework.Scriptable {
        public void run() {
            Framework.Log.push(Fon_PackageScripts.class.getName(),'.Scripts.createRollups');
            Framework.Log.pop();
        }
    }*/

    public static void testInstall() {
        Framework.Installer.install();
		PagesApi.PackageScripts.install();
		OrderApi.PackageScripts.install();
		EventApi.PackageScripts.install();
		CPBase.PackageScripts.install();
		ROEApi.PackageScripts.install();
		LTE.PackageScripts.install();

        install();
    }

    public class Install implements Framework.Scriptable {
        public void run() {
            /*Framework.Log.push(Fon_PackageScripts.Install.class.getName(),'run');

            //testInstall();

            try {
                new Rollups().run();
            } catch (Exception ex) {
                Framework.Log.debugException(ex);
            }
            Framework.Log.pop();*/
        }
    }

}
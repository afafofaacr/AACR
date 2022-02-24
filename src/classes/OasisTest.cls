/**
 * Created by lauren.lezberg on 1/8/2021.
 */

public with sharing class OasisTest {
    AsyncCttOasisWsPROD.OasisWSGetReportResponse_elementFuture resp;
    public Long result {get;set;}

    public Continuation startRequest() {
        // Create continuation. Argument is timeout in seconds.
        // more to come here
        AsyncCttOasisWsPROD.AsyncOasisWSSoap oa = new AsyncCttOasisWsPROD.AsyncOasisWSSoap();

        cttOasisWsPROD.AuthenticationHeader ah = new cttOasisWsPROD.AuthenticationHeader();
        ah.SecurityTokenKey = 'tom.pham@aacr.org';
        ah.SecurityTokenValue='tom.pham@';

        oa.AuthenticationHeader = ah;

//        System.debug('oa: ' + oa);

        Continuation con = new System.Continuation(120);
        con.continuationMethod = 'processResponse';

        try {
            resp = oa.beginGetReport(con, '00A038F4-EEDE-47F2-9CC7-4B11E18D97F5', '___PUBLICATIONS_PLANNER: Presenter Display Status');
        } catch(Exception e){
            System.debug('exception: ' + e.getMessage());
        }

        return con;
    }

    public Object processResponse(){
        System.debug('processing response....');
        result = Long.valueOf(resp.getValue());
//        result = result.substring(0, 50);


        System.debug('result: ' + result);
        return null;
    }



}
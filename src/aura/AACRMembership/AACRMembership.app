<!--
 - Created by lauren.lezberg on 2/14/2019.
 -->

<aura:application description="All lightning components related to AACRMembership(Profile,Login,JoinProcess,etc)" extends="ltng:outApp">
    <aura:dependency resource="c:MyMembership"/>
    <aura:dependency resource="c:MembershipCategories"/>
    <aura:dependency resource="c:JP_Container"/>
    <aura:dependency resource="c:selfRegister"/>

    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>
    <aura:dependency resource="markup://force:showToast" type="EVENT"/>
    <aura:dependency resource="markup://force:createRecord" type="EVENT"/>
</aura:application>
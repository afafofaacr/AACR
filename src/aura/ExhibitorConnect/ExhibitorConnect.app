<!--
 - Created by afaf.awad on 2/2/2021.
 -->

<aura:application description="ExhibitorConnect"  access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess">
    <aura:dependency resource="c:EC_AccountInfo"/>
    <aura:dependency resource="c:JP_Container"/>
    <aura:dependency resource="c:EC_Dashboard"/>

    <aura:dependency resource="markup://force:showToast" type="EVENT"/>
</aura:application>
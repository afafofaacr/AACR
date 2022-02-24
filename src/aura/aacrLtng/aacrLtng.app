<!--
 - Created by lauren.lezberg on 12/5/2018.
 -->

<aura:application description="aacrLtng" extends="ltng:outApp">

    <!--<aura:dependency resource="c:forgotPassword"/> -->
    <aura:dependency resource="c:AACRSiteMaintenance"/>
    <!--<aura:dependency resource="c:JP_ItemSelection"/>-->
    <!--<aura:dependency resource="c:JP_ScientificInterest"/>-->
    <!--<aura:dependency resource="c:JP_ProgressBar"/>-->
    <!--<aura:dependency resource="c:JP_JournalSelections"/>-->
    <!--<aura:dependency resource="c:JP_OptionalItemSelection"/>-->
    <!--<aura:dependency resource="c:JP_WorkingGroupSelection"/>-->
    <!--<aura:dependency resource="c:JP_EducationInfo"/>-->
    <!--<aura:dependency resource="c:JP_PersonalInformation"/>-->
    <!--<aura:dependency resource="c:JP_CheckoutCart"/>-->
    <!--<aura:dependency resource="c:JP_Nominators"/>-->
    <!--<aura:dependency resource="c:JP_MembershipSelection"/>-->
    <aura:dependency resource="c:UpdatePersonalInformation"/>
    <aura:dependency resource="c:CompanyLookup"/>
    <aura:dependency resource="c:MyAddresses"/>
    <aura:dependency resource="c:PaymentBillingAddress"/>

    <aura:dependency resource="c:JP_Container"/>
    <aura:dependency resource="c:JP_CheckoutCart"/>
    <aura:dependency resource="c:JP_ContainerClone"/>
    <aura:dependency resource="c:MembershipCategories"/>
    <aura:dependency resource="c:VolunteerForm"/>
    <aura:dependency resource="c:ModifyAACRGroups"/>
    <aura:dependency resource="c:CommunicationPreferences"/>
    <aura:dependency resource="c:AdvocateAppConfirmation"/>
    <!--<aura:dependency resource="c:SaveButton"/>-->
<!--    <aura:dependency resource="c:UpdateAssistants"/>-->

    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>
    <aura:dependency resource="markup://force:showToast" type="EVENT"/>
    <aura:dependency resource="markup://force:createRecord" type="EVENT"/>

</aura:application>
import { LightningElement, wire } from 'lwc';
import digitalGuestBookLandingImage1 from '@salesforce/resourceUrl/DigitalGuestBookLandingImage1';
import digitalGuestBookLandingImage2 from '@salesforce/resourceUrl/DigitalGuestBookJaguar1';
import digitalGuestBookLandingImage3 from '@salesforce/resourceUrl/DigitalGuestBookLandRover1';
import getRetailerData from '@salesforce/apex/CustomerRegistrationFlowController.getRetailerData';
import insertLead from '@salesforce/apex/CustomerRegistrationFlowController.insertLead';
import getVehicleSpecifications from '@salesforce/apex/CustomerRegistrationFlowController.getVechicleSpecificationData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRetailerCampaigns from '@salesforce/apex/CustomerRegistrationFlowController.getRetailerCampaigns';
import searchCampaignMembers from '@salesforce/apex/CustomerRegistrationFlowController.searchCampaignMembers';
import setCampaignMemberAsResponded from '@salesforce/apex/CustomerRegistrationFlowController.setCampaignMemberAsResponded';

export default class DigitalGuestBook extends LightningElement {
    
    //Campagin Selection
    selectedCampaign = 'retailerShowroom'; 
    selectedCampaignMember = '';
    campaigns = [
        { label: '전시장 방명록', value: 'retailerShowroom' }
    ];

    campaignSelected = false;
    campaignMemberSearchTerm = '';
    zeroResultsForCampaignMembersSearch = false;
    campaignMembers;
    
    showNewLead = false;
    isModalOpen = false;
    disableButton=true;
    digitalGuestBookLandingImage1 = digitalGuestBookLandingImage1;
    digitalGuestBookLandingImage2 = digitalGuestBookLandingImage2;
    digitalGuestBookLandingImage3 = digitalGuestBookLandingImage3;

    retailerName = 'JLR';
    showroomName = 'Guest Book';

    // Refactored
    vehicleSpecifications = [];
    jlrBrandOptions = [];
    jlrBrandSelected;
    jlrModelOptionsDisplayed = [];
    jlrModelSelected;
    jlrModelOptionsDisabled = true;
    currentVehicleBrandOptions = [];
    currentVehcileBrandSelected;
    currentVehicleModelSelected;
    currentVehicleModelOptionsDisplayed = [];
    currentVehicleModelOptionsDisabled = true;

    preferredretailerOptions = [];
    preferredRetailerSelected;
    retailserUsers ={};

    ownerOptions = [];
    allOwnerOptions=[];
    ownerValue;

    // Not refactored
    lastName;
    strMobile;
    strEmail;
    strGender;
    strDateofBirth;
    
    
    
    cityAddress;
    stateAddress;
    // HK add ---Start---
    streetAddress;
    countryAddress;
    postalCodeAddress;
    // HK add ---End---
    
    
    strAdditionalInformationInpChange;

    disableCofirmButton = true;

    //Form Submission Consents
    mandatoryTerm1 = false;
    mandatoryTerm2 = false;
    mandatoryTerm3 = false;
    marketingConsent = false;
    disableDataSubmissionPreConsent = true;

    // HK add ---Start---
    handleSaveAddress(event){
        var addressInfo = event.detail;
        this.cityAddress = addressInfo.cityAddr;
        this.stateAddress = addressInfo.stateAddr;
        this.streetAddress = addressInfo.streetAddr;
        this.countryAddress = '대한민국';
        this.postalCodeAddress = addressInfo.postalAddr;
    }
    // HK add ---End---
    

    handleClickNewRegistraiton() {
        this.showNewLead = true;
    }


    @wire(getRetailerCampaigns)
    loadCampaigns({error, data}){
        if(error) {
            console.log('error occurred.');
        }
        if(data) {
            var loadedCampaigns = [
                { label: '전시장 방명록', value: 'retailerShowroom' }
            ];
            console.log('  data --> ' + JSON.stringify(data) + ' error -->  ' + JSON.stringify(error) );
            console.log('mod1');
            console.log(data); 
           
            data.map( item => {
                const campaignItem = {}
                console.log('i am here inside data.map');
                console.log(item.Name);
                campaignItem.label = item.Name;
                campaignItem.value = item.Id;
                loadedCampaigns.push(campaignItem);
            });
            this.campaigns = loadedCampaigns;
            console.log(this.campaigns);
        }
    }

    handleCampaignSelection(event) {
        if(event) {
            this.selectedCampaign = event.detail.value;
        }
        
        if(this.selectedCampaign === 'retailerShowroom' ) {
            this.campaignSelected = false;
        } else {
            this.campaignSelected = true;
        }
    }

    

    handleCampaignMemberSearchTermChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchTerm = event.target.value;
        this.delayTimeout = setTimeout(() => {
			this.campaignMemberSearchTerm = searchTerm;
            console.log('changed search term');
            if(!searchTerm) {
                return;
            }
            this.lastName = searchTerm;
            searchCampaignMembers({
                campaignId: this.selectedCampaign, 
                searchTerm: this.campaignMemberSearchTerm
            })
            .then(members => {
                console.log('called search apex');
                const updatedCampaignMembers = [];
                members.map(item => {
                    console.log(item);
                    const campaignMemberItem = {};
                    const lastName = item.LastName ? item.LastName : '';
                    const mobile = item.MobilePhone ? item.MobilePhone : ''

                    campaignMemberItem.label = lastName +' - ' + mobile;
                    campaignMemberItem.value = item.Id;
                    campaignMemberItem.leadId = item.LeadId;
                    updatedCampaignMembers.push(campaignMemberItem);
                });
                if(updatedCampaignMembers.length > 0) {
                    this.zeroResultsForCampaignMembersSearch = false;
                    this.campaignMembers = updatedCampaignMembers;
                } else {
                    this.campaignMembers = undefined;
                    this.zeroResultsForCampaignMembersSearch = true;
                }
                
            })
            .catch(err => {
                
            })
		}, 300);
    }

    handleCampaignMemberSelection(event) {
        this.selectedCampaignMember = event.detail.value;
    }

    handleConfirmAttendence() {

        const selectedCampaignMember = this.campaignMembers.filter(x => x.value === this.selectedCampaignMember)[0];

        setCampaignMemberAsResponded({campaignMemberId: selectedCampaignMember.value})
            .then(() => {
                this.resetLeadCaptureDetails();
                const evt = new ShowToastEvent({
                    title: 'Success (Pending Korean Message)',
                    message: 'Guest Attendance Confirmed',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            })
            .catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Error (Pending Korean Message)',
                    message: 'Error Attemtping to update Guest Attendance',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            })

        
    }


    @wire(getVehicleSpecifications)
    loadVehicles({error, data}) {
        if(error) {
            console.log('Error loading brand data');
        }
        if(data) {
            const retrievedVehicleSpecifications = [];
            const retrievedJlrBrandOption = [];
            const retrievedCurrentVehicleBrandOption = [];
            
            data.map(brandDefinition => {
                const brandOption = {};
                brandOption.label = brandDefinition.Name;
                brandOption.value = brandDefinition.Id;
                brandOption.Make__c = brandDefinition.Make__c;
                
                retrievedVehicleSpecifications.push(brandOption);

                if(brandDefinition.aop_JLR_Owned__c === true && brandDefinition.RecordType.DeveloperName === 'Make'){
                    retrievedJlrBrandOption.push(brandOption);   
                }


                if(brandDefinition.RecordType.DeveloperName === 'Make'){
                    retrievedCurrentVehicleBrandOption.push(brandOption);   
                }

            });

            this.vehicleSpecifications = retrievedVehicleSpecifications;
            this.jlrBrandOptions = retrievedJlrBrandOption;
            this.currentVehicleBrandOptions = retrievedCurrentVehicleBrandOption;
            
        }

    }
    //preferred retailer
    @wire(getRetailerData)
    loadRetailerData({error, data}) {
        if(error) {
            console.log('error loading Preferredretailer data');
        }
        if(data) {
            const retrievedPreferredretailerOption = [];
            const output = JSON.parse(data);
            console.log('output is here');
            console.log(output);
            let currentUserRetailerId;
            try {
                currentUserRetailerId = output.currentUser.Contact.AccountId;
            } catch (error) {
                // do nothing
            }
            

            output.retailerAccounts.map(PreferredretailerDefinition => {
                const PreferredretailerOption = {};
                PreferredretailerOption.label = PreferredretailerDefinition.NameLocal;
                PreferredretailerOption.value = PreferredretailerDefinition.Id;
                retrievedPreferredretailerOption.push(PreferredretailerOption);

                if(PreferredretailerDefinition.Id === currentUserRetailerId && currentUserRetailerId) {
                    this.showroomName = PreferredretailerDefinition.NameLocal;
                }
            });
            this.retailserUsers = output.userList;

            const retrievedConsultantOptions = [];
            Object.entries(output.userList).forEach(usr => {
               const ownerOption = {
                    label: usr[1].LastName,
                    value: usr[1].Id
                };
                retrievedConsultantOptions.push(ownerOption);
            })
            
            this.ownerOptions = retrievedConsultantOptions;
            this.allOwnerOptions = retrievedConsultantOptions;

            console.log('@@output.currentUser.Id@@'+output.currentUser.Id);
            this.ownerValue = output.currentUser.Id;

            this.preferredretailerOptions = retrievedPreferredretailerOption;
            console.log('@@output.currentUser.Contact.AccountId'+output.currentUser.Contact.AccountId);
               // const currentUserRetailerId = output.currentUser.Contact.AccountId;
                this.preferredRetailerSelected = output.currentUser.Contact.AccountId;
                console.log('@@@preferredRetailerSelected@@300@@'+this.preferredRetailerSelected);
                /*
                const retailerNameParts = output.currentUser.Contact.Account.Name.split(' - ');
                this.retailerName = retailerNameParts[0];
                this.showroomName = retailerNameParts[1];
                */

            
        }
    }



    get GenderOptions() {
        return [
            { label: '남성', value: 'Male' },
            { label: '여성', value: 'Female' },
        ];
    }

    // Input Handlers

    handleLastNameChange(event){
        this.lastName = event.detail.value;
        this.verifyMandatoryFields();
    }
     
    phoneInpChange(event){
        this.strMobile = event.detail.value;
        this.verifyMandatoryFields();
    }
    EmailInpChange(event){
        this.strEmail = event.detail.value;
    }
    GenderInpChange(event){
        this.strGender = event.detail.value;
    }
    DateofBirthInpChange(event){
        this.strDateofBirth = event.detail.value;
    }
    cityInpChange(event){
        this.cityAddress = event.detail.value;
    }
    StateInpChange(event){
        this.stateAddress = event.detail.value;
    }
    
    
    
    currentVehicleInpChange(event){
        this.strCurrentVehicle = event.detail.value;
    }
    currentVehicleBrandInpChange(event){
        this.strcurrentVehicleBrandInpChange = event.detail.value;
    }
    AdditionalInformationInpChange(event){
        this.strAdditionalInformationInpChange = event.detail.value;
    }
    

    handleJlrBrandSelection(event) {
        this.jlrBrandSelected = event.detail.value;
        this.jlrModelOptionsDisplayed = this.vehicleSpecifications.filter(x => x.Make__c === this.jlrBrandSelected);
        this.jlrModelSelected = undefined;
        this.jlrModelOptionsDisabled = false;
        this.verifyMandatoryFields();
    }

    handleJlrModelSelection(event) {
        this.jlrModelSelected = event.detail.value;
        this.verifyMandatoryFields();
    }

    handleCurrentBrandSelection(event) {
        this.currentVehcileBrandSelected = event.detail.value;
        this.currentVehicleModelOptionsDisplayed = this.vehicleSpecifications.filter(x => x.Make__c === this.currentVehcileBrandSelected);
        this.currentVehicleModelSelected = undefined;
        this.currentVehicleModelOptionsDisabled = this.currentVehicleModelOptionsDisplayed.length === 0;
    }

    handleCurrentModelSelection(event) {
        this.currentVehicleModelSelected = event.detail.value;
    }

    preferredRetailerChange(event) {
        debugger;
        this.preferredRetailerSelected = event.detail.value;
        console.log(' this.preferredRetailerSelected '+this.preferredRetailerSelected);
       
        let matchNotfound = true ;
        const retrievedConsultantOptions = [];
        try{
        Object.entries(this.retailserUsers).forEach(usr => {
          
           
            if(usr[1].Contact!== undefined && usr[1].Contact.AccountId === this.preferredRetailerSelected){

                console.log(usr[1].Contact.AccountId );
                const ownerOption = {
                    label: usr[1].LastName,
                    value: usr[1].Id
                };
                retrievedConsultantOptions.push(ownerOption); 
                matchNotfound=false;   
            }
           
            
        });
    }
    catch(error){
      console.log('error'+JSON.stringify(error));
    }
       
    if( matchNotfound ){
        this.ownerOptions=[];
    }
    else{
        this.ownerOptions=retrievedConsultantOptions;
    }
       
        this.verifyMandatoryFields();
     

    }

    leadOwnerChange(event) {
        this.ownerValue = event.detail.value;
        this.verifyMandatoryFields();
    }

    


    verifyMandatoryFields(){
        console.log('@@check  this.lastName@@'+ this.lastName);
        console.log('@@check  this.strMobile@@'+ this.strMobile);
        console.log('@@check  this.jlrBrandSelected@@'+ this.jlrBrandSelected);
        console.log('@@check  this.jlrModelSelected@@'+ this.jlrModelSelected);
        console.log('@@check  this.preferredRetailerSelected@@'+ this.preferredRetailerSelected);
        console.log('@@check  this.ownerValue@@'+ this.ownerValue);
     this.disableCofirmButton = !(
        this.lastName && this.strMobile && this.jlrBrandSelected && 
        this.jlrModelSelected && this.preferredRetailerSelected && this.ownerValue) ;
    }

    

    // Modal Controls
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.marketingConsent = false;
        this.mandatoryTerm1 = false;
        this.mandatoryTerm2 = false;
        this.mandatoryTerm3 = false;
        
        this.isModalOpen = false;
        this.disableButton=true;
        this.disableDataSubmissionPreConsent = true;
    }
    
    
    handleMandatoryOption1() {
        this.mandatoryTerm1 = !this.mandatoryTerm1;
        this.checkDataSubmissionConsent();
    }

    
    handleMandatoryOption2() {
        this.mandatoryTerm2 = !this.mandatoryTerm2;
        this.checkDataSubmissionConsent();
    }

    
    handleMandatoryOption3() {
        this.mandatoryTerm3 = !this.mandatoryTerm3;
        this.checkDataSubmissionConsent();
    }

    
    handleMarketingConsent() {
        this.marketingConsent = !this.marketingConsent;
    }

    

    checkDataSubmissionConsent() {
        this.disableDataSubmissionPreConsent = !(
            this.mandatoryTerm1 && this.mandatoryTerm2 && this.mandatoryTerm3
        );
    }
    
    
    
    
    // Insert record.
    handlesubmit(){
      const lead = {};
      lead.LastName = this.lastName;
      lead.MobilePhone = this.strMobile;
      lead.Email = this.strEmail;
      lead.Brand__c = this.jlrBrandSelected;
      lead.Primary_Model_Interest__c = this.jlrModelSelected;
      lead.Current_Vehicle_Brand__c = this.currentVehcileBrandSelected;
      lead.Current_Vehicle__c = this.currentVehicleModelSelected;
      lead.Preferred_Retailer__c = this.preferredRetailerSelected;

      lead.Gender__c = this.strGender;
      lead.Date_of_Birth__c = this.strDateofBirth;
      lead.City = this.cityAddress;
      lead.State = this.stateAddress;
      
      

      if(this.selectedCampaign != 'retailerShowroom') {
        lead.Campaign__c = this.selectedCampaign;
      }

      //lead.LeadSource = 'Retailer Website';
      
      lead.Country_ISO_Code__c = 'KR';

      lead.et4ae5__HasOptedOutOfMobile__c = !this.marketingConsent;
      lead.DoNotCall = !this.marketingConsent;
      lead.Whitemail_Opt_Out__c = !this.marketingConsent;
      lead.HasOptedOutOfEmail = !this.marketingConsent;
    
      lead.OwnerId = this.ownerValue;
      
      lead.Description = this.strAdditionalInformationInpChange;
      
      const leadData = JSON.stringify(lead);
      insertLead({leadData: leadData})
        .then(result => {
            console.log('Lead Created');
        })
        .catch((error) => {
            
            
            const evt = new ShowToastEvent({
                title: '오류',
                message: '필수정보를 확인하시기 바랍니다.',
                variant: 'error'
                    });
                    this.dispatchEvent(evt);
            });

        this.resetLeadCaptureDetails();
        this.isModalOpen = false;
        this.disableButton = true;
       
        const evt = new ShowToastEvent({
            title: '성공',
            message: '방명록에 등록되었습니다.',
            variant: 'success'
        });
        this.dispatchEvent(evt);
        this.isModalOpen = false;
        this.disableButton = true;

          
    } //handle submit end here
    

    resetLeadCaptureDetails() {
        console.log('reset triggered');

        this.lastName = undefined;
        this.strMobile = undefined;
        this.strEmail = undefined;
        
        
        this.strAdditionalInformationInpChange = undefined;
        this.strGender = undefined;
        this.strDateofBirth = undefined;
        this.cityAddress = undefined;
        this.strCurrentVehicle = undefined;
        
        this.strcurrentVehicleBrandInpChange = undefined;
        
        this.cityAddress = undefined;
        this.stateAddress = undefined;

        this.jlrBrandSelected = undefined;
        this.jlrModelSelected = undefined;
        this.currentVehcileBrandSelected = undefined;
        this.currentVehicleModelSelected = undefined;
        
        this.allowDataSubmissionWithConsent = false;
        this.marketingConsent = false;
        this.mandatoryTerm1 = false;
        this.mandatoryTerm2 = false;
        this.mandatoryTerm3 = false;

        this.disableCofirmButton = true;
        this.showNewLead = false;

        this.campaignMemberSearchTerm = undefined;
        this.campaignMembers = undefined;
        this.selectedCampaignMember = undefined;

        this.zeroResultsForCampaignMembersSearch = false;
        this.disableDataSubmissionPreConsent=true;
        this.jlrModelOptionsDisabled=true;
        this.verifyMandatoryFields();

    }

}
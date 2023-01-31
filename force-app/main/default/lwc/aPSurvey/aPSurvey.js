import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import surveydata from '@salesforce/apex/ap_surveyController.getSUrveyData';
import saveSurveyResponses from '@salesforce/apex/ap_surveyController.saveSurveyResponses';
import FORM_FACTOR from '@salesforce/client/formFactor';
import Background_Image from '@salesforce/resourceUrl/AP_Survey_Form_Background_Image';

export default class aPSurvey extends LightningElement {
    @api opId;
    objData;
    header;
    isoCode;
    heading1;
    heading2;
    pSYourdetails;
    pSPermissionBox;
    pSToAgree;
    secHeader1;
    secHeader2;
    secHeader3;
    secHeader4;
    secHeader5;
    secHeader6;
    secHeader7;
    secHeader8;
    secHeader9;
    secHeader10;
    secHeader11;
    secHeader12;
    @track surveyTypePurchase = false;
    @track showSecHeader1 = false;
    @track showSecHeader2 = false;
    @track showSecHeader3 = false;
    @track showSecHeader4 = false;
    @track showSecHeader5 = false;
    @track showSecHeader6 = false;
    @track showSecHeader7 = false;
    @track showSecHeader8 = false;
    @track showSecHeader9 = false;

    @track questionFieldAPI;
    @track answerFieldAPI;
    @track defaultordernumber = 1;
    @track defaultLang;
    @track isBilingual = false;
    @track tradingName;
    @track surveyConfig;
    @track countryOptions = null;
    @track showcountryoption = false;
    @track defanswers = [];
    @track nextVisiblity = true;
    @track backVisiblity = false;
    @track submitVisiblity = false;
    @track totalpages;
    @api error;
    @track pagetext;
    @track ofText;
    @track nextText;
    @track backText;
    @track submitText;
    @track requiredText;
    @track arrQnA = [];
    @track quesArr = [];
    @track mapAnswers;
    @track mapQuestions;
    mapQuestionwithPageNum;
    mapQIdtoAnswer;
    @track textAnsReCId;
    @track mapOfListValues = [];
    @track confirmationMessage;
    @track confirmationMessage2;
    @api isForm ;
    @track isSuccess = false;
    @api isError = false;
    isLoaded = true;
    @track pbControl;
    textPlaceholder;
    @api isTradingAvailable;

    isForm = true;
    @wire(surveydata, {
        opportunityId: '$opId'
    })
    wiredobjData({
        error,
        data
    }) {
        if (data) {
            this.objData = data;                      
            if (this.objData.errMsg != '') {              
                this.header = this.objData.formHeader;
                this.tradingName = this.objData.tradingName;               
                this.isTradingAvailable = this.tradingName == ''?  false : true;              
                document.title = this.header + ' - ' + this.objData.tradingName;
                this.isSuccess = false;
                this.isError = true;
                this.isForm = false;
                this.error = this.objData.errMsg;
            } else {
                this.isTradingAvailable = this.tradingName == ''?  false : true;
                this.isSuccess = false;
                this.isError = false;
                this.isForm = true;
                this.error = this.objData.errMsg;
                this.header = this.objData.formHeader;
                this.tradingName = this.objData.tradingName;
                this.surveyConfig = this.objData.surveyConfig;
                this.defaultLang = this.surveyConfig.Default_Language__c != 'English' ? this.surveyConfig.Default_Language__c : 'English';
                this.isoCode = this.surveyConfig.Label;
                this.totalpages = this.objData.totalQuestion;
                this.progressbarwidth = 100 / this.totalpages;
                this.template.querySelector(`[data-id="pbControl"]`).style.width = this.progressbarwidth + '%';
                this.pbControl = this.progressbarwidth;
                console.log(this.progressbarwidth);
                this.mapQuestionwithPageNum = this.objData.mapQuestionswithPageNumber;
                this.mapAnswers = this.objData.mapAnswers;
                this.mapQuestions = this.objData.mapQuestions;
                this.mapQIdtoAnswer = this.objData.mapQIdtoAnswers;
                document.title = this.header + ' - ' + this.objData.tradingName;
                if (this.surveyConfig.Text_for_Local_Language__c != null) {
                    this.showcountryoption = true;
                    this.countryOptions = [{
                            label: this.surveyConfig.Text_for_Local_Language__c,
                            value: this.surveyConfig.Default_Language__c
                        },
                        {
                            label: 'English (United Kingdom)',
                            value: 'English'
                        },
                    ];
                }
                this.fn_SurveyData();
            }
        } else if (error) {
            console.log('this.objData--' +JSON.stringify(error));
          //  this.header = this.objData.formHeader;
          //  this.tradingName = this.objData.tradingName;
            this.error = 'You are not allowed to participate in this survey. Please contact your retailer for more information.';
            this.isError = true;
            this.isSuccess = false;
            this.isForm = false;
            this.objData = null;
        }
    }

    ContainerCSS() {
        let css = `background-repeat: no-repeat; background-attachment: fixed; height: 100vh; `;
        css += `background-image: url(${Background_Image}); background-size: 100vw auto; `;
        css += `position:absolute; top:0; bottom:0; left:0; right:0; overflow:scroll; `;
        css += `overflow-y: scroll; /* Hide vertical scrollbar */ overflow-x: hidden; /* Hide horizontal scrollbar */ z-index:-1;`;
        console.log(css);
        return css;

    }

    ContainerCSSsmall() {
        let css = `background-repeat: no-repeat; background-attachment: fixed; height: 100vh; `;
       // css += `background-image: url(${Background_Image}); `;
        css += ` -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover;   `;
        // css += `overflow-y: scroll; /* Hide vertical scrollbar */ overflow-x: hidden; /* Hide horizontal scrollbar */ z-index:-1;`;
        // console.log(css);
        return css;

    }

    get bodyClass() {
        return FORM_FACTOR == 'Large' ? 'formbody' : 'formbodySmall';
    }

    get formContainerClass() {
        return FORM_FACTOR == 'Large' ? this.ContainerCSS() : this.ContainerCSSsmall();
    }


    get dropdownClass(){
        return FORM_FACTOR == 'Large' ? 'countryslot' : 'countryslotsmall';
    }

    get formmainClass(){
        return FORM_FACTOR == 'Large' ? 'formmain' : 'formmainsmall';
    }

    get formfooterClass(){
        return FORM_FACTOR == 'Large' ? 'formfooter' : 'formfootersmall';
    }

    get heading(){
        return FORM_FACTOR == 'Large' ? 'headingsection' : 'headingsectionsmall';
    }
    get formTitle(){
        return FORM_FACTOR == 'Large' ? 'formtitle' : 'formtitlesmall';
    }

    get starrate(){
        return FORM_FACTOR == 'Large' ? 'starrate' : 'starratesmall';
    }

    get buttoncontainer(){
        return FORM_FACTOR == 'Large' ? 'buttoncontainer' : 'buttoncontainersmall';
    }

    get navigationbarcontainer(){
        return FORM_FACTOR == 'Large' ? 'navigationbarcontainer' : 'navigationbarcontainersmall';
    }

    get progressbarcontainer(){
        return FORM_FACTOR == 'Large' ? 'progressbarcontainer' : 'progressbarcontainersmall';   
    }

    fn_SurveyData() {
        var meta = document.createElement("meta");
        meta.setAttribute("name", "viewport");
        meta.setAttribute("content", "width=device-width, initial-scale=1, shrink-to-fit=no");
        
        document.getElementsByTagName('head')[0].appendChild(meta);
       
        this.isBilingual = this.surveyConfig.Bilingual_Form__c;
        this.questionFieldAPI = this.defaultLang != 'English' ? this.surveyConfig.API_Name_of_Question__c : this.surveyConfig.API_Name_of_Question_in_English__c;
        this.answerFieldAPI = this.defaultLang != 'English' ? this.surveyConfig.API_Name_of_Answer__c : this.surveyConfig.API_Name_of_Answer_in_English__c;
       // this.confirmationMessage = this.defaultLang != 'English' ? this.surveyConfig.Purchase_Survey_Confirmation_Message__c : this.surveyConfig.English_Purchase_Confirmation_Message__c;
        //this.confirmationMessage1 = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Confirmation_Message__c : this.surveyConfig.English_Service_Confirmation_Message__c;
      
      
        if (this.objData.surveyType === 'Purchase') {
            this.surveyTypePurchase = true;
            this.heading1 = this.defaultLang != 'English' ? this.surveyConfig.Heading_1_Translated__c : this.surveyConfig.Heading_1_in_English__c;
            this.heading2 = this.defaultLang != 'English' ? this.surveyConfig.Heading_2_Translated__c : this.surveyConfig.Heading_2_in_English__c;
            this.pSYourdetails = this.defaultLang != 'English' ? this.surveyConfig.ps_Your_details_English__c : this.surveyConfig.ps_Your_details_English__c;
            this.pSPermissionBox = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_Permission_box_English__c; 
            this.pSToAgree = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_To_agree_English__c; 
            this.secHeader1 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_4_Translated__c : this.surveyConfig.Sec_Header_4_English__c; 
            this.secHeader2 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_7_Translated__c : this.surveyConfig.Sec_Header_7_English__c; 
            this.secHeader3 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_12_Translated__c : this.surveyConfig.Sec_Header_12_English__c; 
            this.secHeader4 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_13_Translated__c : this.surveyConfig.Sec_Header_13_English__c; 
            this.secHeader5 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_14_Translated__c : this.surveyConfig.Sec_Header_14_English__c;
            this.secHeader6 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_15_Translated__c : this.surveyConfig.Sec_Header_15_English__c;
            this.secHeader7 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_16_Translated__c : this.surveyConfig.Sec_Header_16_English__c;
            this.secHeader8 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_10_Translated__c : this.surveyConfig.Sec_Header_10_English__c; 
            this.secHeader9 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_11_Translated__c : this.surveyConfig.Sec_Header_11_English__c; 
            this.confirmationMessage = this.defaultLang != 'English' ? this.surveyConfig.Purchase_Survey_Confirmation_Message__c : this.surveyConfig.English_Purchase_Confirmation_Message__c;

        } else {
            this.surveyTypePurchase = false;
            this.heading1 = this.defaultLang != 'English' ? this.surveyConfig.Heading_1_Translated__c : this.surveyConfig.Heading_1_in_English__c;
            this.heading2 = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Heading_2_Translated__c : this.surveyConfig.Service_Survey_Heading_2_English__c;
            this.pSYourdetails = this.defaultLang != 'English' ? this.surveyConfig.ps_Your_details_English__c : this.surveyConfig.ps_Your_details_English__c;
            this.pSPermissionBox = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_Permission_box_English__c; 
            this.pSToAgree = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_To_agree_English__c; 
            this.secHeader1 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_1_Translated__c : this.surveyConfig.Sec_Header_1_English__c; 
            this.secHeader2 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_2_Translated__c : this.surveyConfig.Sec_Header_2_English__c; 
            this.secHeader3 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_3_Translated__c : this.surveyConfig.Sec_Header_3_English__c; 
            this.secHeader4 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_4_Translated__c : this.surveyConfig.Sec_Header_4_English__c; 
            this.secHeader5 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_5_Translated__c : this.surveyConfig.Sec_Header_5_English__c; 
            this.secHeader6 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_6_Translated__c : this.surveyConfig.Sec_Header_6_English__c; 
            this.secHeader7 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_7_Translated__c : this.surveyConfig.Sec_Header_7_English__c; 
            this.secHeader8 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_8_Translated__c : this.surveyConfig.Sec_Header_8_English__c; 
            this.secHeader9 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_9_Translated__c : this.surveyConfig.Sec_Header_9_English__c; 
            this.secHeader10 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_10_Translated__c : this.surveyConfig.Sec_Header_10_English__c; 
            this.secHeader11 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_11_Translated__c : this.surveyConfig.Sec_Header_11_English__c; 
            this.secHeader12 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_17_Translated__c : this.surveyConfig.Sec_Header_17_English__c;
            this.confirmationMessage = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Confirmation_Message__c : this.surveyConfig.English_Service_Confirmation_Message__c;

        }
        this.pagetext = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Page__c : 'Page';
        this.ofText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Of__c : 'of';
        this.nextText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Next__c : 'Next';
        this.backText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Back__c : 'Back';
        this.submitText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Submit__c : 'Submit';
        this.requiredText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Required__c : 'Required';
        this.textPlaceholder = this.defaultLang != 'English' ? this.surveyConfig.Hint_Text_for_Text_Answers__c : 'Enter your answer';

        for (let key in this.mapQuestionwithPageNum) {
            if (this.mapQuestionwithPageNum.hasOwnProperty(key)) {
                this.quesArr = [];
                let isDependent;
                for (let i = 0; i < this.mapQuestionwithPageNum[key].length; i++) {
                    isDependent = this.mapQuestionwithPageNum[key][i].Primary_Dependent__c === 'Primary' ? true : false;
                    this.defanswers = [];
                    this.textAnsReCId = this.mapQuestionwithPageNum[key][i].Answer_Type__c === 'Text' ? this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][0].Id : '';
                    let questionObj = '';
                    if (this.defaultLang != 'English') {
                        if (this.answerFieldAPI === 'Cambodian__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Cambodian__c;
                        } else if (this.answerFieldAPI === 'Chinese__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Chinese__c;
                        } else if (this.answerFieldAPI === 'Laos__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Laos__c;
                        } else if (this.answerFieldAPI === 'Burmese__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Burmese__c;
                        } else if (this.answerFieldAPI === 'Thai__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Thai__c;
                        } else if (this.answerFieldAPI === 'Mongolian__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Mongolian__c;
                        } else if (this.answerFieldAPI === 'Vietnamese__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Vietnamese__c;
                        } else if (this.answerFieldAPI === 'French__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].French__c;
                        } else if (this.answerFieldAPI === 'Bahasa__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Bahasa__c;
                        } else if (this.answerFieldAPI === 'Brunei__c') {
                            questionObj = this.mapQuestionwithPageNum[key][i].Brunei__c;
                        }  else {
                            questionObj = this.mapQuestionwithPageNum[key][i].English__c;
                        }
                    } else {
                        questionObj = this.mapQuestionwithPageNum[key][i].English__c;
                    }
                    for (var j = 0; j < this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id].length; j++) {
                        if (this.defaultLang != 'English') {
                            if (this.answerFieldAPI === 'Cambodian__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Cambodian__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Chinese__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Chinese__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Laos__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Laos__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Burmese__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Burmese__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Thai__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Thai__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Mongolian__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Mongolian__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Vietnamese__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Vietnamese__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Bahasa__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Bahasa__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            } else if (this.answerFieldAPI === 'Brunei__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Brunei__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            }else if (this.answerFieldAPI === 'French__c') {
                                this.defanswers.push({
                                    'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].French__c,
                                    'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                                });
                            }

                        } else {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].English__c,
                                'value': this.mapQIdtoAnswer[this.mapQuestionwithPageNum[key][i].Id][j].Id
                            });
                        }
                    }
                    let questions = {
                        serialNo: '',
                        qName: this.mapQuestionwithPageNum[key][i].Name,
                        qtype: this.mapQuestionwithPageNum[key][i].Question_Type__c,
                        sortorder: this.mapQuestionwithPageNum[key][i].Sort_Order__c,
                        recordId: this.mapQuestionwithPageNum[key][i].Id,
                        ansType: this.mapQuestionwithPageNum[key][i].Answer_Type__c,
                        isText: this.mapQuestionwithPageNum[key][i].Answer_Type__c === 'Text' ? true : false,
                        isRadio: this.mapQuestionwithPageNum[key][i].Answer_Type__c === 'Radio' ? true : false,
                        isStar: this.mapQuestionwithPageNum[key][i].Answer_Type__c === 'Star Rating' ? true : false,
                        isCheckbox: this.mapQuestionwithPageNum[key][i].Answer_Type__c === 'Checkbox' ? true : false,
                        textAnswerId: this.textAnsReCId,
                        isRequired: this.mapQuestionwithPageNum[key][i].Required__c,
                        selectedRadioAnswer: '',
                        selectedTextAnswer: '',
                        selectedStarAnswer: '',
                        selectedCheckBoxAnswer: '',
                        showDependent: isDependent,
                        isOtherType: false,
                        otherTypeValue: '',
                        dependenQues: this.mapQuestionwithPageNum[key][i].Primary_Dependent__c === 'Primary' ? false : true,
                        selectedQuestion: this.mapQuestionwithPageNum[key][i].Id,
                        pORd: this.mapQuestionwithPageNum[key][i].Primary_Dependent__c,
                        question: questionObj,
                        answers: this.defanswers
                    }
                    this.quesArr.push(questions);
                }
                this.mapOfListValues.push({
                    key: key,
                    value: this.quesArr
                });
            }
        }
        this.arrQnA = this.searchValueFromKey(this.defaultordernumber, this.mapOfListValues);

        //Rearrange serial numbers
        this.reArrangeSerialNumbers();
        
    }

    searchValueFromKey(defaultNum, myArray) {
        for (var i = 0; i < myArray.length; i++) {
            if (myArray[i].key == defaultNum) {
                return myArray[i];
            }
        }
    }



    handleCountryChange(event) {
        this.defaultLang = event.target.value;
        this.questionFieldAPI = this.defaultLang != 'English' ? this.surveyConfig.API_Name_of_Question__c : this.surveyConfig.API_Name_of_Question_in_English__c;
        this.answerFieldAPI = this.defaultLang != 'English' ? this.surveyConfig.API_Name_of_Answer__c : this.surveyConfig.API_Name_of_Answer_in_English__c;
        if (this.objData.surveyType === 'Purchase') {
            this.heading1 = this.defaultLang != 'English' ? this.surveyConfig.Heading_1_Translated__c : this.surveyConfig.Heading_1_in_English__c;
            this.heading2 = this.defaultLang != 'English' ? this.surveyConfig.Heading_2_Translated__c : this.surveyConfig.Heading_2_in_English__c;
            this.pSYourdetails = this.defaultLang != 'English' ? this.surveyConfig.ps_Your_details_English__c : this.surveyConfig.ps_Your_details_English__c;
            this.pSPermissionBox = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_Permission_box_English__c; 
            this.pSToAgree = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_To_agree_English__c; 
            this.secHeader1 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_4_Translated__c : this.surveyConfig.Sec_Header_4_English__c; 
            this.secHeader2 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_7_Translated__c : this.surveyConfig.Sec_Header_7_English__c; 
            this.secHeader3 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_12_Translated__c : this.surveyConfig.Sec_Header_12_English__c; 
            this.secHeader4 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_13_Translated__c : this.surveyConfig.Sec_Header_13_English__c; 
            this.secHeader5 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_14_Translated__c : this.surveyConfig.Sec_Header_14_English__c;
            this.secHeader6 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_15_Translated__c : this.surveyConfig.Sec_Header_15_English__c;
            this.secHeader7 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_16_Translated__c : this.surveyConfig.Sec_Header_16_English__c;
            this.secHeader8 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_10_Translated__c : this.surveyConfig.Sec_Header_10_English__c; 
            this.secHeader9 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_11_Translated__c : this.surveyConfig.Sec_Header_11_English__c; 
            this.confirmationMessage = this.defaultLang != 'English' ? this.surveyConfig.Purchase_Survey_Confirmation_Message__c : this.surveyConfig.English_Purchase_Confirmation_Message__c;

          /*  this.heading1 = this.defaultLang != 'English' ? this.surveyConfig.Heading_1_Translated__c : this.surveyConfig.Heading_1_in_English__c;
            this.heading2 = this.defaultLang != 'English' ? this.surveyConfig.Heading_2_Translated__c : this.surveyConfig.Heading_2_in_English__c;*/
        } else {
            this.heading1 = this.defaultLang != 'English' ? this.surveyConfig.Heading_1_Translated__c : this.surveyConfig.Heading_1_in_English__c;
            this.heading2 = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Heading_2_Translated__c : this.surveyConfig.Service_Survey_Heading_2_English__c;
            this.pSYourdetails = this.defaultLang != 'English' ? this.surveyConfig.ps_Your_details_English__c : this.surveyConfig.ps_Your_details_English__c;
            this.pSPermissionBox = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_Permission_box_English__c; 
            this.pSToAgree = this.defaultLang != 'English' ? this.surveyConfig.PS_Permission_box_English__c : this.surveyConfig.PS_To_agree_English__c; 
            this.secHeader1 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_1_Translated__c : this.surveyConfig.Sec_Header_1_English__c; 
            this.secHeader2 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_2_Translated__c : this.surveyConfig.Sec_Header_2_English__c; 
            this.secHeader3 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_3_Translated__c : this.surveyConfig.Sec_Header_3_English__c; 
            this.secHeader4 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_4_Translated__c : this.surveyConfig.Sec_Header_4_English__c; 
            this.secHeader5 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_5_Translated__c : this.surveyConfig.Sec_Header_5_English__c; 
            this.secHeader6 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_6_Translated__c : this.surveyConfig.Sec_Header_6_English__c; 
            this.secHeader7 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_7_Translated__c : this.surveyConfig.Sec_Header_7_English__c; 
            this.secHeader8 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_8_Translated__c : this.surveyConfig.Sec_Header_8_English__c; 
            this.secHeader9 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_9_Translated__c : this.surveyConfig.Sec_Header_9_English__c; 
            this.secHeader10 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_10_Translated__c : this.surveyConfig.Sec_Header_10_English__c; 
            this.secHeader11 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_11_Translated__c : this.surveyConfig.Sec_Header_11_English__c; 
            this.secHeader12 = this.defaultLang != 'English' ? this.surveyConfig.Sec_Header_17_Translated__c : this.surveyConfig.Sec_Header_17_English__c;
            this.confirmationMessage = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Confirmation_Message__c : this.surveyConfig.English_Service_Confirmation_Message__c;
            /*this.heading1 = this.defaultLang != 'English' ? this.surveyConfig.Heading_1_Translated__c : this.surveyConfig.Heading_1_in_English__c;
            this.heading2 = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Heading_2_Translated__c : this.surveyConfig.Service_Survey_Heading_2_English__c;*/
        }

        this.pagetext = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Page__c : 'Page';
        this.ofText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Of__c : 'of';
        this.nextText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Next__c : 'Next';
        this.backText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Back__c : 'Back';
        this.submitText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Submit__c : 'Submit';
        this.requiredText = this.defaultLang != 'English' ? this.surveyConfig.Translation_for_Required__c : 'Required';
        this.textPlaceholder = this.defaultLang != 'English' ? this.surveyConfig.Hint_Text_for_Text_Answers__c : 'Enter your answer';
      //  this.confirmationMessage = this.defaultLang != 'English' ? this.surveyConfig.Purchase_Survey_Confirmation_Message__c : this.surveyConfig.English_Purchase_Confirmation_Message__c;
       // this.confirmationMessage1 = this.defaultLang != 'English' ? this.surveyConfig.Service_Survey_Confirmation_Message__c : this.surveyConfig.English_Service_Confirmation_Message__c;
      
        for (let i = 0; i < this.mapOfListValues.length; i++) {
            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                let questionObj = '';
                if (this.defaultLang != 'English') {
                    if (this.questionFieldAPI === 'Cambodian__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Cambodian__c;
                    } else if (this.questionFieldAPI === 'Chinese__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Chinese__c;
                    } else if (this.questionFieldAPI === 'Laos__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Laos__c;
                    } else if (this.questionFieldAPI === 'Burmese__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Burmese__c;
                    } else if (this.questionFieldAPI === 'Thai__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Thai__c;
                    } else if (this.questionFieldAPI === 'Mongolian__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Mongolian__c;
                    } else if (this.questionFieldAPI === 'Vietnamese__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Vietnamese__c;
                    } else if (this.questionFieldAPI === 'Bahasa__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Bahasa__c;
                    }else if (this.questionFieldAPI === 'Brunei__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].Brunei__c ;
                    }else if (this.questionFieldAPI === 'French__c') {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].French__c;
                    } else {
                        questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].English__c;
                    }

                } else {
                    questionObj = this.mapQuestions[this.mapOfListValues[i].value[j].recordId].English__c;
                }
                this.mapOfListValues[i].value[j].question = questionObj;
                this.defanswers = [];
                this.enanswers = [];
                for (var k = 0; k < this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId].length; k++) {
                    if (this.defaultLang != 'English') {
                        if (this.answerFieldAPI === 'Cambodian__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Cambodian__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Chinese__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Chinese__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Laos__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Laos__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Burmese__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Burmese__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Thai__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Thai__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Mongolian__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Mongolian__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Vietnamese__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Vietnamese__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'Bahasa__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Bahasa__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        }else if (this.answerFieldAPI === 'Brunei__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Brunei__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        } else if (this.answerFieldAPI === 'French__c') {
                            this.defanswers.push({
                                'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].French__c,
                                'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                            });
                        }

                    } else {
                        this.defanswers.push({
                            'label': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].English__c,
                            'value': this.mapQIdtoAnswer[this.mapOfListValues[i].value[j].recordId][k].Id
                        });
                    }
                }
                this.mapOfListValues[i].value[j].answers = this.defanswers;
            }
        }
    }
   

    handleNext(event) {
       /* this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.name == 'LastName'){
                console.log('element', event.target.checked);
              
               if(event.target.checked){
                    console.log('inpTrue');
                }else{
                    console.log('inpFalse');
                return inputField.checkValidity();;
            }
            }            
       });
       */
       
        const isRadioCorrect = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isRadioCorrect) {
            let myDiv = this.template.querySelector(`[data-id="formbody1"]`);
            myDiv.scrollIntoView({
                block: 'start',
                behavior: 'smooth'
            });
            this.progressbarwidth = this.progressbarwidth + this.pbControl;
            this.template.querySelector(`[data-id="pbControl"]`).style.width = this.progressbarwidth + '%';

            if (this.defaultordernumber <= this.totalpages) {
                this.showcountryoption = false;
                this.backVisiblity = true;
                this.defaultordernumber += 1;
                this.arrQnA = this.searchValueFromKey(this.defaultordernumber, this.mapOfListValues);
            }
            if (this.defaultordernumber == this.totalpages) {
                this.submitVisiblity = true;
                this.nextVisiblity = false;
                this.backVisiblity = true;
            }
        }
        this.reArrangeSerialNumbers();
        
    }


    handleBack(event) {
        this.progressbarwidth = this.progressbarwidth - this.pbControl;
        this.template.querySelector(`[data-id="pbControl"]`).style.width = this.progressbarwidth + '%';
        let myDiv = this.template.querySelector(`[data-id="formbody1"]`);
        myDiv.scrollIntoView({
            block: 'start',
            behavior: 'smooth'
        });
        if (this.defaultordernumber != '1') {
            this.defaultordernumber -= 1;
            this.arrQnA = this.searchValueFromKey(this.defaultordernumber, this.mapOfListValues);
        }
        if (this.defaultordernumber == '1') {
            this.backVisiblity = false;
            if (this.surveyConfig.Text_for_Local_Language__c != null) {
              this.showcountryoption = true;
            }
        }
        if (this.defaultordernumber < this.totalpages) {
            this.submitVisiblity = false;
            this.nextVisiblity = true;
        }
        this.reArrangeSerialNumbers();
    }

    reArrangeSerialNumbers() {
    
        if(this.defaultordernumber == 2){
            this.showSecHeader1 = true;
        }else{
            this.showSecHeader1 = false;
        }
        if(this.defaultordernumber == 3){
            this.showSecHeader2 = true;
        }else{
            this.showSecHeader2 = false;
        }
        if(this.defaultordernumber == 4){
            this.showSecHeader3 = true;
        }else{
            this.showSecHeader3 = false;
        }
        if(this.defaultordernumber == 5){
            this.showSecHeader4 = true;
        }else{
            this.showSecHeader4 = false;
        }
        if(this.defaultordernumber == 6){
            this.showSecHeader5 = true;
        }else{
            this.showSecHeader5 = false;
        }
        if(this.defaultordernumber == 7){
            this.showSecHeader6 = true;
         }else{
            this.showSecHeader6 = false;
        }
        if(this.defaultordernumber == 8){
            this.showSecHeader7 = true;
        }else{
            this.showSecHeader7 = false;
        }
        if(this.defaultordernumber == 9){
            this.showSecHeader8 = true;
        }else{
            this.showSecHeader8 = false;
        }
        if(this.defaultordernumber == 10){
            this.showSecHeader9 = true;
        }else{
            this.showSecHeader9 = false;
        }
        
        let sr = 1;
        for (let i = 0; i < this.mapOfListValues.length; i++) {
            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                if (this.mapOfListValues[i].value[j].showDependent === true) {
                    this.mapOfListValues[i].value[j].serialNo = sr;
                    sr++;
                }

            }
        }
    }

    handleRadioChange(event) {
        let answerId = event.target.value;

        //Skip primary questions
        if (typeof this.mapAnswers[answerId].Dependent_Question__c != 'undefined') {
            if (this.mapQuestions[this.mapAnswers[answerId].Dependent_Question__c].Primary_Dependent__c === 'Primary') {
                let q1No = this.mapQuestions[this.mapAnswers[answerId].Question__c].Sort_Order__c;
                let q2No = this.mapQuestions[this.mapAnswers[answerId].Dependent_Question__c].Sort_Order__c;
                for (let i = 0; i < this.mapOfListValues.length; i++) {
                    for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                        if (this.mapOfListValues[i].value[j].sortorder > q1No && this.mapOfListValues[i].value[j].sortorder < q2No) {
                            this.mapOfListValues[i].value[j].showDependent = false;
                        } else {
                            // this.mapOfListValues[i].value[j].showDependent  = true;
                        }
                    }
                }
            }
        }
        //Adding/Removing question in main array
        let dependetQsArr = [];
        let dependetQsArr1 = [];

        let otherDependentQues = [];
        if (typeof this.mapAnswers[answerId].Other_Dependent_Questions__c != 'undefined') {
            let depQs = this.mapAnswers[answerId].Other_Dependent_Questions__c.split(';');
            for (let i = 0; i < depQs.length; i++) {
                otherDependentQues.push(depQs[i]);
            }
        }


        let otherDependentToRemove = [];

        for (let i = 0; i < this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c].length; i++) {
            if (!dependetQsArr.includes(this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c][i].Dependent_Question__c)) {
                dependetQsArr.push(this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c][i].Dependent_Question__c);
            }
            if (typeof this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c][i].Other_Dependent_Questions__c != 'undefined') {
                let depQs = this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c][i].Other_Dependent_Questions__c.split(';');
                for (let i = 0; i < depQs.length; i++) {
                    otherDependentToRemove.push(depQs[i]);
                }
            }
        }

        if (typeof this.mapAnswers[answerId].Other_Dependent_Questions__c == 'undefined') {
            for (let i = 0; i < this.mapOfListValues.length; i++) {
                for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                    if (typeof otherDependentToRemove != 'undefined') {
                        if (otherDependentToRemove.length > 0) {
                            if (otherDependentToRemove.includes(this.mapOfListValues[i].value[j].qtype)) {
                                this.mapOfListValues[i].value[j].showDependent = false;
                            }
                        }
                    }
                }
            }
        }
        for (let j = 0; j < dependetQsArr.length; j++) {
            if (dependetQsArr[j] != this.mapAnswers[answerId].Dependent_Question__c) {
                dependetQsArr1.push(dependetQsArr[j]);
            }
        }
        for (let i = 0; i < this.mapOfListValues.length; i++) {
            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                if (this.mapOfListValues[i].value[j].recordId === this.mapAnswers[answerId].Dependent_Question__c) {
                    this.mapOfListValues[i].value[j].showDependent = true;
                }
                if (typeof otherDependentQues != 'undefined') {
                    if (otherDependentQues.length > 0) {
                        if (otherDependentQues.includes(this.mapOfListValues[i].value[j].qtype)) {
                            this.mapOfListValues[i].value[j].showDependent = true;
                        }
                    }
                }
            }
        }

        for (let i = 0; i < dependetQsArr1.length; i++) {
            if (this.mapQIdtoAnswer.hasOwnProperty(dependetQsArr1[i])) {
                for (let j = 0; j < this.mapQIdtoAnswer[dependetQsArr1[i]].length; j++) {
                    if (typeof this.mapQIdtoAnswer[dependetQsArr1[i]][j].Dependent_Question__c != 'undefined') {
                        if (!dependetQsArr1.includes(this.mapQIdtoAnswer[dependetQsArr1[i]][j].Dependent_Question__c)) {
                            dependetQsArr1.push(this.mapQIdtoAnswer[dependetQsArr1[i]][j].Dependent_Question__c);
                        }
                    }
                }
            }
        }
        //Remove value from hidden answers
        for (let i = 0; i < this.mapOfListValues.length; i++) {
            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                for (let k = 0; k < dependetQsArr1.length; k++) {
                    if (this.mapOfListValues[i].value[j].recordId === dependetQsArr1[k]) {
                        this.mapOfListValues[i].value[j].showDependent = false;
                        if (this.mapOfListValues[i].value[j].ansType === 'Text') {
                            this.mapOfListValues[i].value[j].selectedTextAnswer = '';
                        } else if (this.mapOfListValues[i].value[j].ansType === 'Checkbox') {
                            this.mapOfListValues[i].value[j].selectedCheckBoxAnswer = [];
                        } else {
                            this.mapOfListValues[i].value[j].selectedRadioAnswer = '';
                        }
                    }

                }
            }
        }


        //Assign selected radio button
        if (typeof this.mapAnswers[answerId].Question__c != 'undefined') {
            for (let i = 0; i < this.mapOfListValues.length; i++) {
                for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                    if (this.mapOfListValues[i].value[j].recordId === this.mapAnswers[answerId].Question__c) {
                        this.mapOfListValues[i].value[j].selectedRadioAnswer = answerId;
                    }
                }
            }
        }
        // Rearranging serial numbers
        this.reArrangeSerialNumbers();
    }

    //Assign answers to Checkbox
    handleCheckBoxChange(event) {
      
        let questionId = event.target.dataset.id;
        let removeDepQus =  JSON.stringify(event.target.options[0].value);
        removeDepQus = removeDepQus.replaceAll('"', '');
        let dataArray = [];
        dataArray = event.detail.value.join();
        for (let i = 0; i < this.mapOfListValues.length; i++) {
            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                if (this.mapOfListValues[i].value[j].recordId === questionId) {
                    this.mapOfListValues[i].value[j].selectedCheckBoxAnswer = dataArray;
               }
            }
        }

        let checkBoxAnswers = [];
        let answerId =''; 
        if (dataArray != '') {
             checkBoxAnswers = dataArray.split(',');
        } else {
            console.log('enter else');
            for (let i = 0; i < this.mapOfListValues.length; i++) {
                for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                    if (this.mapOfListValues[i].value[j].recordId === questionId) {
                      this.mapOfListValues[i].value[j].isOtherType = false;
                        this.mapOfListValues[i].value[j].otherTypeValue = '';
                        if (typeof this.mapAnswers[removeDepQus].Other_Dependent_Questions__c != 'undefined') {
                            answerId = removeDepQus;
                        }
                    }
                }
            }
        }
        let checkBoxAnswersIds = [];
        let othersQuestionId = ''; 
        if (checkBoxAnswers.length > 0 || answerId !='') {
            for (let i = 0; i < checkBoxAnswers.length; i++) {
                if (typeof this.mapAnswers[checkBoxAnswers[i]].Other_Dependent_Questions__c != 'undefined') {
                    answerId = checkBoxAnswers[i];
                    checkBoxAnswersIds.push(checkBoxAnswers[i]);
                }else{   
                    if (this.mapAnswers[checkBoxAnswers[i]].English__c == 'Other') {
                        othersQuestionId = this.mapAnswers[checkBoxAnswers[i]].Question__c;
                    }
                    if (this.mapAnswers[checkBoxAnswers[i]].English__c == 'Other (please specify)') {
                        othersQuestionId = this.mapAnswers[checkBoxAnswers[i]].Question__c;
                    }
                }
            }

            if(answerId != ''){ 
                let dependetQsArr = [];
                let dependetQsArr1 = [];
                if (typeof this.mapAnswers[answerId].Other_Dependent_Questions__c != 'undefined') {
                    let otherDependentQues = [];
                    if (typeof this.mapAnswers[answerId].Other_Dependent_Questions__c != 'undefined') {
                        let depQs = this.mapAnswers[answerId].Other_Dependent_Questions__c.split(';');
                        for (let i = 0; i < depQs.length; i++) {
                            otherDependentQues.push(depQs[i]);
                        }
                    }
            
                    for (let i = 0; i < this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c].length; i++) {
                        if (!dependetQsArr.includes(this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c][i].Dependent_Question__c)) {
                            dependetQsArr.push(this.mapQIdtoAnswer[this.mapAnswers[answerId].Question__c][i].Dependent_Question__c);
                        }
                    }
                    if(checkBoxAnswers.length > 0){
                        for (let j = 0; j < dependetQsArr.length; j++) {
                            if (dependetQsArr[j] != this.mapAnswers[answerId].Dependent_Question__c) {
                                dependetQsArr1.push(dependetQsArr[j]);
                            }
                        }
                    }else{
                        for (let j = 0; j < dependetQsArr.length; j++) {
                                dependetQsArr1.push(dependetQsArr[j]);
                        }
                    }

                    for (let j = 0; j < checkBoxAnswersIds.length; j++) {
                       for (let k = 0; k < dependetQsArr1.length; k++) {
                            if (dependetQsArr1[k] == this.mapAnswers[checkBoxAnswersIds[j]].Dependent_Question__c) {
                                dependetQsArr1 = dependetQsArr1.filter(value => value !== dependetQsArr1[k]);
                            }
                        }
                    }

                    for (let i = 0; i < this.mapOfListValues.length; i++) {
                        for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                            if (this.mapOfListValues[i].value[j].recordId === this.mapAnswers[answerId].Dependent_Question__c) {
                                this.mapOfListValues[i].value[j].showDependent = true;
                            }
                            if (typeof otherDependentQues != 'undefined') {
                                if (otherDependentQues.length > 0) {
                                    if (otherDependentQues.includes(this.mapOfListValues[i].value[j].qtype)) {
                                        this.mapOfListValues[i].value[j].showDependent = true;
                                    }
                                }
                            }
                        }
                    }
            
                    for (let i = 0; i < dependetQsArr1.length; i++) {
                        if (this.mapQIdtoAnswer.hasOwnProperty(dependetQsArr1[i])) {
                            for (let j = 0; j < this.mapQIdtoAnswer[dependetQsArr1[i]].length; j++) {
                                if (typeof this.mapQIdtoAnswer[dependetQsArr1[i]][j].Dependent_Question__c != 'undefined') {
                                    if (!dependetQsArr1.includes(this.mapQIdtoAnswer[dependetQsArr1[i]][j].Dependent_Question__c)) {
                                        dependetQsArr1.push(this.mapQIdtoAnswer[dependetQsArr1[i]][j].Dependent_Question__c);
                                    }
                                }
                            }
                        }
                    }
                    //Remove value from hidden answers
                    for (let i = 0; i < this.mapOfListValues.length; i++) {
                        for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                            for (let k = 0; k < dependetQsArr1.length; k++) {
                                if (this.mapOfListValues[i].value[j].recordId === dependetQsArr1[k]) {
                                    this.mapOfListValues[i].value[j].showDependent = false;
                                    if (this.mapOfListValues[i].value[j].ansType === 'Text') {
                                        this.mapOfListValues[i].value[j].selectedTextAnswer = '';
                                    } else if (this.mapOfListValues[i].value[j].ansType === 'Checkbox') {
                                        this.mapOfListValues[i].value[j].selectedCheckBoxAnswer = [];
                                    } else {
                                        this.mapOfListValues[i].value[j].selectedRadioAnswer = '';
                                    }
                                }
            
                            }
                        }
                    }
            
            
                    //Assign selected radio button
                    if (typeof this.mapAnswers[answerId].Question__c != 'undefined') {
                        for (let i = 0; i < this.mapOfListValues.length; i++) {
                            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                                if (this.mapOfListValues[i].value[j].recordId === this.mapAnswers[answerId].Question__c) {
                                    this.mapOfListValues[i].value[j].selectedRadioAnswer = answerId;
                                }
                            }
                        }
                    }
                }
            }
            console.log('othersQuestionId--' +othersQuestionId);
            for (let i = 0; i < this.mapOfListValues.length; i++) {
                for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                    if (othersQuestionId != '') {
                        if (this.mapOfListValues[i].value[j].recordId === othersQuestionId) {
                            this.mapOfListValues[i].value[j].isOtherType = true;
                        }
                    } else {
                        if(this.mapOfListValues[i].value[j].recordId === questionId){
                            this.mapOfListValues[i].value[j].isOtherType = false;
                            this.mapOfListValues[i].value[j].otherTypeValue = '';
                        }
                    }
                }
            }
        }
        this.reArrangeSerialNumbers();
    }

    //Assign answer to textbox
    handleTextAnsChange(event) {
        let answerId = event.target.dataset.id;
        if (typeof this.mapAnswers[answerId].Question__c != 'undefined') {
            for (let i = 0; i < this.mapOfListValues.length; i++) {
                for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                    if (this.mapOfListValues[i].value[j].recordId === this.mapAnswers[answerId].Question__c) {
                        this.mapOfListValues[i].value[j].selectedTextAnswer = event.target.value;
                    }
                }
            }
        }
    }

    //Assign answer to textbox
    handleTextBoxOtherChange(event) {
        let answerId = event.target.dataset.id;
        //if (typeof this.mapAnswers[answerId].Question__c != 'undefined') {
        for (let i = 0; i < this.mapOfListValues.length; i++) {
            for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                if (this.mapOfListValues[i].value[j].recordId === answerId) {
                    this.mapOfListValues[i].value[j].otherTypeValue = event.target.value;
                }
            }
        }
        //   }
    }

    //Submit responses
    handleSubmit() {
        const isRadioCorrect = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isRadioCorrect) {
            let myDiv = this.template.querySelector(`[data-id="formbody1"]`);
            myDiv.scrollIntoView({
                block: 'start',
                behavior: 'smooth'
            });
            this.isLoaded = false;
            let responseArray = [];
            for (let i = 0; i < this.mapOfListValues.length; i++) {
                for (let j = 0; j < this.mapOfListValues[i].value.length; j++) {
                    if (this.mapOfListValues[i].value[j].showDependent) {
                        let scoreValue = '';
                        let scoreValueRating = '';
                        let nps;
                        let isUnanswered = true;
                        let medalliaValueAns='';
                      //  let arrAnsShortOrder = '';
                        if (this.mapOfListValues[i].value[j].ansType === 'Text') {
                            scoreValue = this.mapOfListValues[i].value[j].selectedTextAnswer;
                            if (this.mapOfListValues[i].value[j].selectedTextAnswer != '') {
                                isUnanswered = false;
                            }
                        } else if (this.mapOfListValues[i].value[j].ansType === 'Checkbox') {
                            if (this.mapOfListValues[i].value[j].selectedCheckBoxAnswer != '') {
                                let arr = this.mapOfListValues[i].value[j].selectedCheckBoxAnswer.split(',');
                              
                                let tempScoreArray = [];
                                for (let k = 0; k < arr.length; k++) {
                                    if (this.mapAnswers.hasOwnProperty(arr[k])) {
                                        if(this.mapAnswers[arr[k]].Medallia_Value__c != ''){
                                            medalliaValueAns += this.mapAnswers[arr[k]].Medallia_Value__c +',';
                                        }
                                        
                                       // arrAnsShortOrder += this.mapAnswers[arr[k]].Sort_Order__c +',';
                                        if (this.mapAnswers[arr[k]].English__c != 'Other' && this.mapAnswers[arr[k]].English__c != 'Other (please specify)') {
                                            if (this.defaultLang != 'English') {
                                                if (this.answerFieldAPI === 'Cambodian__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Cambodian__c);
                                                } else if (this.answerFieldAPI === 'Chinese__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Chinese__c);
                                                } else if (this.answerFieldAPI === 'Laos__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Laos__c);
                                                } else if (this.answerFieldAPI === 'Burmese__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Burmese__c);
                                                } else if (this.answerFieldAPI === 'Thai__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Thai__c);
                                                } else if (this.answerFieldAPI === 'Mongolian__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Mongolian__c);
                                                } else if (this.answerFieldAPI === 'Vietnamese__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Vietnamese__c);
                                                } else if (this.answerFieldAPI === 'Bahasa__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Bahasa__c);
                                                } else if (this.answerFieldAPI === 'Brunei__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].Brunei__c);
                                                }else if (this.answerFieldAPI === 'French__c') {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].French__c);
                                                } else {
                                                    tempScoreArray.push(this.mapAnswers[arr[k]].English__c);
                                                }
                                            } else {
                                                tempScoreArray.push(this.mapAnswers[arr[k]].English__c);
                                            }
                                        }

                                    }
                                }
                                scoreValue = tempScoreArray.join(';');;
                                if (this.mapOfListValues[i].value[j].otherTypeValue != '' && this.mapOfListValues[i].value[j].isOtherType) {
                                    scoreValue = scoreValue != '' ? scoreValue + ';Other(' + this.mapOfListValues[i].value[j].otherTypeValue + ')' : 'Other(' + this.mapOfListValues[i].value[j].otherTypeValue + ')';
                                }
                                isUnanswered = false;
                            }
                        } else {
                            if (this.mapOfListValues[i].value[j].selectedRadioAnswer != '') {
                                if(this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Medallia_Value__c != ''){
                                    medalliaValueAns += this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Medallia_Value__c +',';
                                }
                              //  arrAnsShortOrder += this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Sort_Order__c +',';
                                if (typeof this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Score__c != 'undefined') {
                                    scoreValue = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Score__c;
                                    isUnanswered = false;
                                    if (this.mapOfListValues[i].value[j].qtype == 'Likelihood to Recommend Retailer') {
                                        nps = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Score__c;
                                    }
                                } else {
                                    if (this.defaultLang != 'English') {
                                        if (this.answerFieldAPI === 'Cambodian__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Cambodian__c;
                                        } else if (this.answerFieldAPI === 'Chinese__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Chinese__c;
                                        } else if (this.answerFieldAPI === 'Laos__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Laos__c;
                                        } else if (this.answerFieldAPI === 'Burmese__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Burmese__c;
                                        } else if (this.answerFieldAPI === 'Thai__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Thai__c;
                                        } else if (this.answerFieldAPI === 'Mongolian__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Mongolian__c;
                                        } else if (this.answerFieldAPI === 'Vietnamese__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Vietnamese__c;
                                        } else if (this.answerFieldAPI === 'Bahasa__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Bahasa__c;
                                        } else if (this.answerFieldAPI === 'Brunei__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].Brunei__c;
                                        } else if (this.answerFieldAPI === 'French__c') {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].French__c;
                                        } else {
                                            scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].English__c;
                                        }

                                    } else {
                                        scoreValueRating = this.mapAnswers[this.mapOfListValues[i].value[j].selectedRadioAnswer].English__c;
                                    }
                                    // scoreValue = scoreValueRating;
                                    isUnanswered = false;
                                }
                            }
                        }

                        let responseWrapper = {
                            customerId: this.objData.customerId,
                            retailerId: this.objData.retailerId,
                            surveyId: this.objData.surveyId,
                            objectId: this.objData.surveyType == 'Service' ? this.objData.serviceId : this.objData.OppId,
                            language: this.defaultLang,
                            questionId: this.mapOfListValues[i].value[j].recordId,
                            selectedRadioAnswer: this.mapOfListValues[i].value[j].selectedRadioAnswer,
                            selectedTextAnswer: this.mapOfListValues[i].value[j].selectedTextAnswer,
                            selectedStarAnswer: this.mapOfListValues[i].value[j].selectedStarAnswer,
                            answerType: this.mapOfListValues[i].value[j].ansType,
                            qTYpe: this.mapOfListValues[i].value[j].qtype,
                            scoreRating: scoreValue,
                            scoreText: scoreValueRating,
                            isUnanswered: isUnanswered,
                            npsRating: nps,
                            medalliaValue: medalliaValueAns,
                          //  shortOrderNo: arrAnsShortOrder,
                           

                        }
                        responseArray.push(responseWrapper);
                    }

                }
            }

            //Call apex to insert responses        
            saveSurveyResponses({
                    strResponses: JSON.stringify(responseArray)
                })
                .then(result => {
                    // this.showcountryoption = true;
                    this.isLoaded = true;
                    this.isError = false;
                    this.isForm = false;
                    this.isSuccess = true;
                    this.showSecHeader5 = false;
                    this.showSecHeader6 = false;
                    this.showSecHeader7 = false;
                    this.showSecHeader8 = false;
                    this.showSecHeader9 = false;
                    this.showSecHeader10 = false;
                  
                    
                })
                .catch(error => {
                    this.isLoaded = true;
                    console.log(error);
                    this.error = error;
                    this.isError = true;
                    this.isForm = false;
                    this.isSuccess = false;
                    this.showSecHeader5 = false;
                    this.showSecHeader6 = false;
                    this.showSecHeader7 = false;
                    this.showSecHeader8 = false;
                    this.showSecHeader9 = false;
                    this.showSecHeader10 = false;
                });
        }
    }
}
import {LightningElement} from 'lwc';
import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import LightningAlert from 'lightning/alert';
// import networkId from '@salesforce/community/Id';

export default class AddressFinderModal extends LightningModal  {
    
    keyword = '';
    items = [];
    @api
    isCommunity;
    

    handleEnter(event){
        if(event.keyCode === 13){
            var keyValue = event.target.value;
            this.handleSearch(keyValue);
        }
    }

    handleSearch(keyValue){
        if (!keyValue) return;
        var encodedKeyword = encodeURI(keyValue); 
        var token = this.isCommunity ? 'U01TX0FVVEgyMDIyMTIwNTE1MTE0MTExMzI5NTg%3D' : 'U01TX0FVVEgyMDIyMTIwNTE1MTE0MTExMzI5NTc%3D'
        fetch(
            'https://business.juso.go.kr/addrlink/addrLinkApi.do',
            {
                method: 'POST',
                headers: {
                    'Content-Type' : 'application/x-www-form-urlencoded',
                },
                redirect: 'follow',
                body: 'confmKey=' + token + '&currentPage=1&countPerPage=5&resultType=json&keyword=' + encodedKeyword
            }
        ).then(response => {
            return response.text();
        }).then(result => {
            var resultObj = JSON.parse(result);
            // console.log(resultObj);
            var errorCode = resultObj.results.common.errorCode;
            var errorMessage = resultObj.results.common.errorMessage;

            if (errorCode.toString() !== '0') throw new Error(errorMessage);

            var resultAddrList = [];
            resultObj.results.juso.forEach((address, index) =>{
                
                var streetAddr = address.rn + ' ' + (address.buldSlno != 0 ? address.buldMnnm + '-' + address.buldSlno : address.buldMnnm) + address.roadAddrPart2;

                resultAddrList.push({
                    "name": index,
                    "label": address.roadAddr,
                    "metatext": address.jibunAddr,
                    "stateAddress": address.siNm,
                    "cityAddress": address.sggNm,
                    "postalCodeAddress": address.zipNo,
                    "streetAddress": streetAddr,
                });
            });
            this.items = resultAddrList;

        }).catch(errorMessage =>  {
            console.log(errorMessage);
            this.openAlert(errorMessage, 'warning', 'Error!');
        });
    }

    handleSelect(event) {
        this.close(this.items[event.detail.name]);
    }

    async openAlert(message, theme, label) {
        await LightningAlert.open({
            message: message,
            theme: theme, // a red theme intended for error states
            label: label // this is the header text
        });
    }

    


}
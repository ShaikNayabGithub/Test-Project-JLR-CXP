import { LightningElement, api } from 'lwc';

import linksHeader from '@salesforce/label/c.Home_Page_Custom_Links_Header'

export default class HomePageCustomLinks extends LightningElement {
    @api firstLink;
    @api firstLinkLabel;
    
    @api secondLink;
    @api secondLinkLabel;
    
    @api thirdLink;
    @api thirdLinkLabel;
    
    @api fourthLink;
    @api fourthLinkLabel;
    
    @api fifthLink;
    @api fifthLinkLabel;
    
    @api sixthLink;
    @api sixthLinkLabel;
    
    @api seventhLink;
    @api seventhLinkLabel;
    
    @api eighthLink;
    @api eighthLinkLabel;
    
    @api ninthLink;
    @api ninthLinkLabel;
    
    @api tenthLink;
    @api tenthLinkLabel;

    label = {
        linksHeader,
    }

}
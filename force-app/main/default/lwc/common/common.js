/**
 * Created by caleb on 5/03/2021.
 */

import {ShowToastEvent} from "lightning/platformShowToastEvent";
import queryApex from '@salesforce/apex/LWCUtility.query';
import updateApex from '@salesforce/apex/LWCUtility.up';

const query = async (q) =>
{
    console.log('query = ' + q);
    let res = await queryApex({q:q});
    console.log('query result = ' + JSON.stringify(res));
    return res;
}

const update = async (toUpdate) =>
{
    console.log('update = ' + JSON.stringify(toUpdate));
    await updateApex({toUpdate:toUpdate});
}


const toastErrorOnFail = async (promise) =>
{
    let error = undefined;
    let res = await promise.catch(
        err =>
        {
            error = err;
            console.log('Common.Error: ' + JSON.stringify(err));
            let message = err?.body?.pageErrors?.[0]?.message;
            if (!message) message = err?.body?.message;
            if (!message)
            {
                showErrorToastMsg('An Unexpected Error Has Occurred');
            }
            else if (messageTranslationMap[message])
            {
                showErrorToastMsg(messageTranslationMap[message]);
            }
            else
            {
                showErrorToastMsg(message);
            }
        });
    if (error)
    {
        throw error;
    }
    else
    {
        console.log('Common.Response: ' + JSON.stringify(res));
        return res;
    }
}

const showErrorToastMsg = (msg) =>
{
    const toast = new ShowToastEvent({
        title: "Error",
        message: msg,
        variant: "error"
    });
    dispatchEvent(toast);
}

// custom error handeling
const messageTranslationMap = {

};

export {toastErrorOnFail, query, update, showErrorToastMsg};
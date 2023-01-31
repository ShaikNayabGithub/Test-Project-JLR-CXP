import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import Query from '@salesforce/apex/LWCUtility.query';
import communityBasePath from '@salesforce/community/basePath';

export default class RelatedList extends NavigationMixin(LightningElement) {
    @api
    recordId;
    @api
    sobjectName;
    @api
    icon;
    @api
    fieldsNamesCommaSeparated = "";
    @api
    fieldsLabelsCommaSeparated = "";
    @api
    fieldsTypesCommaSeparated = "";
    @api
    refFieldName = "";
    @api
    whereClause = "";
    @track
    data;
    @track
    currentExpanded;
    @track
    columns;
    @track
    show = false;


    async connectedCallback()
    {
        this.columns = this.getColumns();
        this.data = await this.getData();
        this.show = true;
    }

    getColumns = () =>
    {
        let names = this.fieldsNamesCommaSeparated.split(',').map(x => x.trim());
        let labels = this.fieldsLabelsCommaSeparated.split(',').map(x => x.trim());
        let types = this.fieldsTypesCommaSeparated.split(',').map(x => x.trim());
        let res = [];
        for (let i = 0; i < names.length; i++)
        {
            if (types[i].startsWith('ref'))
            {
                res.push({
                    type: 'url',
                    fieldName: `SObjectUrl(${types[i].split(' ')[1]})`,
                    label: labels[i],
                    typeAttributes: {
                        label: { fieldName: names[i] }
                    }
                })
            }
            else
            {
                res.push({type: types[i], fieldName: names[i], label: labels[i]});
            }
        }
        return res;
    }

    getData = async () =>
    {
        let names = this.fieldsNamesCommaSeparated.split(',').map(x => x.trim());
        let labels = this.fieldsLabelsCommaSeparated.split(',').map(x => x.trim());
        let types = this.fieldsTypesCommaSeparated.split(',').map(x => x.trim());

        let queryString = `SELECT Name, Id, ${this.refFieldName}`;

        for (let i = 0; i < names.length; i++)
        {
            if (names[i].toUpperCase() === 'ID' || names[i].toUpperCase() === 'NAME') continue;
            if (types[i].startsWith('ref'))
            {
                queryString += ', ' + names[i];
                let refFiledName = types[i].split(' ')[1];
                if (refFiledName.toUpperCase() !== 'ID' && refFiledName.toUpperCase() !== 'NAME')
                    queryString += ', ' + types[i].split(' ')[1];
            }
            else
            {
                queryString += ', ' + names[i];
            }
        }

        queryString += ` FROM ${this.sobjectName} `;
        queryString += ` WHERE ${this.refFieldName} = \'${this.recordId}\'`;
        if (this.whereClause && this.whereClause !== "")
        {
            queryString += ' And ' + this.whereClause;
        }

        console.log('queryString = ' + queryString);
        let queryRes = await Query({q: queryString});
        console.log(JSON.stringify(queryRes));

        for (let i = 0; i < queryRes.length; i++)
        {
            queryRes[i] = this.flatten(queryRes[i]);
            queryRes[i].SObjectUrl = window.location.origin + '/' + communityBasePath.split('/')[1] + '/' + queryRes[i].Id;
        }

        // populate link urls
        for (let i = 0; i < names.length; i++)
        {
            if (types[i].startsWith('ref'))
            {
                for (let i = 0; i < queryRes.length; i++)
                {
                    let refFieldName = `SObjectUrl(${types[i].split(' ')[1]})`;
                    queryRes[i][refFieldName] = window.location.origin + '/' + communityBasePath.split('/')[1] + '/' + queryRes[i][types[i].split(' ')[1]];
                }
            }
        }

        console.log(JSON.stringify(queryRes));

        return queryRes;
    }

    flatten = (obj) =>
    {
        for (let key in obj)
        {
            if (
                typeof obj[key] === 'object' &&
                !Array.isArray(obj[key] ) &&
                obj[key] !== null
            )
            {
                let recRes = this.flatten(obj[key]);
                for (let key2 in recRes)
                {
                    obj[key + '.' + key2] = recRes[key2];
                }
            }
        }
        return obj;
    }

    get recordCount()
    {
        return this.data ? this.data.length : 0;
    }

    get hasRecords()
    {
        return this.data && this.data.length > 0;
    }
}
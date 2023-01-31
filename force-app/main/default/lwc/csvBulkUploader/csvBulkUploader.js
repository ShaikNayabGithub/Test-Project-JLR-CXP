import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import papaParse from '@salesforce/resourceUrl/PapaParse'; 
import importCSV from '@salesforce/apex/CsvBulkUploadController.importCsv';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import csvBulkUpload from '@salesforce/label/c.Csv_Bulk_Upload';
import csvObject from '@salesforce/label/c.csv_Object';
import csvOperation from '@salesforce/label/c.Csv_Operation';
import csvUpdateUpsertKey from '@salesforce/label/c.Csv_Update_Upsert_Key';
import csvClearandReset from '@salesforce/label/c.Csv_Clear_and_Reset';
import csvTogglePreview from '@salesforce/label/c.Csv_Toggle_Preview';
import csvToggleResults from '@salesforce/label/c.Csv_Toggle_Results';
import csvOptionsGuidance from '@salesforce/label/c.Csv_Advance_options';


export default class CsvBulkUploader extends NavigationMixin(LightningElement) {
    
    parserLoaded = false;
    loading = false;
    showPreviewData = false;
    showResultsData = false;

    @api adminObjects;
    selectedObject;
    objectOptions;
    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        console.log('via handleObjectChange: now set selectedObject to: ' + this.selectedObject);
    };

    @api adminOperations;
    selectedOperation;
    operationOptions;
    handleOperationChange(event) {
        this.selectedOperation = event.detail.value;
    };

    @api adminUpdateKey;
    selectedUpdateUpsertKey = 'Id';
    updateUpsertKeyOptions;
    handleUpdateUpsertKeyChange(event) {
        this.selectedUpdateUpsertKey = event.detail.value;
    };

    // Report Export Templates
    @api reportId;
    reportIdSet;
    @api reportNames;
    reportNamesSet;
    reportExportOptions;

    showAdvancedOptions = false;
    autoConvert15DigitSalesforceIds = true;
    manualConvert15DigitSalesforceIdHeaders;
    manualConvert15DigitSalesforceIdHeadersList = [];

    autoConvertDates = false;
    selectedInputDateFormat;
    dateFormatConversionOptions = [
        {label: "YYYY-MM-dd", value: "noConversion"},
        {label: "dd/MM/YYYY", value: "dd/MM/YYYY"},
    ]

    // REMOVED SUPPORT - priority call on time
    //autoConvertDatetimes = false;
    //manualConvertDatetimeHeaders;
    //manualConvertDatetimeHeadersList = [];


    columns = [];
    rows = [];

    resultRows;
    resultColumns = [
        { label: 'Record ID', fieldName: 'id' },
        { label: 'Success', fieldName: 'success' },
        { label: 'Errors', fieldName: 'errorsString' },

    ]

    renderedCallback() {
        if(!this.parserLoaded) {
            loadScript(this, papaParse)
                .then (() => {
                    console.log('loaded papaparse');
                    this.parserLoaded = true;
                })
                .catch(error => console.log(error));
        }
        //Mandatory Configs
        if(!this.objectOptions) {
            this.objectOptions = this.commaSeparatedListToArray(this.adminObjects);
            this.selectedObject = this.objectOptions[0].value;
            console.log('Set selectedObject to: ' + this.selectedObject );
        }

        if(!this.operationOptions) {
            this.operationOptions = this.commaSeparatedListToArray(this.adminOperations);
            this.selectedOperation = this.operationOptions[0].value;
        }

        if(!this.updateUpsertKeyOptions) {
            this.updateUpsertKeyOptions = this.commaSeparatedListToArray(this.adminUpdateKey);
            this.selectedUpdateUpsertKey = this.updateUpsertKeyOptions[0].value;
        }

        //Optional Configs
        if(!this.reportNamesSet && this.reportNames) {
            this.reportNamesSet = this.commaSeparatedListToArray(this.reportNames);
        }

        if(!this.reportIdSet && this.reportId) {
            this.reportIdSet = this.commaSeparatedListToArray(this.reportId);
            console.log('this.reportIdSet');
            console.log(this.reportIdSet);

            console.log('reportNamesSet');
            console.log(this.reportNamesSet);

            try {
                let reportExportOptionsUpdate = this.reportIdSet.map( (template, index) => {
                    
                    console.log(template.value + ' index: ' + index + 'length: ' + this.reportNamesSet.length  );
                    const displayNumber = index + 1;
                    const reportExportConfig = {};
                    reportExportConfig.id = template.value;
                    if(index <= this.reportNamesSet.length) {
                        reportExportConfig.displayName = (this.reportNamesSet[index]).label;
                    } else {
                        reportExportConfig.displayName = 'Template Report ' + displayNumber;
                    }

                    console.log('report name set as: ' + reportExportConfig.displayName + ' for ' + reportExportConfig.id );
                    return reportExportConfig;
                });
                this.reportExportOptions = reportExportOptionsUpdate;
            } catch(error) {
                console.log('Report Names not provided');
                console.log(error);
            }
        }

    }

    commaSeparatedListToArray(stringList) {
        let outputArray = stringList.split(',').map(value => {
            const trimmedValue = value.trim();
            const item = {
                label: trimmedValue,
                value: trimmedValue
            };
            return item;
        });
        return outputArray;

    }
    convert15to18CharId(id) {
        let i, j, flags, alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345",
            isUppercase = function(c) {
                return c >= "A" && c <= "Z";
            };
        
        if (id == null) {
            return id;
        }
        id = id.replace(/\W/g, "");

        if (id.length != 15) { 
            return id; 
        }

        for (i = 0; i < 3; i++) {
            flags = 0;
            for (j = 0; j < 5; j++) {
                if (isUppercase(id.charAt(i * 5 + j))) { 
                    flags += 1 << j; 
                }
            }
            id += alphabet.charAt(flags);
        }
        return id;
    }

    //labels
    label = {
        csvObject,csvBulkUpload,csvOperation,csvUpdateUpsertKey,csvClearandReset,csvTogglePreview,csvToggleResults,csvOptionsGuidance
    };

    handleFileInput(event) {
        if(event.target.files.length > 0) {
            const file = event.target.files[0];
            this.loading = true;
            console.log('now loading');
            Papa.parse(file, {
                quoteChar: '"',
                skipEmptyLines: true,
                header: 'true',
                //encoding: 'euc-kr',
                complete: (results) => {

                    this.setColumnsFromFirstRow(results.data[0]);

                    this.setManualHeadersFromTextInputs();

                    
                    let uploadedRows = results.data.map((record, index) => {
                        let formattedRecord = {};
                        formattedRecord['row_id'] = index;
                        
                        Object.entries(record).forEach(([key, value]) => {

                            //default mapping of no transformation
                            formattedRecord[key] = value; 

                            // *** Handle Salesforce Record Id Conversion ***
                            // If Auto Convert
                            if(this.autoConvert15DigitSalesforceIds === true) {
                                if(value.match('[a-zA-Z0-9]{15}')) {
                                    formattedRecord[key] = this.convert15to18CharId(value);
                                    return;
                                }

                            // If Manual Conversion
                            } else if (this.manualConvert15DigitSalesforceIdHeaders) {
                                if(manualConvert15DigitSalesforceIdHeadersList.includes(key)) {
                                    formattedRecord[key] = this.convert15to18CharId(value);
                                    return;
                                } 
                            } 

                            
                            // Handle Date Format Conversion - WIP
                            if(this.autoConvertDates === true) {
                                if(selectedInputDateFormat === 'dd/MM/YYYY') {
                                    if(value.match('\d{2}\/\d{2}\/\d{4}')) {
                                        let dateParts = value.split('/');
                                        formattedRecord[key] = dateParts[2] & '-' & dateParts[1] & '-' & dateParts[0];
                                    }
                                }
                            } 
                            if(value) {
                                if(value.toLowerCase().trim() === 'true') {
                                    formattedRecord[key] = true;
                                }

                                if(value.toLowerCase().trim() === 'false') {
                                    formattedRecord[key] = false;
                                }
                            }
                        

                        });
                            

                        return formattedRecord;

                    });
                    console.log('uploadedRows.length: ' + uploadedRows.length);
                    this.rows = uploadedRows;
                    this.showPreviewData = true;
                    this.loading = false;

                    
                    
                    
                },
                error: (error) => {
                    console.log('calling error callback');
                    console.log(error);
                    this.loading = false;
                }
            });

            console.log('Completed Papa.parse()');
        }
    }

    handleAutoConvertSfIdChange() {
        this.autoConvert15DigitSalesforceIds = !this.autoConvert15DigitSalesforceIds;
    }
    
    handleManualConvertSfIdChange(event) {
        this.manualConvert15DigitSalesforceIdsInput = event.detail.target;
    }

    handleAutoConvertDatesChange() {
        this.autoConvertDates = !this.autoConvertDates;
    }

    handleAutoConvertDatetimesChange() {
        this.autoConvertDatetimes = !this.autoConvertDatetimes;
    }

    setColumnsFromFirstRow(firstRow) {
        var uploadedColumns = [];
        var firstRecord = Object.keys(firstRow);
        for( const key in firstRecord) {
            const column = {
                label: firstRecord[key],
                fieldName: firstRecord[key]
            };
            uploadedColumns.push(column);
        }
        this.columns = uploadedColumns;
    }

    setManualHeadersFromTextInputs() {
        if(this.manualConvert15DigitSalesforceIdHeaders) {
            this.this.manualConvert15DigitSalesforceIdHeaders.split(",").forEach(x => {
                manualConvert15DigitSalesforceIdHeadersList.push(x.trim());
            })
        }
    }


    handleImport() {
        console.log('handle import');
        const configObject = {};
        configObject.objectApiName = this.selectedObject;
        configObject.operation = this.selectedOperation;
        configObject.updateKey = this.selectedUpdateUpsertKey;
        console.log('configObject');
        console.log(configObject);
        console.log('this.rows');
        console.log(this.rows);
        importCSV({jsonRecordData: JSON.stringify(this.rows), jsonConfigObject: JSON.stringify(configObject)})
            .then(x => {
                const successMessage = new ShowToastEvent({
                    title: 'Success',
                    message: 'Data Import Successful. If you have created any new data, Salesforce Record Ids will be displayed in the data table below.',
                    variant: 'success',
                });
                this.dispatchEvent(successMessage);
                console.log('success uploading data');
                console.log(x);
                const returnedData = JSON.parse(x).map( (row, index) => {
                    const item = {
                        ...row,
                        row_id: index,
                        errorsString: row.errors.toString()
                    }
                    return item;
                }
                    
                );
                this.resultRows = returnedData;
                this.showResultsData = true;
            })
            .catch(error => {
                const successMessage = new ShowToastEvent({
                    title: 'Error Importing Data',
                    message: 'Error Importing Data.\n',
                    variant: 'error',
                });
                this.dispatchEvent(successMessage);
                console.log('error uploading data');
                console.log(error);
            })
    }

    handleTogglePreview() {
        this.showPreviewData = !this.showPreviewData;
    }

    handleToggleResults() {
        this.showResultsData = !this.showResultsData;
    }

    handleReset() {
        this.columns = [];
        this.data = [];
        this.resultRows = [];
        this.showPreviewData = false;
        this.showResultsData = false;
        
        this.loading = false;
    }

    handleAdvancedOptions() {
        this.showAdvancedOptions = !this.showAdvancedOptions;
    }

    handleExportTemplateClick(event) {
        this[NavigationMixin.GenerateUrl]({
            type:'standard__recordPage',
            attributes:{
                'recordId': event.target.dataset.reportId,
                'objectApiName': 'Report',
                'actionName': 'view'
            }
        })
        .then((url) => {
            console.log(url);
            window.open(url);
        });
    }

    
}
import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import getAssets from '@salesforce/apex/GeoMapController.getAssets';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import ASSET_OBJECT from '@salesforce/schema/Asset';
import INCIDENT_OBJECT from '@salesforce/schema/Incident';
import geoMapTitle from '@salesforce/label/c.AIM_GeoMapTitle';
import geoMapFilterProduct from '@salesforce/label/c.AIM_GeoMap_Filter_Product';
import geoMapFilterProductFamily from '@salesforce/label/c.AIM_GeoMap_Filter_ProductFamily';
import geoMapFilterAssetStatus from '@salesforce/label/c.AIM_GeoMap_Filter_AssetStatus';
import geoMapListViewToggle from '@salesforce/label/c.AIM_GeoMap_ListView_Toggle';
import geoMapListViewToggleActive from '@salesforce/label/c.AIM_GeoMap_ListView_Toggle_Active';
import geoMapListViewToggleInactive from '@salesforce/label/c.AIM_GeoMap_ListView_Toggle_Inactive';
import geoMapFilterValueAll from '@salesforce/label/c.AIM_GeoMap_Filter_Value_All';
import geoMapListTitle from '@salesforce/label/c.AIM_GeoMap_List_Title';
import geoMapNoData from '@salesforce/label/c.AIM_GeoMap_No_Data';
import geoMapGenericException from '@salesforce/label/c.AIM_GeoMap_Generic_Exception';

export default class GeoMap extends LightningElement {
    @api recordId;
    @api inputRecords;
    @api selectedAssetId;
    @track mapMarkers;
    @track productOptions;
    @track productFamilyOptions;
    @track statusOptions;
    inputIds;;
    selectedMarkerValue = '';
    productValue = 'All';
    productFamilyValue = 'All';
    statusValue = 'All';
    listViewLimit = 10;
    selectedMarkerData;
    assetsData;
    errorMessage;
    notificationMessage;
    objectsInfo;
    listView = 'visible';
    showList;
    label = {
        geoMapTitle,
        geoMapFilterProduct,
        geoMapFilterProductFamily,
        geoMapFilterAssetStatus,
        geoMapListViewToggle,
        geoMapListViewToggleActive,
        geoMapListViewToggleInactive,
        geoMapFilterValueAll,
        geoMapListTitle,
        geoMapNoData,
        geoMapGenericException
    };
    objectApiNames = [ACCOUNT_OBJECT, CONTACT_OBJECT, PRODUCT_OBJECT, ASSET_OBJECT, INCIDENT_OBJECT];

    connectedCallback() {
        if (this.recordId != undefined) {
            this.inputIds = [this.recordId];
        }
        else if (this.inputRecords != undefined) {
            this.inputIds = this.inputRecords.map((record) => record.Id)
        }
        else {
            this.notificationMessage = geoMapNoData;
        }
    }

    /**
     * wiredObjectsInfo: Wired method to retrieve Object metadata(labels) using UI API
     * 
     * @param {objectApiNames}: List of SObject API names
     */
    @wire(getObjectInfos, { objectApiNames: '$objectApiNames' })
    wiredObjectsInfo({ error, data }) {
        if (data) {
            this.generateObjectsInfo(data);
        } else if (error) {
            this.errorMessage = geoMapGenericException;
            if (!Array.isArray(error) && !Array.isArray(error.body)) {
                this.errorMessage = error.body.message;
            }
        }
    }

    /**
     * wiredAssets: Wired method to retrieve Assets and related records data via Apex Controller
     * 
     * @param {inputIds}: List of record Ids
     */
    @wire(getAssets, { inputIds: '$inputIds' })
    wiredAssets({ error, data }) {
        if (data) {
            this.assetsData = data;
            this.errorMessage = undefined;
            this.notificationMessage = undefined;
            if (this.objectsInfo && this.assetsData) {
                this.setupData();
            }
        } else if (error) {
            this.errorMessage = geoMapGenericException;
            if (!Array.isArray(error) && !Array.isArray(error.body)) {
                this.errorMessage = error.body.message;
            }
            this.assetsData = undefined;
        }
    }

    /**
     * handleFilterChange: change event handler when the Map filter value changes
     * 
     * @param event: event information
     */
    handleFilterChange(event) {
        const filterType = event.target.dataset.name;
        const selectedValue = event.detail.value;
        switch (filterType) {
            case 'product':
                this.productValue = selectedValue;
                break;
            case 'productFamily':
                this.productFamilyValue = selectedValue;
                break;
            case 'status':
                this.statusValue = selectedValue;
                break;
        }
        this.selectedMarkerData = undefined;
        this.generateMapMarker();
    }

    /**
     * handleListToggle: change event handler for the Map list view toggle
     * 
     * @param event: event information
     */
    handleListToggle(event) {
        this.showList = event.target.checked;
        if (this.showList) {
            this.listView = 'visible';
        }
        else {
            this.listView = 'hidden';
        }
    }

    /**
     * handleMarkerSelect: select event handler when a marker is selected on the Map or in the Map list view.
     * 
     * @param event: event information
     */
    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        for(const record of this.assetsData) {
            if (this.selectedMarkerValue == `${record.assetId}${record.incidentId ? `-${record.incidentId}` : ''}`) {
                this.selectedMarkerData = record;
                this.selectedAssetId = record.assetId;
                break;
            }
        }
    }

    /**
     * setupData: populate Map marker data and filters on initialization.
     */
    setupData() {
        if (this.assetsData.length) {
            this.notificationMessage = undefined;
            this.generateMapMarker();
            this.productOptions = [{ label: geoMapFilterValueAll, value: 'All' }];
            this.productFamilyOptions = [{ label: geoMapFilterValueAll, value: 'All' }];
            this.statusOptions = [{ label: geoMapFilterValueAll, value: 'All' }];
            let productSet = new Set(['All']);
            let productFamilySet = new Set(['All']);
            let statusSet = new Set(['All']);
            /**
             * Create filters' unique label/value from the assets data
             */
            for (let record of this.assetsData) {
                if (record.productId && !productSet.has(record.productId)) {
                    let productOption = { label: record.productName, value: record.productId };
                    this.productOptions.push(productOption);
                    productSet.add(record.productId);
                }
                if (record.productFamily && !productFamilySet.has(record.productFamily)) {
                    let productFamilyOption = { label: record.productFamily, value: record.productFamily };
                    this.productFamilyOptions.push(productFamilyOption);
                    productFamilySet.add(record.productFamily);
                }
                if (record.assetStatus && !statusSet.has(record.assetStatus)) {
                    let statusOption = { label: record.assetStatus, value: record.assetStatus };
                    this.statusOptions.push(statusOption);
                    statusSet.add(record.assetStatus);
                }
            }
        }
        else {
            this.notificationMessage = geoMapNoData;
        }
    }

    /**
     * generateMapMarker: method to generate(on initialization) and regenerated(when filter value changes) Map markers.
     */
    generateMapMarker() {
        this.mapMarkers = [];
        for (let record of this.assetsData) {
            const isFilteredRecord = (this.productValue == 'All' || record.productId == this.productValue) && (this.productFamilyValue == 'All' || record.productFamily == this.productFamilyValue) && (this.statusValue == 'All' || record.assetStatus == this.statusValue)
            if (isFilteredRecord) {
                let desc = '';
                if (record.accountName) {
                    desc += `<p><b>${this.objectsInfo.AccountLabel}:</b>  ${record.accountName} </p>`;
                }
                if (record.contactName) {
                    desc += `<p><b>${this.objectsInfo.ContactLabel}:</b>  ${record.contactName} </p>`;
                }
                if (record.incidentNumber) {
                    desc += `<p><b>${this.objectsInfo.IncidentLabel}:</b>  ${record.incidentNumber} </p>`;
                }
                if (record.productName) {
                    desc += `<p><b>${this.objectsInfo.ProductLabel}:</b>  ${record.productName} </p>`;
                }
                let mapRow = {
                    location: ({
                        Latitude: record.assetLatitude,
                        Longitude: record.assetLongitude
                    }),
                    // As Incident-to-Asset is many-to-many, creating a unique value using 2 primary keys
                    value: `${record.assetId}${record.incidentId ? `-${record.incidentId}` : ''}`,
                    icon: 'standard:asset_object',
                    description: `${desc}`,
                    title: record.assetName
                };
                this.mapMarkers.push(mapRow);
            }
        }
        if (this.mapMarkers.length > this.listViewLimit) {
            this.listView = 'hide';
            this.showList = false;
        }
        else {
            this.listView = 'visible';
            this.showList = true;
        }
    }

    /**
     * generateMapMarker: method to populate SObjects and fields labels
     * 
     * @param objects: response from UI API wired call
     */
    generateObjectsInfo(objects) {
        this.objectsInfo = {};
        for (const object of objects.results) {
            if (object.statusCode === 200) {
                const objectApiName = object.result?.apiName;
                const objectFields = object.result?.fields;
                const objectLabel = object.result?.label;
                switch (objectApiName) {
                    case 'Account':
                        this.objectsInfo.AccountLabel = objectLabel;
                        break;
                    case 'Contact':
                        this.objectsInfo.ContactLabel = objectLabel;
                        break;
                    case 'Product2':
                        this.objectsInfo.ProductLabel = objectLabel;
                        this.objectsInfo.ProductFamilyLabel = objectFields?.Family?.label;
                        break;
                    case 'Asset':
                        this.objectsInfo.AssetLabel = objectLabel;
                        break;
                    case 'Incident':
                        this.objectsInfo.IncidentLabel = objectLabel;
                        this.objectsInfo.IncidentStatusLabel = objectFields?.Status?.label;
                        break;
                }
            }
        }
        if (this.objectsInfo && this.assetsData) {
            this.setupData();
        }
    }
}
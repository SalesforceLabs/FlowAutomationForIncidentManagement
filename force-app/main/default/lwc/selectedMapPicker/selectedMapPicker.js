import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SelectedMapPicker extends NavigationMixin(LightningElement)
{
    @api
    selectedMarkerData;
    @api
    objectsInfo;

    /**
     * handleRecordLinkClick: click event handler for record tiles
     * 
     * @param event: event information
     */
    handleRecordLinkClick(event) {
        event.preventDefault();
        event.stopPropagation();
        let id;
        const objectType = event.target.dataset.object;
        const selectedRecord = this.selectedMarkerData;
        switch (objectType) {
            case 'Account':
                id = selectedRecord.accountId;
                break;
            case 'Asset':
                id = selectedRecord.assetId;
                break;
            case 'Contact':
                id = selectedRecord.contactId;
                break;
            case 'Product':
                id = selectedRecord.productId;
                break;
            case 'Incident':
                id = selectedRecord.incidentId;
                break;
        }
        if (id) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: id,
                    actionName: 'view'
                }
            });
        }
    }
}
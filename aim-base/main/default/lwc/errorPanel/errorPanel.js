import { api, LightningElement } from 'lwc';

export default class ErrorPanel extends LightningElement {
    @api errorMessage;
}
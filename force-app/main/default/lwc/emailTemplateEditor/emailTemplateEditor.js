import { api, LightningElement, track, wire } from "lwc";
import getEmailTemplates from "@salesforce/apex/EmailTemplateEditorController.getEmailTemplates";
import getSenderAddresses from "@salesforce/apex/EmailTemplateEditorController.getSenderAddresses";
import sendTestEmail from "@salesforce/apex/EmailTemplateEditorController.sendTestEmail";
import emailBody from "@salesforce/label/c.AIM_Email_Editor_Email_Body";
import selectFolder from "@salesforce/label/c.AIM_Email_Editor_Select_Folder";
import selectSender from "@salesforce/label/c.AIM_Email_Editor_Select_Sender";
import selectTemplate from "@salesforce/label/c.AIM_Email_Editor_Select_Template";
import sendEmailTest from "@salesforce/label/c.AIM_Email_Editor_Send_Test_Email";
import subject from "@salesforce/label/c.AIM_Email_Editor_Subject";
import testEmail from "@salesforce/label/c.AIM_Email_Editor_Test_Email";
import testEmailSent from "@salesforce/label/c.AIM_Flow_Test_Email_Sent";
import testEmailFailed from "@salesforce/label/c.AIM_Flow_Test_Email_Failed";
import genericError from "@salesforce/label/c.AIM_Generic_Error";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class EmailTemplateEditor extends LightningElement {
  @api whatId;
  @api orgWideEmailAddressId;
  @api subject;
  @api emailBody;
  @api templateId;
  @track templatesByFolder;
  @track folderOptions;
  @track templateOptions;
  @track senderEmailAddressesOptions;
  folderValue;
  errorMessage;
  formats = [
    "font",
    "size",
    "bold",
    "italic",
    "underline",
    "strike",
    "list",
    "indent",
    "align",
    "link",
    "image",
    "clean",
    "table",
    "header",
    "color"
  ];
  label = {
    emailBody,
    selectFolder,
    selectSender,
    selectTemplate,
    sendEmailTest,
    subject,
    testEmail
  };

  @wire(getEmailTemplates)
  wiredEmailTemplates({ error, data }) {
    if (data) {
      this.templatesByFolder = data;
      this.folderOptions = [];
      for (const folderId of Object.keys(data)) {
        this.folderOptions.push({
          label: data[folderId].at(0).folderName,
          value: folderId
        });
      }
    } else if (error) {
      this.errorMessage = genericError;
      if (!Array.isArray(error) && !Array.isArray(error.body)) {
        this.errorMessage = error.body.message;
      }
    }
  }

  @wire(getSenderAddresses)
  wiredSenderAddresses({ error, data }) {
    if (data) {
      this.senderEmailAddressesOptions = [];
      for (const addresses of data) {
        this.senderEmailAddressesOptions.push({
          label: `${addresses.DisplayName} (${addresses.Address})`,
          value: addresses.Id
        });
      }
    } else if (error) {
      this.errorMessage = genericError;
      if (!Array.isArray(error) && !Array.isArray(error.body)) {
        this.errorMessage = error.body.message;
      }
    }
  }

  handleFolderChange(event) {
    this.subject = "";
    this.emailBody = "";
    this.folderValue = event.detail.value;
    const emailTemplates = this.templatesByFolder[this.folderValue];
    this.templateOptions = [];
    for (const emailTemplate of emailTemplates) {
      this.templateOptions.push({
        label: emailTemplate.emailTemplateName,
        value: emailTemplate.emailTemplateId
      });
    }
  }

  handleEmailTemplateChange(event) {
    this.subject = "";
    this.emailBody = "";
    this.templateId = event.detail.value;
    for (const emailTemplate of this.templatesByFolder[this.folderValue]) {
      if (emailTemplate.emailTemplateId === this.templateId) {
        this.subject = emailTemplate.emailSubject;
        this.emailBody = emailTemplate.emailBody;
        break;
      }
    }
  }

  handleSenderChange(event) {
    this.orgWideEmailAddressId = event.detail.value;
  }

  handleSubjectChange(event) {
    this.subject = event.detail.value;
  }

  handleBodyChange(event) {
    this.emailBody = event.detail.value;
  }

  showSuccessToast() {
    const evt = new ShowToastEvent({
        title: testEmailSent,
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }

  showErrorToast() {
    const evt = new ShowToastEvent({
        title: testEmailFailed,
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }

  handleSendTestEmail() {
    const recipient = this.template.querySelector(
      'lightning-input[data-name="testEmail"]'
    ).value;
    if (recipient) {
      sendTestEmail({
        emailAddress: recipient,
        sender: this.orgWideEmailAddressId,
        subject: this.subject,
        body: this.emailBody,
        whatId: this.whatId
      })
        .then((result) => {
          result === true ? this.showSuccessToast() : this.showErrorToast();
        })
        .catch((error) => {
          this.errorMessage = genericError;
          if (!Array.isArray(error) && !Array.isArray(error.body)) {
            this.errorMessage = error.body.message;
          }
        });
    }
  }
}

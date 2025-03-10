import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountContactController.getAccounts';
import getContactsByAccountId from '@salesforce/apex/AccountContactController.getContactsByAccountId';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountContactPicker extends LightningElement {
    @track accountOptions = [];
    @track selectedAccountId;
    @track contacts = [];
    @track isModalOpen = false;
    @track selectedContact = {};
    wiredContactsResult; 

    columns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Mobile Phone', fieldName: 'MobilePhone' },
        {
            type: 'button',
            typeAttributes: {
                label: 'Edit Details',
                name: 'edit',
                iconPosition: 'right'
            },
        }
    ];

    // Wire Accounts
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            console.log('Accounts fetched successfully:', data);
            this.accountOptions = data.map(account => ({
                label: account.Name,
                value: account.Id
            }));
        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }

    // Wire Contacts (Updated)
    @wire(getContactsByAccountId, { accountId: '$selectedAccountId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            console.log('Contacts fetched for Account:', result.data);
            this.contacts = result.data;
        } else if (result.error) {
            console.error('Error fetching contacts:', result.error);
        }
    }

    get hasContacts() {
    return this.contacts && this.contacts.length > 0;
}

    // Handle Account Selection
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        console.log('Account selected:', this.selectedAccountId);
    }

    // Handle Edit Button Click (open modal)
    handleRowAction(event) {
        if (event.detail.action.name === 'edit') {
            const contactId = event.detail.row.Id;
            console.log('Edit button clicked for Contact ID:', contactId);
            this.selectedContact = this.contacts.find(contact => contact.Id === contactId);
            console.log('Selected Contact:', this.selectedContact);
            this.isModalOpen = true; 
        }
    }

    // Close Modal
    closeModal() {
        console.log('Closing modal');
        this.isModalOpen = false;
    }

    // Handle Contact Field Change
    handleContactFieldChange(event) {
        const field = event.target.dataset.id;
        const value = event.target.value;
        console.log('Updating field:', field, 'with value:', value);
        this.selectedContact = { ...this.selectedContact, [field]: value };
    }

    // Save Contact and Refresh Data
    saveContact() {
        console.log('Saving contact:', this.selectedContact);
        const fields = {
            Id: this.selectedContact.Id,
            FirstName: this.selectedContact.FirstName,
            LastName: this.selectedContact.LastName,
            Email: this.selectedContact.Email,
            MobilePhone: this.selectedContact.MobilePhone
        };

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                console.log('Contact updated successfully!');
                this.isModalOpen = false; 
                return refreshApex(this.wiredContactsResult);
            })
            .then(() => {
            this.showToast('Success', 'Contact updated successfully!', 'success');
        })
        .catch(error => {
            console.error('Error saving contact:', error);
            this.showToast('Error', 'Failed to update contact.', 'error');
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
import { LightningElement, api } from 'lwc';
import { validateEmail } from 'c/utils';

export default class ToptalNewPatientCreation extends LightningElement {

    @api showpatientform;

    loadSpinner = false;
    emailValid = '';

    newPatient = {
        name: '',
        age: '',
        phoneNumber: '',
        email: '',
        address: ''
    }

    connectedCallback() {
        console.log('value from parent###' + this.showpatientform);
    }

    handleInputChanges(event) {
        this.newPatient = { ...this.newPatient, [event.target.name]: event.target.value };
    }

    openPromptForCreate() {
        let name = this.template.querySelector("lightning-input[data-id='name']");
        let age = this.template.querySelector("lightning-input[data-id='age']");
        let email = this.template.querySelector("lightning-input[data-id='email']");

        if (!this.newPatient.name) {
            name.setCustomValidity("Patient Name is Required");
        } else name.setCustomValidity("");
        name.reportValidity();

        if (!this.newPatient.age) {
            age.setCustomValidity("Patient Age is Required");
        } else age.setCustomValidity("");
        age.reportValidity();

        this.emailValid = validateEmail(this.newPatient.email);
        if (!this.newPatient.email) {
            email.setCustomValidity("Patient Email is Required");
        } else if (this.emailValid == false && this.newPatient.email) {
            email.setCustomValidity("Kindly enter valid Email Id");
        } else if (this.emailValid == true && this.newPatient.email) {
            email.setCustomValidity("");
        }
        email.reportValidity();

        if (this.newPatient.name && this.newPatient.age && this.newPatient.email && this.emailValid == true) {
            this.dispatchEvent(new CustomEvent('formrecords', {
                detail: {
                    formValues: this.newPatient
                }
            }));
        }

    }

    goToOldPatientPage(event) {
        this.dispatchEvent(new CustomEvent('gotopreviouspage', {
            detail: {
                prevPage: true
            }
        }));
    }







}
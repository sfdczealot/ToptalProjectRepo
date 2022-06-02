import { LightningElement,api } from 'lwc';

export default class TimeSlotChild extends LightningElement {
    @api time;
    @api availability;
    available = true;

    connectedCallback() {
        if (this.availability.toUpperCase() == 'NO') {
            this.available = false;
        }
    }

    getTime() {
        this.dispatchEvent(new CustomEvent('bookingdetails', {
            detail: {
                bookingTime: this.time
            }
        }))
    }
}
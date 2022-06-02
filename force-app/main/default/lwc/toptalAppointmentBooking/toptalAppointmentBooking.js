import { LightningElement, wire, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchAppointmentScreenDetails from "@salesforce/apex/Toptal_ClinicHandler.fetchAppointmentScreenDetails";
import fetchPatientDetails from "@salesforce/apex/Toptal_ClinicHandler.fetchPatientDetails";
import createAppointmentForOldPatient from "@salesforce/apex/Toptal_ClinicHandler.createAppointmentForOldPatient";
import createAppointmentForNewPatient from "@salesforce/apex/Toptal_ClinicHandler.createAppointmentForNewPatient";
import fetchPhysicianCalendarEvents from "@salesforce/apex/Toptal_GCalendarService.fetchPhysicianCalendarEvents";
import postEventToPhysicianCalendar from "@salesforce/apex/Toptal_GCalendarService.postEventToPhysicianCalendar";



import {dateValidator,getTimeSlots,validateEmail} from 'c/utils';
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

export default class ToptalAppointmentBooking extends LightningElement {
  
  appointmentDetails = [];
  specializationOptions = [];
  physicianOptions = [];
  timeSlots = []; 
  timeSlotListResponse = [];
  filterdPatients = [];
  physiciansData = new Map();
  physiciansOptionsForSpecialization = new Map();
  specializationApptmtPrice = new Map();
  referenceNo =''

 
  currentStep = "1";
  
  firstPage = false;
  navigateNext = false;
  secondPage = false;
  showCalender = false;
  hideCalender = false;
  existingPatientPage = true;
  filterTime = true;
  filterPhysician = true;
  showSpinner = false;
  optedBooking = false;
  disableBooking = true;
  apptmtForNewPatient = false;
  apptmtForExistingPatient = false;
  newPatient = false;
  showTimeSlots = false;
  openModal = false;
  isAppointmentCreated = false;
  
  
  filteredData ={
    specialization: "",
    physician: "",
    date: "",
    time: "",
  }

  existingPatient = {
    Name: '',
    EmailId : ''
  }


  @track calendarEventWrapper = {
    physicianName: "",
    physicianEmail:"",
    selectedTimeSlot: "",
    selectedDate: "",
    selectedTime:"",
    patientName:"",
    patientEmail:""
  };

  @track newPatientWrapper = {
    name: "",
    email:"",
    age: "",
    phoneNumber: "",
    patientAddress:""
  };

  @wire(fetchAppointmentScreenDetails)
  fetchScreenDetails({ error, data }) {
    if (data) {
        this.appointmentDetails = data;
        this.appointmentDetails.specializationList.forEach((spl) => {
            
            this.specializationOptions.push({
              label: spl.specialization.Name,
              value: spl.specialization.Name
            });

            this.specializationApptmtPrice .set(spl.specialization.Name,spl.specialization.Price__c);

            if(spl.physicianList.length > 0){
              for (const key in spl.physicianList) {
                  let physicianOptionsList=[];
                  physicianOptionsList.push({
                    label: spl.physicianList[key].Physician__r.Name,
                    value: spl.physicianList[key].Physician__r.Name
                  });
                  this.physiciansData.set(spl.physicianList[key].Physician__r.Name, spl.physicianList[key]);
                  this.physiciansOptionsForSpecialization.set(spl.specialization.Name, physicianOptionsList);
              }
            }
        });
       
        this.firstPage = true;
    } else if (error) {
      console.error(error);
    }
  }

  handleSpecializationChange(event) {
    this.clearObjects(this.filteredData);
    this.filteredData = {
      ...this.filteredData,
      [event.target.name]: event.target.value
    };
    this.showSpinner = true;
    this.showCalender = false;
    this.hideCalender = false;
    this.showTimeSlots = false;
    this.filterTime = true;
    this.optedBooking = false;
    this.physicianOptions = [];
    if(this.physiciansOptionsForSpecialization.has(event.target.value)){
      this.filterPhysician = false;
      this.physicianOptions = this.physiciansOptionsForSpecialization.get(event.target.value);      
    }else{
      this.filterPhysician = true;
      this.showToast(
          "Kindly select other specilization",
          "No physcian found",
          "warning"
        );
    }
    this.showSpinner = false;
  }

  handlePhysicianChange(event) {
    this.filteredData = {
      ...this.filteredData,
      [event.target.name]: event.target.value
    };
    if(this.physiciansData.has(event.target.value)){
      this.showCalender = this.physiciansData.get(event.target.value).Show_Calendar__c == true ? true:false;
      this.hideCalender = this.physiciansData.get(event.target.value).Show_Calendar__c == false ? true:false;
    }
  }


  showToast(message, title, variant) {
    const event = new ShowToastEvent({
      message: message,
      title: title,
      variant: variant,
      mode: "dismissible"
    });
    this.dispatchEvent(event);
  }

  handleDateChange(event){
    this.optedBooking = false;
    this.filteredData = {
      ...this.filteredData,
      [event.target.name]: event.target.value
    };
    this.timeSlots =[];
    let isValid =dateValidator(event.target.value);
    let date = this.template.querySelector("lightning-input[data-id='date']");
    if (isValid) {
      this.filteredData.date = "";
      date.setCustomValidity("Select today date or Future date");
      this.filterTime = true;
    }else {
      date.setCustomValidity("");
      this.filterTime = false;
    }
    date.reportValidity();
    this.getTimeSlotsDetails();
   
    
  }

  getTimeSlotsDetails(){
    this.timeSlots = getTimeSlots();
    this.timeSlotListResponse = [];
    this.filteredData.time = "";
  }

  handleTimeSlotChange(event){
    this.showSpinner = true;
    this.filteredData = {
       ...this.filteredData,
       [event.target.name]: event.target.value
     };
    this.calendarEventWrapper.physicianName = this.filteredData.physician;
    this.calendarEventWrapper.physicianEmail = this.getPhyscianEmail(this.filteredData.physician);
    this.calendarEventWrapper.selectedTimeSlot = this.filteredData.time;
    this.calendarEventWrapper.selectedDate = this.filteredData.date;
    fetchPhysicianCalendarEvents({ processCalendar: this.calendarEventWrapper})
      .then((response) => {
        if (response) {
          console.log("res", response);
          this.timeSlotListResponse = response;
          this.showSpinner = false;
          this.showTimeSlots = true;
        }
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
        this.showTimeSlots = false;
        this.showToast(
          "There is no event",
          "Problem occured on fetching",
          "error"
        );
      })
      .finally(() => {
        console.log("executed");
      });

  }

  getPhyscianEmail(physicianName){

    if (this.physiciansData.has(physicianName)) {
      return this.physiciansData.get(physicianName).Physician__r.Email;     
    }
  }


  bookAppointment(event){
    this.calendarEventWrapper.physicianName = this.filteredData.physician;
    this.calendarEventWrapper.selectedTimeSlot = this.filteredData.time;
    this.calendarEventWrapper.selectedDate = this.filteredData.date;
    this.calendarEventWrapper.selectedTime = event.detail.bookingTime;
    this.apptmtPrice = this.specializationApptmtPrice.get(this.filteredData.specialization);
    this.optedBooking = true;
    this.navigateNext = true ;

  }

  navigateToNextPage(){
    this.firstPage = false;
    this.navigateNext = false;
    this.secondPage = true;
  }

  navigateToPreviousPage(){
    this.firstPage = true;
    this.navigateNext = true;
    this.secondPage = false;
  }

  handleSearchPatient(event){
    this.existingPatient = { ...this.existingPatient, [event.target.name]: event.target.value };
  }

  searchExistingPatients(event){

    if (!this.existingPatient.Name && !this.existingPatient.EmailId){
      this.showToast("Please fill Patient Name/Email", "Error", "error");
      return;
    }
    
    let isValidEmail = this.emailValidator(this.existingPatient.EmailId);
    console.log('==isValidEmail===='+isValidEmail);
    if(((this.existingPatient.EmailId && isValidEmail && (this.existingPatient.Name ||! this.existingPatient.Name))) || 
       (this.existingPatient.Name && !this.existingPatient.EmailId)){
      this.showSpinner = true;
      fetchPatientDetails({patientName: this.existingPatient.Name, 
                          patientEmail :this.existingPatient.EmailId})
      .then((response) => {
        if (response.length >0) {
          console.log("res", response);
          this.filterdPatients = response;
          this.showSpinner = false;
        }else{
          this.showToast(
            "Patient Details Not Found",
            "Kindly click New patient to add patient",
            "error"
          );
        }
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
        this.showToast(
          "There is no event",
          "Problem occured on fetching",
          "error"
        );
      })
      .finally(() => {
        console.log("executed");
      });
    }


   }

   emailValidator(emailId){
    let isValidEmail = validateEmail(emailId);
    let emailField = this.template.querySelector("lightning-input[data-id='EmailId']");
    if (isValidEmail == false && emailId) {
      emailField.setCustomValidity("Kindly enter valid Email Id");
    } else emailField.setCustomValidity("");
    emailField.reportValidity();
    return isValidEmail;
    
   }


   handleselectedPatient(event) {
    event.preventDefault();

    this.calendarEventWrapper.patientName = event.currentTarget.dataset.name;
    this.calendarEventWrapper.patientEmail = event.currentTarget.dataset.email;
    this.template
      .querySelectorAll(".selectedPatient a")
      .forEach((element) => {
        element.classList.remove("clickBackground");
    });


    this.selectedPatientId = event.currentTarget.dataset.id;
    let inputItem = this.template.querySelector(
      `[data-id='${this.selectedPatientId}']`
    );
    inputItem.classList.add("clickBackground");
    this.disableBooking = false;
  }

  handleExistingPatientAppointment(event) {
    this.openModal = true;
    this.apptmtForExistingPatient = true;
    this.apptmtForNewPatient = false;
  }

  updateExistingPatient(event){
    let referenceNumber;
    let isEventCreated;
    this.showSpinner = true;
    

    postEventToPhysicianCalendar({createCalendarEvent: this.calendarEventWrapper})
      .then((response) => {
        if(response) { 
          console.log('====response==='+JSON.stringify(response)); 
          isEventCreated = response.isEventCreated;          
        }
        if(!isEventCreated){
          this.showToast(
            "Integration Error Occured.Please contact your administrator",
            "Problem occured on fetching",
            "error"
          );
        }
        this.showSpinner =false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
        this.showToast(
          "There is no event",
          "Problem occured on fetching",
          "error"
        );
      })
      .finally(() => {
        console.log("executed");
        if(isEventCreated){
          this.createAppointmentForOldPatient(this.selectedPatientId,this.physiciansData.get(this.filteredData.physician).Id);
        }
      });
    

  }
 
  createAppointmentForOldPatient(patientId,physicianId){
    let referenceNumber;
    createAppointmentForOldPatient({patientId: patientId , 
      physicianId :physicianId})
      .then((response) => {
        if(response) { 
          console.log('====referencenoresponse==='+response); 
          referenceNumber = response; 
          console.log('====referenceno==='+referenceNumber); 
          this.openModal = false; 
          this.secondPage = false;   
          this.isAppointmentCreated = true;
          this.currentStep = '2';
          this.successAlert(3500);
          
        }
        this.showSpinner =false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
        this.showToast(
          "There is no event",
          "Problem occured on fetching",
          "error"
        );
      })
      .finally(() => {
        console.log("executed");
        this.referenceNo = referenceNumber;
      });
  }
  handleNewPatientCreation(event){
    this.existingPatient = false;
    this.newPatient = true;
    this.disableBooking = true;
    this.secondPage = false;

  }

  handlePrevPageNavigation(event) {
    this.existingPatient = event.detail.prevPage;
    this.secondPage = event.detail.prevPage;
    this.newPatient = false;
    this.disableBooking = true;
  }

  handleNewPatientRecordCreation(event) {
    this.openModal = true;
    this.apptmtForNewPatient = true;
    this.apptmtForExistingPatient = false;
    this.calendarEventWrapper.patientName = event.detail.formValues.name;
    this.calendarEventWrapper.patientEmail = event.detail.formValues.email;

    this.newPatientWrapper = event.detail.formValues;
  }

  addPatient(event){
    let referenceNumber;
    let isEventCreated;
    this.showSpinner = true;
    

    postEventToPhysicianCalendar({createCalendarEvent: this.calendarEventWrapper})
      .then((response) => {
        if(response) { 
          isEventCreated = response.isEventCreated;          
        }
        if(!isEventCreated){
          this.showToast(
            "Integration Error Occured.Please contact your administrator",
            "Problem occured on fetching",
            "error"
          );
        }
        this.showSpinner =false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
        this.showToast(
          "There is no event",
          "Problem occured on fetching",
          "error"
        );
      })
      .finally(() => {
        console.log("executed");
        if(isEventCreated){
            this.createAppointmentForNewPatient(this.newPatientWrapper,this.physiciansData.get(this.filteredData.physician).Id);
        }
      });
    

  }

  createAppointmentForNewPatient(newPatientWrapper,physicianId){
    let referenceNumber;
    createAppointmentForNewPatient({newPatientDetails: newPatientWrapper , 
      physicianId :physicianId})
      .then((response) => {
        if(response) { 
          console.log('====referencenoresponse==='+response); 
          referenceNumber = response; 
          console.log('====referenceno==='+referenceNumber); 
          this.openModal = false; 
          this.secondPage = false;   
          this.isAppointmentCreated = true;
          this.currentStep = '2';
          this.newPatient = false;
          this.successAlert(3500);
          
        }
        this.showSpinner =false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
        this.showToast(
          "There is no event",
          "Problem occured on fetching",
          "error"
        );
      })
      .finally(() => {
        console.log("executed");
        this.referenceNo = referenceNumber;
      });
  }

  closeModal() {
    this.openModal = false;
  }

  clearObjects(object) {
    for (const key in object) {
      object[key] = "";
    }
  }

  resetFilters() {
    // making fields disables as defaults
   
    this.filterTime = true;
    this.filterPhysician = true;
    this.clearObjects(this.filteredData);
    this.showCalender = false;
    this.hideCalender = false;
    this.showTimeSlots = false;
    this.optedBooking = false;
    this.navigateNext =false;
  }

  successAlert(time){
    setTimeout(() => {
        this.secondPage = false;
        this.firstPage = true;
        this.currentStep = "1";
        this.resetFilters();
        this.isAppointmentCreated = false;
        this.clearObjects(this.existingPatient);
        this.clearObjects(this.calendarEventWrapper);
        this.filterdPatients = [];
        this.emailValid = '';
      }, time);
  }
}
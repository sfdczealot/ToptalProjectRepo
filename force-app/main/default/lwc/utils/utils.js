import AvailableSlots from "@salesforce/label/c.Toptal_AvailableSlots";

export function validateEmail(email) {
  const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

// import dateValidator from 'c/utils';
export function dateValidator(date) {
  let today = new Date().toISOString().split("T")[0];
  let selecteDate = new Date(date).toISOString().split("T")[0];
  return today > selecteDate ? true : false;
}

//import timeSlots from 'c/utils';
export function getTimeSlots() {
  let timeSlots = AvailableSlots.split(",");
  let timeSlotsList = [];
  for (const key in timeSlots) {
    timeSlotsList.push({ label: timeSlots[key], value: timeSlots[key] });
  }
  return timeSlotsList;
}
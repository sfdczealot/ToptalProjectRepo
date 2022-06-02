/**
* Util wrapper class for booking appoitments
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/

public with sharing class Toptal_WrapperUtil {
    public class NewPatient {
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public String email{get; set;}
        @AuraEnabled
        public Decimal age{get; set;}
        @AuraEnabled
        public String phoneNumber{get; set;}
        @AuraEnabled
        public String patientAddress{get; set;}
    }

    public class PatientCreationDetails {
        @AuraEnabled
        public Boolean isPatientCreated {get; set;}
        @AuraEnabled
        public String referenceNo {get; set;}
    }

    public class EventAvailability {
        public EventAvailability(String timeSlot, String availability){
            this.timeSlot = timeSlot;
            this.availability = availability;
        }
        @AuraEnabled
        public String timeSlot {get; set;}
        @AuraEnabled
        public String availability {get; set;}
    }

    public class AppointmentScreen {
        @AuraEnabled
        public List<SpecializationDetails> specializationList{get;set;}
    }

    public class SpecializationDetails {
        @AuraEnabled
        public Specialization__c specialization{get;set;}
        @AuraEnabled
        public List<Physician__c> physicianList{get;set;}
    }

    public class CalendarDetails {
        @AuraEnabled
        public String physicianName {get; set;}
        @AuraEnabled
        public String physicianEmail {get; set;}
        @AuraEnabled
        public String selectedDate {get; set;}
        @AuraEnabled
        public String selectedTimeSlot {get; set;}
        @AuraEnabled
        public String selectedTime {get; set;}
    }

    public class EventStatus {
        @AuraEnabled
        public List<EventAvailability> evtAvailabilityList {get; set;} 
    }

    public class CalendarResponse{
        @AuraEnabled
        public Boolean isEventCreated {get; set;}
        @AuraEnabled
        public Integer statusCode {get; set;}
    }
}
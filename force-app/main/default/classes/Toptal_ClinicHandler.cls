/**
* Handler class for booking appoitments
*
* @author  Ramamoorthy D
* @version 1.0
* @date   06/02/2022 
*/

public with sharing class Toptal_ClinicHandler {

   /**
   * This method is used to fetch both Specialization
   * and Physicians records
   * @return Toptal_WrapperUtil.AppointmentScreen
   */
    @AuraEnabled(cacheable=true)
    public static Toptal_WrapperUtil.AppointmentScreen fetchAppointmentScreenDetails() {
        Toptal_WrapperUtil.AppointmentScreen apptmtDetails = new Toptal_WrapperUtil.AppointmentScreen();
        List<Specialization__c> specializationsList = [ SELECT Id, Name, Price__c, (SELECT Id, Physician__c, Physician__r.Name, Physician__r.Email, Show_Calendar__c, Specialization__r.Name from Physicians__r) FROM Specialization__c ];
        List<Toptal_WrapperUtil.SpecializationDetails> specializationDetailsList = new List<Toptal_WrapperUtil.SpecializationDetails>();
        for(Specialization__c objSpecialization : specializationsList){
            Toptal_WrapperUtil.SpecializationDetails specializationDetails = new Toptal_WrapperUtil.SpecializationDetails();
            specializationDetails.specialization = objSpecialization;            
            specializationDetails.physicianList = objSpecialization.Physicians__r;
            specializationDetailsList.add(specializationDetails);
        }
        apptmtDetails.specializationList = specializationDetailsList;
        return apptmtDetails;
    }  
    
    /**
    * This method is used to create appointment for old patient
    * @param String - Name of the patient
    * @param String - Id of the physician
    * @return String - newly created appointment name
    */
    @AuraEnabled
    public static String createAppointmentForOldPatient(String patientId, String physicianId){
        if(String.isNotBlank(patientId) && String.isNotBlank(physicianId)){
            try {
                Appointment__c appointment = createAppointment(patientId,physicianId);            
                logAppointmentHistory(patientId, appointment.Id);
                if(appointment != null) {
                    return [SELECT Id, Name FROM Appointment__c WHERE Id = :appointment.Id].Name;
                }
            } catch (Exception ex) {
                throw ex;
            }
        }
        return 'Something went wrong';
    }
    
    /**
    * This method is used to create appointment for new patient
    * @param String - Name of the patient
    * @param String - Id of the appointnment
    * @return Toptal_WrapperUtil.PatientCreationDetails - newly created patient details
    */
    @AuraEnabled
    public static String createAppointmentForNewPatient(Toptal_WrapperUtil.NewPatient newPatientDetails, String physicianId){
        if(newPatientDetails != null) {
            Patient__c patient = createPatient(newPatientDetails);
            Appointment__c appointment = createAppointment(patient.Id,physicianId);
            LogAppointmentHistory(patient.Id, appointment.ID);
            if(appointment != null) {
                return [SELECT Id, Name FROM Appointment__c WHERE Id = :appointment.Id].Name;
            }
        }
        return '';
    }
    
    /**
    * This reusable method is used to create appointment history record
    * @param String - Name of the patient
    * @param String - Id of the appointnment
    * @return Appointment__c - newly created appointment record
    */
    public static void logAppointmentHistory(String patientId, String appointmentId){
        Appointment_History__c appointmentHistory = new Appointment_History__c();
        appointmentHistory.Patient__c = [SELECT Id, Name FROM Patient__c WHERE ID =: patientId LIMIT 1].Id;
        appointmentHistory.Appointment_ID__c = [SELECT ID, NAME FROM Appointment__c WHERE Id =: appointmentId LIMIT 1].Id;
        INSERT appointmentHistory;
    }
    
    /**
    * This reusable method is used to create patient record
    * @param Toptal_WrapperUtil.NewPatient - Details of the new patient
    * @return Patient__c - newly created Patient record
    */
    public static Patient__c createPatient(Toptal_WrapperUtil.NewPatient newPatientDetails){
        Patient__c patient = new Patient__c();
        patient.Name = newPatientDetails.name;
        patient.Age__c = newPatientDetails.age;
        patient.Email_Id__c = newPatientDetails.email;
        patient.Phone_number__c = newPatientDetails.phoneNumber;
        patient.Address__c = newPatientDetails.patientAddress;
        insert patient;
        if(patient != null) {
            return patient;
        }
        return patient;
    }
    
    /**
    * This reusable method is used to create appointment record
    * @param String - Name of the patient
    * @param String - Email Id of the patient
    * @return Appointment__c - newly created appointment record
    */
    public static Appointment__c createAppointment(String patientId,String physicianId){
        Appointment__c appointment = new Appointment__c();
        appointment.Patient__c = patientId;
        appointment.Physician__c =  physicianId;
        insert appointment;
        if(appointment != null) {
            return appointment;
        }
        return appointment;
    }
    
    /**
    * This method is used to fetch patient details in existing patient screen
    * @param String - Name of the patient
    * @param String - Email Id of the patient
    * @return List<Patient__c>
    */
    @AuraEnabled
    public static List<Patient__c> fetchPatientDetails(String patientName, String patientEmail) {
        List<Patient__c> patientList = new List<Patient__c>();
        String sQuery = '';
        if(String.isNotBlank(patientName) && String.isNotBlank(patientEmail)) {
            sQuery = 'SELECT Id, Name, Email_Id__c FROM  Patient__c WHERE Name LIKE ' + '\'%' + patientName + '%\'' + ' AND Email_Id__c LIKE ' + '\'%' + patientEmail + '%\'';
        }
        else if(String.isNotBlank(patientName)) {
            sQuery = 'SELECT Id, Name, Email_Id__c FROM  Patient__c WHERE Name LIKE ' + '\'%' + patientName + '%\'';
        } 
        else if(String.isNotBlank(patientEmail)) {
            sQuery = 'SELECT Id, Name, Email_Id__c FROM  Patient__c WHERE Email_Id__c LIKE ' + '\'%' + patientEmail + '%\'';
        }
        patientList = Database.Query(sQuery);
        if(patientList.size() > 0) {
            return patientList;
        }
        return patientList;
    }
  
}
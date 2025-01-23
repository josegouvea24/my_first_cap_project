// Add costum 'admin' service implementations

const cds = require('@sap/cds');

class AdminService extends cds.ApplicationService {
    init() {
        // Get the Authors entity from the data model 
        // Destructuring assignment: Unpacks values from arrays, or properties from objects, into distinct variables
        const { Authors } = this.entities;

        // register a before handler for CREATE and UPDATE operations on the Authors entity
        this.before(['CREATE', 'UPDATE'], Authors, this.validateLifeData); 

        return super.init(); // don't forget this line
    }

    validateLifeData(req) {
        // Destructuring assignment again
        const { dateOfBirth, dateOfDeath } = req.data; // req.data contains the HTTP request body

        if (!dateOfBirth || !dateOfDeath) {
            return;
        }

        const birth = new Date(dateOfBirth);
        const death = new Date(dateOfDeath);

        if (birth > death) {
            req.error('DEATH_BEFORE_BIRTH', [dateOfDeath, dateOfBirth]); // localized error message usage (see i18n folder)
            // req.error(`The date of death (${dateOfDeath}) must be after the date of birth (${dateOfBirth})`); 
            // use `` and not '' or "" (allows variables to be embedded)
        }
    }
}

module.exports = { AdminService };
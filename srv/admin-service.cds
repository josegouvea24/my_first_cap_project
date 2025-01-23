using com.sap.learning as db from '../db/schema'; // Importing the schema from the domain model

// Defining a Service:
// Default is service name in kebab-case, with string 'Service' ommitted
// Service path can be costumized using @(path: '/costum-path')
// Projections are used to shape data in a specific way for a particular service, 
// potentially limiting the fields or changing the structure of the data from the 
// model entity to suit the needs of the service consumer.
service AdminService @(path: '/admin') { 
    entity Authors as projection on db.Authors;
    entity Books as projection on db.Books;
    entity OrderItems as projection on db.OrderItems;
    entity Orders as projection on db.Orders;
}




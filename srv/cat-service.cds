using com.sap.learning as db from '../db/schema'; // Importing the schema from the domain model

service CatalogService @(path: '/cat') {
    // Explicit select clause: only what is explicitly listed will be exposed in the View
    entity Books as
        projection on db.Books {
            ID,
            title,
            author.name as writer,
            publCountry.name as publCountry,
            price.amount,
            price.currency,
            stock,
            author
        };
    
    entity Authors as
        projection on db.Authors {
            *, // all fields from Authors entity
            epoch.name as period
        } 
        excluding { //excluding clause
            createdAt,
            createdBy,
            modifiedAt,
            modifiedBy
        };
    
    //action declaration
    action submitOrder(book : db.Books:ID, quantity : Integer) returns {
        stock: db.Books:stock
    }
}
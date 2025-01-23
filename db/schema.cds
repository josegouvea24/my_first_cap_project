namespace com.sap.learning;

using {
    cuid, // unique identifier
    managed, // aspect for managed objects (createdAt, createdBy, modifiedAt, modifiedBy)
    sap.common.CodeList, // aspect for code lists (allows to define a list of values that can be used in an entity)
    Country, // aspect for country data lists (extends CodeList)
    Currency // aspect for currency data lists  (extends CodeList)
} from '@sap/cds/common';

// ENTITIES

entity Epochs: CodeList { //just "CodeList" is suficient
    key ID : UUID;
    //Added behind the scenes by CodeList extension:
    //  name: localized String(255);
    //  descr: localized String(255);
}

entity Orders {
    key ID : UUID;
        items: Composition of many OrderItems on items.order = $self; // one-to-many composition
}

// Special CAP features for Compositions:
// Cascaded delete: The deletion of an order would also result in the deletion of all its order items.
// Deep insert: In the generated OData service, both an order and the contained order items can be created via one single POST request.

entity OrderItems: cuid{
    order: Association to Orders;
    book: Association to Books;
    quantity: Integer;
}

entity Authors : cuid, managed{ // defining an entity (capitalized and plural) and extending it with an aspect
        name : String(100) @mandatory;
        dateOfBirth : Date;
        dateOfDeath : Date; // default value for an element
        books : Association to many Books on books.author = $self; // one-to-many association
        epoch: Association to Epochs @assert.target; // CodeLists usage for translation
}

extend Authors with { // extending an entity
    country : String(2);
}

entity Books : cuid, managed{
        title : localized String(100) @mandatory; // localized data, used to identify entity elements that require translated texts.
        //One-to-one association
        //@assert.target: chechk if target entity exists during CREATE and UPDATE operations.
        author : Association to Authors @mandatory @assert.target; 
        genre : Genre @assert.range: true; //@assert.range: [min, max]: check if the value is within the defined range, in this case if the value is in the Genre enumeration.
        stock : NoOfBooks default 0; // defining a default value for an element
        price : Price; //Books entity has gains two fields named price_amount and price_currency_code (foreign key for Currency entity)
        publCountry: Country; //Books entity has gains a field named publCountry_code (foreign key for Country entity)
}

// ANNOTATIONS

annotate Authors with {
    // Optimistic Locking using ETags:
    // Used to prevent conflicts when multiple users try to update the same data record at the same time.
    // ETags are used to check if the data record has been modified since the last time it was read.
    // If the ETag value in the request does not match the ETag value in the database, the request is rejected.
    // Elements who change uniquely each time a data record is updated are good ETag candidates.
    modifiedAt @odata.etag 
}

annotate Books with {
    modifiedAt @odata.etag
}

// ASPECTS

aspect ExtraInfo { // defining an aspect
    publishedDate : Date;
    publisherName : String(255);
}

extend Books with ExtraInfo; // extending an entity with an aspect


// TYPES

type NoOfBooks : Integer; // defining a type (capitalized and single)

type Price { // defining a structured type 
    amount : Decimal;
    currency : Currency;
}

type Genre: Integer enum { // defining an enumeration type
    fiction = 1;
    non_fiction = 2;
}


const cds = require('@sap/cds');

class CatalogService extends cds.ApplicationService {
    init() {
        const { Books } = this.entities;

        this.after('READ', Books, this.grantDiscount); // register after handler
        
        this.on('submitOrder', this.reduceStock); // register on handler

        return super.init();
    }

    // After handler recieve two arguments: 
    // req (cds.Request instance) and results (outcomes of the on handler which ran before)
    grantDiscount(results) {
        for (let b of results) {
            if (b.stock > 200) { b.title += ' -- 11% discount!'; } 
        }
    }

    // On handler, declared async so we the await operator can be used to wait for the result of the SELECT query
    async reduceStock(req) {
        const { Books } = this.entities;
        const { book, quantity } = req.data;

        if (quantity < 1) {
            return req.error('INVALID_QUANTITY');
        }
        
        // Query construction (https://cap.cloud.sap/docs/node.js/cds-ql#select)
        // let query1 = SELECT.one.from(Books).where({ ID: book }).columns( b => ({ stock: b.stock }));
        // or using tagged template literals:
        let query1 = SELECT.one.from(Books).where`ID=${book}`.columns`stock`;
        
        const b = await cds.db.run(query1); // execute the query (b is undefined if book with the given ID is not found)
        // or:
        // const b = SELECT.one.from(Books).where({ ID: book }).columns( b => ({ stock: b.stock }));
        // or:
        // const b = SELECT.one.from(Books).where`ID=${book}`.columns`stock`;

        if (!b) {
            return req.error('BOOK_NOT_FOUND', [book]);
        }

        let { stock } = b;
        if (stock < quantity) {
            return req.error('ORDER_EXCEEDS_STOCK', [quantity, stock, book]);
        }

        // Option 1:
        // let query2 = UPDATE(Books).where({ ID: book }).set({ stock: stock - quantity });
        // await cds.db.run(query2);
        // Option 2:
        // let query2 = UPDATE(Books).where`ID=${book}`.set({ stock: { '-=': quantity } });
        // await cds.db.run(query2);
        // Option 3:
        // await UPDATE(Books).where({ ID: book }).set({ stock: { '-=': quantity } });
        // Option 4:
        await UPDATE(Books).where`ID=${book}`.set({ stock: { '-=': quantity } });

        return { stock: stock - quantity };
    }

    /*
    Alternativelly to registering a handler, actions and functions can also be implemented 
    as conventional JS methods on a service implementation class. The method name must match 
    the name of the action/function. 
    The implementation for our submitOrder action would look like this:

    class CatalogService extends cds.ApplicationService {

      submitOrder(book, quantity) {
        const { Books } = this.entities;

        if (quantity < 1) {
          return req.error('The quantity must be at least 1.');
        }

        let stock = 10;
        return { stock };
      }

    }
    */
}

module.exports ={ CatalogService };
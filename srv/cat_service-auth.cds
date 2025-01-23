using { //import entity definitions
    CatalogService.Authors,
    CatalogService.Books,
    CatalogService.submitOrder
} from './cat-service';

annotate Authors with @readonly;
annotate Books with @readonly;
annotate submitOrder with @(requires: 'authenticated-user'); //pseudo role authentication
// @requires can be used at service level, entity level, action level, and function level

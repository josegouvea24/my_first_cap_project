using { AdminService.Authors, AdminService.Books } from './admin-service';

annotate Books with @(restrict: [ // @restrict annotation usage
    {
        grant: ['DELETE'], //allowed operations
        to: 'admin', //role (optional)
        where: 'stock = 0' //condition (optional)
    },
    {
        grant: ['READ', 
                'CREATE',
                'UPDATE'
        ],
        to: 'admin'
    }
]);
// restrict annotations can be used at service level, entity level, action level, and function level
// however, the grant and where properties are only available at entity level

annotate Authors with @(requires: 'admin');
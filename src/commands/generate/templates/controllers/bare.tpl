/**
 * <%= folder %>/<%= entityClass %>
 *
 * @description :: Server-side logic for managing <%= entityClass %> entities
 */

/**
 * BareController
 *
 * @description :: Server-side logic for managing users
 * @help        :: See http://links.axel.s.org/docs/controllers
 */

/**
 * Api/BareController
 *
 * @description :: Server-side logic for managing all entitys
 * @help        :: See http://axel.s.org/#!/documentation/concepts/Controllers
 */
const { ExtendedError, Utils } = require('axel-core'); // adjust path as needed

/*
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel

*/
// const { ExcelService, DocumentManager } = require('axel-core');

const primaryKey = axel.config.framework.primaryKey;
const entity = '<%= entity %>';

class <%= entityClass %>Controller {
  stats(request, response, next) {
      // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  list(request, response, next) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  get(request, response, next) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  post(request, response, next) {
        // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  /**
   * [put description]
   * [description]
   * @method
   * @param  {[type]} request  [description]
   * @param  {[type]} response [description]
   * @return {[type]}      [description]
   */
  put(request, response, next) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  /**
   * [delete Item]
   * [description]
   * @method
   * @param  {[type]} request  [description]
   * @param  {[type]} response [description]
   * @return {[type]}      [description]
   */
  delete(request, response, next) {
 // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  export(request, response, next) {

      // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  importTemplate(request, response, next) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  import(request, response, next) {
      // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }
}

module.exports = new <%= entityClass %>Controller();

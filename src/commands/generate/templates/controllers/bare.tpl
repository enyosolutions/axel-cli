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
const { stats, findAll, findOne, create, update, deleteOne, export, import, importTemplate } = require('axel-core/src/controllers/CrudSqlController');

/*
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel

*/
// const { ExcelService, DocumentManager } = require('axel-core');

const primaryKey = axel.config.framework.primaryKey;
const modelName = '<%= entity %>';

class <%= entityClass %>Controller {
  stats(request, response, next) {
      // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      stats(request, response, next);
  }

  list(request, response, next) {
       // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      findAll(request, response, next);
  }

  get(request, response, next) {
       // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      findOne(request, response, next);
  }

  post(request, response, next) {
        // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      create(request, response, next);
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
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      update(request, response, next);
  }

  /**
   * [delete Item]
   * [description]
   * @method
   * @param  {[type]} request  [description]
   * @param  {[type]} response [description]
   * @return {[type]}      [description]
   */
  deleteOne(request, response, next) {
      // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      deleteOne(request, response, next);
  }

  export(request, response, next) {

      // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      export(request, response, next);
  }

  importTemplate(request, response, next) {
       // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      importTemplate(request, response, next);
  }

  import(request, response, next) {
      // your route related code goes here.
      request.modelName = modelName;
      // This sends the request to the default crud controller, delete if you implement your own action code.
      import(request, response, next);
  }
}

module.exports = new <%= entityClass %>Controller();

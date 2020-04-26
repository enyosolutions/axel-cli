/**
 * <%= folder %>/<%= entityClass %>
 *
 * @description :: Server-side logic for managing <%= entityClass %> entities
 */

/**
 * UserSqlController
 *
 * @description :: Server-side logic for managing users
 * @help        :: See http://links.esails.s.org/docs/controllers
 */

/**
 * Api/CrudSqlController
 *
 * @description :: Server-side logic for managing all entitys
 * @help        :: See http://esails.s.org/#!/documentation/concepts/Controllers
 */
import { Request, Response, NextFunction } from 'express';
import Utils from '../../common/services/Utils'; // adjust path as needed
import EnyoError from '../../common/services/EnyoError'; // adjust path as needed
/*
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel

*/
// import DocumentManager from '../../services/DocumentManager';
// import ExcelService from '../../services/ExcelService';

declare const esails: any;

const primaryKey = esails.config.framework.primaryKey;
const entity = '<%= entity %>';

class <%= entityClass %>Controller {
  stats(request: Request, response: Response, next: NextFunction) {
      // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - stats');
      }
  }

  list(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - list');
      }
  }

  get(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - get');
      }
  }

  post(request: Request, response: Response, next: NextFunction) {
        // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - post');
      }
  }

  /**
   * [put description]
   * [description]
   * @method
   * @param  {[type]} request  [description]
   * @param  {[type]} response [description]
   * @return {[type]}      [description]
   */
  put(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - put');
      }
  }

  /**
   * [delete Item]
   * [description]
   * @method
   * @param  {[type]} request  [description]
   * @param  {[type]} response [description]
   * @return {[type]}      [description]
   */
  delete(request: Request, response: Response, next: NextFunction) {
 // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - delete');
      }
  }

  export(request: Request, response: Response, next: NextFunction) {

      // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - export');
      }
  }

  importTemplate(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the requestuest the default crud controller, delete if you implement your own action code.
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - generate import template');
      }
  }

  import(request: Request, response: Response, next: NextFunction) {
         // sends the requestuest the default crud controller
      if (next) {
          next();
      }
      else {
          response.send('<%= entityClass %> - import');
      }
  }
}

export default new <%= entityClass %>Controller();

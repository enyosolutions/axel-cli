/**
 * <%= folder %>/<%= entityClass %>
 *
 * @description :: Server-side logic for managing <%= entityClass %> entities
 */

/**
 * UserSqlController
 *
 * @description :: Server-side logic for managing users
 * @help        :: See http://links.axel.s.org/docs/controllers
 */

/**
 * Api/CrudSqlController
 *
 * @description :: Server-side logic for managing all entitys
 * @help        :: See http://axel.s.org/#!/documentation/concepts/Controllers
 */
import { Request, Response, NextFunction } from 'express';
import Utils from '../../common/services/Utils'; // adjust path as needed
import ExtendedError from '../../../axel'; // adjust path as needed
/*
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel

*/
// import DocumentManager from '../../services/DocumentManager';
// import ExcelService from '../../services/ExcelService';

declare const axel: any;

const primaryKey = axel.config.framework.primaryKey;
const entity = '<%= entity %>';

class <%= entityClass %>Controller {
  stats(request: Request, response: Response, next: NextFunction) {
      // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  list(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  get(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  post(request: Request, response: Response, next: NextFunction) {
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
  put(request: Request, response: Response, next: NextFunction) {
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
  delete(request: Request, response: Response, next: NextFunction) {
 // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  export(request: Request, response: Response, next: NextFunction) {

      // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  importTemplate(request: Request, response: Response, next: NextFunction) {
       // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }

  import(request: Request, response: Response, next: NextFunction) {
      // your route related code goes here.

      // This sends the request to the default crud controller, delete if you implement your own action code.
      next();
  }
}

export default new <%= entityClass %>Controller();

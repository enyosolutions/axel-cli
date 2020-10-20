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

import { Request, Response } from 'express';
import Utils from '../../common/services/Utils'; // adjust path as needed
import ExtendedError from '../../axel'; // adjust path as needed

/*
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel
*/

// import DocumentManager from '../../services/DocumentManager';
// import ExcelService from '../../services/ExcelService';

declare const axel: any;

const entity = '<%= entityCamelCased %>';
const primaryKey = axel.models[entity] && axel.models[entity].primaryKeyField ? axel.models[entity].primaryKeyField : axel.config.framework.primaryKey;


class <%= entityClass %>Controller {
  stats(req: Request, resp: Response) {
    const output: { total?: any; month?: any; week?: any; today?: any } = {};


    if (!axel.models[entity] || !axel.models[entity].repository) {
      return resp.status(404).json({
        errors: ['not_found'],
        message: 'not_found'
      });
    }
    const { repository, tableName } = axel.models[entity];
    repository
      .count({})
      .then((data: number) => {
        // TOTAL
        output.total = data;

        // THIS MONTH
        return axel.sqldb.query(
          `SELECT COUNT(*)  as month
        FROM
        FROM ${tableName}
        WHERE
        createdOn >= SUBDATE(CURDATE(), DAYOFMONTH(CURDATE())-1)`,
          {
            type: axel.sqldb.QueryTypes.SELECT
          }
        );
      })
      .then((data: [{ month: number }]) => {
        if (data && data.length > 0 && data[0].month) {
          output.month = data[0].month;
        } else {
          output.month = 0;
        }

        // THIS WEEK
        return axel.sqldb.query(
          `SELECT COUNT(*) as week
          FROM ${tableName}
        WHERE
        YEARWEEK(createdOn) = YEARWEEK(CURRENT_TIMESTAMP)`,
          {
            type: axel.sqldb.QueryTypes.SELECT
          }
        );
      })
      .then((data: [{ week: number }]) => {
        if (data && data.length > 0 && data[0].week) {
          output.week = data[0].week;
        } else {
          output.week = 0;
        }

        // TODAY
        return axel.sqldb.query(
          `SELECT COUNT(*) as today
          FROM ${tableName}
        WHERE
        DATE(createdOn) = DATE(NOW())`,
          {
            type: axel.sqldb.QueryTypes.SELECT
          }
        );
      })
      .then((data: [{ today: number }]) => {
        if (data && data.length > 0 && data[0].today) {
          output.today = data[0].today;
        } else {
          output.today = 0;
        }

        return resp.status(200).json({
          body: output
        });
      })
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }

  list(req: Request, resp: Response) {
    let items: Array<object> = [];

    const {
      listOfValues,
      startPage,
      limit,
      offset,
      order
    } = Utils.injectPaginationQuery(req);
    let query = Utils.injectQueryParams(req);
    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }
    if (req.query.search) {
      query = Utils.injectSqlSearchParams(req, query, {
        modelName: req.params.entity
      });
    }
    query = Utils.cleanSqlQuery(query);
    repository
      .findAndCountAll({
        // where: req.query.filters,
        where: query,
        order,
        limit,
        offset
      })
      .then((result: { rows: [object]; count: number }) => {
        items = result.rows;
        if (listOfValues) {
          items = items.map((item: any) => ({
            [primaryKey]: item[primaryKey],
            label:
              item.title ||
              item.name ||
              item.label ||
              `${item.firstname} ${item.lastname}`
          }));
        }
        return result.count || 0;
      })

      .then((totalCount?: number) =>
        resp.status(200).json({
          body: items,
          page: startPage,
          count: limit,
          totalCount: totalCount
        })
      )
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }

  get(req: Request, resp: Response) {
    const id = parseInt(req.params.id);
    if (!id) {
      return false;
    }
    const listOfValues = req.query.listOfValues
      ? req.query.listOfValues
      : false;

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }
    repository
      .findOne({
        where: { [primaryKey]: id },
        raw: false
      })
      .catch((err: Error) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err);
        }
        throw new ExtendedError({
          code: 404,
          errors: [
            {
              message: err.message || 'not_found'
            }
          ],
          message: err.message || 'not_found'
        });
      })
      .then((item: any) => {
        if (item) {
          item = item.get();
          if (listOfValues) {
            item = {
              [primaryKey]: item[primaryKey],
              label:
                item.title ||
                item.name ||
                item.label ||
                `${item.firstname} ${item.lastname}`
            };
          }
          return resp.status(200).json({
            body: item
          });
        }
        throw new ExtendedError({
          code: 404,
          errors: [
            {
              message: 'not_found'
            }
          ],
          message: 'not_found'
        });
      })
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }

  post(req: Request, resp: Response) {
    const data = Utils.injectUserId(req.body, req.token);

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }
    repository
      .create(data)
      .then((result: any) =>
        resp.status(200).json({
          body: result
        })
      )
      .catch((err: ExtendedError) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err);
        }
        if (err && err.name === 'SequelizeValidationError') {
          resp.status(400).json({
            //@ts-ignore
            errors: err.errors && err.errors.map((e: ExtendedError) => e.message),
            message: 'validation_error'
          });
          return false;
        }
        Utils.errorCallback(err, resp);
      });
  }

  /**
   * [put description]
   * [description]
   * @method
   * @param  {[type]} req  [description]
   * @param  {[type]} resp [description]
   * @return {[type]}      [description]
   */
  put(req: Request, resp: Response) {
    const id = parseInt(req.params.id);
    let data = req.body;


    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }
    repository
      .findByPk(id)
      .catch((err: Error) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err);
        }
        throw new ExtendedError({
          code: 404,
          errors: [
            {
              message: err.message || 'not_found'
            }
          ],
          message: err.message || 'not_found'
        });
      })
      .then((result: any) => {
        if (result) {
          return repository.update(data, {
            where: {
              [primaryKey]: id
            }
          });
        }
        throw new ExtendedError({
          code: 404,
          message: 'not_found',
          errors: ['not_found']
        });
      })
      .then(() => repository.findByPk(id))
      .then((result: any) => {
        if (result) {
          return resp.status(200).json({
            body: result
          });
        }
        return resp.status(404).json({
          errors: ['not_found'],
          message: 'not_found'
        });
      })
      .catch((err: ExtendedError) => {
        if (err && err.name === 'SequelizeValidationError') {
          resp.status(400).json({
            //@ts-ignore
            errors: err.errors && err.errors.map((e: ExtendedError) => e.message),
            message: 'validation_error'
          });
          return false;
        }
        Utils.errorCallback(err, resp);
      });
  }

  /**
   * [delete Item]
   * [description]
   * @method
   * @param  {[type]} req  [description]
   * @param  {[type]} resp [description]
   * @return {[type]}      [description]
   */
  delete(req: Request, resp: Response) {
    const id = parseInt(req.params.id);

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }
    repository
      .destroy({
        where: {
          [primaryKey]: id
        }
      })
      .catch((err: Error) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err);
        }
        throw new ExtendedError({
          code: 400,
          errors: [err || 'delete_error'],
          message: err.message || 'delete_error'
        });
      })
      .then((a: any) => {
        if (!a) {
          return resp.status(404).json();
        }
        resp.status(200).json({
          status: 'OK',
        });
      })
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }

  /*
  export(req: Request, resp: Response) {

    let repository;
    const schema = axel.models[entity] && axel.models[entity].schema;
    let data = [];

    const url = `${entity}_export`;
    const options = {};
    const query = {};

    Promise.resolve()
      .then(() => {
        repository = Utils.getEntityManager(entity, resp);
        if (!repository) {
          throw new Error('table_model_not_found_error_O');
        }

        return repository.findAll({
          where: query
        });
      })
      .then(result => {
        data = result;
        return ExcelService.export(data, url, options);
      })
      .then(result => {
        if (result) {
          if (result.errno) {
            return resp.status(500).json({
              errors: ['export_failed'],
              message: 'export_failed'
            });
          }

          return resp.status(200).json({
            status: 'OK',
            url: result
          });
        }
        return resp.status(404).json({
          errors: ['not_found'],
          message: 'not_found'
        });
      })
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }

  getImportTemplate(req: Request, resp: Response) {


    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      throw new Error('table_model_not_found_error_O');
    }

    let data = [];

    const url = `${entity}_template`;
    const options = {};
    const query = {};

    Promise.resolve()
      .then(() =>
        repository.findAll({
          limit: 1
        })
      )
      .then(result => {
        data = result;
        return ExcelService.export(data, url, options);
      })
      .then(result => {
        if (result) {
          if (result.errno) {
            return resp.status(500).json({
              errors: ['export_failed'],
              message: 'export_failed'
            });
          }

          return resp.status(200).json({
            status: 'OK',
            url: result
          });
        }
        return resp.status(404).json({
          errors: ['not_found'],
          message: 'not_found'
        });
      })
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }

  import(req: Request, resp: Response) {
    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }

    const properData: [] = [];
    const improperData: [] = [];
    let doc: any;
    DocumentManager.httpUpload(req, {
      path: 'updloads/excel'
    })
      // @ts-ignore
      .then((document?: any[]) => {
        if (document && document.length > 0) {
          doc = document[0];
          return ExcelService.parse(doc.fd, {
            columns: {},
            eager: false
          });
        }
        throw new ExtendedError({
          code: 404,
          message: 'no_file_uploaded',
          errors: ['no_file_uploaded']
        });
      })
      .then((result?: []) => {
        if (result) {
          result.forEach(item => {
            // check if data is proper before pushing it
            properData.push(item);
          });
          if (properData.length > 0) {
            return repository.bulkCreate(properData);
          }
          return true;
        }
        throw new ExtendedError({
          code: 404,
          message: 'parse_error',
          errors: ['parse_error']
        });
      })
      .catch((err: Error) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err);
        }
        throw new ExtendedError({
          errors: [
            {
              message: err.message || 'create_error'
            }
          ],
          message: err.message || 'create_error'
        });
      })
      .then(() => DocumentManager.delete(doc[0].fd))
      .catch((err: Error) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        throw new ExtendedError({
          code: 500,
          errors: [
            {
              message: err.message || 'delete_error'
            }
          ],
          message: err.message || 'delete_error'
        });
      })
      .then(() =>
        resp.json({
          body: 'ok',
          properData,
          improperData
        })
      )
      .catch((err: Error) => {
        Utils.errorCallback(err, resp);
      });
  }
  */
}

export default new <%= entityClass %>Controller();

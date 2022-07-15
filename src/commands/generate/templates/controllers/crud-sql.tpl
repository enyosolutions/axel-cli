/**
 * <%= folder %>/<%= entityClass %>
 *
 * @description :: Server-side logic for managing <%= entityClass %> endpoints
 */
import { Request, Response } from 'express';
import Utils from '../../../common/services/Utils';
import ExtendedError from '../../../axel'; // adjust path as needed
import DocumentManager from '../../services/DocumentManager';
import ExcelService from '../../services/ExcelService';

declare const axel;

const primaryKey = axel.config.enyo.primaryKey;

class CrudSqlController {
  list(req, resp) {
    let items: Array<object> = [];

    const {
      startPage,
      limit,
      offset,
      order
    } = req.pagination || Utils.injectPaginationQuery(req);
    let query = req.parsedQuery || Utils.injectQueryParams(req);
    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    if (req.query.search) {
      query = Utils.injectSqlSearchParams(req, query, {
        modelName: req.params.endpoint
      });
    }
    repository
      .findAndCountAll({
        // where: req.query.filters,
        where: query,
        order,
        limit,
        offset
      })
      .then((result) => {
        items = result.rows;
        return result.count || 0;
      })

      .then((totalCount) =>
        resp.status(200).json({
          body: items,
          page: startPage,
          count: limit,
          totalCount: totalCount
        })
      )
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }
        Utils.errorCallback(err, resp);
      });
  }

  get(req, resp) {
    const id = req.param('id');
    if (!id) {
      return false;
    }

    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    repository
      .findOne({
        where: { [primaryKey]: id },
        raw: false
      })
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
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
      .then((item) => {
        if (item) {
          item = item.get();
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
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        Utils.errorCallback(err, resp);
      });
  }

  post(req, resp) {
    const data = Utils.injectUserId(req.body, req.user);

    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    if (axel.config.framework && axel.config.framework.validateDataWithJsonSchema) {
      try {
        const result = SchemaValidator.validate(data, req.params.endpoint);
        if (!result.isValid) {
          console.warn('[SCHEMA VALIDATION ERROR]', req.params.endpoint, result, data);
          resp.status(400).json({
            message: 'data_validation_error',
            errors: result.formatedErrors,
          });
          debug('formatting error', result);
          return;
        }
      } catch (err) {
        throw new Error('error_wrong_json_format_for_model_definition');
      }
    }
    repository
      .create(data)
      .then((result) =>
        resp.status(200).json({
          body: result
        })
      )
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        if (err && err.name === 'SequelizeValidationError') {
          resp.status(400).json({
            //@ts-ignore
            errors: err.errors && err.errors.map((e) => e.message),
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
  put(req, resp) {
    const id = req.param('id');
    let data = req.body;

    const endpoint = req.param('endpoint');
    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    if (axel.config.framework && axel.config.framework.validateDataWithJsonSchema) {
      try {
        const result = SchemaValidator.validate(data, req.params.endpoint);
        if (!result.isValid) {
          console.warn('[SCHEMA VALIDATION ERROR]', req.params.endpoint, result, data);
          resp.status(400).json({
            message: 'data_validation_error',
            errors: result.formatedErrors,
          });
          debug('formatting error', result);
          return;
        }
      } catch (err) {
        throw new Error('error_wrong_json_format_for_model_definition');
      }
    }
    repository
      .findByPk(id)
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
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
      .then((result) => {
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
      .then((result) => {
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
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        if (err && err.name === 'SequelizeValidationError') {
          resp.status(400).json({
            //@ts-ignore
            errors: err.errors && err.errors.map((e) => e.message),
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
  delete(req, resp) {
    const id = req.param('id');

    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    repository
      .destroy({
        where: {
          [primaryKey]: id
        }
      })
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }
        throw new ExtendedError({
          code: 400,
          errors: [err || 'delete_error'],
          message: err.message || 'delete_error'
        });
      })
      .then(() =>
        resp.status(200).json({
          status: 'OK'
        })
      )
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        Utils.errorCallback(err, resp);
      });
  }

  export(req, resp) {
    const endpoint = req.param('endpoint');
    let repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    const schema = axel.models[endpoint] && axel.models[endpoint].schema;
    let data = [];

    const url = `${endpoint}_export`;
    const options = {};
    const query = {};

    repository.findAll({
        where: query
      })
      .then(result => {
        data = result;
        if (endpoint === 'user') {
          data = data.map((item) => {
            delete item.encryptedPassword;
            delete item.resetToken;
            return item;
          });
        }
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
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        Utils.errorCallback(err, resp);
      });
  }

  importTemplate(req, resp) {
    const endpoint = req.param('endpoint');

    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }

    let data = [];

    const url = `${endpoint}_template`;
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
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        Utils.errorCallback(err, resp);
      });
  }

  import(req, resp) {
    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      resp.status(400).json({ message: 'error_model_not_found_for_this_url' });
      return;
    }
    const endpoint = req.param('endpoint');
    const properData = [];
    const improperData = [];
    let doc;
    DocumentManager.httpUpload(req, {
      path: 'updloads/excel'
    })
      // @ts-ignore
      .then((document) => {
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
      .then((result) => {
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
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
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
      .catch((err) => {
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
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err && err.message ? err.message : err);
        }

        Utils.errorCallback(err, resp);
      });
  }
}

export default new CrudSqlController();

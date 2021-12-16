/**
 * <%= folder %>/<%= entityClass %>
 *
 * @description :: Server-side logic for managing <%= entityClass %> entities
 */


const { ExtendedError, Utils, SchemaValidator } = require('axel-core');
const { get } = require('lodash');



/*
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel
*/

// import DocumentManager from '../../services/DocumentManager';
// import ExcelService from '../../services/ExcelService';

const entity = '<%= entityCamelCased %>';
const primaryKey = axel.models[entity] && axel.models[entity].primaryKeyField
  ? axel.models[entity].primaryKeyField : axel.config.framework.primaryKey;


class <%= entityClass %>Controller {
  list(req, resp) {
    let items = [];

    const {
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
        modelName: entity
      });
    }
    query = Utils.cleanSqlQuery(query);
    repository
      .findAndCountAll({
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
        Utils.errorCallback(err, resp);
      });
  }

  get(req, resp) {
    const id = req.params.id;

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      // No need to send response error as it's already thrown in the Entity manager getter
      return;
    }
    repository
      .findOne({
        where: { [primaryKey]: id },
        raw: false
      })
      .catch((err) => {
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
        Utils.errorCallback(err, resp);
      });
  }

  post(req, resp) {
    const data = Utils.injectUserId(req.body, req.user, ['createdBy']); // replace field by userId or any other relevant field

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }

    if (get(axel, 'config.framework.validateDataWithJsonSchema') && (axel.models[entity] && axel.models[entity].autoValidate)) {
      try {
        const result = SchemaValidator.validate(data, entity);
        if (!result.isValid) {
          console.warn('[SCHEMA VALIDATION ERROR]', entity, result, data);
          resp.status(400).json({
            message: 'data_validation_error',
            errors: result.formatedErrors,
          });
          return;
        }
      } catch (err) {
        return resp.status(400).json({
          message: 'error_wrong_json_format_for_model_definition',
          errors: [err.message],
        });
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
          axel.logger.warn(err);
        }
        if (err && err.name === 'SequelizeValidationError') {
          return resp.status(400).json({
            //@ts-ignore
            errors: err.errors && err.errors.map((e) => e.message),
            message: 'validation_error'
          });
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
    const id = req.params.id;
    const data = Utils.injectUserId(req.body, req.user, ['lastModifiedBy']); // replace field by userId or any other relevant field

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      // No need to send response error as it's already thrown in the Entity manager getter
      return;
    }
    if (get(axel, 'config.framework.validateDataWithJsonSchema') && (axel.models[entity] && axel.models[entity].autoValidate)) {
      try {
        const result = SchemaValidator.validate(data, entity);
        if (!result.isValid) {
          console.warn('[SCHEMA VALIDATION ERROR]', entity, result, data);
          return resp.status(400).json({
            message: 'data_validation_error',
            errors: result.formatedErrors,
          });
        }
      } catch (err) {
        return resp.status(400).json({
          message: 'error_wrong_json_format_for_model_definition',
          errors: [err.message],
        });
      }
    }

    repository
      .findByPk(id)
      .catch((err) => {
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
        if (err && err.name === 'SequelizeValidationError') {
          return resp.status(400).json({
            errors: err.errors && err.errors.map((e) => e.message),
            message: 'validation_error'
          });
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
  delete (req, resp) {
    const id = req.params.id;

    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }

    repository
      .findByPk(id)
      .then(async (result) => {
        if (!result) {
          throw new ExtendedError({
            code: 404,
            errors: ['not_found'],
            message: 'not_found'
          });
        }
        return result;
      })
      .then(() =>
        repository
          .destroy({
            where: {
              [primaryKey]: id
            }
          }))
      .catch((err) => {
        if (process.env.NODE_ENV === 'development') {
          axel.logger.warn(err);
        }
        throw new ExtendedError({
          code: err.code || 400,
          errors: [err.message || err || 'delete_error'],
          message: err.message || 'delete_error'
        });
      })
      .then((a) => {
        if (!a) {
          return resp.status(404).json();
        }
        return resp.status(200).json({
          status: 'OK',
        });
      })
      .catch((err) => {
        Utils.errorCallback(err, resp);
      });
  }

  /*
  export(req, resp) {

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
      .catch((err) => {
        Utils.errorCallback(err, resp);
      });
  }

  getImportTemplate(req, resp) {

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
      .catch((err) => {
        Utils.errorCallback(err, resp);
      });
  }

  import(req, resp) {
    const repository = Utils.getEntityManager(entity, resp);
    if (!repository) {
      return;
    }

    const properData: [] = [];
    const improperData: [] = [];
    let doc;
    DocumentManager.httpUpload(req, {
      path: 'updloads/excel'
    })
      // @ts-ignore
      .then((document?[]) => {
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
      .catch((err) => {
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
        Utils.errorCallback(err, resp);
      });
  }
  */
}

module.exports = new <%= entityClass %>Controller();

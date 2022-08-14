/**
 * <%= folder %>/<%= entityClass %>
 *
 * @description :: Server-side logic for managing <%= entityClass %> entities
 */

const { ExtendedError, Utils, SchemaValidator, ControllerUtils } = require('axel-core');
const { get } = require('lodash');
const path = require('path');

/**
Uncomment if you need the following features:
- Create import template for users
- Import from excel
- Export to excel
*/
// const { DocumentManager } = require('axel-core');
// const ExcelService = require('axel-core/src/services/ExcelService');

const { execHook, getPrimaryKey } = ControllerUtils;
const modelName = '<%= entityCamelCased %>';
const primaryKey = getPrimaryKey(modelName);

class <%= entityClass %>Controller {

  async list(req, resp, next) {
    try {
      let items = [];
      const {
        startPage, limit, offset, order
      } = req.pagination;
      let query = req.parsedQuery;

      const repository = Utils.getEntityManager(req, resp);
      if (!repository) {
        throw new ExtendedError({
          code: 400,
          message: 'error_model_not_found_for_this_url'
        });
      }
      if (req.query.search) {
        query = Utils.injectSqlSearchParams(req, query, {
          modelName: modelName
        });
      }

      query = Utils.cleanSqlQuery(query);
      const sequelizeQuery = {
        where: query,
        order,
        limit,
        offset,
        raw: false,
        nested: true
      };
      await execHook(modelName, 'beforeApiFind', { request: req, sequelizeQuery });
      const { rows, count } = await repository
        .findAndCountAll(sequelizeQuery);


      items = rows.map(item => item.get());
      const result = {
        body: items,
        page: startPage,
        perPage: limit,
        count: limit,
        totalCount: count
      };
      await execHook(modelName, 'afterApiFind', result, { request: req, response: resp });

      resp.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }

  async get(req, resp, next) {
    const id = req.params.id;
    try {
      const repository = Utils.getEntityManager(req, resp);
      if (!repository) {
        throw new ExtendedError({ code: 400, message: 'error_model_not_found_for_this_url' });
      }
      const sequelizeQuery = {
        where: { [primaryKey]: id },
        raw: false
      };
      await execHook(modelName, 'beforeApiFindOne', { request: req, sequelizeQuery });
      const item = await repository
        .findOne(sequelizeQuery);

      if (!item) {
        throw new ExtendedError({
          code: 404,
          errors: [
            `${modelName}_not_found_${id}`
          ],
          message: 'item_not_found'
        });
      }

      const result = {
        body: item.get()
      };
      execHook(modelName, 'afterApiFindOne', result, { request: req, response: resp });
      return resp.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }

  async post(req, resp, next) {
    const data = Utils.injectUserId(req.body, req.user, ['createdBy']); // replace field by userId or any other relevant field
    try {
      await execHook(modelName, 'beforeApiCreate', { request: req, sequelizeQuery: data });
      const repository = Utils.getEntityManager(req, resp);
      if (!repository) {
        throw new ExtendedError({ code: 400, message: 'error_model_not_found_for_this_url' });
      }
      await SchemaValidator.validateAsync(data, modelName);

      const result = {
        body: await repository
        .create(data)
      };
      result.body = result.body.get();
      await execHook(modelName, 'afterApiCreate', result, { request: req, response: resp });

      resp.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }

  /**
   * [put description]
   * [description]
   * @method
   * @param  {[type]} req  [description]
   * @param  {[type]} resp [description]
   * @return {[type]}      [description]
   */
  async put(req, resp, next) {
    const data = Utils.injectUserId(req.body, req.user, ['lastModifiedBy']); // replace field by userId or any other relevant field

    const id = req.params.id;

    try {
      const repository = Utils.getEntityManager(req, resp);
      if (!repository) {
        throw new ExtendedError({ code: 400, message: 'error_model_not_found_for_this_url' });
      }

      const sequelizeQuery = { where: { [primaryKey]: id } };
      sequelizeQuery.individualHooks = true;
      sequelizeQuery.raw = false;

      await execHook(modelName, 'beforeApiUpdate', { request: req, sequelizeQuery });
      await SchemaValidator.validateAsync(data, modelName);

      const exists = await repository
        .findOne(sequelizeQuery);
      if (!exists) {
        throw new ExtendedError({
          code: 404,
          message: 'item_not_found',
          errors: ['item_not_found']
        });
      }

      await repository.update(data, sequelizeQuery);

      const result = {
        body: await repository
        .create(data)
      };
      result.body = result.body.get();
      await execHook(modelName, 'afterApiUpdate', result, { request: req, response: resp });

      return resp.status(200).json({
        body: result
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * [delete Item]
   * [description]
   * @method
   * @param  {[type]} req  [description]
   * @param  {[type]} resp [description]
   * @return {[type]}      [description]
   */
  async delete (req, resp, next) {
    try {
      const id = req.params.id;
      const repository = Utils.getEntityManager(req, resp);

      if (!repository) {
        throw new ExtendedError({ code: 400, message: 'error_model_not_found_for_this_url' });
      }
      const sequelizeQuery = { where: { [primaryKey]: id } };
      // make sure hooks are triggered
      sequelizeQuery.individualHooks = true;
      sequelizeQuery.raw = false;
      await execHook(modelName, 'beforeApiDelete', { request: req, sequelizeQuery });
      const result = {
      body: await repository
        .destroy(sequelizeQuery)
      };
      result.body = result.body.get();
      await execHook(modelName, 'afterApiDelete', result, { request: req, response: resp });

      return resp.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }

  /*
  export(req, resp) {
    let repository;
    const schema = axel.models[modelName] && axel.models[modelName].schema;
    let data = [];

    const url = `${modelName}_export`;
    const options = {};
    const query = {};

    Promise.resolve()
      .then(() => {
        repository = Utils.getEntityManager(req, resp);
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

    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      throw new ExtendedError({ code: 400, message: 'error_model_not_found_for_this_url' });
    }

    let data = [];

    const url = `${modelName}_import_template`;
    const options = { targetFolder: path.resolve(process.cwd(), 'public/data/' + modelName) };

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
    const repository = Utils.getEntityManager(req, resp);
    if (!repository) {
      return;
    }

    const properData = [];
    const improperData = [];
    let doc;
     DocumentManager.httpUpload(req, resp, {
      path: 'public/uploads/excel'
    })
      // @ts-ignore
      .then((document) => {
        console.log('doc', document);
        if (!document && !req.file) {
          throw new ExtendedError({
            code: 404,
            message: 'no_file_uploaded',
            errors: ['no_file_uploaded']
          });
        }
        let doc;
        if (document && document.length > 0 && document[0].fd) {
          doc = document[0].fd;
        }
        else if (req.file) {
          doc = req.file.path;
        }
        return ExcelService.parse(doc, {
          columns: {},
          eager: false
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
      .then(() => DocumentManager.delete(doc))
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

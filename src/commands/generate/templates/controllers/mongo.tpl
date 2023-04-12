/**
 * Api/<%= entityClass %>
 *
 * @description :: Server-side logic for managing all endpoints for <%= entityClass %>
 */

module.exports = {
  stats(req, resp) {
    const output = {};
    const endpoint = '<%= entity %>';
    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item

    const currentDate = new Date();
    const now = Date.now();
    const oneDay = (1000 * 60 * 60 * 24);
    const today = new Date(now - (now % oneDay));
    const tomorrow = new Date(today.valueOf() + oneDay);
    const monthStartDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
    const weekStartDay = new Date(currentDate.setDate(currentDate.getDate()
                                                    - currentDate.getDay()));

    if (!collection) {
      throw new ExtendedError({
        code: 404,
        errors: [{
          message: 'not_found',
          stack: 'not_found',
        }],
        message: 'not_found'
      });
    }

    collection
      .count()
      .then((data) => {
        // TOTAL
        output.total = data;

        // THIS MONTH
        return collection.count({
          createdOn: {
            $gte: monthStartDay,
            $lt: tomorrow
          }
        });
      })
      .then((data) => {
        output.month = data;

        // THIS WEEK
        return collection.count({
          createdOn: {
            $gte: weekStartDay,
            $lt: tomorrow
          }
        });
      })
      .then((data) => {
        output.week = data;

        // TODAY
        return collection.count({
          createdOn: {
            $gte: today,
            $lt: tomorrow
          }
        });
      })
      .then((data) => {
        output.today = data;

        resp.status(200).json({
          body: output
        });
      })
      .catch((err) => {
        console.warn(err);
        Tools.errorCallback(err, resp);
      });
  },

  list(req, resp) {
    const endpoint = '<%= entity %>';
    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item
    let query = {};
    const listOfValues = req.query.listOfValues ? req.query.listOfValues : false;
    const startPage = parseInt(req.query.page ? req.query.page : 0);
    const limit = Tools.getPagination(req);
    const skip = startPage * limit;

    let output = [];
    let options = {
      limit,
      skip
    };
    if (req.query) {
      if (req.query.search) {
        collection.createIndex({
          '$**': 'text'
        }, {
          default_language: 'en',
          language_override: 'en'
        });
        query.$text = {
          $search: req.query.search,
          $language: 'en'
        };
      }

      query = Tools.injectQueryParams(req, query);
      options = Tools.injectMongoSortParams(req, options);
    }

    collection
      .find(query, options)
      .then((data) => {
        if (data && data.length) {
          output = data;
          if (listOfValues) {
            output = output.map(item => ({
              _id: item._id.toString(),
              label: item.title || item.name || item.label,
              metadata: item.metadata
            }));
          }
          return collection.count(query);
        }
        return 0;
      })
      .then((totalCount) => {
        resp.status(200).json({
          body: output,
          page: startPage,
          perPage: limit,
          totalCount
        });
      })
      .catch((err) => {
        Tools.errorCallback(err, resp);
      });
  },

  get(req, resp) {
    const endpoint = '<%= entity %>';
    const id = req.params.id;
    if (!Tools.checkIsMongoId(id, resp)) {
      return false;
    }
    const listOfValues = req.query.listOfValues ? req.query.listOfValues : false;
    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item
    collection
      .findOne({
        _id: sails.mongodb.id(id)
      })
      .then((doc) => {
        if (doc) {
          if (listOfValues) {
            return resp.status(200).json({
              body: {
                _id: doc._id.toString(),
                label: doc.title || doc.name || doc.label,
                metadata: doc.metadata
              }
            });
          }
          resp.status(200).json({
            body: doc
          });
        } else {
          throw new ExtendedError({
            code: 404,
            errors: [{
              message: 'not_found',
              stack: 'not_found'
            }],
            message: 'not_found'
          });
        }
      })
      .catch((err) => {
        Tools.errorCallback(err, resp);
      });
  },

  /**
  * [put description]
  * [description]
  * @method
  * @param  {[type]} req  [description]
  * @param  {[type]} resp [description]
  * @return {[type]}      [description]
  */
  post(req, resp) {
    const endpoint = '<%= entity %>';
    const data = Tools.injectUserId(req.body, req.token);
    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item

    // prevent inject of ids in the create form to steal other peoples entities
    delete data._id;
    collection
      .insert(data)
      .then(() => {
        resp.status(200).json({
          body: data
        });
        const userId = req.token ? req.token._id : 'ANONYMOUS';

        /* eslint-disable prefer-template */
        EventManager.bus.publish(endpoint.toUpperCase() + '_CREATED', {
          userId,
          data,
          entity: endpoint,
          entityId: data._id
        });
        /* eslint-enable prefer-template */

        ActivityLog.log(null, data, {
          userId,
          entityId: data._id,
          entity: endpoint
        });
      })
      .catch((err) => {
        Tools.errorCallback(err, resp);
      });
  },

  /**
   * [put description]
   * [description]
   * @method
   * @param  {[type]} req  [description]
   * @param  {[type]} resp [description]
   * @return {[type]}      [description]
   */
  put(req, resp) {
    const endpoint = '<%= entity %>';
    const id = req.params.id;
    let original;
    let updatee;
    if (!Tools.checkIsMongoId(id, resp)) {
      return false;
    }

    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item

    collection
      .findOne({
        _id: id
      })
      .catch((err) => {
        console.warn(err);
        throw new ExtendedError({
          code: 404,
          errors: [{
            message: err.message || 'not_found',
            stack: err.stack || 'not_found',
          }],
          message: err.message || 'not_found'
        });
      })
      .then((o) => {
        original = o;
        if (original) {
          updatee = _.merge(req.body, {
            metadata: original.metadata
          });
          updatee._id = id;
          return collection.update({
            _id: id
          }, updatee);
        }
      })
      .catch((err) => {
        console.warn(err);
        throw new ExtendedError({
          code: err && err.code < 504 ? err.code : 500,
          errors: err.errors || [{
            message: err.message,
            stack: err.stack
          }],
          message: err.message || 'updating_error'
        });
      })
      .then(() => {
        resp.status(200).json({
          body: updatee
        });
        const userId = req.token ? req.token._id : 'ANONYMOUS';
        /* eslint-disable prefer-template */
        EventManager.bus.publish(endpoint.toUpperCase() + '_MODIFIED', {
          userId,
          data: updatee,
          entity: endpoint,
          entityId: id
        });
        /* eslint-enable prefer-template */
        ActivityLog.log(original, updatee, {
          userId,
          entityId: id,
          entity: endpoint
        });
      })
      .catch((err) => {
        Tools.errorCallback(err, resp);
      });
  },

  /**
   * @param  {[type]}
   * @param  {[type]}
   * @return {[type]}
   */
  patch(req, resp) {
    const endpoint = '<%= entity %>';
    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item

    collection
      .findOne({
        _id: req.params.id
      })
      .then((o) => {
        if (o) {
          const original = o;
          const data = _.merge({}, original, req.body, {
            lastModifiedOn: new Date()
          });

          collection
            .update({
              _id: data._id
            }, data)
            .then(() => {
              resp.status(200).json({
                body: data
              });

              const userId = req.token ? req.token._id : 'ANONYMOUS';
              /* eslint-disable prefer-template */
              EventManager.bus.publish(endpoint.toUpperCase() + '_MODIFIED', {
                userId,
                data,
                entity: endpoint,
                entityId: data._id
              });
              /* eslint-enable prefer-template */
              ActivityLog.log(original, data, {
                userId,
                entityId: req.params.id,
                entity: endpoint
              });
            })
            .catch((err) => {
              console.warn(err);
            });
        } else {
          throw new ExtendedError({
            code: 404,
            errors: [{
              message: 'not_found',
              stack: 'not_found',
            }],
            message: 'not_found'
          });
        }
      })
      .catch((err) => {
        Tools.errorCallback(err, resp);
      });
  },

  /**
   * [description]
   * @method
   * @param  {[type]} req  [description]
   * @param  {[type]} resp [description]
   * @return {[type]}      [description]
   */
  delete(req, resp) {
    const endpoint = '<%= entity %>';

    const id = req.params.id;
    if (!Tools.checkIsMongoId(id, resp)) {
      return false;
    }
    const collection = sails.mongodb.get(endpoint);
    // const collection = sails.models[endpoint].em; // if you have a schema defined for this item

    collection
      .remove({
        _id: id
      })
      .then((data) => {
        resp.status(200).json({
          status: 'OK'
        });
      })
      .catch((err) => {
        Tools.errorCallback(err, resp);
      });
  }
};
/* eslint no-unused-vars: ["error", { "args": "none" }] */
/**
*'<%= identity %>'  hooks. See https://sequelize.org/master/manual/hooks.html
* for more infos.
* LIst of hooks can be found here https://github.com/sequelize/sequelize/blob/v6/lib/hooks.js#L7
* Be sure sure to set the hooks for both individual and bulkUpdates
*/
// before
module.exports.beforeCreate = (<%= identity %>, options) => { return true; }
module.exports.beforeDestroy = (<%= identity %>, options) => {  return true; }
module.exports.beforeUpdate = (<%= identity %>, options) => { return true; }
module.exports.beforeSave = (<%= identity %>, options) => { return true; }
module.exports.beforeUpsert = (values, options) => { return true; }

module.exports.beforeBulkCreate = (<%= identity %>s, options) => { return true; }
module.exports.beforeBulkDestroy = (options) => { return true; }
module.exports.beforeBulkUpdate = (options) => { return true; }

module.exports.beforeFind = (<%= identity %>s, options) => { return true; }

// After
module.exports.afterCreate = (<%= identity %>, options) => { return true; }
module.exports.afterDestroy = (<%= identity %>, options) => { return true; }
module.exports.afterUpdate = (<%= identity %>, options) => { return true; }
module.exports.afterSave = (<%= identity %>, options) => { return true; }
module.exports.afterUpsert = (created, options) => { return true; }

module.exports.afterBulkCreate = (<%= identity %>s, options) => { return true; }
module.exports.afterBulkDestroy = (options) => { return true; }
module.exports.afterBulkUpdate = (options) => { return true; }

module.exports.afterFind = (<%= identity %>s, options) => { return true; }


// API middlewares
// context is an alias for context
// const {request : ExpressRequest, sequelizeQuery: SequelizeRequest } = context;
// api middlewares must return a promise or throw an error.
module.exports.beforeApiFind    = (context) => { return true; }
module.exports.beforeApiFindOne = (context) => { return true; }
module.exports.beforeApiCreate  = (context) => { return true; }
module.exports.beforeApiUpdate  = (context) => { return true; }
module.exports.beforeApiDelete  = (context) => { return true; }

/**
* result the body of the response sent to the client
* context  = {request: Express Request, response: Express Response}
*/
module.exports.afterApiFind    = (result, context) => { return true; }
module.exports.afterApiFindOne = (result, context) => { return true; }
module.exports.afterApiCreate  = (result, context) => { return true; }
module.exports.afterApiUpdate  = (result, context) => { return true; }
module.exports.afterApiDelete  = (result, context) => { return true; }
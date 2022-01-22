/* eslint no-unused-vars: ["error", { "args": "none" }] */
/**
*'cool'  hooks. See https://sequelize.org/master/manual/hooks.html
* for more infos.
* LIst of hooks can be found here https://github.com/sequelize/sequelize/blob/v6/lib/hooks.js#L7
* Be sure sure to set the hooks for both individual and bulkUpdates
*/
// before
module.exports.beforeCreate = (cool, options) => {}
module.exports.beforeDestroy = (cool, options) => {}
module.exports.beforeUpdate = (cool, options) => {}
module.exports.beforeSave = (cool, options) => {}
module.exports.beforeUpsert = (values, options) => {}

module.exports.beforeBulkCreate = (cools, options) => {}
module.exports.beforeBulkDestroy = (options) => {}
module.exports.beforeBulkUpdate = (options) => {}

module.exports.beforeFind = (cools, options) => {}

// After
module.exports.afterCreate = (cool, options) => {}
module.exports.afterDestroy = (cool, options) => {}
module.exports.afterUpdate = (cool, options) => {}
module.exports.afterSave = (cool, options) => {}
module.exports.afterUpsert = (created, options) => {}

module.exports.afterBulkCreate = (cools, options) => {}
module.exports.afterBulkDestroy = (options) => {}
module.exports.afterBulkUpdate = (options) => {}

module.exports.afterFind = (cools, options) => {}


// API middlewares
// ctx is an alias for context
// const {request : ExpressRequest, sequelizeQuery: SequelizeRequest } = ctx;
// api middlewares must return a promise or throw an error.
module.exports.beforeApiFind = async (ctx) => {}
module.exports.beforeApiFindOne = async (ctx) => {}
module.exports.beforeApiCreate = async (ctx) => {}
module.exports.beforeApiUpdate = async (ctx) => {}
module.exports.beforeApiDelete = async (ctx) => {}

module.exports.afterApiFind = async (result, ctx) => {}
module.exports.afterApiFindOne = async (result, ctx) => {}
module.exports.afterApiCreate = async (result, ctx) => {}
module.exports.afterApiUpdate = async (result, ctx) => {}
module.exports.afterApiDelete = async (result, ctx) => {}
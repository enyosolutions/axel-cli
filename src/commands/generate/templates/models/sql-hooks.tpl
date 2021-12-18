/* eslint no-unused-vars: ["error", { "args": "none" }] */
/**
*'<%= identity %>'  hooks. See https://sequelize.org/master/manual/hooks.html
* for more infos.
* Be sure sure to set the hooks for both individual and bulkUpdates
*/
// before
module.exports.beforeCreate = (<%= identity %>, options) => {}
module.exports.beforeDestroy = (<%= identity %>, options) => {}
module.exports.beforeUpdate = (<%= identity %>, options) => {}
module.exports.beforeSave = (<%= identity %>, options) => {}
module.exports.beforeUpsert = (values, options) => {}

module.exports.beforeBulkCreate = (<%= identity %>s, options) => {}
module.exports.beforeBulkDestroy = (options) => {}
module.exports.beforeBulkUpdate = (options) => {}


// After
module.exports.afterCreate = (<%= identity %>, options) => {}
module.exports.afterDestroy = (<%= identity %>, options) => {}
module.exports.afterUpdate = (<%= identity %>, options) => {}
module.exports.afterSave = (<%= identity %>, options) => {}
module.exports.afterUpsert = (created, options) => {}

module.exports.afterBulkCreate = (<%= identity %>s, options) => {}
module.exports.afterBulkDestroy = (options) => {}
module.exports.afterBulkUpdate = (options) => {}
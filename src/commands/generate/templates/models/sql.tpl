/* eslint no-unused-vars: ["error", { "args": "none" }] */
/**
 * <%= filename %>
 *
 * @description :: This is model file that connects with sequelize.
 *                 TODO: You might write a short summary of
 *                 how this model works and what it represents here.
 */

// const sequelize = require('sequelize');
// const { DataTypes } = sequelize; // Not needed as axel-core automatically resolves the type from te string name

/*
  // event hooks => http://docs.sequelizejs.com/manual/tutorial/hooks.html
  const eventCallback = () => { // items, options
    // do something like stringifying data...
  };
*/

const <%= entityClass %> = {
  identity: '<%= identity %>',
  entity: {
    attributes: {
      <% if (!fields || fields.length === 0) {%>
      id: {
        type: "INTEGER",
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      <% } %>
      <% for (var i = 0; i < fields.length; i++) { %>
      <%= fields[i].name || fields[i] %>: {
        <% if (fields[i].primaryKey) { %>
        primaryKey: true,
        <% } %>
        <% if (fields[i].autoIncrement) { %>
        autoIncrement: true,
        <% } %>
        allowNull: <%= !fields[i].required %>,
        type: "<%= fields[i].type || 'DataTypes.STRING' %>",
      },<% } %>
    },
    options: {
      // disable the modification of tablenames; By default, sequelize will automatically
      // transform all passed model names (first parameter of define) into plural.
      // if you don't want that, set the following
      freezeTableName: true,
      // Table Name
      tableName: '<%= tableName %>',
      // Enable TimeStamp
      timestamps: true,
      // createdAt should be createdOn
      createdAt: 'createdOn',
      // updatedAt should be lastModifiedOn
      updatedAt: 'lastModifiedOn',
      // Hooks. see => http://docs.sequelizejs.com/manual/tutorial/hooks.html
      hooks: {
        // beforeSave: eventCallback,
        // beforeValidate: eventCallback,
        // afterFind: eventCallback,
        // beforeBulkCreate: eventCallback,
        // beforeBulkUpdate: eventCallback,
      },
      indexes: [
      // {
      //  unique: false,
      //  fields: ['userId'],
      // },
      ]
    },
    // Create relations
    // @ts-ignore
    associations: (models) => {
      //  models.user.hasMany(models.<%= identity %>, {
      //   foreignKey: 'createdBy',
      //   targetKey: 'id'
      // });
    },
    // define default join
    // @ts-ignore
    defaultScope: (models) => ({

    }),
  }
};


module.exports = <%= entityClass %>;
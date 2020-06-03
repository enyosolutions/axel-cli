module.exports = {
  identity: '<%= identity %>',
  collectionName: '<%= identity %>',
  url: '/<%= entity %>', // url for front api
  additionalProperties: false,
  autoValidate: true,
  schema: {
    $id: 'http://acme.com/schemas/<%= entity %>.json',
    type: 'object',
    properties: {
      id: {
        $id: 'id',
        <% if (isSql) { %>type: 'number',<% } else { %>type: ['object', 'string'],<% } %>
        title: '<%= entityClass %> id', // serves for front form fields
        description: 'The id of this item' // serves for front form hint
      },<% for (var i = 0; i < fields.length; i++) { %>
      <%=fields[i] %>: {
        type: 'string',
      },<% } %>
      createdOn: {
        type: ['string', 'object'],
        format: 'date-time',
        edit: { readonly: true },
        display: {
          type: 'datetime'
        }
      },
      lastModifiedOn: {
        type: ['string', 'object'],
        format: 'date-time',
        edit: { readonly: true },
        display: {
          type: 'datetime'
        }
      },
      createdBy: {
        type: ['string'],
        relation: '/user',
        foreignKey: '_id',
        display: {},
        edit: { readonly: true },
      },
      lastModifiedBy: {
        type: ['string'],
        relation: '/user',
        foreignKey: '_id',
        display: {},
        edit: { readonly: true },
      }
    },
    required: []
  }
};

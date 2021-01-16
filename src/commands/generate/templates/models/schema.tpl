module.exports = {
  identity: '<%= identity %>',
  collectionName: '<%= identity %>',
  apiUrl: '/<%= entity %>', // url for front api
  additionalProperties: false,
  automaticApi: false,
  primaryKeyField: null,
  displayField: null,
  autoValidate: true,
  schema: {
    $id: 'http://acme.com/schemas/<%= entity %>.json',
    type: 'object',
    properties: {
      <% if (!fields || fields.length === 0) {%>
      id: {
        $id: 'id',
        <% if (isSql) { %>type: 'number',<% } else { %>type: ['object', 'string'],<% } %>
        title: '<%= entityClass %> id', // serves for front form fields
        description: 'The id of this item' // serves for front form hint
      },
      <% } %>
      <% for (var i = 0; i < fields.length; i++) { %>
      <%= fields[i].name || fields[i] %>: {
        title: '<%= _.startCase(fields[i].name || fields[i]) %>',
        description: 'The <%= _.startCase(fields[i].name || fields[i]) %> of the <%= identity %>',
        type: '<%= fields[i].type || 'string' %>',
      },<% } %>
      createdOn: {
        type: ['string', 'object'],
        format: 'date-time',
        field: { readonly: true },
        column: {
          type: 'datetime'
        }
      },
      lastModifiedOn: {
        type: ['string', 'object'],
        format: 'date-time',
        field: { readonly: true },
        column: {
          type: 'datetime'
        }
      },
      createdBy: {
        type: ['string'],
        relation: '/user',
        relationKey: '_id',
        column: {},
        field: { readonly: true },
      },
      lastModifiedBy: {
        type: ['string'],
        relation: '/user',
        relationKey: '_id',
        column: {},
        field: { readonly: true },
      }
    },
    required: [
       <% for (var i = 0; i < fields.length; i++) {
        if (fields[i].required) { %>
          '<%= fields[i].name %>',
       <% }
        } %>
    ]
  },
  admin: {
      name: null,
      namePlural: null,
      pageTitle: null,
      routerPath: null,
      options:  null,
      actions: null,
      formOptions:  null,
      listOptions:  null,
      kanbanOptions:  null,
      tableOptions:  null,
  }
};

module.exports = {
  identity: '<%= identity %>',
  collectionName: '<%= identity %>',
  apiUrl: '/api/<%= entity %>', // url for front api
  additionalProperties: false,
  automaticApi: <%= automaticApi %>,
  primaryKeyField: 'id',
  displayField: null,
  searchableFields: null, // array of fields
  includeInServedModels: true,
  autoValidate: <%= jsonSchemaValidation %>,
  schema: {
    $id: 'http://acme.com/schemas/<%= entity %>.json',
    type: 'object',
    properties: {
      <% if (!fields || fields.length === 0) {%>
      id: {
        $id: 'id',
        <% if (isSql) { %>type: 'number',<% } else { %>type: ['object', 'string'],<% } %>
        title: '<%= entityClass %> id', // serves for front form fields
        description: 'The id of this item', // serves for front form hint
        field: {
          readonly: true,
          visible: '{{ context.mode === "create"}}'
        },
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
        relation: 'user',
        relationKey: 'id',
        column: {},
        field: { readonly: true, disabled: true },
      },
      lastModifiedBy: {
        type: ['string'],
        relation: 'user',
        relationKey: 'id',
        column: {},
        field: { readonly: true, disabled: true },
      }
    },
    required: [
       <% for (var i = 0; i < fields.length; i++) {
        if (fields[i].required) { %>
          '<%= fields[i].name %>',
       <% }
        } %>
        } %>
    ]
  },
  admin: {
      name: null,
      namePlural: null,
      pageTitle: null,
      tabTitle: null,
      routerPath: null,
      menuIsVisible: true,
      tabIsVisible: true,
      detailPageMode: 'page',
      tableRowClickAction: 'view',
      tableRowDoubleClickAction: 'none',
      tableDataLimit: 20,
      segmentField: '',
      postCreateDisplayMode: 'view',
      enabledListingModes: ['table', 'kanban', 'list'],
      customInlineActions: [],
      customTopActions: [],
      customTabletopActions: [],
      options: {
        apiUrl: '/api/<%= entity %>',
        dataPaginationMode: 'remote', // remote | local
        createPath: '',
        viewPath: '',
        editPath: '',
        stats: false,
        initialDisplayMode: 'table',
        modalMode: '',
        columnsDisplayed: 10
      },
      actions: {
        create: true,
        edit: true,
        view: true,
        delete: true, // if you are using VaC then you can set this to '{{ userHasRole("ADMIN") || currentItem.createdBy == $state.user.user.id }}'
        search: true,
        filter: true,
        export: true,
        import: true,
        dateFilter: false,
        refresh: true,
        advancedFiltering: true,
        changeDisplayMode: true,
        pagination: true,
        collapse: true,
        formPagination: true,
        noActions: false,
        automaticRefresh: false,
        columnsFilters: true,
        bulkDelete: true,
        bulkEdit: true,
        changeItemsPerRow: true,
        editLayout: true,
        addKanbanList: true
      },
      formOptions: {
        layout: []
      },
      listOptions: {
        titleField: '{{ firstName }} {{ lastName }}',
        subtitleField: 'currentPosition',
        labelsField: 'currentCompany',
        descriptionField: 'description',
        itemComponent: null
      },
      kanbanOptions: {},
      tableOptions: {},
  }
};

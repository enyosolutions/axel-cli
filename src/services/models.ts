import * as path from 'path'
import * as fs from 'fs-extra'
import * as _ from 'lodash'
import * as replace from 'replace'

const typeMap = {
  INTEGER: 'integer',
  'INTEGER(11)': 'integer',
  BIGINT: 'integer',
  FLOAT: 'number',
  DOUBLE: 'number',
  BOOLEAN: 'boolean',
  TINYINT: 'boolean',
  VARCHAR: 'string',
  'VARCHAR(255)': 'string',
  CHAR: 'string',
  TIME: 'string',
  STRING: 'string',
  TEXT: 'string',

  JSON: 'object',
  JSONB: 'object',

  ARRAY: 'array',
  ENUM: 'string',
  DATE: 'string',
  DATETIME: 'string',
  DATEONLY: 'string',
}

export const migrateSequelizeModels = async (
  file: string,
  options: any = {}
) => {
  await replace({
    regex: /import.+from '.\/db';\n/,
    replacement: '',
    paths: [file],
    recursive: true,
    silent: true,
  })

  await replace({
    regex: 'module.exports = function.+\n.+\\(',
    replacement: `
module.exports = {\n\tidentity:`,
    paths: [file],
    recursive: true,
    silent: true,
  })

  await replace({
    regex: /identity:(.+), {/,
    replacement: '\n\tidentity: $1,\n\tentity: {\n\t\tattributes:{\n\t\t',
    paths: [file],
    recursive: true,
    silent: true,
  })

  await replace({
    regex: /}\);/,
    replacement: `}
                }
                `,
    paths: [file],
    recursive: true,
    silent: true,
  })

  await replace({
    regex: /DataTypes.INTEGER\(1\)/g,
    replacement: 'DataTypes.BOOLEAN',
    paths: [file],
    recursive: true,
    silent: true,
  })

  await replace({
    regex: /DataTypes.INTEGER\(.+\)/g,
    replacement: 'DataTypes.INTEGER',
    paths: [file],
    recursive: true,
    silent: true,
  })

  await replace({
    regex: /}, {/,
    replacement: `
      },
      associations: (models: {[key: string]: any}) => {
        // models.address.belongsTo(models.user, {
        //     foreignKey: 'userId',
        //     targetKey: 'id',
        // });
      },
      options: {
    `,
    paths: [file],
    recursive: true,
    silent: true,
  })

  //   replace({
  //     regex: 'tableName',
  //     replacement: `
  //       freezeTableName: true,
  //       timestamps: true,
  //       createdAt: 'createdOn',
  //       updatedAt: 'lastModifiedOn',
  //       tableName`,
  //     paths: [file],
  //     recursive: true,
  //     silent: options.silent,
  //   });

  // replace({
  //   regex: "DataTypes",
  //   replacement: `Sequelize`,
  //   paths: [file],
  //   recursive: true,
  //   silent: false,
  // });
}

export function generateSchemaFromModel(
  file: string,
  target: string,
  options: any = {}
) {
  if (file.endsWith('.js') || file.endsWith('.ts')) {
    const model = require(file)

    if (!model.entity) {
      console.log(file, model)
      throw new Error('missing_tablename_' + file)
    }
    const tableName = model.entity.options.tableName
    if (!tableName) {
      throw new Error('missing_tablename_' + tableName)
    }
    const destination: { [key: string]: any } = {
      identity: tableName,
      url: '/' + tableName,
      additionalProperties: false,
      autoValidate: true,
      schema: {
        $id: `http://acme.com/schemas/${tableName}.json`,
        type: 'object',
        properties: {},
        required: [],
      },
    }

    for (const key in model.entity.attributes) {
      const field = model.entity.attributes[key]
      let type = field.type.toString()
      type = type.replace(/\(\d+\)/, '')
      // @ts-ignore
      if (!typeMap[type]) {
        console.log('field.type', field.type, type)
        throw new Error('unkown_type_' + type)
      }
      const schema: any = {
        // @ts-ignore
        type: typeMap[type],
        column: {},
        field: {},
      }

      if (!field.allowNull && key !== 'id') {
        destination.schema.required.push(key)
        if (!field.defaultValue) {
          schema.field.required = true
        }
      }
      if (field.defaultValue) {
        schema.default = field.defaultValue
      }

      switch (type) {
      case 'VARCHAR':
        schema.enum = field.type.values
        break
      case 'ENUM':
        schema.enum = field.type.values
        break
      case 'TEXT':
        schema.field.type = 'textArea'
        break
      case 'DATE':
        schema.field.format = 'date-time'
        schema.column.type = 'datetime'
        schema.field.type = 'dateTime'
        break
      case 'DATEONLY':
        schema.field.format = 'date-time'
        schema.column.type = 'datetime'
        schema.field.type = 'dateTime'
        schema.field.fieldOptions = {
          type: 'date',
        }
        break
      case 'TIME':
        schema.field.format = 'date-time'
        schema.field.type = 'dateTime'
        schema.field.fieldOptions = {
          type: 'time',
        }
        break
      case 'INTEGER':
        if (field.type.options) {
          schema.maxLength = field.type.options.length
        }

      case 'BOOLEAN':
        break
      }

      destination.schema.properties[key] = schema
    }
    if (
      model.entity &&
      model.entity.options &&
      model.entity.options.timestamps
    ) {
      ['createdOn', 'lastModifiedOn'].forEach((field: string) => {
        if (!destination.schema.properties[field]) {
          destination.schema.properties[field] = {
            type: 'string',
            column: {
              type: 'datetime',
            },
            field: {
              format: 'date-time',
              type: 'dateTime',
              readonly: true,
            },
          }
        }
      })
    }

    try {
      fs.writeFileSync(
        target,
        `module.exports = ${JSON.stringify(destination, null, 2)}`,
        {flag: options.force ? 'w' : 'wx'}
      )
    } catch (e) {
      console.log('[MIGRATON]', `${tableName}.ts`, e.message)
    }
  }
}

if (options.schemas) {
  generateSchemaFromModel(file, file.replace('sequelize', 'schema'), options)
}

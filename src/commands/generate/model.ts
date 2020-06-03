import {flags} from '@oclif/command'
import Command from '../../base'
import {
  renderTemplate,
  parseCommaInputs,
  promptFields,
} from '../../services/utils'
import * as _ from 'lodash'
import * as fs from 'fs'
import * as chalk from 'chalk'
import {generateSchemaFromModel} from '../../services/models'

const modelsLocation = `${process.cwd()}/src/api/models/sequelize`
const schemasLocation = `${process.cwd()}/src/api/models/schema`

export default class Generate extends Command {
                 static description = 'Generate a model for your axel project';

                 static target = 'model';

                 static args = [{name: 'name', required: true}];

                 static flags = {
                   ...Command.flags,
                   help: flags.help({char: 'h'}),
                   interactive: flags.boolean({char: 'i', required: false}),
                   // flag with a value (-n, --name=VALUE)
                   types: flags.string({
                     char: 't',
                     description: 'type of project',
                     options: ['sql', 'schema', 'all'],
                     required: true,
                     multiple: true,
                   }),
                   fields: flags.string({
                     description: 'List of fields to declare',
                     required: false,
                     multiple: true,
                   }),
                   'from-sequelize': flags.boolean({
                     description:
                       'Generate the schema from the sequelize model',
                     required: false,
                   }),
                   // flag with no value (-f, --force)
                   force: flags.boolean({char: 'f'}),
                 };

                 async run() {
                   const {args, flags} = this.parse(Generate)

                   let types: string[] = []
                   if (flags.types) {
                     types = parseCommaInputs(flags.types)
                   }
                   if (types.indexOf('all') > -1) {
                     types = ['sql', 'schema']
                   }
                   let fields = parseCommaInputs(flags.fields || [])

                   if (flags.interactive) {
                     this.log(
                       'Type in the field name that you need in your model, one field at a time.'
                     )
                     this.log('When you are done just press enter.')
                     fields = await promptFields()
                   }

                   const name = args.name.trim()

                   const entityClass = _.trim(_.startCase(name)).replace(
                     / /g,
                     ''
                   )
                   const entity = _.kebabCase(name)
                   const entityKebabCased = _.kebabCase(name)
                   const entityCamelCased = _.camelCase(name)
                   const filename = entityClass
                   const format: 'camelCase' | 'kebabCase' | 'snakeCase' =
                     this.projectConfig &&
                     this.projectConfig.modelIdentityFormat
                   if (!format || !_[format]) {
                     this.error(
                       'Unsupported value in project config [modelIdentityFormat]'
                     )
                     return
                   }
                   const identity: any = _[format](entity)

                   for (const type of types) {
                     const filePath = `./src/api/models/${
                       type === 'sql' ? 'sequelize' : type
                     }/${entityClass}.ts`

                     if (fs.existsSync(filePath) && !flags.force) {
                       this.warn(
                         `File ${filePath} already exists. Use --force to overwrite.`
                       )
                       return
                     }
                     if (type === 'schema' && flags['from-sequelize']) {
                       generateSchemaFromModel(
                         modelsLocation + '/' + filename + '.ts',
                         schemasLocation + '/' + filename + '.ts',
                         {force: flags.force}
                       )

                       return
                     }
                     renderTemplate(
                       `${__dirname}/templates/models/${type}.tpl`,
                       filePath,
                       {
                         ...this.projectConfig,
                         type,
                         identity,
                         entity,
                         tableName: identity,
                         entityClass,
                         entityKebabCased,
                         entityCamelCased,
                         filename,
                         fields,
                         isSql: types.indexOf('sql') > -1,
                       }
                     )
                   }
                   const message = `✔️ Generated model ${args.name}\n`
                   this.log(chalk.green(message))
                 }
}

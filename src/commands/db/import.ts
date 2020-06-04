import Command from '../../base'
import {flags} from '@oclif/command'
import * as _ from 'lodash'
import * as path from 'path'
import * as fs from 'fs-extra'
import * as SequelizeAuto from 'sequelize-auto'
import {migrateSequelizeModels} from '../../services/models'

const modelsLocation = `${process.cwd()}/src/api/models/sequelize`

export default class Import extends Command {
  static description =
    'Generate sequelize models and json schemas from database';

  static flags = {
    ...Command.flags,
    help: flags.help({char: 'h'}),
    force: flags.boolean({
      char: 'f',
      description:
        'Overwrite models if present before recreating them (Do not use in production...)',
    }),
    schemas: flags.boolean({
      char: 's',
      description: 'Also generate schemas',
      required: false,
    }),
    tables: flags.string({
      char: 't',
      default: '',
      multiple: true,
      description: 'list of tables to import',
    }),
  };

  async run() {
    const {flags} = this.parse(Import)
    const force = flags.force
    const schemas = flags.schemas
    const tables = flags.tables
    // if (force && !silent) {
    //   const confirm = await cli.confirm(
    //     'Are you sure you want to overwrite tables ? (this operation is irreversible...)'
    //   );
    //   if (!confirm) {
    //     this.log('Aborting operation');
    //     return;
    //   }
    // }
    import(
      path.resolve(process.cwd(), 'src/resources/sequelize/config/config')
    ).then(config => {
      const env = process.env.NODE_ENV || 'development'
      const auto = new SequelizeAuto(
        config[env].database,
        config[env].username,
        config[env].password,
        {
          host: config[env].host,
          dialect: config[env].dialect,
          directory: modelsLocation, // prevents the program from writing to disk
          port: config[env].port,
          typescript: true,
          additional: {
            timestamps: true,
            freezeTableName: true,
            createdAt: 'createdOn',
            updatedAt: 'lastModifiedOn',
            // ...
          },
          tables: flags.tables,
          // ...
        }
      )

      auto.run((err: Error) => {
        if (err) {
          this.error(err.message)
          return
        }

        const format: 'camelCase' | 'kebabCase' | 'snakeCase' =
          this.projectConfig && this.projectConfig.modelIdentityFormat
        if (!format || !_[format]) {
          this.log(format)
          this.error(
            'Unsupported value in project config [modelIdentityFormat]'
          )
          return
        }
        // console.log('auto', auto.foreignKeys)
        fs.moveSync(
          path.resolve(modelsLocation, 'db.d.ts'),
          path.resolve(process.cwd(), 'src/types/models.d.ts'),
          {overwrite: true}
        )
        fs.moveSync(
          path.resolve(modelsLocation, 'db.tables.ts'),
          path.resolve(process.cwd(), 'src/types/ModelsList.d.ts'),
          {overwrite: true}
        )
        Object.keys(auto.tables).forEach(table => {
          const filename = _.upperFirst(_.camelCase(table))
          this.log(filename, table)
          if (table !== filename) {
            fs.renameSync(
              path.resolve(modelsLocation, table + '.ts'),
              path.resolve(modelsLocation, filename + '.ts'),
            )
          }

          migrateSequelizeModels(
            path.resolve(
              process.cwd(),
              'src/api/models/sequelize',
              filename + '.ts'
            ),
            {
              force,
              schemas,
              tables,
              format,
              filename,
              tableName: table,
              entityClass: filename,
              identity: _[format](table),
            }
          )
        })

        // for each table run the migrator.
        // if schema is true
      })
    })
  }
}

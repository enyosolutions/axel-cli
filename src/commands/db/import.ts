/* eslint-disable arrow-parens */
import Command from '../../base';
import { flags } from '@oclif/command';
import * as _ from 'lodash';
import * as path from 'path';
import * as fs from 'fs-extra';
// import * as SequelizeAuto from 'sequelize-auto'
const SequelizeAuto = require('sequelize-auto');
import { migrateSequelizeModels } from '../../services/models';
import { renderTemplate } from '../../services/utils';

const modelsLocation = `${process.cwd()}/src/api/models/sequelize`;

export default class Import extends Command {
  static description =
    'Generate sequelize models and json schemas from database';

  static flags = {
    ...Command.flags,
    help: flags.help({ char: 'h' }),
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
    const { flags } = this.parse(Import);
    const force = flags.force;
    const schemas = flags.schemas;
    const tables = flags.tables;

    // if (force && !silent) {
    //   const confirm = await cli.confirm(
    //     'Are you sure you want to overwrite tables ? (this operation is irreversible...)'
    //   );
    //   if (!confirm) {
    //     this.log('Aborting operation');
    //     return;
    //   }
    // }
    let file;
    const oldFolderExists = fs.existsSync(
      path.resolve(process.cwd(), 'resources/sequelize/config/config.js')
    );

    if (oldFolderExists) {
      file = path.resolve(
        process.cwd(),
        'resources/sequelize/config/config.js'
      );
    } else {
      file = path.resolve(
        process.cwd(),
        'src/resources/sequelize/config/config.js'
      );
    }
    import(path.resolve(process.cwd(), file)).then((config) => {
      const env = process.env.NODE_ENV || 'development';
      const auto = new SequelizeAuto(
        config[env].database,
        config[env].username,
        config[env].password,
        {
          host: config[env].host,
          dialect: config[env].dialect,
          directory: modelsLocation, // prevents the program from writing to disk
          port: config[env].port,
          typescript: false,
          additional: {
            timestamps: true,
            freezeTableName: true,
            createdAt: 'createdOn',
            updatedAt: 'lastModifiedOn',
            // ...
          },
          tables: flags.tables,
          skipTables: [
            'axelModelFieldConfig',
            'axelModelConfig',
            'axel-model-field-config',
            'axel-model-config',
            'axelUser',
            'axel-user',
          ],
          // ...
        }
      );
      this.log('Starting import...');
      auto
        .run()
        .then((data: { tables: any; relations: any }) => {
          // console.log('Imported tables: ', data.relations);
          this.log('Generating models from database');
          const format: 'camelCase' | 'kebabCase' | 'snakeCase' =
            this.projectConfig && this.projectConfig.modelIdentityFormat;
          if (!format || !_[format]) {
            this.log(format);
            this.error(
              'Unsupported value in project config [modelIdentityFormat]'
            );
            return;
          }
          // auto foreign keys
          // console.log('auto', auto.foreignKeys)
          // fs.moveSync(
          //   path.resolve(modelsLocation, 'db.d.js'),
          //   path.resolve(process.cwd(), 'src/types/models.d.js'),
          //   {overwrite: true}
          // )
          // fs.moveSync(
          //   path.resolve(modelsLocation, 'db.tables.js'),
          //   path.resolve(process.cwd(), 'src/types/ModelsList.d.js'),
          //   {overwrite: true}
          // )

          fs.unlink(path.resolve(modelsLocation, 'init-models.js'));
          Object.keys(data.tables).forEach((table) => {
            if (table.includes('.') && config[env].dialect === 'postgres') {
              table = table.split('.').pop() || '';
            }
            if (!table) {
              return;
            }

            const filename = _.upperFirst(_.camelCase(table));
            this.log(filename, table);
            if (table !== filename) {
              this.log('Renaming table', table, 'to', filename);

              fs.renameSync(
                path.resolve(modelsLocation, table + '.js'),
                path.resolve(modelsLocation, filename + '.js')
              );
            }

            this.log('generate hook', table, modelsLocation);
            renderTemplate(
              `${__dirname}/../generate/templates/models/sql-hooks.tpl`,
              `${modelsLocation.replace('/sequelize', '/hooks')}/${_[format](
                table
              )}.js`,
              { identity: _[format](table) }
            );

            migrateSequelizeModels(
              path.resolve(
                process.cwd(),
                'src/api/models/sequelize',
                filename + '.js'
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
                automaticApi:
                  this.projectConfig && this.projectConfig.automaticApi,
                jsonSchemaValidation:
                  this.projectConfig && this.projectConfig.jsonSchemaValidation,
              }
            );
          });

          // for each table run the migrator.
          // if schema is true
        })
        .catch((err: Error) => {
          this.error(err.message);
        });
    });
  }
}

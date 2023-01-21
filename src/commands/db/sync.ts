import Command from '../../base';
import { flags } from '@oclif/command';
import * as path from 'path';
import * as fs from 'fs';
import * as _ from 'lodash';
import cli from 'cli-ux';

export default class Sync extends Command {
  static description = 'Sync sequelize models to the database';

  static flags = {
    help: flags.help({ char: 'h' }),
    alter: flags.boolean({
      char: 'a',
      default: false,
      description: 'Alter table columns if they already exist.',
    }),
    force: flags.boolean({
      char: 'f',
      description:
        'Drop tables before recreating them (Do not use in production...',
    }),
    silent: flags.boolean({
      char: 's',
      default: false,
      description: 'Do not ask for confirmation',
    }),
    tables: flags.string({
      char: 't',
      description: 'name of table to sync (ex: user)',
      multiple: true,
    }),
    match: flags.string({
      char: 'm',
      description: 'name of database to match (ex: _test)',
    }),
  };

  async run() {
    const { flags } = this.parse(Sync);

    let resource;
    const oldFolderExists = fs.existsSync(
      path.resolve(process.cwd(), 'resources/sequelize/models/index.js')
    );

    if (oldFolderExists) {
      resource = path.resolve(
        process.cwd(),
        'resources/sequelize/models/index.js'
      );
    } else {
      resource = path.resolve(
        process.cwd(),
        'src/resources/sequelize/models/index.js'
      );
    }
    this.log('Running db:sync based on models in ', resource);
    if (!fs.existsSync(resource)) {
      this.error(
        'models resources not found ! . Please make sure you compile your code before running axel'
      );
      return;
    }
    const alter = flags.alter;
    const force = flags.force;
    const silent = flags.silent;
    const tables = flags.tables || [];
    const match = flags.match ? new RegExp(flags.match, 'g') : undefined;
    cli.action.start('Sync database');

    if (force && !silent) {
      const confirm = await cli.confirm(
        'Are you sure you want to drop tables ? (this operation is irreversible...)'
      );
      if (!confirm) {
        this.log('Aborting operation');
        return;
      }
    }
    try {
      const db = await import(resource);
      const models = db.models || db.sequelize.models;
      if (!db.sequelize) {
        console.warn('db.sequelize', Object.keys(db));
        throw new Error('missing sequelize models');
      }
      Object.values(models).forEach((model: any) => {
        if (model.attributes) {
          Object.keys(model.attributes).forEach((idx) => {
            const attr = model.attributes[idx];
            // transform strng real sequelize values
            if (typeof attr.type === 'string') {
              const type = attr.type
                .replace('DataTypes.', '')
                .replace('sequelize.', '')
                .replace(/\(.+\)/, '');
              const args = attr.type.match(/\(.+\)/);
              const resolvedType = _.get(db.Sequelize.DataTypes, type);
              if (resolvedType) {
                attr.type = resolvedType;
                if (args && args[0]) {
                  attr.type = attr.type(
                    ...args[0]
                      .replace(/\(|\)/g, '')
                      .split(',')
                      .map((s: string) => s.replace(/["']/g, '').trim())
                  );
                }
              }
            }
          });
        }
      });
      if (tables.length > 0) {
        this.log('Syncing tables ', tables);
        const promises = Object.keys(models).filter((model) => {
            if (!tables.includes(model)) {
              this.log('skipping', model);
            }
            return tables.includes(model);
          })
          .map((model: any) => {
            this.log('Syncing table ', model);
            const m = models[model];

            return m.sync({ alter, force, match, log: true });
          });
        await Promise.all(promises);
      } else {
        await (db.default || db).sequelize.sync({
          alter,
          force,
          match,
        });
      }
      cli.action.stop('Sync completed');
      this.log('Sync completed');
      // eslint-disable-next-line unicorn/no-process-exit,no-process-exit
      setTimeout(() => process.exit(0), 3000);
    } catch (error) {
      this.error(error as Error);
    }
  }
}

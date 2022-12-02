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
    match: flags.string({
      char: 'm',
      description: 'name of table to match (ex: _test)',
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
    const match = flags.match ? new RegExp(flags.match, 'g') : undefined;

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
      Object.values(db.sequelize.models).forEach((model: any) => {
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
      await (db.default || db).sequelize.sync({ alter, force, match });
      // eslint-disable-next-line unicorn/no-process-exit
      return process.exit(0);
    } catch (error) {
      this.error(error as Error);
    }
  }
}

/* eslint-disable arrow-parens */
import Command from '../../base';
import { flags } from '@oclif/command';
// import * as _ from 'lodash';
import * as path from 'path';
import * as fs from 'fs-extra';
import * as replace from 'replace';

// import * as SequelizeAuto from 'sequelize-auto'

export default class Eject extends Command {
  static description =
    'Generate sequelize models and json schemas from database';

  static flags = {
    ...Command.flags,
    help: flags.help({ char: 'h' }),
    name: flags.string({
      char: 'n',
      description: 'Name to use for the admin panel folder',
    }),
    force: flags.boolean({
      char: 'f',
      description:
        'Overwrite admin if present before recreating them (Do not use in production...)',
    }),
  };

  async run() {
    const { flags } = this.parse(Eject);
    const force = flags.force;
    const src = path.resolve(
      process.cwd(),
      'node_modules/axel-core/admin-panel'
    );
    const dest = path.resolve(process.cwd(), flags.name || 'admin-panel');
    this.log(`Ejecting admin panel to ${dest}...`);
    if (force) {
      fs.removeSync(dest);
    }

    await replace({
      regex: 'adminPanelLocation:(.+)',
      replacement: '',
      paths: [path.resolve(process.cwd(), 'axel.config.js')],
      recursive: false,
      silent: true,
    });
    await replace({
      regex: 'module.exports(.+)',
      replacement: `module.exports$1
    adminPanelLocation: '${flags.name || 'admin-panel'}',`,
      paths: [path.resolve(process.cwd(), 'axel.config.js')],
      recursive: false,
      silent: true,
    });

    fs.copySync(src, dest, { overwrite: force });
  }
}

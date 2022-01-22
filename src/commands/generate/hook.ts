import Command from '../../base';
import { flags } from '@oclif/command';
import { renderTemplate } from '../../services/utils';
import * as _ from 'lodash';
import * as fs from 'fs';

export default class Hook extends Command {
  static description = 'Generate an api hook for your axel project';

  static target = 'hook';

  static args = [{ name: 'name', required: true }];

  static flags = {
    ...Command.flags,
    help: flags.help({ char: 'h' }),
    // flag with no value (-f, --force)
    force: flags.boolean({ char: 'f' }),
  };

  async run() {
    const { args, flags } = this.parse(Hook);
    this.init();
    const name = args.name.trim();

    const identity = _.snakeCase(name);
    const filename = identity;

    const hookPath = `./src/api/models/hooks/${_.upperFirst(filename)}.js`;
    if (fs.existsSync(hookPath) && !flags.force) {
      this.warn(`File ${hookPath} already exists. Use --force to overwrite.`);
    } else {
      renderTemplate(`${__dirname}/templates/models/sql-hooks.tpl`, hookPath, {
        identity,
      });
      const message = `✔️ Generated hook ${args.name}\n`;
      // this.log(chalk.green(message))
      this.log(message);
    }
  }
}

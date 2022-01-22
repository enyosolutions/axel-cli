import Command from '../../base';
import { flags } from '@oclif/command';
import { renderTemplate } from '../../services/utils';
import * as _ from 'lodash';
import * as fs from 'fs';

export default class Test extends Command {
  static description = 'Generate an api test for your axel project';

  static target = 'test';

  static args = [{ name: 'name', required: true }];

  static flags = {
    ...Command.flags,
    help: flags.help({ char: 'h' }),
    // flag with a value (-n, --name=VALUE)
    type: flags.string({
      char: 't',
      description: 'type of test',
      options: ['bare', 'full'],
      required: true,
    }),
    // flag with no value (-f, --force)
    force: flags.boolean({ char: 'f' }),
  };

  async run() {
    const { args, flags } = this.parse(Test);
    this.init();
    const type = flags.type;
    const name = args.name.trim();
    const folderArray: string[] = name.split('/');
    const controller: any = _.trim(folderArray.pop());
    const folder = folderArray.join('/').toLowerCase();

    const entityClass = _.startCase(controller).replace(/ /g, '');
    const entityIdentity = _.camelCase(controller).replace(/ /g, '');
    const entity = _.snakeCase(controller);
    const entityKebabCased = _.kebabCase(controller);
    const filename = entity;

    const testPath = `./test/${folder ? folder + '/' : ''}${filename}.test.js`;
    if (fs.existsSync(testPath) && !flags.force) {
      this.warn(`File ${testPath} already exists. Use --force to overwrite.`);
    } else {
      renderTemplate(
        `${__dirname}/templates/tests/api-test-${flags.type}.tpl`,
        testPath,
        {
          entity,
          type,
          controller,
          entityClass,
          entityIdentity,
          entityCamelCased: entityIdentity,
          entityApiUrl: entityKebabCased,
          entityKebabCased,
          filename,
          folder,
        }
      );
      const message = `✔️ Generated test ${args.name}\n`;
      // this.log(chalk.green(message))
      this.log(message);
    }
  }
}

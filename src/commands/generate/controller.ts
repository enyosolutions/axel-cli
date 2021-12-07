import Command from '../../base';
import { flags } from '@oclif/command';
import { renderTemplate } from '../../services/utils';
import * as _ from 'lodash';
import * as fs from 'fs';

type ControllerType = 'sql' | 'mongo' | 'bare';
type OptionsType = {
  name: string;
  type: ControllerType;
  force?: boolean | number;
};

export const generateController = (options: OptionsType) => {
  const { name, type, force } = options;
  const folderArray: string[] = name.split('/');
  const controller: any = _.trim(folderArray.pop());
  const folder = folderArray.join('/').toLowerCase();

  const entityClass = _.startCase(controller).replace(/ /g, '').trim();
  const entityIdentity = _.camelCase(controller).replace(/ /g, '');
  const entity = _.snakeCase(controller);
  const entityKebabCased = _.kebabCase(controller);
  const filename = entity;
  const controllerPath = `./src/api/controllers/${
    folder ? folder + '/' : ''
  }${entityClass}Controller.js`;

  if (fs.existsSync(controllerPath) && !force) {
    console.warn(
      `File ${controllerPath} already exists. Use --force to overwrite.`
    );
  } else {
    renderTemplate(
      `${__dirname}/templates/controllers/${type}.tpl`,
      controllerPath,
      {
        entityIdentity,
        controller,
        entity,
        entityCamelCased: entityIdentity,
        entityApiUrl: entityKebabCased,
        entityClass,
        entityKebabCased,
        filename,
        folder,
        type,
      }
    );
  }

  const testPath = `./test/controllers/${
    folder ? folder + '/' : ''
  }${filename}.test.js`;
  if (fs.existsSync(testPath) && !force) {
    console.warn(`File ${testPath} already exists. Use --force to overwrite.`);
  } else {
    renderTemplate(`${__dirname}/templates/tests/api-test-full.tpl`, testPath, {
      entityIdentity,
      controller,
      entity,
      entityCamelCased: entityIdentity,
      entityApiUrl: entityKebabCased,
      entityClass,
      entityKebabCased,
      filename,
      folder,
      type,
    });
  }
};

export default class Generate extends Command {
  static description = 'Generate a controller for your axel project';

  static target = 'controller';

  static args = [{ name: 'name', required: true }];

  static flags = {
    ...Command.flags,
    help: flags.help({ char: 'h' }),
    // flag with a value (-n, --name=VALUE)
    type: flags.string({
      char: 't',
      description: 'type of project',
      options: ['sql', 'mongo', 'bare'],
      required: true,
    }),
    // flag with no value (-f, --force)
    force: flags.boolean({ char: 'f' }),
  };

  async run() {
    const { args, flags } = this.parse(Generate);

    const { force } = flags;
    const type: any = flags.type;
    const name = args.name.trim();
    generateController({ name, type, force });
    const message = `✔️ Generated controller ${args.name}\n`;
    this.log(message);
  }
}

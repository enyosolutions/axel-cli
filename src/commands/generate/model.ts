import { Command, flags } from '@oclif/command';
const colors = require('colors');
import {
  renderTemplate,
  parseCommaInputs,
  promptFields
} from '../../services/Utils';
import * as _ from 'lodash';
import * as fs from 'fs';
import { cli } from 'cli-ux';

export default class Generate extends Command {
  static description = 'Generate a model for your esails project';
  static target = 'model';
  static args = [{ name: 'name', required: true }];

  static flags = {
    help: flags.help({ char: 'h' }),
    interactive: flags.boolean({ char: 'i', required: false }),
    // flag with a value (-n, --name=VALUE)
    types: flags.string({
      char: 't',
      description: 'type of project',
      options: ['sql', 'schema', 'all'],
      required: true,
      multiple: true
    }),
    fields: flags.string({
      description: 'List of fields to declare',
      required: false,
      multiple: true
    }),
    // flag with no value (-f, --force)
    force: flags.boolean({ char: 'f' })
  };

  async run() {
    const { args, flags } = this.parse(Generate);

    let types: string[] = [];
    if (flags.types) {
      types = parseCommaInputs(flags.types);
    }
    if (types.indexOf('all') > -1) {
      types = ['sql', 'schema'];
    }
    let fields = parseCommaInputs(flags.fields || []);

    if (flags.interactive) {
      this.log(
        'Type in the field name that you need in your model, one field at a time.'
      );
      this.log('When you are done just press enter.');
      fields = await promptFields();
      console.log(fields);
    }

    const name = args.name.trim();

    const entityClass = _.trim(_.startCase(name)).replace(/ /g, '');
    const entity = _.kebabCase(name);
    const filename = entity;

    for (let type of types) {
      const filePath = `./src/api/models/${type}/${entityClass}.ts`;

      if (fs.existsSync(filePath) && !flags.force) {
        this.warn(`File ${filePath} already exists. Use --force to overwrite.`);
      } else {
        renderTemplate(`${__dirname}/templates/models/${type}.tpl`, filePath, {
          type,
          entity,
          entityClass,
          filename,
          fields,
          isSql: types.indexOf('sql') > -1
        });
      }
    }
    const message = `✔️ Generated model ${args.name}\n`;
    // @ts-ignore
    this.log(message.green);
  }
}

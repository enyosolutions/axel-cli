import { flags } from '@oclif/command';
import Command, { getConfig } from '../../base';
import {
  renderTemplate,
  parseCommaInputs,
  promptFields,
} from '../../services/utils';
import * as _ from 'lodash';
import * as fs from 'fs';
import {
  generateSchemaFromModel,
  cliTypesToSqlTypesMap,
  cliTypesToSchemaTypesMap,
} from '../../services/models';

const modelsLocation = `${process.cwd()}/src/api/models/sequelize`;
const schemasLocation = `${process.cwd()}/src/api/models/schema`;
const hooksLocation = `${process.cwd()}/src/api/models/hooks`;

export type ModelType = 'sql' | 'schema' | 'all';
type OptionsType = {
  name: string;
  types: ModelType[];
  fields?: string[] | { [key: string]: any }[];
  fromSequelize?: boolean | number;
  force?: boolean | number;
  projectConfig?: any;
};

export const generateModel = ({
  name,
  types,
  fields,
  fromSequelize,
  force,
  projectConfig,
}: OptionsType) => {
  const pConfig = projectConfig || getConfig();
  const format: 'camelCase' | 'kebabCase' | 'snakeCase' =
    pConfig && pConfig.modelIdentityFormat;

  const entityClass = _.trim(_.startCase(name)).replace(/ /g, '');
  const entity = _.kebabCase(name);
  const entityKebabCased = _.kebabCase(name);
  const entityCamelCased = _.camelCase(name);
  const filename = entityClass;

  if (!format || !_[format]) {
    console.error('Unsupported value in project config [modelIdentityFormat]');
    return;
  }
  const identity: any = _[format](entity);

  for (const type of types) {
    const filePath = `./src/api/models/${
      type === 'sql' ? 'sequelize' : type
    }/${entityClass}.js`;

    if (fs.existsSync(filePath) && !force) {
      console.warn(
        `File ${filePath} already exists. Use --force to overwrite.`
      );
      return;
    }
    if (type === 'schema' && fromSequelize) {
      generateSchemaFromModel(
        modelsLocation + '/' + filename + '.js',
        schemasLocation + '/' + filename + '.js',
        { force }
      );

      return;
    }

    const sqlFields = fields // @ts-ignore
      ? fields.map((f: any) => {
          if (f.name && f.type) {
            return {
              ...f,
              // @ts-ignore
              type: (cliTypesToSqlTypesMap[f.type] as any) || f.type,
            };
          }
          return f;
        })
      : [];
    const schemaFields = fields // @ts-ignore
      ? fields.map((f: any) => {
          if (f.name && f.type) {
            return {
              ...f,
              // @ts-ignore
              type:
                (cliTypesToSchemaTypesMap[f.type] as any) || f.type || 'string',
            };
          }
          return f;
        })
      : [];
    const config = {
      ...projectConfig,
      type,
      identity,
      entity,
      tableName: identity,
      entityClass,
      entityKebabCased,
      entityCamelCased,
      filename,
      fields: type === 'sql' ? sqlFields : schemaFields,
      isSql: types.indexOf('sql') > -1,
      automaticApi: Boolean(pConfig.automaticApi),
      jsonSchemaValidation: Boolean(pConfig.jsonSchemaValidation),
    };

    renderTemplate(
      `${__dirname}/templates/models/${type}.tpl`,
      filePath,
      config
    );
    console.log('type', type);
    // if type is sql render the hooks also
    if (type === 'sql') {
      renderTemplate(
        `${__dirname}/templates/models/sql-hooks.tpl`,
        filePath.replace('/sequelize/', '/hooks/'),
        config
      );
    }
  }
};

export default class Generate extends Command {
  static description = 'Generate a model for your axel project';

  static target = 'model';

  static args = [{ name: 'name', required: true }];

  static flags = {
    ...Command.flags,
    help: flags.help({ char: 'h' }),
    interactive: flags.boolean({ char: 'i', required: false }),
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
      description: 'Generate the schema from the sequelize model',
      required: false,
    }),
    // flag with no value (-f, --force)
    force: flags.boolean({ char: 'f' }),
  };

  async run() {
    const { args, flags } = this.parse(Generate);

    const { force } = flags;

    let types: ModelType[] = [];
    if (flags.types) {
      types = parseCommaInputs(flags.types) as ModelType[];
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
    }

    const name = args.name.trim();
    generateModel({
      name,
      types,
      fields,
      force,
      projectConfig: this.projectConfig,
    });
    const message = `✔️ Generated model ${args.name}\n`;
    this.log(message);
  }
}

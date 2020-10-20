import Command from '../../base'
import {flags} from '@oclif/command'
import * as chalk from 'chalk'
import {
  promptFields,
} from '../../services/utils'
import {generateRoute} from './route'
import {generateModel, ModelType} from './model'
import  {generateController} from './controller'

export type ApiType = 'mongo' | 'sql';

type ApiOptionsType = {
  name: string;
  type: ApiType;
  force?: boolean | number;
  withSchema?: boolean | number;
  fields?: string[] | { [key: string]: any }[];
  types?: string[];
};

export const generateApi = async ({
  name,
  type,
  force,
  fields,
  withSchema,
}: ApiOptionsType) => {
  const modelType: ModelType = type === 'mongo' ? 'schema' : 'sql'
  const types: ModelType[] = withSchema ? ['schema', 'sql'] : [modelType]
  console.warn('ModelType', modelType, types)
  const modelParams: any = [name, '--types ' +  types.join(',')]
  const controllerParams = [name, '--type', type]
  if (force) {
    modelParams.push('--force')
    controllerParams.push('--force')
  }
  if (fields && fields.length > 0) {
    modelParams.push('--fields ' + fields.join(','))
  }
  console.log('modelParams', modelParams, fields)
  await generateModel({name, types, fields})
  await generateController({name, type, force})
  await generateRoute(name)
}

export default class Generate extends Command {
  static description = 'Generate an api for your axel project';

  static target = 'api';

  static args = [{name: 'name', required: true}];

  static flags = {
    help: flags.help({char: 'h'}),
    // flag with a value (-n, --name=VALUE)
    type: flags.string({
      char: 't',
      description: 'type of database',
      options: ['sql', 'mongo'],
      default: 'sql',
    }),
    interactive: flags.boolean({char: 'i', required: false}),
    // flag with a value (-n, --name=VALUE)
    'with-schema': flags.boolean({
      description:
        'Whether to generate schema model also when generating an sql model',
      required: false,
    }),
    force: flags.boolean({
      description:
        'Whether to generate schema model also when generating an sql model',
      required: false,
      default: false,
    }),
    fields: flags.string({
      description: 'List of fields to declare in the model',
      required: false,
      multiple: true,
    }),
  };

  async run() {
    const {args, flags} = this.parse(Generate)

    const {name} = args
    const {interactive, force} = flags
    let fields = flags.fields
    const type: ApiType = flags.type as ApiType
    if (flags.interactive) {
      this.log(
        'Type in the field name that you need in your model, one field at a time.'
      )
      this.log('When you are done just press enter.')
      fields = await promptFields()
    }
    generateApi({name, type, force, fields, withSchema: flags['with-schema']})
    this.log(chalk.green('\n✔️ all done'))
  }
}

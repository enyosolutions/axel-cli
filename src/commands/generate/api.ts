import {Command, flags} from '@oclif/command'
import Route from './route'
import Model from './model'
import Controller from './controller'
export default class Generate extends Command {
  static description = 'Generate an api for your esails project';

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

    const modelType = flags.type === 'mongo' ? 'schema' : 'sql'

    const modelParams = [
      args.name,
      '--types',
      flags['with-schema'] ? 'all' : modelType,
    ]

    const controllerParams = [args.name, '--type', flags.type]
    if (flags.interactive) {
      modelParams.push('-i')
    }
    if (flags.force) {
      modelParams.push('--force')
      controllerParams.push('--force')
    }
    await Model.run(modelParams)
    await Controller.run(controllerParams)
    await Route.run([args.name])
    this.log('\'✔️ all done')
  }
}

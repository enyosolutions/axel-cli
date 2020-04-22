import {Command, flags} from '@oclif/command'

export default class Generate extends Command {
  static description = 'Generate various documents for your esails project';

  static args = [
    {
      name: 'target',
      required: true,
      options: ['api', 'controller', 'route', 'model', 'migration'],
    },
  ];

  static flags = {
    help: flags.help({char: 'h'}),
    // flag with a value (-n, --name=VALUE)
    type: flags.string({
      char: 't',
      description: 'type of project',
      options: [''],
      default: 'sql',
    }),
    // flag with no value (-f, --force)
    force: flags.boolean({char: 'f'}),
  };

  async run() {
    const {args, flags} = this.parse(Generate)

    const type = flags.type
    this.log(
      `hello ${args.target} ${type} from /Users/faou/Projects/esails-cli/src/commands/generate.ts`
    )
  }
}

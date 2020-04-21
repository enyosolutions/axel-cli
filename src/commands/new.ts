import {Command, flags} from '@oclif/command'

export default class New extends Command {
  static description = `Create a new esails project.
  - Download the zip of project
  - Unzip it,
  - Place crud controller, auth controller, and Authservices according to the database system.
  `;

  static flags = {
    help: flags.help({char: 'h'}),
    type: flags.string({char: 'n', description: 'name to print',
    options: ['mongodb', 'sql']
  }),
  }

  static args = [{name: 'projectName'}]

  async run() {
    const {args, flags} = this.parse(New);

    const name = args.projectName;
    this.log(
      `hello ${name} from /Users/faou/Projects/esails-cli/src/commands/new.ts`,
    );
  }
}

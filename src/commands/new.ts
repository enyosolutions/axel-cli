import {Command, flags} from '@oclif/command'

export default class New extends Command {
  static description = `Create a new axel project.
  - Download the zip of project
  - Unzip it,
  - install peer dependencies,
  - Place relevant crud controller, auth controller, and Authservices according to the database system.
  `;

  static flags = {
    help: flags.help({char: 'h'}),
    type: flags.string({char: 'n', description: 'name to print',
      options: ['mongodb', 'sql'],
    }),
  }

  static args = [{name: 'projectName'}]

  async run() {
    const {args} = this.parse(New)

    const name = args.projectName
    this.log(
      `hello ${name} from /Users/faou/Projects/axel-cli/src/commands/new.ts`,
    )
  }
}

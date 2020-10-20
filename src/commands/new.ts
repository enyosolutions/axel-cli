import {Command, flags} from '@oclif/command'
import {execSync} from 'child_process'
import {mkdirSync, createWriteStream, unlink} from 'fs'
import * as http from 'http'

const download = function (url, dest) {
  const file = createWriteStream(dest)
  return new Promise((resolve, reject) => {
    http
    .get(url, function (response) {
      response.pipe(file)
      file.on('finish', function () {
        file.close() // close() is async, call cb after close completes.
        resolve()
      })
    })
    .on('error', function (err) {
      // Handle errors
      unlink(dest, err => {
        if (err) {
          console.warn(err)
        }
      }) // Delete the file async. (But we don't check the result)
      reject(err.message)
    })
  })
}

export default class New extends Command {
  static description = `Create a new axel project.
  - Download the zip of project
  - Unzip it,
  - install peer dependencies,
  - Place relevant crud controller, auth controller, and Authservices according to the database system.
  `;

  static flags = {
    help: flags.help({char: 'h'}),
    type: flags.string({
      char: 'n',
      description: 'name to print',
      options: ['mongodb', 'sql'],
    }),
  };

  static args = [{name: 'name'}];

  async run() {
    const {args} = this.parse(New)

    const name = args.name
    mkdirSync(name)
    execSync(`cd ${name} `)
    download('', name)
    .then(() => {
      this.log(
        `hello ${name} from /Users/faou/Projects/axel-cli/src/commands/new.ts`
      )
    })
    this.log(
      `hello ${name} from /Users/faou/Projects/axel-cli/src/commands/new.ts`
    )
  }
}

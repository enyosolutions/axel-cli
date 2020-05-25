import {Command, flags} from '@oclif/command'
const {cosmiconfigSync} = require('cosmiconfig')
import * as fs from 'fs'

export default class Init extends Command {
  static description = 'describe the command here';

  static flags = {
    help: flags.help({char: 'h'}),
    // flag with no value (-f, --force)
  };

  static args = [{name: 'file'}];

  async run() {
    const {args, flags} = this.parse(Init)
    const moduleName = 'axel'

    const explorer = cosmiconfigSync(moduleName, {})
    explorer.clearCaches()
    const searchedFor = explorer.search()
    this.log(searchedFor)
    if (searchedFor &&  !searchedFor.isEmpty) {
      this.error(
        'Config file already initialized'
      )
      return new Error('config_already_exists')
    }
    fs.writeFileSync('axel.config.json', 'module.exports = {"da":  true};\n', {
      encoding: 'utf8',
    })
    this.log('Config done.')
  }
}

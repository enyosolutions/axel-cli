import {Command, flags} from '@oclif/command'
const {cosmiconfigSync} = require('cosmiconfig')
import * as fs from 'fs'
import {promptInit} from '../services/utils'

export default class Init extends Command {
  static description = 'describe the command here';

  static flags = {
    help: flags.help({char: 'h'}),
    // flag with no value (-f, --force)
  };

  static args = [{name: 'file'}];

  async run() {
    // const {args, flags} = this.parse(Init)
    const moduleName = 'axel'

    const explorer = cosmiconfigSync(moduleName, {})
    explorer.clearCaches()
    const searchedFor = explorer.search()
    this.log(searchedFor)
    if (searchedFor && !searchedFor.isEmpty) {
      this.error('Config file already initialized', searchedFor)
      return new Error('config_already_exists')
    }
    const config = await promptInit([
      'projectName',
      {
        name: 'modelIdentityFormat',
        message: 'identity format (camelCase | snakeCase)',
        type: 'list',
        default: 'camelCase',
        choices: [
          {name: 'camelCase'},
          {name: 'snakeCase'},
          {name: 'kebabCase'},
        ],
      },
      {
        name: 'database',
        message: 'Database',
        type: 'list',
        choices: [
          'sequelize',
          {value: 'mongodb', name: 'mongodb (incomplete support)'},
        ],
      },
      {
        name: 'primaryKey',
        message: 'Primary Key (id | _id | other) ',
        default: 'id',
      },
      {
        name: 'jsonSchema',
        message: 'Add json schema support (generate schema along with models)',
        default: true,
      },
      {
        name: 'jsonSchemaValidation',
        message: 'Validate data using json schema',
        default: false,
      },
    ])

    fs.writeFileSync(
      'axel.config.js',
      `module.exports = ${JSON.stringify(config, null, 2)};\n`,
      {
        encoding: 'utf8',
      }
    )
    this.log('Config done.')
  }
}

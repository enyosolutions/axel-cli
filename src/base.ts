import Command, {flags} from '@oclif/command'
const {cosmiconfigSync} = require('cosmiconfig')

export default abstract class extends Command {
                 static flags = {
                   loglevel: flags.string({
                     options: ['error', 'warn', 'info', 'debug'],
                     default: 'info',
                   }),
                 };

                 projectConfig: {[key: string]: any} = {};

                 async init() {
                   // do some initialization
                   const explorer = cosmiconfigSync('axel')
                   const searchedFor = explorer.search()
                   if (!searchedFor || searchedFor.isEmpty) {
                     this.error(
                       'No config found! Is this an axel project ? If so make sure you have a config file initialized.'
                     )
                     return new Error('no_config_found')
                   }
                   this.projectConfig = searchedFor.config
                   const {flags} = this.parse(this.constructor)
                   this.flags = flags
                 }
}

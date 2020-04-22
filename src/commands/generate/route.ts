import {Command, flags} from '@oclif/command'
import * as _ from 'lodash'
import * as replace from 'replace'
import * as chalk from 'chalk'

export default class Generate extends Command {
  static description = 'Generate an api for your esails project';

  static target = 'api';

  static args = [{name: 'name', required: true}];

  static flags = {
    help: flags.help({char: 'h'}),
    secure: flags.string({char: 's', description: 'Add secure policies to the app'}),
  };

  async run() {
    const {args} = this.parse(Generate)

    let folderPath: any = args.name.split('/')
    const name = folderPath.pop()
    folderPath = folderPath.join('/')
    const route = _.kebabCase(name)
    const file = _.startCase(name).replace(/ /g, '')
    replace({
      regex: 'routes: ?{',
      replacement: `routes: {

        // Endpoints for ${_.startCase(name)}
        'GET /api/${route}/stats': '${folderPath}/${file}Controller.stats',
        'GET /api/${route}': '${folderPath}/${file}Controller.list',
        'GET /api/${route}/:id': '${folderPath}/${file}Controller.get',
        'POST /api/${route}': '${folderPath}/${file}Controller.post',
        'PUT /api/${route}/:id': '${folderPath}/${file}Controller.put',
        'DELETE /api/${route}/:id': '${folderPath}/${file}Controller.delete',

        /*
        // UNCOMMENT IF YOU NEED IMPORT AND EXPORT FORM EXCEL FEATURES
        'GET /api/${route}/export': '${folderPath}/${file}Controller.export',
        'POST /api/${route}/import': '${folderPath}/${file}Controller.import',
        'GET /api/${route}/import-template': '${folderPath}/${file}Controller.importTemplate',
        */


        `,
      paths: ['./src/config/routes.ts'],
      recursive: false,
      silent: true,
    })
    const message = '✔️ Generated route ' + args.name
    this.log(chalk.green(message))
  }
}

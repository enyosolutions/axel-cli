import { flags } from '@oclif/command';
import * as _ from 'lodash';
import Command from '../../base';

const replace = require('replace');

export const generateRoute = (routeName: string) => {
  let folderPath: any = routeName.split('/');
  const name = folderPath.pop();
  folderPath = folderPath.join('/');
  if (folderPath) {
    folderPath += '/';
  }
  const route = _.kebabCase(name);
  const file = _.startCase(name).replace(/ /g, '');
  replace({
    regex: 'routes: ?{',
    replacement: `routes: {

        // Endpoints for ${_.startCase(name)}
        // If you don't need some of them, be sure to delete the route AND the action in the controller...
        'GET /api/${route}/stats': '${folderPath}${file}Controller.stats',
        'GET /api/${route}': '${folderPath}${file}Controller.findAll',
        'GET /api/${route}/:id': '${folderPath}${file}Controller.findOne',
        'POST /api/${route}': '${folderPath}${file}Controller.create',
        'PUT /api/${route}/:id': '${folderPath}${file}Controller.updateOne',
        'DELETE /api/${route}/:id': '${folderPath}${file}Controller.deleteOne',

        /*
        // UNCOMMENT IF YOU NEED IMPORT AND EXPORT FORM EXCEL FEATURES
        'GET /api/${route}/export': '${folderPath}${file}Controller.exportData',
        'POST /api/${route}/import': '${folderPath}${file}Controller.importData',
        'GET /api/${route}/import-template': '${folderPath}${file}Controller.getImportTemplate',
        */
        `,
    paths: ['./src/config/routes.js'],
    recursive: false,
    silent: true,
  });
};
export default class Generate extends Command {
  static description = 'Generate an api for your axel project';

  static target = 'route';

  static args = [{ name: 'name', required: true }];

  static flags = {
    help: flags.help({ char: 'h' }),
    secure: flags.string({
      char: 's',
      description: 'Add secure policies to the app',
    }),
  };

  async run() {
    const { args } = this.parse(Generate);
    generateRoute(args.name);
    const message = '✔️ Generated route ' + args.name;
    this.log(message);
  }
}

import Command from '../../base'
import {flags} from '@oclif/command'
import {renderTemplate} from '../../services/utils'
import * as _ from 'lodash'
import * as fs from 'fs'
import * as chalk from 'chalk'

export default class Generate extends Command {
  static description = 'Generate a controller for your axel project';

  static target = 'controller';

  static args = [{name: 'name', required: true}];

  static flags = {
    help: flags.help({char: 'h'}),
    // flag with a value (-n, --name=VALUE)
    type: flags.string({
      char: 't',
      description: 'type of project',
      options: ['sql', 'mongo', 'bare'],
      required: true,
    }),
    // flag with no value (-f, --force)
    force: flags.boolean({char: 'f'}),
  };

  async run() {
    const {args, flags} = this.parse(Generate)

    const type = flags.type
    const name = args.name.trim()
    const folderArray: string[] = name.split('/')
    const controller: any = _.trim(folderArray.pop())
    const folder = folderArray.join('/').toLowerCase()

    const entityClass = (_.startCase(controller)).replace(/ /g, '')
    const entityIdentity = (_.camelCase(controller)).replace(/ /g, '')
    const entity = _.snakeCase(controller)
    const entityKebabCased = _.kebabCase(controller)
    const filename = entity
    const controllerPath = `./src/api/controllers/${
      folder ? folder + '/' : ''
    }${entityClass}Controller.ts`

    if (fs.existsSync(controllerPath) && !flags.force) {
      this.warn(
        `File ${controllerPath} already exists. Use --force to overwrite.`
      )
    } else {
      renderTemplate(
        `${__dirname}/templates/controllers/${type}.tpl`,
        controllerPath,
        {entity, type, controller, entityClass, filename, folder}
      )
    }

    const testPath = `./test/controllers/${
      folder ? folder + '/' : ''
    }${filename}.test.ts`
    if (fs.existsSync(testPath) && !flags.force) {
      this.warn(`File ${testPath} already exists. Use --force to overwrite.`)
    } else {
      renderTemplate(
        `${__dirname}/templates/tests/api-test-full.tpl`,
        testPath,
        {
          entity,
          type,
          controller,
          entityClass,
          entityIdentity,
          entityCamelCased: entityIdentity,
          entityKebabCased,
          filename,
          folder,
        }
      )
      const message = `✔️ Generated controller ${args.name}\n`
      this.log(chalk.green(message))
    }
  }
}

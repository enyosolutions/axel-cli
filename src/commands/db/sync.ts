import Command from '../../base'
import {flags} from '@oclif/command'
import * as path from 'path'
import * as fs from 'fs'
import cli from 'cli-ux'

export default class Sync extends Command {
  static description = 'Sync sequelize models to the database';

  static flags = {
    help: flags.help({char: 'h'}),
    alter: flags.boolean({
      char: 'a',
      default: false,
      description: 'Alter table columns if they already exist.',
    }),
    force: flags.boolean({
      char: 'f',
      description:
        'Drop tables before recreating them (Do not use in production...',
    }),
    silent: flags.boolean({
      char: 's',
      default: false,
      description: 'Do not ask for confirmation',
    }),
  };

  async run() {
    const {flags} = this.parse(Sync)

    const resource = path.resolve(process.cwd(), 'src/resources/sequelize/models/index.js')
    this.log('Running db:sync based on models in ', resource)
    if (!fs.existsSync(resource)) {
      this.error('models resources not found ! . Please make sure you compile your code before running axel')
      return
    }

    const alter = flags.alter
    const force = flags.force
    const silent = flags.silent

    if (force && !silent) {
      const confirm = await cli.confirm(
        'Are you sure you want to drop tables ? (this operation is irreversible...)'
      )
      if (!confirm) {
        this.log('Aborting operation')
        return
      }
    }
    import(resource)
    .then(db => {
      Object.values(db.sequelize.models).forEach((model: any) => {
        if (model.attributes) {
          Object.keys(model.attributes).forEach(idx => {
            const attr = model.attributes[idx]
            if (typeof attr.type === 'string') {
              const type = attr.type
              .replace('DataTypes.', '')
              .replace('sequelize.', '')
              .replace(/\(.+\)/, '')
              const args = attr.type.match(/\(.+\)/)
              const resolvedType = _.get(db.Sequelize.DataTypes, type)
              if (resolvedType) {
                attr.type = resolvedType
                if (args && args[0]) {
                  attr.type = attr.type(
                    ...args[0]
                    .replace(/\(|\)/g, '')
                    .split(',')
                    .map(s => s.replace(/["']/g, '').trim())
                  )
                }
              }
            }
          })
        }
      })

      return (db.default || db).sequelize.sync({alter, force})
    })
    .catch((error: Error) => {
      this.error(error)
    })
  }
}

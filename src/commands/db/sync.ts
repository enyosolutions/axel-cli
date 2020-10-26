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
    this.log('Running db:sync based on models.')
    if (!fs.existsSync(path.resolve(process.cwd(), 'src/resources/sequelize/models'))) {
      this.error('models resources not found ! . Please make sure you compile your code before running axel')
      return;
    }
    const dbImportConfig = import(
      path.resolve(process.cwd(), 'src/resources/sequelize/models')
    )
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
    await dbImportConfig
    .then(db => {
      return db.default.sequelize.sync({alter, force})
    })
    .catch((error: Error) => {
      this.error(error)
    })
  }
}

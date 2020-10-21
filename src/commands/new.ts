import {Command, flags} from '@oclif/command'
import Init from './init'
import {
  renameSync,
  createWriteStream,
  createReadStream,
  unlink,
  existsSync, unlinkSync, readFileSync, writeFileSync,
} from 'fs'
import * as http from 'http'
import * as https from 'https'
const unzipper = require('unzipper')

const download = (url: string, filePath: string) => {
  const proto = url.charAt(4) === 's' ? https : http

  return new Promise((resolve, reject) => {
    const file = createWriteStream(filePath)
    let fileInfo: any = null

    const request = proto.get(url, response => {
      if (response.statusCode !== 200) {
        reject(new Error(`Failed to get '${url}' (${response.statusCode})`))
        return
      }

      fileInfo = {
        mime: response.headers['content-type'],
        size: response.headers['content-length'] ? parseInt(response.headers['content-length'], 10) : 0,
      }

      response.pipe(file)
    })

    // The destination stream is ended by the time it's called
    file.on('finish', () => resolve(fileInfo))

    request.on('error', err => {
      unlink(filePath, () => reject(err))
    })

    file.on('error', err => {
      unlink(filePath, () => reject(err))
    })

    request.end()
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
    silent: flags.boolean({
      char: 's',
      description: 'Silent',
    }),
  };

  static args = [{name: 'name'}];

  async run() {
    const {args, flags} = this.parse(New)

    const name = args.name
    const exists = existsSync(name)
    if (exists) {
      console.warn(`/!\\ Project ${name} already exists!`)
      return
    }

    download(
      'https://codeload.github.com/enyosolutions/axel-template/zip/master',
      'axel-tmp.zip'
    )
    .then(() => {
      return (
        createReadStream('axel-tmp.zip')
        // eslint-disable-next-line
            .pipe(unzipper.Extract({ path: './' }))
        .promise()
      )
    })
    .then(() => {
      renameSync('axel-template-master', name)
      unlinkSync('axel-tmp.zip')
      this.log(`Project ${name} created !`)

      let content = readFileSync(`${name}/package.json`, {
        encoding: 'utf8',
      })
      content = content.replace('{{name}}', name).replace('--name--', name)
      writeFileSync(`${name}/package.json`, content, {
        encoding: 'utf8',
      })

      if (flags.silent) {
        let content2 = readFileSync(`${name}/axel.config.js`, {
          encoding: 'utf8',
        })
        content2 = content2.replace('{{name}}', name).replace('--name--', name)
        writeFileSync(`${name}/axel.config.js`, content2, {
          encoding: 'utf8',
        })
      } else {
        unlinkSync(`${name}/axel.config.js`)
        process.chdir(name)
        Init.run([name])
      }
    })
    .catch((error: Error) => {
      this.warn(error.message)
    })
  }
}

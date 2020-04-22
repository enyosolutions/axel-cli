import * as fs from 'fs'
import * as path from 'path'
import * as _ from 'lodash'
import cli from 'cli-ux'

const mkdirp = require('mkdirp')

export function renderTemplate(
  source: string,
  dest: string,
  data: { [key: string]: any }
) {
  _.templateSettings.interpolate = /<%=([\s\S]+?)%>/g
  _.templateSettings.evaluate = /<%([\s\S]+?)%>/g

  const template = _.template(fs.readFileSync(source, {encoding: 'utf8'}))
  const text: string = template(data)
  let folder: any = dest.split('/')
  folder.pop()
  folder = folder.join('/')
  mkdirp.sync(folder)
  return fs.writeFileSync(path.resolve(dest), text)
}

export function parseCommaInputs(source: array) {
  let output: string[] = []
  source.forEach((item: string) => {
    const tArray = item.split(',').map(_.trim)
    output = output.concat(tArray)
  })
  return output
}

export async function promptFields(
  message = 'Type the next field name (leave empty to finish) '
) {
  const fields = []
  let hasInput = true
  do {
    /* eslint-disable-next-line no-await-in-loop */
    const input = await cli.prompt(message, {required: false})
    if (!input) {
      hasInput = false
      return fields
    }
    fields.push(input.trim())
  } while (hasInput)
  return fields
}

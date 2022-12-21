# @axel/cli

![](https://github.com/enyosolutions-team/axel-cli/workflows/CI/badge.svg)
[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)
[![Version](https://img.shields.io/npm/v/@axel/cli.svg)](https://npmjs.org/package/@axel/cli)
[![Downloads/week](https://img.shields.io/npm/dw/@axel/cli.svg)](https://npmjs.org/package/@axel/cli)
[![License](https://img.shields.io/npm/l/@axel/cli.svg)](https://github.com/enyosolutions-team/axel-cli/blob/master/package.json)

<!-- toc -->
* [@axel/cli](#axelcli)
* [Usage](#usage)
* [Commands](#commands)
<!-- tocstop -->

# Usage

<!-- usage -->
```sh-session
$ npm install -g axel-cli
$ axel COMMAND
running command...
$ axel (-v|--version|version)
axel-cli/0.18.0 darwin-x64 node-v16.18.1
$ axel --help [COMMAND]
USAGE
  $ axel COMMAND
...
```
<!-- usagestop -->

# Commands

<!-- commands -->
* [`axel db:import`](#axel-dbimport)
* [`axel db:sync`](#axel-dbsync)
* [`axel generate TARGET`](#axel-generate-target)
* [`axel generate:api NAME`](#axel-generateapi-name)
* [`axel generate:controller NAME`](#axel-generatecontroller-name)
* [`axel generate:hook NAME`](#axel-generatehook-name)
* [`axel generate:model NAME`](#axel-generatemodel-name)
* [`axel generate:route NAME`](#axel-generateroute-name)
* [`axel generate:test NAME`](#axel-generatetest-name)
* [`axel hello [FILE]`](#axel-hello-file)
* [`axel help [COMMAND]`](#axel-help-command)
* [`axel init [NAME]`](#axel-init-name)
* [`axel new [NAME]`](#axel-new-name)
* [`axel run [FILE]`](#axel-run-file)

## `axel db:import`

Generate sequelize models and json schemas from database

```
Generate sequelize models and json schemas from database

USAGE
  $ axel db:import

OPTIONS
  -f, --force          Overwrite models if present before recreating them (Do not use in production...)
  -h, --help           show CLI help
  -s, --schemas        Also generate schemas
  -t, --tables=tables  list of tables to import
```

_See code: [src/commands/db/import.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/db/import.ts)_

## `axel db:sync`

Sync sequelize models to the database

```
Sync sequelize models to the database

USAGE
  $ axel db:sync

OPTIONS
  -a, --alter          Alter table columns if they already exist.
  -f, --force          Drop tables before recreating them (Do not use in production...
  -h, --help           show CLI help
  -m, --match=match    name of database to match (ex: _test)
  -s, --silent         Do not ask for confirmation
  -t, --tables=tables  name of table to sync (ex: user)
```

_See code: [src/commands/db/sync.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/db/sync.ts)_

## `axel generate TARGET`

Generate various documents for your axel project

```
Generate various documents for your axel project

USAGE
  $ axel generate TARGET

OPTIONS
  -f, --force
  -h, --help   show CLI help
  -t, --type=  [default: sql] type of project
```

_See code: [src/commands/generate.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate.ts)_

## `axel generate:api NAME`

Generate an api for your axel project

```
Generate an api for your axel project

USAGE
  $ axel generate:api NAME

OPTIONS
  -h, --help            show CLI help
  -i, --interactive
  -t, --type=sql|mongo  [default: sql] type of database
  --fields=fields       List of fields to declare in the model
  --force               Whether to generate schema model also when generating an sql model
  --with-schema         Whether to generate schema model also when generating an sql model
```

_See code: [src/commands/generate/api.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate/api.ts)_

## `axel generate:controller NAME`

Generate a controller for your axel project

```
Generate a controller for your axel project

USAGE
  $ axel generate:controller NAME

OPTIONS
  -f, --force
  -h, --help                 show CLI help
  -t, --type=sql|mongo|bare  (required) type of project
```

_See code: [src/commands/generate/controller.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate/controller.ts)_

## `axel generate:hook NAME`

Generate an api hook for your axel project

```
Generate an api hook for your axel project

USAGE
  $ axel generate:hook NAME

OPTIONS
  -f, --force
  -h, --help   show CLI help
```

_See code: [src/commands/generate/hook.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate/hook.ts)_

## `axel generate:model NAME`

Generate a model for your axel project

```
Generate a model for your axel project

USAGE
  $ axel generate:model NAME

OPTIONS
  -f, --force
  -h, --help                  show CLI help
  -i, --interactive
  -t, --types=sql|schema|all  (required) type of project
  --fields=fields             List of fields to declare
  --from-sequelize            Generate the schema from the sequelize model
```

_See code: [src/commands/generate/model.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate/model.ts)_

## `axel generate:route NAME`

Generate an api for your axel project

```
Generate an api for your axel project

USAGE
  $ axel generate:route NAME

OPTIONS
  -h, --help           show CLI help
  -s, --secure=secure  Add secure policies to the app
```

_See code: [src/commands/generate/route.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate/route.ts)_

## `axel generate:test NAME`

Generate an api test for your axel project

```
Generate an api test for your axel project

USAGE
  $ axel generate:test NAME

OPTIONS
  -f, --force
  -h, --help            show CLI help
  -t, --type=bare|full  (required) type of test
```

_See code: [src/commands/generate/test.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/generate/test.ts)_

## `axel hello [FILE]`

describe the command here

```
describe the command here

USAGE
  $ axel hello [FILE]

OPTIONS
  -f, --force
  -h, --help       show CLI help
  -n, --name=name  name to print

EXAMPLE
  $ axel hello
  hello world from ./src/hello.ts!
```

_See code: [src/commands/hello.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/hello.ts)_

## `axel help [COMMAND]`

display help for axel

```
display help for <%= config.bin %>

USAGE
  $ axel help [COMMAND]

ARGUMENTS
  COMMAND  command to show help for

OPTIONS
  --all  see all commands in CLI
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v2.2.3/src/commands/help.ts)_

## `axel init [NAME]`

describe the command here

```
describe the command here

USAGE
  $ axel init [NAME]

OPTIONS
  -h, --help  show CLI help
```

_See code: [src/commands/init.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/init.ts)_

## `axel new [NAME]`

Create a new axel project.

```
Create a new axel project.
  - Download the zip of project
  - Unzip it,
  - install peer dependencies,
  - Place relevant crud controller, auth controller, and Authservices according to the database system.
  

USAGE
  $ axel new [NAME]

OPTIONS
  -h, --help              show CLI help
  -n, --type=mongodb|sql  name to print
  -s, --silent            Silent

DESCRIPTION
  - Download the zip of project
     - Unzip it,
     - install peer dependencies,
     - Place relevant crud controller, auth controller, and Authservices according to the database system.
```

_See code: [src/commands/new.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/new.ts)_

## `axel run [FILE]`

describe the command here

```
describe the command here

USAGE
  $ axel run [FILE]

OPTIONS
  -f, --force
  -h, --help       show CLI help
  -n, --name=name  name to print
```

_See code: [src/commands/run.ts](https://github.com/enyosolutions-team/axel-cli/blob/v0.18.0/src/commands/run.ts)_
<!-- commandsstop -->

## Features / Todo

- [x] Generate models, routes, controllers and api
- [x] Init a project
- [x] Generate models from the sequelize-auto template
- [ ] Hook into sequelize cli commands
- [x] use config from rc files to locate folders
- [ ] Generate mongo controllers
- [x] Generate bare controllers
- [x] Generate bare controllers
- [ ] Custom models folder
- [ ] Better associations How to define relationships => https://docs.forestadmin.com/documentation/v/v6/reference-guide/relationships#lumber-relationship-generation-rules

- [ ] use primary from config when generating models

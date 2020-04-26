@esails/cli
===========



![](https://github.com/enyosolutions-team/esails-cli/workflows/CI/badge.svg)
[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)
[![Version](https://img.shields.io/npm/v/@esails/cli.svg)](https://npmjs.org/package/@esails/cli)
[![Downloads/week](https://img.shields.io/npm/dw/@esails/cli.svg)](https://npmjs.org/package/@esails/cli)
[![License](https://img.shields.io/npm/l/@esails/cli.svg)](https://github.com/enyosolutions-team/esails-cli/blob/master/package.json)

<!-- toc -->
* [Usage](#usage)
* [Commands](#commands)
<!-- tocstop -->
# Usage
<!-- usage -->
```sh-session
$ npm install -g @esails/cli
$ esails COMMAND
running command...
$ esails (-v|--version|version)
@esails/cli/0.0.1 darwin-x64 node-v12.11.1
$ esails --help [COMMAND]
USAGE
  $ esails COMMAND
...
```
<!-- usagestop -->
# Commands
<!-- commands -->
* [`esails db:sync`](#esails-dbsync)
* [`esails generate TARGET`](#esails-generate-target)
* [`esails generate:api NAME`](#esails-generateapi-name)
* [`esails generate:controller NAME`](#esails-generatecontroller-name)
* [`esails generate:model NAME`](#esails-generatemodel-name)
* [`esails generate:route NAME`](#esails-generateroute-name)
* [`esails hello [FILE]`](#esails-hello-file)
* [`esails help [COMMAND]`](#esails-help-command)
* [`esails init [FILE]`](#esails-init-file)
* [`esails new [PROJECTNAME]`](#esails-new-projectname)
* [`esails run [FILE]`](#esails-run-file)

## `esails db:sync`

Sync sequelize models to the database

```
USAGE
  $ esails db:sync

OPTIONS
  -a, --alter   Alter table columns if they already exist.
  -f, --force   Drop tables before recreating them (Do not use in production...
  -h, --help    show CLI help
  -s, --silent  Do not ask for confirmation
```

_See code: [src/commands/db/sync.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/db/sync.ts)_

## `esails generate TARGET`

Generate various documents for your esails project

```
USAGE
  $ esails generate TARGET

OPTIONS
  -f, --force
  -h, --help   show CLI help
  -t, --type=  [default: sql] type of project
```

_See code: [src/commands/generate.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/generate.ts)_

## `esails generate:api NAME`

Generate an api for your esails project

```
USAGE
  $ esails generate:api NAME

OPTIONS
  -h, --help            show CLI help
  -i, --interactive
  -t, --type=sql|mongo  [default: sql] type of database
  --fields=fields       List of fields to declare in the model
  --force               Whether to generate schema model also when generating an sql model
  --with-schema         Whether to generate schema model also when generating an sql model
```

_See code: [src/commands/generate/api.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/generate/api.ts)_

## `esails generate:controller NAME`

Generate a controller for your esails project

```
USAGE
  $ esails generate:controller NAME

OPTIONS
  -f, --force
  -h, --help            show CLI help
  -t, --type=sql|mongo  (required) type of project
```

_See code: [src/commands/generate/controller.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/generate/controller.ts)_

## `esails generate:model NAME`

Generate a model for your esails project

```
USAGE
  $ esails generate:model NAME

OPTIONS
  -f, --force
  -h, --help                  show CLI help
  -i, --interactive
  -t, --types=sql|schema|all  (required) type of project
  --fields=fields             List of fields to declare
```

_See code: [src/commands/generate/model.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/generate/model.ts)_

## `esails generate:route NAME`

Generate an api for your esails project

```
USAGE
  $ esails generate:route NAME

OPTIONS
  -h, --help           show CLI help
  -s, --secure=secure  Add secure policies to the app
```

_See code: [src/commands/generate/route.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/generate/route.ts)_

## `esails hello [FILE]`

describe the command here

```
USAGE
  $ esails hello [FILE]

OPTIONS
  -f, --force
  -h, --help       show CLI help
  -n, --name=name  name to print

EXAMPLE
  $ esails hello
  hello world from ./src/hello.ts!
```

_See code: [src/commands/hello.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/hello.ts)_

## `esails help [COMMAND]`

display help for esails

```
USAGE
  $ esails help [COMMAND]

ARGUMENTS
  COMMAND  command to show help for

OPTIONS
  --all  see all commands in CLI
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v2.2.3/src/commands/help.ts)_

## `esails init [FILE]`

describe the command here

```
USAGE
  $ esails init [FILE]

OPTIONS
  -f, --force
  -h, --help       show CLI help
  -n, --name=name  name to print
```

_See code: [src/commands/init.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/init.ts)_

## `esails new [PROJECTNAME]`

Create a new esails project.

```
USAGE
  $ esails new [PROJECTNAME]

OPTIONS
  -h, --help              show CLI help
  -n, --type=mongodb|sql  name to print

DESCRIPTION
  - Download the zip of project
     - Unzip it,
     - install peer dependencies,
     - Place relevant crud controller, auth controller, and Authservices according to the database system.
```

_See code: [src/commands/new.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/new.ts)_

## `esails run [FILE]`

describe the command here

```
USAGE
  $ esails run [FILE]

OPTIONS
  -f, --force
  -h, --help       show CLI help
  -n, --name=name  name to print
```

_See code: [src/commands/run.ts](https://github.com/enyosolutions-team/esails-cli/blob/v0.0.1/src/commands/run.ts)_
<!-- commandsstop -->



## Features

- [x] Generate models, routes, controllers anf api
- [ ] Init a project
- [X] Generate models from the sequelize-auto template
- [ ] Hook into sequelize cli commands
- [X] use config from rc files to locate folders
- [ ] Generate mongo controllers
- [X] Generate bare controllers

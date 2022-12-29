import Command from '@oclif/command';
const { cosmiconfigSync } = require('cosmiconfig');

export const getConfig = () => {
  // do some initialization
  const explorer = cosmiconfigSync('axel');
  const searchedFor = explorer.search();
  if (!searchedFor || searchedFor.isEmpty) {
    console.error(
      'No config found! Is this an axel project ? If so make sure you have a config file initialized.'
    );
    return new Error('no_config_found');
  }
  return searchedFor.config;
};
export default abstract class extends Command {
  // static flags = {

  // };

  projectConfig: { [key: string]: any } = {};

  async init() {
    this.projectConfig = getConfig();
    return this.projectConfig;
  }
}

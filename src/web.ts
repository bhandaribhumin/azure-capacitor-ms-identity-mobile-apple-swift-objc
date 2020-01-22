import { WebPlugin } from '@capacitor/core';
import { azureAppDelegatePlugin } from './definitions';

export class azureAppDelegateWeb extends WebPlugin implements azureAppDelegatePlugin {
  constructor() {
    super({
      name: 'azureAppDelegate',
      platforms: ['web']
    });
  }

  async echo(options: { value: string }): Promise<{value: string}> {
    console.log('ECHO', options);
    return options;
  }
}

const azureAppDelegate = new azureAppDelegateWeb();

export { azureAppDelegate };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(azureAppDelegate);

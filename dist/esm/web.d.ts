import { WebPlugin } from '@capacitor/core';
import { azureAppDelegatePlugin } from './definitions';
export declare class azureAppDelegateWeb extends WebPlugin implements azureAppDelegatePlugin {
    constructor();
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
declare const azureAppDelegate: azureAppDelegateWeb;
export { azureAppDelegate };

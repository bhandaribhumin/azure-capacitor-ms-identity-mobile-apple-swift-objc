declare module "@capacitor/core" {
  interface PluginRegistry {
    azureAppDelegate: azureAppDelegatePlugin;
  }
}

export interface azureAppDelegatePlugin {
  echo(options: { value: string }): Promise<{value: string}>;
}

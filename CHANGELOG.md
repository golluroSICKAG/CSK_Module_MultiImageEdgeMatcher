# Changelog
All notable changes to this project will be documented in this file.

## Release 2.1.0

### New features
- Check if persistent data to load provides all relevant parameters. Otherwise add default values

### Improvements
- Better instance handling regarding FlowConfig

### Bugfix
- Legacy bindings of ValueDisplay elements within UI did not work if deployed with VS Code AppSpace SDK
- UI differs if deployed via Appstudio or VS Code AppSpace SDK
- Fullscreen icon of iFrame was visible

## Release 2.0.1

### Bugfix
- ROI too small for bigger images
- Translation was limited to positive values

## Release 2.0.0

### New features
- Supports FlowConfig feature to set images to process / provide Transform object(s) or an aligned image
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'getParameters' to provide PersistentData parameters
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function to 'resetModule' to default setup

### Improvements
- 'OnNewTransformationNUM' can provide multiple 'Transform' results
- Reset tought status if changing downsample factor
- New UI design available (e.g. selectable via CSK_Module_PersistentData v4.1.0 or higher), see 'OnNewStatusCSKStyle'
- check if instance exists if selected
- 'loadParameters' returns its success
- 'sendParameters' can control if sent data should be saved directly by CSK_Module_PersistentData
- Changed log level of some messages from 'info' to 'fine'
- Added UI icon and browser tab information

### Bugfix
- Did not cancel editor correctly if selecting other instance
- Error if module is not active but 'getInstancesAmount' was called
- processInstanceNUM did not work after deregistering from event to process images

## Release 1.0.0
- Initial commit

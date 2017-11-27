
"use strict"; // This is for your code to comply with the ECMAScript 5 standard.

var moduleScapeAireasPath = require('path').resolve(__dirname, 'node_modules/scape-aireas/../..');

var apriConfig 	= require(moduleScapeAireasPath + '/apri-config');

var main_module	= process.argv[2];

module.exports = {

	start: function (options) {
		if (main_module == undefined) {
			console.log('Error: main modulename missing!');
			return -1;
		}

		if ( apriConfig.init(main_module) ) {
			console.log('aireas-start.js: '+ main_module);
			//console.log('systemfolderparent: '+ apriConfig.getSystemFolderParent());
			var apriModule = require(moduleScapeAireasPath + '/' + main_module);
			var options = {
				systemFolderParent: apriConfig.getSystemFolderParent(),
				configParameter: apriConfig.getConfigParameter(),
				systemCode: apriConfig.getSystemCode(),
	            twitterConfig: apriConfig.getTwitterConfig()
			};
			apriModule.init(options);
		}
	}
}

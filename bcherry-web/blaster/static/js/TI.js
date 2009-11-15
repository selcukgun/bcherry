// This file provides a mock JavaScript API for a TI graphing calculator
// You'll need a browser with <canvas> support, of course
// Right now, it assumes a TI-89 variety, but adding support for others would be trivial
;(function(){
	var TI = window.TI = {};
	
	var calcs = {
		ti89	: {
			display	: {
				width	: 160,
				height	: 100,
				bgColor	: "#D7E5D2",
				fgColor	: "#313F42"
			}
		}
	};
	
	TI.Calculator = function(model, params) {
		assert(model in calcs, "Unsupported Calculator");
		
		params = params || {};
		defaultParams = {
			width	: calcs[model].display.width,
			height	: calcs[model].display.height,
			gfxMode	: "monochrome"
		};
		for (var key in defaultParams) {
			if (params[key] === undefined) {
				params[key] = defaultParams[key];
			}
		}
		
		assert(params.gfxMode in {"monochrome":1, "grayscale":1}, "Unsupported graphics mode.");
		if (params.gfxMode == "monochrome") {
			this.display = new BasicDisplay(calcs[model].display, params.width, params.height);
		} else if (params.gfxMode == "grayscale") {
			this.display = new GrayDisplay(calcs[model].display, params.width, params.height);
		}
		
		this.getDomElement = this.display.getDomElement;
	};
	
	var BasicDisplay = function(params, width, height, noWarn) {
		noWarn || issueWarnings("display", params, width, height);
		
		var canvas = document.createElement("canvas");
		canvas.width = width;
		canvas.height = height;
		var pixelWidth = width / params.width;
		var pixelHeight = height / params.height;
		
		canvas.setAttribute("style", "background-color:" + params.bgColor + ";border:solid 1px black;");
		
		this.getDomElement = function() { return canvas; };
		
		this.pixelOn = function(x, y) {
			var ctx = canvas.getContext("2d");
			ctx.fillStyle = params.fgColor;
			ctx.fillRect(getX(x), getY(y), pixelWidth, pixelHeight);
		};
		
		this.pixelOff = function(x, y) {
			var ctx = canvas.getContext("2d");
			ctx.fillStyle = params.bgColor;
			ctx.fillRect(getX(x), getY(y), pixelWidth, pixelHeight);
		};
		
		this.drawSprite = function(sprite, width, x, y, mode) {
			mode = mode || "xor";
			
			for (var row = 0; row < sprite.length; row++) {
				for (var col = 0; col < width; col++) {
					if ((sprite[row] >> (width - col - 1)) & 1) {
						this.pixelOn(x + col, y + row);
					}
				}
			}
		};
		
		var getX = function(x) {
			return x * pixelWidth;
		};
		
		var getY = function(y) {
			return y * pixelHeight;
		};
	};
	
	var GrayDisplay = function(params, width, height, noWarn) {
		noWarn || issueWarnings("display", params, width, height);
		
		var div = document.createElement("div");
		div.setAttribute("style", "width:" + width + ";height:" + height + ";background-color:" + params.bgColor + ";border:solid 1px black;position:relative;");
		
		var plane1 = new BasicDisplay(params, width, height, true);
		var plane2 = new BasicDisplay(params, width, height, true);
		
		plane1.getDomElement().setAttribute("style", "position:absolute;top:0;left:0;opacity:0.3;");
		plane2.getDomElement().setAttribute("style", "position:absolute;top:0;left:0;opacity:0.7;");
		
		div.appendChild(plane1.getDomElement());
		div.appendChild(plane2.getDomElement());
		
		this.getDomElement = function() { return div; };
		
		this.pixelOn = function(x, y, color) {
			if (color === undefined) {
				color = 3;
			}
			if (color & 1) {
				plane1.pixelOn(x, y);
			}
			if (color & (1 << 1)) {
				plane2.pixelOn(x, y);
			}
		};
		
		this.pixelOff = function(x, y) {
			plane1.pixelOff(x, y);
			plane2.pixelOff(x, y);
		};
		
		this.drawSprite = function(layer1, layer2, width, x, y, mode) {
			plane1.drawSprite(layer1, width, x, y, mode);
			plane2.drawSprite(layer2, width, x, y, mode);
		};
	}
	
	// extra internal bits
	var assert = function(test, msg) {
		if (!test) {
			throw "TIjs Error: " + msg;
		}
	};
	
	var warn = function(msg) {
		if (window.console) {
			console.warn("TIjs Warning: " + msg);
		}
	};
	
	var issueWarnings = function(component, params, width, height) {
		switch (component.toLowerCase()) {
			case "display":
				if (width < params.width) {
					warn("Display width is too small, some pixels will be lost.");
				} else if (width % params.width !== 0) {
					warn("Display width is not even multiple of native width and will look bad.");
				}
				if (height < params.height) {
					warn("Display height is too small, some pixels will be lost");
				} else if (height % params.height !== 0) {
					warn("Display height is not even multiple of native height and will look bad.");
				}
				if (width / height != params.width / params.height) {
					warn("Display aspect ratio is off, dome distortion will occur.");
				}
				break;
		}
	};
})();
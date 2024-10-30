package debug;

using haxe.io.Path;

/*
A class that simply points OpenALSoft to a custom configuration file when the game starts up.
The config overrides a few global OpenALSoft settings with the aim of improving audio quality on desktop targets.
*/
@:keep class ALSoftConfig {
	#if desktop
	public static function __init__():Void {
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;
		var configPath:String = origin.withoutExtension().directory();
		#if windows
		configPath += '/plugins/alsoft.ini';
		#elseif mac
		configPath = configPath.directory() + '/Resources/plugins/alsoft.conf';
		#else
		configPath += '/plugins/alsoft.conf';
		#end
		Sys.putEnv('ALSOFT_CONF', configPath);
	}
	#end
}
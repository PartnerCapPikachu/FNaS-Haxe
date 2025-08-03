package backend;

import haxe.io.Path;

@:keep class ALSoftConfig
{
	#if desktop
	public static function __init__():Void
	{
		var configPath:String = Path.directory(Path.withoutExtension(#if hl Sys.getCwd() #else Sys.programPath() #end));
		#if windows
		configPath += '/plugins/alsoft.ini';
		#elseif mac
		configPath = Path.directory(configPath) + '/Resources/plugins/alsoft.conf';
		#else
		configPath += '/plugins/alsoft.conf';
		#end
		Sys.putEnv('ALSOFT_CONF', configPath);
	}
	#end
}
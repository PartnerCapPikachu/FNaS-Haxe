package main;

import lime.app.Application;

#if (cpp && windows)
@:buildXml('
	<target id="haxe">
		<lib name="dwmapi.lib"/>
		<lib name="gdi32.lib"/>
	</target>
')
@:cppFileCode('
	#include <windows.h>
	#include <dwmapi.h>
	#include <winuser.h>
	#include <wingdi.h>

	#define attributeDarkMode 20
	#define attributeDarkModeFallback 19

	#define attributeCaptionColor 34
	#define attributeTextColor 35
	#define attributeBorderColor 36

	struct HandleData
	{
		DWORD pid = 0;
		HWND handle = 0;
	};

	BOOL CALLBACK findByPID(HWND handle, LPARAM lParam)
	{
		DWORD targetPID = ((HandleData*)lParam)->pid;
		DWORD curPID = 0;

		GetWindowThreadProcessId(handle, &curPID);
		if (targetPID != curPID || GetWindow(handle, GW_OWNER) != (HWND)0 || !IsWindowVisible(handle))
		{
			return TRUE;
		}

		((HandleData*)lParam)->handle = handle;
		return FALSE;
	}

	HWND curHandle = 0;
	void getHandle()
	{
		if (curHandle == (HWND)0)
		{
			HandleData data;
			data.pid = GetCurrentProcessId();
			EnumWindows(findByPID, (LPARAM)&data);
			curHandle = data.handle;
		}
	}
')
#end
class Native
{
	public static function __init__():Void
	{
		registerDPIAware();
	}

	public static function registerDPIAware():Void
	{
		#if (cpp && windows)
		untyped __cpp__('
			SetProcessDPIAware();	
			#ifdef DPI_AWARENESS_CONTEXT
			SetProcessDpiAwarenessContext(
				#ifdef DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
				DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
				#else
				DPI_AWARENESS_CONTEXT_SYSTEM_AWARE
				#endif
			);
			#endif
		');
		#end
	}

	static var fixedScaling:Bool = false;
	@:access(lime.ui.Window)
	public static function fixScaling():Void
	{
		if (fixedScaling) return;
		fixedScaling = true;

		#if (cpp && windows)
		var display:Null<lime.system.Display> = lime.system.System.getDisplay(0);
		if (display != null)
		{
			var dpiScale:Float = display.dpi / 96;
			Application.current.window.width = Std.int(500 * dpiScale);
			Application.current.window.height = Std.int(500 * dpiScale);
			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) * .5);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) * .5);
		}

		untyped __cpp__('
			getHandle();
			if (curHandle != (HWND)0)
			{
				HDC curHDC = GetDC(curHandle);
				RECT curRect;
				GetClientRect(curHandle, &curRect);
				FillRect(curHDC, &curRect, (HBRUSH)GetStockObject(BLACK_BRUSH));
				ReleaseDC(curHandle, curHDC);
			}
		');
		#end
	}
}
-------------------------------------------------------------------------------
-- Premake5 build script for Wally
-------------------------------------------------------------------------------

-- Convenience locals

-- Configurations, filters must be updated if these change
conf_dbg = "Debug"
conf_rel = "Release"
conf_rtl = "Retail"

-- Platforms
plat_32bit = "x86"
plat_64bit = "x64"

-- Directories
build_dir = "Build"
out_dir = "Output"

-- Filters for each config
filter_dbg = "configurations:debug"
filter_rel_or_rtl = "configurations:release or retail"
filter_rtl = "configurations:retail"

-- Filters for each platform
filter_32bit = "platforms:" .. plat_32bit
filter_64bit = "platforms:" .. plat_64bit

-- Options --------------------------------------------------------------------

-- Actions --------------------------------------------------------------------

-- Functions ------------------------------------------------------------------

-- Workspace definition -------------------------------------------------------

workspace "Wally"
	configurations { conf_dbg, conf_rel, conf_rtl }
	platforms { plat_32bit, plat_64bit }
	location( build_dir )
	preferredtoolarchitecture "x86_64"
	startproject "Wally"

-- Configuration --------------------------------------------------------------

-- Misc flags for all projects

flags { "MultiProcessorCompile", "NoBufferSecurityCheck" }
staticruntime "On"
cppdialect "C++latest"
conformancemode "On"
warnings "Default"
floatingpoint "Default"
characterset "ASCII"
exceptionhandling "On"
editandcontinue "On"
vectorextensions "SSE2"

-- Config for all 32-bit projects
filter( filter_32bit )
	architecture "x86"
filter {}

-- Config for all 64-bit projects
filter( filter_64bit )
	architecture "x86_64"
filter {}

-- Config for Windows
filter "system:windows"
	buildoptions { "/Zc:__cplusplus", "/Zc:preprocessor" } -- "/utf-8"
	defines { "WIN32", "_WINDOWS", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS" }
filter {}

-- Config for Windows, release
filter { "system:windows", filter_rel_or_rtl }
	buildoptions { "/Gw", "/Zc:checkGwOdr" }
filter {}

-- Config for Linux
filter "system:linux"
	-- Fake headers for Linux
	includedirs { "thirdparty/linuxcompat" }
	-- Position independent code generation
	pic "On"
	-- Link groups
	linkgroups "On"
	-- Intrinsic stuff
	buildoptions { "-march=native -Wno-c++11-narrowing -Wno-register" }
	linkoptions { "-Wl,--no-undefined" }
	-- Always link to SDL2, it's basically our version of the WinAPI (which is accessible everywhere on Windows)
	-- TODO: Is this wrong for static libraries?
	links { "SDL2" }
filter {}

-- Config for all projects in debug, _DEBUG is defined for library-compatibility
filter( filter_dbg )
	defines { "_DEBUG" }
	symbols "FastLink"
filter {}

-- Config for all projects in release or retail, NDEBUG is defined for cstd compatibility (assert)
filter( filter_rel_or_rtl )
	defines { "NDEBUG" }
	symbols "Full"
	optimize "Speed"
filter {}

-- Config for all projects in retail
filter( filter_rtl )
	--symbols "Off" -- Enabling symbols for now for development
	flags { "LinkTimeOptimization" }
filter {}

-- Config for shared library projects
filter "kind:SharedLib"
	flags { "NoManifest" } -- We don't want manifests for DLLs
	targetprefix "" -- No prefix please!
filter {}

-- Always have libjpeg, libpng, zlib and the configs in the include paths
includedirs {
	"Thirdparty/libjpeg-turbo", "Thirdparty/libpng", "Thirdparty/zlib", "Thirdparty/configs"
}

-- Project definitions --------------------------------------------------------

zlib_public = {
	"Thirdparty/zlib/zconf.h",
	"Thirdparty/zlib/zlib.h"
}

zlib_sources = {
	"Thirdparty/zlib/adler32.c",
	"Thirdparty/zlib/compress.c",
	"Thirdparty/zlib/crc32.c",
	"Thirdparty/zlib/crc32.h",
	"Thirdparty/zlib/deflate.c",
	"Thirdparty/zlib/deflate.h",
	"Thirdparty/zlib/gzclose.c",
	"Thirdparty/zlib/gzguts.h",
	"Thirdparty/zlib/gzlib.c",
	"Thirdparty/zlib/gzread.c",
	"Thirdparty/zlib/gzwrite.c",
	"Thirdparty/zlib/infback.c",
	"Thirdparty/zlib/inffast.c",
	"Thirdparty/zlib/inffast.h",
	"Thirdparty/zlib/inffixed.h",
	"Thirdparty/zlib/inflate.c",
	"Thirdparty/zlib/inflate.h",
	"Thirdparty/zlib/inftrees.c",
	"Thirdparty/zlib/inftrees.h",
	"Thirdparty/zlib/trees.c",
	"Thirdparty/zlib/trees.h",
	"Thirdparty/zlib/uncompr.c",
	"Thirdparty/zlib/zutil.c",
	"Thirdparty/zlib/zutil.h"
}

project "zlib"
	kind "StaticLib"
	targetname "zlib"
	language "C"

	disablewarnings { "4267", "4244" }
	
	vpaths { ["code"] = "*" }

	files {
		zlib_public,
		zlib_sources
	}

libpng_public = {
	"Thirdparty/libpng/png.h",
	"Thirdparty/libpng/pngconf.h"
}

libpng_sources = {
	"Thirdparty/libpng/png.c",
	"Thirdparty/libpng/pngpriv.h",
	"Thirdparty/libpng/pngstruct.h",
	"Thirdparty/libpng/pnginfo.h",
	"Thirdparty/libpng/pngdebug.h",
	"Thirdparty/libpng/pngerror.c",
	"Thirdparty/libpng/pngget.c",
	"Thirdparty/libpng/pngmem.c",
	"Thirdparty/libpng/pngpread.c",
	"Thirdparty/libpng/pngread.c",
	"Thirdparty/libpng/pngrio.c",
	"Thirdparty/libpng/pngrtran.c",
	"Thirdparty/libpng/pngrutil.c",
	"Thirdparty/libpng/pngset.c",
	"Thirdparty/libpng/pngtrans.c",
	"Thirdparty/libpng/pngwio.c",
	"Thirdparty/libpng/pngwrite.c",
	"Thirdparty/libpng/pngwtran.c",
	"Thirdparty/libpng/pngwutil.c"
}

project "libpng"
	kind "StaticLib"
	targetname "libpng"
	language "C"

	vpaths { ["code"] = "*" }

	files {
		libpng_public,
		libpng_sources,

		"thirdparty/libpng/pnglibconf.h"
	}

libjpeg_public = {
	"Thirdparty/libjpeg-turbo/jpeglib.h",
	"Thirdparty/libjpeg-turbo/jconfig.h",
	"Thirdparty/libjpeg-turbo/jconfigint.h",
}

libjpeg_sources = {
	"Thirdparty/libjpeg-turbo/jcapimin.c",
	"Thirdparty/libjpeg-turbo/jcapistd.c",
	"Thirdparty/libjpeg-turbo/jccoefct.c",
	"Thirdparty/libjpeg-turbo/jccolor.c",
	"Thirdparty/libjpeg-turbo/jcdctmgr.c",
	"Thirdparty/libjpeg-turbo/jchuff.c",
	"Thirdparty/libjpeg-turbo/jcicc.c",
	"Thirdparty/libjpeg-turbo/jcinit.c",
	"Thirdparty/libjpeg-turbo/jcmainct.c",
	"Thirdparty/libjpeg-turbo/jcmarker.c",
	"Thirdparty/libjpeg-turbo/jcmaster.c",
	"Thirdparty/libjpeg-turbo/jcomapi.c",
	"Thirdparty/libjpeg-turbo/jcparam.c",
	"Thirdparty/libjpeg-turbo/jcphuff.c",
	"Thirdparty/libjpeg-turbo/jcprepct.c",
	"Thirdparty/libjpeg-turbo/jcsample.c",
	"Thirdparty/libjpeg-turbo/jctrans.c",
	"Thirdparty/libjpeg-turbo/jdapimin.c",
	"Thirdparty/libjpeg-turbo/jdapistd.c",
	"Thirdparty/libjpeg-turbo/jdatadst.c",
	"Thirdparty/libjpeg-turbo/jdatasrc.c",
	"Thirdparty/libjpeg-turbo/jdcoefct.c",
	"Thirdparty/libjpeg-turbo/jdcolor.c",
	"Thirdparty/libjpeg-turbo/jddctmgr.c",
	"Thirdparty/libjpeg-turbo/jdhuff.c",
	"Thirdparty/libjpeg-turbo/jdicc.c",
	"Thirdparty/libjpeg-turbo/jdinput.c",
	"Thirdparty/libjpeg-turbo/jdmainct.c",
	"Thirdparty/libjpeg-turbo/jdmarker.c",
	"Thirdparty/libjpeg-turbo/jdmaster.c",
	"Thirdparty/libjpeg-turbo/jdmerge.c",
	"Thirdparty/libjpeg-turbo/jdphuff.c",
	"Thirdparty/libjpeg-turbo/jdpostct.c",
	"Thirdparty/libjpeg-turbo/jdsample.c",
	"Thirdparty/libjpeg-turbo/jdtrans.c",
	"Thirdparty/libjpeg-turbo/jerror.c",
	"Thirdparty/libjpeg-turbo/jfdctflt.c",
	"Thirdparty/libjpeg-turbo/jfdctfst.c",
	"Thirdparty/libjpeg-turbo/jfdctint.c",
	"Thirdparty/libjpeg-turbo/jidctflt.c",
	"Thirdparty/libjpeg-turbo/jidctfst.c",
	"Thirdparty/libjpeg-turbo/jidctint.c",
	"Thirdparty/libjpeg-turbo/jidctred.c",
	"Thirdparty/libjpeg-turbo/jquant1.c",
	"Thirdparty/libjpeg-turbo/jquant2.c",
	"Thirdparty/libjpeg-turbo/jutils.c",
	"Thirdparty/libjpeg-turbo/jmemmgr.c",
	"Thirdparty/libjpeg-turbo/jmemnobs.c",
	"Thirdparty/libjpeg-turbo/jaricom.c",
	"Thirdparty/libjpeg-turbo/jcarith.c",
	"Thirdparty/libjpeg-turbo/jdarith.c",
	"Thirdparty/libjpeg-turbo/jsimd_none.c"
}

project "libjpeg-turbo"
	kind "StaticLib"
	targetname "libjpeg-turbo"
	language "C"
	
	vpaths { ["code"] = "*" }

	files {
		libjpeg_public,
		libjpeg_sources,
	}

project "Wally"
	kind "WindowedApp"
	language "C++"
	targetname "Wally"
	targetdir "Output"
	debugdir "Output"
	defines { "_WALLY" }
	flags { "MFC" }
	links { "winmm", "zlib", "libpng", "libjpeg-turbo" }
	conformancemode "Off"
	
	-- Warnings to ignore if doing a w4 run
	--disablewarnings { "4244", "4456", "4100", "4324" }
	
	pchsource( "Stdafx.cpp" )
	pchheader( "Stdafx.h" )
	--filter( "files:not ../worldcraft/worldcraft/**" )
		--flags( { "NoPCH" } )
	--filter( {} )
	
	vpaths { ["Header Files"] = "*.h" }
	vpaths { ["Source Files"] = "*.cpp" }
	
	files {
		"Wally.rc",
		"wally.rc2",
		"Wally.manifest",
	
		"*.cpp",
		"*.h"
	}
	
	removefiles {
		"Wally.aps",
		
		"BrowseDIBList.cpp",
		"BrowseDlg.cpp",
		"BrowseDocument.cpp",
		"COleDataSourceEX.cpp",
		"DIBToDocHelper.cpp",
		"HalfLifePaletteWnd.cpp",
		"NewWalDlg.cpp",
		"Package2ChildFrm.cpp",
		"Package2Doc.cpp",
		"Package2FormListBox.cpp",
		"Package2FormView.cpp",
		"Package2ScrollView.cpp",
		"PakListCtrl.cpp",
		"PcxHelper.cpp",
		"PropertyPage5_1.cpp",
		"test_delete.cpp",
		"ThreadItem.cpp",
		"ThreadList.cpp",
		"ThreadSpooler.cpp",
		"WAD2List.cpp",
		"WAD3List.cpp",
		"WallyOptions.cpp",
	}

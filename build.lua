#!/usr/bin/env lua

---------------
-- Utilities --
---------------

local common = require "build_tools.lua.common"

local repository = "https://github.com/sonicretro/s2disasm"

-- Just a shim for backwards-compatibility with things like Vladikcomper's debugger.
-- TODO: Remove this when nothing uses it any more.
local function message_abort_wrapper(message_printed, abort)
	common.handle_failure(message_printed, abort)
end

-- Produce PCM and DPCM data.
common.convert_pcm_files_in_directory("sound/PCM")
common.convert_dpcm_files_in_directory("sound/DAC")

-- Build the ROM.
common.build_rom_and_handle_failure("s2", "s2built", "", "-p=0 -z=0," .. "kosinskiplus" .. ",Size_of_Snd_driver_guess,after", true, repository)

-- Remove the header file, since we no longer need it.
os.remove("s2.h")

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("s2built.bin")

-- A successful build; we can quit now.
common.exit()

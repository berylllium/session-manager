local session_manager = {}

-- Config.
local config = {
	defaults = {
		session_path = ".nvim/Session.vim",
		autocmd_load_ignore_filetypes = {
			"gitcommit",
			"gitrebase"
		},
		save_session_if_not_exist = false,
		load_session_if_exist = true
	}
}

-- Local functions.
local is_windows = (function()
    if jit then
        local os = string.lower(jit.os)
        return os == "windows"
    else
        return "\\" == package.config:sub(1, 1)
    end
end)()

local path_sep = (function()
    if is_windows then
        return "\\"
    else
        return "/"
    end
end)()

local function slice(tbl, s, e)
	return { unpack(tbl, s, e) }
end

local function split_path(path)
    local parts = vim.split(path, path_sep)

    -- Only a file name given.
    if #parts == 1 then
        return nil, parts[1]
    end

    -- Return directory and file name.
    local dir = vim.fn.join(slice(parts, 1, #parts - 1), path_sep)
    local name = parts[#parts]

    return dir, name
end

local function ensure_path_is_safe(path)
	local s = ""

	if is_windows then
		s = path:gsub("/", path_sep)
	else
		s = path:gsub("\\", path_sep)
	end

	return s
end

local function ensure_session_path()
	local dir, _ = split_path(config.session_path)

	if dir and vim.fn.isdirectory(dir) == 0 then
		if vim.fn.mkdir(dir, "p") == 0 then
			return false
		end
	end
end

local function get_session_path()
	return ensure_path_is_safe(config.session_path)
end

local function autocmd_save_session()
	if vim.fn.filereadable(get_session_path()) == 1 then
		session_manager.save_session()
	end
end

local function autocmd_load_session()
	local opened_with_args = next(vim.fn.argv()) ~= nil
	local reading_from_stdin = vim.g.in_pager_mode == 1

	if not opened_with_args and not reading_from_stdin then
		session_manager.load_session()
	end
end

-- Plugin exported functions.
function session_manager.setup(conf)
	setmetatable(
		config,
		{ __index = vim.tbl_extend("force", config.defaults, conf) }
	)

	local augroup = vim.api.nvim_create_augroup("session-manager", {})

	vim.api.nvim_create_autocmd(
		{ "VimLeavePre" },
		{
			group = augroup,
			pattern = "*",
			callback = autocmd_save_session
		}
	)

	vim.api.nvim_create_autocmd(
		{ "VimEnter" },
		{
			group = augroup,
			pattern = "*",
			callback = autocmd_load_session
		}
	)

	vim.cmd([[
		command! SessionManagerSave lua require("session-manager").save_session()
	]])
end

function session_manager.save_session()
	ensure_session_path()

	vim.cmd(string.format("mksession %s", get_session_path()))
end

function session_manager.load_session()
	if vim.fn.filereadable(get_session_path()) == 0 then
		--vim.notify(string.format("session-banager: file `%s` does not exist.", get_session_path()))
		return false
	end

	vim.cmd(string.format("silent! source %s", get_session_path()))
end


return session_manager

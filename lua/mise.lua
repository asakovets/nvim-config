-- Based on https://github.com/ejrichards/mise.nvim

local Mise = {}

local log = {}

function log.info (message)
    vim.notify ("mise.nvim: " .. message, vim.log.levels.INFO, { title = "mise.nvim" })
end

function log.warn (message)
    vim.notify ("mise.nvim: " .. message, vim.log.levels.WARN, { title = "mise.nvim" })
end

function log.error (message)
    vim.notify ("mise.nvim: " .. message, vim.log.levels.ERROR, { title = "mise.nvim" })
end

---@class MiseConfig
local defaults = {
    run = "mise",
    args = "env --json",
    initial_path = vim.env.PATH,
    unset_vars = true,
    load_on_setup = true,
    force_run = false,
    change_dir_flag = "--cd",
}

---@type MiseConfig
local options

local previous_vars = {}

---@param data table
local function set_previous (data)
    previous_vars = {}
    for var_name, var_value in pairs (data) do
        previous_vars[var_name] = var_value
    end
end

local function get_previous ()
    return previous_vars
end

---@return table?
local function get_data (opts)
    opts = opts or {}
    local full_command = options.run .. " " .. options.args
    if opts.cwd then
        full_command = full_command .. " " .. options.change_dir_flag .. " " .. opts.cwd
    end

    local env_sh = vim.fn.system (full_command)

    -- mise will print out warnings: "mise WARN" without the "--quiet" flag
    if string.find (env_sh, "^mise") then
        local first_line = string.match (env_sh, "^[^\n]*")
        log.error (first_line)
        return nil
    end

    local ok, data = pcall (vim.json.decode, env_sh)
    if not ok or data == nil then
        log.error ('Invalid json returned by "' .. full_command .. '"')
        return nil
    end

    return data
end

---@param data table
local function load_env (data, previous_data)
    for var_name, _ in pairs (previous_data) do
        vim.env[var_name] = nil
    end

    for var_name, var_value in pairs (data) do
        vim.env[var_name] = var_value
    end
end

local function buf_is_regular (buf)
    if vim.bo[buf].buftype ~= "" then
        return false
    end

    if vim.api.nvim_buf_get_name (buf) == "" then
        return false
    end

    return true
end

local CFG_ENV = "mise--env-cfg"

local function buf_get_cfg_env (buf)
    local ok, data = pcall (vim.api.nvim_buf_get_var, buf, CFG_ENV)
    if ok then
        return data
    end

    return {}
end

local function buf_set_cfg_env (buf, env)
    vim.api.nvim_buf_set_var (buf, CFG_ENV, env or {})
end

local function buf_update_cfg_env (buf)
    if not buf_is_regular (buf) then
        return
    end

    local file = vim.api.nvim_buf_get_name (buf)
    local parent_dir = vim.fn.fnamemodify (file, ":h")

    local data = get_data ({ cwd = parent_dir })
    if data.Path then
        data.PATH = data.Path
        data.Path = nil
    end

    buf_set_cfg_env (buf, data or {})
end

local function buf_on_enter (buf)
    if not buf_is_regular (buf) then
        return
    end

    local prev = {}
    local cfg = buf_get_cfg_env (buf)
    for k, _ in pairs (cfg) do
        prev[k] = vim.env[k]
    end

    local file = vim.api.nvim_buf_get_name (buf)

    set_previous (prev)
    load_env (cfg, {})
end

local function buf_on_leave (buf)
    if not buf_is_regular (buf) then
        return
    end

    local file = vim.api.nvim_buf_get_name (buf)

    cfg = buf_get_cfg_env (buf)

    load_env (get_previous (), cfg)
    set_previous ({})

    -- vim.env.PATH = initial_path
end

local function mise_reload_env ()
    buf_on_leave (0)

    for _, bufnr in ipairs (vim.api.nvim_list_bufs ()) do
        if vim.fn.buflisted (bufnr) == 1 then
            buf_update_cfg_env (bufnr)
        end
    end

    buf_on_enter (0)
end

---@param opt? MiseConfig
function Mise.setup (opt)
    options = vim.tbl_deep_extend ("force", {}, defaults, opt or {})

    if vim.fn.executable (options.run) ~= 1 then
        log.error ('Cannot find "' .. options.run .. '" executable')
        return
    end

    if options.run ~= "mise" and not options.force_run then
        log.error (options.run .. ' not supported, set "force_run = true" in setup() if you know the data is correct.')
        return
    end

    vim.api.nvim_create_autocmd ("BufReadPost", {
        pattern = "*",
        callback = function (e)
            buf_update_cfg_env (e.buf)
        end,
    })

    vim.api.nvim_create_autocmd ("BufEnter", {
        pattern = "*",
        callback = function (e)
            buf_on_enter (e.buf)
        end,
    })

    vim.api.nvim_create_autocmd ("BufLeave", {
        pattern = "*",
        callback = function (e)
            buf_on_leave (e.buf)
        end,
    })

    vim.api.nvim_create_user_command ("MiseReloadEnv", function ()
        mise_reload_env ()
    end, { desc = "Reload mise env and update vim.env variables" })

    vim.api.nvim_create_user_command ("Mise", function (opts)
        local bufdir = require ("util").bufdir (0)

        -- stylua: ignore start
        local full_command = (
            options.run
            ..  " " .. options.change_dir_flag
            ..  " " .. bufdir
            ..  " " .. opts.args
        )
        -- stylua: ignore end

        print (vim.fn.system (full_command))
    end, { nargs = "*" })
end

return Mise

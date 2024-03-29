local api = vim.api
local M = {}
local author
local email

local function get_git_author()
    local cmd = "git config --get user.name"
    local git_author = vim.fn.system(cmd)
    git_author = git_author:gsub("%s+", "")
    return git_author
end

local function get_git_email()
    local cmd = "git config --get user.email"
    local git_email = vim.fn.system(cmd)
    git_email = git_email:gsub("%s+", "")
    return git_email
end

local function default_filetype_comment()
    M.head_comment = "/*"
    M.tail_comment = "*/"
end

-- stylua: ignore start
local filetype_swich = {
    go          = default_filetype_comment,
    javascript  = default_filetype_comment,
    typescript  = default_filetype_comment,
    java        = default_filetype_comment,
    c           = default_filetype_comment,
    cpp         = default_filetype_comment,

    python = function()
        M.head_comment = "'''"
        M.tail_comment = "'''"
    end,

    lua = function()
        M.head_comment = "--"
        M.tail_comment = "--"
    end,
}
-- stylua: ignore end

function M.set_lines(start_line, end_line, lines)
    api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end

function M.add_header()
    local filetype = vim.bo.filetype
    filetype_swich[filetype]()

    local lines = {
        M.head_comment,
        string.format("@Time: %s", os.date("%Y-%m-%d %H:%M:%S")),
        string.format("@File: %s", vim.fn.expand("%")),
        string.format("@Author: %s", author),
        string.format("@Email: %s", email),
        M.tail_comment,
    }

    M.set_lines(0, 0, lines)
end

local function setup_commands()
    api.nvim_command('command! SetHeader lua require("nvim-header").add_header()')
end

function M.setup(config)
    config = config or {}
    author = config.author or vim.g.nvim_header_author or get_git_author()
    email = config.email or vim.g.nvim_header_email or get_git_email()

    setup_commands()
end

return M

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                library = {
                    { path = "luvit-meta/library", words = { "vim%.uv" } },
                },
            },
        },
        "Bilal2453/luvit-meta",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "smiteshp/nvim-navic",
    },
    config = function()
        local mason_registry = require("mason-registry")
        require("lspconfig.ui.windows").default_options.border = "rounded"

        -- Diagnostics
        vim.diagnostic.config({
            signs = true,
            underline = true,
            update_in_insert = true,
            virtual_text = {
                source = "if_many",
                prefix = "●",
            },
        })

        -- Run setup for no_config_servers
        local no_config_servers = {
            "docker_compose_language_service",
            "dockerls",
            "html",
            "jsonls",
            "tailwindcss",
            --"taplo",
            --"yamlls",
        }
        for _, server in pairs(no_config_servers) do
            require("lspconfig")[server].setup({})
        end

        -- Go
        require("lspconfig").gopls.setup({
            settings = {
                gopls = {
                    completeUnimported = true,
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                },
            },
        })

        -- Templ
        --require("lspconfig").templ.setup({})
        --vim.filetype.add({
        --    extension = {
        --        templ = "templ",
        --    },
        --})

        -- Bicep
        --local bicep_path = vim.fn.stdpath("data") .. "/mason/packages/bicep-lsp/bicep-lsp.cmd"
        --require("lspconfig").bicep.setup({
        --    cmd = { bicep_path },
        --})
        --vim.filetype.add({
        --    extension = {
        --        bicepparam = "bicep",
        --    },
        --})

        -- C#
        local omnisharp_path = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/omnisharp.dll"
        require("lspconfig").omnisharp.setup({
            cmd = { "dotnet", omnisharp_path },
            enable_ms_build_load_projects_on_demand = true,
        })

        -- Lua
        require("lspconfig").lua_ls.setup({
            on_init = function(client)
                local path = client.workspace_folders[1].name
                if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
                    client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                        },
                    })

                    client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                end
                return true
            end,
        })

        -- PowerShell
        --local bundle_path = mason_registry.get_package("powershell-editor-services"):get_install_path()
        --require("lspconfig").powershell_es.setup({
        --    bundle_path = bundle_path,
        --})
    end,
}

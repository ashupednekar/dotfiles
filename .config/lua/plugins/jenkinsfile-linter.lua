-- lua/plugins/jenkinsfile-linter.lua
return {
  "ckipp01/nvim-jenkinsfile-linter",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufWritePost Jenkinsfile*" }, -- lazy-load for any Jenkinsfile variant
  config = function()
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "Jenkinsfile*",
      callback = function()
        vim.cmd("JenkinsfileLint")
      end,
    })
  end,
}


# Neovim Jupyter Notebooks

This flake contains the Neovim configuration for Jupyter notebooks, which includes the following features:

- **Jupyter Kernel Management**: Automatically detects and manages Jupyter kernels.
- **Markdown Support**: Provides syntax highlighting and rendering for Markdown cells.
- **Code Execution**: Execute code cells and display output inline.

To run the configuration, execute the following command:

```bash
nix develop
```
This will open a bash shell with access to a Neovim environment that has the necessary dependencies installed.

----
### 2 important notes
1. Once you initally install the nvim config, it will give an error regarding the lazy lock - this is normal. It is read only in the Nix store.
2. If the Molten plugin doesn't initially load, run `:UpdateRemotePlugins` in the nvim editor and reboot it. 

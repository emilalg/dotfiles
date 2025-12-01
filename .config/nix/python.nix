# python-data-science.nix
# 
# This module can be imported in your home-manager or nix-darwin configuration
# to provide a global Python 3.12 environment with data science packages
#
# Usage in home-manager:
#   imports = [ ./python-data-science.nix ];
#
# Or include the relevant parts directly in your home.nix or darwin-configuration.nix

{ config, pkgs, lib, ... }:

let
  # Define Python 3.12 with all data science packages
  # Optimized for Apple Silicon (M1/M2/M3)
  pythonDataScience = pkgs.python312.withPackages (ps: with ps; [

    uv

    # Core scientific computing
    numpy
    scipy
    pandas
    
    # Visualization
    matplotlib
    seaborn
    plotly
    bokeh
    
    # Machine Learning
    scikit-learn
    
    # Deep Learning
    # Note: On Apple Silicon, these will use CPU or Metal Performance Shaders (MPS) when available
    torch         # PyTorch with MPS support on macOS
    torchvision
    torchaudio
    jax           # JAX can use Metal on macOS
    jaxlib        
    flax
    optax         # Optimization library for JAX
    
    # Jupyter ecosystem
    jupyter
    jupyterlab
    notebook
    ipykernel
    ipywidgets
    nbconvert
    nbformat
    jupyterlab-widgets
    jupyterlab-pygments
    
    # Data handling
    sqlalchemy    # SQL toolkit
    
    # Image processing
    pillow
    opencv4       # Computer vision
    imageio       # Image I/O
    
    # Utilities
    tqdm
    rich          # Rich terminal formatting
    click         # Command line interface creation
    python-dotenv # .env file support
    pyyaml        # YAML support
    toml          # TOML support

    
    # Development tools
    ipython
    ipympl
    ipdb          # IPython debugger
    pytest        # Testing
    black         # Code formatter
    
    # Web and API
    requests
    httpx         # Modern HTTP client
    beautifulsoup4
    lxml
    fastapi       # Modern web framework
    uvicorn       # ASGI server
    
    # Additional scientific packages
    statsmodels   # Statistical modeling
    sympy         # Symbolic mathematics
    networkx      # Network analysis
    
    # Package management
    pip
    setuptools
    wheel
  ]);

in
{
  # Environment variables
  home.sessionVariables = {
    # Set Python environment
    PYTHONPATH = "${pythonDataScience}/${pythonDataScience.sitePackages}";
    
    # Jupyter configuration
    JUPYTER_ENABLE_LAB = "yes";
    JUPYTER_PATH = "$HOME/.local/share/jupyter";
    JUPYTER_CONFIG_DIR = "$HOME/.jupyter";
    JUPYTERLAB_DIR = "$HOME/.jupyter/lab";
    
    # Enable JAX 64-bit mode
    JAX_ENABLE_X64 = "1";
    
    # PyTorch settings for Apple Silicon
    PYTORCH_ENABLE_MPS_FALLBACK = "1";  # Fallback for unsupported MPS operations
    
    # Matplotlib backend
    #MPLBACKEND = "Agg";  # Native macOS backend
  };

  # Shell aliases for convenience
  home.shellAliases = {
    python = "${pythonDataScience}/bin/python";
    ipy = "${pythonDataScience}/bin/ipython";
    jlab = "${pythonDataScience}/bin/jupyter-lab";
  };

  # Create Jupyter configuration
  home.file.".jupyter/jupyter_lab_config.py".text = ''
    c = get_config()
    
    # Server settings
    c.ServerApp.ip = '127.0.0.1'
    c.ServerApp.port = 8888
    c.ServerApp.open_browser = True
    
    # Security settings for local use
    c.ServerApp.token = ""  # No token for local use
    c.ServerApp.password = ""  # No password for local use
    
    # Enable extensions
    c.LabApp.extensions_in_dev_mode = True
    
    # Notebook settings
    c.NotebookApp.notebook_dir = '~/Documents/notebooks'
    
    # Terminal settings for macOS
    c.ServerApp.terminado_settings = {'shell_command': ['${pkgs.zsh}/bin/zsh']}
  '';

  # Create a default kernel spec for Jupyter
  home.file.".local/share/jupyter/kernels/python3-data-science/kernel.json".text = builtins.toJSON {
    display_name = "Python 3.12 (Data Science)";
    language = "python";
    argv = [
      "${pythonDataScience}/bin/python"
      "-m"
      "ipykernel_launcher"
      "-f"
      "{connection_file}"
    ];
    metadata = {
      debugger = true;
    };
    env = {
      PYTHONPATH = "${pythonDataScience}/${pythonDataScience.sitePackages}";
    };
  };
}
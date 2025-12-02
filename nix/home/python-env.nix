{ config, pkgs, lib, ... }:

let
  # Define the Python Bundle
  pythonDataScience = pkgs.python312.withPackages (ps: with ps; [
    uv
    pip
    numpy
    scipy
    pandas
    matplotlib
    seaborn
    scikit-learn
    ipykernel


    # Conditional packages based on OS (Optional refinement)
    # On Linux/WSL, we might want CUDA support, on Mac we want MPS.
    # For now, we install the standard torch/jax.
    # Nix handles the backend logic mostly automatically.
    torch
    torchvision
    jax
    jaxlib
    flax
    flaxlib
    transformers
    datasets
    diffusers
    accelerate
    einops
    tokenizers


    # scraping
    beautifulsoup4
    curl-cffi
    httpx


    # Tools
    jupyter
    jupyterlab
    notebook
    ipython
    black
    requests
    fastapi
    uvicorn

    # Misc
    pillow
    click

  ]);

  isDarwin = pkgs.stdenv.isDarwin;
in
{
  home.packages = [ pythonDataScience ];

  home.sessionVariables = {
    # 1. Common Variables (Mac + WSL)
    TF_CPP_MIN_LOG_LEVEL = "2";
    JUPYTER_PATH = "${config.home.homeDirectory}/.local/share/jupyter";
    JAX_ENABLE_X64 = "1";
  } // lib.optionalAttrs isDarwin {
    # 2. Mac-Only Variables (Merged in only if on Mac)
    PYTORCH_ENABLE_MPS_FALLBACK = "1";

  };

  home.shellAliases = {
    python = "${pythonDataScience}/bin/python";
    ipy = "${pythonDataScience}/bin/ipython";
    jlab = "${pythonDataScience}/bin/jupyter-lab";
  };

  # Jupyter Config (Simplified for robustness)
  home.file.".jupyter/jupyter_lab_config.py".text = ''
    c = get_config()
    c.ServerApp.ip = '127.0.0.1'
    c.ServerApp.open_browser = False # Better for WSL/Headless
    c.ServerApp.token = ""
    c.ServerApp.password = ""
  '';
}

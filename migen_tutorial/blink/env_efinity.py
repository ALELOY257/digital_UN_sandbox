# env_efinity.py
import os

EFINITY_PATH = "/Work/CAD/efinity/2024.2"

os.environ["LITEX_ENV_EFINITY"] = EFINITY_PATH
os.environ["EFINITY_HOME"]      = EFINITY_PATH + "/"
os.environ["EFXPGM_HOME"]       = EFINITY_PATH + "/pgm/"
os.environ["EFXDBG_HOME"]       = EFINITY_PATH + "/debugger"
os.environ["EFXPT_HOME"]        = EFINITY_PATH + "/pt"
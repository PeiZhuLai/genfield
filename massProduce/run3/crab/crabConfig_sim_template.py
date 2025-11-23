from CRABClient.UserUtilities import config
import os

config = config()

# ===== 從環境變數讀取設定（由 4_sub_crab_sim.sh 提供） =====
era       = os.getenv("ERA")
era_alias = os.getenv("ERA_ALIAS", era)
year_tag  = os.getenv("YEAR_TAG", "")
mass      = os.getenv("MASS")
fraction  = os.getenv("FRACTION")
step      = os.getenv("STEP", "SIM")

# 1_sim_fragment_* 的完整路徑
pset_path = os.getenv("CFG_PATH")
# 對應輸出的邏輯目錄（只是用來組 outLFN；實際檔名由 cfg 本身決定）
out_base_dir = os.getenv("OUT_DIR")

if not all([era, mass, fraction, pset_path, out_base_dir]):
    raise RuntimeError("Missing required environment variables: ERA/MASS/FRACTION/CFG_PATH/OUT_DIR")

if not os.path.isfile(pset_path):
    raise RuntimeError(f"pset cfg not found: {pset_path}")

# ===== General =====
config.General.workArea = f"crab_HZa_{era}_{step}"
config.General.transferOutputs = True
config.General.transferLogs = True

config.General.requestName = f"HZa_{step}_{era}_M{mass}_frac{fraction}"

# ===== JobType =====
config.JobType.pluginName = "Analysis"
config.JobType.psetName   = pset_path
config.JobType.allowUndistributedCMSSW = True
config.JobType.inputFiles = []
# config.JobType.maxMemoryMB = 2500
# config.JobType.maxJobRuntimeMin = 2750

# ===== Data（PrivateMC）=====
config.Data.inputDBS = "global"
config.Data.splitting = "EventBased"
config.Data.unitsPerJob = 100
config.Data.totalUnits  = 10000

config.Data.outputPrimaryDataset = "HZaTo2l2g_sim"
config.Data.publication = False

username = os.getenv("USER", "pelai")

# outLFNDirBase：沿用你在 shell 裡的 OUT_DIR 結構，轉成 /store/user/... 下面的層級
# 例如 OUT_DIR=/eos/home-p/.../HZaTo2l2g/SIM/M1/2023preBPix
# 就對應到 /store/user/<user>/HZaTo2l2g/SIM/M1/2023preBPix/
rel_out_dir = out_base_dir.split("/eos/")[-1] if "/eos/" in out_base_dir else out_base_dir
config.Data.outLFNDirBase = f"/store/user/{username}/{rel_out_dir.strip('/')}"

# ===== Site =====
config.Site.storageSite = "T2_CN_Beijing"
config.Site.whitelist = ["T2_CN_Beijing"]

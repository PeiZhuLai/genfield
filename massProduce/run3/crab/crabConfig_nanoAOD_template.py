from CRABClient.UserUtilities import config
import os

config = config()

# ===== 從環境變數讀取設定（由 8_sub_crab_nanoAOD.sh 提供） =====
era       = os.getenv("ERA")
era_alias = os.getenv("ERA_ALIAS", era)
year_tag  = os.getenv("YEAR_TAG", "")
mass      = os.getenv("MASS")
fraction  = os.getenv("FRACTION")
step      = os.getenv("STEP", "NANOAOD")

pset_path    = os.getenv("CFG_PATH")
out_base_dir = os.getenv("OUT_DIR")

# 新增：miniAOD 的輸入 dataset（由 miniAOD CRAB 產生、已 publication 的 USER dataset）
# SIM --> DIGI --> AOD --> miniAOD --> nanoAOD (本檔)
miniaod_dataset  = os.getenv("MINIAOD_DATASET")           # e.g. /HZaTo2l2g_miniAOD/pelai-HZa_miniAOD_.../USER
miniaod_inputDBS = os.getenv("MINIAOD_INPUT_DBS", "phys03")

if not all([era, mass, fraction, pset_path, out_base_dir, miniaod_dataset]):
    raise RuntimeError(
        "Missing required environment variables: ERA/MASS/FRACTION/CFG_PATH/OUT_DIR/MINIAOD_DATASET"
    )

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

# ===== Data（使用 miniAOD 的輸出 ROOT 檔）=====
# 從 miniAOD 的 USER dataset 讀檔
config.Data.inputDataset = miniaod_dataset
config.Data.inputDBS     = miniaod_inputDBS

# 同 miniAOD：以檔案為單位分割 job
config.Data.splitting   = "FileBased"
config.Data.unitsPerJob = 1          # 每個 job 處理 1 個 miniAOD root file，可視情況調整
config.Data.totalUnits  = -1         # 讓 CRAB 自動根據 dataset 決定

config.Data.outputPrimaryDataset = "HZaTo2l2g_nanoAOD"
config.Data.publication = True

username = os.getenv("USER", "pelai")

# outLFNDirBase：沿用 OUT_DIR 結構，轉成 /store/user/... 下面的層級
rel_out_dir = out_base_dir.split("/eos/")[-1] if "/eos/" in out_base_dir else out_base_dir
config.Data.outLFNDirBase = f"/store/user/{username}/{rel_out_dir.strip('/')}"

# ===== Site =====
config.Site.storageSite = "T2_CN_Beijing"

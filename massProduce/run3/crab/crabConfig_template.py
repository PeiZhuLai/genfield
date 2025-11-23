from CRABClient.UserUtilities import config
import os

config = config()

# ===== 從環境變數讀取基本設定 =====
era        = os.getenv("ERA")
era_alias  = os.getenv("ERA_ALIAS", era)
year_tag   = os.getenv("YEAR_TAG", "")
mass       = os.getenv("MASS")
fraction   = os.getenv("FRACTION")

cfg_base_124 = os.getenv("CFG_BASE_DIR_124")
cfg_base_130 = os.getenv("CFG_BASE_DIR_130")
out_base_dir = os.getenv("OUT_BASE_DIR")

if not all([era, mass, fraction, cfg_base_124, cfg_base_130, out_base_dir]):
    raise RuntimeError("Missing required environment variables: ERA/MASS/FRACTION/CFG_BASE_DIR_124/CFG_BASE_DIR_130/OUT_BASE_DIR")

# ===== 路徑約定（需與 3_prepareConfig_* 對應） =====
# cfg 目錄結構：
#   LHEGS/DRPremix/AOD: {CFG_BASE_DIR_124}/HZaTo2l2g_M{MASS}/fraction{FRACTION}/...
#   MiniAOD/Nano      : {CFG_BASE_DIR_130}/HZaTo2l2g_M{MASS}/fraction{FRACTION}/...
cfg_dir_130 = os.path.join(cfg_base_130, f"HZaTo2l2g_M{mass}", f"fraction{fraction}")

# 這個 template 目前選擇「直接執行 NanoAOD step」的 cfg。
# 如需 AOD / MiniAOD 的 CRAB，可以複製本檔，將 pset 與輸出路徑改成對應的 step。
pset_nano = os.path.join(
    cfg_dir_130,
    f"HIG-Run3Summer22NanoAODv12-00005_1_cfg_{fraction}.py"
)

if not os.path.isfile(pset_nano):
    raise RuntimeError(f"NanoAOD cfg not found: {pset_nano}")

# 輸出根目錄結構（實際 ROOT 檔名由 cfg 的 fileName 決定）：
#   AOD     : {OUT_BASE_DIR}/HZaTo2l2g/AOD/M{MASS}/{ERA}/...
#   MiniAOD : {OUT_BASE_DIR}/HZaTo2l2g/MINIAOD/M{MASS}/{ERA}/...
#   NanoAOD : {OUT_BASE_DIR}/HZaTo2l2g/NANOAOD/M{MASS}/{ERA}/...
# 本 template 專門給 NanoAOD 用，因此這裡只設 NANOAOD 的目錄。
sample_out_dir = os.path.join(out_base_dir, "HZaTo2l2g", "NANOAOD", f"M{mass}", era)

# ===== General 部分 =====
config.General.workArea = f"crab_HZa_{era}"
config.General.transferOutputs = True
config.General.transferLogs = True

config.General.requestName = f"HZa_NANO_{era}_M{mass}_frac{fraction}"

# ===== JobType 部分 =====
config.JobType.pluginName = "Analysis"
config.JobType.psetName   = pset_nano
config.JobType.allowUndistributedCMSSW = True

# 如需額外輸入檔（例如校正、JSON），可以放進 inputFiles
config.JobType.inputFiles = []
# 如需更多 memory/time 限制可以在這邊設：
# config.JobType.maxMemoryMB = 2500
# config.JobType.maxJobRuntimeMin = 2750

# ===== Data 部分（PrivateMC 模式） =====
config.Data.inputDBS = "global"
config.Data.splitting = "EventBased"
config.Data.unitsPerJob = 100
config.Data.totalUnits  = 10000  # 每個 mass / era / fraction 總共 10k events

config.Data.outputPrimaryDataset = "HZaTo2l2g"
config.Data.publication = False

# user 的 LFN base，例如 /store/user/<username>...
username = os.getenv("USER", "pelai")

# 將 NanoAOD 的 LFN 也對應到 NANOAOD 子目錄（與 sample_out_dir 層級一致）
config.Data.outLFNDirBase = (
    f"/store/user/{username}/HZa/"
    f"HZa_Zto2L_ato2G_M-{mass}_TuneCP5_13p6TeV_madgraph-pythia/"
    f"fraction{fraction}/{era}/NANOAOD/"
)

# ===== Site 部分 =====
config.Site.storageSite = "T2_CN_Beijing"
config.Site.whitelist = ["T2_CN_Beijing"]
# config.Site.blacklist = []

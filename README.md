# genfield

Since pileup Premix files are not fully storaged on the T2_CH_CERN, we have to get available files on the disks.

Details are on my thread: 
[CMS Talk Thread on Neutrino_E-10_gun Dataset Issue](https://cms-talk.web.cern.ch/t/cannot-access-dataset-neutrino-e-10-gun/125112)

```
python3 2_getfiles_ondisk.py -o fileslist_Neutrino_E-10_gun.txt -u pelai -v -a T2_CH_CERN -- "/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX"
```
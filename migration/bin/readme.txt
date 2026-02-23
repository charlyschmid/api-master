Migration
--------------------------------------------------------------------------------

batch_migration.bat

set environment variables                              %MIG_HOME%\bin\setenv.bat
Delete Log Files                                                 %MIG_HOME%\logs
Copy all Source Files                                 %MIG_BIN_DIR%\copy_all.bat
Prepare Migration Setup                               %MIG_BIN_DIR%\prep_all.bat
Migrate Source Files                                 %MIG_BIN_DIR%\migration.bat
Copy Migrated Files to Test-Directory           %MIG_BIN_DIR%\copy2testmig12.bat
Generate Compiler Script                           %MIG_BIN_DIR%\compiler12c.bat
Compile Files in Test-Directory                     %MIG_TEST12_DIR%\compile.bat

No Parameter Migration Mode = MIGRATE
Settings from config.ini are used

mig_olb=1
mig_pll=1
mig_mmb=1
mig_fmb=1
mig_ref=1

mig_olb_filter=*.olb
mig_pll_filter=*.pll
mig_mmb_filter=*.mmb
mig_fmb_filter=login60.fmb

Command Files in %MIG_HOME%\bin
--------------------------------------------------------------------------------
setenv.bat

copy_all.bat
copy_lot1.bat
copy_lot2.bat

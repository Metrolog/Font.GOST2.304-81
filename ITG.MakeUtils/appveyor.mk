ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_APPVEYOR_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifeq ($(APPVEYOR),True)

APPVEYORTOOL ?= appveyor

# $(call pushDeploymentArtifactFile, DeploymentName, Path)
pushDeploymentArtifactFile = for file in $2; do $(APPVEYORTOOL) PushArtifact $$file -DeploymentName '$(1)'; done

pushDeploymentArtifact = $(call pushDeploymentArtifactFile,$@,$^)

# $(call testPlatformWrapper,testId,testScript)
$(eval testPlatformWrapper = \
  $(call shellEncode,\
    powershell \
      -NoLogo \
      -NonInteractive \
      -Command & { \
        Update-AppveyorTest \
            -Name '$$1' \
            -Outcome 'Running' \
        ; \
        $$$$$$$$process = [System.Diagnostics.Process]::new(); \
        try { \
            $$$$$$$$process.StartInfo = [System.Diagnostics.ProcessStartInfo]::new($$$$$$$$env:ComSpec, '/C $$2'); \
            $$$$$$$$process.StartInfo.RedirectStandardOutput = $$$$$$$$true; \
            $$$$$$$$process.StartInfo.RedirectStandardError = $$$$$$$$true; \
            $$$$$$$$process.StartInfo.UseShellExecute = $$$$$$$$false; \
            $$$$$$$$process.StartInfo.WorkingDirectory = Get-Location; \
            Write-Verbose 'Run $$2'; \
            $$$$$$$$null = $$$$$$$$process.Start(); \
            $$$$$$$$process.WaitForExit(); \
            $$$$$$$$stdOut = $$$$$$$$process.StandardOutput.ReadToEnd(); \
            $$$$$$$$stdErr = $$$$$$$$process.StandardError.ReadToEnd(); \
            $$$$$$$$duration = $$$$$$$$process.ExitTime.Subtract( $$$$$$$$process.StartTime ); \
            if ( $$$$$$$$process.ExitCode -eq 0 ) { \
                Update-AppveyorTest \
                    -Name '$$1' \
                    -Outcome 'Passed' \
                    -Duration ( $$$$$$$$duration.Milliseconds ) \
                    -StdOut $$$$$$$$stdOut \
                    -StdErr $$$$$$$$stdErr \
                ; \
                Write-Output $$$$$$$$stdOut; \
            } else { \
                Update-AppveyorTest \
                    -Name '$$1' \
                    -Outcome 'Failed' \
                    -Duration ( $$$$$$$$duration.Milliseconds ) \
                    -StdOut $$$$$$$$stdOut \
                    -StdErr $$$$$$$$stdErr \
                ; \
                Write-Output $$$$$$$$stdOut; \
                Write-Error $$$$$$$$stdErr; \
            }; \
            exit( $$$$$$$$process.ExitCode ); \
        } finally { \
            $$$$$$$$process.Dispose(); \
        }; \
      } \
  ) \
)

else

pushDeploymentArtifactFile =
pushDeploymentArtifact =

endif

endif

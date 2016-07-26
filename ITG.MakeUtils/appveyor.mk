ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_APPVEYOR_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifeq ($(APPVEYOR),True)

APPVEYORTOOL ?= appveyor

# $(call pushDeploymentArtifactFile, DeploymentName, Path)
pushDeploymentArtifactFile = $(call shellEncode,\
  powershell \
    -NoLogo \
    -NonInteractive \
    -Command & { \
      $$$$ErrorActionPreference = 'Stop'; \
      @( $(foreach file,$(2),,'$(file)') ) \
      | Get-Item \
      | % { Push-AppveyorArtifact \
        $$$$_.FullName \
        -FileName $$$$_.Name \
        -DeploymentName '$(1)' \
      } \
    } \
  )

# $(call pushDeploymentArtifactFolder, DeploymentName, Path)
pushDeploymentArtifactFolder = $(call shellEncode,\
  powershell \
    -NoLogo \
    -NonInteractive \
    -Command & { \
      $$$$ErrorActionPreference = 'Stop'; \
      $$$$root = Resolve-Path '$(2)'; \
      [IO.Directory]::GetFiles($$$$root.Path, '*.*', 'AllDirectories') \
      | Get-Item \
      | % { Push-AppveyorArtifact \
        $$$$_.FullName -FileName \
        $$$$_.FullName.Substring($$$$root.Path.Length + 1) \
        -DeploymentName '$(1)' \
      } \
    } \
  )

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
pushDeploymentArtifactFolder =
pushDeploymentArtifact =

endif

endif

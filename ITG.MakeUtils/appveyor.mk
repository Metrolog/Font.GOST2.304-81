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
      $$ErrorActionPreference = 'Stop'; \
      @( $(foreach file,$(2),,'$(file)') ) \
      | Get-Item \
      | % { Push-AppveyorArtifact \
        $$_.FullName \
        -FileName $$_.Name \
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
      $$ErrorActionPreference = 'Stop'; \
      $$root = Resolve-Path '$(2)'; \
      [IO.Directory]::GetFiles($$root.Path, '*.*', 'AllDirectories') \
      | Get-Item \
      | % { Push-AppveyorArtifact \
        $$_.FullName -FileName \
        $$_.FullName.Substring($$root.Path.Length + 1) \
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
        $$$$$$$$ErrorActionPreference = 'Stop'; \
        function Execute-TestScript { \
            [CmdletBinding()] \
            param() \
            & $$2 \
        }; \
        $$$$$$$$sw = [Diagnostics.Stopwatch]::new(); \
        try { \
            Update-AppveyorTest \
                -Name '$$1' \
                -Outcome 'Running' \
            ; \
            $$$$$$$$sw.Start(); \
            Execute-TestScript \
                -ErrorAction 'Stop' \
                -OutVariable stdOutStr \
                -ErrorVariable stdErrStr \
            ; \
            $$$$$$$$sw.Stop(); \
            Update-AppveyorTest \
                -Name '$$1' \
                -Outcome 'Passed' \
                -Duration ( $$$$$$$$sw.Elapsed.Milliseconds ) \
                -StdOut $$$$$$$$stdOutStr \
            ; \
        } catch { \
            $$$$$$$$sw.Stop(); \
            Update-AppveyorTest \
                -Name '$$1' \
                -Outcome 'Failed' \
                -Duration ( $$$$$$$$sw.Elapsed.Milliseconds ) \
                -StdOut $$$$$$$$stdOutStr \
                -ErrorMessage ( $$$$$$$$_.Exception.Message ) \
                -StdErr $$$$$$$$stdErrStr \
            ; \
            throw; \
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

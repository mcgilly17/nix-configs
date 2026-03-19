# Registry tweaks module
# Each tweak is a toggleable option (defaults off). When enabled, generates a
# .reg file and registers it with windows.registryFiles for import via reg.exe.
# HKLM keys require elevation — failures are logged as warnings, not errors.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.windows.registry;

  # Helper to generate a .reg file from raw content
  mkReg =
    name: content:
    pkgs.writeText "${name}.reg" ''
      Windows Registry Editor Version 5.00

      ${content}
    '';
in
{
  options.windows.registry = {
    # ── UI / Appearance ──────────────────────────────────
    darkMode = lib.mkEnableOption "Force dark mode for apps and system";
    disableRoundedCorners = lib.mkEnableOption "Disable Windows 11 rounded corners via DWM";
    classicContextMenu = lib.mkEnableOption "Restore full right-click context menu";
    hideSearchBox = lib.mkEnableOption "Hide taskbar search box";
    hideTaskView = lib.mkEnableOption "Hide task view button";
    hideWidgets = lib.mkEnableOption "Hide widgets button";
    hideCopilot = lib.mkEnableOption "Hide Copilot button";

    # ── Privacy / Telemetry ──────────────────────────────
    disableTelemetry = lib.mkEnableOption "Disable Windows telemetry (needs elevation)";
    disableAdvertisingId = lib.mkEnableOption "Disable advertising ID tracking";
    disableCortana = lib.mkEnableOption "Disable Cortana (needs elevation)";
    disableSuggestedContent = lib.mkEnableOption "Disable Settings suggestions";
    disableTips = lib.mkEnableOption "Disable tips and recommendations";
    disableActivityHistory = lib.mkEnableOption "Disable activity history (needs elevation)";
    disableFeedback = lib.mkEnableOption "Disable feedback prompts";

    # ── Performance ──────────────────────────────────────
    disableTransparency = lib.mkEnableOption "Disable transparency effects";
    disableAnimations = lib.mkEnableOption "Disable window animations";
    disableStartupDelay = lib.mkEnableOption "Remove app startup delay";
  };

  config.windows.registryFiles = lib.mkMerge [
    # ── UI / Appearance ──────────────────────────────────

    (lib.mkIf cfg.darkMode {
      dark-mode = mkReg "dark-mode" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]
        "AppsUseLightTheme"=dword:00000000
        "SystemUsesLightTheme"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableRoundedCorners {
      disable-rounded-corners = mkReg "disable-rounded-corners" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
        "UseWindowFrameStagingBuffer"=dword:00000000
      '';
    })

    (lib.mkIf cfg.classicContextMenu {
      classic-context-menu = mkReg "classic-context-menu" ''
        [HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
        @=""
      '';
    })

    (lib.mkIf cfg.hideSearchBox {
      hide-search-box = mkReg "hide-search-box" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
        "SearchboxTaskbarMode"=dword:00000000
      '';
    })

    (lib.mkIf cfg.hideTaskView {
      hide-task-view = mkReg "hide-task-view" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
        "ShowTaskViewButton"=dword:00000000
      '';
    })

    (lib.mkIf cfg.hideWidgets {
      hide-widgets = mkReg "hide-widgets" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
        "TaskbarDa"=dword:00000000
      '';
    })

    (lib.mkIf cfg.hideCopilot {
      hide-copilot = mkReg "hide-copilot" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
        "ShowCopilotButton"=dword:00000000
      '';
    })

    # ── Privacy / Telemetry ──────────────────────────────

    (lib.mkIf cfg.disableTelemetry {
      disable-telemetry = mkReg "disable-telemetry" ''
        [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
        "AllowTelemetry"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableAdvertisingId {
      disable-advertising-id = mkReg "disable-advertising-id" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
        "Enabled"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableCortana {
      disable-cortana = mkReg "disable-cortana" ''
        [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
        "AllowCortana"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableSuggestedContent {
      disable-suggested-content = mkReg "disable-suggested-content" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
        "SubscribedContent-338393Enabled"=dword:00000000
        "SubscribedContent-353694Enabled"=dword:00000000
        "SubscribedContent-353696Enabled"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableTips {
      disable-tips = mkReg "disable-tips" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
        "SoftLandingEnabled"=dword:00000000

        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
        "ScoobeSystemSettingEnabled"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableActivityHistory {
      disable-activity-history = mkReg "disable-activity-history" ''
        [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
        "EnableActivityFeed"=dword:00000000
        "PublishUserActivities"=dword:00000000
        "UploadUserActivities"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableFeedback {
      disable-feedback = mkReg "disable-feedback" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules]
        "NumberOfSIUFInPeriod"=dword:00000000
        "PeriodInNanoSeconds"=-
      '';
    })

    # ── Performance ──────────────────────────────────────

    (lib.mkIf cfg.disableTransparency {
      disable-transparency = mkReg "disable-transparency" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]
        "EnableTransparency"=dword:00000000
      '';
    })

    (lib.mkIf cfg.disableAnimations {
      disable-animations = mkReg "disable-animations" ''
        [HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics]
        "MinAnimate"="0"

        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
        "TaskbarAnimations"=dword:00000000

        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
        "VisualFXSetting"=dword:00000003
      '';
    })

    (lib.mkIf cfg.disableStartupDelay {
      disable-startup-delay = mkReg "disable-startup-delay" ''
        [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize]
        "StartupDelayInMSec"=dword:00000000
      '';
    })
  ];
}

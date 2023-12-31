{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.icecream.daemon;
in {

  ###### interface

  options = {

    services.icecream.daemon = {

     enable = mkEnableOption (lib.mdDoc "Icecream Daemon");

      openFirewall = mkOption {
        type = types.bool;
        description = lib.mdDoc ''
          Whether to automatically open receive port in the firewall.
        '';
      };

      openBroadcast = mkOption {
        type = types.bool;
        description = lib.mdDoc ''
          Whether to automatically open the firewall for scheduler discovery.
        '';
      };

      cacheLimit = mkOption {
        type = types.ints.u16;
        default = 256;
        description = lib.mdDoc ''
          Maximum size in Megabytes of cache used to store compile environments of compile clients.
        '';
      };

      netName = mkOption {
        type = types.str;
        default = "ICECREAM";
        description = lib.mdDoc ''
          Network name to connect to. A scheduler with the same name needs to be running.
        '';
      };

      noRemote = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Prevent jobs from other nodes being scheduled on this daemon.
        '';
      };

      schedulerHost = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = lib.mdDoc ''
          Explicit scheduler hostname, useful in firewalled environments.

          Uses scheduler autodiscovery via broadcast if set to null.
        '';
      };

      maxProcesses = mkOption {
        type = types.nullOr types.ints.u16;
        default = null;
        description = lib.mdDoc ''
          Maximum number of compile jobs started in parallel for this daemon.

          Uses the number of CPUs if set to null.
        '';
      };

      nice = mkOption {
        type = types.int;
        default = 5;
        description = lib.mdDoc ''
          The level of niceness to use.
        '';
      };

      hostname = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = lib.mdDoc ''
          Hostname of the daemon in the icecream infrastructure.

          Uses the hostname retrieved via uname if set to null.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "icecc";
        description = lib.mdDoc ''
          User to run the icecream daemon as. Set to root to enable receive of
          remote compile environments.
        '';
      };

      package = mkPackageOption pkgs "icecream" { };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = lib.mdDoc "Additional command line parameters.";
        example = [ "-v" ];
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ 10245 ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openBroadcast [ 8765 ];

    systemd.services.icecc-daemon = {
      description = "Icecream compile daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = escapeShellArgs ([
          "${getBin cfg.package}/bin/iceccd"
          "-b" "$STATE_DIRECTORY"
          "-u" "icecc"
          (toString cfg.nice)
        ]
        ++ optionals (cfg.schedulerHost != null) ["-s" cfg.schedulerHost]
        ++ optionals (cfg.netName != null) [ "-n" cfg.netName ]
        ++ optionals (cfg.cacheLimit != null) [ "--cache-limit" (toString cfg.cacheLimit) ]
        ++ optionals (cfg.maxProcesses != null) [ "-m" (toString cfg.maxProcesses) ]
        ++ optionals (cfg.hostname != null) [ "-N" (cfg.hostname) ]
        ++ optional  cfg.noRemote "--no-remote"
        ++ cfg.extraArgs);
        DynamicUser = true;
        User = "icecc";
        Group = "icecc";
        StateDirectory = "icecc";
        RuntimeDirectory = "icecc";
        AmbientCapabilities = "CAP_SYS_CHROOT";
        CapabilityBoundingSet = "CAP_SYS_CHROOT";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ emantor ];
}

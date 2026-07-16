self: {
  config,
  pkgs,
  ...
}: let
  cfg = config.services.octo-fiesta;
  inherit (pkgs) lib;
in {
  options = {
    services.octo-fiesta = {
      enable = lib.mkEnableOption "octo-fiesta, a Subsonic API proxy server that transparently integrates multiple music streaming providers as sources.";

      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        description = "The octo-fiesta package to use";
      };

      subsonic = {
        url = lib.mkOption {
          type = lib.types.str;
          default = null;
          description = "The URL of your Navidrome/Subsonic server";
        };

        admin = {
          username = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = "Admin username to perform actions on navidrome server that require admin permissions (optional)";
          };

          password = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = "Admin Password to perform actions on navidrome server that require admin permissions (optional)";
          };
        };

        musicService = lib.mkOption {
          type = with lib.types; enum ["Deezer" "Qobuz" "SquidWTF" "Yandex"];
          default = "SquidWTF";
          description = "Music provider to use: Deezer, Qobuz, SquidWTF, or Yandex";
        };

        autoUpgradeQuality = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Re-download existing MP3 tracks as FLAC when higher quality is available";
        };

        folderTemplate = lib.mkOption {
          type = lib.types.str;
          default = "{artist}/{album}/{track} - {title}";
          description = ''
            Template for organizing downloaded files into folders.
            See https://github.com/V1ck3s/octo-fiesta/wiki/Configuration#folder-template for more details.
          '';
        };

        enableExternalPlaylists = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable/disable external playlist support";
        };

        playlistsDirectory = lib.mkOption {
          type = lib.types.str;
          default = "playlists";
          description = "Directory name where M3U playlist files are created";
        };

        storageMode = lib.mkOption {
          type = lib.types.enum ["Permanent" "Cache"];
          default = "Permanent";
          description = "Storage mode: Permanent (saved to library), Cache (temporary, auto-cleanup)";
        };

        cacheDurationHours = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Cache duration in hours when StorageMode=Cache";
        };

        explicitFilter = lib.mkOption {
          type = lib.types.enum ["All" "ExplicitOnly" "CleanOnly"];
          default = "All";
          description = "Explicit content filter: All, ExplicitOnly, CleanOnly (default: All)";
        };

        downloadMode = lib.mkOption {
          type = lib.types.enum ["Track" "Album"];
          default = "Track";
          description = "Download mode: Track (only requested track), Album (full album when playing a track)";
        };
      };

      library = {
        downloadPath = lib.mkOption {
          type = with lib.types; nullOr path;
          default = null;
          description = "Directory where downloaded songs are stored";
        };
      };

      deezer = {
        arl = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Your Deezer ARL token";
        };

        arlFallback = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Backup ARL token if primary fails";
        };

        quality = lib.mkOption {
          type = lib.types.enum ["auto" "FLAC" "MP3_320" "MP3_128"];
          default = "auto";
          description = "Preferred audio quality";
        };
      };

      qobuz = {
        userAuthToken = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Your Qobuz User Auth Token";
        };

        userId = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Your Qobuz User ID";
        };

        quality = lib.mkOption {
          type = lib.types.enum ["auto" "FLAC_24_HIGH" "FLAC_24_LOW" "FLAC" "FLAC_16" "MP3_320"];
          default = "auto";
          description = "Preferred audio quality";
        };
      };

      squidWTF = {
        source = lib.mkOption {
          type = lib.types.enum ["Qobuz" "Tidal"];
          default = "Qobuz";
          description = "Backend to use: Qobuz or Tidal";
        };

        quality = lib.mkOption {
          type = lib.types.enum ["auto" "27" "7" "6" "5" "HI_RES_LOSSLESS" "LOSSLESS" "HIGH" "LOW"];
          default = "auto";
          description = "Preferred audio quality";
        };

        instancesTimeoutSeconds = lib.mkOption {
          type = lib.types.int;
          default = 5;
          description = "Timeout in seconds before switching to next instance (Tidal only)";
        };

        instances = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Force a specific Tidal API instance URL (e.g. a self-hosted hifi-api). Disables the remote instances list";
        };

        instancesUrl = lib.mkOption {
          type = with lib.types; nullOr str;
          default = "https://tidal-uptime.geeked.wtf/";
          description = "Override URL of the remote instances.json registry (ignored if a custom instance is set)";
        };

        # qobuzBaseUrl = lib.mkOption {
        #   type = lib.types.str;
        #   default = "https://qobuz.squid.wtf";
        #   description = "Override base URL of the Qobuz backend (e.g. a self-hosted qobuz-dl instance). Useful when the public instance is rate-limited or CAPTCHA-walled (Qobuz only)";
        # };
      };

      yandex = {
        OAuthToken = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "OAuth token for API access (required)";
        };

        quality = lib.mkOption {
          type = lib.types.enum ["FLAC" "MP3_320" "AAC_256" "AAC_192" "MP3_192" "AAC_64"];
          default = "FLAC";
          description = "Preferred audio quality";
        };

        language = lib.mkOption {
          type = lib.types.enum ["en" "uz" "uk" "us" "ru" "kk" "hy"];
          default = "ru";
          description = "Language for API responses. Some titles and curated playlists are translated. Available: en, uz, uk, us, ru, kk, hy";
        };

        includeUnavailable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Include tracks marked unavailable in search results, albums, and playlists";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.octo-fiesta = {
      enable = true;
      after = ["network.target"];
      wantedBy = ["default.target"];
      description = "octo-fiesta, a Subsonic API proxy server that transparently integrates multiple music streaming providers as sources.";
      environment = let
        sub = cfg.subsonic;
        deezer = cfg.deezer;
        qobuz = cfg.qobuz;
        squidwtf = cfg.squidWTF;
        yandex = cfg.yandex;
        boolToString = input:
          if input
          then "true"
          else "false";
      in {
        Subsonic__Url = lib.throwIf (sub.url == null) "Subsonic instance URL must be defined, but is null." (toString sub.url);
        Subsonic__MusicService = toString sub.musicService;
        Subsonic__AdminUsername = toString sub.admin.username;
        Subsonic__AutoUpgradeQuality = boolToString sub.autoUpgradeQuality;
        Subsonic__FolderTemplate = toString sub.folderTemplate;
        Subsonic__EnableExternalPlaylists = boolToString sub.enableExternalPlaylists;
        Subsonic__PlaylistsDirectory = toString sub.playlistsDirectory;
        Subsonic__StorageMode = sub.storageMode;
        Subsonic__CacheDurationHours = toString sub.cacheDurationHours;
        Subsonic__ExplicitFilter = sub.explicitFilter;
        Subsonic__DownloadMode = sub.downloadMode;

        Library__DownloadPath =
          lib.throwIfNot (
            cfg.library.downloadPath != null
            /*
            && lib.pathIsDirectory cfg.library.downloadPath
            */
          ) "The download path must be a valid path."
          (toString cfg.library.downloadPath);

        Deezer__Arl = lib.throwIf (sub.musicService == "Deezer" && deezer.arl == null) "When using Deezer as a music service, the ARL must be provided, but is null." (toString deezer.arl);
        Deezer_ArlFallback = toString deezer.arlFallback;
        Deezer_Quality = toString deezer.quality;

        Qobuz__UserAuthToken = lib.throwIf (sub.musicService == "Qobuz" && qobuz.userAuthToken == null) "When using Qobuz as a music service, the user auth token must be provided, but is null." (toString qobuz.userAuthToken);
        Qobuz__UserId = lib.throwIf (sub.musicService == "Qobuz" && qobuz.userId == null) "When using Qobuz as a music service, the user ID must be provided, but is null." (toString qobuz.userId);
        Qobuz__Quality = toString qobuz.quality;

        SquidWTF__Source = toString squidwtf.source;
        SquidWTF__Quality = toString squidwtf.quality;
        SquidWTF__InstanceTimeoutSeconds = toString squidwtf.instancesTimeoutSeconds;
        SquidWTF__Instance__0 = toString squidwtf.instances;
        SquidWTF__InstancesUrl = toString squidwtf.instancesUrl;

        Yandex__OAuthToken = lib.throwIf (sub.musicService == "Yandex" && yandex.OAuthToken == null) "When using Yandex as a music service, the OAuth token must be provided, but is null." (toString yandex.OAuthToken);
        Yandex__Quality = toString yandex.quality;
        Yandex__Language = toString yandex.language;
        Yandex__IncludeUnavailable = toString yandex.includeUnavailable;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${lib.getExe cfg.package}'';
      };
    };
  };
}
